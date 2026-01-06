#!/bin/sh
# ============================================================
# INTERSTITIAL ADS STRICT POLICY GUARD
# Target App Type: Job Listings / Employment Content
# Purpose: Enforce Google AdMob Interstitial Compliance
# ============================================================

set -e

echo "🔒 Enforcing Interstitial Ads Compliance Policy..."

# ------------------------------------------------------------
# 1. ABSOLUTE PROHIBITIONS
# ------------------------------------------------------------

echo "⛔ Checking forbidden triggers..."

FORBIDDEN_TRIGGERS="
onClick
onItemClick
onJobClick
onCardClick
onButtonClick
onResumeClick
onApplyClick
onBackPressed
onCreate
onStart
onResume
"

for trigger in $FORBIDDEN_TRIGGERS; do
  if grep -R "showInterstitial.*$trigger" ./app/src 2>/dev/null; then
    echo "❌ POLICY VIOLATION: Interstitial linked to user click ($trigger)"
    exit 1
  fi
done

# ------------------------------------------------------------
# 2. CONTENT-FIRST RULE
# ------------------------------------------------------------

echo "📄 Verifying content-first rule..."

if grep -R "showInterstitial()" ./app/src | grep -E "onCreate|onStart|onResume"; then
  echo "❌ POLICY VIOLATION: Interstitial shown before content"
  exit 1
fi

# ------------------------------------------------------------
# 3. FREQUENCY CONTROL
# ------------------------------------------------------------

echo "⏱ Checking frequency constraints..."

MIN_TIME_BETWEEN_ADS=60  # seconds (1 minute)
MIN_CONTENT_ACTIONS=3     # job views

if ! grep -R "lastInterstitialTimestamp" ./app/src >/dev/null; then
  echo "❌ POLICY VIOLATION: No time-based throttling found"
  exit 1
fi

if ! grep -R "jobViewCounter" ./app/src >/dev/null; then
  echo "❌ POLICY VIOLATION: No content-based trigger found"
  exit 1
fi

# ------------------------------------------------------------
# 4. NON-DETERMINISTIC RULE
# ------------------------------------------------------------

echo "🎲 Checking randomness safeguard..."

if ! grep -R "Random" ./app/src >/dev/null; then
  echo "❌ POLICY VIOLATION: Interstitial is deterministically shown"
  exit 1
fi

# ------------------------------------------------------------
# 5. USER EXPERIENCE SAFETY
# ------------------------------------------------------------

echo "🧠 Ensuring UX protection..."

FORBIDDEN_CONTEXTS="
JobDetailsActivity
ApplyJobActivity
SearchResultsActivity
"

for ctx in $FORBIDDEN_CONTEXTS; do
  if grep -R "showInterstitial" ./app/src | grep "$ctx"; then
    echo "❌ POLICY VIOLATION: Interstitial blocks critical user intent ($ctx)"
    exit 1
  fi
done

# ------------------------------------------------------------
# 6. FAIL-SAFE RULE
# ------------------------------------------------------------

echo "🛡 Checking fail-safe behavior..."

if ! grep -R "if (interstitialAd != null)" ./app/src >/dev/null; then
  echo "❌ POLICY VIOLATION: No null-check before showing interstitial"
  exit 1
fi

# ------------------------------------------------------------
# 7. FINAL VERDICT
# ------------------------------------------------------------

echo "✅ POLICY PASSED: Interstitial Ads comply with Google AdMob rules"
exit 0
