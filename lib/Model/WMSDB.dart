import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/cupertino.dart';

class WMS extends ChangeNotifier
{
  String?firstname;
  String?lastname;
  String?phone;
  String?email;
  String?id;
  String?automobile_color;
  String? automobile_model;
  String?plate_number;
  String?profilepicture;

  WMS({this.firstname, this.lastname,this.phone, this.email, this.id, this.automobile_color, this.automobile_model, this.plate_number, this.profilepicture,});

  static WMS fromMap(Map<String, dynamic> data)

  {
    //var data= dataSnapshot.value;
    return WMS(
      id: data['uid'],
      phone: data["phone"],
      email: data["email"],
      firstname: data["Username"],
      // lastname: data["LastName"],
      profilepicture: data["riderImageUrl"],
      // automobile_color: data["car_details"]["automobile_color"],
      // automobile_model: data["car_details"]["motorBrand"],
      //  plate_number:data["car_details"]["licensePlateNumber"],
    );
  }

  WMS? _riderInfo;

  WMS? get riderInfo => _riderInfo;

  void setRider(WMS wms) {
    _riderInfo = wms;
    notifyListeners();
  }
}
