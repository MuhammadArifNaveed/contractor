# Handover — read this first

> **Resuming in a fresh chat? Start with [`RESUME_HERE.md`](RESUME_HERE.md)** — current state,
> what is left, who is blocking what, and the traps that cost hours. This file is the ground
> rules and tooling underneath it.

Enough context to pick up the iOS/Android parity work in a fresh session without re-deriving anything.
Where this file says "see X", X has the detail.

- [`PARITY_STATUS.md`](PARITY_STATUS.md) — what is replicated, what is left, the verification ledger,
  the backend issues list. **The authority on current state.**
- [`USER_SIDE_ROADMAP.md`](USER_SIDE_ROADMAP.md) — consumer-side detail, per-feature notes.
- [`COMPANY_SIDE_ROADMAP.md`](COMPANY_SIDE_ROADMAP.md) — company/vendor plan and the design system.
- [`IOS_VENDOR_PARITY_PROGRESS.md`](IOS_VENDOR_PARITY_PROGRESS.md) — the original phase log.

---

## 1. What the job is

One repo, two apps: `TheContractor/` (iOS, the thing being built) and `TheContractor-Android/` (the
reference). The goal is functional parity with Android while the iOS presentation is better than
Android's, not a copy of its layouts.

Branch: `feature/arif`. Base: `master`. Everything below is pushed.

### Ground rules that keep being right

- **`TheContractor-Android/app/src/main/java/com/thecontractor/RetrofitLibrary/RetrofitApi.java` is the
  only authority on endpoints.** If a path is not declared there, it does not exist. Read the
  `@Part("name")` annotation, never the Java argument name — they differ often.
- **Paths are case-sensitive.** `vendor/...` lowercase for the vendor API; `Home/...`, `Account/...`,
  `Vendor/...` capitalised. Android's own spelling wins (`Home/twentyFourCompanies`, not lowercase).
- **Backend typos are load-bearing**: `quotations_dashnoard`, `vaccancies`, `Vendor_profile`, `images[]`,
  `sur_name` (only on register), `isChecked` (camelCase, only on the freelance-status toggle).
- **Every API value is a string**, including `"0"`/`"1"` flags. Parse through SwiftyJSON `stringValue`.
- **Check reachability before fixing a screen.** Roughly 25 files have been deleted this way — dead auth
  screens, dead browse screens, 17 dead vendor screens, the fabricated cart/checkout. Grep for the type
  name outside its own file before touching it.
- **Never invent an endpoint or a URL.** If Android does not have one, say so instead.
- iOS deployment target is **15.0**; the simulator is iOS 26, so newer SF Symbols and APIs compile and
  run there but would break on a real iOS 15 device. Two rounds of this have already happened.

---

## 2. Tooling

Scripts live in the session scratchpad and **get wiped between sessions** — recreate as needed. Paths
below are the current session's; the pattern is `/private/tmp/claude-501/<project>/<session>/scratchpad`.

| Script | What it does |
|---|---|
| `build.sh` | `xcodebuild -workspace TheContractor.xcworkspace -scheme TheContractor -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -derivedDataPath /private/tmp/cc-dd -quiet build`, then echoes `--- exit: N ---`. |
| `run.sh` | `simctl install` + `launch` on the booted device. |
| `audit_urls.py` | Every API path iOS calls vs Android's declared list. Understands all **three** URL shapes in this codebase: `BASE_URL + "literal"`, `BASE_URL + EndPoints.constant`, `"\(EndPoints.BASE_URL)Home/foo"`, plus hardcoded absolute URLs. Exits non-zero on anything undeclared. **Currently reports 0.** |
| `parity.py` | Payload audit: iOS part names vs Android `@Part` names. Repeatedly caught bugs the path audit could not. Four known flags, all triaged (3 false positives, 1 real: `addWorkshopQuotation` could not attach a document — **now fixed**). |
| `add_files.py` | Adds a Swift file to `project.pbxproj` (one file ref, one build file, one group child, one Sources entry). Takes `--group <uuid> --write`. Group uuids: Views `806CA97D2F5768C600D31D28`, Vendor `806CA9462F5768C600D31D28`, Services `18EA180A26D28820003DF2FC`, **Global `18EA17F226D28820003DF2FC`**, **Components `806CA8E12F57689000D31D28`**. **The group must match the file's real directory** — a group's `path` is what the file ref resolves against, so registering `Global/Foo.swift` under Views makes the build look for `SwiftUI/Views/Foo.swift` and fail with "Build input file cannot be found". Two files were misfiled this way. Also beware: several names appear in more than one group (there is a "Recovered References" group), so find the group by its `path = …`, not by which group happens to contain a similarly named file. |
| `scripts/firebase_preflight.sh` | **In the repo, not the scratchpad.** Checks the four file-level items from §4's checklist in one command and names the console-side ones it cannot see. Run it after any Firebase project change. |
| `drop_files.py` | Removes files from `project.pbxproj` with a dangling-uuid assertion. **Must match names with a word boundary** — plain substring matching once nearly unregistered `FreelancerCheckoutView` while removing `CheckoutView`. |

