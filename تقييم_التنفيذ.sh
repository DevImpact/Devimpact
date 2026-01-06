#!/bin/bash

# =========================================================
# Deep Read-Only Audit Script
# NO EXECUTION - NO MODIFICATION - NO BUILD
# =========================================================

OUTPUT_FILE="AUDIT_REPORT.md"

echo "# 📊 Deep Code vs Docs Audit Report" > "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "**Mode:** Read-Only Analysis" >> "$OUTPUT_FILE"
echo "**Code Modification:** ❌ None" >> "$OUTPUT_FILE"
echo "**Build / Execution:** ❌ None" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# ---------------------------------------------------------
# 1. Collect Docs
# ---------------------------------------------------------
echo "## 1️⃣ Documentation Analysis" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

if [ ! -d "docs" ]; then
  echo "- ❌ docs/ directory not found" >> "$OUTPUT_FILE"
  exit 1
fi

DOC_FILES=$(find docs -type f -name "*.md")

echo "- Total docs files found:" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

for doc in $DOC_FILES; do
  echo "  - \`$doc\`" >> "$OUTPUT_FILE"
done

echo "" >> "$OUTPUT_FILE"
echo "---" >> "$OUTPUT_FILE"

# ---------------------------------------------------------
# 2. Extract Conceptual Requirements (Textual)
# ---------------------------------------------------------
echo "## 2️⃣ Extracted Conceptual Requirements (Textual)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "_This section lists key concepts, features, rules as text, without interpretation._" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

grep -Rni "" docs/*.md >> "$OUTPUT_FILE" 2>/dev/null
echo "" >> "$OUTPUT_FILE"
echo "---" >> "$OUTPUT_FILE"

# ---------------------------------------------------------
# 3. Scan Full Codebase (All Files)
# ---------------------------------------------------------
echo "## 3️⃣ Full Codebase Inventory" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

find . \
  -type f \
  ! -path "./.git/*" \
  ! -path "./docs/*" \
  ! -name "$OUTPUT_FILE" \
  >> "$OUTPUT_FILE"

echo "" >> "$OUTPUT_FILE"
echo "---" >> "$OUTPUT_FILE"

# ---------------------------------------------------------
# 4. Source Code Analysis
# ---------------------------------------------------------
echo "## 4️⃣ Source Code Analysis" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

SOURCE_FILES=$(find . -type f \( -name "*.kt" -o -name "*.java" \) ! -path "./docs/*" ! -path "./.git/*")

echo "### Files Analyzed:" >> "$OUTPUT_FILE"
for file in $SOURCE_FILES; do
  echo "- \`$file\`" >> "$OUTPUT_FILE"
done

echo "" >> "$OUTPUT_FILE"

# ---------------------------------------------------------
# 5. Feature Presence vs Docs (Textual Matching Only)
# ---------------------------------------------------------
echo "## 5️⃣ Feature Presence vs Docs (Textual Match)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "_Matching identifiers, class names, keywords between code and docs._" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

for doc in $DOC_FILES; do
  echo "### Comparing with \`$doc\`" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"

  grep -Rni -f "$doc" . \
    --exclude-dir=docs \
    --exclude-dir=.git \
    >> "$OUTPUT_FILE" 2>/dev/null

  echo "" >> "$OUTPUT_FILE"
done

echo "---" >> "$OUTPUT_FILE"

# ---------------------------------------------------------
# 6. Architecture Signals
# ---------------------------------------------------------
echo "## 6️⃣ Architecture Signals Detected" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

grep -Rni "ViewModel\|Repository\|UseCase\|DataSource\|Room\|Retrofit\|Hilt\|DI" . \
  --exclude-dir=docs \
  --exclude-dir=.git \
  >> "$OUTPUT_FILE" 2>/dev/null

echo "" >> "$OUTPUT_FILE"
echo "---" >> "$OUTPUT_FILE"

# ---------------------------------------------------------
# 7. Testing Coverage Presence
# ---------------------------------------------------------
echo "## 7️⃣ Testing Files Presence" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

find . -type f \( -name "*Test.kt" -o -name "*Test.java" \) \
  ! -path "./docs/*" \
  ! -path "./.git/*" \
  >> "$OUTPUT_FILE"

echo "" >> "$OUTPUT_FILE"
echo "---" >> "$OUTPUT_FILE"

# ---------------------------------------------------------
# 8. Gaps & Observations (Non-Inferential)
# ---------------------------------------------------------
echo "## 8️⃣ Gaps & Observations (Non-Inferential)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "- This section highlights **absence or presence only**, without assumptions." >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "- Files mentioned in docs but not found in code: _manual review required_" >> "$OUTPUT_FILE"
echo "- Code elements with no textual reference in docs: _manual review required_" >> "$OUTPUT_FILE"

echo "" >> "$OUTPUT_FILE"
echo "---" >> "$OUTPUT_FILE"

# ---------------------------------------------------------
# 9. Final Notes
# ---------------------------------------------------------
echo "## 9️⃣ Final Notes" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "- No code was executed." >> "$OUTPUT_FILE"
echo "- No files were modified." >> "$OUTPUT_FILE"
echo "- Analysis is textual and structural only." >> "$OUTPUT_FILE"
echo "- Interpretation and judgment are intentionally avoided." >> "$OUTPUT_FILE"

echo "" >> "$OUTPUT_FILE"
echo "✅ Audit completed. Output written to \`$OUTPUT_FILE\`."
