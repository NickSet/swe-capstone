
var data = {
    Description: null,
    Hash: null,
    Index: null,
    Latitude: null,
    Longitude: null
}; 

var nodeCount = 0;
var map;
var database = firebase.database().ref();
var ref = firebase.database().ref("Graph/Node/");
var nodes

ref.on("value", function(snapshot) {
    nodes = snapshot.val();
    initMap(nodes)
}, function (error) {
    console.log("Error: " + error.code);
});

function initMap(nodes) {
    var loc = {lat: 36.971643, lng: -82.558822}
    map = new google.maps.Map(document.getElementById('map'), {
        center: loc, 
        zoom: 19
    });
   for (const [key, value] of Object.entries(nodes)) {
       nodeCount += 1;
       var latFloat = parseFloat(value.Latitude);
       var lonFloat = parseFloat(value.Longitude);
       var marker = new google.maps.Marker({
           position: {lat: latFloat, lng: lonFloat},
           map: map
    })};

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
