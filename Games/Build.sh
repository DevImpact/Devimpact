#!/bin/bash

# 📁 مجلد الوثائق
DOCS_DIR="docs"

# 📁 مجلد Builds داخل المشروع
BUILDS_DIR="Build/Builds"

# 📄 اسم ملف التقرير النهائي
OUTPUT_MD="MISSING_BUILDS_AUDIT.md"

# 🔹 ملفات مؤقتة
TMP_REQ=$(mktemp)
TMP_EXISTING=$(mktemp)

# 1️⃣ إنشاء ملف Markdown للتقرير
echo "# Unity Builds Compliance Audit" > "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"
echo "## ❗ Missing Builds Report" >> "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"

# 2️⃣ استخراج أسماء Builds المطلوبة من Markdown
# نفترض أي كلمة تحتوي على Build|Windows|Android|iOS|Mac|Linux تشير لاسم Build
echo "[+] Extracting required builds from markdown..."
cat "$DOCS_DIR"/*.md \
 | grep -Eo "\b[A-Za-z0-9_]+(Build|Windows|Android|iOS|Mac|Linux)\b" \
 | sort -u > "$TMP_REQ"

# 3️⃣ جمع أسماء Builds الموجودة فعليًا مع دعم جميع الامتدادات المهمة
echo "[+] Collecting existing builds from Build/Builds..."
find "$BUILDS_DIR" -type f \( -iname "*.exe" -o -iname "*.apk" -o -iname "*.aab" -o -iname "*.xcodeproj" -o -iname "*.app" -o -iname "*.dll" \) \
 | sed 's#.*/##' \
 | sed -E 's/\.[^.]+$//' \
 | sort -u > "$TMP_EXISTING"

# 4️⃣ إنشاء جدول Markdown للتقرير
echo "| Build Name | Status | Evidence |" >> "$OUTPUT_MD"
echo "|------------|--------|----------|" >> "$OUTPUT_MD"

TOTAL=0
MISSING=0

# 5️⃣ مقارنة Builds المطلوبة مع الموجودة
while IFS= read -r build; do
  ((TOTAL++))

  if grep -qx "$build" "$TMP_EXISTING"; then
    echo "| $build | ✅ Present | Build file exists in Build/Builds |" >> "$OUTPUT_MD"
  else
    echo "| $build | ❌ MISSING | Build not found in Build/Builds |" >> "$OUTPUT_MD"
    ((MISSING++))
  fi
done < "$TMP_REQ"

# 6️⃣ ملخص التقرير
echo "" >> "$OUTPUT_MD"
echo "## 📊 Summary" >> "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"
echo "- Total required builds detected: **$TOTAL**" >> "$OUTPUT_MD"
echo "- Missing builds: **$MISSING**" >> "$OUTPUT_MD"
echo "- Compliance rate: **$(( (TOTAL - MISSING) * 100 / TOTAL ))%**" >> "$OUTPUT_MD"

# 7️⃣ حذف الملفات المؤقتة
rm "$TMP_REQ" "$TMP_EXISTING"

echo "[✓] Builds audit completed"
echo "Markdown report generated: $OUTPUT_MD"
