#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="${HUIXIN_BUILD_DIR:-$ROOT/build}"
xcodebuild -project "$ROOT/SkillsBar.xcodeproj" -scheme SkillsBar -configuration Release -derivedDataPath "$BUILD_DIR/DerivedData" CODE_SIGNING_ALLOWED=NO build
APP="$BUILD_DIR/DerivedData/Build/Products/Release/HuixinSkillsManager.app"
mkdir -p "$APP/Contents/Resources/Licenses"
cp "$ROOT/LICENSE" "$ROOT/NOTICE" "$APP/Contents/Resources/Licenses/"
cp "$ROOT/licenses/SkillsBar-Apache-2.0.txt" "$APP/Contents/Resources/Licenses/"
codesign --force --deep --sign - "$APP"
"$APP/Contents/MacOS/HuixinSkillsManager" --self-test
mkdir -p "$BUILD_DIR/distribution"
ditto "$APP" "$BUILD_DIR/distribution/汇芯技能管家.app"
ditto -c -k --sequesterRsrc --keepParent "$BUILD_DIR/distribution/汇芯技能管家.app" "$BUILD_DIR/huixin-skills-manager-macos.zip"
echo "已生成：$BUILD_DIR/huixin-skills-manager-macos.zip"
