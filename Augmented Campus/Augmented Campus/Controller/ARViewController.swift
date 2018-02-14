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
    @IBOutlet var menuButton: UIButton!
    
    var locationManager = CLLocationManager()
    var arrowNode = SCNNode()
    var lightNode = SCNNode()
    
    var currentCoord = CLLocationCoordinate2D()
    
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
        locationManager.startUpdatingHeading()
        
        let arrowScene = SCNScene(named: "art.scnassets/arrow.scn")!
        arrowNode = arrowScene.rootNode.childNode(withName: "arrow", recursively: true)!
        arrowNode.position = SCNVector3Make(0.0, -1.0, -2.8)
        sceneView.pointOfView?.addChildNode(arrowNode)
        
        arrowNode.isHidden = true
        
        setupSideMenu()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("ViewWillAppear()")
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravity

        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    func setupSideMenu() {
        SideMenuManager.default.menuPresentMode = .menuSlideIn
        SideMenuManager.default.menuBlurEffectStyle = .none
        SideMenuManager.default.menuAnimationFadeStrength = 0.4
        SideMenuManager.default.menuWidth = view.frame.width * 0.6
        SideMenuManager.default.menuFadeStatusBar = false
    }
    
    func updateNode(withHeading heading: Double) {
        arrowNode.eulerAngles = SCNVector3Make(0.0, 0.0, 0.0)
        
        if currentCoord != CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0) {
            arrowNode.isHidden = false
        }
        
        let loc = locationManager.location?.coordinate
        let bearing = loc!.calculateBearing(to: currentCoord)
        var direction = 0.0
        
        if heading < Double.pi {
            direction = heading + Double.pi + abs(bearing)
        } else {
            direction = heading - Double.pi + abs(bearing)
        }
        
        arrowNode.eulerAngles = SCNVector3Make(0.0, Float(direction), 0.0)
    }
    
    @IBAction func unwindToARViewController(segue: UIStoryboardSegue) {
        if let sideMenuController = segue.source as? SideMenuTableViewController {
            currentCoord = sideMenuController.selectedCoordinate
            self.title = sideMenuController.selectedDescription
            updateNode(withHeading: locationManager.heading!.magneticHeading.toRadians())
            
        }
    }
    
    @IBAction func menuButtonTapped(sender: UIButton) {
        performSegue(withIdentifier: "LeftMenuControllerSegue", sender: nil)
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
