import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as Path;

import '../pages/progressdialog.dart';

class SellingBinsWidget extends StatefulWidget {
  @override
  _SellingBinsWidgetState createState() => _SellingBinsWidgetState();
}

class _SellingBinsWidgetState extends State<SellingBinsWidget> {
  TextEditingController _landmarkController = TextEditingController();
  TextEditingController _gpsController = TextEditingController();
  TextEditingController _CompanyNameController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _employeesController = TextEditingController();
  TextEditingController _ghMobileNumberController = TextEditingController();
  TextEditingController _ghanaCardNumberController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> _bins = [];
  final _database = FirebaseDatabase.instance.ref();
  final _storage = FirebaseStorage.instance;
  List<Map<String, dynamic>> _pickupBins = [];
  List<Map<String, dynamic>> _sellingBins = [];
  bool _sellsBins = false;
  File? _logoFile;
  File? _CompRegFile;
  File? _registrationDocFile;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    // Ensure _bins is initialized and not null
    if (_bins == null) {
      _bins = [];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bin Types & Pricing',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ..._bins.map((bin) => binCard(bin)).toList(),
            addButton('Add Another Selling Bin', () {
              setState(() {
                _bins.add({'image': null, 'price': ''});
              });
            }),
          ],
        ),
        Column(
          children: [
            Container(
              height: height/1.7,
              width: 400,
              decoration: BoxDecoration(
                color: Color(0xFFE9EBED),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Column(
                children: [
//Company Name
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Container(
                      height: size.width / 7,
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(right: size.width / 30),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                        controller: _CompanyNameController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.business,
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                          hintMaxLines: 1,
                          hintText: 'Company Name',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),

                  //GPS ADDRESS
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Container(
                      height: size.width / 7,
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(right: size.width / 30),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                        controller: _gpsController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.location_searching_sharp,
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                          hintMaxLines: 1,
                          hintText: 'GPS Address',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),

                  //Location
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Container(
                      height: size.width / 7,
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(right: size.width / 30),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                        controller: _locationController,
                         decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.location_on,
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                          hintMaxLines: 1,
                          hintText: 'Location',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  submitButton()

                ],
              ),
            ),

          ],
        )
      ],
    );
  }

  Widget binCard(Map<String, dynamic> bin) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Image.asset(
              bin['image'] ?? "assets/images/choose.png",
              height: 100,
              width: 100,
            ),
            DropdownButtonFormField<String>(
              value: bin['image'] as String?,
              // Ensure type safety
              hint: Text('Select Bin Image'),
              items: [
                DropdownMenuItem(
                    child: Text('Borla Extra - 240L'),
                    value: 'assets/images/240L.png'),
                DropdownMenuItem(
                    child: Text('Borla General-140L'),
                    value: 'assets/images/140.png'),
                DropdownMenuItem(
                    child: Text('Borla Medium -100L'),
                    value: 'assets/images/100l.png'),
                DropdownMenuItem(
                    child: Text('Borla Bag'),
                    value: 'assets/images/plasticbag.png'),
              ],
              onChanged: (value) {
                setState(() {
                  bin['image'] = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a bin image';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Price for selected bin'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                bin['price'] = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a price';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _bins.remove(bin);
                });
              },
              child: Text('Remove Bin'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget addButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget submitButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _submitForm,
        child: Text('Submit'),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        ),
      ),
    );
  }

  void _submitForm() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog(
            message: "Adding, Please wait...",
          );
        });

    if (_formKey.currentState!.validate()) {
      User? user = _auth.currentUser;
      if (user != null) {
        String userId = user.uid;

        // Upload logo and registration document to Firebase Storage
        String? logoUrl;
        String? CompRegUrl;
        String? regDocUrl;

        if (_logoFile != null) {
          logoUrl = await uploadFile(_logoFile!, 'company_logos');
        }
        if (_CompRegFile != null) {
          CompRegUrl = await uploadFile(_CompRegFile!, 'Comp_reg');
        }
        if (_registrationDocFile != null) {
          regDocUrl =
              await uploadFile(_registrationDocFile!, 'registration_documents');
        }

        Map<String, dynamic> formData = {
          'WMSType': "BinSale",
          'sellsBins': _sellsBins,
          'sellingBins': _sellingBins,
          // 'CompanyType':
          'logoUrl': logoUrl,
          'BusinessCertUrl': CompRegUrl,
          'registrationDocUrl': regDocUrl,
          'landmark': _landmarkController.text.toString(),
          'location': _locationController.text.toString(),
          'employeesCount': _employeesController.text.toString(),
          'ghMobileNumber': _ghMobileNumberController.text.toString(),
          'ghanaCardNumber': _ghanaCardNumberController.text.toString(),
        };

        await _database
            .child('WMS')
            .child(userId)
            .child('wasteManagementInfo')
            .set(formData);

        Navigator.of(context).pop();
        Navigator.of(context).pushNamed("/SignIn");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Data submitted successfully')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('User not signed in')));
      }
    }
  }

  Future<String> uploadFile(File file, String folderName) async {
    Reference reference =
        _storage.ref().child('$folderName/${Path.basename(file.path)}');
    UploadTask uploadTask = reference.putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
}
