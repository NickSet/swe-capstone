
var data = {
    Description: null,
    Hash: null,
    Index: null,
    Latitude: null,
    Longitude: null
}; 

var nodeCount;
var map;
var database = firebase.database().ref();
var ref = firebase.database().ref("Graph/Node/");
var refEdge = firebase.database().ref("Graph/Edge");
var nodes;
var edges;

ref.on("value", function(snapshot) {	
    nodes = snapshot.val();
    initMap(nodes);
}, function (error) {
    console.log("Error: " + error.code);
});

/*
ref.on("value",function(snapshot) {
	edges = snapshot.val();
	initPaths(edges);
}, function (error) {
    console.log("Error: " + error.code);
});
//To be implemented with initPaths
*/

function addEdge(index) {
/*
	var edge = {
		toIndex: index,
		fromIndex: null,
		weight: null,
		stairs: null
	};
	console.log(index);
	return firebase.database().ref('/edge/').orderByChild('uid').equalTo(userUID).once('value').then(function(snapshot) {
	var username = snapshot.val().username;
});
//Currently has no way of knowing who called it
*/
};

/*
function initPaths(edge) {
	//function to write edges
	
}
*/

function initMap(nodes) {
    var loc = {lat: 36.971643, lng: -82.558822}
    map = new google.maps.Map(document.getElementById('map'), {
        center: loc, 
        zoom: 19
    });
	nodeCount = 0;
    for (const [key, value] of Object.entries(nodes)) {
      nodeCount += 1;
	  var contentString = '<div >'+
      '<ul class="noBullet" style="list-style: none;" > <li> <h3 id="NodeName">'+
	  value.Description+
	  '</h3> </li> <li>'+
      //'<br>'+
	  Number(value.Latitude).toFixed(6) +
	  ','+
	  Number(value.Longitude).toFixed(6)+
	  '</li> </div> <br> <h4> Edges <br>'+
	  //<ul> <li>+
	  //This is where edges go when implemented with a for loop
	  //'</li> </ul>
	  '<br> <br>'+
      '<button type="button" onclick="addEdge(value.Index);">Add Edge</button>';
	  //addEdge(value.Index) does not work, need to figure out another way to pass edge value to function
		var infoWindow = new google.maps.InfoWindow({
			content: contentString
		});
        var latFloat = parseFloat(value.Latitude);
        var lonFloat = parseFloat(value.Longitude);
        var _marker = new google.maps.Marker({
			position: {lat: latFloat, lng: lonFloat},
			map: map,
			title: value.Description
	    })
		console.log(nodeCount);
		
		google.maps.event.addListener(_marker, 'click',  (function(infoWindow) {
			return function() {
				infoWindow.open(map,this);
			}
		})
		(infoWindow));
	};
	
    map.addListener('click', function(e) {
          data.Latitude = parseFloat(e.latLng.lat());
          data.Longitude = parseFloat(e.latLng.lng());
          data.Description = "Testing Node";
          data.Index = nodeCount;
          data.Hash = data.Description.hashCode();
          addToFirebase(data);
    });
}

function addToFirebase(data) {
    var refDB = database.child('Graph/Node/').push(data, function(err) {
        if (err) {  // Data was not written to firebase.
              console.warn(err);
        }
    });
}

String.prototype.hashCode = function() {
    var hash = 0;
    if (this.length == 0) {
        return hash;
    }
    for (var i = 0; i < this.length; i++) {
        char = this.charCodeAt(i);
        hash = ((hash<<5)-hash)+char;
        hash = hash & hash; // Convert to 32bit integer
    }
    return hash;
}

firebase.auth().onAuthStateChanged(function(user) {
    if (user) {
        // User is authorized: Do nothing
    } else {
        window.location.href = 'login.html'; 
    }
});
