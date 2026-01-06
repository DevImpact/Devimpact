#!/bin/sh

set -e

echo "🧹 Cleaning TEST signing artifacts..."
echo "------------------------------------"

PROJECT_ROOT="$(pwd)"

# 1️⃣ حذف ملفات keystore التجريبية المعروفة
echo "🗑 Removing test keystore files..."

find "$PROJECT_ROOT" -type f \( \
  -name "test-release.jks" \
  -o -name "debug.keystore" \
  -o -name "*test*.jks" \
\) -print -delete || true

# حذف keystore.properties التجريبي فقط إذا كان يحتوي على test
if [ -f "$PROJECT_ROOT/android/keystore.properties" ]; then
  if grep -qi "test" "$PROJECT_ROOT/android/keystore.properties"; then
    echo "🗑 Removing TEST keystore.properties"
    rm -f "$PROJECT_ROOT/android/keystore.properties"
  fi
fi

# 2️⃣ البحث عن كلمات مرور وهمية أو قيم اختبار
echo "🔍 Scanning for TEST passwords / aliases..."

FORBIDDEN_PATTERNS="
testStorePassword
testAlias
password123
TESTING ONLY
DO NOT use in production
"

for pattern in $FORBIDDEN_PATTERNS; do
  if grep -RIn "$pattern" "$PROJECT_ROOT/android" >/dev/null 2>&1; then
    echo "❌ FORBIDDEN TEST VALUE FOUND: $pattern"
    echo "   Remove all testing credentials before production."
    exit 1
  fi
done

# 3️⃣ منع أي توليد تلقائي للـ keystore (keytool / bash)
echo "🔍 Checking for automatic keystore generation..."

if grep -RIn --exclude=prepare_production_signing.sh "keytool -genkeypair" "$PROJECT_ROOT" >/dev/null 2>&1; then
  echo "❌ Automatic keystore generation detected!"
  echo "   Keystore MUST be created manually and stored securely."
  exit 1
fi

if grep -RIn --exclude=prepare_production_signing.sh "#!/bin/bash" "$PROJECT_ROOT" | grep -i keystore >/dev/null 2>/dev/null 2>&1; then
  echo "❌ Bash script related to keystore detected!"
  exit 1
fi

# 4️⃣ التحقق من أن release يعتمد على keystore.properties فقط
echo "🔐 Validating Gradle release signing..."

GRADLE_FILE="$PROJECT_ROOT/app/build.gradle.kts"

if ! grep -q "signingConfigs.*release" "$GRADLE_FILE"; then
  echo "❌ Release signingConfig not found!"
  exit 1
fi

if grep -q "test-release.jks" "$GRADLE_FILE"; then
  echo "❌ test-release.jks referenced in Gradle!"
  exit 1
fi

echo ""
echo "✅ SUCCESS"
echo "✔ All test signing artifacts removed"
echo "✔ No fake passwords detected"
echo "✔ No automatic keystore generation"
echo "✔ Project is ready for PRODUCTION signing"
echo ""
