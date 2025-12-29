#!/usr/bin/env bash

# إيقاف السكربت فوراً عند أي خطأ
set -e
set -o pipefail

echo "🚀 بدء عملية بناء الإصدار..."

# التأكد من أننا داخل مستودع Git
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "❌ هذا المجلد ليس مستودع Git"
  exit 1
fi

# تنظيف أي build قديم لضمان نسخة محدثة
echo "🧹 تنظيف ملفات البناء القديمة..."
./gradlew clean

# بناء APK Release
echo "📦 بناء APK Release..."
./gradlew assembleRelease

# بناء AAB Release
echo "📦 بناء AAB Release..."
./gradlew bundleRelease

# التحقق من وجود ملفات APK و AAB
APK_COUNT=$(find . -name "*release*.apk" | wc -l)
AAB_COUNT=$(find . -name "*release*.aab" | wc -l)

if [ "$APK_COUNT" -eq 0 ] || [ "$AAB_COUNT" -eq 0 ]; then
  echo "❌ لم يتم العثور على ملفات APK أو AAB بعد البناء"
  exit 1
fi

echo "✅ تم التأكد من وجود ملفات APK و AAB"

# إضافة ملفات الإصدار بالقوة
echo "➕ إضافة ملفات release-artifacts إلى Git بالقوة..."
git add --force release-artifacts/

echo "✅ تمت العملية بنجاح"
echo "📌 يمكنك الآن تنفيذ:"
echo "   git commit -m \"Update release APK & AAB\""