A **plist** goes in the Resources phase (`18EA17D326D287CC003DF2FC`), not Sources — `add_files.py` does
Sources only.

### Simulator

`attach` on the simulator MCP tool fails on this Mac (it wants a `/var/db/xcode_select_link` that is not
there). **`screenshot`, `tap`, `text` and `swipe` all work headlessly** against the booted device by
`udid` — an earlier session wrongly concluded no interactive verification was possible.

- Device: iPhone 17 Pro, udid `0931632C-BE3E-4E7D-AE6A-BA8C379D62A0` (confirm with
  `xcrun simctl list devices booted`).
- Coordinates are **device points**; screenshots come back larger. Scale by
  `points_width / image_width` — about **0.437** on this device.
- **Screenshot between navigation steps.** Blind tap chains fail often and silently; several hours have
  gone into taps that landed on the tab bar.
- **Convert coordinates from the whole image height, not a remembered number.** A tap meant for a bottom
  bar landed mid-screen because the scale was applied to the wrong axis reference, and the resulting
  "nothing happened" was briefly misdiagnosed as a SwiftUI bug. Multiply the *displayed* x and y by
  `points_width / image_width` (~0.437 here) and sanity-check that the result is inside the 402×874 frame.
- **A notification banner lives ~5 seconds**, which is shorter than a tool round-trip, so a single
  `simctl push` then tap always misses and the log shows only `willPresent`, never `didReceive`. Push on
  a loop in the background (`for i in $(seq 1 30); do simctl push …; sleep 2; done &`) so a banner is
  guaranteed on screen when the tap lands, then `pkill` the loop. Tapping the notification on the *lock
  screen* does not work either — it wants authentication first.
- A stored **company** session survives `simctl uninstall` because it lives in the keychain:
  `xcrun simctl keychain <udid> reset`.
- Dark mode: `xcrun simctl ui <udid> appearance dark|light`. This is how the last theme defect was found.
- `simctl spawn <udid> defaults ...` is unreliable for this app's `UserDefaults`; log out through the UI
  instead.

### Test accounts

The owner supplied a company account and a consumer account in chat. **Do not write the PINs into the
repo** — that discipline has been kept so far. Two facts that are safe and needed:

- The consumer login sends the phone as **`+971` + the 10 local digits** (`PhoneNumber.e164`). Curl with
  `user_phone=+971…`; without the country code it returns "Invalid credentials".
- The QA consumer is user id **45** (uuid on the record), with real workshop ads, one estimate request and
  a freelancer record. The QA company is vendor id **706**, `user_type=companies`, with 24 direct hires
  and 42 jobs. A second consumer, id **46**, was created by the sign-up flow and has nothing.
- **User 45's freelancer *record* is id 2, not 45.** The freelancer address endpoints take that record id
  as `freelancer_id` — the column is `freelancer_details_id` — and passing the user id instead returns an
  empty list rather than an error, which is how it went unnoticed. Same trap for any other
  freelancer-scoped call.
- Vendor 706 already owns the workshop membership add-on, so the "add with a coupon" button on Membership
  detail is correctly hidden for it. Testing the *visible* case needs a membership without the add-on.

---

## 3. Where the app stands

**113 of the 121 endpoints Android actually calls are implemented; 0 fabricated.** (Android declares 126;
5 of those it never calls itself.) All 8 remaining are accounted for — 3 payment-gated, 2 backend-broken,
3 dead in Android. `PARITY_STATUS.md` has the table and is kept current.

**The one large gap is localization.** Android ships 264 Arabic strings and branches on language in 138
files; iOS has no `Localizable.strings` at all and renders no Arabic content field, though it parses
several. The language picker saves a preference nothing reads. Payments are the other exclusion, deferred
by decision.

