var map;
var nodeRef = firebase.database().ref("Graph/Nodes/");
var edgeRef = firebase.database().ref("Graph/Edges/");

var nodeCount = 0;
var nodes;
var edges;
var addingEdge = false;

var markers = [];
var infoWindows = [];

var nodesForEdge = [];

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

    var i = 0;
    for (const [key, value] of Object.entries(nodes)) {
        var contentString = generateDetailWindow(value, i);

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
        markers[i] = _marker;
        markers[i].index = i;
        infoWindows[i] = infoWindow;

		google.maps.event.addListener(markers[i], 'click',  function() {
            if (addingEdge == true) {
                console.log("Adding edge");
                addSecondEdge(value);
            } else {
				    infoWindows[this.index].open(map, markers[this.index]);
		    }
        });
        i++;
    }

    map.addListener('dblclick', function(e) {
        let loc = {lat: e.latLng.lat(), lng: e.latLng.lng()};
        var windowContent = generateNodeCreationWindow(loc);
        var createNodeWindow = new google.maps.InfoWindow({
            content: windowContent,
            position: e.latLng
        });
        createNodeWindow.open(map);
    });
}

function addSecondEdge(fromNode) {
    //Change infowWIndow of this node to have a checkbox for if there are stairs
    var edge = {

    };
    console.log(fromNode);
}

function addFirstEdge(fromNode, index) {
    //Close the old InfoWindow
    infoWindows[index].close();
    //Copy the old value to use later
    var oldWindow = infoWindows[index]
    //Set the infoWindow for edge adding
    var windowContent = 'Click on the a node to add the edge';
    infoWindows[index] = new google.maps.InfoWindow({
        content: windowContent,
        position: markers[index].position
    });
    infoWindows[index].open(map, markers[index])

    addingEdge = true;
    nodesForEdge[0] = fromNode;
    infoWindows[index] = oldWindow;
    /*
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
    */
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
                <button type="button" onclick="addNode(${lat}, ${lng})">Add Node</button>
            </form>
        </div>
    `;
    return markup;
}

function generateDetailWindow(node, index) {
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
        <button type="button" onclick="addFirstEdge('${node._id}', ${index})">Add Edge</button>
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
