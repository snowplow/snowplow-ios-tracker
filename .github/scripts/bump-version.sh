#!/usr/bin/env bash
# Bump the tracker version across all files that the "Prepare for release" commit touches.
# Usage: bump-version.sh <X.Y.Z>
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <X.Y.Z>" >&2
  exit 2
fi

NEW_VERSION="$1"

if [[ ! "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Invalid version '$NEW_VERSION' (expected X.Y.Z)" >&2
  exit 2
fi

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$REPO_ROOT"

# 1. VERSION
echo "$NEW_VERSION" > VERSION

# 2. SnowplowTracker.podspec — line: s.version = "X.Y.Z"
sed -i.bak -E "s/(s\.version[[:space:]]*=[[:space:]]*)\"[0-9]+\.[0-9]+\.[0-9]+\"/\1\"$NEW_VERSION\"/" SnowplowTracker.podspec
rm SnowplowTracker.podspec.bak

# 3. Sources/Core/TrackerConstants.swift — line: let kSPRawVersion = "X.Y.Z"
sed -i.bak -E "s/(let kSPRawVersion[[:space:]]*=[[:space:]]*)\"[0-9]+\.[0-9]+\.[0-9]+\"/\1\"$NEW_VERSION\"/" Sources/Core/TrackerConstants.swift
rm Sources/Core/TrackerConstants.swift.bak

# Sanity check: all three files must now contain the new version exactly once on the expected line.
grep -q "^$NEW_VERSION\$" VERSION
grep -q "s.version[[:space:]]*=[[:space:]]*\"$NEW_VERSION\"" SnowplowTracker.podspec
grep -q "let kSPRawVersion[[:space:]]*=[[:space:]]*\"$NEW_VERSION\"" Sources/Core/TrackerConstants.swift

echo "Bumped to $NEW_VERSION:"
echo "  VERSION"
echo "  SnowplowTracker.podspec"
echo "  Sources/Core/TrackerConstants.swift"
