# iOS ⇄ Android parity — status

One page for "what is replicated and what is left". The three working documents keep the detail:

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
| Firebase | **SDK in, chat built, project mismatched.** Auth/Firestore/Messaging pods, plist registered, `FirebaseApp.configure()`, and the real FCM token now reaches the backend instead of the literal `"testtoken123"`. See the blocked row. |
| Design system | **One system now.** `AppTheme`'s colours resolve to `VendorTheme`, so the consumer screens share the palette and follow dark mode, and **every** yellow bar in the app is `VendorTopBar` — fifteen were hand-rolled `HStack`s. |
| Company / vendor side | **Complete.** All 17 drawer items and the header's View Profile reach a real screen on a real endpoint, or say plainly that the feature is unavailable. |
| Consumer side | **Complete.** Every drawer item and every tab reaches a real screen, or an honest "not available yet" (Inbox). Sign-up works; the SMS code step Android has is the one piece missing, see *What is left*. |
| Guest (no-login) flow | **Matches Android's item-for-item, never walked end to end.** Android hides twelve drawer items from a guest (Inbox, Submit Enquiry, Enquiries, Request for Quotation, Quotations, Complaints, Estimations, Workshop, Contact Us, Logout, My Job Applies, Direct Hiring) and gates Freelancer Dashboard, the Workshop tab and the estimate consultation behind a login prompt. `GUEST_MENU` hides exactly those twelve and iOS gates the same three. Two items Android shows to guests were missing from both iOS drawers — Select Language and Documentation — and are now added. There is no anonymous company mode on either platform: a company either signs in or does not. |
| Fabricated endpoints | **0.** Every API path iOS calls is declared in Android's `RetrofitApi.java`. |
| Endpoint coverage | iOS calls **103 of Android's 124** endpoints. Of the 21 it does not, **6 are dead in Android too** — declared in `RetrofitApi` and never called — so 15 are real gaps. Listed below. |

### Re-running the checks

Two scripts, both in the session scratchpad, both worth running after any change in this area:

- **`audit_urls.py`** — every API path iOS calls, against Android's declared list. It understands all
  three URL shapes in this codebase: `BASE_URL + "literal"`, `BASE_URL + EndPoints.constant`, and
  `"\(EndPoints.BASE_URL)Home/foo"`, plus fully hardcoded `https://…/rest/…` URLs. Exits non-zero on
  anything Android does not declare.
- **`parity.py`** — part names against Android's `@Part` names. This is the one that matters most: a
  path can be right while every field is silently ignored, which is exactly what was happening on
  company registration and password reset. It currently reports four flags, all triaged (three false
  positives, one real: `addWorkshopQuotation` cannot attach a document yet).

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
| `VendorRating`, `VendorRatingDetail` | `VendorReviewsView` | List only; Android's per-review drill-down is not built. |
| `VendorPostWorkshop`, `VendorWorkshop`, `VendorAllWorkshopsAds`, `VendorWorkshopDetail`, `VendorInterestedWorkshops` | `VendorPostWorkshopView`, `VendorWorkshopView`, `VendorWorkshopAdsView`, `VendorWorkshopDetailView` | Workshop quotation add + lock/unlock included. |
| `VendorDashboardJobs`, `VendorJobListing`, `VendorPostJob`, `VendorJobDetail` | `VendorJobsView`, `VendorPostJobView`, `VendorJobDetailView` | Create and edit, with image picker. Backend spells it `vaccancies`. |
| `VendorApplicants`, `VendorApplicantDetail` | `VendorJobApplicantsView`, `VendorApplicantDetailView` | |
| `VendorDirectHiring`, `VendorDirectHiringDetail` | `VendorDirectHiringView` | Off the jobs dashboard, as on Android. Despite the endpoint name it is not accept/reject: Android's dialog sets one of five statuses — Submitted, Viewed, Shortlisted, `interviewed` (its own lower case), Selected — sent verbatim. |
| `VendorFreelancersList`, `VendorHiredFreelancers`, `VendorHiredFreelancersSummary`, `VendorDashboardFreelancer` | `VendorFreelancersView`, `VendorHireFreelancerView`, `FreelanceDashboardView` | Hire call works; multi-select + pick-up addresses are Android extras not built. |
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

### 2. Android endpoints iOS does not call (21, of which 6 are dead in Android too)

**Dead on both sides — declared but never called by Android either.** Nothing to port; they are listed
so nobody mistakes them for missing features:

`Home/recent_workshop_ads`, `Home/workshop_ad_detail`, `Home/submit_workshop_ad`,
`Home/update_workshop_ad_status`, `Home/category_wise_companies`, `Home/sub_category_wise_companies`.

The first four are the reason "consumer workshop-ad browsing" looked like the largest remaining
feature: Android's `RetrofitApi` declares two `workshopAds` overloads and two `workshopAdDetails`
overloads, and the live activities call the `workshop/...` ones, not these. The consumer browse list is
built on `workshop/workshops` + `workshop/get_workshop_details`, which is what actually shipped.

