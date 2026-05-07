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

import '../widgets/BinSale.dart';
import '../widgets/RecycleForm.dart';
import '../widgets/WMSFORM.dart';

class Addwmsdetails extends StatefulWidget {
  const Addwmsdetails({super.key});

  @override
  State<Addwmsdetails> createState() => _AddwmsdetailsState();
}

// These controllers are used inside the separate forms (WasteManagementForm, etc.)
// Keeping them as defined originally.
TextEditingController _landmarkController = TextEditingController();
TextEditingController _locationController = TextEditingController();
TextEditingController _employeesController = TextEditingController();
TextEditingController _ghMobileNumberController = TextEditingController();
TextEditingController _ghanaCardNumberController = TextEditingController();
Uint8List? _registrationDocBytes;

class _AddwmsdetailsState extends State<Addwmsdetails> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _database = FirebaseDatabase.instance.ref();
  final _storage = FirebaseStorage.instance;
  List<Map<String, dynamic>> _pickupBins = [];
  List<Map<String, dynamic>> _sellingBins = [];
  bool _sellsBins = false;
  File? _logoFile;
  File? _CompRegFile;
  File? _registrationDocFile;
  Uint8List? _registrationDocBytes;
  String _selectedType = 'Waste Management Service';

  // ✅ NEW: Toggle for scheduled requests (only for Waste Management Service)
  bool _acceptScheduledRequests = false;

  @override
  void initState() {
    super.initState();
    // Ensure default selected type is valid
    if (!['Waste Management Service', 'Recycling', 'Bin Sale'].contains(_selectedType)) {
      _selectedType = 'Waste Management Service';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type selection dropdown
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    color: Colors.green,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(5, 5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Select Type',
                        border: InputBorder.none,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      dropdownColor: Colors.green,
                      value: _selectedType,
                      items: const [
                        DropdownMenuItem(value: 'Waste Management Service', child: Text('Waste Management Service')),
                        DropdownMenuItem(value: 'Recycling', child: Text('Recycling')),
                        DropdownMenuItem(value: 'Bin Sale', child: Text('Bin Sale')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),


                // Conditional form widgets (existing)
                _selectedType == 'Waste Management Service'
                    ? WasteManagementForm()
                    : _selectedType == 'Recycling'
                    ? RecyclingForm()
                    : _selectedType == 'Bin Sale'
                    ? SellingBinsWidget()
                    : Container(),

                const SizedBox(height: 20),
                // submitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------------------
  // Existing helper methods (logo upload, bin cards, etc.)
  // ----------------------------------------------------------------------
  Widget addButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }

  final ImagePicker _imagePicker = ImagePicker();

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
          child: const Text('Upload Company Logo'),
        ),
      ],
    );
  }

  Widget BusinessReGUploadButton() {
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
          child: const Text('Upload Business Registration'),
        ),
      ],
    );
  }

  Widget registrationDocUploadButton() {
    return ElevatedButton(
      onPressed: () async {
        const typeGroup = XTypeGroup(label: 'documents', extensions: ['pdf', 'doc', 'docx']);
        final file = await openFile(acceptedTypeGroups: [typeGroup]);
        if (file != null) {
          setState(() {
            _registrationDocBytes = file.readAsBytes() as Uint8List?;
          });
        }
      },
      child: const Text('Upload Registration Document'),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              hint: const Text('Select Bin Image'),
              items: const [
                DropdownMenuItem(child: Text('Borla Extra -660L'), value: 'assets/images/140.png'),
                DropdownMenuItem(child: Text('Borla Plus - 360L'), value: 'assets/images/140.png'),
                DropdownMenuItem(child: Text('Borla Large - 240L'), value: 'assets/images/140.png'),
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
            TextFormField(
              decoration: const InputDecoration(labelText: 'Price for selected bin'),
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
              child: const Icon(Icons.delete),
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
        child: const Text('Submit'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        ),
      ),
    );
  }

  void _submitForm() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return  ProgressDialog(message: "Adding, Please wait...");
      },
    );

    if (_formKey.currentState!.validate()) {
      User? user = _auth.currentUser;
      if (user != null) {
        String userId = user.uid;

        // Upload files
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
          regDocUrl = await uploadFile(_registrationDocFile!, 'registration_documents');
        }

        // ✅ Include the new scheduled requests flag
        Map<String, dynamic> formData = {
          'pickupBins': _pickupBins,
          'sellsBins': _sellsBins,
          'sellingBins': _sellingBins,
          'logoUrl': logoUrl,
          'BusinessCertUrl': CompRegUrl,
          'registrationDocUrl': regDocUrl,
          'landmark': _landmarkController.text.toString(),
          'location': _locationController.text.toString(),
          'employeesCount': _employeesController.text.toString(),
          'ghMobileNumber': _ghMobileNumberController.text.toString(),
          'ghanaCardNumber': _ghanaCardNumberController.text.toString(),
          // 👇 Save availability for scheduled requests
          'availableFor': _acceptScheduledRequests ? 'scheduled' : 'instant',
        };

        await _database
            .child('WMS')
            .child(userId)
            .child('wasteManagementInfo')
            .set(formData);

        // Also store at the root of the WMS node for easier lookup
        await _database.child('WMS').child(userId).update({
          'availableFor': _acceptScheduledRequests ? 'scheduled' : 'instant',
          'token': await _getDeviceToken(), // You should implement token retrieval
        });

        if (mounted) {
          Navigator.of(context).pop(); // close progress dialog
          Navigator.of(context).pushNamed("/SignIn");
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data submitted successfully')));
        }
      } else {
        if (mounted) {
          Navigator.of(context).pop(); // close progress dialog
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('User not signed in')));
        }
      }
    } else {
      if (mounted) Navigator.of(context).pop(); // close dialog if validation fails
    }
  }

  Future<String> uploadFile(File file, String folderName) async {
    Reference reference = _storage.ref().child('$folderName/${Path.basename(file.path)}');
    UploadTask uploadTask = reference.putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // Helper to get the device's FCM token – you need to implement this
  // based on your firebase_messaging setup.
  Future<String> _getDeviceToken() async {
    // Example: FirebaseMessaging.instance.getToken()
    return "dummy_token_please_implement";
  }
}