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

/// The main view controller for the application. This controller is responsible for presenting the AR view, managing the user's location, and rendering our 3D arrow.
class ARViewController: UIViewController {
    
    /// The AR view that allows us to draw the arrow and display output from the user's camera
    @IBOutlet var sceneView: ARSCNView!
    /// A button to display the navigational menu.
    @IBOutlet var menuButton: UIButton!
    /// An indicator that remains on screen until FireBase data has been loaded
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    /// A text label that displays the distance from the user's location to their chosen destination.
    @IBOutlet var destinationDistanceLabel: UILabel!
    /// A view that houses the `destinationDistanceLabel` and it's red UIView background
    @IBOutlet var destinationView: UIView!
    
    /// A property to access the `CLLocationManager` properties and methods
    var locationManager = CLLocationManager()
    /// The 3D arrow that we draw and manipulate within the view.
    var arrowNode = SCNNode()
    /// A lighting node to show proper shadows on our `arrowNode`
    var lightNode = SCNNode()
    /// Singleton instance of the `DataManager` class
    let graph = DataManager.shared
    /// Array we will use to store the optimal path returned by the A* algorithm
    var path = [NavigationLocation]()
    /// Boolean to determine if we're currently in the process of following a path to a destination
    var pathFinding = false
    /// A property used when trying to recalculate path based on user deviation from optimal path. Currently not used.
    var staticDistance = 0.0
    
    /// A property to hold the user's chosen destination property.
    var destination = NavigationLocation(lat: 0.0, lng: 0.0, name: "", id: -1)
    
    /// Called after the controller's view is loaded into memory.
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
    
    /// Notifies the view controller that its view is about to be added to a view hierarchy.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravity
        sceneView.session.run(configuration)
    }
    
    /// Notifies the view controller that its view was added to a view hierarchy.
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    /// Notifies the view controller that its view is about to be removed from a view hierarchy.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
        if self.presentedViewController == nil {
            sceneView.session.pause()
        }
    }
    
    /// Setup the default values for the `SideMenuManager` class
    func setupSideMenu() {
        SideMenuManager.default.menuPresentMode = .menuSlideIn
        SideMenuManager.default.menuBlurEffectStyle = .none
        SideMenuManager.default.menuAnimationFadeStrength = 0.4
        SideMenuManager.default.menuWidth = view.frame.width * 0.7
        SideMenuManager.default.menuFadeStatusBar = false
    }
    
    /// Tracks and updates the `path` array as the user naviates to their destination. Responsible for calling `updateArrow` method.
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

    /// Orientates the arrow to point towards the next node in the `path` array
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
    
    /// Unwind segue called when `SideMenuNavigationalController` is dismissed. Allows passing the selection destination back to this controller for path finding and navigation.
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
    
    /// Called when the user taps on `menuButton`. Animates the dissapearance of the `menuButton` and performs the segue.
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
    
    /// Updates `destinationDistanceLabel` with current distance from user to destination in feet.
    func updateDistanceLabel(fromLocation: CLLocation) {
        destinationView.isHidden = false
        destinationDistanceLabel.text = "Destination: "
        let destinationDistance = Int(round(10 * fromLocation.distance(from: CLLocation(latitude: path.last!.latitude, longitude: path.last!.longitude)))/10 * 3.28084)
        destinationDistanceLabel.text! += "\(destinationDistance) feet"
    }
}

extension ARViewController: CLLocationManagerDelegate {
    /// Delegate method from `CoreLocation` library called whenever the user's heading is updated. Used to call the `updateArrow` method with the new heading.
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        updateArrow()
    }
    
    /// Delegate method from `CoreLocation` library called whenever the user's location is updated. Used to call the `followPath` method with the new location.
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
    /// If the session fails, present an arrow message to the user.
    func session(_ session: ARSession, didFailWithError error: Error) {

    }
    
    /// Inform the user that the session has been interrupted
    func sessionWasInterrupted(_ session: ARSession) {
        
    }
    /// Reset tracking and/or remove existing anchors if consistent tracking is required
    func sessionInterruptionEnded(_ session: ARSession) {
      
    }
}

extension ARViewController: UISideMenuNavigationControllerDelegate {
    /// Delegate method called when the sideMenu is about to appear. Used to hide the `menuButton`.
    func sideMenuWillAppear(menu: UISideMenuNavigationController, animated: Bool) {
        UIView.animate(withDuration: 0.2, delay: 0.2, options: [], animations: {
            self.menuButton.alpha = 0.0
        }, completion: nil)
    }
    
    /// Delegate method called when the sideMenu has disappeared. Used to reshow the `menuButton`.
    func sideMenuDidDisappear(menu: UISideMenuNavigationController, animated: Bool) {
        UIView.animate(withDuration: 0.3, animations: {
            self.menuButton.alpha = 1.0
        })
    }
}
