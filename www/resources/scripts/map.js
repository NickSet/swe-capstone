var map;
var nodeRef = firebase.database().ref("Graph/Nodes/");
var edgeRef = firebase.database().ref("Graph/Edges/");
var baseRef = firebase.database().ref("Graph");
var indexRef = firebase.database().ref("Graph/index");

var nodeCount = 0;
var nodes;
var edges;
var paths = false;
var addingEdge = false;

var markers = [];
var infoWindows = [];

var nodesForEdge = [];
var edgeAddingWindow;


indexRef.on("value", function(snapshot) {
    nodeCount = snapshot.val();
});

nodeRef.on("value", function(snapshot) {
	//Initial node query for all nodes
    nodes = snapshot.val();
	//Counts the number of objects stored in nodes
    initMap(nodes);
}, function (error) {
    console.log("Error: " + error.code);
});

edgeRef.on("value", function(snapshot) {
	//Initial edge query for all edges
    edges = snapshot.val();
    initPaths(edges);
	paths = true;
}, function (error) {
    console.log("Error: " + error.code);
});

function padToThree(number) {
  if (number<=999) { number = ("00"+number).slice(-3); }
  return number;
}


function initPaths(edge) {
	//function to write edges
	for (const [key, value] of Object.entries(edge)) {
		
        var fromNode = value.from;
        var toNode = value.to;
        var stairs = value.stairs;
		var fNode
		var tNode
		
		var fNodeName = "node"+padToThree(fromNode);
		var tNodeName = "node"+padToThree(toNode);
	
		var fNodePath = "Graph/Nodes/"+fNodeName+'/';
		var tNodePath = "Graph/Nodes/"+tNodeName+'/';
		
		//Both query paths written out to only grab from that node's path
		var fNodeRef = firebase.database().ref(fNodePath);
		var tNodeRef = firebase.database().ref(tNodePath);
		
		//Setting up the queries for the from and to nodes
		fNodeRef.orderByKey().on("value", function(snapshot) {
		//Initial node query for all nodes matching fromNode
		fNode = snapshot.val();
		})
		tNodeRef.orderByKey().on("value", function(snapshot) {
		//Initial node query for all nodes matching toNode
		tNode = snapshot.val();
		})
        
        //Set color of edge depending on stairs boolean
        let color = stairs ? "#FF0000" : "#9B51E0";

		//Defining Google's polyline to assign it to the map
		var line = new google.maps.Polyline({
			path: [
				new google.maps.LatLng(fNode.latitude, fNode.longitude),
				new google.maps.LatLng(tNode.latitude, tNode.longitude)],
			//Edit the properties of the line with these
			strokeColor: color,
			strokeOpacity: 1.0,
			strokeWeight: 4,
			geodesic: true,
			map: map
		});
		//Adding the line to the map
		
    }
	
}


