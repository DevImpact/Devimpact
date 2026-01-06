

🚀 تشغيل التطبيق على جهاز/محاكي

(يجب أن يكون جهاز متصل أو Emulator شغال):

gradlew installDebug

🧽 تنظيف مع تجاهل الكاش

إذا تشك بوجود مشكلة كاش:

gradlew clean build --no-build-cache

❌ إيقاف Gradle (لو علق)
gradlew --stop


🧠 ملاحظة مهمة

إذا لم يتعرف CMD على gradlew:

.\gradlew clean

وجود جهاز حقيقي أو Emulator يعمل

للتحقق:

java -version
adb version
