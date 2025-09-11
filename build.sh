#!/bin/bash

# Build script for Need For Control Android App
# This script helps build the APK without Android Studio

echo "======================================"
echo "Need For Control - Build Script"
echo "======================================"

# Check if ANDROID_HOME is set
if [ -z "$ANDROID_HOME" ]; then
    echo "❌ Error: ANDROID_HOME environment variable is not set"
    echo "Please set ANDROID_HOME to your Android SDK path"
    echo "Example: export ANDROID_HOME=/path/to/Android/Sdk"
    exit 1
fi

# Check if Gradle wrapper exists
if [ ! -f "./gradlew" ]; then
    echo "📦 Initializing Gradle wrapper..."
    gradle wrapper --gradle-version=8.0
fi

# Make gradlew executable
chmod +x ./gradlew

echo "🔧 Building debug APK..."

# Clean and build
./gradlew clean
./gradlew assembleDebug

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo "📱 APK location: app/build/outputs/apk/debug/app-debug.apk"
    echo ""
    echo "To install on device:"
    echo "adb install app/build/outputs/apk/debug/app-debug.apk"
else
    echo "❌ Build failed!"
    echo "Make sure you have:"
    echo "1. Android SDK installed"
    echo "2. ANDROID_HOME environment variable set"
    echo "3. Java 8+ installed"
    exit 1
fi