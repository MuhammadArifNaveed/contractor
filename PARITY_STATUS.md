# iOS ⇄ Android parity — status

**Last audited: 2026-08-17.** One page for "what is replicated and what is left". The three working
documents keep the detail:

- [`COMPANY_SIDE_ROADMAP.md`](COMPANY_SIDE_ROADMAP.md) — company/vendor plan and design system
- [`USER_SIDE_ROADMAP.md`](USER_SIDE_ROADMAP.md) — consumer plan, endpoint mapping, per-feature notes
- [`IOS_VENDOR_PARITY_PROGRESS.md`](IOS_VENDOR_PARITY_PROGRESS.md) — the phase-by-phase working log

**Sources of truth.** `TheContractor-Android/app/src/main/java/com/thecontractor/RetrofitLibrary/RetrofitApi.java`
is authoritative for every endpoint path and part name — read the `@Part` annotation, never the Java
argument name. The activities and `res/layout/*.xml` are authoritative for behaviour. Presentation is
iOS-native and deliberately not a copy of Android's layouts.

---

## Where it stands

| Area | State |
|---|---|
| Firebase | **SDK in, chat built and driven, project mismatched.** Auth/Firestore/Messaging pods, plist registered, `FirebaseApp.configure()`, and the real FCM token now reaches the backend instead of the literal `"testtoken123"`. `firestore.rules` is written and ready to deploy (writes validated, deletes off, message text immutable) but **reads stay open** until the backend mints custom tokens — the iOS half of that is already done in `ChatAuthService`. `./scripts/firebase_preflight.sh` checks the file-level config in one command. See the blocked row. |
| Design system | **One system now.** `AppTheme`'s colours resolve to `VendorTheme`, so the consumer screens share the palette and follow dark mode, and **every** yellow bar in the app is `VendorTopBar` — fifteen were hand-rolled `HStack`s. |
| Company / vendor side | **Complete.** All 17 drawer items and the header's View Profile reach a real screen on a real endpoint, or say plainly that the feature is unavailable. |
| Consumer side | **Complete**, including the sign-up SMS code, which is built and driven. Every drawer item and every tab reaches a real screen. "Company Finder" now opens the keyword search on `Home/get_by_company_id` rather than duplicating the bottom bar's filter tab. |
| Guest (no-login) flow | **Matches Android's item-for-item, never walked end to end.** Android hides twelve drawer items from a guest (Inbox, Submit Enquiry, Enquiries, Request for Quotation, Quotations, Complaints, Estimations, Workshop, Contact Us, Logout, My Job Applies, Direct Hiring) and gates Freelancer Dashboard, the Workshop tab and the estimate consultation behind a login prompt. `GUEST_MENU` hides exactly those twelve and iOS gates the same three. Two items Android shows to guests were missing from both iOS drawers — Select Language and Documentation — and are now added. There is no anonymous company mode on either platform: a company either signs in or does not. |
| Fabricated endpoints | **0.** Every API path iOS calls is declared in Android's `RetrofitApi.java`. |
| Endpoint coverage | Android declares **126** endpoints, of which **121 are actually called** there (5 are dead in Android). iOS covers **113 of those 121**. The 8 remaining are *all* accounted for and none is portable work: 3 payment-gated, 2 backend-broken, 3 dead in Android via unused method overloads. Listed below. |
| Push | **Token, receive and tap routing all built.** `PushRouter` mirrors Android's `MyFirebaseMessagingService` across all ten actions, and iOS now subscribes to the `toAll` topic Android has always used. **Delivery is still blocked** — see the blocked row. |
| Localization | **The one large gap.** Android ships 264 Arabic strings and branches on language in 138 files, rendering `arabic_name` / `arabic_title` / `arabic_description` from the API. iOS has no `Localizable.strings`, no `.lproj` beyond `Base`, and renders no Arabic content field; the language picker saves a preference nothing reads. Not started — scope it deliberately. |
| Payments | **Deferred by decision.** The three card-payment endpoints are unimplemented and the screens say so plainly. The coupon paths — membership *and* the workshop add-on — are implemented and work. |

### Re-running the checks

