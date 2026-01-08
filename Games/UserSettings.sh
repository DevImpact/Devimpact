#!/bin/bash

# 📁 مجلد الوثائق
DOCS_DIR="docs"

# 📁 مجلد UserSettings داخل المشروع
USERSETTINGS_DIR="UserSettings"

# 📄 اسم ملف التقرير النهائي
OUTPUT_MD="MISSING_USERSETTINGS_AUDIT.md"

# 🔹 ملفات مؤقتة
TMP_REQ=$(mktemp)
TMP_EXISTING=$(mktemp)

# 1️⃣ إنشاء ملف Markdown للتقرير
echo "# Unity UserSettings Compliance Audit" > "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"
echo "## ❗ Missing UserSettings Report" >> "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"

# 2️⃣ استخراج أسماء UserSettings المطلوبة من Markdown
# نفترض أي كلمة تحتوي على UserSettings أو أسماء إعدادات مستخدم مخصصة
echo "[+] Extracting required UserSettings from markdown..."
cat "$DOCS_DIR"/*.md \
 | grep -Eo "\b[A-Za-z0-9_]+(UserSettings|Settings|Prefs|Config)\b" \
 | sort -u > "$TMP_REQ"

# 3️⃣ جمع أسماء UserSettings الموجودة فعليًا
echo "[+] Collecting existing UserSettings from UserSettings directory..."
find "$USERSETTINGS_DIR" -type f \
 | sed 's#.*/##' \
 | sed -E 's/\.[^.]+$//' \
 | sort -u > "$TMP_EXISTING"

# 4️⃣ إنشاء جدول Markdown للتقرير
echo "| UserSetting Name | Status | Evidence |" >> "$OUTPUT_MD"
echo "|-----------------|--------|----------|" >> "$OUTPUT_MD"

TOTAL=0
MISSING=0

# 5️⃣ مقارنة UserSettings المطلوبة مع الموجودة
while IFS= read -r setting; do
  ((TOTAL++))

  if grep -qx "$setting" "$TMP_EXISTING"; then
    echo "| $setting | ✅ Present | UserSetting file exists in UserSettings |" >> "$OUTPUT_MD"
  else
    echo "| $setting | ❌ MISSING | UserSetting not found in UserSettings |" >> "$OUTPUT_MD"
    ((MISSING++))
  fi
done < "$TMP_REQ"

# 6️⃣ ملخص التقرير
echo "" >> "$OUTPUT_MD"
echo "## 📊 Summary" >> "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"
echo "- Total required UserSettings detected: **$TOTAL**" >> "$OUTPUT_MD"
echo "- Missing UserSettings: **$MISSING**" >> "$OUTPUT_MD"
echo "- Compliance rate: **$(( (TOTAL - MISSING) * 100 / TOTAL ))%**" >> "$OUTPUT_MD"

# 7️⃣ حذف الملفات المؤقتة
rm "$TMP_REQ" "$TMP_EXISTING"

echo "[✓] UserSettings audit completed"
echo "Markdown report generated: $OUTPUT_MD"
