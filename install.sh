#!/bin/sh
# nautilus bootstrap installer
#
# Drops the always-loaded baseline and selected path-scoped patterns into a
# target project, mirroring LGTM's Claude rule layout:
#   ./.claude/rules/standards.md
#   ./.claude/rules/patterns/README.md
#   ./.claude/rules/patterns/{rust,python,typescript}.md
#
# Source of truth lives in the nautilus repo under templates/. This script
# pulls the tarball at install time so there is no duplication.
#
# Usage:
#   sh install.sh                              # all three languages, current dir
#   sh install.sh --lang rust                  # rust only
#   sh install.sh --lang rust,typescript       # polyglot subset
#   sh install.sh --dest /path/to/project      # different target
#   sh install.sh --force                      # overwrite existing files
#   sh install.sh --ref v1.0.0                 # pin to a tag/branch
#
# Canonical one-liner:
#   curl -fsSL https://raw.githubusercontent.com/tcbuilds/nautilus/main/install.sh | sh
#
# Source: https://github.com/tcbuilds/nautilus

set -eu

REPO_OWNER="tcbuilds"
REPO_NAME="nautilus"

LANG_INPUT=""
DEST="."
FORCE=0
REF="main"

usage() {
	cat <<'EOF'
nautilus bootstrap installer

Usage:
  install.sh [--lang LIST] [--dest DIR] [--force] [--ref REF] [-h|--help]

Options:
  --lang LIST   Comma-separated subset of {rust,python,typescript}.
                Default: all three.
  --dest DIR    Target project directory. Default: current directory.
  --force       Overwrite existing .claude/rules standards or patterns.
                Default: refuse and list conflicts.
  --ref REF     Git ref/tag/branch to pull from. Default: main.
  -h, --help    Print this help and exit.

Examples:
  install.sh
  install.sh --lang rust
  install.sh --lang rust,typescript --dest ./myproj
  install.sh --force --ref v1.0.0
EOF
}

err() {
	printf 'error: %s\n' "$1" >&2
	exit 1
}

while [ $# -gt 0 ]; do
	case "$1" in
		--lang)
			[ $# -ge 2 ] || err "--lang requires a value"
			LANG_INPUT="$2"
			shift 2
			;;
		--lang=*)
			LANG_INPUT="${1#--lang=}"
			shift
			;;
		--dest)
			[ $# -ge 2 ] || err "--dest requires a value"
			DEST="$2"
			shift 2
			;;
		--dest=*)
			DEST="${1#--dest=}"
			shift
			;;
		--force)
			FORCE=1
			shift
			;;
		--ref)
			[ $# -ge 2 ] || err "--ref requires a value"
			REF="$2"
			shift 2
			;;
		--ref=*)
			REF="${1#--ref=}"
			shift
			;;
		-h|--help)
			usage
			exit 0
			;;
		*)
			printf 'error: unknown argument: %s\n' "$1" >&2
			usage >&2
			exit 1
			;;
	esac
done

# Resolve language list; default to all three when no --lang given.
if [ -z "$LANG_INPUT" ]; then
	LANGS="rust python typescript"
else
	# Normalize commas to spaces and validate each token strictly.
	LANGS=$(printf '%s' "$LANG_INPUT" | tr ',' ' ')
	for L in $LANGS; do
		case "$L" in
			rust|python|typescript)
				:
				;;
			*)
				err "invalid --lang value: $L (allowed: rust, python, typescript)"
				;;
		esac
	done
fi

# Tool detection: prefer curl, fall back to wget.
DOWNLOADER=""
if command -v curl >/dev/null 2>&1; then
	DOWNLOADER="curl"
elif command -v wget >/dev/null 2>&1; then
	DOWNLOADER="wget"
else
	err "need curl or wget on PATH"
fi

command -v tar >/dev/null 2>&1 || err "need tar on PATH"

# Create destination if missing; verify it is a directory (not a file).
# Greenfield use case: `install.sh --dest ./my-new-project` should bootstrap
# a fresh project, not error out. Later code already does mkdir -p on the
# nested .claude/rules/ path, so refusing here was inconsistent.
mkdir -p "$DEST" || err "could not create destination: $DEST"
[ -d "$DEST" ] || err "destination is not a directory: $DEST"

# Resolve target paths up front for the conflict pre-flight.
TARGET_RULES_DIR="$DEST/.claude/rules"
TARGET_STANDARDS="$TARGET_RULES_DIR/standards.md"
TARGET_PATTERNS_DIR="$TARGET_RULES_DIR/patterns"
TARGET_PATTERNS_README="$TARGET_PATTERNS_DIR/README.md"