- **Company/vendor side** — complete. Every drawer item and the header's View Profile reach a real screen
  or say plainly the feature is unavailable.
- **Consumer side** — feature-complete including sign-up and its SMS verification code, which is built
  and driven. Two screens built this session have never been *looked at* — Company Finder and the
  job-title suggestion chips — because both sit behind a consumer login and the simulator holds a
  company session.
- **Guest (no-login)** — matches Android item-for-item: Android hides twelve drawer items from a guest and
  gates Freelancer Dashboard, the Workshop tab and the estimate consultation behind a login prompt; iOS
  hides the same twelve and gates the same three. Never walked end to end.
- **Design system** — one system. `AppTheme`'s colours resolve to `VendorTheme` (the shared system despite
  the name), so consumer screens share the palette and follow dark mode; every yellow bar in the app is
  `VendorTopBar`, which takes either a trailing icon or an arbitrary `@ViewBuilder`.

---

## 4. Firebase — current state

### ⚙️ Changing the Firebase project — the full checklist

Every time the Firebase account or project changes, **all of these** have to be redone. Each one has
already cost a round trip at least once, and every one of them fails quietly or with a misleading error.

| # | Step | Where | If you skip it |
|---|---|---|---|
| 1 | Register an **iOS app** with bundle id `com.contractor.TheContractorx` | Project settings → Add app → iOS | No plist exists to download. `GOOGLE_APP_ID` is issued here and cannot be hand-written |
| 2 | Replace `TheContractor/GoogleService-Info.plist` | repo | App talks to the old project |
| 3 | **Update the URL scheme** in `TheContractor/Info.plist` → `CFBundleURLTypes` to `app-<GOOGLE_APP_ID with colons as dashes>` | repo | **Hard crash** on the SMS step: `PhoneAuthProvider` calls `fatalError` when the scheme is missing |
| 4 | Create the **Cloud Firestore** database | Build → Firestore Database → Create database | Every chat read and write 404s. Not the Realtime Database — different product |
| 5 | Set Firestore **rules** to allow the app's access | Firestore → Rules | 403 `Missing or insufficient permissions`. The app never signs in to Firebase Auth, so `if request.auth != null` denies everything |
| 6 | **Authentication → Get started**, then enable **Phone** | Build → Authentication | `CONFIGURATION_NOT_FOUND` on sign-up and password reset |
| 7 | Add a **test phone number** | Authentication → Sign-in method → Phone | A simulator cannot receive a real SMS |
| 8 | **SMS region policy** → Allow → **United Arab Emirates (AE)** | Authentication → Settings → SMS region policy | `OPERATION_NOT_ALLOWED : SMS unable to be sent until this region enabled`. Separate gate from step 6 |
| 9 | Upload the **APNs auth key** (`.p8`, dev + production) | Project settings → Cloud Messaging | No push delivery, and phone auth falls back to reCAPTCHA in a browser on real devices |
| 10 | Generate a **service account key** and give it to the backend | Project settings → Service accounts | Backend cannot push to this project's tokens |
| 11 | Attach a **billing account** before launch | Google Cloud console | SMS is capped at **10/day** on a new project |

**Verify from the terminal rather than trusting the console** — the console has shown the wrong project
more than once. `API_KEY` comes from the plist:

```
# Firestore reachable and rules open?
curl -s -H "x-goog-api-key: $KEY" \
  "https://firestore.googleapis.com/v1/projects/<PROJECT>/databases/(default)/documents/user_connections?pageSize=1"
# 404 = no database · 403 = rules deny · 200 = good

# Auth configured, Phone on, region allowed?
curl -s -X POST "https://identitytoolkit.googleapis.com/v1/accounts:sendVerificationCode?key=$KEY" \
  -H "Content-Type: application/json" -d '{"phoneNumber":"+971500000000"}'
# CONFIGURATION_NOT_FOUND = Auth never initialised · OPERATION_NOT_ALLOWED = region not allowed
# sessionInfo = good
```

**Also remember:** Firestore and FCM are per-project, so changing projects **orphans every existing
conversation** and invalidates every stored push token. Chat history does not migrate.


iOS runs on its **own Firebase project, separate from Android's**, and will keep doing so: Android is
`thecontractor-uae` (sender 440409598739) and nobody on this side has access to that account. Firestore
and FCM are both per-project, so the two apps' conversations cannot see each other and the backend's push
credentials cannot reach iOS. The history of which project iOS used is below; only the last one matters.

