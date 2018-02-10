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
        sceneView.debugOptions = ARSCNDebugOptions.showWorldOrigin
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.delegate = self
        locationManager.distanceFilter = kCLLocationAccuracyBest
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        //let arrowNode = createArrowNode()
        let arrowScene = SCNScene(named: "art.scnassets/arrow.dae")!
        let arrowNode = arrowScene.rootNode.childNode(withName: "arrow", recursively: true)!
        
        let loc = locationManager.location?.coordinate
        let bearing = loc?.calculateBearing(to: CLLocationCoordinate2D(latitude: 36.971542, longitude: -82.558492))
        
        arrowNode.position = SCNVector3(0.0, -1.0, 1.0)
        
        arrowNode.transform = SCNMatrix4Mult(arrowNode.transform, SCNMatrix4MakeRotation(Float(bearing!), 0.0, 1.0, 0.0))
        arrowNode.eulerAngles = SCNVector3Make(Float.pi/2, arrowNode.eulerAngles.y - Float.pi/2, 0.0)
        
        sceneView.scene = arrowScene
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
