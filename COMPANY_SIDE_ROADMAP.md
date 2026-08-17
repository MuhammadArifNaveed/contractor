# Company (vendor) side — completion roadmap


> **Status banner (2026-08-17).** This document is a *working log / plan*, not the current state.
> [`PARITY_STATUS.md`](PARITY_STATUS.md) is the authority, and [`RESUME_HERE.md`](RESUME_HERE.md) is the
> entry point for picking the work up. Anything below that reads as "not built yet" may well be built;
> check there first.


> **Start with [`PARITY_STATUS.md`](PARITY_STATUS.md)** for the current what-is-done / what-is-left picture. This document is the detail behind it.

Walks the vendor drawer top to bottom, from the header's **View Profile** button down to **Logout**,
and says for each entry what exists, what is missing, and what it takes to finish. Android is the
functional source of truth (`RetrofitApi.java` for endpoints, `VendorActivities/*` + `res/layout/*`
for behaviour); iOS presentation is deliberately *not* a copy — see the design rule below.

Sequence: **company side → user side → no-login browsing.** This document covers the company side.

## The design rule

The earlier phases ported Android's 2021 Material look literally — 14sp bold headings, 5dp corners,
flat white boxes, hairline dividers. That is faithful and it looks dated on iOS. Going forward:

> **Data, behaviour, terminology, and state transitions: identical to Android.**
> **Layout, type, spacing, colour depth, motion, and empty states: iOS-native and better.**

Concretely, what changes and what must not:

| Must stay identical | Free to improve |
|---|---|
| Endpoint paths and part names | Type scale, spacing, corner radius, elevation |
| Which fields appear on a screen | How they are grouped and ordered visually |
| Status names and their API-provided colours | Badge shape, contrast, pill vs tag |
| Which sections hide when empty | What the empty state actually says and shows |
| Validation messages, word for word | Where and how the error appears |
| Pagination boundaries (`total_page`) | Loading affordance: skeletons instead of a spinner |

## Phase A — design system (do this first, everything else builds on it)

Without this, each new screen re-invents its own padding and every fix is 17 edits.

1. **`VendorTheme`** — one file replacing the ad-hoc `VendorHomeStyle`: semantic colours that
   resolve for light *and* dark mode, a real type scale (`.largeTitle` → `.caption2` via
   `Font.system(_:design:)` so Dynamic Type works), a 4-point spacing scale, two elevation levels.
   Keep `#f2be36` as the brand accent — it is the one thing that should not change.
2. **Card, section header, badge, field-row, empty-state, skeleton-row primitives.** The current
   code repeats the same `.padding(12).background(.white).cornerRadius(5).shadow(...)` in nine
   places; that becomes `.vendorCard()`.
