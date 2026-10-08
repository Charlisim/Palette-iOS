#!/bin/bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
validation_root="$(mktemp -d "${TMPDIR:-/tmp}/palette-validation.XXXXXX")"
trap 'rm -rf "$validation_root"' EXIT
result_root="${PALETTE_RESULTS_DIR:-$validation_root/results}"
mkdir -p "$result_root" "$validation_root/package"

# A separate workspace ensures xcodebuild selects SPM instead of the legacy project.
ln -s "$repo_root/Package.swift" "$validation_root/package/Package.swift"
ln -s "$repo_root/Palette" "$validation_root/package/Palette"
ln -s "$repo_root/PaletteTests" "$validation_root/package/PaletteTests"

if [[ -n "${PALETTE_DESTINATION:-}" ]]; then
    destination="$PALETTE_DESTINATION"
else
    sdk_version="$(xcrun --sdk iphonesimulator --show-sdk-version)"
    device_id="$(xcrun simctl list devices available -j | python3 -c '
import json, sys
sdk = tuple((list(map(int, sys.argv[1].split("."))) + [0])[:2])
sets = json.load(sys.stdin)["devices"]
runtimes = []
for runtime, devices in sets.items():
    if ".iOS-" in runtime:
        version = tuple((list(map(int, runtime.split(".iOS-")[1].split("-"))) + [0])[:2])
        if (17, 0) <= version <= sdk:
            runtimes.append((version, devices))
for _, devices in sorted(runtimes, key=lambda item: item[0], reverse=True):
    for device in devices:
        if device["name"].startswith("iPhone"):
            print(device["udid"])
            sys.exit(0)
sys.exit("No compatible iPhone simulator (iOS 17+); set PALETTE_DESTINATION explicitly.")
' "$sdk_version")"
    destination="platform=iOS Simulator,id=$device_id"
fi

xcodebuild -version
xcrun swift --version
(
    cd "$validation_root/package"
    xcodebuild -scheme Palette -destination "$destination" \
        -derivedDataPath "$validation_root/spm" \
        -resultBundlePath "$result_root/package.xcresult" test CODE_SIGNING_ALLOWED=NO
)
xcodebuild -project "$repo_root/Palette-iOS.xcodeproj" -scheme Example \
    -destination "$destination" -derivedDataPath "$validation_root/project" \
    -resultBundlePath "$result_root/project.xcresult" test CODE_SIGNING_ALLOWED=NO
xcodebuild -project "$repo_root/Palette-iOS.xcodeproj" -scheme 'Example Objective-C' \
    -configuration Debug -destination "$destination" -derivedDataPath "$validation_root/objc" \
    CODE_SIGNING_ALLOWED=NO build
xcodebuild -project "$repo_root/Palette-iOS.xcodeproj" -scheme Palette \
    -configuration Release -destination 'generic/platform=iOS' \
    -derivedDataPath "$validation_root/release" CODE_SIGNING_ALLOWED=NO build
