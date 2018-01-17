//
//  ARViewController.swift
//  Augmented Campus
//
//  Created by Nicholas Setliff on 1/17/18.
//  Copyright © 2018 Nicholas Setliff. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreLocation

class ARViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!
    var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView.delegate = self
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.delegate = self
        locationManager.distanceFilter = kCLLocationAccuracyBest
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        let arrowNode = createArrowNode()
        let loc = locationManager.location?.coordinate
        let bearing = loc?.calculateBearing(to: CLLocationCoordinate2D(latitude: 36.971542, longitude: -82.558492))
        
        arrowNode.scale = SCNVector3(0.09, 0.09, 0.09)
        arrowNode.position = SCNVector3(0.0, -1.2, -1.4)
        arrowNode.transform = SCNMatrix4Mult(arrowNode.transform, SCNMatrix4MakeRotation(Float(bearing!), 0.0, 1.0, 0.0))
        
        sceneView.scene.rootNode.addChildNode(arrowNode)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func createArrowNode() -> SCNNode {
        let vertcount = 48;
        let verts: [Float] = [ -1.4923, 1.1824, 2.5000, -6.4923, 0.000, 0.000, -1.4923, -1.1824, 2.5000, 4.6077, -0.5812, 1.6800, 4.6077, -0.5812, -1.6800, 4.6077, 0.5812, -1.6800, 4.6077, 0.5812, 1.6800, -1.4923, -1.1824, -2.5000, -1.4923, 1.1824, -2.5000, -1.4923, 0.4974, -0.9969, -1.4923, 0.4974, 0.9969, -1.4923, -0.4974, 0.9969, -1.4923, -0.4974, -0.9969 ];
        
        let facecount = 13;
        let faces: [CInt] = [  3, 4, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 0, 1, 2, 3, 4, 5, 6, 7, 1, 8, 8, 1, 0, 2, 1, 7, 9, 8, 0, 10, 10, 0, 2, 11, 11, 2, 7, 12, 12, 7, 8, 9, 9, 5, 4, 12, 10, 6, 5, 9, 11, 3, 6, 10, 12, 4, 3, 11 ];
        
        let vertsData  = NSData(
            bytes: verts,
            length: MemoryLayout<Float>.size * vertcount
        )
        
        let vertexSource = SCNGeometrySource(data: vertsData as Data,
                                             semantic: .vertex,
                                             vectorCount: vertcount,
                                             usesFloatComponents: true,
                                             componentsPerVector: 3,
                                             bytesPerComponent: MemoryLayout<Float>.size,
                                             dataOffset: 0,
                                             dataStride: MemoryLayout<Float>.size * 3)
        
        let polyIndexCount = 61;
        let indexPolyData  = NSData( bytes: faces, length: MemoryLayout<CInt>.size * polyIndexCount )
        
        let element1 = SCNGeometryElement(data: indexPolyData as Data,
                                          primitiveType: .polygon,
                                          primitiveCount: facecount,
                                          bytesPerIndex: MemoryLayout<CInt>.size)
        
        let geometry1 = SCNGeometry(sources: [vertexSource], elements: [element1])
        
        let material1 = geometry1.firstMaterial!
        
        material1.diffuse.contents = UIColor(red: 0.15, green: 0.68, blue: 0.37, alpha: 1.0)
        material1.lightingModel = .lambert
        material1.transparency = 1.00
        material1.transparencyMode = .dualLayer
        material1.fresnelExponent = 1.00
        material1.reflective.contents = UIColor(white:0.00, alpha:1.0)
        material1.specular.contents = UIColor(white:0.00, alpha:1.0)
        material1.shininess = 0.75
        
        let node = SCNNode(geometry: geometry1)
        
        return node
    }

}

extension ARViewController: CLLocationManagerDelegate {
    
}

extension ARViewController: ARSCNViewDelegate {
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
