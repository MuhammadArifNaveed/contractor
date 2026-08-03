# User (consumer) side — plan

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
| `TwentyFourSevenCompaniesView` | `Home/get_24_7_companies` | `Home/twentyfourcompanies` |
| `WorkshopViewModel` | `Home/get_workshop_items` | `Home/recent_workshop_ads` |
| `SearchJobsViewModel` | `Home/search_jobs` | `jobs/search_jobs` |
| `MyJobApplicationsViewModel` | `Home/get_my_job_applications` | `jobs/user_job_applies` |
| `DirectHiringView` | `Home/get_direct_hiring` | `jobs/user_direct_selections` |
| `ContactUsView` | `Home/contact_us` | none — Android opens the contact **web page** (`AppLinks.ContactUS`) |

### No endpoint exists — needs a product decision, not a port

| Screen | Situation |
|---|---|
| `AddReviewViewModel` (`Home/submit_review`) | Android has no review-submit endpoint at all. `vendor/rating` is a company-side *read*. Either the feature does not exist or it is web-only. |
| `ReviewsListViewModel` (`Home/get_company_reviews`) | Same — no consumer review-read endpoint. Ratings may only be reachable through `Home/company_detail`. |
| `CartViewModel` (`Home/get_cart`) | Android has no cart endpoint. The cart is **local state**; `Home/check_cart_limit` only validates how many companies may be added, and the basket is submitted through `Home/send_enquiries`. |
| `CheckoutViewModel` (`Home/submit_order`) | Same — "checkout" for a consumer is `Home/send_enquiries`. |
| `ChatListViewModel` (`Home/get_chats`) | Chat is **Firebase Firestore**, exactly as the vendor inbox is. Blocked on the same iOS Firebase registration. |

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

**U4 — Enquiries and quotations. ◐ lists done; cart, checkout and drill-downs outstanding.**

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

**U6 — Workshops and estimations.** `Home/recent_workshop_ads`, `Home/workshop_ad_detail`,
`Home/submit_workshop_ad`, plus the estimation family (`Home/get_estimation_categories`,
`Home/estimation_request`, `Home/estimation_requests`, `Home/submit_estimate_request`) which iOS does
not touch at all today.

**U7 — Reviews, cart-as-orders, chat.** The four items above with no endpoint. Each needs a decision
before code: does the feature exist, is it web-only, or is it Firestore. Chat is blocked on Firebase
either way and should show the same "not available yet" screen the vendor inbox does.

**U8 — Design system.** Extend `VendorTheme` (rename to a neutral `AppTheme`-style namespace) across
the consumer screens, as was done for the vendor side. Worth doing once the endpoints are right, not
before — restyling a screen that shows no data is wasted effort.

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
