
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
	var edge = {
		toIndex: index,
		fromIndex: null,
		weight: null,
		stairs: null
    };
    
    var refDB = database.child('Graph/Edge/').push(edge, function(err) {
        if (err) {  // Data was not written to firebase.
              console.warn(err);
        }
    });
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
        var contentString = generateInfoWindow(value);

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

function generateInfoWindow(data) {
    const markup = `
    <div>
        <ul class="no-bullet">
            <li>
                <h3 id="node-name">${data.Description}</h3>
            </li>
            <li>
                ${Number(data.Latitude).toFixed(6)},  ${Number(data.Longitude.toFixed(6))}
            </li>
        </ul>
        <br>
        <h4>Edges</h4>
        <br><br><br>
        <button type="button" onclick="addEdge(${data.Index})">Add Edge</button>
    </div>
    `;
    return markup;
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
        window.location.href = 'index.html'; 
    }
});
