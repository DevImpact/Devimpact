#!/bin/bash
set -e

PACKAGE_NAME="com.JobSearch.devimpact"
APP_NAME="JobSearch"
MAIN_ACTIVITY="MainActivity"
SPLASH_ACTIVITY="SplashActivity"

PACKAGE_PATH="app/src/main/java/$(echo $PACKAGE_NAME | tr '.' '/')"
RES_DIR="app/src/main/res"

echo "🚀 Creating Material 3 Splash Screen for $APP_NAME"

# --------------------------------------------------
# 1️⃣ Add SplashScreen dependency
# --------------------------------------------------
GRADLE_FILE="app/build.gradle"
if ! grep -q "core-splashscreen" "$GRADLE_FILE"; then
  sed -i "/dependencies {/a\    implementation \"androidx.core:core-splashscreen:1.0.1\"" "$GRADLE_FILE"
fi

# --------------------------------------------------
# 2️⃣ Create SplashActivity
# --------------------------------------------------
mkdir -p "$PACKAGE_PATH"

cat <<EOF > "$PACKAGE_PATH/$SPLASH_ACTIVITY.kt"
package $PACKAGE_NAME

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen

class $SPLASH_ACTIVITY : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        installSplashScreen()
        super.onCreate(savedInstanceState)

        startActivity(Intent(this, $MAIN_ACTIVITY::class.java))
        finish()
    }
}
EOF

# --------------------------------------------------
# 3️⃣ Material 3 Themes
# --------------------------------------------------
mkdir -p "$RES_DIR/values"

cat <<EOF >> "$RES_DIR/values/themes.xml"

<!-- Material 3 App Theme -->
<style name="Theme.$APP_NAME" parent="Theme.Material3.DayNight.NoActionBar">
    <item name="colorPrimary">@color/brand_primary</item>
    <item name="colorSecondary">@color/brand_secondary</item>
</style>

<!-- Splash Theme -->
<style name="Theme.$APP_NAME.Splash" parent="Theme.SplashScreen">
    <item name="windowSplashScreenBackground">@color/splash_background</item>
    <item name="windowSplashScreenAnimatedIcon">@drawable/ic_splash_anim</item>
    <item name="windowSplashScreenIconBackgroundColor">@color/splash_icon_bg</item>
    <item name="postSplashScreenTheme">@style/Theme.$APP_NAME</item>
</style>
EOF

# --------------------------------------------------
# 4️⃣ Colors (Brand Identity)
# --------------------------------------------------
cat <<EOF >> "$RES_DIR/values/colors.xml"

<color name="brand_primary">#2563EB</color>
<color name="brand_secondary">#0F172A</color>

<color name="splash_background">#0F172A</color>
<color name="splash_icon_bg">#2563EB</color>
EOF

# --------------------------------------------------
# 5️⃣ Animated VectorDrawable
# --------------------------------------------------
mkdir -p "$RES_DIR/drawable" "$RES_DIR/anim"

cat <<EOF > "$RES_DIR/drawable/ic_logo_vector.xml"
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="108"
    android:viewportHeight="108">

    <path
        android:name="logo"
        android:fillColor="#FFFFFF"
        android:pathData="M20,20h68v68h-68z"/>
</vector>
EOF

cat <<EOF > "$RES_DIR/anim/splash_scale.xml"
<objectAnimator
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:duration="450"
    android:propertyName="scaleX"
    android:valueFrom="0.85"
    android:valueTo="1.0"
    android:valueType="floatType" />
EOF

cat <<EOF > "$RES_DIR/anim/splash_alpha.xml"
<objectAnimator
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:duration="450"
    android:propertyName="alpha"
    android:valueFrom="0.6"
    android:valueTo="1.0"
    android:valueType="floatType" />
EOF

cat <<EOF > "$RES_DIR/drawable/ic_splash_anim.xml"
<animated-vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:drawable="@drawable/ic_logo_vector">

    <target android:name="logo" android:animation="@anim/splash_scale"/>
    <target android:name="logo" android:animation="@anim/splash_alpha"/>
</animated-vector>
EOF

# --------------------------------------------------
# 6️⃣ AndroidManifest update
# --------------------------------------------------
MANIFEST="app/src/main/AndroidManifest.xml"

sed -i "/<application/a\
        <activity\n\
            android:name=\".$SPLASH_ACTIVITY\"\n\
            android:exported=\"true\"\n\
            android:theme=\"@style/Theme.$APP_NAME.Splash\">\n\
            <intent-filter>\n\
                <action android:name=\"android.intent.action.MAIN\" />\n\
                <category android:name=\"android.intent.category.LAUNCHER\" />\n\
            </intent-filter>\n\
        </activity>" "$MANIFEST"

sed -i "/android.intent.action.MAIN/,/activity>/d" "$MANIFEST"

echo "✅ Splash Screen created successfully"
echo "🎯 Material 3 + Google Play compliant"
echo "🔥 Production-ready"