> ### ✅ Resolved — iOS is now on `contractor-e1442`
>
> b1d78 was abandoned. Two things were wrong with it: the owner's account had no permission to create a
> Firestore database there (the console offered *"ask a project owner for the necessary permissions"*
> instead of a Create button), and the database that *did* appear in it was a **Realtime Database** —
> a different product the chat code cannot talk to. Do not confuse the three console sections:
> **Realtime Database**, **Storage** (needs a paid plan, irrelevant here) and **Cloud Firestore**. Only
> the last one matters; Android's chat and this port both use `FirebaseFirestore` / `db.collection(...)`.
>
> A fresh project, **`contractor-e1442`**, was created with the owner as owner, an iOS app registered for
> `com.contractor.TheContractorx`, Firestore created, and rules published as `allow read, write: if true`.
> `TheContractor/GoogleService-Info.plist` is that project's. Read, write and delete are verified against
> it, and **chat has now been driven end to end on it** — see the ledger in `PARITY_STATUS.md`.
>
> Three things to know:
>
> - **The open rules are deliberate and temporary.** The app authenticates against the PHP backend and
>   never signs into Firebase Auth, so there is no identity for rules to test and production-mode rules
>   deny every query. The API key ships inside the app binary, so the database is currently readable by
>   anyone who extracts it. Tightening this means adopting Firebase Auth — separate work.
> - **iOS chat is isolated from Android chat, permanently for now.** Android is on `thecontractor-uae`,
>   which has its own live Firestore with real conversations in it. The owner has no access to that
>   account, so the two will not converge without one.
> - **Push delivery is still dead.** The backend pushes with `uae` credentials and cannot reach tokens
>   minted by `contractor-e1442`. The two `send_message_notification` calls fire correctly; only delivery
>   is blocked.

Done:

- Pods `Firebase/Auth`, `Firebase/Firestore`, `Firebase/Messaging` (12.17.0). CocoaPods prints a
  deprecation notice — Firebase stops publishing to CocoaPods after October 2026, so SPM is the eventual
  move.
- `GoogleService-Info.plist` in `TheContractor/`, registered in the Resources phase.
- `FirebaseApp.configure()`, APNs registration and `MessagingDelegate` in `AppDelegate`.
- **`firebase_token` now carries the real FCM token.** It used to be the literal `"testtoken123"` on every
  login and registration call, so the backend stored a token it could never push to. Falls back to
  Android's own `"null"` default before a token arrives (`Global.firebaseTokenForRequest`).
- `UserViewModel` gained `uuid` — the login response has always returned it and nothing read it; Firestore
  keys every chat document on it.
- **Chat**: `ChatService.swift` + `InboxView.swift`. Both inboxes (consumer and company) now open it
  instead of the "not available yet" screen.

### The Firestore schema, as read off Android

Two collections, no chat endpoint of any kind (`Home/get_chats`, which iOS used to call, never existed).

**`user_connections`** — one document per company/user pair:

```
company_id, company_uuid, company_serial_no, company_name, company_is_active,
user_id, user_uuid, user_name, full_name, user_is_active, is_active,
chat_uuid, created_at, last_message, message_time
```

**`chat`** — one document per message:

```
company_uuid, user_uuid, chat_uuid, time, country_time,
company_is_view, user_is_view, message, sent_by   // "user" | "company"
```

Queries: inbox is `where user_uuid == uuid` (consumer) or `where company_uuid == uuid` (company), with a
snapshot listener; a thread is `where chat_uuid == X order by country_time`, snapshot listener. Sending
adds to `chat` then updates the connection's `last_message` + `message_time`.

Two things copied rather than corrected:

1. **Timestamps are `yyyy-dd-MM HH:mm:ss` — day and month swapped.** Android's `getCurrentDateTime()`
   does this, and messages are ordered by `country_time` **as a string**, so writing a sensible
   `yyyy-MM-dd` would interleave iOS and Android messages wrongly.
2. `country_time` is that format in **Asia/Dubai**; `time` is the device's own zone.

### Who creates a conversation — answered

