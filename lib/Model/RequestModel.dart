import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';



class ReqModel extends ChangeNotifier {
  String? key;
  String? id;
  String? email;
  String? clientname;
  String? lastname;
  String? profilepicture;
  String?  phone;


  ReqModel({
    this.email,
    this.clientname,
    this.lastname,
    this.phone,
    this.profilepicture,

  });



  ReqModel.fromSnapshot(DataSnapshot dataSnapShot) {
    id = dataSnapShot.key;
    var data;
    data=dataSnapShot.value;

    clientname=data["client_name"];
    // profilepicture=data["Profilepicture"].toString();
    // Description = data["Description"];
    // Education=data["Education Background"];
    // location=data["Location"];
    // Service=data["Service Type"];
    phone=data["client_phone"];

  }



  ReqModel? _otherinfo;

  ReqModel? get otherinfo => _otherinfo;

  void setotherUser(ReqModel oinfo) {
    _otherinfo = oinfo;
    notifyListeners();
  }
}
