# Resume here — iOS/Android parity, state at 2026-08-11

Written to be enough on its own. Read this, then `HANDOVER.md` (ground rules, tooling, traps) and
`PARITY_STATUS.md` (the authority on per-feature state).

Branch `feature/arif`, everything pushed, latest commit `3fd3abb`. Build is clean.

---

## 1. The one thing that decides whether this can ship

**Cross-platform chat is broken, and no amount of iOS work fixes it.**

iOS chat lives in Firebase project `contractor-e1442`. Android chat lives in `thecontractor-uae`, which
already holds real conversations. Firestore is per-project, so an iOS company and an Android customer
each see an empty inbox and conclude the other never replied. Accounts are unaffected — those are on the
shared PHP backend. It is specifically **chat and push** that are split.

Two ways out, and it is a business decision, not a technical one:

| Option | Cost | Risk |
|---|---|---|
| **A. Get access to `thecontractor-uae`** — ask whoever originally built the Android app | Swap `GoogleService-Info.plist`, redo the checklist in `HANDOVER.md` §4 | Lowest. Existing Android chat keeps working |
| **B. Migrate Android to `contractor-e1442`** — the Android source is in this repo | New `google-services.json`, an Android release, backend credential swap | Existing Android chat history is orphaned; every Android user must update |

Until this is resolved, **do not tell anyone chat works across platforms.** It does not.

---

## 2. What is actually done, and how well

The verification standard used throughout: *endpoint confirmed live with curl → parser written against
the real key names → screen driven in the simulator*. Anything short of that is said plainly below.

### Driven end to end and checked against stored data

- **Firestore chat.** Company 706 started a thread from workshop ad 109, consumer 45 saw it and replied.
  Both documents read back out of Firestore: `user_connections` has all 15 of Android's fields and no
  others, `chat` all 9. `created_at = 2026-11-08` confirms the swapped `yyyy-dd-MM` order. `user_is_view`
  and `company_is_view` each flip only on the *other* side's messages. `findConnection` reuses an existing
  thread rather than creating a duplicate — confirmed by a second Message tap leaving exactly one
  connection document.
- **Sign-up SMS gate.** `+971500000000` / `123456`: code step appeared, code accepted, details form opened
  with the number locked in.
- **Password reset gate.** Both branches: an unregistered number is refused with no SMS attempted; a
  registered number passes and proceeds to send.
- **Sign-out / login routing**, on the hierarchy where it used to fail silently.
- **The Message entry point** on workshop ads, with the `show_chat` gate removed.

### Built, compiles, not yet driven

- **Freelancer order chat** (`FreelancerOrderChatView.swift`). All four endpoints verified live against
  vendor 706. The **Order chats** row renders on the Freelancer Dashboard — that much was seen on screen.
  The list and thread themselves were never opened: the simulator died mid-navigation.
  **This is the first thing to finish.** See §4.

---

## 3. What is left, in priority order

### Blocked on someone else

| Item | Who | Detail |
|---|---|---|
| Cross-platform chat | Owner | §1 above |
| Push **delivery** | Backend dev | The backend pushes with `uae` credentials and cannot reach `e1442` tokens. **Solvable without the uae account:** the backend already stores `firebase_token_device` (`ios`/`android`) — confirmed on the live user record — so it can hold two credential sets and pick by that field. Needs a service account key from `e1442` (Project settings → Service accounts). Fallback: push straight to APNs with the `.p8` already uploaded |
| SMS quota | Owner | Capped at **10/day** until a billing account is attached. Real users will hit this immediately |
| Payment gateway | Owner | Deferred; memberships to show "Coming soon" |
| 4 backend bugs | Backend dev | `Vendor/workshop_ad_detail` 500s (breaks this screen on **Android too**); `Home/recent_enquiries` returns HTML, unknown column `t2.company_whatsapp_phone`; `jobs/update_direct_hiring_status` crashes on an unknown id; `jobs/view_direct_hirings` has no `total_page` so it cannot page |

### Code work, nothing blocking it

1. **Finish freelancer order chat verification** — §4.
2. **Push receive + tap routing.** Android's `MyFirebaseMessagingService` routes on `type` (`user`/`vendor`)
   and `action` (e.g. `user_inbox`), carrying `vendorId`, `vendorName`, `vendorUUID`, `chatUUID`,
   `vendorSerialNo`. iOS has none of this. Buildable now, but **unverifiable until push delivery works**.
3. **Three small endpoints:** `jobs/search_job_title` (job-title autocomplete), `Home/get_by_company_id`
   (company lookup), `Home/quotation_fee_paid` (quotation fee).
4. **Memberships → "Coming soon"** so the screens are not dead ends.
5. **Firestore rules.** Currently `allow read, write: if true` and the API key ships inside the app binary,
   so anyone who extracts it can read every conversation. This is a real pre-launch item. Properly fixing
   it means signing in to Firebase Auth — the SDK is already wired.
6. **Unverified screens:** freelancer form prefill (sign in as user 45 → Profile → Profile Settings →
   Freelancer profile; expect hourly rate 5, two skills, category `carpentor`, Dubai / Al Mamzar,
   10:00–18:00, bank block, four addresses) and Company Details' top bar.