**Only the company side creates one.** `VendorChat.checkUserConnectionFromFireStore()` looks for a
document matching `company_uuid` + `user_uuid`; if there is none, `createUserConnectionOnFireStore()`
writes it **lazily on the first send**, with `chat_uuid = UUID.randomUUID()`, `created_at` in the swapped
format, `last_message` and `message_time` empty, and the three `is_active` flags `"1"`. The consumer's
`Chat.java` only ever reads connections and updates `last_message`; a user cannot start a thread.

Android opens `VendorChat` from **`VendorWorkshopDetail`** (and the inbox row adapter). So on Android the
entry point for a *new* conversation is a company messaging a user about a workshop ad.

### iOS now creates connections too — with two detours Android does not have

`ChatService.createConnection` writes the same fifteen fields in the same order, and `send()` calls it
lazily when the connection is still pending (`id == ""`), which is Android's `if(userConnection) send
else create` branch. `VendorWorkshopDetailView` has the Message action, mirroring `VendorWorkshopDetail`.
Two things could not be copied:

1. **`Vendor/workshop_ad_detail` is dead on the backend.** It answers
   `Call to undefined method Workshop_model::get_workshop_ad_detail_by_id()` (`Vendor.php:2013`) for
   every id. That is the endpoint feeding Android's `VendorWorkshopDetail`, so **Android's own chat
   entry point cannot load either** — the screen behind the Message row never renders. iOS uses
   `workshop/get_workshop_details` instead, which works but returns no `uuid` for the ad's owner.
2. **So the owner's uuid comes from `Account/get_user_details_by_id`** (part `user_id`, response key
   `user`), verified live: it returns `uuid`, `username`, `name` and `surname` — exactly the four values
   Android reads off its ad model. This endpoint was on the "never called" list; it has a use now.

**Android gates the chat row on `show_chat == "1"`; iOS deliberately does not.** Every row from
`workshop/workshops` and `workshop/show_workshops_for_interest` carries `show_chat: "0"`, no declared
endpoint writes the flag (`workshop/submit_workshop_ad` does not take it), and the detail endpoint does
not return it at all. Honouring it hid the Message action on every ad in existence, so the owner chose to
show it instead. The flag was plumbed through the list row for a while; that plumbing is gone, since
nothing read it once the gate went. `canMessageOwner` still requires a signed-in company and an ad owned
by a *user* — `user_connections` has one company half and one user half, with no company-to-company form.

---

## 5. Pending, in the order worth doing

1. **Chat is done. Nothing is pending on it** — every path has now been driven and checked against the
   documents in Firestore, including `findConnection`'s reuse branch (a second Message tap on the same ad
   reopened the same thread; the collection still holds exactly one connection with the same `chat_uuid`)
   and `markThreadViewed` on both sides. The only chat work left is outside the app: push *delivery*
   (item 3), which no code change here can unblock.
2. **SMS code on sign-up — done and verified end to end.** Driven on the simulator with the test
   number `+971500000000` / `123456`: the code step appeared, the code was accepted, and the details
   form opened with the verified number locked in.

   Two things worth knowing. **On a simulator there is no APNs token**, so FirebaseAuth falls back to a
   reCAPTCHA page in an `SFSafariViewController` and comes back through the custom URL scheme — which is
   why that `Info.plist` entry is load-bearing rather than decorative. On a real device the uploaded
   APNs key means a silent push is used and no browser ever appears. And **the SMS region policy is a
   separate gate from enabling Phone**: a new project denies every `+971` number with
   `OPERATION_NOT_ALLOWED : SMS unable to be sent until this region enabled by the app developer` until
   AE is added under Authentication → Settings → SMS region policy.
3. **Push delivery.** The token now reaches the backend; what is untested is whether a notification
   arrives and what happens when it is tapped. Blocked in practice by the project mismatch, since the
   backend pushes from `uae`.
4. **Freelancer form prefill is unverified on screen.** Written against the live record and compiles.
   Check: sign in as user 45, Profile → Profile Settings → Freelancer profile; expect hourly rate 5, two
   skills, category `carpentor`, Dubai / Al Mamzar, 10:00–18:00, the bank block, four addresses.
5. **Company Details' top bar is unverified** after moving to `VendorTopBar`'s trailing builder — the
   Add-to-enquiry pill's fit inside the shared bar is the only thing to look at.
6. Then the smaller items in `PARITY_STATUS.md` §4: the still-dead "available for job" checkbox, the four
   profile fields Edit Profile sends empty, `addWorkshopQuotation`'s document, freelancer multi-select.

---

## 6. Verification discipline

The standard that has held up: **endpoint verified live with curl, parser written against the real key
names, then the screen driven in the simulator.** Compile-and-launch alone has been wrong twice —
the last visual pass found four defects on two screens whose endpoints were all correct.

Two write actions are deliberately **never exercised**, because neither is reversible on the QA data:
setting a direct-hire status (`hiring_status` starts empty and there is no way back to empty) and
submitting the estimate consultation. Both are contract-verified instead.

Nothing has been tested on a physical device, in Arabic, or (except the theme pass) in dark mode.

---

## 7. Traps that have already cost time

- **`project.pbxproj` name matching must be anchored.** `CheckoutView.swift` also matches
  `FreelancerCheckoutView.swift`.
- **zsh does not word-split unquoted `$FILES`**, and `--include=*.swift` unquoted is a glob error — two
  leak scans were silently vacuous because of this. Quote globs; prefer Python for anything structural.
- **`pgrep -f "pod install"` inside a shell command that itself contains that string matches itself** —
  an `until ! pgrep …` wait loop then never exits.
- **`containerView` is pinned to all four edges of the root view**, with the top and bottom bars drawn
  *over* it. A SwiftUI screen embedded at `containerView.bounds` loses its first ~45pt behind the yellow
  bar. Use `showTabScreen(_:)`, which pins between the bars.
- **A SwiftUI `NavigationLink` does nothing on a screen pushed onto a UIKit stack** (Edit Profile). Use a
  sheet.
- **Do not wrap a screen in `NavigationView` if it is pushed from one** — it renders a second floating
  back chevron.
- **`VendorTopBar`**: pass `onBack` only for pushed or sheet screens. A drawer-rooted screen gets the
  hamburger, because `dismiss()` has nothing to pop. Consumer drawer screens post
  `"GoBackToTabBar"` instead.
- **Only post `"RequestLogin"`** to ask for the login screen. Posting `"GoToLogin"` as well made
  `loginUser()` run twice and left the app on whatever tab was behind.
- **The backend writes and reads some values in different cases** — hiring status is written
  `Shortlisted` and stored `shortlisted`. Compare case-insensitively.
- **Screens shipped with demo data.** `UpdateFreelancerView` had "Test Freelancer", a made-up IBAN and
  four sample addresses in its `@State` initialisers, all of which would have been submitted. Check for
  this pattern before trusting a form.
- Old-style `project.pbxproj` with many duplicate file references; the build prints "Skipping duplicate
  build file" warnings that are pre-existing and harmless.
- **The drawer is installed two different ways, and only one of them has a navigation controller.**
  `LoginViewController` *pushes* it (`enterApp()`, `actionSkip`), so it sits inside a `UINavigationController`;
  but `CompanyLoginView` and `SceneDelegate`'s already-signed-in path assign
  `window.rootViewController = drawer`, where it has none. Code that reached for
  `(navigationController?.parent as? KYDrawerController)?.navigationController` therefore succeeded on the
  cast and then sent everything to a nil optional — sign-out and the login prompt both did nothing at all,
  silently, for the whole session. `MainContainerViewController.showLoginScreen()` handles both shapes;
  anything else walking that chain needs the same treatment. Note `LoginViewController` cannot function
  without a navigation controller — Skip, Forgot password, Sign up, Login as a company and `enterApp()`
  all push.
- **A Firestore equality filter plus `order(by:)` on another field needs a composite index**, which a
  freshly created project has none of, and the query fails outright until someone creates it by hand from
  the URL in the error. `observeMessages` sorts in Swift instead, as `observeConnections` already did.
  Android only works because that index was added to its project at some point.
- **`VendorTheme.date` cannot be trusted for chat timestamps.** It tries `yyyy-MM-dd` first and only falls
  back to the swapped order when that *fails* — and on a chat timestamp it never fails, it just silently
  yields the wrong month for any day ≤ 12. Chat parses with the exact format via `ChatService.display` /
  `shortDisplay`. Anything else reading a swapped-format string has the same bug latent in it.
- **A fresh `simctl install` starts with no session at all.** The keychain note above is about surviving
  `uninstall`, not about a session existing in the first place — after a reinstall the drawer shows
  "Login or Create Account" and both halves have to be signed in again.
- **`curl` is not on `PATH` inside a `for` loop** in this sandbox, though it resolves fine in a plain
  command. Use `/usr/bin/curl` in loops.
