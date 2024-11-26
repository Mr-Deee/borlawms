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
 String? profileImageUrl;
   String? companyName;
   String ?directorName;
   String ?location;
   String ?landmark;
   int ?employeesCount;

  WMS({this.firstname,
    this.lastname,
    this.phone,
    this.email,
    this.profileImageUrl,
    this.companyName,
    this.directorName,
    this.location,
    this.landmark,
    this.employeesCount,
    this.id,
    this.automobile_color,
    this.automobile_model,
    this.plate_number,
    this.profilepicture,});

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
      // companyName: data['wasteManagementInfo']['CompanyName'],
      // directorName: data['wasteManagementInfo']['DirectorName'],
      // // location: data['wasteManagementInfo']['SoldBins']['location']??"",
      // landmark: data['wasteManagementInfo']['SolidBins']['landmark'],
      // employeesCount: data['wasteManagementInfo']['SolidBins']['employeesCount'],
    );
  }

  WMS? _riderInfo;

  WMS? get riderInfo => _riderInfo;

  void setRider(WMS wms) {
    _riderInfo = wms;
    notifyListeners();
  }
}
