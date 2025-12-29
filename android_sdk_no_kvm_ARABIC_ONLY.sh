#!/usr/bin/env bash
###############################################################################
# ⚠️ SYSTEM / AGENT DIRECTIVE (MANDATORY)
#
# هذا السكريبت يُفترض تشغيله بواسطة وكيل ذكي (AI Agent).
#
# قاعدة غير قابلة للنقاش:
# - يجب على الوكيل التحدث معي باللغة العربية فقط.
# - يُمنع استخدام أي لغة غير العربية في أي رد، شرح، توثيق، أو مخرجات تفسيرية.
# - أي رد غير عربي يُعتبر فشلًا في تنفيذ المهمة.
#
# قاعدة تقنية صارمة:
# - ملف local.properties هو الحقيقة المطلقة لكل ما يتعلق بـ SDK و NDK.
# - يُمنع تجاهل هذا الملف عبر .gitignore.
###############################################################################

set -e

############################################
# معلومات التطبيق (إجباري)
############################################

APP_NAME="MyAndroidApp"
PROJECT_ROOT="$(pwd)"

echo "=========================================="
echo "بدء إعداد بيئة أندرويد للتطبيق: $APP_NAME"
echo "البيئة المستهدفة: Unix / Linux فقط"
echo "local.properties: مصدر الحقيقة الوحيد"
echo "=========================================="

############################################
# STEP 0: المتغيرات الأساسية
############################################

ANDROID_HOME="$HOME/Android/Sdk"
NDK_DIR="$ANDROID_HOME/ndk/25.2.9519653"

SDK_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"
CMDLINE_ZIP="commandlinetools-linux-11076708_latest.zip"

API_LEVEL="36"
BUILD_TOOLS="36.1.0"
NDK_VERSION="25.2.9519653"
AVD_NAME="${APP_NAME}_low_spec_no_kvm"

############################################
# STEP 1: تثبيت الاعتماديات (بدون KVM)
############################################

echo "==> تثبيت الاعتماديات الأساسية (Unix فقط)"
sudo apt update
sudo apt install -y \
  openjdk-17-jdk \
  wget unzip \
  libglu1-mesa mesa-utils \
  libpulse0 \
  libx11-6 libxcomposite1 libxcursor1 \
  libxdamage1 libxext6 libxi6 libxtst6 \
  libc6 libstdc++6

java -version

############################################
# STEP 2: إعداد Android SDK
############################################

mkdir -p "$ANDROID_HOME/cmdline-tools"
cd "$ANDROID_HOME/cmdline-tools"

wget -q "$SDK_URL"
unzip -q "$CMDLINE_ZIP"
mv cmdline-tools latest
rm "$CMDLINE_ZIP"

stat latest/bin/sdkmanager

############################################
# STEP 3: متغيرات البيئة (User-level)
############################################

export ANDROID_HOME="$ANDROID_HOME"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"

grep -q ANDROID_HOME ~/.bashrc || echo "export ANDROID_HOME=\"$ANDROID_HOME\"" >> ~/.bashrc
grep -q cmdline-tools ~/.bashrc || echo "export PATH=\"$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools:\$ANDROID_HOME/emulator:\$PATH\"" >> ~/.bashrc

source ~/.bashrc

############################################
# STEP 4: تثبيت مكونات SDK / NDK
############################################

yes | sdkmanager --licenses

sdkmanager --install \
  "cmdline-tools;latest" \
  "platform-tools" \
  "build-tools;$BUILD_TOOLS" \
  "platforms;android-$API_LEVEL" \
  "emulator" \
  "system-images;android-$API_LEVEL;default;x86_64" \
  "ndk;$NDK_VERSION"

############################################
# STEP 5: إنشاء ملف local.properties (إجباري)
############################################

echo "==> إنشاء ملف local.properties (مصدر الحقيقة الوحيد)"

cat > "$PROJECT_ROOT/local.properties" <<EOF
##
## ⚠️ هذا الملف مُنشأ تلقائيًا
## وهو المصدر الوحيد والحقيقي لمسارات SDK و NDK
## مخصص لبيئات Unix / Linux
##

sdk.dir=$ANDROID_HOME
ndk.dir=$NDK_DIR
EOF

echo "تم إنشاء local.properties بالمحتوى التالي:"
cat "$PROJECT_ROOT/local.properties"

############################################
# STEP 6: منع تجاهل local.properties في Git
############################################

echo "==> التحقق من .gitignore"

if [ -f "$PROJECT_ROOT/.gitignore" ]; then
  if grep -q "local.properties" "$PROJECT_ROOT/.gitignore"; then
    sed -i '/local.properties/d' "$PROJECT_ROOT/.gitignore"
  fi

  if ! grep -q "!local.properties" "$PROJECT_ROOT/.gitignore"; then
    echo "!local.properties" >> "$PROJECT_ROOT/.gitignore"
  fi
else
  echo "!local.properties" > "$PROJECT_ROOT/.gitignore"
fi

############################################
# STEP 7: إنشاء AVD بدون تسريع
############################################

echo "no" | avdmanager create avd \
  -n "$AVD_NAME" \
  -k "system-images;android-$API_LEVEL;default;x86_64" \
  --device "pixel"

############################################
# STEP 8: فرض Software Rendering
############################################

AVD_CONFIG="$HOME/.android/avd/$AVD_NAME.avd/config.ini"

cat >> "$AVD_CONFIG" <<EOF
hw.gpu.enabled=no
hw.gpu.mode=off
hw.ramSize=1024
hw.cpu.ncore=1
vm.heapSize=128
EOF

############################################
# STEP 9: التحقق النهائي
############################################

which sdkmanager
which adb
which emulator

adb version
emulator -version

echo "=========================================="
echo "اكتمل الإعداد بنجاح"
echo "local.properties هو المرجع الوحيد"
echo "البيئة: Unix / Linux"
echo "=========================================="
