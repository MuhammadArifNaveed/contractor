# User (consumer) side — plan


> **Start with [`PARITY_STATUS.md`](PARITY_STATUS.md)** for the current what-is-done / what-is-left picture. This document is the detail behind it.

Same method as the company side: Android is the functional source of truth
(`RetrofitApi.java` for endpoints, the activities and `res/layout` for behaviour), while presentation
is iOS-native. See `COMPANY_SIDE_ROADMAP.md` for the design rule and the design system the vendor
screens now share.

## The headline finding

The consumer side is in worse shape than the company side was. An audit of every hardcoded URL in the
project found **26 paths that Android does not declare**, spread across roughly two dozen reachable
screens. Sign-up, sign-in, cart, checkout, chat, reviews, enquiry and quotation lists, profile
editing and password change all post to endpoints the backend has never served.

Two audits are worth re-running after every change to this area; both live in the session scratchpad:

- **Path audit** — every `BASE_URL + "..."` and hardcoded URL against Android's `@POST` list.
- **Payload audit** (`parity.py`) — part names against Android's `@Part` names. This is the one that
  matters most: a path can be right while every field is silently ignored, which is exactly what was
  happening on the company side's registration and password-reset flows.

## Endpoint mapping

Everything below is read off `RetrofitApi.java`. This is the substance of the work — the UI mostly
exists already.