- **`./scripts/firebase_preflight.sh`** — in the repo, not the scratchpad. Checks the four file-level
  Firebase items that each cost a round trip at least once: bundle id against the build, the phone-auth
  URL scheme against `GOOGLE_APP_ID` (absent, and `PhoneAuthProvider` calls `fatalError` outright), the
  rules file, and the plist being in Resources rather than Sources. All four pass today. It names the
  console-side items it *cannot* see rather than letting a clean run imply readiness.
- **`audit_urls.py`** — every API path iOS calls, against Android's declared list. Understands all
  three URL shapes in this codebase: `BASE_URL + "literal"`, `BASE_URL + EndPoints.constant`, and
  `"\(EndPoints.BASE_URL)Home/foo"`, plus fully hardcoded `https://…/rest/…` URLs. Exits non-zero on
  anything Android does not declare.
- **`parity.py`** — part names against Android's `@Part` names. This is the one that matters most: a
  path can be right while every field is silently ignored. Its one real flag —
  `addWorkshopQuotation` could not attach a document — is now fixed.

`audit_urls.py` and `parity.py` live in the session scratchpad and are wiped between sessions;
recreate them from the descriptions above. **Two traps when rewriting the path audit**, both of which
produced wrong answers before being caught:

1. Stripping `//` comments naively also truncates every hardcoded `https://…` URL, which makes a dozen
   implemented endpoints look missing. Only treat `//` as a comment when it is not preceded by `:`.
2. Android **overloads method names** — there are two `workshopAds` and two `workshopAdDetails`, each
   pair pointing at different paths. Matching on the method name alone marks a path as called when
   only its sibling is. Distinguish by argument count, or the audit will hide three dead endpoints
   among the live ones.

---

## What is replicated

### Company / vendor

| Android | iOS | Notes |
|---|---|---|
| `VendorLogin`, `VendorForgotPassword*`, `VendorNewPassword` | `CompanyLoginView`, `VendorForgotPassword*View` | Password reset sent `email` where Android sends `login_email` — fixed. |
| `VendorHome` | `VendorHomeView` | Counts grid + recent enquiries. |
| `VendorProfile` | `VendorProfileView` | |
| `VendorDashboardEnquiries`, `VendorParticularEnquiries`, `VendorEnquiryDetail` | `VendorEnquiriesView`, `VendorEnquiryDetailView` | |
| `VendorDashboardQuotations`, `VendorParticularQuotations`, `VendorQuotationDetail` | `VendorQuotationsView`, `VendorQuotationDetailView` | Quotation document upload included. |
| `VendorRating`, `VendorRatingDetail` | `VendorReviewsView` | List only; Android's per-review drill-down makes no API call, so nothing is lost. |
| `VendorPostWorkshop`, `VendorWorkshop`, `VendorAllWorkshopsAds`, `VendorWorkshopDetail`, `VendorInterestedWorkshops` | `VendorPostWorkshopView`, `VendorWorkshopView`, `VendorWorkshopAdsView`, `VendorWorkshopDetailView` | Workshop quotation add + lock/unlock included. |
| `VendorDashboardJobs`, `VendorJobListing`, `VendorPostJob`, `VendorJobDetail` | `VendorJobsView`, `VendorPostJobView`, `VendorJobDetailView` | Create and edit, with image picker. Backend spells it `vaccancies`. |
| `VendorApplicants`, `VendorApplicantDetail` | `VendorJobApplicantsView`, `VendorApplicantDetailView` | |
| `VendorDirectHiring`, `VendorDirectHiringDetail` | `VendorDirectHiringView` | Off the jobs dashboard, as on Android. Despite the endpoint name it is not accept/reject: Android's dialog sets one of five statuses — Submitted, Viewed, Shortlisted, `interviewed` (its own lower case), Selected — sent verbatim. |
| `VendorFreelancersList`, `VendorHiredFreelancers`, `VendorHiredFreelancersSummary`, `VendorDashboardFreelancer` | `VendorFreelancersView`, `VendorHireFreelancerView`, `FreelanceDashboardView` | **Multi-select hiring built** — tick several, book each through the same sheet, post one `freelancer_data` array with per-freelancer detail. Browse used to read `freelancers`, but the key is `freelancers_list`, so the list was always empty and hiring was unreachable; fixed. |
| `VendorMembership`, `VendorMyMembership`, `VendorMyMembershipDetail` | `VendorSubscriptionView`, `VendorMyMembershipDetailView` | Coupon purchase works; **card payment is not wired** — see *Blocked*. |
| `VendorChat`, `VendorFreelancerChat` | "Coming soon" screen | Firebase Firestore — see *Blocked*. |

