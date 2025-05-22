-keep class **.zego.** { *; }
-keep class **.**.zego_zpns.** { *; }

# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Keep your model classes
-keep class com.example.grade_pro.models.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelable classes
-keepclassmembers class * implements android.os.Parcelable {
    static ** CREATOR;
}

# Keep R classes
-keepclassmembers class **.R$* {
    public static <fields>;
}

# Keep custom views
-keep public class * extends android.view.View

# Keep custom application class
-keep public class * extends android.app.Application

# Keep custom activity classes
-keep public class * extends android.app.Activity

# Keep custom service classes
-keep public class * extends android.app.Service

# Keep custom broadcast receiver classes
-keep public class * extends android.content.BroadcastReceiver

# Keep custom content provider classes
-keep public class * extends android.content.ContentProvider