| Screen / view model | Calls today | Android's actual endpoint |
|---|---|---|
| `LoginViewModel` | `Home/login` | `Account/user_login` |
| `RegistrationViewModel` | `Home/register` | `Account/user_register` |
| `ChangePasswordView` | `Home/change_password` | `Account/change_password` |
| `ForgotPasswordViewModel`, `ForgetPasswordViewController` | `Home/forgot_password`, `Account/forgot_password` | `Account/phone_check` then `Account/update_password` |
| `VerifyNumberView` | `Home/verify_number` | `Account/phone_check` |
| `EditProfileViewModel` | `Home/update_user_profile` | `Account/update_user_profile` |
| `EnquiriesListViewModel` | `Home/get_enquiries` | `Home/recent_enquiries` |
| `QuotationsListViewModel` | `Home/get_quotations` | `Home/recent_quotations` |
| `ComplaintsListViewModel` | `Home/get_complaints` | `Home/recent_complaints` |
| `CompaniesByCategoryView` | `Home/companies_by_category` | `Home/category_wise_companies` (and `Home/sub_category_wise_companies`) |
| `CompaniesListViewModel` | `Home/get_searched_companies` | `Home/find_companies` / `Home/get_search` |
| `TwentyFourSevenCompaniesView` | `Home/get_24_7_companies` | `Home/twentyFourCompanies` (the camelCase spelling is Android's; iOS had it all-lowercase until later) |
| `WorkshopViewModel` | `Home/get_workshop_items` | `Home/recent_workshop_ads` |
| `SearchJobsViewModel` | `Home/search_jobs` | `jobs/search_jobs` |
| `MyJobApplicationsViewModel` | `Home/get_my_job_applications` | `jobs/user_job_applies` |
| `DirectHiringView` | `Home/get_direct_hiring` | `jobs/user_direct_selections` |
| `ContactUsView` | `Home/contact_us` | none — Android opens the contact **web page** (`AppLinks.ContactUS`) |

### No endpoint exists — needs a product decision, not a port

| Screen | Situation |
|---|---|
| `AddReviewViewModel` (`Home/submit_review`) | **Resolved by deletion.** Android has no review-submit endpoint at all, and the iOS screen was unreachable, so nothing was waiting on the product answer. Deleted. |
| `ReviewsListViewModel` (`Home/get_company_reviews`) | **Resolved by deletion.** Also unreachable. Company ratings still reach the UI through `Home/company_detail`. |
| `CartViewModel` (`Home/get_cart`) | **Done.** The cart is local state in `ConsumerCartStore`; `CartView` is on it and the old view model is deleted. |
| `CheckoutViewModel` (`Home/submit_order`) | **Done.** A consumer "checkout" is just the cart submit — `Home/send_enquiries` — so the screen and its view model are deleted. |
| `ChatListViewModel` (`Home/get_chats`) | **Done.** Chat is **Firebase Firestore**, exactly as the vendor inbox is, so the consumer Inbox now shows the same honest "not available yet" screen and the fabricated call is gone. |

### Payload bugs on paths that are already correct

Found by the payload audit; these are live screens that cannot be working:

| Endpoint | Sends | Android expects |
|---|---|---|
| `Home/send_enquiries` | `first_name`, `last_name`, `phone`, `email` | `user_name`, `surname`, `user_phone`, `user_email` |
| `Home/enquiry_detail` | `enquiry_id` | `id`, `user_id` |
| `Account/change_password` | `user_id` | `user_email` |

## Plan, in order

Ordered so that each phase leaves the app in a better state on its own, and the cheap high-impact
fixes come first.

**U1 — Payload fixes. ✅ done.** All three corrected: `Home/send_enquiries` now sends
`user_name`/`surname`/`user_phone`/`user_email`, `Home/enquiry_detail` sends `id`+`user_id` instead of
`enquiry_id`, and `Account/change_password` is keyed on `user_email` rather than `user_id`. Both
changed signatures were unreferenced, so no call sites needed updating. The payload audit now reports
no consumer mismatches.

Four flags remain in the audit output, triaged:

- `registerCompany` — false positive; its params arrive from the caller, which the script cannot see.
  The caller was corrected on the company side.
- `requestQuotationByPhoto` — false positive; it does attach images, through a ternary the detector
  does not follow.
- `setWorkshopQuotationLock` — false positive; the `"lock"`/`"unlock"` ternary literal is read as a
  param key.
- `addWorkshopQuotation` — **real**: Android can attach a document to a workshop quotation and iOS
  sends only text and price. Small gap, company side.

**U2 — Auth and profile. ✅ done.**

The reachability check paid off. Of the six screens listed, **four were unreachable duplicates**: the
SwiftUI `LoginView`, `RegistrationView`, `ForgotPasswordView` and `VerifyNumberView` had no call sites
anywhere. The live path is the storyboard one — `LoginViewController` → `VerifyNumberViewController` /
`ForgetPasswordViewController` → `RegistrationViewController` → `OTPViewController` →
`NewPasswordViewController` — and `LoginViewController` already used the correct
`Account/user_login`. Fixing the SwiftUI screens would have been effort spent on code nothing opens.

Deleted those four plus their three view models, taking the fabricated `Home/login`,
`Home/register`, `Home/forgot_password` and `Home/verify_number` with them. The count of fabricated
hardcoded URLs drops from 26 to 18.

Three genuinely live screens fixed:

| Screen | Was | Now |
|---|---|---|
| `ChangePasswordView` | `Home/change_password` with `user_id` + `current_password` | `Account/change_password` with `user_email` + `old_password` |
| `EditProfileViewModel` | `Home/update_user_profile` with `name` / `phone` | `Account/update_user_profile` with `user_name` / `user_phone` / `surname` / `user_email` / `address` / `city` / `country` / `job_category` |
| `ForgetPasswordViewController` | `Account/forgot_password` | `Account/update_password` with `new_password` + `user_phone` |

`UserViewModel` had to gain an `email` field — it was commented out, so the session never captured
the email that `Account/change_password` is keyed on. It reads `email`, falling back to `user_email`.

Still open in this area: `EditProfileViewModel` sends `address`, `city`, `country` and `job_category`
as empty strings because the form does not collect them, and it does not send the three optional
file parts Android supports. The call is correct; the form is thinner than Android's.

**U3 — Browse and discovery. ✅ done.**

Reachability again cut the work down: `CompaniesByCategoryView` and `SubCategoriesView` have no call
sites, so they and `SubCategoriesViewModel` were deleted, taking the fabricated
`Home/companies_by_category` with them. `SearchCompaniesViewModel` turned out to be **already
correct** — it uses `EndPoints.getSearch`, which is the real `Home/get_search`.

Three live screens fixed:

| Screen | Was | Now |
|---|---|---|
| `TwentyFourSevenCompaniesView` | `Home/get_24_7_companies` | `Home/twentyfourcompanies` (takes no parts) |
| `CompaniesListViewModel` | `Home/get_searched_companies`, paging on `page_no` | `Home/find_companies`, paging on `page` |
| `CompanyDetailViewModel.submitComplaint` | `Home/submit_complaint` with a `text` part | same path, part renamed to `complaint` |

`CompanyDetailViewModel`'s main fetch was already right: `Home/company_detail` with `company_id`.

The complaint one is worth noting — the path had always been correct, so a path-only audit called it
clean while every complaint submitted carried no complaint text.

Fabricated hardcoded URLs: 18 → 15.

**U4 — Enquiries and quotations. ◐ lists, cart, quotation and complaint drill-downs done; enquiry drill-down blocked on the backend.**

The three lists are fixed. All three carried the *same pair* of defects — a `Home/get_*` path the
backend does not serve, and `page_no` where Android's part is `page`, so paging was broken
independently of the path:

| View model | Was | Now |
|---|---|---|
| `EnquiriesListViewModel` | `Home/get_enquiries`, `page_no` | `Home/recent_enquiries`, `page` |
| `QuotationsListViewModel` | `Home/get_quotations`, `page_no` | `Home/recent_quotations`, `page` |
| `ComplaintsListViewModel` | `Home/get_complaints`, `page_no` | `Home/recent_complaints`, `page` |

All three take `user_id` + `page`, confirmed against `RetrofitApi.java`.

**Outstanding in this phase.**

*No drill-down from any list.* `EnquiryDetailView`, `QuotationDetailView` and `ComplaintDetailView`
all exist but have **no call sites and make no API calls** — they are display-only shells expecting a
model to be handed in. The endpoints they should use are ready: `Home/enquiry_detail` (already fixed
in U1), `Home/quotation` and `Home/complaint`, each taking `id` + `user_id`. Wiring the lists to them
is the next concrete piece of work here.

*Cart and checkout still need the product decision from U7.* `CartViewModel` calls `Home/get_cart`
and `CheckoutViewModel` calls `Home/submit_order`; neither exists. The shape Android implies is: cart
is **local state**, `Home/check_cart_limit` (already implemented as `LoginService.checkCartLimit`)
validates how many companies may be added, and the basket is submitted through `Home/send_enquiries`
— which U1 already corrected. Converting the cart to local state is a behavioural change, not a
rename, so it is left for a decision rather than guessed at.

Fabricated hardcoded URLs: 15 → 12.

**U5 — Jobs. ✅ done, and verified against the live API.**

The only phase so far where the endpoints could actually be exercised — none of these needs a company
session, so all three were called live with real responses:

| Screen | Was | Now | Live result |
|---|---|---|---|
| `SearchJobsViewModel` | `Home/search_jobs`, part `search_query`, read `jobs` | `jobs/search_jobs`, parts `page`/`jobs`/`job_category`/`job_city`, reads `available_jobs` | `error:false`, 7 rows |
| `MyJobApplicationsViewModel` | `Home/get_my_job_applications`, read `applications` | `jobs/user_job_applies` + `page`, reads `job_applications` | `error:false` |
| `DirectHiringView` | `Home/get_direct_hiring`, read `items` | `jobs/user_direct_selections` + `page`, reads `user_direct_selections` | `error:false` |

**Each of these was wrong in three places at once** — path, request part names, *and* the response key
the parser read. Fixing only the path would have left every list silently empty, which is why the live
call mattered here: it is the first phase where the response shape was confirmed rather than inferred
from Android's models.

Two details worth carrying forward: the job-search term's part is literally named **`jobs`**, not
`query` or `search`; and `search_jobs` returns its rows under **`available_jobs`**, not `jobs`.

`jobs/job_apply` needed nothing — `JobDetailViewModel` already called it correctly with `user_id` and
`job_uuid`.

Fabricated hardcoded URLs: 12 → 9.

**U6 — Workshops and estimations. ◐ audited; the work here is bigger than a rename.**

`ContactUsView` was unreachable and is deleted, clearing `Home/contact_us`. Android does not have that
endpoint either — it opens the contact **web page** (`AppLinks.ContactUS`), which the drawer already
does.

**Estimations are now built — see the section at the end.** They were the one feature here with no
implementation at all: `EstimationViewController`, the Estimation bottom tab, could calculate a figure
and had no way to submit it, and the user's own requests were unreachable from anywhere.

The contract is confirmed and `Home/get_estimation_categories` was called live: `error:false`, two
categories back, each carrying a nested `sub_categories` array.

| Step | Endpoint | Parts |
|---|---|---|
| Categories | `Home/get_estimation_categories` | none |
| Submit | `Home/submit_estimate_request` | `user_id`, `full_name`, `phone_number`, `email_address`, `note`, `est_enter_sqft`, `look_id`, `cate_id` |
| List | `Home/estimation_requests` | `user_id`, `page` |
| Detail | `Home/estimation_request` | `id`, `user_id` |

**The workshop cluster is now untangled. ✅**

Done in the documented order: the dead `VendorWorkshopView` and `VendorWorkshopViewModel` structs were
stripped out of `VendorWorkshopView.swift`, leaving the live `VendorInterestedWorkshopsView`,
`VendorWorkshopAd` and `VendorWorkshopAdCard` in place (the file keeps its name). Then
`WorkshopView.swift`, `WorkshopViewModel.swift`, `VendorAddWorkshopItemView.swift` and the two
matching hosting controllers were deleted, along with the now-unreachable
`showVendorWorkshopController` and `showVendorAddWorkshopController` on `MainContainerViewController`.

That clears three fabricated URLs at once: `Home/get_workshop_items`, `Home/vendor_workshop_items` and
`Home/add_workshop_item`.

The leak check earned its keep — it refused the first attempt and named all three real dependencies:
the two container methods, and a stale comment in `VendorPostWorkshopView.swift` referring to a file
about to disappear. `WorkshopItem` is still declared in `Models/WorkshopModels.swift`, which is not a
target member, so that duplicate is harmless.

The live consumer workshop path (`WorkshopPostView`, reached from the Workshop tab) was not touched.

Fabricated hardcoded URLs: 9 → 5, and **all five that remain are the U7 items awaiting a decision**.


**U7 — Reviews, cart-as-orders, chat.** The four items above with no endpoint. Each needs a decision
before code: does the feature exist, is it web-only, or is it Firestore. Chat is blocked on Firebase
either way and should show the same "not available yet" screen the vendor inbox does.

**U8 — Design system.** Extend `VendorTheme` (rename to a neutral `AppTheme`-style namespace) across
the consumer screens, as was done for the vendor side. Worth doing once the endpoints are right, not
before — restyling a screen that shows no data is wasted effort.

## Live verification of U4, and a backend bug

Using a real consumer account (user 45, from the QA phone number entered without its leading zero),
the three list endpoints and their detail endpoints were finally called for real. Two results matter.

### `Home/recent_enquiries` is broken on the server

It does not return JSON. It returns an HTML CodeIgniter stack trace:

```
Type: mysqli_sql_exception
Message: Unknown column 't2.company_whatsapp_phone' in 'field list'
```

So the consumer enquiries list cannot work no matter what the app sends — the query references a
column that does not exist. **This needs a backend fix and is worth reporting to whoever owns the
API.** It also means the enquiry drill-down cannot be verified end to end yet: there is no way to
obtain a valid enquiry id for a user through the API.

Worth noting Android would hit exactly the same wall, so this is likely broken in production on both
platforms.

### The U4 parsers were already right

This was flagged as a risk after U5 found wrong response keys on three of three screens. Checked, and
for these three it was a false alarm — `EnquiriesListViewModel`, `QuotationsListViewModel` and
`ComplaintsListViewModel` read `enquiries`, `quotations` and `complaints`, and
`Home/recent_quotations` does return its rows under **`quotations`** (not `recent_quotations`, which
would have been the natural guess). `Home/recent_complaints` answered
`{"message":"complaints not found.","error":true}` — reachable, just no data for this account.

So U4 needs no follow-up beyond the drill-downs.

### Detail endpoint shapes, confirmed

| Endpoint | Parts | Response |
|---|---|---|
| `Home/quotation` | `id`, `user_id` | `quotation`, plus `quotation_price` and `symbol` at the top level |
| `Home/complaint` | `id`, `user_id` | reachable; `complaint` expected, unconfirmed — no complaint data on this account |
| `Home/enquiry_detail` | `id`, `user_id` | unverifiable while `recent_enquiries` is throwing |

Note `Home/quotation` returns the price and currency symbol as **siblings** of `quotation`, not
inside it — a detail screen has to read all three.

## Cart — local state, implemented

Confirmed with the product owner and built to match Android exactly.

Android keeps the basket in a local SQLite table via `DatabaseHandler` and talks to the server only
twice: `Home/check_cart_limit` for how many companies the plan allows, and `Home/send_enquiries` to
submit. There is no cart endpoint at all. iOS was calling `Home/get_cart` and `Home/submit_order`,
neither of which exists.

`ConsumerCartStore` (`SwiftUI/ViewModels/ConsumerCartStore.swift`) is the replacement — a shared
observable store persisting to UserDefaults rather than SQLite, since the basket is a short list of
ids and a few strings per row.

It carries the per-company fields Android collects before submitting — `date_time`, `location`,
`lat`, `lng`, `description` — and reproduces Android's two gates: every row must be complete
(`SelectedCompaniesAdapter` refuses to build the payload while any field is blank), and the basket
must fit `available_cart_limit`, with `overLimitBy` matching Android's "remove N companies" message.

The payload shape is the part to get right. `companies` is a JSON **string** holding an array of
`{company_id, date_time, location, lat, lng, description}` — what Android produces from
`new Gson().toJson(selectedCompaniesList)` over `SelectedCompaniesResponseModel`. Contact details come
off the stored user rather than being asked for again, as in `OrderContactInfo.getDataFromSP()`.

### UI, done

`CartView` is now the enquiry basket on the store: a card per company (logo, name, category), the
per-company when/where/what shown inline, a details sheet to fill them in, remove, the over-limit
warning driven by `exceedsLimit`/`overLimitBy`, `refreshLimit()` on appear, and one submit gated on
`canSubmit`. `CartCompanyDetailsView` in the same file collects the three required fields; `lat`/`lng`
submit empty because nothing in the app picks a location on a map yet, which is also what Android
sends when its picker is skipped.

Companies get into the basket from two places, matching Android. `CompanyDetailView`'s top bar had a
decorative `cart` glyph doing nothing and now carries an "Add to enquiry" / "Added" toggle. And Android
adds from the list adapters too (`CompaniesAdapter`, `TitaniumCompaniesAdapter` — both hold a
`DatabaseHandler`), so the shared `CompanyCard` row has a circular add/added control; that one change
covers the search results, companies list, 24/7 list and home list, since all four use the same row.

`CompanyCard` was a `Button` wrapping its whole content, which would have swallowed taps on a nested
control, so the row's tap target is now a gesture on the content instead.

Not done: the compact `TitaniumCompanyCard` tile on the home screen has no basket control — Android's
titanium adapter does add from the row, but the tile is ~90pt wide and would be crowded. Its details
screen has the toggle.

Five files went with it, all unreferenced afterwards: `CartViewModel` (`Home/get_cart`),
`CheckoutViewModel` (`Home/submit_order`), `CheckoutView`, plus `CartManager` and `CartItem` — an
earlier, never-referenced local-cart attempt that was not even in the Xcode target, so it had never
compiled. **That clears the last of the fabricated endpoints: no `Home/`, `Account/` or `vendor/`
path anywhere in the iOS source is now absent from Android's `RetrofitApi`, and no hardcoded API URL
bypasses `BASE_URL`.**

One trap worth recording: the pbxproj removal script matched file names by substring, so
`CheckoutView.swift` also matched `FreelancerCheckoutView.swift` and would have silently unregistered
a live screen. Anchored with a negative lookbehind; the count dropped 28 → 24 lines.

## Estimations — done

Android splits this in two, and iOS collapsed both into one calculator that could not submit anything:

| Android | Endpoint | iOS now |
|---|---|---|
| `EstimationFragment` (bottom tab) | `Home/get_estimation_categories`, `Home/submit_estimate_request` | `EstimationView` |
| `Estimations` (drawer + profile) | `Home/estimation_requests` | `EstimationRequestsView` |
| `EstimationsDetail` | `Home/estimation_request` | `EstimationRequestDetailView` |

All four endpoints verified live. Categories come back as two entries (`Shell & Core`, `Fitted`) with
three sub-categories each; `min_val` on the sub-category is the **per-square-foot rate**, despite the
name. The estimate is `area × rate` and is never sent — the server holds the rate and recomputes.

The one trap is the two id parts on submit, which read backwards: **`look_id` is the top-level
category** ("looking for") and **`cate_id` is the sub-category**. That is how
`EstimationFragment.requestEstimation()` passes them, and it matches the response, which names them
`looking_for` and `category_name`. The payload audit cross-checks all three new calls against
Android's `@Part` names with no mismatch.

Deleted with it: `EstimationViewController` (the calculator-only storyboard screen), its
`getEsstimationData` service call — the last `makeGetAPICall` on an endpoint Android POSTs — and the
`EndPoints.homeEsstimation` constant. Its two storyboard scenes in `Home.storyboard` are now dead but
left in place; nothing instantiates them.

### Two infrastructure fixes this needed

**`containerView` runs the full height of the screen** with the top and bottom bars drawn *over* it —
which is why the vendor screens needed a status-bar underlay. A SwiftUI screen embedded at
`containerView.bounds` therefore loses its first ~45pt behind the yellow bar. The older tab screens
work around it by drawing their own copy of the bar underneath the real one (the source of the doubled
logo fixed earlier). `MainContainerViewController.showTabScreen(_:)` pins the content between the two
bars instead, so a SwiftUI tab screen needs to know nothing about them.

**"GoToLogin" is only observed by `ProfileHostingController`**, which is not installed while another
tab is showing, so a sign-in prompt posted from any other tab silently did nothing.
`MainContainerViewController` now observes **"RequestLogin"** and calls `loginUser()`; the estimate
screen uses that for its consultation gate.

## Notes carried over

- Every count and flag from this backend is a **string**, including `"0"`/`"1"` booleans. Parse
  through `stringValue`.
- Backend spellings are load-bearing: `vaccancies`, `quotations_dashnoard`, `Vendor_profile` with a
  capital V. Do not tidy them.
- Part names sometimes differ from the Retrofit argument name — the workshop image part is `images[]`
  though the argument is called `surveyImage`. Read the `@Part` annotation, never the signature.
- Verification is still limited to curl plus compile plus launch. No form in this app has been
  submitted by hand; that needs
  `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer` on this machine.
