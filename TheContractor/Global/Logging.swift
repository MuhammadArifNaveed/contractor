//
//  Logging.swift
//  TheContractor
//
//  Silences every `print` in Release builds.
//
//  The app had 102 `print` calls across 22 files, 23 of them printing API responses, request
//  parameters, session tokens and raw JSON — `BaseService` logs every request and its full response
//  body. `print` writes to the system log in Release exactly as it does in Debug, and anyone can read
//  it off a connected device with Console.app without jailbreaking or any special access. That is a
//  real disclosure of other people's enquiries, quotations and chat messages.
//
//  This shadows the standard library's `print` for the whole module. Swift resolves an unqualified
//  `print` to the one declared here in preference to `Swift.print`, so all 102 call sites are covered
//  without touching any of them — which matters, because wrapping each site in `#if DEBUG` by hand
//  across multi-line calls, closures and `guard` bodies is exactly the kind of mechanical edit that
//  introduces a mistake in the one place nobody re-reads.
//
//  In DEBUG it forwards to `Swift.print` and behaves identically.
//
//  Note it silences *output*, not evaluation: the arguments to a `print` still run, so a `print` whose
//  argument has a side effect or is expensive to build still costs that in Release. Nothing here does
//  anything but interpolate strings, so that is acceptable; if a hot loop ever needs it, give that call
//  site its own `#if DEBUG`.
//
//  To deliberately log something in Release — a genuine diagnostic — call `Swift.print` explicitly, so
//  the intent is visible at the call site.
//

import Foundation

@inline(__always)
func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    Swift.print(items.map { String(describing: $0) }.joined(separator: separator), terminator: terminator)
    #endif
}
