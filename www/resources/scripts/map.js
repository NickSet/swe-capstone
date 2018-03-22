var node = {
    _id: "",
    description: "",
    latitude: 0,
    longitude: 0
};

var nodeCount;
var map;
var nodeRef = firebase.database().ref("Graph/Nodes/");
var edgeRef = firebase.database().ref("Graph/Edges/");
var nodes;
var edges;

nodeRef.on("value", function(snapshot) {	
    nodes = snapshot.val();
    initMap(nodes);
}, function (error) {
    console.log("Error: " + error.code);
});

edgeRef.on("value", function(snapshot) {	
    edges = snapshot.val();
    //initMap(nodes);
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

function addEdge(fromNode) {
    var edge = {
        _id: "node1node2",
        from: fromNode,
        to: "node2",
        stairs: false,
        weight: 100 
    };

    edgeRef.child(edge._id).set(edge, function(err) {
        if (err) {
            console.warn(err);
        }
    });
}

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
        var latFloat = parseFloat(value.latitude);
        var lonFloat = parseFloat(value.longitude);

        var nodeImage = new google.maps.MarkerImage('/resources/images/node.png',
                new google.maps.Size(30, 30),
                new google.maps.Point(0, 0),
                new google.maps.Point(15, 15));
        var _marker = new google.maps.Marker({
            icon: nodeImage,
			position: {lat: latFloat, lng: lonFloat},
			map: map,
			title: value.description
	    })
		
		google.maps.event.addListener(_marker, 'click',  (function(infoWindow) {
			return function() {
				infoWindow.open(map,this);
			}
		})
		(infoWindow));
	};
	
    map.addListener('click', function(e) {
          node._id = "node" + ++nodeCount;
          node.latitude = parseFloat(e.latLng.lat());
          node.longitude = parseFloat(e.latLng.lng());
          node.description = "Testing Node";
          addToFirebase(node);
    });
}

function addToFirebase(node) {
    nodeRef.child(node._id).set(node, function(err) {
        if (err) {
            console.warn(err);
        }
    });
}

function generateInfoWindow(node) {

    const markup = `
    <div>
        <ul class="no-bullet">
            <li>
                <h3 id="node-name">${node.description}</h3>
            </li>
            <li>
                ${Number(node.latitude).toFixed(6)},  ${Number(node.longitude).toFixed(6)}
            </li>
        </ul>
        <br>
        <h4>Edges</h4>
        <br><br><br>
        <button type="button" onclick="addEdge('${node._id}')">Add Edge</button>
    </div>
    `;
    return markup;
}

firebase.auth().onAuthStateChanged(function(user) {
    if (user) {
        // User is authorized: Do nothing
    } else {
        window.location.href = 'index.html'; 
    }
});
