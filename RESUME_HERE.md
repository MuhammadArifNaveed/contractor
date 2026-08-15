# Resume here — iOS/Android parity, state at 2026-08-15

Written to be enough on its own. Read this, then `HANDOVER.md` (ground rules, tooling, traps) and
`PARITY_STATUS.md` (the authority on per-feature state).

Branch `feature/arif`, everything pushed. Build is clean.

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

- **Freelancer order chat.** Driven on 15 Aug as vendor 706. **Placed** lists order #9 (Himanshu Dimri
  software Solutions, 2026-06-27) badged Expired; **Received** lists order #8 (Bilal update Jan Updte,
  2026-03-20) badged Expired. The thread opens, shows the empty state, and the composer is replaced by
  "Order Expired / Rejected". Driving it found a real defect, now fixed — see the note in §4.
- **Push notification tap routing** (`PushRouter.swift`). Driven with `xcrun simctl push`: a tapped
  `vendor_membership` notification opened My Membership on the real ELITE record, and `user_inbox` with
  an unknown `chatUUID` fell back to the company inbox showing the live Firestore thread. The routing
  and the buffering are proven; what is *not* proven is delivery from the real backend, which is still
  blocked (§3).

### Built, compiles, not yet driven

- **Company Finder** (`CompanyFinderView.swift`). `Home/get_by_company_id` verified live (238 companies
  for `a`, `error:true` + "company not found." for a miss). The screen was not driven: it is on the
  *consumer* drawer and the simulator holds a company session that would be lost by signing out, which
  costs the owner a PIN entry to restore. Drive it on the next consumer login.
- **Job-title suggestions.** `jobs/search_job_title` verified live (`eng` → Civil Engineer), wired into
  `SearchJobsView` as tappable chips. Same reason: the screen is behind the consumer's Available Jobs.

---

## 3. What is left, in priority order

### Blocked on someone else

| Item | Who | Detail |
|---|---|---|
| Cross-platform chat | Owner | §1 above |
| Push **delivery** | Backend dev | The backend pushes with `uae` credentials and cannot reach `e1442` tokens. **Solvable without the uae account:** the backend already stores `firebase_token_device` (`ios`/`android`) — confirmed on the live user record — so it can hold two credential sets and pick by that field. Needs a service account key from `e1442` (Project settings → Service accounts). Fallback: push straight to APNs with the `.p8` already uploaded |
| SMS quota | Owner | Capped at **10/day** until a billing account is attached. Real users will hit this immediately |
| Payment gateway | Owner | Deferred. The membership screens are **not** dead ends: plans load from `vendor/memberships`, coupon redemption works, and the card button already says "Card payment not available yet" |
| **Credential leak** | Backend dev | `Home/get_by_company_id` returns `login_password` (MD5), `otp`, `verified_token`, `password_update_token`, `app_password_update_pin` and both firebase tokens for all 238 companies, unauthenticated. Neither app reads those fields — the fix is to stop selecting them. **Report this first** |
| 7 backend bugs | Backend dev | The four already known (`Vendor/workshop_ad_detail` 500s, breaking this screen on **Android too**; `Home/recent_enquiries` returns HTML, unknown column `t2.company_whatsapp_phone`; `jobs/update_direct_hiring_status` crashes on an unknown id; `jobs/view_direct_hirings` has no `total_page` so it cannot page) plus three found on 15 Aug: `Home/quotation_fee_paid` errors on `Undefined variable $quotation_id`; `vendor/membership_details` throws on null; `freelancing/fetch_order_chats` omits `sending` for an empty thread. Full list in `PARITY_STATUS.md` §5 |

### Code work, nothing blocking it

1. **Deploy `firestore.rules`.** The file is written and in the repo root. Read its header before doing
   anything else: it is a real improvement on `allow read, write: if true` (writes are shape-validated,
   deletes are off, message text is immutable, everything outside `chat`/`user_connections` is closed)
   but **reads stay open**, and it explains exactly why that cannot be fixed from the rules file alone.
   Chat identity is the backend's account `uuid`; scoping by participant needs `request.auth`, which
   means the backend minting Firebase **custom tokens** — the same service-account key the push fix
   needs, so it is one ask. The participant-scoped rules are written and commented out at the bottom of
   the file, ready to swap in. Do not call chat private until then.
2. **Sign the consumer in and drive two screens:** Company Finder (drawer → Company Finder) and the
   job-title chips (Available Jobs → search). Both are built and their endpoints verified live; neither
   has been looked at.
3. **Unverified screens:** freelancer form prefill (sign in as user 45 → Profile → Profile Settings →
   Freelancer profile; expect hourly rate 5, two skills, category `carpentor`, Dubai / Al Mamzar,
   10:00–18:00, bank block, four addresses) and Company Details' top bar.
