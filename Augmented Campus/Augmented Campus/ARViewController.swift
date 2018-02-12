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
    var arrowNode = SCNNode()
    var lightNode = SCNNode()
    
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
        locationManager.startUpdatingHeading()
        
        let arrowScene = SCNScene(named: "art.scnassets/arrow.scn")!
        arrowNode = arrowScene.rootNode.childNode(withName: "arrow", recursively: true)!
        arrowNode.position = SCNVector3Make(0.0, -1.0, -2.8)
        sceneView.pointOfView?.addChildNode(arrowNode)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravity

        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    func updateNode(withHeading heading: Double) {
        let loc = locationManager.location?.coordinate
        let bearing = loc!.calculateBearing(to: CLLocationCoordinate2D(latitude: 36.971542, longitude: -82.558492))
        let direction = heading + bearing - Double.pi/2
        
        arrowNode.eulerAngles = SCNVector3Make(0.0, Float(direction), 0.0)
    }
    
}

extension ARViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        updateNode(withHeading: newHeading.magneticHeading.toRadians())
    }
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
