// import 'dart:async';
//
// import 'package:location/location.dart';
//
// class LocationService {
//   UserLocation? currentUserLocation;
//   Location location = Location();
//   StreamController<UserLocation> _locationController = StreamController<UserLocation>.broadcast();
//
//   Future<UserLocation?> getLocation()async{
//     try {
//       var userLocation = await location.getLocation();
//       currentUserLocation = UserLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
//     }
//     catch(e)
//     {
//       print("Cannot find location with $e");
//     }
//     return currentUserLocation;
//   }
// }
//
// class UserLocation {
//   double? latitude;
//   double? longitude;
//
//   UserLocation({required this.latitude, required this.longitude});
// }
