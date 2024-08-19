import 'package:borlawms/pages/progressdialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:borlawms/pages/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_selector/file_selector.dart';

import '../widgets/RecycleForm.dart';
import '../widgets/WMSFORM.dart';

class WasteManagementForm extends StatefulWidget {
  @override
  _WasteManagementFormState createState() => _WasteManagementFormState();
}

class _WasteManagementFormState extends State<WasteManagementForm> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.reference();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final List<Map<String, dynamic>> _sellingBins = [];
  List<Map<String, dynamic>> _pickupBins = [];
  // bool _pickupBins = false;
  bool _sellsBins = false;
  File? _logoFile;
  File? _compRegFile;
  File? _registrationDocFile;
  final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _gpsController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _employeesController = TextEditingController();
  final TextEditingController _ghMobileNumberController = TextEditingController();
  final TextEditingController _ghanaCardNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return    Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              sectionTitle('Pickup Bins'),
                Padding(
                  padding: const EdgeInsets.only(left:2.0),
                  child: Text("Kindly Let us know the types of bins you "
                      "pickup and the price you charge, by tapping the '+' button",style: TextStyle(color: Colors.black54),),
                ),
                ..._pickupBins.map((bin) => binCard(bin, _pickupBins)),
                addButton('Add Another Pickup Bin', () {
                  setState(() {
                    _pickupBins.add({'image': null, 'price': ''});
                  });
                }),

                SizedBox(height: 20),
                sectionTitle('Company Details'),
                logoUploadButton(),
                BusinessReGUploadButton(),
                TextFormField(
                  decoration: InputDecoration(labelText: 'FullName'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter landmark';
                    }
                    return null;
                  },
                  controller: _fullnameController,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Landmark close to location'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter landmark';
                    }
                    return null;
                  },
                  controller: _landmarkController,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Location'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter location';
                    }
                    return null;
                  },
                  controller: _locationController,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'GPS Address'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter location';
                    }
                    return null;
                  },
                  controller: _gpsController,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Number of Employees'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter number of employees';
                    }
                    return null;
                  },
                  controller: _employeesController,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'GH Mobile Number'),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter GH mobile number';
                    }
                    return null;
                  },
                  controller: _ghMobileNumberController,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Ghana Card Number'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Ghana card number';
                    }
                    return null;
                  },
                  controller: _ghanaCardNumberController,
                ),
                SizedBox(height: 20),
                submitButton(),
              ],

          ),
        )
      )
    );

  }


  Widget logoUploadButton() {
    return Column(
      children: [
        if (_logoFile != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Image.file(
              _logoFile!,
              width: 100,
              height: 100,
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text("Upload Logo"),
                GestureDetector(
                  onTap: () async {
                    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setState(() {
                        _logoFile = File(pickedFile.path);
                      });
                    }
                  },
                  child: Container(child: Icon(Icons.drive_folder_upload)),
                ),
              ],
            ),
            Column(
              children: [
                Text("Upload"),
                GestureDetector(
                  onTap: () async {
                    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setState(() {
                        _logoFile = File(pickedFile.path);
                      });
                    }
                  },
                  child: Container(child: Icon(Icons.drive_folder_upload)),
                ),
              ],
            ),
          ],
        ),

      ],
    );
  }
  Widget BusinessReGUploadButton() {
    return Column(
      children: [
        if (_compRegFile != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Image.file(
              _compRegFile!,
              width: 100,
              height: 100,
            ),
          ),
        ElevatedButton(
          onPressed: () async {
            final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
            if (pickedFile != null) {
              setState(() {
                _compRegFile = File(pickedFile.path);
              });
            }
          },
          child: Text('Upload Business Registration'),
        ),
      ],
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

  Widget uploadButton(String text, File? file, Function(File) onFilePicked) {
    return Column(
      children: [
        if (file != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Image.file(
              file,
              width: 100,
              height: 100,
            ),
          ),
        ElevatedButton(
          onPressed: () async {
            final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
            if (pickedFile != null) {
              setState(() {
                onFilePicked(File(pickedFile.path));
              });
            }
          },
          child: Text(text),
        ),
      ],
    );
  }

  Widget textField(String label, TextEditingController controller, [TextInputType keyboardType = TextInputType.text]) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
      controller: controller,
      keyboardType: keyboardType,
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget binCard(Map<String, dynamic> bin, List<Map<String, dynamic>> binsList) {
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
              value: bin['image'],
              hint: Text('Select Bin Image'),
              items: [
                DropdownMenuItem(child: Text('Borla Extra - 240L'), value: 'assets/images/240L.png'),
                DropdownMenuItem(child: Text('Borla General-140L'), value: 'assets/images/140.png'),
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
                  binsList.remove(bin);
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

  Widget submitButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _submitForm,
        child: Text('Submit'),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      User? user = _auth.currentUser;
      if (user != null) {
        String userId = user.uid;

        String? logoUrl;
        String? compRegUrl;
        String? registrationDocUrl;

        if (_logoFile != null) {
          logoUrl = await uploadFile(_logoFile!, 'CompanyLogo');
        }
        if (_compRegFile != null) {
          compRegUrl = await uploadFile(_compRegFile!, 'CompanyRegistration');
        }
        if (_registrationDocFile != null) {
          registrationDocUrl = await uploadFile(_registrationDocFile!, 'BusinessRegistration');
        }

        Map<String, dynamic> formData = {
          'pickupBins': _pickupBins,
          'fullname': _fullnameController,
          'sellsBins': _sellsBins,
          'sellingBins': _sellingBins,
          'logoUrl': logoUrl,
          'compRegUrl': compRegUrl,
          'registrationDocUrl': registrationDocUrl,
          'gps': _gpsController,
          'landmark': _landmarkController.text,
          'location': _locationController.text,
          'employees': _employeesController.text,
          'ghMobileNumber': _ghMobileNumberController.text,
          'ghanaCardNumber': _ghanaCardNumberController.text,
        };

        await _database.child('WasteManagement').child(userId).child('wasteManagementInfo').set(formData);

        Navigator.of(context).pop();
        Navigator.of(context).pushNamed("/SignIn");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data submitted successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User not signed in')));
      }
    }
  }

  Future<String> uploadFile(File file, String folderName) async {
    Reference reference = _storage.ref().child('$folderName/${Path.basename(file.path)}');
    UploadTask uploadTask = reference.putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
}