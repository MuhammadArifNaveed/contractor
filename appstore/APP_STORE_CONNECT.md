# App Store Connect — submission content pack

Everything to paste into App Store Connect, plus the answers to the questions it asks.
Written 2026-08-18. **Nothing here is a placeholder** — every URL was checked live (all 200) and every
claim describes a feature that exists in the build.

---

## 1. App Information

| Field | Value |
|---|---|
| **Name** | `Thecontractor - المقاول` |
| **Subtitle** | `Online Contracting Portal` |
| **Bundle ID** | `com.contractor.TheContractorx` |
| **Primary language** | English (U.K.) |
| **Primary category** | Business |
| **Secondary category** | Productivity |
| **Age rating** | 4+ (no objectionable content; see §6 for the questionnaire answers) |

The app's `CFBundleDisplayName` was set to match the listing name exactly. Apple checks that the
home-screen name and the store name are recognisably the same app.

> **Note on the display name.** `Thecontractor - المقاول` is long for a home-screen label; iOS truncates
> at roughly 12 characters, so users will see something like "Thecontrac…". That is legal and common,
> but if you would rather it read cleanly, `Thecontractor` alone as `CFBundleDisplayName` is still
> recognisably the same app and Apple accepts it. Your call — say so and it is a one-line change.

---

## 2. URLs

All verified live:

| Field | URL |
|---|---|
| **Privacy Policy URL** (required) | `https://contractor.bidcont.com/privacy-policy-app` |
| **Support URL** (required) | `https://contractor.bidcont.com/contact` |
| **Marketing URL** (optional) | `https://contractor.bidcont.com` |
| Terms of Use (EULA) | `https://contractor.bidcont.com/terms-and-conditions-app` |

The `-app` variants are the ones the app itself opens, so store and app agree. `/privacy-policy` and
`/terms-and-conditions` (without the suffix) are the website versions and are also live.

---

## 3. Description

```
The Contractor connects you with verified contracting companies, workshops and
freelancers across the UAE — from a single enquiry to a finished job.

FOR CUSTOMERS
• Find companies by category, city or speciality, or look one up directly by name or ID
• Send one enquiry to several companies at once and compare what comes back
• Request quotations and track them from submitted through to completed
• Get an instant construction estimate by area and finish level
• Post a workshop advertisement and receive competitive bids
• Hire freelancers by the hour or the day, book several at once, and see transport costs up front
• Browse and apply for jobs, and track your applications
• Reach any company directly through in-app messaging
• 24/7 maintenance listings for urgent work

FOR COMPANIES
• Receive and respond to customer enquiries and quotation requests
• Post workshop advertisements and bid on other companies' work
• Advertise vacancies, review applicants and manage direct hiring
• Hire freelancers for your projects
• Track leads and quotations against your membership
• Message customers directly
• Manage your company profile, reviews and ratings

Register free as a customer, or list your company and start receiving work.
```

*Character count is within the 4,000 limit.*

---

## 4. Keywords (100 characters max)

```
contractor,construction,uae,dubai,quotation,enquiry,freelancer,maintenance,workshop,builder,tender
```

98 characters. Do not repeat words already in the app name or subtitle — Apple indexes those anyway,
so "portal" and "contracting" are deliberately omitted.

---

## 5. Promotional text (170 characters, changeable without a new build)

```
Find verified contractors, request quotations and hire freelancers across the UAE. Companies: receive enquiries, post jobs and win work — all in one app.
```

---

## 6. App Review Information

### Demo account — YES, this is required

Your app puts essentially everything behind a login, so Apple **will** reject it without working
credentials. Guideline 2.1 requires a fully functional demo account.

**You have two account types, and you must supply both.** A reviewer given only a customer account
cannot reach the company dashboard, memberships, job posting or applicant management — roughly half the
app. They will either reject for incomplete access or review only half the functionality. Give both, and label
which is which in the notes below.

Enter these in App Store Connect → App Review Information. **Do not put them in the repo** — that
discipline has been kept throughout this project, and the review form is the correct place for them.

```
Username: <the customer mobile number, in full +971… form>
Password: <the customer password>
```

App Store Connect only provides one username/password pair, so put the customer account there and give
the company account in the Notes field below.

### Notes field — paste this