**The 15 real gaps**, grouped:

| Group | Endpoints | Comment |
|---|---|---|
| ~~Session~~ | ~~`Account/get_user_details_by_id`~~ | **Now called.** Chat needs the workshop ad owner's `uuid` and it is the only live endpoint that returns one. |
| Vendor workshop ads (capital-V variants) | `Vendor/workshop_ads`, `Vendor/workshop_ad_detail` | A separate vendor-side ad list; the `workshop/...` pair covers what both drawers open. **`Vendor/workshop_ad_detail` is broken on the backend** and cannot be ported — see the issues table below. |
| Freelancer order chat | `freelancing/fetch_order_chats`, `freelancing/order_placed_chats`, `freelancing/order_recieved_chats`, `freelancing/send_message` | Chat — same Firebase blocker. |
| Memberships | `vendor/membership_details`, `vendor/buy_workshop_membership_online`, `vendor/buy_workshop_membership_by_coupon` | See *Blocked*. |
| ~~Push notifications~~ | ~~`Home/send_message_notification`, `vendor/send_message_notification`~~ | **Now called**, one per side, fire-and-forget from `ChatService.send` exactly where Android fires them. Both probed live (with deliberately bogus ids, so nothing was pushed to a real account) and both answer `{"message":"error","error":false}`. Note the part is `meesage`, and the consumer call's `company_id` part actually carries the company's *serial number*. |
| Misc | `Home/quotation_fee_paid`, `Home/get_by_company_id`, `jobs/search_job_title` | Quotation fee payment; company lookup by id; job-title autocomplete. |

### 3. Blocked on something outside the code

| Blocker | Affects | What is needed |
|---|---|---|
| ~~**Firestore not provisioned**~~ | ~~All of chat~~ | **Resolved.** iOS moved to a new project, `contractor-e1442`, with Firestore created and rules `allow read, write: if true`. Chat is verified end to end on it. The open rules are a standing security debt — the app never signs into Firebase Auth, so there is no identity for stricter rules to test, and the API key ships in the binary. |
| **Firebase is in a different project than Android** | Cross-platform chat visibility, and push delivery | iOS is on `contractor-e1442`, Android on `thecontractor-uae`. Firestore and FCM are per-project, so the two apps' conversations are invisible to each other and the backend (which pushes from `uae`) cannot deliver to iOS tokens — the `send_message_notification` calls succeed, only delivery is dead. **Not fixable from this side:** nobody here has access to the `uae` account, so converging the two needs whoever owns it. |
| **Firebase Authentication is not enabled** | The SMS code on sign-up | Built and compiling, never executed: `identitytoolkit.googleapis.com` answers `CONFIGURATION_NOT_FOUND` for `contractor-e1442`, so Auth has never been initialised. Console → Authentication → Get started, enable **Phone**, then add a **test phone number**, which a simulator needs because it cannot receive an SMS and has no APNs token to prove the app with. |
| **No payment gateway decision** | Membership card purchase (`vendor/buy_membership_online` and the two workshop-membership calls) | Coupon purchase already works. |
| **Backend bug** | Consumer enquiry detail | `Home/recent_enquiries` returns HTML: `mysqli_sql_exception: Unknown column 't2.company_whatsapp_phone' in 'field list'`. Affects Android too. The list works; the drill-down waits on the column fix. |
| **Product question** | Consumer reviews | Android has no `submit_review` or `get_company_reviews` endpoint at all. The unreachable iOS screens for both were deleted. Company ratings still show via `Home/company_detail`. If reviews are meant to exist, the backend needs endpoints first. |

### 4. Everything else remaining, ranked

Nothing below blocks a normal user; they are ordered by what they cost.

**Worth doing next**

1. **The freelancer form's prefill is unverified on screen.** The mapping was written against the live
   record (every field shape printed from the real response), and it compiles, but the filled form has
   not been looked at. What would confirm it: sign in as the QA user, Profile → Profile Settings →
   Freelancer profile, and check hourly rate 5, two skills, category `carpentor`, Dubai / Al Mamzar,
   10:00–18:00, the bank block, and four addresses.
3. **Edit Profile's "available for job" checkbox is still a local flag** that saves nowhere. Android
   drives it through its own call; the freelancer switch beside it is now live, which makes the dead one
   more obvious.
4. **`EditProfileView` sends `address`, `city`, `country` and `job_category` as empty strings** because
   the form does not collect them, and none of Android's three optional file parts. The call is correct;
   the form is thinner than Android's.
5. **`addWorkshopQuotation` cannot attach a document**; Android can.
6. **Freelancer hire flow has no multi-select or pick-up addresses** — both are Android extras on a hire
   call that already works.

