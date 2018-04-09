//used for fetching data from Firebase
//and converting JSON to custom types

import Firebase

func fetchData(){
	let ref: DatabaseReference!
	ref = Database.database().reference()
    
    ref.child("Graph").child("Nodes").observeSingleEvent(of: .value, with: { (snapshot) in

        guard let dictionary = snapshot.value as? [String: [String: Any]] else {
            return
        }
        convertToNavigationLocations(from: dictionary)
    }) { (error) in
        print(error.localizedDescription)
    }
}

func convertToNavigationLocations(from dict: [String: [String: Any]]) {
    for properties in dict.values {
        let id = properties["_id"] as! Int        
        let lat = properties["latitude"] as! Double
        let lng = properties["longitude"] as! Double
        let dsc = properties["description"] as! String
        let navLoc = NavigationLocation(lat: lat, lng: lng, name: dsc, id: id)
        
        print(navLoc)
    }
}

