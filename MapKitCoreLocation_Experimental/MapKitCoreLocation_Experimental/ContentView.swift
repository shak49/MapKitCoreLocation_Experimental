//
//  ContentView.swift
//  MapKitCoreLocation_Experimental
//
//  Created by Shak Feizi on 8/19/21.
//

import SwiftUI
import MapKit

struct ContentView: View {
    var body: some View {
        VStack {
            MapView()
            Button(action: {
                
            }, label: {
                Text("Show Direction")
            })
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}

struct MapView: UIViewRepresentable {
    typealias UIViewType = MKMapView
    
    // Here is the delegate function for view to know what and how to coordinate
    func makeCoordinator() -> MapViewCoordinator {
        return MapViewCoordinator()
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        
        mapView.delegate = context.coordinator
        
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 40.71, longitude: -74), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
        mapView.setRegion(region, animated: true)
        
        let newYork = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 40.71, longitude: -74))
        let boston = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 42.36, longitude: -71.05))
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: newYork)
        request.destination = MKMapItem(placemark: boston)
        request.transportType = .automobile
        
        let direction = MKDirections(request: request)
        direction.calculate { response, error in
            guard let routes = response?.routes.first else { return }
            mapView.addAnnotations([newYork, boston])
            mapView.addOverlay(routes.polyline)
            mapView.setVisibleMapRect(routes.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), animated: true)
            
        }
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
    }
    
    // It delegates for addOverlay(draw a polyline for route)
    class MapViewCoordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .blue
            renderer.lineWidth = 5
            return renderer
        }
    }
}
