#!/bin/bash

DOCS_DIR="docs"
ASSETS_DIR="Assets"
OUTPUT_MD="MISSING_SCENES_AUDIT.md"

TMP_SCENE_REQ=$(mktemp)
TMP_EXISTING_SCENES=$(mktemp)
TMP_CODE_SCENES=$(mktemp)

echo "# Unity Scene Compliance Audit" > "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"
echo "## ❗ Missing Scenes Report" >> "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"

echo "[+] Extracting potential scene requirements from markdown..."

# 1️⃣ استخراج الجمل التي توحي بوجود Scene
cat "$DOCS_DIR"/*.md \
 | tr '\n' ' ' \
 | sed 's/\./\n/g' \
 | grep -Ei "screen|scene|menu|level|stage|mode|tutorial|game over|pause|settings|login|intro" \
 | awk 'NF > 6' \
 | sort -u > "$TMP_SCENE_REQ"

echo "[+] Collecting existing Unity scenes..."

# 2️⃣ استخراج Scenes الموجودة فعليًا
find "$ASSETS_DIR" -name "*.unity" \
 | sed 's#.*/##' \
 | sed 's/.unity//' \
 | tr '[:upper:]' '[:lower:]' \
 > "$TMP_EXISTING_SCENES"

echo "[+] Scanning C# code for dynamic scene loading..."

# 3️⃣ استخراج Scenes التي يتم تحميلها بالكود
grep -Rin "LoadScene" "$ASSETS_DIR" \
 | sed 's/.*LoadScene(//' \
 | sed 's/[\" );].*//' \
 | tr '[:upper:]' '[:lower:]' \
 | sort -u > "$TMP_CODE_SCENES"

TOTAL=0
MISSING=0

echo "| Scene Description | Status | Evidence |" >> "$OUTPUT_MD"
echo "|------------------|--------|----------|" >> "$OUTPUT_MD"

while IFS= read -r req; do
  ((TOTAL++))

  # توليد اسم Scene مرشح (كلمة أو كلمتين أساسيتين)
  candidate=$(echo "$req" \
    | tr '[:upper:]' '[:lower:]' \
    | sed 's/[^a-z ]//g' \
    | awk '{print $1}')

  FOUND=0

  if grep -q "$candidate" "$TMP_EXISTING_SCENES" || grep -q "$candidate" "$TMP_CODE_SCENES"; then
    FOUND=1
  fi

  if [ "$FOUND" -eq 1 ]; then
    echo "| $req | ✅ Present | Scene exists or loaded in code |" >> "$OUTPUT_MD"
  else
    echo "| $req | ❌ MISSING | No .unity file and no LoadScene reference |" >> "$OUTPUT_MD"
    ((MISSING++))
  fi

done < "$TMP_SCENE_REQ"

echo "" >> "$OUTPUT_MD"
echo "## 📊 Summary" >> "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"
echo "- Total required scenes detected: **$TOTAL**" >> "$OUTPUT_MD"
echo "- Missing scenes: **$MISSING**" >> "$OUTPUT_MD"
echo "- Compliance rate: **$(( (TOTAL - MISSING) * 100 / TOTAL ))%**" >> "$OUTPUT_MD"

rm "$TMP_SCENE_REQ" "$TMP_EXISTING_SCENES" "$TMP_CODE_SCENES"

echo "[✓] Scene audit complete"
echo "Markdown report generated: $OUTPUT_MD"
