#!/bin/bash

DOCS_DIR="docs"
AUDIO_DIR="Assets/Audio"
OUTPUT_MD="MISSING_AUDIO_AUDIT.md"

TMP_REQ=$(mktemp)
TMP_EXISTING=$(mktemp)

echo "# Unity Audio Assets Compliance Audit" > "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"
echo "## ❗ Missing Audio Assets Report" >> "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"

# 1️⃣ استخراج أسماء Audio المطلوبة من Markdown
# نفترض أي كلمة تحتوي على BGM|SFX|Audio|UI تشير لاسم ملف صوتي
echo "[+] Extracting required audio assets from markdown..."
cat "$DOCS_DIR"/*.md \
 | grep -Eo "\b[A-Za-z]+(BGM|SFX|Audio|UI)\b" \
 | sort -u > "$TMP_REQ"

# 2️⃣ جمع أسماء Audio الموجودة فعليًا
echo "[+] Collecting existing audio files from Assets/Audio..."
find "$AUDIO_DIR" -type f \( -iname "*.mp3" -o -iname "*.wav" -o -iname "*.ogg" -o -iname "*.aiff" \) \
 | sed 's#.*/##' \
 | sed -E 's/\.(mp3|wav|ogg|aiff)$//' \
 | sort -u > "$TMP_EXISTING"

echo "| Audio Name | Status | Evidence |" >> "$OUTPUT_MD"
echo "|------------|--------|----------|" >> "$OUTPUT_MD"

TOTAL=0
MISSING=0

while IFS= read -r audio; do
  ((TOTAL++))

  if grep -qx "$audio" "$TMP_EXISTING"; then
    echo "| $audio | ✅ Present | Audio file exists in Assets/Audio |" >> "$OUTPUT_MD"
  else
    echo "| $audio | ❌ MISSING | Audio file not found in Assets/Audio |" >> "$OUTPUT_MD"
    ((MISSING++))
  fi
done < "$TMP_REQ"

echo "" >> "$OUTPUT_MD"
echo "## 📊 Summary" >> "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"
echo "- Total required audio assets detected: **$TOTAL**" >> "$OUTPUT_MD"
echo "- Missing audio assets: **$MISSING**" >> "$OUTPUT_MD"
echo "- Compliance rate: **$(( (TOTAL - MISSING) * 100 / TOTAL ))%**" >> "$OUTPUT_MD"

rm "$TMP_REQ" "$TMP_EXISTING"

echo "[✓] Audio assets audit completed"
echo "Markdown report generated: $OUTPUT_MD"