CONFLICTS=""
if [ -e "$TARGET_STANDARDS" ]; then
	CONFLICTS="$CONFLICTS $TARGET_STANDARDS"
fi
if [ -e "$TARGET_PATTERNS_README" ]; then
	CONFLICTS="$CONFLICTS $TARGET_PATTERNS_README"
fi
for L in $LANGS; do
	P="$TARGET_PATTERNS_DIR/$L.md"
	if [ -e "$P" ]; then
		CONFLICTS="$CONFLICTS $P"
	fi
done

if [ -n "$CONFLICTS" ] && [ "$FORCE" -ne 1 ]; then
	printf 'error: target file(s) already exist:\n' >&2
	for C in $CONFLICTS; do
		printf '  %s\n' "$C" >&2
	done
	printf 'hint: re-run with --force to overwrite\n' >&2
	exit 1
fi

# Stage everything in a temp dir; clean up on any exit.
TMP=$(mktemp -d 2>/dev/null || mktemp -d -t nautilus-install)
if [ -z "$TMP" ] || [ ! -d "$TMP" ]; then
	err "could not create temp dir"
fi

cleanup() {
	rm -r "$TMP"
}
trap cleanup EXIT INT HUP TERM

# GitHub serves both branch and tag tarballs from the same archive endpoint.
TARBALL_URL="https://github.com/$REPO_OWNER/$REPO_NAME/archive/$REF.tar.gz"
TARBALL_PATH="$TMP/nautilus.tar.gz"

printf 'fetching %s\n' "$TARBALL_URL"
if [ "$DOWNLOADER" = "curl" ]; then
	curl -fsSL "$TARBALL_URL" -o "$TARBALL_PATH" || err "download failed"
else
	wget -q -O "$TARBALL_PATH" "$TARBALL_URL" || err "download failed"
fi

# GitHub archive top-level dir replaces slashes in the ref with dashes.
ARCHIVE_PREFIX="$REPO_NAME-$(printf '%s' "$REF" | tr '/' '-')"

EXTRACT_DIR="$TMP/extract"
mkdir -p "$EXTRACT_DIR"

# Pull only the paths we need. --strip-components=2 drops "<prefix>/templates/"
# so files land directly under "$EXTRACT_DIR".
tar -xz \
	--strip-components=2 \
	-C "$EXTRACT_DIR" \
	-f "$TARBALL_PATH" \
	"$ARCHIVE_PREFIX/templates/claude-rules" \
	|| err "tar extraction failed"

# Sanity: confirm the expected files arrived.
SRC_RULES_DIR="$EXTRACT_DIR/claude-rules"
SRC_STANDARDS="$SRC_RULES_DIR/standards.md"
SRC_PATTERNS_DIR="$SRC_RULES_DIR/patterns"
SRC_PATTERNS_README="$SRC_PATTERNS_DIR/README.md"

[ -f "$SRC_STANDARDS" ] || err "missing extracted file: claude-rules/standards.md"
[ -d "$SRC_PATTERNS_DIR" ] || err "missing extracted dir: claude-rules/patterns"
[ -f "$SRC_PATTERNS_README" ] || err "missing extracted file: claude-rules/patterns/README.md"
for L in $LANGS; do
	[ -f "$SRC_PATTERNS_DIR/$L.md" ] \
		|| err "missing extracted file: claude-rules/patterns/$L.md"
done

# All inputs validated. Write outputs.
mkdir -p "$TARGET_PATTERNS_DIR"

cp "$SRC_STANDARDS" "$TARGET_STANDARDS"
WRITTEN="$TARGET_STANDARDS"
COUNT=1

cp "$SRC_PATTERNS_README" "$TARGET_PATTERNS_README"
WRITTEN="$WRITTEN
$TARGET_PATTERNS_README"
COUNT=$((COUNT + 1))

for L in $LANGS; do
	cp "$SRC_PATTERNS_DIR/$L.md" "$TARGET_PATTERNS_DIR/$L.md"
	WRITTEN="$WRITTEN
$TARGET_PATTERNS_DIR/$L.md"
	COUNT=$((COUNT + 1))
done

printf '\nwrote %d file(s):\n' "$COUNT"
printf '%s\n' "$WRITTEN" | sed 's/^/  /'
printf '\ndone. source: https://github.com/%s/%s (ref: %s)\n' "$REPO_OWNER" "$REPO_NAME" "$REF"
