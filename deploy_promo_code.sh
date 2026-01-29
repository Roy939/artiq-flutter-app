#!/bin/bash

# ARTIQ Promo Code Deployment Script
# This script builds and prepares your ARTIQ app with promo code functionality

echo "🚀 ARTIQ Promo Code Deployment Script"
echo "======================================"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed!"
    echo "Please install Flutter first: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -1)"
echo ""

# Navigate to project directory
cd "$(dirname "$0")"
echo "📁 Working directory: $(pwd)"
echo ""

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build for web
echo "🔨 Building for web (this may take a few minutes)..."
flutter build web --release

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "📂 Build output: build/web/"
    echo ""
    echo "🎯 Next steps:"
    echo "1. Test locally: flutter run -d chrome"
    echo "2. Deploy build/web/ folder to your hosting (GitHub Pages, Firebase, etc.)"
    echo "3. Test promo code 'PRODUCTHUNT' on live site"
    echo ""
    echo "🎉 Your ARTIQ app is ready for Product Hunt launch!"
else
    echo ""
    echo "❌ Build failed! Check the errors above."
    exit 1
fi