### Consumer

| Android | iOS | Notes |
|---|---|---|
| `Login` | `LoginViewController` (storyboard) | Correct on `Account/user_login`. The app sends the phone as `+971` + 10 digits. |
| `ForgotPassword`, `NewPassword` | `ForgetPasswordViewController`, `NewPasswordViewController` | `Account/phone_check` → `Account/update_password`. |
| `Register`, `VerifyNumber` | `SignUpView` | Two steps: number checked with `Account/phone_check`, then details to `Account/user_register`, which signs the new account in from its own response. Reached from "New here? Create an account" on the login screen — the storyboard's own button for this ships `hidden="YES"`, so a new one is laid out with the other programmatic buttons. Android's SMS code step is not replicated; see *What is left*. |
| `HomeFragment` | `HomeView` | |
| `Search`, `SearchResult`, `Companies`, `CompanyFinder` | `SearchCompaniesView`, `SearchResultsView`, `CompaniesListView` | |
| `CompanyDetails` + fragments | `CompanyDetailView` | Detail, opening hours, sub-categories, reviews read from `Home/company_detail`. |
| `TwentyFourSeven` | `TwentyFourSevenCompaniesView` | |
| `Cart`, `OrderContactInfo` | `CartView` + `ConsumerCartStore` | Basket is local state, as on Android; submitted through `Home/send_enquiries`. Add from the company rows and the detail screen. |
| `Enquiries`, `EnquiryDetail` | `EnquiriesListView` | List works. **Detail is blocked by a backend bug.** |
| `Quotations`, `QuotationsDetails`, `SubmitQuotations` | `QuotationsListView`, `QuotationDetailView`, `SubmitQuotationView` | Price and currency arrive as siblings of `quotation`, not inside it. |
| `Complaints`, `ComplaintDetail` | `ComplaintsListView`, `ComplaintDetailView` | Submit part is `complaint`, not `text` — fixed. |
| `EstimationFragment`, `Estimations`, `EstimationsDetail` | `EstimationView`, `EstimationRequestsView`, `EstimationRequestDetailView` | Calculator, consultation request, paged list, detail. `look_id` is the top-level category and `cate_id` the sub-category. |
| `WorkshopFragment` (post an ad) | `WorkshopPostView` | Now on `workshop/workshop_filter_data` + `workshop/submit_workshop_ad`. |
| `WorkShopAds` (type=user), `WorkshopAdDetail` | `WorkshopAdsView` → `VendorWorkshopDetailView` | Own ads, Open Bid / Close Bid, paged, with the quotations received and an enable/disable action (`workshop/toggle_workshop_status`). One Android activity serves both sides, so this is the company list given a consumer identity — the user's own id goes over the wire as `vendor_id`. |
| `AvailableJobs`, `AvailableJobsDetails`, `SearchJobsAndApplicant`, `UserJobApplied` | `AvailableJobsView`, `JobDetailView`, `SearchJobsView`, `MyJobApplicationsView` | All three job screens were wrong in path, parts **and** response key. |
| `UserDirectHiring` | `DirectHiringView` | |
| `Freelancers`, `SearchFreelancer`, `FreelancerCheckout`, `UserDashboardFreelancer` | `FreelancersView`, `FreelancerCheckoutView`, `FreelanceDashboardView` | |
| `UpdateProfile`'s freelancer checkbox and form entry | Edit Profile → availability switch + "Register as a freelancer" | `freelancing/update_user_freelance_status` (flag part is camelCase `isChecked`) and `freelancing/register_user_freelancer`, which despite its name is a **read** that says whether a record exists. |
| `UpdateProfile`, `ChangePassword`, `ProfileFragment` | `EditProfileView`, `ChangePasswordView`, `UserProfileView` | `Account/change_password` is keyed on `user_email`, not `user_id` — fixed. Freelancer availability and the freelancer profile now live here, as on Android. |
| `AdvertiseCompany` | `AdvertiseCompanyView` | |
| `SelectLanguage`, `MapsActivity`, `WebViewActivity` | `LanguageSelectionView`, `MapView`, `WebContentView` | About / Privacy / Terms / Guide / Contact / Advertisement are web pages, as on Android. |
| `Chat`, `ChatConnection`, `VendorChat`, `VendorChatConnection` | `InboxView` + `ChatThreadView` on `ChatService` | Firestore, live listeners, both roles from one screen. **iOS cannot start a new conversation yet** — on Android only the company creates the `user_connections` document, lazily on first send from the workshop-ad detail screen. |

