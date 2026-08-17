//
//  PickUpLocationPicker.swift
//  TheContractor
//
//  Picking the pick-up point for a freelancer address — the map half of Android's
//  `FreelancerAddressFragment`, which drops a marker, reverse-geocodes it, and sends
//  `pick_up_address` / `pick_up_latitude` / `pick_up_longitude` to `freelancing/add_freelancer_address`.
//
//  iOS collected the address as free text and sent "0.00000000" for both coordinates, with a
//  "you might want to get actual coordinates" comment where the work should have been. Since the
//  pick-up *point* is the entire reason the record exists, every address saved was unusable.
//
//  The map is fixed and the pin is fixed at its centre — panning the map moves the world under the
//  pin. That is steadier than a draggable annotation on a small screen and is what most map pickers
//  do. Reverse geocoding is debounced so a pan does not fire a request per frame; `CLGeocoder` is
//  rate-limited by the system and will start failing if hammered.
//

import SwiftUI
import MapKit

struct PickUpLocationPicker: View {
    /// Where the pin starts. Dubai, matching `MapView`'s default, when there is nothing stored yet.
    var initialCoordinate: CLLocationCoordinate2D?

    let onPick: (_ address: String, _ latitude: String, _ longitude: String) -> Void
    let onCancel: () -> Void

    @State private var region: MKCoordinateRegion
    @State private var resolvedAddress = ""
    @State private var isResolving = false
    @State private var geocodeWorkItem: DispatchWorkItem?

    private static let dubai = CLLocationCoordinate2D(latitude: 25.276987, longitude: 55.296249)

    init(initialCoordinate: CLLocationCoordinate2D? = nil,
         onPick: @escaping (_ address: String, _ latitude: String, _ longitude: String) -> Void,
         onCancel: @escaping () -> Void) {
        self.initialCoordinate = initialCoordinate
        self.onPick = onPick
        self.onCancel = onCancel
        _region = State(initialValue: MKCoordinateRegion(
            center: initialCoordinate ?? Self.dubai,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
    }

    var body: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: "Pick-up location", onBack: onCancel)

            ZStack {
                Map(coordinateRegion: $region)
                    .ignoresSafeArea(edges: .horizontal)

                // The pin sits dead centre and never moves; the map moves beneath it.
                Image(systemName: "mappin")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(VendorTheme.negative)
                    .shadow(radius: 2)
                    // A pin's point is at its bottom, so it has to ride half its height above centre
                    // or it marks somewhere south of what the user aimed at.
                    .offset(y: -16)
                    .allowsHitTesting(false)
            }
            .onChange(of: region.center.latitude) { _ in scheduleGeocode() }
            .onChange(of: region.center.longitude) { _ in scheduleGeocode() }

            VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
                HStack(spacing: VendorTheme.Space.s) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(VendorTheme.textSecondary)
                    if isResolving {
                        Text("Finding address…")
                            .font(VendorTheme.Text.body)
                            .foregroundColor(VendorTheme.textSecondary)
                    } else {
                        Text(resolvedAddress.isEmpty ? "Move the map to set the pick-up point" : resolvedAddress)
                            .font(VendorTheme.Text.body)
                            .foregroundColor(resolvedAddress.isEmpty ? VendorTheme.textSecondary : VendorTheme.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 0)
                }

                Text(coordinateLabel)
                    .font(VendorTheme.Text.meta)
                    .foregroundColor(VendorTheme.textTertiary)

                Button(action: confirm) {
                    Text("Use this location")
                        .font(VendorTheme.Text.cardTitle)
                        .foregroundColor(VendorTheme.onAccent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, VendorTheme.Space.m)
                        .background(
                            RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                                .fill(VendorTheme.accent)
                        )
                }
                .buttonStyle(VendorPressStyle())
            }
            .padding(VendorTheme.Space.l)
            .background(VendorTheme.surface)
        }
        .navigationBarHidden(true)
        .onAppear(perform: scheduleGeocode)
    }

    /// Eight decimal places, matching the precision the backend stores (`pick_up_latitude` comes back
    /// as "0.00000000").
    private var coordinateLabel: String {
        String(format: "%.8f, %.8f", region.center.latitude, region.center.longitude)
    }

    private func confirm() {
        onPick(resolvedAddress,
               String(format: "%.8f", region.center.latitude),
               String(format: "%.8f", region.center.longitude))
    }

    /// Debounced: a pan fires `onChange` continuously, and `CLGeocoder` throttles a caller that asks
    /// too often — after which it returns errors rather than results.
    private func scheduleGeocode() {
        geocodeWorkItem?.cancel()
        isResolving = true
        let center = region.center
        let work = DispatchWorkItem { reverseGeocode(center) }
        geocodeWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: work)
    }

    private func reverseGeocode(_ coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, _ in
            DispatchQueue.main.async {
                isResolving = false
                guard let placemark = placemarks?.first else { return }
                // Failure is not surfaced: the coordinates are the part that matters and they are
                // always valid. A blank address is better than an error over a working pin.
                resolvedAddress = [placemark.name,
                                   placemark.locality,
                                   placemark.administrativeArea,
                                   placemark.country]
                    .compactMap { $0 }
                    .reduce(into: [String]()) { unique, part in
                        if !unique.contains(part) { unique.append(part) }
                    }
                    .joined(separator: ", ")
            }
        }
    }
}
