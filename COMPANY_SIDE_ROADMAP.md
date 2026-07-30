# Company (vendor) side — completion roadmap

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

### 3. Inbox ⬜

Android `VendorChatConnection`. iOS routes to the consumer `ChatListView`, which calls
`Home/get_chats` — **an endpoint that does not exist**. The real chat surface is split across
`freelancing/order_placed_chats`, `freelancing/order_recieved_chats`, `freelancing/fetch_order_chats`,
`freelancing/send_message`, and `workshop/*` quotation chats.

**Work:** the largest single item here. Needs its own mini-plan: decide which conversation types a
company sees, build the thread list, then the thread view with send. Treat as its own phase.

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

### 7. Post Workshop ⬜

Android `VendorPostWorkshop`: loads pickers from `workshop/…filter` (workshop type, work sector,
cities), then posts via `vendorPostWorkShopAdNewAPI` with title, detail, type, sector, city **and
multiple images**.

iOS routes to `VendorAddWorkshopItemView`, which posts to `Home/add_workshop_item` — **does not
exist**.

**Work:** a real form. Three remote-loaded pickers, validation, multi-image picker, multipart post.
Second-largest item after Inbox.

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

**Still missing:** `workshop/quotation_toggle_lock`, and the per-quotation chat thread (the
`quotations[].chats` array the detail response already returns).

### 11. Jobs Portal ✅

`jobs/app_jobs_dashboard` → `jobs/jobs_listing` → `jobs/view_job`, plus publish toggle, delete, and
per-job applications with accept/reject. Android also has job **create/edit**
(`jobs/post_job`, `jobs/update_job`) reached from the listing — currently absent.

### 12. Available Applicant ✅

`jobs/search_applicants` with pagination and direct hire.

Filter done. `jobs/get_job_search_fields` feeds category and city pickers; the toolbar icon fills in
when a filter is active, and applying resets to page 1. Android uses two toolbar spinners; a single
sheet of selectable chips shows both current selections at once and takes fewer taps.

### 13. Freelancers ◐

Routes to the consumer `FreelancersView`, which uses `freelancing/freelancers_frontend` — **a real
endpoint**, so this one is closer than it looks. Android passes `from=vendor`, which changes what the
screen offers (hire flow rather than browse).

**Work:** audit against Android's `Freelancers` in vendor mode; add the vendor-mode hire path
(`freelancing/hire_freelancers`, `freelancing/transportation_charges`, address selection).

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
| 7 | Job create / edit | Self-contained form, pattern reused from #8 |
| 8 | Post Workshop form | Large: three pickers + multi-image upload |
| 9 | Freelancers vendor mode | Multi-screen hire flow |
| 10 | Inbox | Largest; wants its own plan |
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
