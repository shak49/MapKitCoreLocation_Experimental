//
//  ContentView.swift
//  MapKitCoreLocation_Experimental
//
//  Created by Shak Feizi on 8/19/21.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @State private var directions: [String] = []
    @State private var showDirections = false
    
    var body: some View {
        VStack {
            MapView(directions: $directions)
            
            Button(action: {
                self.showDirections.toggle()
            }, label: {
                Text("Show Direction")
            })
            .disabled(directions.isEmpty)
            .padding()
        }.sheet(isPresented: $showDirections, content: {
            VStack {
                Text("Directions")
                    .font(.title2)
                    //.bold()
                    .padding()
                
                Divider().background(Color.blue)
                
                List {
                    ForEach(0..<self.directions.count, id: \.self) { i in
                        Text(self.directions[i])
                            .padding()
                    }
                }
            }
        })
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
    
    @Binding var directions: [String]
    
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
            
            self.directions = routes.steps.map { $0.instructions }.filter { !$0.isEmpty }
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
