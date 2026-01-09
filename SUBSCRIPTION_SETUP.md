# Subscription Setup Guide - Couple Tasks App

Complete guide to setting up subscriptions in Google Play Console and App Store Connect.

---

## Table of Contents

1. [Overview](#overview)
2. [Google Play Console Setup](#google-play-console-setup)
3. [App Store Connect Setup](#app-store-connect-setup)
4. [Testing Subscriptions](#testing-subscriptions)
5. [Troubleshooting](#troubleshooting)

---

## Overview

### Subscription Plans

| Plan | Price | Trial | Product ID |
|------|-------|-------|------------|
| Monthly | $4.99/month | 7 days | `couple_tasks_monthly` |
| Annual | $49.99/year | 7 days | `couple_tasks_annual` |

### Benefits

- ✨ Unlimited shared tasks and dreams
- 💕 Loving nudges to stay connected
- 🎯 Achieve your goals together
- 📊 Celebrate your progress as a couple
- 🔒 Private and secure
- 🤖 AI-powered relationship insights (Gemini)

---

## Google Play Console Setup

### Step 1: Create App in Play Console

1. Go to [Google Play Console](https://play.google.com/console)
2. Click **Create app**
3. Fill in app details:
   - **App name**: Couple Tasks
   - **Default language**: English (United States)
   - **App or game**: App
   - **Free or paid**: Free (with in-app purchases)
4. Accept declarations and click **Create app**

### Step 2: Set Up Subscriptions

1. In Play Console, navigate to **Monetize** → **Subscriptions**
2. Click **Create subscription**

#### Monthly Subscription

**Base plan details:**
- **Product ID**: `couple_tasks_monthly`
- **Name**: Monthly Premium
- **Description**: Premium features for Couple Tasks - billed monthly

**Pricing:**
- **Price**: $4.99 USD
- **Billing period**: 1 month
- **Free trial**: 7 days
- **Grace period**: 3 days (recommended)
- **Account hold**: Enabled (recommended)

**Eligibility:**
- **New subscribers**: Yes
- **Upgrade/downgrade**: Yes

#### Annual Subscription

**Base plan details:**
- **Product ID**: `couple_tasks_annual`
- **Name**: Annual Premium
- **Description**: Premium features for Couple Tasks - billed annually (save $10!)

**Pricing:**
- **Price**: $49.99 USD
- **Billing period**: 1 year
- **Free trial**: 7 days
- **Grace period**: 3 days (recommended)
- **Account hold**: Enabled (recommended)

**Eligibility:**
- **New subscribers**: Yes
- **Upgrade/downgrade**: Yes

### Step 3: Configure Subscription Features

**For both subscriptions:**

1. **Subscription benefits** (displayed in Play Store):
   - Unlimited shared tasks
   - Loving nudges and reminders
   - AI-powered insights
   - Private and secure
   - Cancel anytime

2. **Offers** (optional):
   - Consider adding promotional offers for special occasions
   - Example: "Valentine's Day Special - 50% off first month"

3. **Settings**:
   - **Resubscribe**: Enabled
   - **Restore**: Enabled
   - **Prepaid plans**: Disabled (not needed)

### Step 4: Set Up License Tester Accounts

1. Go to **Settings** → **License testing**
2. Add test Gmail accounts (up to 100)
3. Test accounts can purchase without being charged

**Test accounts to add:**
- Your personal Gmail
- Team members' Gmail accounts
- QA testers' Gmail accounts

### Step 5: Configure App Details for Subscriptions

1. Go to **Store presence** → **Main store listing**
2. Update app description to mention premium features
3. Add screenshots showing premium features
4. Update privacy policy to mention subscriptions

### Step 6: Set Up Real-time Developer Notifications (RTDN)

1. Go to **Monetize** → **Monetization setup**
2. Enable **Real-time developer notifications**
3. Enter Cloud Pub/Sub topic (if using backend verification)
4. This allows you to receive instant updates about subscription events

---

## App Store Connect Setup

### Step 1: Create App in App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Click **My Apps** → **+** → **New App**
3. Fill in app details:
   - **Platform**: iOS
   - **Name**: Couple Tasks
   - **Primary Language**: English (U.S.)
   - **Bundle ID**: Select your bundle ID
   - **SKU**: couple-tasks-app
   - **User Access**: Full Access

### Step 2: Create In-App Purchases

1. In your app, go to **Features** → **In-App Purchases**
2. Click **+** to create new subscription

#### Monthly Auto-Renewable Subscription

**Reference Name**: Monthly Premium
**Product ID**: `couple_tasks_monthly`
**Subscription Group**: Couple Tasks Premium (create new group)

**Subscription Duration**: 1 month

**Subscription Prices:**
1. Click **Add Pricing**
2. Select **United States** → **$4.99**
3. Apple will auto-generate prices for other countries
4. Review and adjust if needed

**Introductory Offer:**
- **Type**: Free Trial
- **Duration**: 7 days
- **Eligibility**: New subscribers only

**Localization (English - U.S.):**
- **Display Name**: Monthly Premium
- **Description**: Get unlimited tasks, loving nudges, and AI insights. Billed monthly. Cancel anytime.

#### Annual Auto-Renewable Subscription

**Reference Name**: Annual Premium
**Product ID**: `couple_tasks_annual`
**Subscription Group**: Couple Tasks Premium (same group)

**Subscription Duration**: 1 year

**Subscription Prices:**
1. Click **Add Pricing**
2. Select **United States** → **$49.99**
3. Apple will auto-generate prices for other countries

**Introductory Offer:**
- **Type**: Free Trial
- **Duration**: 7 days
- **Eligibility**: New subscribers only

**Promotional Offer (optional):**
- **Reference Name**: Annual Discount
- **Offer Code**: TOGETHER2026
- **Type**: Pay as you go
- **Duration**: 1 month at $0.99
- **Eligibility**: Former subscribers

**Localization (English - U.S.):**
- **Display Name**: Annual Premium
- **Description**: Get unlimited tasks, loving nudges, and AI insights. Billed annually. Save $10! Cancel anytime.

### Step 3: Configure Subscription Group

1. Go to **Subscription Group**: Couple Tasks Premium
2. Set **Subscription Group Display Name**: Couple Tasks Premium
3. Add **Subscription Group Localization**:
   - **Name**: Couple Tasks Premium
   - **Custom Text**: Join thousands of couples building stronger relationships together

### Step 4: Add App Metadata

1. Go to **App Information**
2. Update **Subtitle**: "Collaborate, Communicate, Celebrate"
3. Update **Privacy Policy URL**: Your privacy policy URL
4. Update **App Category**: Lifestyle or Productivity

### Step 5: Add Screenshots with Premium Features

1. Go to **App Store** → **iOS App** → **Screenshots**
2. Add screenshots showing:
   - Onboarding flow
   - Task management
   - Paywall screen
   - Premium features in action
   - Loving nudges

### Step 6: Set Up Sandbox Testers

1. Go to **Users and Access** → **Sandbox**
2. Click **+** to add testers
3. Add test Apple IDs (create new Apple IDs for testing)
4. Testers can purchase without being charged

**Important**: Sandbox testers must use separate Apple IDs from production accounts.

### Step 7: Configure App Review Information

1. Go to **App Review Information**
2. Add **Sign-in required**: Yes (provide test account)
3. Add **Demo Account**:
   - **Username**: demo@coupletasks.com
   - **Password**: DemoPass123!
   - **Notes**: "This is a demo account with premium access"

4. Add **Notes**:
   ```
   Couple Tasks is a relationship app for couples to collaborate on tasks.
   
   Premium features:
   - Unlimited tasks
   - AI-powered insights
   - Loving nudges
   
   Subscription details:
   - Monthly: $4.99/month with 7-day free trial
   - Annual: $49.99/year with 7-day free trial
   
   To test premium features, please subscribe using the test account provided.
   ```

---

## Testing Subscriptions

### Android Testing (Google Play)

#### 1. License Testing

1. Add your Gmail to license testers in Play Console
2. Install app from internal testing track
3. Subscriptions are free for license testers
4. Test full purchase flow

#### 2. Internal Testing Track

1. Upload APK/AAB to internal testing
2. Add testers via email
3. Testers receive invite link
4. Install and test subscriptions (charged but refunded)

**Test scenarios:**
- [ ] Purchase monthly subscription
- [ ] Purchase annual subscription
- [ ] Cancel subscription
- [ ] Restore purchases
- [ ] Subscription expiry
- [ ] Resubscribe after cancellation

### iOS Testing (App Store)

#### 1. Sandbox Testing

1. Sign out of App Store on device
2. Run app from Xcode
3. When prompted, sign in with sandbox tester account
4. Complete purchase (not charged)
5. Test all subscription flows

**Test scenarios:**
- [ ] Purchase monthly subscription
- [ ] Purchase annual subscription
- [ ] Free trial activation
- [ ] Cancel subscription
- [ ] Restore purchases
- [ ] Subscription renewal
- [ ] Upgrade from monthly to annual
- [ ] Downgrade from annual to monthly

#### 2. TestFlight Testing

1. Upload build to App Store Connect
2. Add internal testers
3. Testers install via TestFlight
4. Test with sandbox accounts

**Important**: TestFlight uses sandbox environment, so purchases are not real.

---

## Backend Verification (Recommended)

### Why Backend Verification?

- **Security**: Prevent fraud and fake purchases
- **Reliability**: Verify purchases with Apple/Google servers
- **Consistency**: Single source of truth for subscription status

### Implementation

#### 1. Set Up Cloud Function (Firebase)

```javascript
// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const {google} = require('googleapis');

admin.initializeApp();

// Verify Android purchase
exports.verifyAndroidPurchase = functions.https.onCall(async (data, context) => {
  const {purchaseToken, productId, packageName} = data;
  
  // Authenticate with Google Play Developer API
  const auth = new google.auth.GoogleAuth({
    keyFile: 'service-account-key.json',
    scopes: ['https://www.googleapis.com/auth/androidpublisher'],
  });
  
  const androidPublisher = google.androidpublisher({
    version: 'v3',
    auth: auth,
  });
  
  try {
    // Verify subscription
    const result = await androidPublisher.purchases.subscriptions.get({
      packageName: packageName,
      subscriptionId: productId,
      token: purchaseToken,
    });
    
    // Check if subscription is valid
    const isValid = result.data.paymentState === 1; // 1 = paid
    const expiryDate = new Date(parseInt(result.data.expiryTimeMillis));
    
    // Save to Firestore
    if (isValid) {
      await admin.firestore().collection('subscriptions').doc(context.auth.uid).set({
        platform: 'android',
        productId: productId,
        purchaseToken: purchaseToken,
        expiryDate: expiryDate,
        isActive: true,
        verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, {merge: true});
    }
    
    return {success: isValid, expiryDate: expiryDate.toISOString()};
  } catch (error) {
    console.error('Verification error:', error);
    throw new functions.https.HttpsError('internal', 'Verification failed');
  }
});

// Verify iOS purchase
exports.verifyIOSPurchase = functions.https.onCall(async (data, context) => {
  const {receiptData, productId} = data;
  
  // Verify with Apple
  const verifyReceipt = async (receiptData, sandbox = false) => {
    const endpoint = sandbox 
      ? 'https://sandbox.itunes.apple.com/verifyReceipt'
      : 'https://buy.itunes.apple.com/verifyReceipt';
    
    const response = await fetch(endpoint, {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({
        'receipt-data': receiptData,
        'password': 'YOUR_SHARED_SECRET', // From App Store Connect
      }),
    });
    
    return await response.json();
  };
  
  try {
    // Try production first
    let result = await verifyReceipt(receiptData, false);
    
    // If sandbox receipt, try sandbox
    if (result.status === 21007) {
      result = await verifyReceipt(receiptData, true);
    }
    
    if (result.status === 0) {
      // Receipt is valid
      const latestReceipt = result.latest_receipt_info[0];
      const expiryDate = new Date(parseInt(latestReceipt.expires_date_ms));
      const isActive = expiryDate > new Date();
      
      // Save to Firestore
      await admin.firestore().collection('subscriptions').doc(context.auth.uid).set({
        platform: 'ios',
        productId: productId,
        transactionId: latestReceipt.transaction_id,
        expiryDate: expiryDate,
        isActive: isActive,
        verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, {merge: true});
      
      return {success: true, expiryDate: expiryDate.toISOString()};
    } else {
      throw new Error(`Verification failed with status: ${result.status}`);
    }
  } catch (error) {
    console.error('Verification error:', error);
    throw new functions.https.HttpsError('internal', 'Verification failed');
  }
});
```

#### 2. Call from Flutter App

```dart
// After successful purchase
final callable = FirebaseFunctions.instance.httpsCallable(
  Platform.isAndroid ? 'verifyAndroidPurchase' : 'verifyIOSPurchase'
);

final result = await callable.call({
  'purchaseToken': purchase.purchaseToken, // Android
  'receiptData': purchase.verificationData, // iOS
  'productId': purchase.productID,
  'packageName': 'com.example.couple_tasks',
});

if (result.data['success']) {
  // Purchase verified!
  print('Subscription active until: ${result.data['expiryDate']}');
}
```

---

## Troubleshooting

### Common Issues

#### "Product not found" Error

**Cause**: Product IDs don't match or products not published

**Solution**:
1. Verify product IDs match exactly in code and store
2. Wait 2-4 hours after creating products (propagation delay)
3. Ensure products are in "Ready to Submit" or "Approved" status
4. For iOS: Ensure app is in "Ready for Sale" or "Pending Developer Release"

#### "Cannot connect to iTunes Store" (iOS)

**Cause**: Not signed in with sandbox account or network issue

**Solution**:
1. Sign out of App Store on device
2. Run app and trigger purchase
3. Sign in with sandbox tester when prompted
4. Ensure device has internet connection

#### Subscription Not Restoring

**Cause**: Different Apple ID or Google account

**Solution**:
1. Ensure using same account as original purchase
2. Check Firestore for subscription record
3. Verify receipt/token with backend
4. Check subscription expiry date

#### Free Trial Not Working

**Cause**: User previously had trial or eligibility issue

**Solution**:
1. Free trials only work once per Apple ID/Google account
2. For testing, create new sandbox/test accounts
3. Check subscription group settings

---

## Production Checklist

### Before Launch

- [ ] Products created in both stores
- [ ] Product IDs match in code
- [ ] Prices set correctly ($4.99, $49.99)
- [ ] Free trials configured (7 days)
- [ ] Subscription benefits listed
- [ ] Privacy policy updated
- [ ] App screenshots include paywall
- [ ] Backend verification implemented (recommended)
- [ ] Test accounts working
- [ ] All purchase flows tested
- [ ] Restore purchases working
- [ ] Analytics tracking subscriptions
- [ ] Customer support ready for billing questions

### After Launch

- [ ] Monitor subscription metrics
- [ ] Track conversion rates
- [ ] A/B test paywall variations
- [ ] Respond to subscription support tickets
- [ ] Update products for special offers
- [ ] Review and optimize pricing
- [ ] Analyze churn and retention

---

## Resources

### Google Play

- [Google Play Console](https://play.google.com/console)
- [Subscription Documentation](https://developer.android.com/google/play/billing/subscriptions)
- [Testing Guide](https://developer.android.com/google/play/billing/test)

### App Store

- [App Store Connect](https://appstoreconnect.apple.com)
- [Subscription Documentation](https://developer.apple.com/app-store/subscriptions/)
- [Testing Guide](https://developer.apple.com/documentation/storekit/in-app_purchase/testing_in-app_purchases_with_sandbox)

### Flutter

- [in_app_purchase Package](https://pub.dev/packages/in_app_purchase)
- [Flutter IAP Guide](https://docs.flutter.dev/cookbook/plugins/in-app-purchases)

---

## Support

For subscription setup help:
- Email: dev@coupletasks.com
- Documentation: https://docs.coupletasks.com
- GitHub Issues: https://github.com/odada2/couple-tasks-app/issues

---

**Last Updated**: January 9, 2026