function initMap(nodes) {
    var loc = {lat: 36.971643, lng: -82.558822}
	//Override the google marker with custom marker google and set its size
    var nodeImage = new google.maps.MarkerImage('/resources/images/node_z19.png',
        new google.maps.Size(20, 20),
        new google.maps.Point(0, 0),
        new google.maps.Point(10, 10));
	//Disable double click zoom because double click is used to create nodes
    map = new google.maps.Map(document.getElementById('map'), {
        center: loc, 
        zoom: 19,
		mapTypeId: 'satellite',
        disableDoubleClickZoom: true
    });
	//i is the standard iterator for storing values in the markers[] and infoWindow[]
    var i = 0;
	//Looping through the nodes and attaching a marker at the lat and lng of each node
    for (const [key, value] of Object.entries(nodes)) {
        var contentString = generateDetailWindow(value, i);

		var detailInfoWindow = new google.maps.InfoWindow({
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
        infoWindows[i] = detailInfoWindow;

		google.maps.event.addListener(markers[i], 'click',  function() {
            if (addingEdge == true) {
                addSecondEdge(value, this.index);
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
	if(paths){
		initPaths(edges);
    };
    
    map.addListener('zoom_changed', function() {
        let zoom = map.zoom;
        var nodeImage;
        switch (zoom) {
            case 17:
                nodeImage = new google.maps.MarkerImage('/resources/images/node_z17.png',
                    new google.maps.Size(12, 12),
                    new google.maps.Point(0, 0),
                    new google.maps.Point(6, 6));
                break;
            case 18:
                nodeImage = new google.maps.MarkerImage('/resources/images/node_z18.png',
                    new google.maps.Size(16, 16),
                    new google.maps.Point(0, 0),
                    new google.maps.Point(8, 8));
                break;
            case 19:
                nodeImage = new google.maps.MarkerImage('/resources/images/node_z19.png',
                    new google.maps.Size(20, 20),
                    new google.maps.Point(0, 0),
                    new google.maps.Point(10, 10));
                break;
            case 20:
                nodeImage = new google.maps.MarkerImage('/resources/images/node_z20.png',
                    new google.maps.Size(22, 22),
                    new google.maps.Point(0, 0),
                    new google.maps.Point(11, 11));
                break;
            default:
                nodeImage = new google.maps.MarkerImage('/resources/images/node_z17.png',
                    new google.maps.Size(12, 12),
                    new google.maps.Point(0, 0),
                    new google.maps.Point(6, 6));
                break;
 
        }

        for (var i = 0; i < markers.length; i++) {
            markers[i].setIcon(nodeImage);
        }
    });
}


function saveEdge(fromNode, toNode, index, iwIndex) {
	//If radio button for stairs is checked, then set the value to true;
    let hasStairs = (document.getElementById("yes-stairs").checked);

	//The helper box telling them to click another node is closed
	markers[index].infoWindow.close();

	var fNode
	var tNode
	if(fromNode == toNode){
		console.log("You can't have a node lead to itself");
	}
	var fNodeName = "node"+padToThree(fromNode);
	var tNodeName = "node"+padToThree(toNode);
	
	var fNodePath = "Graph/Nodes/"+fNodeName+'/';
	var tNodePath = "Graph/Nodes/"+tNodeName+'/';
	
	
	//Both query paths written out to only grab from that node's path
	var fNodeRef = firebase.database().ref(fNodePath);
	var tNodeRef = firebase.database().ref(tNodePath);
	
	//Both queries written to only search down the specific node's tree
	fNodeRef.orderByKey().on("value", function(snapshot) {
	//Initial node query for all nodes matching fromNode
		fNode = snapshot.val();
	})
	tNodeRef.orderByKey().on("value", function(snapshot) {
	//Initial node query for all nodes matching toNode
		tNode = snapshot.val();
	})
	
    //Finally calculating the value using compute distance between
    var deltaLat = fNode.latitude - tNode.latitude;
    var deltaLng = fNode.longitude - tNode.longitude;
    var eWeight = Math.sqrt( Math.pow(deltaLat, 2) + Math.pow(deltaLng, 2));
	
	//Sets the original Edge1
    var edge1 = {
        _id: fNodeName + '_' + tNodeName,
        from: fromNode,
        to: toNode,
        stairs: hasStairs,
        weight: eWeight
    };
	
	//Sets the Reverse of Edge1
    var edge2 = {
        _id: tNodeName + '_' + fNodeName,
        from: toNode,
        to: fromNode,
        stairs: hasStairs,
        weight: eWeight
    };
	
    //Add first edge to firebase
    edgeRef.child(edge1._id).set(edge1, function(err) {
        if (err) {
            console.warn(err);
        }
    });

    //Add second edge to firebase
    edgeRef.child(edge2._id).set(edge2, function(err) {
        if (err) {
            console.warn(err);
        }
    });
}

function addSecondEdge(fromNode, index) {
    var oldWindow= infoWindows[index];
    infoWindows[index].close();
    //Change infowWIndow of this node to have a check-box for if there are stairs
    var windowContent = `
        <div>
            <form>
                Stairs:<br>
                <input id="yes-stairs" type="radio" name="stairs" value="true">Yes
                <input id="no-stairs" type="radio" name="stairs" value="false" checked>No
                <br>
                <button type="button" onclick="saveEdge(${fromNode._id}, ${nodesForEdge[0]}, ${nodesForEdge[1]}, ${index})">Add Edge</button>
				<input type="hidden" name="toNode" value=${nodesForEdge[0]}>
            </form>
        </div>
    `;

    //Opening a new infoWindow at the clicked marker
    infoWindows[index] = new google.maps.InfoWindow({
        content: windowContent,
    });
    
    infoWindows[index].open(map, markers[index]);
    infoWindows[index] = oldWindow;
	//Setting all the values of the edges
    addingEdge = false;
}

function addFirstEdge(fromNode, index) {
    //Close the old InfoWindow
    infoWindows[index].close();
    //Copy the old value to use later
    var oldWindow = infoWindows[index];
    //Set the infoWindow for edge adding
    var windowContent = 'Click on a node to add the edge';
    markers[index].infoWindow = new google.maps.InfoWindow({
        content: windowContent,
    });
    markers[index].infoWindow.open(map, markers[index]);
    addingEdge = true;
    nodesForEdge[0] = fromNode;
	nodesForEdge[1] = index;
    markers[index].infoWindow.content = oldWindow;
}

function saveNode(lat, lng) {
	//Description of nodes grabbed by the infoWindow
    let desc = document.getElementById("node-description").value;
	//Grabbing the node count value, the node will be the n+1 node.
	nodeCount = parseInt(nodeCount) + 1;
    let id = nodeCount;
	//The node values to be sent to the server are set, if description was not set then set description to the node Name
    let node = {
        _id: id,
        description: (desc != "") ? desc : "node"+padToThree(id),
        latitude: lat,
        longitude: lng 
    };
	indexRef.set(nodeCount, function(err) {
		if (err) {
			console.warn(err);
		}
	});
	//Attempt to push the node to the server, if it fails throw a console warning
    nodeRef.child("node"+ padToThree(node._id)).set(node, function(err) {
        if (err) {
            console.warn(err);
        }
    });
}

function deleteNodeBox(node, index){
	infoWindows[index].close();
	
	var oldWindow = infoWindows[index];
    //Set the infoWindow for edge adding
    const windowContent  = `
        <div>
            <form>
                Delete: ${markers[index].title}
                <br>
                <button type="button" onclick="deleteNode('${node}')">Delete</button>
            </form>
        </div>
    `;
    markers[index].infoWindow = new google.maps.InfoWindow({
        content: windowContent,
        position: markers[index].position
    });
	markers[index].infoWindow.open(map, markers[index]);
	
    markers[index].infoWindow.content = oldWindow;
}

function deleteNode(nodeId){
	//Variable for deleting nodes
	var emptyNode = {
			_id: null,
			description: null,
			latitude: null,
			longitude: null
	}
	//Variable to deleting edges
	var emptyEdge = {
        _id: null,
        from: null,
        to: null,
        stairs: null,
        weight: null
	}
	//Looping through all the edges, since we still have access to the values
	//of all the edges
	for (const [key, value] of Object.entries(edges)) {
		//If a edge value has the node _id in the to or from, remove the edge
		//from the to be deleted node
		if(value.from == nodeId || value.to == nodeId){
				edgeRef.child(value._id).set(emptyEdge, function(err) {
				if (err) {
					console.warn(err);
				}
			});
		}	
    }
	nodeRef.child("node"+padToThree(nodeId)).set(emptyNode, function(err) {
        if (err) {
            console.warn(err);
        }
    });
}

function generateNodeCreationWindow(coords) {
	//Storing the values for the lat and lng for the coordinates double clicked
    let lat = coords.lat;
    let lng = coords.lng;
	//The contents of the infoWindow in a markup
    const markup = `
        <div>
            <form>
                Description:<br>
                <input id="node-description" type="text" name="description"><br>
                <br>
                <button type="button" onclick="saveNode(${lat}, ${lng})">Add Node</button>
            </form>
        </div>
    `;
    return markup;
}

function generateDetailWindow(node, index) {
	//Markup for the standard click-on-marker infoWindow
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
		<button type="button" onclick="deleteNodeBox('${node._id}', ${index})">Delete Node</button>
    </div>
    `;
    return markup;
}

function generateDetailEdges(node, index) {
	var nodeConnections;
	/*
	for (const [key, value] of Object.entries(edges)) {
		if(value.from == node)
		{
		}
		
	}
	*/
	edgeRef.orderByChild("from").equalTo("node"+padToThree(node._id)).on("child_added", function(snapshot) {
		console.log(snapshot.key);
	});
	
}

firebase.auth().onAuthStateChanged(function(user) {
    if (user) {
        // User is authorized: Do nothing
    } else {
        window.location.href = 'index.html'; 
    }
});