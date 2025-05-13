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

class RecyclingForm extends StatefulWidget {
  @override
  _RecyclingFormState createState() => _RecyclingFormState();
}

class _RecyclingFormState extends State<RecyclingForm> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  File? _logoFile;
  File? _compRegFile;
  File? _registrationDocFile;

  final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _DirectornameController = TextEditingController();
  final TextEditingController _gpsController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _employeesController = TextEditingController();
  final TextEditingController _ghMobileNumberController = TextEditingController();
  final TextEditingController _ghanaCardNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionTitle('Company Details'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              BusinessReGUploadButton(),
              logoUploadButton(),
            ],
          ),
          Container(
            height: height / 1.2,
            width: 400,
            decoration: BoxDecoration(
              color: Color(0xFFE9EBED),
              borderRadius: BorderRadius.circular(13),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  textField('Company Name', _fullnameController, icon: Icons.business),
                  textField('Director Name', _DirectornameController, icon: Icons.person),
                  textField('Landmark close to location', _landmarkController, icon: Icons.landscape),
                  textField('Location', _locationController, icon: Icons.location_on),
                  textField('GPS', _gpsController, icon: Icons.gps_fixed_outlined),
                  textField('Number of Employees', _employeesController, icon: Icons.people),
                  textField('GH Mobile Number', _ghMobileNumberController, icon: Icons.phone),
                  textField('Ghana Card Number', _ghanaCardNumberController, icon: Icons.credit_card),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          submitButton(),
        ],
      ),
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

  Widget textField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 67,
        alignment: Alignment.center,
        padding: EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextFormField(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: icon != null ? Icon(icon) : null,
            border: InputBorder.none,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            return null;
          },
          controller: controller,
          keyboardType: keyboardType,
        ),
      ),
    );
  }

  Widget submitButton() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _submitForm,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.lightGreenAccent],
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
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ProgressDialog(message: "Updating, please wait....."),
    );

    User? user = _auth.currentUser;
    if (user == null) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User not signed in')));
      return;
    }

    String userId = user.uid;

    List<Future<String?>> uploadTasks = [
      _logoFile != null ? uploadFile(_logoFile!, 'CompanyLogo') : Future.value(null),
      _compRegFile != null ? uploadFile(_compRegFile!, 'CompanyRegistration') : Future.value(null),
      _registrationDocFile != null ? uploadFile(_registrationDocFile!, 'BusinessRegistration') : Future.value(null),
    ];

    List<String?> uploadResults = await Future.wait(uploadTasks);

    Map<String, dynamic> formData = {
      'logoUrl': uploadResults[0],
      'WMSTYPE': "Recycle",
      'detailsComp': true,
      'compRegUrl': uploadResults[1].toString(),
      'registrationDocUrl': uploadResults[2].toString(),
      'FullName': _fullnameController.text,
      'DirectorName': _DirectornameController.text,
      'landmark': _landmarkController.text,
      'location': _locationController.text,
      'GPSAddress': _gpsController.text,
      'employees': _employeesController.text,
      'ghMobileNumber': _ghMobileNumberController.text,
      'ghanaCardNumber': _ghanaCardNumberController.text,
    };

    await _database.child('WMS').child(userId).child('wasteManagementInfo').set(formData);
    await _database.child('WMS').child(userId).update({'detailsComp': true});

    Navigator.of(context).pop();
    Navigator.of(context).pushNamed("/SignIn");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data submitted successfully')));
  }

  Future<String> uploadFile(File file, String folderName) async {
    Reference reference = _storage.ref().child('$folderName/${Path.basename(file.path)}');
    UploadTask uploadTask = reference.putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Widget logoUploadButton() {
    return Column(
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
          child: Container(
            width: 100,
            height: 105,
            child: _logoFile != null ? Image.file(_logoFile!) : Icon(Icons.drive_folder_upload),
          ),
        ),
      ],
    );
  }

  Widget BusinessReGUploadButton() {
    return Column(
      children: [
        Text("Business Registration"),
        GestureDetector(
          onTap: () async {
            final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
            if (pickedFile != null) {
              setState(() {
                _compRegFile = File(pickedFile.path);
              });
            }
          },
          child: Container(
            width: 100,
            height: 100,
            child: _compRegFile != null ? Image.file(_compRegFile!) : Icon(Icons.drive_folder_upload),
          ),
        ),
      ],
    );
  }
}
