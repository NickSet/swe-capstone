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
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet var destinationDistanceLabel: UILabel!
    @IBOutlet var destinationView: UIView!
    
    var locationManager = CLLocationManager()
    var arrowNode = SCNNode()
    var lightNode = SCNNode()
    let graph = DataManager.shared
    var path = [NavigationLocation]()
    var pathFinding = false
    var staticDistance = 0.0
    
    var destination = NavigationLocation(lat: 0.0, lng: 0.0, name: "", id: -1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingIndicator.startAnimating()
        
        sceneView.delegate = self
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.delegate = self
        locationManager.distanceFilter = kCLLocationAccuracyBestForNavigation
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
        let arrowScene = SCNScene(named: "art.scnassets/arrow.scn")!
        arrowNode = arrowScene.rootNode.childNode(withName: "arrow", recursively: true)!
        arrowNode.position = SCNVector3Make(0.0, -1.0, -3.2)
        sceneView.pointOfView?.addChildNode(arrowNode)
        
        arrowNode.isHidden = true
        
        setupSideMenu()
        
        var nodesDict = [String: [String: Any]]()
        var edgesDict = [String: [String: Any]]()
        graph.fetchNodes(completionHandler: { nodes in
            nodesDict = nodes!
            self.graph.fetchEdges(completionHandler: { edges in
                edgesDict = edges!
                self.graph.convertToNavigationLocations(nodes: nodesDict, edges: edgesDict)
                self.loadingIndicator.stopAnimating()
                self.loadingIndicator.isHidden = true
                self.graph.initBuildingsArray()
            })
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravity
        sceneView.session.run(configuration)
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
        if self.presentedViewController == nil {
            sceneView.session.pause()
        }
    }
    
    func setupSideMenu() {
        SideMenuManager.default.menuPresentMode = .menuSlideIn
        SideMenuManager.default.menuBlurEffectStyle = .none
        SideMenuManager.default.menuAnimationFadeStrength = 0.4
        SideMenuManager.default.menuWidth = view.frame.width * 0.7
        SideMenuManager.default.menuFadeStatusBar = false
    }
    
    func followPath(fromLocation loc: CLLocation) {
        let distance = Double(round(10 * loc.distance(from: CLLocation(latitude: path[0].latitude, longitude: path[0].longitude)))/10)
        if distance < 8.0 {
            //If the user is close to the next node in line, change position to that node.
            path.remove(at: 0)
            if path.count == 0 {
                pathFinding = false
                self.title = "Arrived"
                destinationView.isHidden = true
            }
        }
    
        if pathFinding {
            updateArrow()
            updateDistanceLabel(fromLocation: loc)
        }
}
    
func updateArrow() {
    if pathFinding {
        arrowNode.isHidden = false
    } else {
        arrowNode.isHidden = true
        return
    }

    guard let loc = locationManager.location?.coordinate else {
        return
    }
    guard let heading = locationManager.heading?.magneticHeading.toRadians() else {
        return
    }
    
    if path.isEmpty {
        arrowNode.isHidden = true
        return
    }
    
    arrowNode.eulerAngles = SCNVector3Make(0.0, 0.0, 0.0)
    
    let nextNode = CLLocationCoordinate2D(latitude: path[0].latitude, longitude: path[0].longitude)
    let bearing = loc.calculateBearing(to: nextNode)
    var direction = 0.0
    
    if heading < Double.pi {
        direction = heading + Double.pi - bearing
    } else {
        direction = heading - Double.pi - bearing
    }
    
    print("Bearing: \(bearing.toDegrees())")
    print("Heading: \(heading.toDegrees())")
    print("Direction: \(direction.toDegrees())")
    
    arrowNode.eulerAngles = SCNVector3Make(0.0, Float(direction), 0.0)
}
    
    @IBAction func unwindToARViewController(segue: UIStoryboardSegue) {
        if let sideMenuController = segue.source as? SideMenuNavigationTableViewController {
            destination = sideMenuController.selectedNavLoc
            self.title = destination.name
            let start = graph.findClosest(current: (locationManager.location?.coordinate)!, destination: destination)
            path = start.findPath(to: destination)
            staticDistance = Double(round(10 * (locationManager.location?.distance(from: CLLocation(latitude: path[0].latitude, longitude: path[0].longitude)))!)/10)
            pathFinding = true
            updateArrow()
        }
    }
    
    @IBAction func menuButtonTapped(sender: UIButton) {
        UIButton.animate(withDuration: 0.2, animations: {
            self.menuButton.transform = CGAffineTransform(scaleX: 0.93, y: 0.93)
        }, completion: { finish in
            UIButton.animate(withDuration: 0.2, animations: {
                self.menuButton.transform = CGAffineTransform.identity
            })
        })
        performSegue(withIdentifier: "LeftMenuControllerSegue", sender: nil)
    }
    
    func updateDistanceLabel(fromLocation: CLLocation) {
        destinationView.isHidden = false
        destinationDistanceLabel.text = "Destination: "
        let destinationDistance = Int(round(10 * fromLocation.distance(from: CLLocation(latitude: path.last!.latitude, longitude: path.last!.longitude)))/10 * 3.28084)
        destinationDistanceLabel.text! += "\(destinationDistance) feet"
    }
}

extension ARViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        updateArrow()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // If user is currently navigation to a location
        if pathFinding {
            //get the most recent reported user location
            guard let userLoc = locations.last else {
                return
            }
            followPath(fromLocation: userLoc)
        }
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

extension ARViewController: UISideMenuNavigationControllerDelegate {
    func sideMenuWillAppear(menu: UISideMenuNavigationController, animated: Bool) {
        UIView.animate(withDuration: 0.2, delay: 0.2, options: [], animations: {
            self.menuButton.alpha = 0.0
        }, completion: nil)
    }
    
    func sideMenuDidDisappear(menu: UISideMenuNavigationController, animated: Bool) {
        UIView.animate(withDuration: 0.3, animations: {
            self.menuButton.alpha = 1.0
        })
    }
}
