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
class Addwmsdetails extends StatefulWidget {
  const Addwmsdetails({super.key});

  @override
  State<Addwmsdetails> createState() => _AddwmsdetailsState();
}

TextEditingController _landmarkController = TextEditingController();
TextEditingController _locationController = TextEditingController();
TextEditingController _employeesController = TextEditingController();
TextEditingController _ghMobileNumberController = TextEditingController();
TextEditingController _ghanaCardNumberController = TextEditingController();
Uint8List? _registrationDocBytes;
class _AddwmsdetailsState extends State<Addwmsdetails> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _database = FirebaseDatabase.instance.reference();
  final _storage = FirebaseStorage.instance;
  List<Map<String, dynamic>> _pickupBins = [];
  List<Map<String, dynamic>> _sellingBins = [];
  bool _sellsBins = false;
  File? _logoFile;
  File? _CompRegFile;
  File? _registrationDocFile;
  Uint8List? _registrationDocBytes;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Waste Management Registration Form'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                sectionTitle('Pickup Bins'),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Kindly Let us know the types of bins you pickup and the price you charge"),
                ),

                ..._pickupBins.map((bin) => binCard(bin, _pickupBins)),
                addButton('Add Another Pickup Bin', () {
                  setState(() {
                    _pickupBins.add({'image': null, 'price': ''});
                  });
                }),
                SwitchListTile(
                  title: Text('Does the company sell bins?'),
                  value: _sellsBins,
                  onChanged: (bool value) {
                    setState(() {
                      _sellsBins = value;
                    });
                  },
                ),
                if (_sellsBins) ...[
                  sectionTitle('Selling Bins'),
                  ..._sellingBins.map((bin) => binCard(bin, _sellingBins)),
                  addButton('Add Another Selling Bin', () {
                    setState(() {
                      _sellingBins.add({'image': null, 'price': ''});
                    });
                  }),
                ],


                SizedBox(height: 20),
                sectionTitle('Company Details'),
                logoUploadButton(),
                BusinessReGUploadButton(),

                TextFormField(
                  decoration: InputDecoration(labelText: 'Landmark close to location'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter landmark';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Location'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter location';
                    }
                    return null;
                  },
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
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Ghana Card Number'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Ghana card number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                submitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget addButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }


  ImagePicker _imagePicker = ImagePicker();
  Widget logoUploadButton() {
    return ElevatedButton(
      onPressed: () async {
        final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          setState(() {
            _logoFile = File(pickedFile.path);
          });
        }
      },
      child: Text('Upload Company Logo'),
    );
  }
  Widget BusinessReGUploadButton() {
    return ElevatedButton(
      onPressed: () async {
        final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          setState(() {
            _CompRegFile = File(pickedFile.path);
          });
        }
      },
      child: Text('Upload Bussiness Registration'),
    );
  }
  //
  // Widget logoUploadButton() {
  //   return ElevatedButton(
  //     onPressed: () async {
  //       FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
  //       if (result != null) {
  //         setState(() {
  //           _logoFile = File(result.files.single.path!);
  //         });
  //       }
  //     },
  //     child: Text('Upload Company Logo'),
  //   );
  // }


  Widget registrationDocUploadButton() {
    return ElevatedButton(
      onPressed: () async {
        final typeGroup = XTypeGroup(label: 'documents', extensions: ['pdf', 'doc', 'docx']);
        final file = await openFile(acceptedTypeGroups: [typeGroup]);
        if (file != null) {
          setState(()   {
            _registrationDocBytes = file.readAsBytes() as Uint8List?;
          });
        }
      },
      child: Text('Upload Registration Document'),
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
              bin['image']??"assets/images/choose.png",
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
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        ),
      ),
    );
  }

  void _submitForm() async {
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
          'pickupBins': _pickupBins,
          'sellsBins': _sellsBins,
          'sellingBins': _sellingBins,
          'logoUrl': logoUrl,
          'BusinessCertUrl': CompRegUrl,
          'registrationDocUrl': regDocUrl,
          'landmark': _landmarkController.text,
          'location': _locationController.text,
          'employeesCount': int.parse(_employeesController.text),
          'ghMobileNumber': _ghMobileNumberController.text,
          'ghanaCardNumber': _ghanaCardNumberController.text,
        };

        await _database.child('users').child(userId).child(
            'wasteManagementInfo').set(formData);

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Data submitted successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User not signed in')));
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
