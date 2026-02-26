//  MapView.swift
import SwiftUI
import MapKit
struct MapView: View {
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 25.276987, longitude: 55.296249), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    var body: some View {
        Map(coordinateRegion: $region)
            .navigationTitle("Location")
    }
}
