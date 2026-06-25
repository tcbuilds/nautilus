#!/bin/sh
# nautilus user-level tooling installer
#
# Companion to install.sh. Where install.sh drops the project-level coding
# standards into a target repo, this script syncs Claude Code user-level
# tooling into the user's home directory:
#
#   ~/.claude/skills/<skill-name>/...
#   ~/.claude/agents/<agent-name>.md
#
# Source of truth lives in the nautilus repo under skills/ and agents/.
# Each skill is a directory containing at minimum SKILL.md (plus optional
# scripts and assets that travel with it). Each agent is a single markdown
# file with frontmatter. The repo-level framing READMEs (skills/README.md,
# agents/README.md) are excluded — those are docs about the convention, not
# loadable user-level artifacts.
#
# Default behavior is to overwrite existing files in place. This is a sync
# semantic: pull the latest sanitized versions from the playbook and replace
# whatever is currently installed. Pass --no-overwrite if you would rather
# refuse on conflict.
#
# Usage:
#   sh install-tools.sh                              # all skills + all agents
#   sh install-tools.sh --skills foo,bar             # subset of skills
#   sh install-tools.sh --agents baz                 # subset of agents
#   sh install-tools.sh --skills all --agents none   # explicit aliases
#   sh install-tools.sh --dest /custom/.claude       # different home
#   sh install-tools.sh --no-overwrite               # refuse to clobber
#   sh install-tools.sh --ref v1.0.0                 # pin to a tag/branch
#
# Canonical one-liner:
#   curl -fsSL https://raw.githubusercontent.com/tcbuilds/nautilus/main/install-tools.sh | sh
#
# Source: https://github.com/tcbuilds/nautilus

set -eu

REPO_OWNER="tcbuilds"
REPO_NAME="nautilus"

SKILLS_INPUT=""
AGENTS_INPUT=""
DEST="$HOME/.claude"
OVERWRITE=1
REF="main"

usage() {
	cat <<'EOF'
nautilus user-level tooling installer

Usage:
  install-tools.sh [--skills LIST] [--agents LIST] [--dest DIR]
                   [--no-overwrite] [--ref REF] [-h|--help]

Options:
  --skills LIST    Comma-separated skill names, or "all". Default: all.
  --agents LIST    Comma-separated agent names (no .md), or "all". Default: all.
  --dest DIR       Root user-config dir. Default: $HOME/.claude.
                   Writes to $DEST/skills/ and $DEST/agents/.
  --no-overwrite   Refuse to overwrite existing files. Default: overwrite.
  --ref REF        Git ref/tag/branch to pull from. Default: main.
  -h, --help       Print this help and exit.

Examples:
  install-tools.sh
  install-tools.sh --skills refine-spec,build
  install-tools.sh --agents git-platform-engineer --no-overwrite
  install-tools.sh --dest /tmp/fresh-claude --ref v1.0.0
EOF
}

err() {
	printf 'error: %s\n' "$1" >&2
	exit 1
}

note() {
	printf '%s\n' "$1"
}

# Parse args.
while [ $# -gt 0 ]; do
	case "$1" in
		--skills)
			[ $# -ge 2 ] || err "--skills requires a value"
			SKILLS_INPUT="$2"
			shift 2
			;;
		--skills=*)
			SKILLS_INPUT="${1#--skills=}"
			shift
			;;
		--agents)
			[ $# -ge 2 ] || err "--agents requires a value"
			AGENTS_INPUT="$2"
			shift 2
			;;
		--agents=*)
			AGENTS_INPUT="${1#--agents=}"
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
		--no-overwrite)
			OVERWRITE=0
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

# Tool detection: prefer curl, fall back to wget. Same posture as install.sh.
DOWNLOADER=""
if command -v curl >/dev/null 2>&1; then
	DOWNLOADER="curl"
elif command -v wget >/dev/null 2>&1; then
	DOWNLOADER="wget"
else
	err "need curl or wget on PATH"
fi

command -v tar >/dev/null 2>&1 || err "need tar on PATH"

# Resolve and verify destination.
mkdir -p "$DEST" || err "could not create destination: $DEST"
[ -d "$DEST" ] || err "destination is not a directory: $DEST"

DEST_SKILLS="$DEST/skills"
DEST_AGENTS="$DEST/agents"

# Stage everything in a temp dir; clean up on any exit.
TMP=$(mktemp -d 2>/dev/null || mktemp -d -t nautilus-tools)
[ -n "$TMP" ] && [ -d "$TMP" ] || err "could not create temp dir"

cleanup() {
	rm -rf "$TMP"
}
trap cleanup EXIT INT HUP TERM

