# 🎯 ARTIQ Admin Account - Quick Reference

## Your Admin Email
**`thompson9395681@gmail.com`**

This email has **permanent free Pro access** to ARTIQ!

---

## ✅ What You Get (For Free!)

When logged in with your admin email:

- ✨ **Unlimited designs** (no 5-design limit)
- 🎨 **8 premium fonts** (vs 2 on free plan)
- 📥 **Export as JPG and PDF** (not just PNG)
- 🚫 **No watermarks** on exports
- ⭐ **"Pro Member" badge** in the app

---

## 🚀 How to Use It

### Step 1: Log In
Go to https://artiq.works and log in with:
- **Email:** thompson9395681@gmail.com
- **Password:** Your password

OR use "Sign in with Google" if your Gmail is linked.

### Step 2: Verify Pro Access
1. Click the menu (☰) in the top-right
2. Go to **"Subscription"**
3. You should see **"Pro Member"** status
4. No payment required!

### Step 3: Enjoy Pro Features
- Create unlimited designs
- Use all 8 fonts
- Export as JPG/PDF
- No watermarks

---

## 🔧 How It Works

Your email is **hardcoded** in the app as an admin:

**File:** `/lib/src/models/subscription_model.dart`
```dart
static const List<String> adminEmails = [
  'thompson9395681@gmail.com', // Owner account
];
```

The app checks your email on login and automatically grants Pro access.

---

## 📝 Adding More Admins

To give someone else free Pro access:

1. Open `/lib/src/models/subscription_model.dart`
2. Add their email to the list:
```dart
static const List<String> adminEmails = [
  'thompson9395681@gmail.com', // Owner account
  'friend@example.com', // New admin
];
```
3. Commit and push to GitHub
4. Wait 2-3 minutes for deployment

---

## 🐛 Troubleshooting

### Not seeing Pro access?

**Try this:**
1. Log out completely
2. Clear browser cache (Ctrl+Shift+Delete)
3. Log back in with thompson9395681@gmail.com
4. Check the Subscription page

### Still showing "Free Plan"?

**Check:**
- You're using the exact email: `thompson9395681@gmail.com`
- The app has been deployed (check GitHub Actions)
- You've refreshed the page after logging in

---

## 📦 Files Updated

The admin system was added in these files:
- ✅ `/lib/src/models/subscription_model.dart` (admin whitelist)
- ✅ `/lib/src/providers/subscription_provider.dart` (email tracking)
- ✅ `/ADMIN_SETUP.md` (full documentation)

---

## 🎉 You're All Set!

Your account (`thompson9395681@gmail.com`) has **permanent free Pro access** to ARTIQ.

**Deployed to:** https://artiq.works  
**Status:** Live and active  
**Cost:** $0 (admin privilege)

Enjoy your unlimited design tool! 🚀
