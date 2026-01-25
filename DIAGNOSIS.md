# Flutter Web Button Interactivity Issue - Diagnosis

## Problem
The ARTIQ Flutter web app displays visually but buttons and input fields are completely non-interactive. Users cannot click buttons or interact with any UI elements.

## Technical Investigation

### What We Found:
1. **Visual Rendering Works**: The app renders correctly on screen - we can see the login form with email/password fields and buttons
2. **No DOM Interactivity**: Browser inspection shows **0 semantic elements** in the DOM
3. **CanvasKit Renderer**: The app is using CanvasKit renderer which draws everything on `<canvas>` elements
4. **Missing Semantic Layer**: Flutter web is not creating the accessibility/semantic overlay that makes elements clickable

### Root Cause:
**Flutter web with CanvasKit renderer requires a semantic layer to make elements interactive, but this layer is not being generated.**

According to Flutter documentation:
- CanvasKit renders everything to WebAssembly canvas
- Interactive elements need semantic HTML overlays
- These overlays are created by Flutter's accessibility system
- **The semantic layer may not be initializing properly**

## Attempted Fixes (All Failed):
1. ✗ Switched from `auto` to `canvaskit` renderer explicitly - No change
2. ✗ Switched back to `auto` renderer - No change  
3. ✗ Added error handling and logging - No errors shown
4. ✗ Hard refresh and cache clearing - No change

## Current Status:
- **Web Deploy #7**: ✅ Succeeded (deployed with `auto` renderer)
- **Deployed site still shows**: CanvasKit renderer with no interactivity
- **GitHub Pages**: May have caching delay OR the fix didn't work

## Next Steps to Try:
1. **Build with HTML renderer explicitly** (not CanvasKit/auto)
2. **Check if semantic layer needs explicit enablement**
3. **Test with a minimal Flutter web app** to isolate the issue
4. **Review Flutter web initialization code** for semantic layer setup
5. **Consider using WebAssembly build mode** with skwasm renderer

## References:
- https://docs.flutter.dev/platform-integration/web/renderers
- https://blog.flutter.dev/accessibility-in-flutter-on-the-web-51bfc558b7d3
