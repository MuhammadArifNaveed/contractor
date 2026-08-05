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
| Company / vendor side | **Complete.** All 17 drawer items and the header's View Profile reach a real screen on a real endpoint, or say plainly that the feature is unavailable. |
| Consumer side | **Complete.** Every drawer item and every tab reaches a real screen, or an honest "not available yet" (Inbox). Sign-up works; the SMS code step Android has is the one piece missing, see *What is left*. |
| Guest (no-login) flow | **Not started.** `GUEST_MENU` exists and some screens gate on login; the flow has never been walked end to end. |
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
| `Chat`, `ChatConnection` | "Coming soon" screen | Firebase Firestore — see *Blocked*. |

---

## What is left

### 1. The SMS code on sign-up

Sign-up itself now works: `SignUpView` takes the number, checks it with `Account/phone_check`, collects
the account details and creates it with `Account/user_register`, which returns the new `user` so the
account is signed in from the registration response — the same thing Android does.

**What is missing is the verification code.** Android sends it through Firebase Phone Auth and opens
the details form only once the code is confirmed. There is no server-side OTP endpoint — the SMS gate
is entirely client-side — and `Account/user_register` accepts a number with no proof of ownership. So
iOS checks the number is free and takes it on trust. Anyone can register a number that is not theirs,
exactly as they could by calling the endpoint directly.

Turning on Firebase (the same blocker as both inboxes) closes this: the code step slots in between the
two existing steps and nothing else changes.

`Account/get_user_details_by_id` is still unused — nothing needs to re-read the account yet.

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
| Session | `Account/get_user_details_by_id` | Nothing re-reads the account after sign-in yet. |
| Vendor workshop ads (capital-V variants) | `Vendor/workshop_ads`, `Vendor/workshop_ad_detail` | A separate vendor-side ad list; the `workshop/...` pair covers what both drawers open. |
| Freelancer order chat | `freelancing/fetch_order_chats`, `freelancing/order_placed_chats`, `freelancing/order_recieved_chats`, `freelancing/send_message` | Chat — same Firebase blocker. |
| Memberships | `vendor/membership_details`, `vendor/buy_workshop_membership_online`, `vendor/buy_workshop_membership_by_coupon` | See *Blocked*. |
| Push notifications | `Home/send_message_notification`, `vendor/send_message_notification` | Chat push — Firebase. |
| Misc | `Home/quotation_fee_paid`, `Home/get_by_company_id`, `jobs/search_job_title` | Quotation fee payment; company lookup by id; job-title autocomplete. |

### 3. Blocked on something outside the code

| Blocker | Affects | What is needed |
|---|---|---|
| **No Firebase in the iOS app** | Vendor Inbox, consumer Inbox, freelancer order chat, chat push, **and the SMS code on sign-up** | Register bundle `com.contractor.TheContractorx` in Firebase project `thecontractor-uae`, add the SDK. Both inboxes show an honest "not available yet" screen; sign-up proceeds without the code. |
| **No payment gateway decision** | Membership card purchase (`vendor/buy_membership_online` and the two workshop-membership calls) | Coupon purchase already works. |
| **Backend bug** | Consumer enquiry detail | `Home/recent_enquiries` returns HTML: `mysqli_sql_exception: Unknown column 't2.company_whatsapp_phone' in 'field list'`. Affects Android too. The list works; the drill-down waits on the column fix. |
| **Product question** | Consumer reviews | Android has no `submit_review` or `get_company_reviews` endpoint at all. The unreachable iOS screens for both were deleted. Company ratings still show via `Home/company_detail`. If reviews are meant to exist, the backend needs endpoints first. |

### 4. Everything else remaining, ranked

Nothing below blocks a normal user; they are ordered by what they cost.

**Worth doing next**

1. **Design-system pass over the older consumer screens** — `HomeView`, `SearchCompaniesView`,
   `CompanyDetailView`, `CartView`'s neighbours, the job screens. They still use `AppTheme` with
   hand-rolled yellow bars instead of `VendorTheme`, which is the shared system despite its name. This is
   the largest remaining *visible* difference between the two halves of the app.
2. **`UpdateFreelancerView` does not prefill from an existing freelancer record.**
   `freelancing/register_user_freelancer` returns all 38 fields — skills, rate, bank details, addresses —
   so a user editing their profile retypes everything. The data is already fetched by the row that opens
   the form.
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
| `Account/user_register` | Accepts any phone number with no proof of ownership; the SMS gate is client-side only. |
| Reviews | No `submit_review` or `get_company_reviews` endpoint exists at all. |

---

## Verification ledger

Honest account of how far each claim is tested.

| Level | What |
|---|---|
| **Driven in the simulator** | Edit Profile's freelancer availability switch and freelancer-profile form (real account data, no demo values); vendor direct hiring — list with real rows and status chips, detail, and the five-value picker; the consumer's own workshop ads — list with real rows on both bid tabs, detail, and the enable/disable action flipped to Disabled and back to Enabled so the account's data is unchanged; consumer sign-up end to end — the taken-number path shows the backend's own "Phone number is already exist.", and a new account was created and signed in (see the note below); company login and dashboard; both app bars; the whole estimate flow — categories load, 1200 sqft of Shell & Core office gives AED 198,000 at 165/sqft, the signed-out consultation gate reaches the login screen, the request list shows the account's real request, the detail screen fetches and renders it, and the consultation form prefills from the stored user. Consumer login with the tester account. |
| **Endpoint verified live (curl), UI compiled but not driven** | The two write actions listed under *Not exercised* above, and every screen not named in the row above. Each endpoint was called against the live backend and each parser written against the real key names — but a screen that has only been compiled can still be wrong in ways only looking at it reveals, which is exactly what the last visual pass showed: four defects on two screens whose endpoints were all correct. |
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
