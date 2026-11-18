#!/usr/bin/env bash
# scripts/install.sh — shae-objective-c-macos-notes
#
# SHAE Notes — a macOS notes app in Objective-C (Foundation).
#
# Requires clang with Objective-C support and the Foundation framework
# (Xcode on macOS). Not available for compile-testing in this environment:
# clang is present but the Foundation SDK is not; see README.md.

set -euo pipefail

echo "=== shae-objective-c-macos-notes install ==="
echo ""

echo "Requirements:"
echo "  - clang with Objective-C support (Xcode Command Line Tools on macOS)"
echo "  - Foundation framework (macOS SDK)"
echo ""

if command -v clang >/dev/null 2>&1; then
  echo "clang found: $(clang --version | head -n 1)"
else
  echo "clang not found on PATH. Install Xcode Command Line Tools:"
  echo "  macOS: xcode-select --install"
fi

# Check for Foundation headers (macOS SDK)
FOUNDATION_H="/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/Foundation.framework/Headers/Foundation.h"
if [ -f "$FOUNDATION_H" ]; then
  echo "Foundation SDK found at: $FOUNDATION_H"
else
  echo "Foundation framework headers not found at default Xcode SDK path."
  echo "Install Xcode / macOS SDK."
fi

echo ""
echo "=== Build & run (macOS) ==="
echo "# From the project root:"
echo "  cd shae-objective-c-macos-notes/src"
echo "  clang -fobjc-arc -framework Foundation Notes.m -o Notes"
echo "  ./Notes"
echo ""
echo "The app creates/reads notes.json (JSON persistence) and supports:"
echo "  create, list, view/edit, delete notes"
