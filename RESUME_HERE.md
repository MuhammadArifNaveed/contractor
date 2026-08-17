# Resume here — iOS/Android parity, state at 2026-08-17

Written to be enough on its own. Read this, then `HANDOVER.md` (ground rules, tooling, traps) and
`PARITY_STATUS.md` (the authority on per-feature state).

Branch `feature/arif`. Build is clean. **Five commits are local and unpushed** — `git push origin
feature/arif` (the assistant's push was blocked by a permission gate, not by anything wrong with them).

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
- **Freelancer browse and multi-select hiring.** The list populates with the freelancer the API actually
  returns, the checkbox and selection bar behave, and Book opens the per-freelancer booking sheet. The
  final Confirm was **not** pressed: it creates a real hiring record against production.
- **Membership detail**, including the negative case for the new workshop add-on button — vendor 706 owns
  the add-on, so the button correctly stays hidden.
- **The workshop quotation attachment row**, with the Files picker opening. Not submitted: that posts a
  real bid on a live ad and consumes one of the account's 11 quotations.

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

Everything here is blocked on the same thing: the simulator holds a **company** session, and these are
all consumer-side. Signing out costs the owner a PIN entry to restore, so they were left for the next
consumer login rather than burning it.

- **Company Finder** (`CompanyFinderView.swift`). `Home/get_by_company_id` verified live (238 companies
  for `a`, `error:true` + "company not found." for a miss).
- **Job-title suggestions.** `jobs/search_job_title` verified live (`eng` → Civil Engineer), wired into
  `SearchJobsView` as tappable chips.
- **The Edit Profile fix.** It used to send `address`, `city`, `country` and `job_category` as empty
  strings, and the backend wrote the blanks over real values — so saving a name change erased the user's
  address and job category. Now sent properly, prefilled from the stored record, with the city and
  category pickers backed by `Home/get_search` instead of two hardcoded invented arrays. Reasoned against
  user 45's live record (`city_id` 10, `cv_job_category` "carpentor", `country_id` 2); not seen on screen.
- **The consumer freelancer-hire fix.** `FreelancingService.hireFreelancers` sent the selection under
  `freelancer_id`; the backend reads `freelancer_data`, so checkout reported success and hired nobody.
  Probed live — the wrong name and no name at all give the identical error. Not driven.
- **The pick-up location picker** (`PickUpLocationPicker.swift`) and the freelancer-address id fix. The
  addresses live in the freelancer profile, behind the consumer login.

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
| 10 backend bugs | Backend dev | The four already known (`Vendor/workshop_ad_detail` 500s, breaking this screen on **Android too**; `Home/recent_enquiries` returns HTML, unknown column `t2.company_whatsapp_phone`; `jobs/update_direct_hiring_status` crashes on an unknown id; `jobs/view_direct_hirings` has no `total_page` so it cannot page) plus `Home/quotation_fee_paid` (`Undefined variable $quotation_id`), `vendor/membership_details` (throws on null), `freelancing/fetch_order_chats` (omits `sending` for an empty thread, which put a live composer on an expired order), and the hiring-status case mismatch. Full list in `PARITY_STATUS.md` §5 |

### Code work, nothing blocking it

1. **Deploy `firestore.rules`.** Written, in the repo root, with `firebase.json` and `.firebaserc`
   alongside it so `firebase deploy --only firestore:rules` works as soon as someone installs the CLI
   (it is not installed on this Mac). Otherwise paste it into the console.

   It is a real improvement on `allow read, write: if true` — writes are shape-validated, deletes are
   off, message text is immutable, everything outside `chat`/`user_connections` is closed — but **reads
   stay open**, and the header explains why that cannot be fixed from the rules file alone. Locking
   reads needs exactly one thing now: the backend returning a `firebase_custom_token` at login. **The
   iOS side is already done** (`ChatAuthService`, wired into both login paths and sign-out, a verified
   no-op until the field appears). When it lands, swap in the `participantsOnly` rules at the bottom of
   the file. Do not call chat private until then.

   `./scripts/firebase_preflight.sh` checks the file-level Firebase config in one command — bundle id,
   the phone-auth URL scheme, the rules, and that the plist is in the Resources phase. It lists the
   console-side items it cannot see. Run it after any Firebase project change; `HANDOVER.md` §4 is the
   full checklist.
2. **Sign the consumer in.** It is the single unlock for everything left that can be verified: Company
   Finder, the job-title chips, the Edit Profile fix, the consumer freelancer-hire fix, the pick-up
   location picker, and the freelancer form prefill. All are built and reasoned against live data; none
   has been seen on screen, because the simulator holds a company session.
3. **Localization — the one large piece of work left.** Android ships 264 Arabic strings and branches on
   language in 138 files, rendering `arabic_name` / `arabic_title` / `arabic_description` from the API.
   iOS has no `Localizable.strings`, no `.lproj` beyond `Base`, renders no Arabic content field (it parses
   four and shows none), and its language picker saves a preference nothing reads. For a UAE app this is
   the biggest remaining gap by a wide margin. Scope it deliberately — it is a project, not a task.
4. **Cleanup:** dead storyboard scenes; `AppTheme.Fonts` still hands out fixed point sizes, so consumer
   screens ignore the system text size (all 222 call sites funnel through six helpers in
   `AppTheme.swift`, so it is one file — but it shifts type across ~34 screens and wants a visual pass).
   `VendorTheme.Text` is already relative and is the model to copy. Also ~40 files are listed twice in
   `project.pbxproj`'s Sources phase, which makes every build print "Skipping duplicate build file" and
   buries real warnings.

**Done — do not re-open.** Freelancer order chat verification; push receive and tap routing; Company
Finder; job-title suggestions; the workshop add-on coupon purchase; workshop quotation attachments; the
`toAll` topic; multi-select hiring; the pick-up location picker. Plus five bugs found while doing them,
listed in §5.

Two items dissolved on inspection rather than being built: **"available for job" saves nowhere** is not a
gap — `Account/update_user_profile` has no part for it, so Android does not save it either. And
**memberships → "Coming soon"** was unnecessary: the screens already work and the card path already says
it is unavailable.

### Endpoint gap, re-audited 17 Aug

**8 gaps, 0 fabricated endpoints, none of them portable work.** Android declares 126 endpoints and calls
121 of them; iOS covers **113 of those 121**. Of the 8: 3 are card payments (deferred), 2 are broken on
the backend, and 3 are dead in Android — the unused halves of two overloaded method pairs plus the
never-launched `VendorWorkshop` activity. `PARITY_STATUS.md` §2 has the table.

Two traps when re-running this audit, both of which produced wrong answers first time:
stripping `//` comments naively also truncates every hardcoded `https://…` URL (only treat `//` as a
comment when not preceded by `:`), and matching Android method names alone conflates the overloaded
`workshopAds` / `workshopAdDetails` pairs.

---

## 4. Bugs found by auditing — and the pattern behind them

Six defects surfaced while closing the parity gaps. None was reported by a user, none showed as a crash,
and **four of them made a screen silently do nothing while reporting success.** That is the pattern worth
carrying forward: on this backend a wrong key or a wrong id produces an empty result, not an error.

| Bug | Effect | How it was caught |
|---|---|---|
| Consumer hire sent `freelancer_id`, backend reads `freelancer_data` | Checkout said "Freelancer Hired" and hired nobody | Probing the endpoint with the wrong name and with nothing at all — identical error both times |
| Freelancer browse read `freelancers`, key is `freelancers_list` | "No freelancers found" always; hiring unreachable from the vendor side | curl showed `total: 1` while the screen showed none |
| Freelancer addresses keyed on the user id, not the record id | Address list always empty; saves went under someone else's record | `freelancer_id=45` returns `[]`; real rows carry `freelancer_details_id` |
| Edit Profile sent four fields as empty strings | The backend wrote the blanks over real values — saving a name change erased the user's address and job category | Comparing part-by-part against Android's `UpdateProfile` |
| `fetch_order_chats` omits `sending` for an empty thread | Expired orders got a working composer whose every send would fail | Driving the screen — see below |
| Pick-up coordinates hardcoded `"0.00000000"` | Every pick-up point saved as null island; the point is the record's whole purpose | Reading the code around the address save |

**The generalisable lesson: a missing key is not the same as a false one.** Any other `exists()` check
guarding a permissive default has the same shape of bug latent in it. And an empty list from this backend
should be treated as suspicious until the id you sent is confirmed to be the id it wants.

### The order chat, in detail

Driven as vendor 706. Both tabs list the expected rows and the thread opens with the empty state.
**The one thing driving it was for was the defect it found:**

`fetch_order_chats` answers a thread with no messages as `{"status":false,"error":true,"message":"No
chats found"}` — **with no `sending` key**. The thread read `sending` to decide whether to show the
composer and defaulted to `true` when absent, so an expired order got a working composer whose every
send would have come back "Message not sent, Order Expired". The list row already knows (`expired`),
and now seeds it. Confirmed after the fix: composer replaced by "Order Expired / Rejected", empty state
reads "This order is closed."

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
- [ ] Report the other 9 backend bugs (`PARITY_STATUS.md` §5)
- [ ] Push the five local commits — `git push origin feature/arif`
- [ ] Sign the consumer in and drive the six unverified consumer screens (§2)
- [ ] Decide whether **Arabic ships at launch**. If yes, localization is a project's worth of work and
      needs scheduling now, not discovering later — see §3
- [x] ~~Memberships → "Coming soon"~~ — not needed; the screens already work and the card path already
      says it is unavailable
- [x] ~~Multi-select hiring and pick-up addresses~~ — built; fixing them uncovered two more silent bugs (§4)
- [ ] Test on a **real device** — nothing has been. Phone auth behaves differently there: with the APNs key
      uploaded it uses a silent push instead of the reCAPTCHA browser fallback seen on the simulator
- [ ] Deployment target is **iOS 15**, but the simulator is iOS 26 — newer SF Symbols and APIs compile and
      run there and would break on a real iOS 15 device. This has already happened twice. `Map`,
      `.fileImporter` and `.submitLabel` were added this session; all are iOS 14/15 APIs, but check them
      on a real iOS 15 device before shipping
