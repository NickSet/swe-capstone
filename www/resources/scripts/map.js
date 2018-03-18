var map;
var database = firebase.database();

function initMap() {
    map = new google.maps.Map(document.getElementById('map'), {
        center: {lat: 36.971407, lng: -82.559159},
        zoom: 19
    });
}

firebase.auth().onAuthStateChanged(function(user) {
    if (user) {
        // User is authorized: Do nothing
    } else {
        window.location.href = 'login.html'; 
    }
});

