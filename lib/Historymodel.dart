import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

class History extends ChangeNotifier
{
  String? paymentMethod;
  String? createdAt;
  String? status;
  String? fares;
  String? dropOff;
  String? pickup;

  History({this.paymentMethod, this.createdAt, this.status, this.fares, this.dropOff, this.pickup});

  History.fromSnapshot(DataSnapshot snapshot)
  {
    Map<String, dynamic> data = snapshot.value! as Map<String, dynamic>;


    paymentMethod = data["payment_method"];
    createdAt = data["created_at"];
    status = data["status"];
    fares = data["fares"];
    dropOff = data["finalClient_address"];
    pickup = data["Client_address"];
  }



  History? _userhistoryInfo;

  History? get userhistoryInfo => _userhistoryInfo;

  void setUser(History history) {
    _userhistoryInfo = history;
    notifyListeners();
  }
}


