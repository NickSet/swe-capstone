var map;
var nodeRef = firebase.database().ref("Graph/Nodes/");
var edgeRef = firebase.database().ref("Graph/Edges/");

var nodeCount = 0;
var nodes;
var edges;
var addingEdge = false;

nodeRef.on("value", function(snapshot) {	
    nodes = snapshot.val();
    nodeCount = Object.keys(nodes).length;
    initMap(nodes);
}, function (error) {
    console.log("Error: " + error.code);
});

edgeRef.on("value", function(snapshot) {	
    edges = snapshot.val();
    //initPaths(edges);
}, function (error) {
    console.log("Error: " + error.code);
});



/*
function initPaths(edge) {
	//function to write edges
	
}
*/

function initMap(nodes) {
    var loc = {lat: 36.971643, lng: -82.558822}
    var nodeImage = new google.maps.MarkerImage('/resources/images/node.png',
        new google.maps.Size(30, 30),
        new google.maps.Point(0, 0),
        new google.maps.Point(15, 15));

    map = new google.maps.Map(document.getElementById('map'), {
        center: loc, 
        zoom: 19,
        disableDoubleClickZoom: true
    });

    for (const [key, value] of Object.entries(nodes)) {
        var contentString = generateDetailWindow(value);

		var infoWindow = new google.maps.InfoWindow({
			content: contentString
		});
        var latFloat = parseFloat(value.latitude);
        var lonFloat = parseFloat(value.longitude);

        var _marker = new google.maps.Marker({
            icon: nodeImage,
			position: {lat: latFloat, lng: lonFloat},
			map: map,
			title: value.description
        });

		google.maps.event.addListener(_marker, 'click',  (function(infoWindow) {
            if (addingEdge == true) {
                console.log("Adding edge");
            } else {
			    return function() {
				    infoWindow.open(map, this);
			    }
            }
		})
        (infoWindow));
    }

    map.addListener('dblclick', function(e) {
        let loc = {lat: e.latLng.lat(), lng: e.latLng.lng()};
        var windowContent = generateNodeCreationWindow(loc);
        var createNodeWindow = new google.maps.InfoWindow({
            content: windowContent,
            position: e.latLng
        })
        createNodeWindow.open(map);
    });
}

function addEdge(fromNode) {
    addingEdge = true;
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

function addNode(lat, lng) {
    let desc = document.getElementById("node-description").value;
    let id = "node" + (nodeCount + 1);
    let node = {
        _id: id,
        description: (desc != "") ? desc : id,
        latitude: lat,
        longitude: lng 
    };

    nodeRef.child(node._id).set(node, function(err) {
        if (err) {
            console.warn(err);
        }
    });
}

function generateNodeCreationWindow(coords) {
    let lat = coords.lat;
    let lng = coords.lng;
    const markup = `
        <div>
            <form>
                Description:<br>
                <input id="node-description" type="text" name="description"><br>
                <br>
                <button type="button" onclick="addNode(${lat}, ${lng}, ${nodeCount})">Add Node</button>
            </form>
        </div>
    `;
    return markup;
}

function generateDetailWindow(node) {
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
