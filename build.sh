#!/usr/bin/env bash
set -euo pipefail

# Usage: ./build.sh -v <version> [-a <app name>] [-o <dmg path>]
# Example:
#   ./build.sh -v 1.0.1 -a "Pirrot" -o Releases/Pirrot-1.0.1.dmg

VERSION=""
APP_NAME="Pirrot"
DMG_OUT=""

while getopts "v:a:o:" opt; do
    case "$opt" in
        v) VERSION="$OPTARG" ;;
        a) APP_NAME="$OPTARG" ;;
        o) DMG_OUT="$OPTARG" ;;
        *) echo "Usage: $0 -v <version> [-a <app name>] [-o <dmg path>]"; exit 1 ;;
    esac
done

if [[ -z "$VERSION" ]]; then
    echo "Version is required. Usage: $0 -v <version> [-a <app name>] [-o <dmg path>]"
    exit 1
fi

if [[ ! -d "${APP_NAME}.app" ]]; then
    echo "Missing app bundle: ${APP_NAME}.app"
    exit 1
fi

if [[ ! -f "dmg-bg.png" ]]; then
    echo "Missing DMG background: dmg-bg.png"
    exit 1
fi

DMG_NAME="${DMG_OUT:-Releases/Pirrot-${VERSION}.dmg}"
mkdir -p "$(dirname "$DMG_NAME")"

echo "Building $DMG_NAME from ${APP_NAME}.app ..."

create-dmg \
    --volname "$APP_NAME" \
    --volicon "${APP_NAME}.app/Contents/Resources/AppIcon.icns" \
    --background "dmg-bg.png" \
    --window-pos 200 120 \
    --window-size 660 400 \
    --icon-size 120 \
    --icon "${APP_NAME}.app" 170 210 \
    --hide-extension "${APP_NAME}.app" \
    --app-drop-link 490 210 \
    "$DMG_NAME" \
    "${APP_NAME}.app"

echo "Created: $DMG_NAME"