# GitHub serves both branch and tag tarballs from the same archive endpoint.
TARBALL_URL="https://github.com/$REPO_OWNER/$REPO_NAME/archive/$REF.tar.gz"
TARBALL_PATH="$TMP/nautilus.tar.gz"

note "fetching $TARBALL_URL"
if [ "$DOWNLOADER" = "curl" ]; then
	curl -fsSL "$TARBALL_URL" -o "$TARBALL_PATH" || err "download failed"
else
	wget -q -O "$TARBALL_PATH" "$TARBALL_URL" || err "download failed"
fi

# GitHub archive top-level dir replaces slashes in the ref with dashes.
ARCHIVE_PREFIX="$REPO_NAME-$(printf '%s' "$REF" | tr '/' '-')"

EXTRACT_DIR="$TMP/extract"
mkdir -p "$EXTRACT_DIR"

# Pull only the paths we need. --strip-components=1 drops the
# "<prefix>/" directory layer so files land under "$EXTRACT_DIR/skills"
# and "$EXTRACT_DIR/agents".
tar -xz \
	--strip-components=1 \
	-C "$EXTRACT_DIR" \
	-f "$TARBALL_PATH" \
	"$ARCHIVE_PREFIX/skills" \
	"$ARCHIVE_PREFIX/agents" \
	|| err "tar extraction failed"

SRC_SKILLS="$EXTRACT_DIR/skills"
SRC_AGENTS="$EXTRACT_DIR/agents"

[ -d "$SRC_SKILLS" ] || err "missing extracted dir: skills"
[ -d "$SRC_AGENTS" ] || err "missing extracted dir: agents"

# Discover available skills (directories under skills/).
# Excludes the framing README.md regardless of user input.
AVAILABLE_SKILLS=""
for D in "$SRC_SKILLS"/*/; do
	# Bare glob with no matches expands to literal "<dir>/*/"; skip that.
	[ -d "$D" ] || continue
	NAME=$(basename "$D")
	case "$NAME" in
		README.md|README)
			continue
			;;
	esac
	AVAILABLE_SKILLS="$AVAILABLE_SKILLS $NAME"
done

# Discover available agents (markdown files under agents/, no README.md).
AVAILABLE_AGENTS=""
for F in "$SRC_AGENTS"/*.md; do
	[ -f "$F" ] || continue
	BASE=$(basename "$F" .md)
	case "$BASE" in
		README)
			continue
			;;
	esac
	AVAILABLE_AGENTS="$AVAILABLE_AGENTS $BASE"
done

# Resolve skill selection.
if [ "$SKILLS_INPUT" = "none" ]; then
	SELECTED_SKILLS=""
elif [ -z "$SKILLS_INPUT" ] || [ "$SKILLS_INPUT" = "all" ]; then
	SELECTED_SKILLS="$AVAILABLE_SKILLS"
else
	SELECTED_SKILLS=""
	REQUESTED=$(printf '%s' "$SKILLS_INPUT" | tr ',' ' ')
	for REQ in $REQUESTED; do
		FOUND=0
		for AVAIL in $AVAILABLE_SKILLS; do
			if [ "$REQ" = "$AVAIL" ]; then
				FOUND=1
				break
			fi
		done
		if [ "$FOUND" -ne 1 ]; then
			printf 'error: unknown skill: %s\n' "$REQ" >&2
			if [ -n "$AVAILABLE_SKILLS" ]; then
				printf 'available skills:\n' >&2
				for A in $AVAILABLE_SKILLS; do
					printf '  %s\n' "$A" >&2
				done
			else
				printf 'no skills are available in ref %s\n' "$REF" >&2
			fi
			exit 1
		fi
		SELECTED_SKILLS="$SELECTED_SKILLS $REQ"
	done
fi

# Resolve agent selection.
if [ "$AGENTS_INPUT" = "none" ]; then
	SELECTED_AGENTS=""
elif [ -z "$AGENTS_INPUT" ] || [ "$AGENTS_INPUT" = "all" ]; then
	SELECTED_AGENTS="$AVAILABLE_AGENTS"
else
	SELECTED_AGENTS=""
	REQUESTED=$(printf '%s' "$AGENTS_INPUT" | tr ',' ' ')
	for REQ in $REQUESTED; do
		FOUND=0
		for AVAIL in $AVAILABLE_AGENTS; do
			if [ "$REQ" = "$AVAIL" ]; then
				FOUND=1
				break
			fi
		done
		if [ "$FOUND" -ne 1 ]; then
			printf 'error: unknown agent: %s\n' "$REQ" >&2
			if [ -n "$AVAILABLE_AGENTS" ]; then
				printf 'available agents:\n' >&2
				for A in $AVAILABLE_AGENTS; do
					printf '  %s\n' "$A" >&2
				done
			else
				printf 'no agents are available in ref %s\n' "$REF" >&2
			fi
			exit 1
		fi
		SELECTED_AGENTS="$SELECTED_AGENTS $REQ"
	done
fi

# Trim leading whitespace produced by accumulation above.
SELECTED_SKILLS=$(printf '%s' "$SELECTED_SKILLS" | sed 's/^ *//')
SELECTED_AGENTS=$(printf '%s' "$SELECTED_AGENTS" | sed 's/^ *//')

