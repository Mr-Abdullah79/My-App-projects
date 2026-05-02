# Keep Flutter and plugin classes required at runtime.
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**
-dontwarn io.flutter.plugins.**

# Keep Kotlin metadata.
-keep class kotlin.Metadata { *; }
