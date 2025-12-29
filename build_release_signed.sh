#!/bin/bash set -e

==================================================
TEST AUTOMATION SCRIPT
Build APK + AAB and upload to GitHub in ONE STEP
==================================================
⚠️ TEST TOKEN PLACEHOLDER
Replace YOUR_TOKEN_HERE with your own token if needed
export GITHUB_TOKEN=YOUR_TOKEN_HERE

===== CONFIG =====
REPO_OWNER="DevImpact"
REPO_NAME="Job"
BRANCH="main"

OUTPUT_DIR="release-artifacts"

APK_SRC="app/build/outputs/apk/release/app-release.apk" AAB_SRC="app/build/outputs/bundle/release/app-release.aab"

echo "==========================================" echo " TEST BUILD: APK + AAB (ONE STEP)" echo "==========================================" echo ""

===== TOKEN CHECK =====
if [ -z "$GITHUB_TOKEN" ] || [ "$GITHUB_TOKEN" = "YOUR_TOKEN_HERE" ]; then echo "❌ GITHUB_TOKEN is not set or still placeholder" exit 1 fi

===== BUILD =====
echo "🧹 Cleaning project..." chmod +x ./gradlew ./gradlew clean

echo "📦 Building APK..." ./gradlew assembleRelease

echo "📦 Building AAB..." ./gradlew bundleRelease

===== COLLECT ARTIFACTS =====
echo "📁 Collecting artifacts..." mkdir -p "$OUTPUT_DIR"

cp "$APK_SRC" "$OUTPUT_DIR/app-release.apk" cp "$AAB_SRC" "$OUTPUT_DIR/app-release.aab"

===== GIT SETUP =====
echo "🔧 Configuring git user..." git config user.name "automation-bot" git config user.email "automation-bot@local"

git checkout "$BRANCH" git pull origin "$BRANCH"

===== COMMIT & PUSH =====
echo "🚀 Uploading artifacts to GitHub..." git add "$OUTPUT_DIR" git commit -m "Automated test release (APK + AAB)" || echo "Nothing to commit"

git push https://$GITHUB_TOKEN@github.com/$REPO_OWNER/$REPO_NAME.git "$BRANCH"

echo "" echo "✅ DONE" echo "Artifacts available in:" echo " $OUTPUT_DIR/app-release.apk" echo " $OUTPUT_DIR/app-release.aab"