# Empty payload is not an error in early phases. Phase 1 ships only framing
# READMEs; the skill/agent payload fills out as artifacts mature.
if [ -z "$SELECTED_SKILLS" ] && [ -z "$SELECTED_AGENTS" ]; then
	note "no skills available in ref $REF"
	note "no agents available in ref $REF"
	note "nothing to install. exit 0."
	exit 0
fi

# Pre-flight conflict check when --no-overwrite is set.
if [ "$OVERWRITE" -eq 0 ]; then
	CONFLICTS=""
	for S in $SELECTED_SKILLS; do
		if [ -e "$DEST_SKILLS/$S" ]; then
			CONFLICTS="$CONFLICTS $DEST_SKILLS/$S"
		fi
	done
	for A in $SELECTED_AGENTS; do
		if [ -e "$DEST_AGENTS/$A.md" ]; then
			CONFLICTS="$CONFLICTS $DEST_AGENTS/$A.md"
		fi
	done
	if [ -n "$CONFLICTS" ]; then
		printf 'error: target file(s) already exist:\n' >&2
		for C in $CONFLICTS; do
			printf '  %s\n' "$C" >&2
		done
		printf 'hint: drop --no-overwrite to replace them\n' >&2
		exit 1
	fi
fi

# Ensure target dirs exist only when we actually have something to write.
if [ -n "$SELECTED_SKILLS" ]; then
	mkdir -p "$DEST_SKILLS" || err "could not create $DEST_SKILLS"
	[ -d "$DEST_SKILLS" ] || err "not a directory: $DEST_SKILLS"
fi
if [ -n "$SELECTED_AGENTS" ]; then
	mkdir -p "$DEST_AGENTS" || err "could not create $DEST_AGENTS"
	[ -d "$DEST_AGENTS" ] || err "not a directory: $DEST_AGENTS"
fi

# Install skills. Remove existing target directory before copying so files
# removed in a newer skill version do not stick around as stale leftovers.
SKILL_COUNT=0
WRITTEN_SKILLS=""
if [ -z "$SELECTED_SKILLS" ]; then
	note "no skills available in ref $REF"
else
	for S in $SELECTED_SKILLS; do
		SRC="$SRC_SKILLS/$S"
		DST="$DEST_SKILLS/$S"
		[ -d "$SRC" ] || err "internal: skill source missing: $SRC"
		if [ -e "$DST" ]; then
			rm -rf "$DST" || err "could not remove existing: $DST"
		fi
		cp -pR "$SRC" "$DEST_SKILLS/" || err "copy failed for skill: $S"
		SKILL_COUNT=$((SKILL_COUNT + 1))
		WRITTEN_SKILLS="$WRITTEN_SKILLS
$DST"
	done
fi

# Install agents.
AGENT_COUNT=0
WRITTEN_AGENTS=""
if [ -z "$SELECTED_AGENTS" ]; then
	note "no agents available in ref $REF"
else
	for A in $SELECTED_AGENTS; do
		SRC="$SRC_AGENTS/$A.md"
		DST="$DEST_AGENTS/$A.md"
		[ -f "$SRC" ] || err "internal: agent source missing: $SRC"
		cp -p "$SRC" "$DST" || err "copy failed for agent: $A"
		AGENT_COUNT=$((AGENT_COUNT + 1))
		WRITTEN_AGENTS="$WRITTEN_AGENTS
$DST"
	done
fi

# Summary.
TOTAL=$((SKILL_COUNT + AGENT_COUNT))
printf '\nwrote %d artifact(s): %d skill(s), %d agent(s)\n' \
	"$TOTAL" "$SKILL_COUNT" "$AGENT_COUNT"
if [ "$SKILL_COUNT" -gt 0 ]; then
	printf 'skills:\n'
	printf '%s\n' "$WRITTEN_SKILLS" | sed '/^$/d; s/^/  /'
fi
if [ "$AGENT_COUNT" -gt 0 ]; then
	printf 'agents:\n'
	printf '%s\n' "$WRITTEN_AGENTS" | sed '/^$/d; s/^/  /'
fi
printf '\ndone. source: https://github.com/%s/%s (ref: %s)\n' \
	"$REPO_OWNER" "$REPO_NAME" "$REF"
