#!/bin/bash

# 📁 مجلد الوثائق
DOCS_DIR="docs"

# 📁 مجلد Logs داخل المشروع
LOGS_DIR="Logs"

# 📄 اسم ملف التقرير النهائي
OUTPUT_MD="MISSING_LOGS_AUDIT.md"

# 🔹 ملفات مؤقتة
TMP_REQ=$(mktemp)
TMP_EXISTING=$(mktemp)

# 1️⃣ إنشاء ملف Markdown للتقرير
echo "# Unity Logs Compliance Audit" > "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"
echo "## ❗ Missing Logs Report" >> "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"

# 2️⃣ استخراج أسماء Logs المطلوبة من Markdown
# نفترض أي كلمة تحتوي على Log|Error|Trace|Debug تشير لملف سجل
echo "[+] Extracting required logs from markdown..."
cat "$DOCS_DIR"/*.md \
 | grep -Eo "\b[A-Za-z0-9_]+(Log|Error|Trace|Debug)\b" \
 | sort -u > "$TMP_REQ"

# 3️⃣ جمع أسماء Logs الموجودة فعليًا
echo "[+] Collecting existing log files from Logs directory..."
find "$LOGS_DIR" -type f \
 | sed 's#.*/##' \
 | sed -E 's/\.[^.]+$//' \
 | sort -u > "$TMP_EXISTING"

# 4️⃣ إنشاء جدول Markdown للتقرير
echo "| Log Name | Status | Evidence |" >> "$OUTPUT_MD"
echo "|----------|--------|----------|" >> "$OUTPUT_MD"

TOTAL=0
MISSING=0

# 5️⃣ مقارنة Logs المطلوبة مع الموجودة
while IFS= read -r log; do
  ((TOTAL++))

  if grep -qx "$log" "$TMP_EXISTING"; then
    echo "| $log | ✅ Present | Log file exists in Logs |" >> "$OUTPUT_MD"
  else
    echo "| $log | ❌ MISSING | Log not found in Logs |" >> "$OUTPUT_MD"
    ((MISSING++))
  fi
done < "$TMP_REQ"

# 6️⃣ ملخص التقرير
echo "" >> "$OUTPUT_MD"
echo "## 📊 Summary" >> "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"
echo "- Total required logs detected: **$TOTAL**" >> "$OUTPUT_MD"
echo "- Missing logs: **$MISSING**" >> "$OUTPUT_MD"
echo "- Compliance rate: **$(( (TOTAL - MISSING) * 100 / TOTAL ))%**" >> "$OUTPUT_MD"

# 7️⃣ حذف الملفات المؤقتة
rm "$TMP_REQ" "$TMP_EXISTING"

echo "[✓] Logs audit completed"
echo "Markdown report generated: $OUTPUT_MD"