7. **Cleanup:** dead storyboard scenes, `Image("splash_logo")` and `Image("topicon")` referenced in six
   places with neither asset existing, `AppTheme.Fonts` still handing out fixed point sizes so consumer
   screens do not scale with system text size.
8. **Lower value, cut to ship:** "available for job" checkbox saves nowhere; Edit Profile sends `address`,
   `city`, `country`, `job_category` as empty strings; `addWorkshopQuotation` cannot attach a document;
   freelancer hire has no multi-select or pick-up addresses.

### Endpoint gap, re-audited

**13 real gaps, 0 fabricated endpoints.** Method: every path Android's `RetrofitApi` declares *and calls*,
against every path string in the iOS sources. Two caveats — Android has overloaded method names
(`workshopAds`, `workshopAdDetails`) so a path can look called when only its sibling is, and a path merely
mentioned in an iOS comment counts as present. Of the 13: 4 are freelancer order chat (now built), 3 are
memberships (deferred), 2 are dead in Android too, 1 is the broken `Vendor/workshop_ad_detail`, and 3 are
the small endpoints in item 3.

---

## 4. Finishing the order chat — exact steps

Needs a **company** login (the owner has to type the PIN; do not put credentials in the repo).

1. Drawer → **Freelancer Dashboard** → **Order chats**.
2. **Placed** tab should list order **#9** (Himanshu Dimri software Solutions), **Received** order **#8**
   (Bilal update Jan Updte). Both come back live from
   `freelancing/order_placed_chats` / `order_recieved_chats` for vendor 706.
3. Open either. Expect an **empty thread** — `fetch_order_chats` answers `error:true` with "No chats found"
   for both, which the code treats as empty rather than an error.
4. Expect the composer to be **replaced by "Order Expired / Rejected"**, because both orders are past their
   date. That is Android's behaviour when `sending` is `"false"`.

**What cannot be verified without new data:** the message row shape and the send path. Both QA orders are
expired, so `freelancing/send_message` answers "Message not sent, Order Expired". The parser was written
against Android's `FreelancerChatModel` (`message`, `created_at`, `sender_name`, `sender_id`,
`sender_type`, `order_id`) rather than live data, and the bubble side uses Android's rule —
`sender_id == userId && sender_type == userType`, **both**, since a company and a user can share a numeric
id. To finish this properly, someone needs to create a freelancer order dated today or later.

---

## 5. Things that cost hours this session — do not rediscover them

- **`VendorTheme.date` cannot be trusted for chat timestamps.** It tries `yyyy-MM-dd` first and only falls
  back on *failure* — but a swapped-format string parses cleanly as the wrong date, so every message with a
  day ≤ 12 rendered under the wrong month. Chat uses `ChatService.display` / `shortDisplay`, which parse
  the exact format. Anything else reading a swapped string has the same bug latent in it.
- **Firestore equality filter + `order(by:)` on another field needs a composite index**, which a new project
  has none of, and the query fails outright. `observeMessages` sorts in Swift instead.
- **`PhoneAuthProvider` calls `fatalError`** — a hard crash, not an error — when the callback URL scheme is
  missing from `Info.plist`. The scheme is `app-<GOOGLE_APP_ID with colons as dashes>`.
- **Firebase's `.internalError` message is useless** ("print and inspect the error details"). The server's
  real reason lives in `userInfo` under one of three keys depending on which wrapper the SDK used;
  `PhoneAuthService.serverReason(in:)` digs it out. This is what made `CONFIGURATION_NOT_FOUND` visible.
- **SMS region policy is a separate gate from enabling the Phone provider.** Every `+971` number is refused
  with `OPERATION_NOT_ALLOWED` until AE is allowed under Authentication → Settings.
- **Realtime Database, Storage and Firestore are three different console sections.** A database under
  *Realtime Database* does not mean chat is provisioned.
- **`project.pbxproj` name matching must be anchored.** `ForgotPasswordView.swift` matches
  `VendorForgotPasswordView.swift` as a substring; use `(?<![A-Za-z])name`.
- **Verify Firebase from the terminal, not the console** — the console showed the wrong project more than
  once this session. The two curl commands are in `HANDOVER.md` §4.
- **A fresh `simctl install` starts with no session**, and installing terminates a running app — which will
  interrupt a login the owner just did.
- **The derived-data module cache corrupts periodically** (`module file ... .pcm not found`). Fix is
  `rm -rf /private/tmp/cc-dd` and a full rebuild; clearing only `ExplicitPrecompiledModules` was not enough.

---

## 6. Pre-launch checklist

- [ ] Decide cross-platform chat (§1) — **blocks launch**
- [ ] Backend: two-credential push keyed on `firebase_token_device`
- [ ] Tighten Firestore rules
- [ ] Attach a billing account (SMS quota)
- [ ] Finish order chat verification (§4)
- [ ] Report the 4 backend bugs
- [ ] Memberships → "Coming soon"
- [ ] Test on a **real device** — nothing has been. Phone auth behaves differently there: with the APNs key
      uploaded it uses a silent push instead of the reCAPTCHA browser fallback seen on the simulator
- [ ] Deployment target is **iOS 15**, but the simulator is iOS 26 — newer SF Symbols and APIs compile and
      run there and would break on a real iOS 15 device. This has already happened twice
