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
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
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
  final TextEditingController _DirectorNameController = TextEditingController();

  final TextEditingController _CompanynameController = TextEditingController();
  final TextEditingController _gpsController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _employeesController = TextEditingController();
  final TextEditingController _ghMobileNumberController =
      TextEditingController();
  final TextEditingController _ghanaCardNumberController =
      TextEditingController();



  @override
  void initState() {
    super.initState();
    _fetchExistingData();
  }

  Future<void> _fetchExistingData() async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        final ref = _database.child("WMS/${user.uid}/wasteManagementInfo");
        final snapshot = await ref.get();

        if (snapshot.exists) {
          final data = Map<String, dynamic>.from(snapshot.value as Map);
          setState(() {
            // Populate the controllers if data exists
            _CompanynameController.text = data['CompanyName'] ?? '';
            _DirectorNameController.text = data['DirectorName'] ?? '';
            _landmarkController.text = data['landmark'] ?? '';
            _locationController.text = data['location'] ?? '';
            _gpsController.text = data['gps'] ?? '';
            _employeesController.text = data['employees'] ?? '';
            _ghMobileNumberController.text = data['ghMobileNumber'] ?? '';
            _ghanaCardNumberController.text = data['ghanaCardNumber'] ?? '';
          });
        }
      }
    } catch (e) {
      print("Error fetching company details: $e");
    }
  }

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _CompanynameController.dispose();
    _DirectorNameController.dispose();
    _landmarkController.dispose();
    _locationController.dispose();
    _gpsController.dispose();
    _employeesController.dispose();
    _ghMobileNumberController.dispose();
    _ghanaCardNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sectionTitle('Pickup Bins'),
              Padding(
                padding: const EdgeInsets.only(left: 2.0),
                child: Text(
                  "Kindly let us know the types of bins you "
                      "pickup and the price you charge by tapping the '+' button",
                  style: TextStyle(color: Colors.black54),
                ),
              ),
              ..._pickupBins.map((bin) => binCard(bin, _pickupBins)),
              addButton('Add Another Pickup Bin', () {
                setState(() {
                  _pickupBins.add({'image': null, 'price': ''});
                });
              }),
              SizedBox(height: 20),
              sectionTitle('Company Details'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  logoUploadButton(),
                  BusinessReGUploadButton(),
                ],
              ),
              Column(
                children: [
                  // Reusable function for text field widgets
                  _buildTextField(
                      context, _CompanynameController, Icons.business, 'Company Name', 'Please enter Company Name'),
                  _buildTextField(
                      context, _DirectorNameController, Icons.person, 'Director Name', 'Please enter Director Name'),
                  _buildTextField(context, _landmarkController, Icons.landscape, 'Landmark close to location',
                      'Please enter landmark'),
                  _buildTextField(
                      context, _locationController, Icons.location_searching_outlined, 'Location', 'Please enter location'),
                  _buildTextField(
                      context, _gpsController, Icons.gps_fixed, 'GPS Address', 'Please enter GPS Address'),
                  _buildTextField(context, _employeesController, Icons.person_pin_circle_sharp, 'Number of Employees',
                      'Please enter number of employees',
                      keyboardType: TextInputType.number),
                  _buildTextField(
                      context, _ghMobileNumberController, Icons.numbers, 'Phone Number', 'Please enter phone number',
                      keyboardType: TextInputType.phone),
                  _buildTextField(context, _ghanaCardNumberController, Icons.numbers, 'Ghana Card Number',
                      'Please enter Ghana card number'),
                ],
              ),
              SizedBox(height: 20),
              submitButton(),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget BusinessReGUploadButton() {
    return Column(
      children: [
        Text("Business Registration"),
        GestureDetector(
          onTap: () async {
            final pickedFile =
                await _imagePicker.pickImage(source: ImageSource.gallery);
            if (pickedFile != null) {
              setState(() {
                _compRegFile = File(pickedFile.path);
              });
            }
          },
          child: Container(
            width: 100,
            height: 100,
            child: _compRegFile != null
                ? Image.file(_compRegFile!)
                : Icon(Icons.drive_folder_upload),
          ),
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
            final pickedFile =
                await _imagePicker.pickImage(source: ImageSource.gallery);
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

  Widget textField(String label, TextEditingController controller,
      [TextInputType keyboardType = TextInputType.text]) {
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
            // Image Preview
            Image.asset(
              bin['image'] ?? "assets/images/choose.png",
              height: 100,
              width: 100,
            ),
            // Dropdown for Bin Type and Image
            DropdownButtonFormField<String>(
              borderRadius: BorderRadius.circular(10),
              value: bin['image'] != null && bin['bintypename'] != null
                  ? '${bin['image']}|${bin['bintypename']}'
                  : null,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.border_inner,
                  color: Colors.grey,
                ),
                border: InputBorder.none,
                hintText: 'Select Bin Type',
              ),
              items: [
                DropdownMenuItem(
                    child: Text('Borla Extra - 660L'),
                    value: 'assets/images/660l.png|Borla Extra - 660L'),
                DropdownMenuItem(
                    child: Text('Borla Plus - 360L'),
                    value: 'assets/images/360l.png|Borla Plus - 360L'),
                DropdownMenuItem(
                    child: Text('Borla Large - 240L'),
                    value: 'assets/images/240L.png|Borla Large - 240L'),
                DropdownMenuItem(
                    child: Text('Borla Standard - 140L'),
                    value: 'assets/images/140.png|Borla Standard - 140L'),
                DropdownMenuItem(
                    child: Text('Borla Medium - 100L'),
                    value: 'assets/images/100l.png|Borla Medium - 100L'),
                DropdownMenuItem(
                    child: Text('Borla Bag'),
                    value: 'assets/images/plasticbag.png|Borla Bag'),
              ],
              onChanged: (value) {
                setState(() {
                  if (value != null) {
                    final splitValue = value.split('|'); // Split into image and bintypename
                    bin['image'] = splitValue[0];
                    bin['bintypename'] = splitValue[1];
                  }
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a bin type';
                }
                return null;
              },
            ),
            // Price Input
            Container(
              height: 69,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextFormField(
                decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.price_check,
                      color: Colors.grey,
                    ),
                    border: InputBorder.none,
                    hintMaxLines: 1,
                    hintText: 'Price for selected bin'),
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
            // Delete Button
            GestureDetector(
              onTap: () {
                setState(() {
                  binsList.remove(bin);
                });
              },
              child: Icon(Icons.delete, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget submitButton() {
    return  Center(
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
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return; // Exit early if form validation fails
    }

    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ProgressDialog(
          message: "Updating, please wait.....",
        );
      },
    );

    User? user = _auth.currentUser;
    if (user == null) {
      Navigator.of(context).pop(); // Close dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not signed in')),
      );
      return;
    }

    String userId = user.uid;
    List<Future<String?>> uploadTasks = [];

    // Upload files concurrently
    if (_logoFile != null) {
      uploadTasks.add(uploadFile(_logoFile!, 'CompanyLogo'));
    } else {
      uploadTasks.add(Future.value(null));
    }
    if (_compRegFile != null) {
      uploadTasks.add(uploadFile(_compRegFile!, 'CompanyRegistration'));
    } else {
      uploadTasks.add(Future.value(null));
    }
    if (_registrationDocFile != null) {
      uploadTasks.add(uploadFile(_registrationDocFile!, 'BusinessRegistration'));
    } else {
      uploadTasks.add(Future.value(null));
    }

    // Wait for all uploads to complete
    List<String?> uploadResults = await Future.wait(uploadTasks);
    String? logoUrl = uploadResults[0];
    String? compRegUrl = uploadResults[1];
    String? registrationDocUrl = uploadResults[2];

    // Prepare form data
    Map<String, dynamic> formData = {
      'pickupBins': _pickupBins.map((bin) => {
        'image': bin['image'],
        'bintypename': bin['bintypename'],
        'price': bin['price'],
      }).toList(),
      'WMSTYPE': "WMS",
      'CompanyName': _CompanynameController.text,
      'DirectorName': _DirectorNameController.text,
      'logoUrl': logoUrl,
      'compRegUrl': compRegUrl,
      'detailsComp': true,
      'gps': _gpsController.text,
      'landmark': _landmarkController.text,
      'location': _locationController.text,
      'employees': _employeesController.text,
      'ghMobileNumber': _ghMobileNumberController.text,
      'ghanaCardNumber': _ghanaCardNumberController.text,
    };

    // Update database concurrently
    Future<void> dbUpdate1 = _database
        .child('WMS')
        .child(userId)
        .child('wasteManagementInfo')
        .set(formData);
    Future<void> dbUpdate2 = _database
        .child('WMS')
        .child(userId)
        .update({'detailsComp': true});

    await Future.wait([dbUpdate1, dbUpdate2]);

    // Close dialog and navigate
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed("/SignIn");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data submitted successfully')),
    );
  }

// Helper function for creating text field widgets
  Widget _buildTextField(BuildContext context, TextEditingController controller, IconData icon, String hintText, String validationMessage, {TextInputType keyboardType = TextInputType.text}) {
    final size = MediaQuery.of(context).size;
    return Padding(
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
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey),
            border: InputBorder.none,
            hintMaxLines: 1,
            hintText: hintText,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return validationMessage;
            }
            return null;
          },
        ),
      ),
    );
  }


  Future<String> uploadFile(File file, String folderName) async {
    Reference reference =
        _storage.ref().child('$folderName/${Path.basename(file.path)}');
    UploadTask uploadTask = reference.putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
}
