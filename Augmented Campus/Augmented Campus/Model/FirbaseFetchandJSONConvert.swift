//used for fetching data from Firebase
//and converting JSON to custom types

import Firebase

func fetchData(){
	let ref: DatabaseReference!
	ref = Database.database().reference()
    
    ref.child("Graph").child("Nodes").observeSingleEvent(of: .value, with: { (snapshot) in
        // Get user value
        let value = snapshot.value as? NSDictionary
        let value2 = Data(
        convertJSON(json: value2 as! Data)
        // ...
    }) { (error) in
        print(error.localizedDescription)
    }
}

//values for conversion?
func convertJSON(json: Data){
    let navObject = try? JSONDecoder().decode(NavigationLocation.self, from: json)
    
}
