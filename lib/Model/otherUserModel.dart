import 'package:flutter/cupertino.dart';

class  otherUsermodel  extends ChangeNotifier{

  String? Description;
  String? Education;
  String? location;
  String? Experience;
  String? Service;
  String? Institution;

  otherUsermodel({
    this.Description,
    this.Education,
    this.location,
    this.Experience,
    this.Institution,

    this. Service,
    // /this.phone,
  });


  static otherUsermodel fromMap(Map<String, dynamic> map) {
    return otherUsermodel(
      Description: map["Description"],
      Education: map["Education Background"],
      Experience: map["Experience"],
      location: map["Location"],
      Institution: map["Institution"],
      Service: map["Service Type"],
      //  phone : map["phone"],

    );
  }

  otherUsermodel? _otherinfo;

  otherUsermodel? get otherinfo => _otherinfo;

  void setotherUser(otherUsermodel oinfo) {
    _otherinfo = oinfo;
    notifyListeners();
  }
}