**Cleanup**

- Dead storyboard scenes: `EstimationViewController` and `EsstimationVC` in `Home.storyboard`, plus the
  scenes behind other deleted controllers. Nothing instantiates them.
- `VendorSettingsView` and `VendorReportsView` are unreachable leftovers.
- `VendorWorkshopAdsList` and `VendorWorkshopDetailView` are shared with the consumer side now, so the
  `Vendor` prefix on their names misleads. Worth renaming when something else touches them.
- `Image("splash_logo")` and `Image("topicon")` are referenced in six places; neither asset exists.
- The container's background behind a drawer screen is a fixed `F4F4F6`, so a thin light strip shows
  under the content in dark mode. UIKit side, one line in `MainContainerViewController`.
- Company Details' bar was converted last, using `VendorTopBar`'s new trailing view-builder, and has not
  been looked at on a device — the Add-to-enquiry pill's fit inside the shared bar is unverified.
- `AppTheme.Fonts` still hands out fixed point sizes (`semibold(16)`) rather than the semantic scale, so
  consumer screens do not scale with the system text size the way the vendor ones do.
- `parity.py`, the payload audit, lives only in a session scratchpad and gets wiped. It belongs in the
  repo next to a copy of `audit_urls.py`.

**Not exercised**

- No direct-hire status has been set on a real row: `hiring_status` starts empty and the API offers no way
  back to empty, so setting one on the QA data would not be reversible. The picker and the payload are
  verified; the write is not.
- The consultation request on the estimate flow has never been submitted, for the same reason.

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

---

## Verification ledger

Honest account of how far each claim is tested.

| Level | What |
|---|---|
| **Driven in the simulator** | The design-system pass, in light *and* dark mode — the palette, cards, text and accent buttons all follow the system now, which is how the empty-state action's white-on-yellow label was caught. Edit Profile's freelancer availability switch and freelancer-profile form (real account data, no demo values); vendor direct hiring — list with real rows and status chips, detail, and the five-value picker; the consumer's own workshop ads — list with real rows on both bid tabs, detail, and the enable/disable action flipped to Disabled and back to Enabled so the account's data is unchanged; consumer sign-up end to end — the taken-number path shows the backend's own "Phone number is already exist.", and a new account was created and signed in (see the note below); company login and dashboard; both app bars; the whole estimate flow — categories load, 1200 sqft of Shell & Core office gives AED 198,000 at 165/sqft, the signed-out consultation gate reaches the login screen, the request list shows the account's real request, the detail screen fetches and renders it, and the consultation form prefills from the stored user. Consumer login with the tester account. |
| **Endpoint verified live (curl), UI compiled but not driven** | The two write actions listed under *Not exercised* above, and every screen not named in the row above. Each endpoint was called against the live backend and each parser written against the real key names — but a screen that has only been compiled can still be wrong in ways only looking at it reveals, which is exactly what the last visual pass showed: four defects on two screens whose endpoints were all correct. |
| **Driven in the simulator** | **Sign-out and the login prompt, on the hierarchy where they used to fail.** Logging out with the drawer installed as the window's root now reaches the login screen instead of silently doing nothing; Skip then pushes the drawer back onto the navigation controller that fix builds, and the drawer's "Login or Create Account" opens the login screen too. See the fix note below. Not re-tested through a *company* sign-out specifically, which needs the company PIN again — but that is the same `showLoginScreen()` call on the same hierarchy. |
| **Driven in the simulator, both accounts, documents verified** | **Chat, end to end.** Company 706 opened workshop ad 109, pressed Message (owner's `uuid`/`username`/`name`/`surname` resolved live through `Account/get_user_details_by_id`), and sent — `createConnection` wrote the connection *on send, not on open*, then the message. Consumer 45 signed in, saw the thread in the inbox, opened it and replied. Both documents were then read back out of Firestore: `user_connections` has all **15** of Android's fields and no others, `chat` has all **9**; every value a string; `created_at = 2026-11-08` confirms the swapped `yyyy-dd-MM` for 11 August; `country_time` is an hour behind in Dubai; `sent_by` is `company` then `user`; `last_message`/`message_time` follow the newest message; and `user_is_view` flipped to `1` on the company's message when the consumer opened the thread, which verifies `markThreadViewed`. Bubble side and counterpart name flip correctly per role. A later second Message tap on the same ad exercised **`findConnection`'s reuse branch**: it reopened the existing thread with both messages rather than starting an empty one, the collection still holds exactly **one** connection with the same document id and `chat_uuid`, and `company_is_view` flipped to `1` on the consumer's message — each side's own messages left untouched, as `markThreadViewed` skips them. With the `show_chat` gate removed, the Message button is confirmed visible on the ad. |
| **Never done** | Apart from login and sign-up, no form has been submitted by hand. Nothing has been tested on a physical device, in Arabic, or in dark mode. |

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
