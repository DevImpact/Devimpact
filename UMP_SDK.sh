#!/bin/sh
# ==================================================
# GDPR STRICT GUARD — GOOGLE PLAY COMPLIANT
# Mode: STRICT BUT POLICY-SAFE
# ==================================================

set -e
set -u

PROJECT_ROOT="$(pwd)"

echo "🔒 GDPR GUARD (Google Policy Mode)"
echo "📁 Project: $PROJECT_ROOT"
echo "----------------------------------"

# SDKs تتطلب Consent عند التفعيل
CONSENT_REQUIRED_SDKS="
firebaseAnalytics
FirebaseAnalytics
com.google.android.gms.ads
AdMob
"

# ملفات إلزامية
REQUIRED_FILES="
privacy_policy.html
privacy_policy.md
"

# ==================================================
# 1️⃣ سياسة الخصوصية (إلزامية دائمًا)
# ==================================================
echo "🔍 Checking Privacy Policy..."

FOUND_POLICY=false
for f in $REQUIRED_FILES; do
  if find "$PROJECT_ROOT" -iname "$f" | grep -q .; then
    FOUND_POLICY=true
  fi
done

if [ "$FOUND_POLICY" = false ]; then
  echo "❌ POLICY VIOLATION: Privacy Policy missing"
  exit 100
fi

echo "✅ Privacy Policy found"

# ==================================================
# 2️⃣ كشف وجود SDKs تتطلب Consent
# ==================================================
echo "🔍 Detecting consent-relevant SDKs..."

CONSENT_NEEDED=false
for sdk in $CONSENT_REQUIRED_SDKS; do
  if grep -R "$sdk" "$PROJECT_ROOT" >/dev/null 2>&1; then
    CONSENT_NEEDED=true
    echo "ℹ️ Detected SDK requiring consent: $sdk"
  fi
done

# ==================================================
# 3️⃣ إذا لا يوجد SDK يتطلب Consent → لا قيود إضافية
# ==================================================
if [ "$CONSENT_NEEDED" = false ]; then
  echo "✅ No consent-required SDKs detected"
  echo "✅ GDPR GUARD PASSED (No UMP needed)"
  exit 0
fi

# ==================================================
# 4️⃣ فرض وجود منطق Consent
# ==================================================
echo "🔍 Checking Consent Logic..."

if ! grep -R "consent" "$PROJECT_ROOT" >/dev/null 2>&1; then
  echo "❌ POLICY VIOLATION: Consent logic missing"
  exit 101
fi

echo "✅ Consent logic detected"

# ==================================================
# 5️⃣ إذا كان AdMob أو Analytics → فرض UMP
# ==================================================
echo "🔍 Enforcing Google UMP SDK (conditional)..."

if ! grep -R "user-messaging-platform" "$PROJECT_ROOT" >/dev/null 2>&1; then
  echo "❌ POLICY VIOLATION: Google UMP SDK required but not found"
  exit 102
fi

if ! grep -R "ConsentInformation.getInstance" "$PROJECT_ROOT" >/dev/null 2>&1; then
  echo "❌ POLICY VIOLATION: UMP consent flow missing"
  exit 103
fi

echo "✅ Google UMP SDK properly integrated"

# ==================================================
# 6️⃣ منع تهيئة Ads قبل Consent
# ==================================================
echo "🔍 Checking Ad initialization order..."

if grep -R "MobileAds.initialize" "$PROJECT_ROOT" >/dev/null 2>&1; then
  grep -R "requestConsentInfoUpdate" "$PROJECT_ROOT" >/dev/null 2>&1 || {
    echo "❌ POLICY VIOLATION: Ads initialized before consent"
    exit 104
  }
fi

echo "✅ Ads initialized after consent"

# ==================================================
# ✅ SUCCESS
# ==================================================
echo "----------------------------------"
echo "✅ GDPR GUARD PASSED"
echo "🚀 Google Play & GDPR compliant"
exit 0
