#!/bin/bash
#
# Firebase configuration preflight.
#
# HANDOVER.md §4 lists the steps that have to be redone every time the Firebase account or project
# changes, and notes that each one "fails quietly or with a misleading error". Three of them are
# checkable from the files in this repo, and those three are the ones that have actually cost round
# trips. This checks them in one command.
#
# What it CANNOT check — these are console state, not files, and there is no way to see them from here:
#   * Phone provider enabled            (Authentication -> Sign-in method)
#   * AE allowed in the SMS region policy (Authentication -> Settings) — a separate gate from the above,
#     and every +971 number is refused with OPERATION_NOT_ALLOWED until it is set
#   * Firestore actually provisioned    (Firestore Database, NOT Realtime Database — different section)
#   * APNs key uploaded                 (Project settings -> Cloud Messaging)
#   * Firestore rules published         (`firebase deploy --only firestore:rules`, or paste in console)
#
# Usage:  ./scripts/firebase_preflight.sh
# Exits non-zero if anything is inconsistent.

set -u
cd "$(dirname "$0")/.." || exit 2

PLIST="TheContractor/GoogleService-Info.plist"
INFO="TheContractor/Info.plist"
PBX="TheContractor.xcodeproj/project.pbxproj"
fail=0

note() { printf '  %s\n' "$1"; }
ok()   { printf '\033[32mok\033[0m   %s\n' "$1"; }
bad()  { printf '\033[31mFAIL\033[0m %s\n' "$1"; fail=1; }

plist_get() { /usr/libexec/PlistBuddy -c "Print :$1" "$2" 2>/dev/null; }

[ -f "$PLIST" ] || { bad "$PLIST is missing — download it from Project settings -> Add app -> iOS"; exit 1; }

PROJECT_ID=$(plist_get PROJECT_ID "$PLIST")
BUNDLE_ID=$(plist_get BUNDLE_ID "$PLIST")
APP_ID=$(plist_get GOOGLE_APP_ID "$PLIST")

printf '\nFirebase project: %s\n\n' "${PROJECT_ID:-<none>}"

# 1. The bundle id in the plist has to match the one actually being built, or Firebase rejects the app
#    at runtime with an error that does not mention the bundle id.
PBX_BUNDLE=$(grep -m1 "PRODUCT_BUNDLE_IDENTIFIER" "$PBX" | sed 's/.*= *//; s/;//; s/ *$//')
if [ "$BUNDLE_ID" = "$PBX_BUNDLE" ]; then
    ok "bundle id matches the build ($BUNDLE_ID)"
else
    bad "bundle id mismatch"
    note "GoogleService-Info.plist: $BUNDLE_ID"
    note "project.pbxproj:          $PBX_BUNDLE"
fi

# 2. The phone-auth callback scheme. PhoneAuthProvider calls fatalError() — a hard crash, not an error —
#    when this is absent, so getting it wrong takes the app down on the SMS step.
EXPECTED_SCHEME="app-$(printf '%s' "$APP_ID" | tr ':' '-')"
if plist_get CFBundleURLTypes "$INFO" | grep -qF "$EXPECTED_SCHEME"; then
    ok "phone-auth URL scheme present ($EXPECTED_SCHEME)"
else
    bad "phone-auth URL scheme missing from Info.plist — PhoneAuthProvider will fatalError()"
    note "add this scheme: $EXPECTED_SCHEME"
fi

# 3. The rules file the deploy step publishes.
if [ -f firestore.rules ]; then
    # An unconditional *write* is the dangerous one — it lets anyone with the API key overwrite or
    # forge messages. An unconditional *read* is the known interim state (see the header of
    # firestore.rules): it cannot be closed until the backend mints custom tokens, so it is reported
    # as an outstanding item rather than a failure, to keep this script's exit code meaningful.
    if grep -qE '^[[:space:]]*allow ([a-z, ]*\bwrite\b[a-z, ]*):[[:space:]]*if true' firestore.rules; then
        bad "firestore.rules allows unconditional WRITES — anyone with the API key can forge messages"
    else
        ok "firestore.rules has no unconditional write"
    fi
    if grep -qE '^[[:space:]]*allow ([a-z, ]*\bread\b[a-z, ]*):[[:space:]]*if true' firestore.rules; then
        note "note: reads are still open. Expected until the backend mints Firebase custom tokens —"
        note "      swap in the participantsOnly rules at the bottom of firestore.rules once it does."
    fi
    if [ -f .firebaserc ] && grep -qF "$PROJECT_ID" .firebaserc; then
        ok ".firebaserc points at $PROJECT_ID"
    else
        bad ".firebaserc missing or pointing at a different project than the plist"
    fi
else
    bad "firestore.rules is missing"
fi

# 4. The plist has to be in the Resources build phase, not Sources — add_files.py does Sources only,
#    and a plist that never makes it into the bundle leaves FirebaseApp.configure() failing at launch.
if grep -q "GoogleService-Info.plist in Resources" "$PBX"; then
    ok "GoogleService-Info.plist is in the Resources build phase"
else
    bad "GoogleService-Info.plist is not in the Resources build phase — it will not ship in the bundle"
fi

printf '\n'
if [ "$fail" -eq 0 ]; then
    printf 'All file-level checks passed. The console-side items above still need eyes.\n\n'
else
    printf 'Fix the failures above before building.\n\n'
fi
exit "$fail"
