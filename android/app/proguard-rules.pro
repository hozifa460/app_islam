# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# This app has no deferred components. Flutter's embedding retains optional
# legacy Play Core task references, while the modern Feature Delivery library
# uses the newer APIs. R8 generated these exact missing-class rules.
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# EmailJS
-keep class com.emailjs.** { *; }

# speech_to_text
-keep class com.csdcorp.speech_to_text.** { *; }

# video_player
-keep class io.flutter.plugins.videoplayer.** { *; }

# google_sign_in
-keep class com.google.android.libraries.identity.** { *; }
