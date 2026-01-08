#!/bin/bash

DOCS_DIR="docs"
STREAMING_DIR="Assets/StreamingAssets"
OUTPUT_MD="MISSING_STREAMINGASSETS_AUDIT.md"

TMP_REQ=$(mktemp)
TMP_EXISTING=$(mktemp)

echo "# Unity StreamingAssets Compliance Audit" > "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"
echo "## ❗ Missing StreamingAssets Report" >> "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"

# 1️⃣ استخراج أسماء StreamingAssets المطلوبة من Markdown
# نفترض أي كلمة تبدأ بحروف كبيرة وتشير لاسم Resource/Data/File
echo "[+] Extracting required streaming assets from markdown..."
cat "$DOCS_DIR"/*.md \
 | grep -Eo "\b[A-Za-z0-9_]+\b" \
 | sort -u > "$TMP_REQ"

# 2️⃣ جمع أسماء StreamingAssets الموجودة فعليًا
echo "[+] Collecting existing streaming assets from Assets/StreamingAssets..."
find "$STREAMING_DIR" -type f \
 | sed 's#.*/##' \
 | sed -E 's/\.[^.]+$//' \
 | sort -u > "$TMP_EXISTING"

echo "| StreamingAsset Name | Status | Evidence |" >> "$OUTPUT_MD"
echo "|-------------------|--------|----------|" >> "$OUTPUT_MD"

TOTAL=0
MISSING=0

while IFS= read -r asset; do
  ((TOTAL++))

  if grep -qx "$asset" "$TMP_EXISTING"; then
    echo "| $asset | ✅ Present | StreamingAsset file exists in Assets/StreamingAssets |" >> "$OUTPUT_MD"
  else
    echo "| $asset | ❌ MISSING | StreamingAsset not found in Assets/StreamingAssets |" >> "$OUTPUT_MD"
    ((MISSING++))
  fi
done < "$TMP_REQ"

echo "" >> "$OUTPUT_MD"
echo "## 📊 Summary" >> "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"
echo "- Total required streaming assets detected: **$TOTAL**" >> "$OUTPUT_MD"
echo "- Missing streaming assets: **$MISSING**" >> "$OUTPUT_MD"
echo "- Compliance rate: **$(( (TOTAL - MISSING) * 100 / TOTAL ))%**" >> "$OUTPUT_MD"

rm "$TMP_REQ" "$TMP_EXISTING"

echo "[✓] StreamingAssets audit completed"
echo "Markdown report generated: $OUTPUT_MD"