```
This app has two distinct account types with different interfaces. Please test both.

1) CUSTOMER ACCOUNT (credentials in the fields above)
   Sign in from the side menu -> "Login or Create Account".
   Enter the mobile number including the +971 country code.
   This account can: search companies, send enquiries, request quotations,
   run estimates, post workshop ads, apply for jobs and hire freelancers.

2) COMPANY ACCOUNT
   Sign in from the side menu -> "Login or Create Account as Company".
   Email:    <company email>
   Password: <company PIN>
   This account sees a different home screen and side menu: enquiries,
   quotations, workshop ads, job posting, applicants, freelancer hiring
   and membership.

ACCOUNT DELETION (Guideline 5.1.1(v))
   Customer: Profile tab -> Delete Account
   Company:  side menu -> Delete Account
   Both ask the user to type DELETE to confirm, then permanently remove the
   account. Please use a throwaway registration if you wish to test the
   completion, as deletion is irreversible.

NOTIFICATIONS
   The app declares the remote-notification background mode solely so Firebase
   Phone Authentication can verify the app with a silent push during sign-up.
   It is not used for background content fetching.

PAYMENTS
   Memberships are activated by coupon code only. No in-app purchase or card
   payment is offered in this version; the card option states that it is
   unavailable. No purchasable digital content is present, so In-App Purchase
   does not apply.

SMS VERIFICATION
   New customer sign-up sends an SMS verification code. If you prefer not to
   use a real number, the accounts above are already registered and skip that
   step.
```

---

## 7. Screenshots

**Required:** one set for 6.9" iPhone — **1320 × 2868** or **1290 × 2796** portrait. App Store Connect
accepts a single size and scales it to the other iPhone sizes. iPad screenshots are only needed if the
app is submitted as iPad-compatible.

The simulator used during development (iPhone 17 Pro) produces **1206 × 2622**, which is the 6.3" size
and **will be rejected**. Capture on a Pro Max instead:

```bash
xcrun simctl list devices | grep -i "Pro Max"
```

Boot one, install the app, then for each screen:

```bash
xcrun simctl io booted screenshot ~/Desktop/shot-01.png
```

**Suggested six**, chosen to show both sides of the product — the reviewer forms an impression from
these before opening the app:

1. Home — categories and company listings
2. Company Finder — search results with real companies
3. Estimation — the calculator with a result showing
4. Freelancers — list with rates
5. Company dashboard — the enquiries/quotations counts grid
6. Chat — a conversation thread

Sign in as the customer for 1–4 and the company for 5–6.

---

## 8. Age rating questionnaire

Answer **None** to every content question. The app has no violence, sexual content, profanity, gambling,
drugs, horror or mature themes. Two that need care:

- **Unrestricted web access** — answer **No**. The app opens only fixed pages on
  `contractor.bidcont.com` in an in-app browser; there is no address bar and no arbitrary browsing.
- **User-generated content** — answer **Yes**. The app has messaging between customers and companies,
  plus enquiry and quotation text. This raises the rating to **17+** unless you also confirm moderation.

> **This one needs your decision.** Guideline 1.2 requires apps with user-generated content to provide
> a way to report objectionable content and to block abusive users. The app currently has **neither**.
> Options: (a) add reporting/blocking to chat before submitting, (b) declare the content as moderated
> if you moderate it server-side, or (c) accept a 17+ rating. (a) is the safest and is a contained piece
> of work — say the word.

---

## 9. Export compliance

The app uses HTTPS and standard iOS cryptography only, with no custom or proprietary encryption.

- "Does your app use encryption?" → **Yes**
- "Does it qualify for the exemption?" → **Yes** (standard encryption within the OS, HTTPS only)

Add this to `Info.plist` to stop App Store Connect asking on every single upload:

```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

---

## 10. Before you upload

- [ ] Increment `CURRENT_PROJECT_VERSION` (build number) — currently `1.5`; it must be unique per upload
- [ ] Archive with the **Release** configuration (verified building clean)
- [ ] Confirm the distribution certificate and provisioning profile are in place
- [ ] Upload the 1024×1024 App Store icon (no alpha channel, no rounded corners — Apple rounds it)
- [ ] Add the demo credentials above to App Review Information
- [ ] Decide the user-generated-content question in §8


---

## 11. Prepared assets

| File | Notes |
|---|---|
| `appstore/AppStoreIcon-1024.png` | 1024×1024, **alpha channel removed** and flattened onto white. The icon inside the app bundle has an alpha channel, which App Store Connect rejects — upload this one instead. Do not round the corners; Apple does that. |