---

## What is left

### 1. The SMS code on sign-up

`SignUpView` is now three steps, matching Android: the number (`Account/phone_check`), the SMS code
(Firebase Phone Auth, in `PhoneAuthService`), then the account (`Account/user_register`). The code step
replicates `VerifyNumber`: `verifyPhoneNumber` → 60-second countdown with the resend button hidden behind
it → `credential(withVerificationID:verificationCode:)` → `signIn(with:)`, and the details form opens only
once that succeeds. Android's `onVerificationCompleted` auto-fill has no counterpart, because iOS cannot
read the SMS itself.

**It compiles and has never run.** Firebase Authentication is not enabled on `contractor-e1442` —
`identitytoolkit.googleapis.com/v1/projects` answers `CONFIGURATION_NOT_FOUND`, meaning the product has
never been initialised for the project, the same way Firestore had not been. Until that is done:

1. Firebase console → **Authentication** → Get started (this creates the config).
2. Sign-in method → enable **Phone**.
3. Phone → **Phone numbers for testing** → add a number and a fixed code.

Step 3 is not optional for a simulator. Real phone verification needs an APNs key uploaded to the Firebase
project so Firebase can silently push a token to prove the app is genuine; a simulator receives no push,
and the reCAPTCHA fallback needs a `REVERSED_CLIENT_ID` URL scheme that this plist does not carry. A
console test number bypasses all of it. Any of those failures surface as "Verification is not set up for
this app yet" rather than blaming the user's number.

Until the console side is done, **`Account/user_register` is still reachable with an unverified number**
by calling it directly — the gate is client-side on both platforms, so this closes the app's door, not
the endpoint's.

### 2. Android endpoints iOS does not call (8, all accounted for)

Re-audited 2026-08-17 by diffing every path Android's `RetrofitApi` declares **and calls** against every
path in the iOS sources. Android declares 126; 121 are actually called there; iOS covers **113** of those
121. There are **no fabricated endpoints** — every URL iOS calls is one Android declares.

None of the 8 is portable work:

| Endpoint | Why not |
|---|---|
| `vendor/buy_membership_online` | Card payment. Gateway deferred by decision; the screen says "Card payment not available yet" rather than offering a button that fails. |
| `vendor/buy_workshop_membership_online` | Card payment, same. Its **coupon** sibling is implemented. |
| `Home/quotation_fee_paid` | Card payment **and** backend-broken (`Undefined variable $quotation_id`). Deliberately not wired — see the issues table. |
| `vendor/membership_details` | Backend-broken (throws on null). iOS does not need it: every field it would return is already on the `vendor/my_memberships` row, which is what `VendorMyMembershipDetailView` reads. |
| `Vendor/workshop_ad_detail` | Backend-broken (500s for every id). Breaks Android's own `VendorWorkshopDetail` too. |
| `Home/recent_workshop_ads` | **Dead in Android.** The unused half of the overloaded `workshopAds` pair — only the 5-argument `workshop/workshops` version is ever called. |
| `Home/workshop_ad_detail` | **Dead in Android.** The unused half of the overloaded `workshopAdDetails` pair; the live calls go to `workshop/get_workshop_details`. |
| `Vendor/workshop_ads` | **Dead in Android.** Belongs to the `VendorWorkshop` activity, which is declared in the manifest and launched from nowhere — the only one of Android's 90 activities that is unreachable. |

