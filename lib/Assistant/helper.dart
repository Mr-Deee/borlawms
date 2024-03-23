import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator/geolocator.dart' as geolocator; // or whatever name you want


class helper extends ChangeNotifier{



  Position? _currentPosition;
  String ?_currentAddress;

  String? get currentAddress=>_currentAddress;
  Position? get position=>_currentPosition;

  getCurrentLocation() {
    Geolocator
        .getCurrentPosition(desiredAccuracy: geolocator.LocationAccuracy.high, forceAndroidLocationManager: true)
        .then((Position position) {
          print("Location Gotten");
        _currentPosition = position;
        getAddressFromLatLng();
          notifyListeners();
          return _currentPosition;
    }).catchError((e) {
      print(e);
    });

  }



  getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition!.latitude,
          _currentPosition!.longitude
      );

      Placemark place = placemarks[0];


        _currentAddress = "${place.locality}, ${place.street}, ${place.subLocality} ${place.country}";


      notifyListeners();
      return _currentAddress;
    } catch (e) {
      print(e);
    }
  }


}