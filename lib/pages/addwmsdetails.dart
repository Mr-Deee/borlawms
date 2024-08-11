import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as Path;

class Addwmsdetails extends StatefulWidget {
  @override
  _AddwmsdetailsState createState() => _AddwmsdetailsState();
}

class _AddwmsdetailsState extends State<Addwmsdetails> {
  String _selectedType = 'Waste Management';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Select Type'),
                value: _selectedType,
                items: ['Waste Management', 'Recycling']
                    .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              SizedBox(height: 20),
              _selectedType == 'Waste Management'
                  ? WasteManagementForm()
                  : RecyclingForm(),
            ],
          ),
        ),
      ),
    );
  }
}

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
  bool _pickupBins = false;
  bool _sellsBins = false;
  File? _logoFile;
  File? _CompRegFile;
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
          CheckboxListTile(
            title: Text('Do you pick up bins?'),
            value: _pickupBins,
            onChanged: (value) {
              setState(() {
                _pickupBins = value!;
              });
            },
          ),
          CheckboxListTile(
            title: Text('Do you sell bins?'),
            value: _sellsBins,
            onChanged: (value) {
              setState(() {
                _sellsBins = value!;
              });
            },
          ),
          if (_sellsBins) ...[
            sectionTitle('Bins for Sale'),
            ..._sellingBins.map((bin) => binCard(bin)),
            addButton('Add Another Bin', () {
              setState(() {
                _sellingBins.add({'type': '', 'price': ''});
              });
            }),
          ],
          SizedBox(height: 20),
          sectionTitle('Company Details'),
          logoUploadButton(),
          CompRegUploadButton(),
          registrationDocUploadButton(),
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
        ElevatedButton(
          onPressed: () async {
            final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
            if (pickedFile != null) {
              setState(() {
                _logoFile = File(pickedFile.path);
              });
            }
          },
          child: Text('Upload Company Logo'),
        ),
      ],
    );
  }

  Widget CompRegUploadButton() {
    return Column(
      children: [
        if (_CompRegFile != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Image.file(
              _CompRegFile!,
              width: 100,
              height: 100,
            ),
          ),
        ElevatedButton(
          onPressed: () async {
            final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
            if (pickedFile != null) {
              setState(() {
                _CompRegFile = File(pickedFile.path);
              });
            }
          },
          child: Text('Upload Company Registration Document'),
        ),
      ],
    );
  }

  Widget registrationDocUploadButton() {
    return Column(
      children: [
        if (_registrationDocFile != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Image.file(
              _registrationDocFile!,
              width: 100,
              height: 100,
            ),
          ),
        ElevatedButton(
          onPressed: () async {
            final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
            if (pickedFile != null) {
              setState(() {
                _registrationDocFile = File(pickedFile.path);
              });
            }
          },
          child: Text('Upload Business Registration Certificate'),
        ),
      ],
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

  Widget binCard(Map<String, dynamic> bin) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Bin Type'),
              onChanged: (value) {
                bin['type'] = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter bin type';
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
                  _sellingBins.remove(bin);
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
        if (_CompRegFile != null) {
          compRegUrl = await uploadFile(_CompRegFile!, 'CompanyRegistration');
        }
        if (_registrationDocFile != null) {
          registrationDocUrl = await uploadFile(_registrationDocFile!, 'BusinessRegistration');
        }

        Map<String, dynamic> formData = {
          'pickupBins': _pickupBins,
          'sellsBins': _sellsBins,
          'sellingBins': _sellingBins,
          'logoUrl': logoUrl,
          'compRegUrl': compRegUrl,
          'registrationDocUrl': registrationDocUrl,
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

class RecyclingForm extends StatefulWidget {
  @override
  _RecyclingFormState createState() => _RecyclingFormState();
}

class _RecyclingFormState extends State<RecyclingForm> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.reference();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  File? _registrationDocFile;
  final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _FullNameController = TextEditingController();
  final TextEditingController _GPSAddressController = TextEditingController();
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
          sectionTitle('Recycling Company Details'),
          registrationDocUploadButton(),
          TextFormField(
            decoration: InputDecoration(labelText: 'Full Name/ Business Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter landmark';
              }
              return null;
            },
            controller: _FullNameController,
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
                controller:_GPSAddressController,
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
    );
  }

  Widget registrationDocUploadButton() {
    return Column(
      children: [
        if (_registrationDocFile != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Image.file(
              _registrationDocFile!,
              width: 100,
              height: 100,
            ),
          ),
        ElevatedButton(
          onPressed: () async {
            final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
            if (pickedFile != null) {
              setState(() {
                _registrationDocFile = File(pickedFile.path);
              });
            }
          },
          child: Text('Upload Business Registration Certificate'),
        ),
      ],
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

        String? registrationDocUrl;

        if (_registrationDocFile != null) {
          registrationDocUrl = await uploadFile(_registrationDocFile!, 'RecyclingRegistration');
        }

        Map<String, dynamic> formData = {
          'registrationDocUrl': registrationDocUrl,
          'landmark': _landmarkController.text,
          'location': _locationController.text,
          'employees': _employeesController.text,
          'ghMobileNumber': _ghMobileNumberController.text,
          'ghanaCardNumber': _ghanaCardNumberController.text,
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