**Also dead in Android, so never counted as gaps:** `Account/user_register`, `Home/category_wise_companies`,
`Home/sub_category_wise_companies`, `Home/submit_workshop_ad`, `Home/update_workshop_ad_status`.

Closed since the last revision of this section: freelancer order chat (all four), `Home/get_by_company_id`,
`jobs/search_job_title`, `vendor/buy_workshop_membership_by_coupon`, `Account/get_user_details_by_id`,
both `send_message_notification` paths.

### 3. Blocked on something outside the code

| Blocker | Affects | What is needed |
|---|---|---|
| ~~**Firestore not provisioned**~~ | ~~All of chat~~ | **Resolved.** iOS moved to a new project, `contractor-e1442`, with Firestore created and rules `allow read, write: if true`. Chat is verified end to end on it. The open rules are a standing security debt — the app never signs into Firebase Auth, so there is no identity for stricter rules to test, and the API key ships in the binary. |
| **Firebase is in a different project than Android** | Cross-platform chat visibility, and push delivery | iOS is on `contractor-e1442`, Android on `thecontractor-uae`. Firestore and FCM are per-project, so the two apps' conversations are invisible to each other and the backend (which pushes from `uae`) cannot deliver to iOS tokens — the `send_message_notification` calls succeed, only delivery is dead. **Not fixable from this side:** nobody here has access to the `uae` account, so converging the two needs whoever owns it. |
| ~~**Firebase Authentication not enabled**~~ | ~~The SMS code on sign-up~~ | **Resolved and verified end to end.** Auth initialised on `contractor-e1442`, Phone provider enabled, dev + production APNs keys uploaded, and an SMS region policy allowing **AE** — that last one is easy to miss: a new project refuses every UAE number with `OPERATION_NOT_ALLOWED : SMS unable to be sent until this region enabled`. Driven on the simulator with `+971500000000` / `123456`: code step, code accepted, details form opened with the verified number locked in. A **10 SMS/day quota** applies until a billing account is attached. |
| **No payment gateway decision** | Membership card purchase (`vendor/buy_membership_online` and the two workshop-membership calls) | Coupon purchase already works. |
| **Backend bug** | Consumer enquiry detail | `Home/recent_enquiries` returns HTML: `mysqli_sql_exception: Unknown column 't2.company_whatsapp_phone' in 'field list'`. Affects Android too. The list works; the drill-down waits on the column fix. |
| **Product question** | Consumer reviews | Android has no `submit_review` or `get_company_reviews` endpoint at all. The unreachable iOS screens for both were deleted. Company ratings still show via `Home/company_detail`. If reviews are meant to exist, the backend needs endpoints first. |

### 4. Everything else remaining, ranked

**The only large item left is localization** (see the table at the top). Everything below it is small.

**Worth doing next**

1. **Two built screens have never been looked at**, both on the consumer side, which is why they are
   still open: **Company Finder** (drawer → Company Finder) and the **job-title suggestion chips**
   (Available Jobs → search). Endpoints verified live, code compiles; they need a consumer login to drive.
2. **The freelancer form's prefill is unverified on screen.** Written against the live record and it
   compiles, but the filled form has not been seen. To confirm: sign in as the QA user, Profile →
   Profile Settings → Freelancer profile, and check hourly rate 5, two skills, category `carpentor`,
   Dubai / Al Mamzar, 10:00–18:00, the bank block, and the addresses.
3. **`AppTheme.Fonts` hands out fixed point sizes**, so consumer screens ignore the system text size.
   All 222 call sites funnel through six static helpers in `AppTheme.swift`, so it is one file to change
   — but it shifts type across ~34 screens and wants a visual pass, which needs the consumer login too.
   `VendorTheme.Text` is already relative and is the model to copy.
4. **`EditProfileView` still sends none of Android's three optional file parts.** The four text fields it
   used to blank are fixed (see below); the file parts remain unbuilt.

**Closed since the last revision** — do not re-open these:

- ~~"available for job" saves nowhere~~ — **not a gap.** `Account/update_user_profile` has no part for
  `is_available_for_job`; Android prefills the checkbox and never saves it either. iOS matches.
