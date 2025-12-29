#!/bin/bash

echo "⚠️  WARNING:"
echo "This keystore and properties file are GENERATED FOR TESTING ONLY."
echo "DO NOT use them in production."
echo "DO NOT reuse these credentials in real apps."
echo ""

# أسماء الملفات
KEYSTORE_NAME="test-release.jks"
PROPERTIES_FILE="keystore.properties"

# بيانات اختبار (حقيقية تقنيًا لكن غير إنتاجية)
STORE_PASSWORD="testStorePassword123"
KEY_PASSWORD=$STORE_PASSWORD
KEY_ALIAS="testAlias"
DNAME="CN=Test User, OU=Testing, O=Test Company, L=Test City, S=Test State, C=US"

# إنشاء keystore حقيقي
keytool -genkeypair \
  -v \
  -keystore "app/$KEYSTORE_NAME" \
  -alias $KEY_ALIAS \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -storepass $STORE_PASSWORD \
  -keypass $KEY_PASSWORD \
  -dname "$DNAME"

# إنشاء ملف keystore.properties
cat <<EOF > "app/$PROPERTIES_FILE"
# ⚠️ TESTING ONLY
# This file contains TEST credentials.
# Do NOT use in production.

storeFile=app/$KEYSTORE_NAME
storePassword=$STORE_PASSWORD
keyAlias=$KEY_ALIAS
keyPassword=$KEY_PASSWORD
EOF

echo "✅ Keystore generated: app/$KEYSTORE_NAME"
echo "✅ Properties file created: app/$PROPERTIES_FILE"
echo ""
echo "⚠️ Remember: This file is NOT ignored by git and is for testing only."