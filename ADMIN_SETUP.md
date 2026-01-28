# ARTIQ Admin Account Setup

## Overview

The ARTIQ app now includes an **admin whitelist** system that grants specific email addresses free Pro access without requiring payment.

## How It Works

Admin users are identified by their email address. When an admin email logs in:
- ✅ **Automatic Pro access** (no payment required)
- ✅ **All Pro features unlocked** (unlimited designs, all fonts, JPG/PDF export)
- ✅ **No subscription management needed** (no Stripe integration for admins)
- ✅ **Permanent access** (doesn't expire)

## Current Admin Accounts

The following email addresses have admin privileges:

- `thompson9395681@gmail.com` (Owner account)

## Adding More Admin Accounts

To add additional admin emails:

1. Open `/lib/src/models/subscription_model.dart`
2. Find the `adminEmails` list at the top of the `UserSubscription` class
3. Add new email addresses to the list:

```dart
static const List<String> adminEmails = [
  'thompson9395681@gmail.com', // Owner account
  'another-admin@example.com', // Add new admins here
  'team-member@example.com',
];
```

4. Save the file
5. Commit and push to deploy the changes

## Technical Details

### Code Location

**File:** `/lib/src/models/subscription_model.dart`

**Key Code:**
```dart
// Admin emails that get free Pro access
static const List<String> adminEmails = [
  'thompson9395681@gmail.com', // Owner account
];

// Check if user is admin (gets free Pro access)
bool get isAdmin => adminEmails.contains(userEmail.toLowerCase());

// Admin users always have Pro access, regardless of subscription
bool get isPro => isAdmin || (tier == SubscriptionTier.pro && isActive);
```

### How Admin Detection Works

1. When a user logs in, their email is stored in the `UserSubscription` object
2. The `isAdmin` getter checks if the email exists in the `adminEmails` list
3. The `isPro` getter returns `true` if the user is an admin OR has a paid subscription
4. All Pro features check the `isPro` property, so admins automatically get access

### Database Structure

Admin users still have a subscription document in Firestore, but the `tier` and `isActive` fields are ignored. The email check takes precedence.

Example Firestore document for admin:
```json
{
  "userId": "abc123...",
  "userEmail": "thompson9395681@gmail.com",
  "tier": "free",
  "isActive": true,
  "stripeCustomerId": null,
  "stripeSubscriptionId": null
}
```

Even though `tier` is "free", the admin check grants Pro access.

## Testing Admin Access

To verify admin access is working:

1. **Log in** with your admin email (`thompson9395681@gmail.com`)
2. **Check the subscription page** - it should show "Pro Member" status
3. **Try Pro features:**
   - Create more than 5 designs (unlimited)
   - Export as JPG or PDF
   - Use premium fonts (8 fonts available)
   - No watermark on exports

## Security Notes

- ✅ **Email matching is case-insensitive** (THOMPSON@GMAIL.COM = thompson@gmail.com)
- ✅ **Hardcoded in app** - admins are defined in the source code, not in the database
- ✅ **No bypass possible** - users can't modify their email in Firestore to gain admin access (email comes from Firebase Auth)
- ⚠️ **Keep admin list private** - don't share the admin email list publicly

## Removing Admin Access

To remove an admin:

1. Open `/lib/src/models/subscription_model.dart`
2. Remove the email from the `adminEmails` list
3. Commit and push the changes
4. The user will lose admin privileges on next login

## Troubleshooting

### Admin not getting Pro access

**Check:**
1. Email is spelled correctly in the `adminEmails` list
2. User is logging in with the exact email address
3. App has been rebuilt and deployed after adding the email
4. User has logged out and back in to refresh their subscription

### Admin sees "Free Plan" instead of "Pro Member"

**Solution:**
1. Log out completely
2. Clear browser cache (for web) or restart app (for mobile)
3. Log back in
4. The subscription should reload and detect admin status

---

**Your admin account (`thompson9395681@gmail.com`) is now configured with free Pro access!** 🎉