- ~~`EditProfile` sends `address`/`city`/`country`/`job_category` as empty strings~~ — **was a data-loss
  bug**, not a thin form: the backend wrote the blanks over real values, so saving a name change erased
  the user's address and job category. Now sent properly, prefilled from the stored record, with the two
  pickers backed by `Home/get_search` instead of hardcoded invented arrays. Android's asymmetry is kept:
  `city` is the city **id**, `job_category` is the category **title**.
- ~~`addWorkshopQuotation` cannot attach a document~~ — built, with a `.fileImporter` and a real MIME type.
- ~~Freelancer hire has no multi-select or pick-up addresses~~ — both built. Pick-up addresses turned out
  to belong to the freelancer's *profile*, not the hire flow.
- ~~`Image("splash_logo")` / `Image("topicon")` missing~~ — no longer referenced anywhere.

**Cleanup**

- Dead storyboard scenes: `EstimationViewController` and `EsstimationVC` in `Home.storyboard`, plus the
  scenes behind other deleted controllers. Nothing instantiates them.
- `VendorSettingsView` and `VendorReportsView` are unreachable leftovers.
- `VendorWorkshopAdsList` and `VendorWorkshopDetailView` are shared with the consumer side now, so the
  `Vendor` prefix on their names misleads. Worth renaming when something else touches them.
- `project.pbxproj` has ~40 files listed twice in Sources; Xcode warns "Skipping duplicate build file"
  on every build. Harmless, noisy, and it hides real warnings.

### 5. Backend issues to report

Found while porting; all affect Android too unless noted.

| Where | Problem |
|---|---|
| `Home/recent_enquiries` | Returns HTML, not JSON: `mysqli_sql_exception: Unknown column 't2.company_whatsapp_phone' in 'field list'`. Blocks the consumer enquiry drill-down on both platforms. |
| `jobs/update_direct_hiring_status` | An unknown `hiring_id` does not 404 — it crashes with `Attempt to read property "applicant_uuid" on null` at `rest/Jobs.php:1046`. |
| `jobs/view_direct_hirings` | No `total_page` in the response, so the list cannot page. Android's load-more is commented out for the same reason. |
| `freelancing/update_user_freelance_status` | Ignores the `isChecked` part it declares — the endpoint decides the new state itself and reports it as `available`. Sending `true` on an account it considers ineligible returns `available: false`. |
| Hiring status case | Written mixed-case (`Shortlisted`), stored lower-case (`shortlisted`). Clients have to compare case-insensitively. |
| `Vendor/workshop_ad_detail` | 500s for every id: `Call to undefined method Workshop_model::get_workshop_ad_detail_by_id()` at `Vendor.php:2013`. This is the endpoint behind Android's `VendorWorkshopDetail`, so **Android's chat entry point is unreachable too** — the screen that hosts it never loads. |
| `show_chat` on workshop ads | `"0"` on every ad in the QA data, and no declared endpoint sets it (`workshop/submit_workshop_ad` does not take the flag). Android gates its chat entry on `show_chat == "1"`, so on Android that entry can never appear. Also absent from `workshop/get_workshop_details`, though both list endpoints return it. **iOS does not gate on it** — doing so would have shipped the feature dead. If the flag is ever meant to mean something, the backend has to start setting it, and `canMessageOwner` is where iOS would start reading it again. |
| `Account/user_register` | Accepts any phone number with no proof of ownership; the SMS gate is client-side only. |
| Reviews | No `submit_review` or `get_company_reviews` endpoint exists at all. |
| `Home/quotation_fee_paid` | PHP warning then failure: `Undefined variable $quotation_id` at `rest/Home.php:1960`. Android calls this after its payment gateway returns, so **Android's quotation fee payment cannot be recording anything either**. iOS does not call it — the gateway is deferred — so nothing is wired to a broken endpoint. |
| `vendor/membership_details` | Uncaught exception: `Attempt to assign property "workshop" on null` at `models/Membership_model.php:236`, via `Vendor.php:1945`. Breaks Android's `VendorMyMembershipDetail`. iOS does not need it — every field it would return is already in the `vendor/my_memberships` row, which is what `VendorMyMembershipDetailView` reads. |
| `Home/get_by_company_id` | **Leaks credentials.** Every row includes `login_password` (an MD5 hash), `otp`, `verified_token`, `password_update_token`, `app_password_update_pin`, `firebase_token` and `web_firebase_token` — for all 238 companies, on an endpoint that needs no authentication. The password hashes alone make this the most serious item on this list. Both apps ignore the fields, so the fix is purely backend: stop selecting them. |
| `freelancing/fetch_order_chats` | An order with no messages answers `{"status":false,"error":true,"message":"No chats found"}` with **no `sending` key**, so a client cannot learn from this response whether the order is still open. iOS seeds that from the list row's `expired` flag instead (see the order-chat fix below); Android reads `sending` and would leave a live composer on an expired order for the same reason. |

