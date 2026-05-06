#!/bin/sh
# nautilus bootstrap installer
#
# Drops the cross-language baseline (codingStandards.md) and selected per-language
# pattern files into a target project, mirroring the canonical deployment shape:
#   ./codingStandards.md
#   ./.claude/rules/README.md
#   ./.claude/rules/{rust,python,typescript}-patterns.md
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
  --force       Overwrite existing codingStandards.md or .claude/rules/*.md.
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

# Verify destination exists.
[ -d "$DEST" ] || err "destination does not exist: $DEST"

# Resolve target paths up front for the conflict pre-flight.
TARGET_STANDARDS="$DEST/codingStandards.md"
TARGET_RULES_DIR="$DEST/.claude/rules"
TARGET_RULES_README="$TARGET_RULES_DIR/README.md"

CONFLICTS=""
if [ -e "$TARGET_STANDARDS" ]; then
	CONFLICTS="$CONFLICTS $TARGET_STANDARDS"
fi
if [ -e "$TARGET_RULES_README" ]; then
	CONFLICTS="$CONFLICTS $TARGET_RULES_README"
fi
for L in $LANGS; do
	P="$TARGET_RULES_DIR/$L-patterns.md"
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
[ -n "$TMP" ] && [ -d "$TMP" ] || err "could not create temp dir"

cleanup() {
	rm -rf "$TMP"
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
	"$ARCHIVE_PREFIX/templates/codingStandards.md" \
	"$ARCHIVE_PREFIX/templates/language-rules" \
	|| err "tar extraction failed"

# Sanity: confirm the expected files arrived.
SRC_STANDARDS="$EXTRACT_DIR/codingStandards.md"
SRC_RULES_DIR="$EXTRACT_DIR/language-rules"
SRC_RULES_README="$SRC_RULES_DIR/README.md"

[ -f "$SRC_STANDARDS" ] || err "missing extracted file: codingStandards.md"
[ -d "$SRC_RULES_DIR" ] || err "missing extracted dir: language-rules"
[ -f "$SRC_RULES_README" ] || err "missing extracted file: language-rules/README.md"
for L in $LANGS; do
	[ -f "$SRC_RULES_DIR/$L-patterns.md" ] \
		|| err "missing extracted file: language-rules/$L-patterns.md"
done

# All inputs validated. Write outputs.
mkdir -p "$TARGET_RULES_DIR"

cp "$SRC_STANDARDS" "$TARGET_STANDARDS"
WRITTEN="$TARGET_STANDARDS"
COUNT=1

cp "$SRC_RULES_README" "$TARGET_RULES_README"
WRITTEN="$WRITTEN
$TARGET_RULES_README"
COUNT=$((COUNT + 1))

for L in $LANGS; do
	cp "$SRC_RULES_DIR/$L-patterns.md" "$TARGET_RULES_DIR/$L-patterns.md"
	WRITTEN="$WRITTEN
$TARGET_RULES_DIR/$L-patterns.md"
	COUNT=$((COUNT + 1))
done

printf '\nwrote %d file(s):\n' "$COUNT"
printf '%s\n' "$WRITTEN" | sed 's/^/  /'
printf '\ndone. source: https://github.com/%s/%s (ref: %s)\n' "$REPO_OWNER" "$REPO_NAME" "$REF"
