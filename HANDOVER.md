# Handover — read this first

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
| `parity.py` | Payload audit: iOS part names vs Android `@Part` names. Repeatedly caught bugs the path audit could not. Four known flags, all triaged (3 false positives, 1 real: `addWorkshopQuotation` cannot attach a document). |
| `add_files.py` | Adds a Swift file to `project.pbxproj` (one file ref, one build file, one group child, one Sources entry). Takes `--group <uuid> --write`. Group uuids: Views `806CA97D2F5768C600D31D28`, Vendor `806CA9462F5768C600D31D28`, Services `18EA180A26D28820003DF2FC`. |
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

---

## 3. Where the app stands

**101–103 of Android's 124 endpoints are implemented; 0 fabricated.** Of the ~21 not called, 6 are dead in
Android too. `PARITY_STATUS.md` has the grouped list and is kept current.

- **Company/vendor side** — complete. Every drawer item and the header's View Profile reach a real screen
  or say plainly the feature is unavailable.
- **Consumer side** — feature-complete including sign-up. The one missing piece of sign-up is the SMS
  verification code (see Firebase below).
- **Guest (no-login)** — matches Android item-for-item: Android hides twelve drawer items from a guest and
  gates Freelancer Dashboard, the Workshop tab and the estimate consultation behind a login prompt; iOS
  hides the same twelve and gates the same three. Never walked end to end.
- **Design system** — one system. `AppTheme`'s colours resolve to `VendorTheme` (the shared system despite
  the name), so consumer screens share the palette and follow dark mode; every yellow bar in the app is
  `VendorTopBar`, which takes either a trailing icon or an arbitrary `@ViewBuilder`.

---

## 4. Firebase — current state and the one decision that matters

The owner created a Firebase project and supplied `GoogleService-Info.plist`.

> **The plist is for `thecontractor-b1d78`. Android's `google-services.json` is `thecontractor-uae`
> (sender 440409598739).** Firestore and FCM are per-project, so iOS chat reads and writes a different
> database than Android, and the backend's push credentials (uae) cannot deliver to iOS tokens minted by
> b1d78. **The owner chose to keep b1d78 and migrate Android later.** Anyone continuing should know iOS
> chat is isolated from Android chat until that migration happens.

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

**iOS matches the read side but does not create connections yet.** `ChatService` has no
`createConnection`; the iOS company cannot start a new thread. That is the next chat task — see below.

---

## 5. Pending, in the order worth doing

1. **Finish chat.** The build that would confirm `ChatService`/`InboxView` compile was still running when
   this file was written — **verify the build first.** Then:
   - add `createConnection(company:user:)` to `ChatService`, replicating
     `createUserConnectionOnFireStore()` exactly (field list above, `chat_uuid` a fresh UUID, created
     lazily on first send);
   - give the company an entry point, mirroring Android's: a "Message" action on the workshop-ad detail
     screen (`VendorWorkshopDetailView`), which is where `VendorWorkshopDetail` opens `VendorChat`;
   - drive both inboxes in the simulator. Two accounts are needed — company 706 and consumer 45 — so the
     honest test is: company starts a thread, consumer sees and answers it.
2. **SMS code on sign-up** (Firebase Phone Auth). Unaffected by the project mismatch. A simulator cannot
   receive an SMS, so add a test phone number in the Firebase console first, or it cannot be verified.
   The code step slots between `SignUpView`'s two existing steps and nothing else changes.
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