4. **Cleanup:** dead storyboard scenes; `AppTheme.Fonts` still hands out fixed point sizes, so consumer
   screens do not scale with system text size (`VendorTheme.Text` is already relative and is the model
   to copy). The missing `splash_logo` / `topicon` references are **gone** — that item is done.
5. **Lower value, cut to ship:** "available for job" checkbox saves nowhere; Edit Profile sends `address`,
   `city`, `country`, `job_category` as empty strings; `addWorkshopQuotation` cannot attach a document;
   freelancer hire has no multi-select or pick-up addresses.

Done since the last handover, so do not redo it: freelancer order chat verification, push tap routing,
Company Finder, job-title suggestions, and the three "small endpoints" — of which one
(`Home/quotation_fee_paid`) turned out to be broken on the backend and is deliberately not wired.

### Endpoint gap, re-audited

**13 real gaps, 0 fabricated endpoints.** Method: every path Android's `RetrofitApi` declares *and calls*,
against every path string in the iOS sources. Two caveats — Android has overloaded method names
(`workshopAds`, `workshopAdDetails`) so a path can look called when only its sibling is, and a path merely
mentioned in an iOS comment counts as present. Of the 13: 4 are freelancer order chat (now built), 3 are
memberships (deferred), 2 are dead in Android too, 1 is the broken `Vendor/workshop_ad_detail`, and 3 are
the small endpoints in item 3.

---

## 4. The order chat — done, and the defect it surfaced

Driven on 15 Aug as vendor 706. Both tabs list the expected rows and the thread opens with the empty
state. **The one thing driving it was for was the defect it found:**

`fetch_order_chats` answers a thread with no messages as `{"status":false,"error":true,"message":"No
chats found"}` — **with no `sending` key**. The thread read `sending` to decide whether to show the
composer and defaulted to `true` when absent, so an expired order got a working composer whose every
send would have come back "Message not sent, Order Expired". The list row already knows (`expired`),
and now seeds it. Confirmed after the fix: composer replaced by "Order Expired / Rejected", empty state
reads "This order is closed."

The lesson generalises — **a missing key is not the same as a false one.** Any other `exists()` check
guarding a permissive default has the same shape of bug latent in it.

**Still not verifiable without new data:** the message row shape and the send path. Both QA orders are
expired, so `freelancing/send_message` answers "Message not sent, Order Expired". The parser was written
against Android's `FreelancerChatModel` (`message`, `created_at`, `sender_name`, `sender_id`,
`sender_type`, `order_id`) rather than live data, and the bubble side uses Android's rule —
`sender_id == userId && sender_type == userType`, **both**, since a company and a user can share a numeric
id. To close this out, someone needs to create a freelancer order dated today or later.

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
- **A notification banner lives ~5 seconds, which is shorter than a tool round-trip.** Three attempts at
  `simctl push` then tap missed it, and the log showed only `willPresent`, never `didReceive`. What works:
  push on a loop in the background (`for i in $(seq 1 30); do simctl push …; sleep 2; done`) so a banner
  is guaranteed to be on screen whenever the tap lands. Tapping the notification on the *lock screen*
  does not work either — it wants authentication first.
- **The derived-data module cache corrupts periodically** (`module file ... .pcm not found`). Fix is
  `rm -rf /private/tmp/cc-dd` and a full rebuild; clearing only `ExplicitPrecompiledModules` was not enough.

---

## 6. Pre-launch checklist

- [ ] Decide cross-platform chat (§1) — **blocks launch**
- [ ] Report the `Home/get_by_company_id` credential leak — **blocks launch**, and it is a one-line
      backend fix (stop selecting those columns)
- [ ] Backend: two-credential push keyed on `firebase_token_device`
- [ ] Deploy `firestore.rules`, then chase the custom tokens that let the participant-scoped version go live
- [ ] Attach a billing account (SMS quota)
- [x] ~~Finish order chat verification~~ — done, and it found a defect (§4)
- [x] ~~Push receive + tap routing~~ — built and driven; delivery still blocked
- [ ] Report the other 6 backend bugs (`PARITY_STATUS.md` §5)
- [x] ~~Memberships → "Coming soon"~~ — not needed; the screens already work and the card path already
      says it is unavailable
- [ ] Test on a **real device** — nothing has been. Phone auth behaves differently there: with the APNs key
      uploaded it uses a silent push instead of the reCAPTCHA browser fallback seen on the simulator
- [ ] Deployment target is **iOS 15**, but the simulator is iOS 26 — newer SF Symbols and APIs compile and
      run there and would break on a real iOS 15 device. This has already happened twice
