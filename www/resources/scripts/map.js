var map;
var nodeRef = firebase.database().ref("Graph/Nodes/");
var edgeRef = firebase.database().ref("Graph/Edges/");

var nodeCount = 0;
var nodes;
var edges;
var paths = false;
var addingEdge = false;

var markers = [];
var infoWindows = [];

var nodesForEdge = [];
var edgeAddingWindow;

nodeRef.on("value", function(snapshot) {
	//Initial node query for all nodes
    nodes = snapshot.val();
	//Counts the number of objects stored in nodes
    nodeCount = Object.keys(nodes).length;
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
		var fNode
		var tNode
		
		//Both query paths written out to only grab from that node's path
		var fNodeRef = firebase.database().ref("Graph/Nodes/"+fromNode+'/');
		var tNodeRef = firebase.database().ref("Graph/Nodes/"+toNode+'/');
		
		//Setting up the queries for the from and to nodes
		fNodeRef.orderByKey().on("value", function(snapshot) {
		//Initial node query for all nodes matching fromNode
		fNode = snapshot.val();
		})
		tNodeRef.orderByKey().on("value", function(snapshot) {
		//Initial node query for all nodes matching toNode
		tNode = snapshot.val();
		})
		
		//Defining Google's polyline to assign it to the map
		var line = new google.maps.Polyline({
			path: [
				new google.maps.LatLng(fNode.latitude, fNode.longitude),
				new google.maps.LatLng(tNode.latitude, tNode.longitude)],
			//Edit the properties of the line with these
			strokeColor: "#FF0000",
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
    var nodeImage = new google.maps.MarkerImage('/resources/images/node.png',
        new google.maps.Size(30, 30),
        new google.maps.Point(0, 0),
        new google.maps.Point(15, 15));
	//Disable double click zoom because double click is used to create nodes
    map = new google.maps.Map(document.getElementById('map'), {
        center: loc, 
        zoom: 19,
        disableDoubleClickZoom: true
    });
	//i is the standard iterator for storing values in the markers[] and infoWindow[]
    var i = 0;
	//Looping through the nodes and attaching a marker at the lat and lng of each node
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
}

function saveEdge(fromNode, toNode) {
	//If radio button for stairs is checked, then set the value to true;
    let stairs = (document.getElementById("yes-stairs").value == 'true');
	
	var fNode
	var tNode
	if(fromNode == toNode){
		console.log("You can't have a node lead to itself");
	}
	
	//Both query paths written out to only grab from that node's path
	var fNodeRef = firebase.database().ref("Graph/Nodes/"+fromNode+'/');
	var tNodeRef = firebase.database().ref("Graph/Nodes/"+toNode+'/');
	
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
	var eWeight = Math.sqrt( (fNode.latitude - tNode.latitude)^2 + (fNode.longitude - tNode.longitude) );
	
    //get distance between nodes
    var edge = {
        _id: fromNode + toNode,
        from: fromNode,
        to: toNode,
        stairs: stairs,
        weight: eWeight
    };
    //Add edge to firebase
    edgeRef.child(edge._id).set(edge, function(err) {
        if (err) {
            console.warn(err);
        }
    });
}

function addSecondEdge(fromNode, index) {
    //Change infowWIndow of this node to have a check-box for if there are stairs
    var windowContent = `
        <div>
            <form>
                Stairs:<br>
                <input id="yes-stairs" type="radio" name="stairs" value="true">Yes
                <input id="no-stairs" type="radio" name="stairs" value="false">No
                <br>
                <button type="button" onclick="saveEdge('${fromNode._id}','${nodesForEdge[0]}')">Add Edge</button>
				<input type="hidden" name="toNode" value=${nodesForEdge[0]}>
            </form>
        </div>
    `;
	//Opening a new inforWindow at the clicked marker
    infoWindows[index] = new google.maps.InfoWindow({
        content: windowContent,
        position: markers[index].position
    });
    infoWindows[index].open(map, markers[index])
	//Setting all the values of the edges
    addingEdge = false;
    edgeAddingWindow.close();
}

function addFirstEdge(fromNode, index) {
    //Close the old InfoWindow
    infoWindows[index].close();
    //Copy the old value to use later
    var oldWindow = infoWindows[index]
    //Set the infoWindow for edge adding
    var windowContent = 'Click on a node to add the edge';
    infoWindows[index] = new google.maps.InfoWindow({
        content: windowContent,
        position: markers[index].position
    });
    infoWindows[index].open(map, markers[index])
    edgeAddingWindow = infoWindows[index];

    addingEdge = true;
    nodesForEdge[0] = fromNode;
    infoWindows[index] = oldWindow;

    /*
    edgeRef.child(edge._id).set(edge, function(err) {
        if (err) {
            console.warn(err);
        }
    });
    */
}

function addNode(lat, lng) {
	//Description of nodes grabbed by the infoWindow
    let desc = document.getElementById("node-description").value;
	//Grabbing the node count value, the node will be the n+1 node.
    let id = "node" + padToThree(nodeCount + 1);
	//The node values to be sent to the server are set, if description was not set then set description to _id
    let node = {
        _id: id,
        description: (desc != "") ? desc : id,
        latitude: lat,
        longitude: lng 
    };
	//Attempt to push the node to the server, if it fails throw a console warning
    nodeRef.child(node._id).set(node, function(err) {
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
                <button type="button" onclick="addNode(${lat}, ${lng})">Add Node</button>
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