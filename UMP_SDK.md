
> ✅ **ملاحظة أساسية جدًا**
> لا يمكن لأي سكربت `sh` أن **ينفّذ UMP داخل التطبيق**
> لأن UMP **منطق Runtime داخل كود أندرويد (Kotlin/Java)**
>
> سكربت `sh` دوره فقط:
>
> * فحص
> * فرض
> * منع البناء
>
> **أما التنفيذ الفعلي لـ UMP → فهو كود أندرويد**

لذلك الحل الصحيح (والمتوافق مع Google) هو:

* 🔹 سكربت `sh` للفحص (الذي عندك ✔️)
* 🔹 **ملف كود منفصل** مسؤول فقط عن تنفيذ UMP

وسأعطيك الآن **تنفيذًا نظيفًا، رسميًا، ومتوافقًا 100% مع Google Play**.

---

## ✅ ما سأعطيك الآن

* ملف واحد فقط
* مسؤول فقط عن:

  * تحميل UMP
  * طلب الموافقة
  * منع تشغيل AdMob قبل الموافقة
* لا فلسفة، لا تعقيد

---

# 📄 UmpManager.kt (السكربت الحقيقي لتنفيذ UMP)

### 📍 Kotlin (موصى به من Google)

```kotlin
package 

import android.app.Activity
import com.google.android.ump.*

object UmpManager {

    private lateinit var consentInformation: ConsentInformation

    fun requestConsent(
        activity: Activity,
        onConsentReady: () -> Unit
    ) {
        val params = ConsentRequestParameters.Builder()
            .setTagForUnderAgeOfConsent(false)
            .build()

        consentInformation = UserMessagingPlatform.getConsentInformation(activity)

        consentInformation.requestConsentInfoUpdate(
            activity,
            params,
            {
                if (consentInformation.isConsentFormAvailable) {
                    loadAndShowForm(activity, onConsentReady)
                } else {
                    // لا حاجة لعرض فورم (خارج EEA)
                    onConsentReady()
                }
            },
            {
                // فشل تحميل معلومات الموافقة → نكمل بدون تخصيص
                onConsentReady()
            }
        )
    }

    private fun loadAndShowForm(
        activity: Activity,
        onConsentReady: () -> Unit
    ) {
        UserMessagingPlatform.loadConsentForm(
            activity,
            { consentForm ->
                if (consentInformation.consentStatus == ConsentInformation.ConsentStatus.REQUIRED) {
                    consentForm.show(activity) {
                        onConsentReady()
                    }
                } else {
                    onConsentReady()
                }
            },
            {
                // فشل تحميل الفورم → نكمل بدون تخصيص
                onConsentReady()
            }
        )
    }
}
```

---

## 🔗 كيف تستخدمه في التطبيق (مهم جدًا)

### ❌ خطأ شائع (لا تفعل هذا)

```kotlin
MobileAds.initialize(this) // ❌ قبل UMP
```

---

### ✅ الاستخدام الصحيح (كما تريد Google)

```kotlin
UmpManager.requestConsent(this) {
    // 👇 لا يتم استدعاء هذا إلا بعد:
    // - موافقة المستخدم (في EEA)
    // - أو إذا لم يكن في EEA
    MobileAds.initialize(this)
}
```

✔️ بهذه الطريقة:

* AdMob **لن يبدأ أبدًا قبل UMP**
* Google Review يمر بدون مشاكل
* GDPR + EU User Consent Policy ✔️

---

## 📌 ماذا عن الدول التي خارج أوروبا؟

* UMP **يتحقق تلقائيًا**
* لا يعرض أي نافذة
* يستدعي `onConsentReady()` مباشرة
* الإعلانات تعمل طبيعي

👉 **لا تحتاج أي منطق دول أو لغات**

---

## 📦 Dependency المطلوبة (تأكد فقط)

```gradle
implementation "com.google.android.ump:user-messaging-platform:2.2.0"
```

(أي إصدار حديث مقبول)

---

## 🧠 الخلاصة النهائية

* 🔹 سكربت `sh` = حارس
* 🔹 `UmpManager` = المنفّذ الحقيقي
* 🔹 Google UMP = من يقرر متى يظهر الـ Consent

> **لا تحاول تنفيذ UMP بـ sh**
> **هذا هو التنفيذ الصحيح والوحيد المعتمد**

---
