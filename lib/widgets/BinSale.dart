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
  TextEditingController _DirectorNameController = TextEditingController();
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
              height: height / 1.4,
              width: 400,
              decoration: BoxDecoration(
                color: Color(0xFFE9EBED),
                borderRadius: BorderRadius.circular(13),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: size.width / 7,
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(right: size.width / 30),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextFormField(
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.business,
                              color: Colors.grey,
                            ),
                            border: InputBorder.none,
                            hintMaxLines: 1,
                            hintText: 'Company Name',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter CompanyName';
                            }
                            return null;
                          },
                          controller: _CompanyNameController,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: size.width / 7,
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(right: size.width / 30),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextFormField(
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.person,
                              color: Colors.grey,
                            ),
                            border: InputBorder.none,
                            hintMaxLines: 1,
                            hintText: 'Director Name',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Director Name';
                            }
                            return null;
                          },
                          controller: _DirectorNameController,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: size.width / 7,
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(right: size.width / 30),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextFormField(
                          decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.landscape,
                                color: Colors.grey,
                              ),
                              border: InputBorder.none,
                              hintMaxLines: 1,
                              hintText: 'Landmark close to location'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter landmark';
                            }
                            return null;
                          },
                          controller: _landmarkController,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: size.width / 7,
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(right: size.width / 30),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextFormField(
                          decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.location_searching_outlined,
                                color: Colors.grey,
                              ),
                              border: InputBorder.none,
                              hintMaxLines: 1,
                              hintText: 'Location'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter location';
                            }
                            return null;
                          },
                          controller: _locationController,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: size.width / 7,
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(right: size.width / 30),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextFormField(
                          decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.gps_fixed,
                                color: Colors.grey,
                              ),
                              border: InputBorder.none,
                              hintMaxLines: 1,
                              hintText: 'GPS Address'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter location';
                            }
                            return null;
                          },
                          controller: _gpsController,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: size.width / 7,
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(right: size.width / 30),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextFormField(
                          decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.person_pin_circle_sharp,
                                color: Colors.grey,
                              ),
                              border: InputBorder.none,
                              hintMaxLines: 1,
                              hintText: 'Number of Employees'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter number of employees';
                            }
                            return null;
                          },
                          controller: _employeesController,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: size.width / 7,
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(right: size.width / 30),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextFormField(
                          decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.numbers,
                                color: Colors.grey,
                              ),
                              border: InputBorder.none,
                              hintMaxLines: 1,
                              hintText: 'Phone Number'),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter GH mobile number';
                            }
                            return null;
                          },
                          controller: _ghMobileNumberController,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: size.width / 7,
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(right: size.width / 30),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextFormField(
                          decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.numbers,
                                color: Colors.grey,
                              ),
                              border: InputBorder.none,
                              hintMaxLines: 1,
                              hintText: 'Ghana Card Number'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Ghana card number';
                            }
                            return null;
                          },
                          controller: _ghanaCardNumberController,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),


            submitButton(),
          ],
        ),
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
              borderRadius: BorderRadius.circular(10),

              value: bin['image'] as String?,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.border_inner,
                  color: Colors.grey,
                ),
                border: InputBorder.none,
                hintText: ('Select Bin Image'),),
              // Ensure type safety
              items: [
                DropdownMenuItem(child: Text('Borla Extra -660L'), value: 'assets/images/660l.png'),
                DropdownMenuItem(child: Text('Borla Plus - 360L'), value: 'assets/images/360l.png'),
                DropdownMenuItem(child: Text('Borla Large - 240L'), value: 'assets/images/240L.png'),
                DropdownMenuItem(child: Text('Borla Standard-140L'), value: 'assets/images/140.png'),
                DropdownMenuItem(child: Text('Borla Medium -100L'), value: 'assets/images/100l.png'),
                DropdownMenuItem(child: Text('Borla Bag'), value: 'assets/images/plasticbag.png'),
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
            Container(
              height: 69,
              alignment: Alignment.center,
              // padding: EdgeInsets.only(right: size.width / 30),30
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextFormField(
                decoration:  InputDecoration(
                  prefixIcon: Icon(
                    Icons.price_check,
                    color: Colors.grey,
                  ),
                  border: InputBorder.none,
                    hintText:  'Price for selected bin'


              ),
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
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // Ensure the button background is transparent
          shadowColor: Colors.transparent,     // Remove shadow to match the gradient container
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Match the container's border radius
          ),
        ),
        onPressed: _submitForm,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.lightGreenAccent], // Define the gradient colors
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            child: Text('Submit', style: TextStyle(color: Colors.white)),
          ),
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

        _database
            .child('WMS')
            .child(userId)
            .update({'detailsComp': true});

        Navigator.of(context).pop();
        Navigator.of(context).pushNamed("/SignIn");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Data submitted successfully')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('User not signed in')));
      }
    }

  final ImagePicker _imagePicker = ImagePicker();

  Widget logoUploadButton() {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Text("Upload Logo"),
              GestureDetector(
                onTap: () async {
                  final pickedFile =
                  await _imagePicker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _logoFile = File(pickedFile.path);
                    });
                  }
                },
                child: Container(
                  width: 100, // Set a fixed width for the image container
                  height: 105, // Set a fixed height for the image container
                  child: _logoFile != null
                      ? Image.file(_logoFile!) // Display the uploaded image
                      : Icon(Icons
                      .drive_folder_upload), // Display the icon if no image is uploaded
                ),
              ),
            ],
          ),
        ],
      )
    ]);
  }

  Future<String> uploadFile(File file, String folderName) async {
    Reference reference =
        _storage.ref().child('$folderName/${Path.basename(file.path)}');
    UploadTask uploadTask = reference.putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
}