---

## Verification ledger

Honest account of how far each claim is tested.

| Level | What |
|---|---|
| **Driven in the simulator** | The design-system pass, in light *and* dark mode — the palette, cards, text and accent buttons all follow the system now, which is how the empty-state action's white-on-yellow label was caught. Edit Profile's freelancer availability switch and freelancer-profile form (real account data, no demo values); vendor direct hiring — list with real rows and status chips, detail, and the five-value picker; the consumer's own workshop ads — list with real rows on both bid tabs, detail, and the enable/disable action flipped to Disabled and back to Enabled so the account's data is unchanged; consumer sign-up end to end — the taken-number path shows the backend's own "Phone number is already exist.", and a new account was created and signed in (see the note below); company login and dashboard; both app bars; the whole estimate flow — categories load, 1200 sqft of Shell & Core office gives AED 198,000 at 165/sqft, the signed-out consultation gate reaches the login screen, the request list shows the account's real request, the detail screen fetches and renders it, and the consultation form prefills from the stored user. Consumer login with the tester account. |
| **Endpoint verified live (curl), UI compiled but not driven** | The two write actions listed under *Not exercised* above, and every screen not named in the row above. Each endpoint was called against the live backend and each parser written against the real key names — but a screen that has only been compiled can still be wrong in ways only looking at it reveals, which is exactly what the last visual pass showed: four defects on two screens whose endpoints were all correct. |
| **Driven in the simulator** | **Sign-out and the login prompt, on the hierarchy where they used to fail.** Logging out with the drawer installed as the window's root now reaches the login screen instead of silently doing nothing; Skip then pushes the drawer back onto the navigation controller that fix builds, and the drawer's "Login or Create Account" opens the login screen too. See the fix note below. Not re-tested through a *company* sign-out specifically, which needs the company PIN again — but that is the same `showLoginScreen()` call on the same hierarchy. |
| **Driven in the simulator, both accounts, documents verified** | **Chat, end to end.** Company 706 opened workshop ad 109, pressed Message (owner's `uuid`/`username`/`name`/`surname` resolved live through `Account/get_user_details_by_id`), and sent — `createConnection` wrote the connection *on send, not on open*, then the message. Consumer 45 signed in, saw the thread in the inbox, opened it and replied. Both documents were then read back out of Firestore: `user_connections` has all **15** of Android's fields and no others, `chat` has all **9**; every value a string; `created_at = 2026-11-08` confirms the swapped `yyyy-dd-MM` for 11 August; `country_time` is an hour behind in Dubai; `sent_by` is `company` then `user`; `last_message`/`message_time` follow the newest message; and `user_is_view` flipped to `1` on the company's message when the consumer opened the thread, which verifies `markThreadViewed`. Bubble side and counterpart name flip correctly per role. A later second Message tap on the same ad exercised **`findConnection`'s reuse branch**: it reopened the existing thread with both messages rather than starting an empty one, the collection still holds exactly **one** connection with the same document id and `chat_uuid`, and `company_is_view` flipped to `1` on the consumer's message — each side's own messages left untouched, as `markThreadViewed` skips them. With the `show_chat` gate removed, the Message button is confirmed visible on the ad. |
| **Driven in the simulator (2026-08-17, company session)** | **Freelancer order chat, end to end** — Placed lists order #9 badged Expired, Received lists #8, the thread opens on its empty state, and the composer is replaced by "Order Expired / Rejected". Driving it found the defect that `fetch_order_chats` omits `sending` entirely for an empty thread, so an expired order had a live composer. **Push tap routing** — `simctl push` with `type=vendor, action=vendor_membership` opened My Membership on the real ELITE record; `action=user_inbox` with an unknown `chatUUID` exercised the new Firestore lookup and fell back to the company inbox showing the live thread. **Membership detail** — loads, and the new workshop add-on button correctly stays hidden because vendor 706 already owns the add-on (negative case). **Workshop quotation sheet** — the attachment row renders and the Files picker opens. **Freelancer browse and multi-select** — the list populates with the freelancer the API actually returns (it was reading the wrong key and had always shown "No freelancers found"), the checkbox and selection bar behave, and Book opens the per-freelancer booking sheet. |
| **Deliberately not done** | Three actions were left unconfirmed because completing them writes to production: submitting a workshop quotation (posts a real bid and consumes one of 11), confirming a freelancer booking (creates a real hiring record), and redeeming a coupon. In each case everything up to the final button is verified. |
| **Never done** | Apart from login and sign-up, no form has been submitted by hand. Nothing has been tested on a physical device, in Arabic, or in dark mode. The consumer side has not been driven since the Edit Profile and freelancer-hire fixes — both are compiled and reasoned against live responses, neither has been seen on screen. |

`attach` on the simulator MCP tool fails on this Mac, but `screenshot`, `tap`, `text` and `swipe` all
work headlessly against the booted device — an earlier session's conclusion that no interactive
verification was possible was wrong. Coordinates are device points; screenshots come back larger, so
scale by `points_width / image_width`. A stored company session survives `simctl uninstall` because it
lives in the keychain: `xcrun simctl keychain <udid> reset`.

---

## Corrections to earlier claims in these documents

Recorded because the mistakes were in the checking, not the code, and the same holes would recur.

1. **"0 fabricated endpoints" was wrong when first stated.** The scan matched `BASE_URL + "…"` and
   absolute URLs containing `/api/`, so it missed every hardcoded `https://…/rest/…` call and the
   `"\(EndPoints.BASE_URL)Home/foo"` interpolation shape. Three genuinely fabricated calls were hiding
   behind that: `Home/get_chats` (consumer Inbox), `Home/workshop_filter_api` and
   `Home/post_work_shop_ad_new_api` (consumer workshop ad — both confirmed 404). All three are now
   gone, and `audit_urls.py` understands all three shapes.
2. **The 24/7 path had the wrong case.** iOS used `Home/twentyfourcompanies`; Android declares
   `Home/twentyFourCompanies`. This server happens to route both, but paths are case-sensitive in
   general and Android is the spec.
3. **The consumer workshop filter parse could never have worked**, even against the right endpoint: it
   read the type and sector rows off a `name` key, and the real rows are `{value, title}`.
4. **"Reviews awaiting a product decision" was overstated as a blocker.** The screens were unreachable,
   so nothing was waiting on the answer; they are deleted.
5. **"Consumer workshop-ad browsing" was described as the largest remaining feature on the strength of
   endpoints Android never calls.** `RetrofitApi` declares two `workshopAds` and two `workshopAdDetails`
   overloads; the unused-endpoint scan could not tell them apart, so four dead `Home/...workshop_ad...`
   paths looked like missing features. The real pair is `workshop/workshops` +
   `workshop/get_workshop_details`.
6. **Two features were reported as done while only contract-verified.** Driving them afterwards found
   four defects — a wrong response key, demo data in every field of a live form, a blank email field
   that discarded input, and a double-posted notification that broke the login entry point. Endpoint
   correctness is not screen correctness; the ledger below now separates the two.

---

## Test data created while verifying

Verifying sign-up meant creating one account on the QA backend, since there is no other way to know
the flow works. Delete it whenever you like:

- user id **46**, username `iostest01`, `+971509998877`, `iostest01@example.com`, PIN `3187`.

Nothing else in this work has written to the backend. In particular the estimate consultation form was
filled in but never submitted.
