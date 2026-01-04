📌 افتح CMD في مجلد المشروع

داخل مجلد مشروع Android (حيث يوجد ملف gradlew.bat):

cd C:\Path\To\Your\AndroidProject

🧹 تنظيف المشروع

يحذف جميع ملفات البناء:

gradlew clean

🔨 بناء المشروع

يبني المشروع بدون تنظيف:

gradlew build

♻️ تنظيف + إعادة بناء كامل

الأكثر استخدامًا لحل المشاكل:

gradlew clean build

🏗️ إعادة بناء مثل Android Studio

(نفس Build → Rebuild Project):

gradlew clean assembleDebug

أو للإصدار النهائي:

gradlew clean assembleRelease

🚀 تشغيل التطبيق على جهاز/محاكي

(يجب أن يكون جهاز متصل أو Emulator شغال):

gradlew installDebug

🧽 تنظيف مع تجاهل الكاش

إذا تشك بوجود مشكلة كاش:

gradlew clean build --no-build-cache

❌ إيقاف Gradle (لو علق)
gradlew --stop

🔍 عرض الأخطاء بالتفصيل

مفيد جدًا للتشخيص:

gradlew build --stacktrace

أو:

gradlew build --info

🧠 ملاحظة مهمة

إذا لم يتعرف CMD على gradlew:

.\gradlew clean

