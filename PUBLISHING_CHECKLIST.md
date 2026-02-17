# Alter Ego Publishing & Monetization Checklist

## Product IDs (must match store dashboards)
- `alter_ego_premium_monthly`
- `alter_ego_premium_yearly`

## App Store Connect
1. Create subscription group `Alter Ego Premium`.
2. Add monthly + yearly auto-renewable subscriptions using IDs above.
3. Configure localized display names/descriptions.
4. Add privacy policy + terms URLs in app metadata.
5. Set review notes with sandbox test account info.

## Google Play Console
1. Create in-app products (subscriptions) with same IDs.
2. Configure base plans and offers.
3. Add testing license accounts.
4. Upload signed AAB and verify Billing declaration.

## App behavior implemented
- Free tier limits:
  - Top 3 identities shown.
  - Limited history window (7 points).
- Premium unlocks:
  - Full identity map
  - Shadow analysis
  - Deep council simulation
  - Weekly evolution report
- Billing:
  - Product query
  - Purchase flow
  - Restore purchases
  - Local entitlement cache in SharedPreferences

## QA before release
- Purchase monthly (sandbox) and validate unlocks.
- Purchase yearly (sandbox) and validate unlocks.
- Restore on fresh install.
- Offline reopen uses cached entitlement.
- Non-premium users see paywall and retained free paths.
