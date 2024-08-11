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
  final DatabaseReference _database = FirebaseDatabase.instance.reference();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  File? _logoFile;
  File? _compRegFile;
  File? _registrationDocFile;
  final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _employeesController = TextEditingController();
  final TextEditingController _ghMobileNumberController = TextEditingController();
  final TextEditingController _ghanaCardNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionTitle('Company Details'),
          uploadButton('Upload Company Logo', _logoFile, (file) => _logoFile = file),
          uploadButton('Upload Company Registration Document', _compRegFile, (file) => _compRegFile = file),
          uploadButton('Upload Business Registration Certificate', _registrationDocFile, (file) => _registrationDocFile = file),
          textField('Landmark close to location', _landmarkController),
          textField('Location', _locationController),
          textField('Number of Employees', _employeesController, TextInputType.number),
          textField('GH Mobile Number', _ghMobileNumberController, TextInputType.phone),
          textField('Ghana Card Number', _ghanaCardNumberController),
          SizedBox(height: 20),
          submitButton(),
        ],
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
          'logoUrl': logoUrl,
          'compRegUrl': compRegUrl,
          'registrationDocUrl': registrationDocUrl,
          'landmark': _landmarkController.text,
          'location': _locationController.text,
          'employees': _employeesController.text,
          'ghMobileNumber': _ghMobileNumberController.text,
          'ghanaCardNumber': _ghanaCardNumberController.text,
        };

        await _database.child('Recycling').child(userId).child('recyclingInfo').set(formData);

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