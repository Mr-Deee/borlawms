import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

User? firebaseUser;


User? currentfirebaseUser;

class Users extends ChangeNotifier {
  String? id;
  String? email;
  String? firstname;
  String? lastname;
  String? profilepicture;
  String?phone;

  Users({
    this.id,
    this.email,
    this.firstname,
    this.lastname,
    this.profilepicture,
    this.phone,
  });

  static Users fromMap(Map<String, dynamic> map) {
    return Users(
      id:map['id'],
      email : map["email"],
      firstname : map["Username"],
      lastname: map["lastName"],
      profilepicture: map["Profilepicture"].toString(),
      phone : map["phone"],

    );
  }

  Users? _userInfo;

  Users? get userInfo => _userInfo;

  void setUser(Users user) {
    _userInfo = user;
    notifyListeners();
  }
}



