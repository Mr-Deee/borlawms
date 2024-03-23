
import 'package:flutter/cupertino.dart';

import 'Historymodel.dart';
import 'address.dart';


class AppData extends ChangeNotifier {
  // TextEditingController pickUpTextEditingController =
  //     TextEditingController(); // PICK UP TEXT EDITING CONTROLLER(PROVIDER)
  // TextEditingController dropOffTextEditingController =
  //     TextEditingController(); // DROP OFF TEXT EDITING CONTROLLER(PROVIDER)
  late Address pickUpLocation,
      dropOffLocation; // PICK UP LOCATION AND DROP OFF LOCATION AS ADDRESS OBJECTS

  late String _pickUpLocationText;
  late String _dropOffLocationText;

  String get pickUpLocationText => _pickUpLocationText;
  String get dropOffLocationText => _dropOffLocationText;

  String earnings = "0"; // EARNINGS ???
  int countTrips = 0; // TRIP COUNT ??? NUMBER OF TRIPS TAKEN FOR USER
  List<String> tripHistoryKeys = []; // TRIP HISTORY KEYS
  List<History> tripHistoryDataList = []; // TRIP HISTORY DATA LIST

  void updatePickUpLocationAddress(Address pickUpAddress) {
    pickUpLocation = pickUpAddress;
    notifyListeners();
  }

  changePickupLocationAddress(String pickAddress) {
    _pickUpLocationText = pickAddress;
    notifyListeners();
  }


  void updateDropOffLocationAddress(Address dropOffAddress) {
    dropOffLocation = dropOffAddress;
    notifyListeners();
  }

  //history
  void updateEarnings(String updatedEarnings) {
    earnings = updatedEarnings;
    notifyListeners();
  }

  void updateTripsCounter(int tripCounter) {
    countTrips = tripCounter;
    notifyListeners();
  }

  void updateTripKeys(List<String> newKeys) {
    tripHistoryKeys = newKeys;
    notifyListeners();
  }

  void updateTripHistoryData(History eachHistory) {
    tripHistoryDataList.add(eachHistory);
    notifyListeners();
  }

  changeDropLocationAddress(String destination) {
    _dropOffLocationText = destination;
    notifyListeners();
  }


  get isVisible => _isVisible;
  bool _isVisible = false;
  
  set isVisible(value) {
    _isVisible = value;
    notifyListeners();
  }
}