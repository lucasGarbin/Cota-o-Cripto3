#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter não foi encontrado no PATH."
  exit 1
fi

if [ ! -f android/gradlew ]; then
  echo "Gerando plataformas Android/iOS/Web com o Flutter instalado..."
  flutter create --platforms=android,ios,web .
  cp mobile_branding/android/AndroidManifest.xml android/app/src/main/AndroidManifest.xml
  cp -R mobile_branding/android/res/. android/app/src/main/res/
  if [ -d ios/Runner/Assets.xcassets ]; then
    rm -rf ios/Runner/Assets.xcassets/AppIcon.appiconset ios/Runner/Assets.xcassets/LaunchImage.imageset
    cp -R mobile_branding/ios/Assets.xcassets/AppIcon.appiconset ios/Runner/Assets.xcassets/
    cp -R mobile_branding/ios/Assets.xcassets/LaunchImage.imageset ios/Runner/Assets.xcassets/
  fi
fi

flutter pub get
echo "Projeto preparado."