3. **Replace the spinner** with skeleton rows, and **replace "Data Not Found"** with a real empty
   state: icon, one-line explanation, and an action where one exists ("Nothing pending — new
   enquiries appear here").
4. **Pull-to-refresh** (`.refreshable`) on every list. Android has no refresh at all; this is a
   straight win.
5. **Larger touch targets.** The dashboard's square count cards are currently ~110pt wide with
   14pt text; a 2-column grid with 17pt figures reads far better on a phone and still shows all
   five statuses without truncation.

Estimated: one focused pass. Everything after this is cheaper.

## Phase B — the drawer, item by item

Legend: ✅ done · ◐ partial · ⬜ missing

### Header — View Profile ✅

Android `VendorProfile`: `POST vendor/my_company` for the full company record, plus an
**online/offline toggle** (`POST vendor/is_online` with `vendor_id`, `is_online`).

Done. `VendorProfileView` now calls `vendor/my_company` and renders the record across five cards:
identity (logo, name, category, plus Verified / Titanium / Trusted chips the response already carried
and Android never surfaced), online state, about, location, registration, contact. Both the nav
header's "View Profile" and the drawer's "Profile" row land here, as on Android.

The online toggle is a single switch rather than Android's "Go Online" button plus a separate Yes/No
label — same endpoint, same two states, one control. It flips optimistically and reverts if the
server rejects it.

**Gotcha for anyone else reading this response:** the key is `Vendor_profile` with a **capital V**,
not the `vendor_profile` Android's Gson field name implies.

### 1. Home ✅

`VendorHomeView`, verified rendering with live data. Phase A should widen the count grid.

### 2. Profile ✅ — same screen as the header, above

### 3. Inbox ⬜ — shows "not available yet"; blocked on a dependency, not on porting

The drawer row now opens `VendorComingSoonView` saying messaging needs Firebase set up for iOS,
rather than the consumer `ChatListView` it used to open — that screen calls `Home/get_chats`, which
does not exist, so it could only ever show an error.

**Correction to an earlier assumption in this document: the vendor inbox is not REST at all.**
`VendorChatConnection` and `VendorChat` both use **Firebase Firestore** directly
(`FirebaseFirestore.getInstance()`). The `freelancing/*chats` REST endpoints listed here previously
belong to the freelancing-order chat, which is a separate surface.

**The blocker:** the iOS project has no Firebase whatsoever — nothing in the `Podfile`, nothing in
`Pods/`, no `import Firebase` anywhere, and no `GoogleService-Info.plist`. (`Global.shared.fcmToken`
is only a stored string; no SDK backs it.) Android's `google-services.json` is for project
`thecontractor-uae`, package `com.thecontractor`, and cannot be reused: iOS needs its own app
registered in that Firebase project under bundle id `com.contractor.TheContractorx`, which produces
an iOS-specific `GoogleService-Info.plist`. Only someone with Firebase console access can generate it.

Adding `pod 'Firebase/Firestore'` without that plist makes `FirebaseApp.configure()` crash on launch,
so it was deliberately **not** added — that would leave the app in a worse state than it is now.

**What is needed to unblock, in order:**

1. Register an iOS app for bundle id `com.contractor.TheContractorx` in the `thecontractor-uae`
   Firebase project and add the resulting `GoogleService-Info.plist` to the target.
2. Add `pod 'Firebase/Firestore'` (and `Firebase/Core`) and run `pod install`.
3. Confirm the Firestore security rules permit an iOS client — the rules may be scoped to the
   Android app or to authenticated users, and this app performs no Firebase Auth sign-in.

**The contract, ready to implement once unblocked.** Read off `VendorChatConnection` and
`VendorChat`, so no guesswork remains:

*Thread list* — collection **`user_connections`**, filtered `whereEqualTo("company_uuid", <vendor
uuid>)`, live via a snapshot listener. `VendorSession.uuid` already carries that value and is
populated (verified: `1f60a79a-…` for the test company). Document fields used: `company_id`,
`company_uuid`, `company_serial_no`, `company_name`, `company_is_active`, `user_id`, `user_uuid`,
`user_name`, `full_name`, `user_is_active`, `is_active`, `chat_uuid`, `created_at`, `last_message`,
`message_time`.

*Thread* — collection **`chat`**, filtered `whereEqualTo("chat_uuid", <chat uuid>)`, ordered by
**`country_time`**, live via a snapshot listener.

*Sending* — `add()` a document to **`chat`** with exactly: `company_uuid`, `user_uuid`, `chat_uuid`,
`time`, `country_time`, `company_is_view` `"0"`, `user_is_view` `"0"`, `message`, and
`sent_by` `"company"`. On success Android then updates `last_message` on the `user_connections`
document and fires a push via `vendor/send_message_notification`.

Note every field is a **string**, including the `"0"` view flags — Firestore is schemaless, so
writing them as booleans or numbers would make the Android client fail to read them.

**Also still missing:** the per-quotation workshop chat thread (`quotations[].chats` in the workshop
detail response). It belongs with this work.

### 4. Rating ✅

`vendor/rating` → `rating_enquiries`. Returns `error:true, "Rating not found."` for the test account,
so only the empty path has been exercised — re-test on an account with ratings.

### 5. Enquiries ✅

Full chain: `vendor/enquiries_status` → `vendor/view` → `vendor/enquiry`, with status updates and the
rejection-reason flow. Untested against an account that actually has enquiries.

### 6. Quotations ✅

Chain complete: `vendor/quotations_dashnoard` → `vendor/quotations` → `vendor/quotation`, with status
updates, rejection, and the image grid.

Document upload done. The section appears only at status `2` ("Upload Document") and `5`
("Resubmit Document"), matching Android, and posts to `vendor/upload_document`.

This needed a new transport: both existing multipart helpers hardcode `image.jpg` / `video.mov`, so
a PDF went up as a JPEG. `BaseService.makePostAPICallWithDocument` sends the real filename and MIME
type. The picker's URL is security-scoped, so the bytes are read inside a
start/stopAccessingSecurityScopedResource pair.

### 7. Post Workshop ✅

`VendorPostWorkshopView` replaces `VendorAddWorkshopItemView`, which posted to
`Home/add_workshop_item` — an endpoint the backend does not serve.

Pickers come from `workshop/workshop_filter_data`: `workshop_type` and `work_sector` as
`{title, value}` (Open/Close and Government/Private), `freelancer_cities` as `{id, name}`. The ad
posts to `workshop/submit_workshop_ad`.

**Gotcha:** the images go up as repeated **`images[]`** parts. That is what Android's
`ImagePartFromUri.createPartFromUri(..., "images[]")` actually sends, despite the Retrofit signature
naming the argument `surveyImage`. This needed a third transport helper —
`makePostAPICallWithImages` — because the existing multipart call takes a dictionary and so cannot
express the same key twice.

Photos use a `PHPickerViewController` wrapper (SwiftUI's `PhotosPicker` is iOS 16; the target is
iOS 15), up to eight, each downscaled to 1600pt and re-encoded at JPEG 0.75 — straight off the camera
eight photos is tens of megabytes.

### 8. My Workshops ✅ · 9. All Workshops ✅ · 10. Interested Workshops ✅

`workshop/workshops`, `workshop/show_workshops_for_interest` (+ `mark_workshop_interested`), and
`workshop/workshop_my_page`. All paginated with Android's Open Bid / Close Bid tabs.

**Detail screen — done.** `VendorWorkshopDetailView` on `workshop/get_workshop_details` is now the
destination for all three lists: the ad summary with Enabled/Disabled and Paid/Unpaid chips, the
image strip, and the quotations already placed on it (showing the agreed price once one exists,
falling back to the initial price, with a lock indicator).

On All Workshops it also offers "Send a quotation" via `workshop/add_workshop_quotation`. Android
branches on the response's `action` field, and that is reproduced: `posted` / `failed` /
`'invalid id` report the message, while `need subscription` and `subscription expired` raise a
dialog the company has to acknowledge.

**Gotcha:** the part is `workshop_id` here, but `workshop_ad_id` on `mark_workshop_interested` —
same value, two names.

Quotation lock done: each quotation row carries a Lock / Unlock action on
`workshop/quotation_toggle_lock`. The part is `chatEntryId` — the quotation's own id — and `action`
is the literal word `"lock"` or `"unlock"`, not a flag (`WorkshopAdDetail.updateLockAPI`).

**Still missing:** the per-quotation chat thread. The detail response already returns a
`quotations[].chats` array, so the data is in hand; it belongs with the Inbox work.

### 11. Jobs Portal ✅

`jobs/app_jobs_dashboard` → `jobs/jobs_listing` → `jobs/view_job`, plus publish toggle, delete, and
per-job applications with accept/reject.

Create and edit done. `VendorPostJobView` serves both, as Android's `VendorPostJob` does —
`jobs/post_job` and `jobs/update_job` take identical parts except the update adds `job_id`. Reached
from a `+` on the dashboard toolbar and an Edit action on each row, matching
`VendorJobListingAdapter`.

Two things worth knowing: the vacancies part is spelled **`vaccancies`** server-side, and `job_types`
comes back with only a `type` string and no id, so the label itself is what gets posted. Editing
opens populated straight from the listing row without a second fetch, but the row carries display
*names* while the form must post *ids*, so the selections are matched back onto the freshly loaded
option lists.

Job image done: one optional image via the same `PHPickerViewController` wrapper Post Workshop uses,
downscaled and re-encoded through `vendorUploadJPEG()` before upload.

### 12. Available Applicant ✅

`jobs/search_applicants` with pagination and direct hire.

Filter done. `jobs/get_job_search_fields` feeds category and city pickers; the toolbar icon fills in
when a filter is active, and applying resets to page 1. Android uses two toolbar spinners; a single
sheet of selectable chips shows both current selections at once and takes fewer taps.

### 13. Freelancers ✅ — browse, multi-select and hire

`VendorHireFreelancerView` replaces the consumer screen for companies: browse on
`freelancing/freelancers_frontend` with a category/city filter from
`freelancing/get_freelancing_search`, then a detail screen showing rates, skills and availability
with transport cost from `freelancing/transportation_charges`, then a booking sheet (hourly or daily,
a time window, one or more dates) that hires via `freelancing/hire_freelancers`.

Android's vendor mode passes the company id as both `vendor_id` and `user_id`; that is reproduced.

**The payload is the part to be careful with.** `freelancer_data` is not an object — it is a JSON
**string** containing an *array*, because Android sends `new Gson().toJson(list)` of its selected
freelancers. Each entry mirrors `SelectedFreelancersDatabaseModel`, including a nested `detail` with
`isHourly`, `fromTime`, `toTime`, `isPicked` and a `dates` array. Every value is a string, so
`isHourly` goes as `"1"`/`"0"` rather than a JSON boolean.

**Multi-select is built.** Tick freelancers on the list, book each in turn through the same sheet a
single hire uses, then post one array. Per-freelancer detail is preserved, which is the point — each
entry keeps its own dates and window, which is what Android's local selection table exists to do. No
local database is needed; the selection is view state.

**Correction to an earlier note here.** This section used to say `freelancers_frontend` "returned zero
rows for the test company, so only the empty state has actually rendered". That was wrong, and the wrong
conclusion was drawn from it. The endpoint returns `freelancers_list`; iOS was reading `freelancers`, so
the screen showed "No freelancers found" no matter what came back. Vendor 706 gets `{"total":1,
"freelancers_list":[…]}` and the list renders correctly now.

The lesson is the one in `RESUME_HERE.md` §4: **an empty screen on this backend is more often a wrong key
or a wrong id than an empty result.** Confirm with curl before recording "no data" as a finding.

**Pick-up addresses are not part of this flow** — a second earlier assumption that did not survive
checking. `pick_up_address` / `pick_up_latitude` / `pick_up_longitude` belong to the *freelancer's own
profile* (Android's `FreelancerAddressFragment`), not to hiring. They live in `UpdateFreelancerView`,
backed by `PickUpLocationPicker`, and their three endpoints were already wired — but keyed on the user id
instead of the freelancer record id, so the list always came back empty. Fixed.

### 14. Freelancer Dashboard ✅

`freelancing/freelancing_dashboard` counts grid. Note Android's adapter sends every tile to
`VendorJobListing`, which is reproduced faithfully — verify with the team that this is intended and
not an Android copy-paste bug. If it is a bug, the counts should drill into
`freelancing/freelancing_orders` / `hired_freelancers` instead.

### 15. Memberships ◐

`vendor/memberships` with the full perk card and coupon redemption
(`vendor/buy_membership_by_coupon`).

**Missing:** card payment (`vendor/buy_membership_online` with `paid_amount`, `transaction_no`).
Needs a payment gateway decision — this is a product call, not a porting task.

### 16. My Membership ✅

`vendor/my_memberships` list.

Detail screen done. Rows are tappable into `VendorMyMembershipDetailView`, which needs no API call —
every field was already in the `vendor/my_memberships` row, so the record is passed through. Shows
the top-10 / top-20 listing windows, purchase details, and leads / quotations usage as meters rather
than Android's raw "used / capacity" text, turning red when a limit is reached.

### 17. Logout ✅

Clears the vendor session, `isCompanyLoggedIn`, and returns to login.

## Recommended order

Cheapest-to-most-valuable, front-loading the work that unblocks other work:

| # | Item | Why here |
|---|---|---|
| 1 | Phase A design system | Every later screen is cheaper and consistent; fixes the "dated" look at the root |
| ~~2~~ | ~~View Profile + online toggle~~ | done |
| ~~3~~ | ~~Workshop detail (+ quotation submit)~~ | done |
| ~~4~~ | ~~Quotation document upload~~ | done |
| ~~5~~ | ~~My Membership detail~~ | done |
| ~~6~~ | ~~Applicant filter sheet~~ | done |
| ~~7~~ | ~~Job create / edit~~ | done |
| ~~8~~ | ~~Post Workshop form~~ | done |
| ~~9~~ | ~~Freelancers vendor mode~~ | browse + single hire done; cart and addresses outstanding |
| 10 | Inbox (+ workshop quotation chat) | blocked on Firebase iOS setup; placeholder in place |
| — | Membership card payment | Blocked on a payment-gateway decision |

## Testing note that applies throughout

The test company (vendor 706) has **zero enquiries, quotations, and ratings**, so only empty states
have been exercised end to end. Ask for a QA account with live data before signing off any of the
list screens. Also worth fixing: the Claude Code simulator integration cannot attach until someone
runs `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`, which is why no form has yet
been driven by hand.

## After the company side

- **User side** — same treatment. Note the audit already found the consumer flows in worse shape:
  login, registration, cart, checkout, chat, profile edit, and password change all post to
  fabricated `Home/*` paths. Listed in `IOS_VENDOR_PARITY_PROGRESS.md`.
- **No-login browsing** — category browse, company search, company detail, 24/7 list. Needs its own
  audit; several already use real endpoints.
