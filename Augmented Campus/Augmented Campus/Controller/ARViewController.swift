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
    
    var locationManager = CLLocationManager()
    var arrowNode = SCNNode()
    var lightNode = SCNNode()
    let graph = DataManager.shared
    var path = [NavigationLocation]()
    var pathFinding = false
    
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
        let userLocation = NavigationLocation(lat: (loc.coordinate.latitude), lng: (loc.coordinate.longitude), name: "", id: -1)
        
        if path.count == 1 {
            //Do arrived at destination stuff
            pathFinding = false
            self.title = "Finished"
        }
        if userLocation.cost(to: path[0]) < (17.6/36000) {
            //If the user is close to the next node in line, change position to that node.
            path.remove(at: 0)
        }
        else if userLocation.cost(to: path[1]) < (17.6/36000) {
            //If the user is close to the node after the next node in line, change position to that node.
            path.remove(at: 0)
            path.remove(at: 1)
        }
        if userLocation.cost(to: path[0]) > (path[0].cost(to: path[1])*1.17){
            //recalculate because user is farther from the end point than the distance from start -> next node * 1.17
            
            let newNode = graph.findClosest(current: loc.coordinate, destination: path[path.count-1])
            path = newNode.findPath(to: path[path.count-1])
        }
        addDebugInfo(fromLocation: loc)
}
    
    func updateArrow(withHeading heading: Double) {
        if pathFinding {
            arrowNode.isHidden = false
        } else {
            arrowNode.isHidden = true
        }
        arrowNode.eulerAngles = SCNVector3Make(0.0, 0.0, 0.0)
    
        guard let loc = locationManager.location?.coordinate else {
            return
        }
        if path.isEmpty {
            return
        }
        let temp = CLLocationCoordinate2D(latitude: path[0].latitude, longitude: path[0].longitude)
        let bearing = loc.calculateBearing(to: temp)
        var direction = 0.0
        
        if heading < Double.pi {
            direction = heading + Double.pi + abs(bearing)
        } else {
            direction = heading - Double.pi + abs(bearing)
        }
        
        arrowNode.eulerAngles = SCNVector3Make(0.0, Float(direction), 0.0)
    }
    
    @IBAction func unwindToARViewController(segue: UIStoryboardSegue) {
        if let sideMenuController = segue.source as? SideMenuNavigationTableViewController {
            
            destination = sideMenuController.selectedNavLoc
            self.title = destination.name
            let start = graph.findClosest(current: (locationManager.location?.coordinate)!, destination: destination)
            path = start.findPath(to: destination)
            pathFinding = true
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
    
    /// Setup and Display Debug Info
    @IBOutlet var nextLabel: UILabel!
    @IBOutlet var nextDistanceLabel: UILabel!
    @IBOutlet var destinationLabel: UILabel!
    @IBOutlet var destinationDistanceLabel: UILabel!
    
    func addDebugInfo(fromLocation: CLLocation) {
        nextLabel.isHidden = false
        nextDistanceLabel.isHidden = false
        destinationLabel.isHidden = false
        destinationDistanceLabel.isHidden = false
        
        nextLabel.text = "Next: "
        nextDistanceLabel.text = "Distance to Next: "
        destinationLabel.text = "Destination: "
        destinationDistanceLabel.text = "Distance to Dstn: "
        
        nextLabel.text! += path[0].name
        let nextDistance = Double(round(10 * fromLocation.distance(from: CLLocation(latitude: path[0].latitude, longitude: path[0].longitude)))/10)
        nextDistanceLabel.text! += "\(nextDistance) meters"
        destinationLabel.text! += path.last!.name
        let destinationDistance = Double(round(10 * fromLocation.distance(from: CLLocation(latitude: path.last!.latitude, longitude: path.last!.longitude)))/10)
        destinationDistanceLabel.text! += "\(destinationDistance) meters"
    }
}

extension ARViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        updateArrow(withHeading: newHeading.magneticHeading.toRadians())
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
