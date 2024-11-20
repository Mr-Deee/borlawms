import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CustomerSupportService extends StatefulWidget {
  const CustomerSupportService({super.key});

  @override
  State<CustomerSupportService> createState() => _CustomerSupportServiceState();
}

class _CustomerSupportServiceState extends State<CustomerSupportService> {
  final _formKey = GlobalKey<FormState>();
  String? selectedIssue;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  File? imageFile;
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<Map<String, dynamic>> userRequests = [];

  @override
  void initState() {
    super.initState();
    _fetchUserRequests();
  }

  Future<void> _fetchUserRequests() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final uid = user.uid;
        final ref = _database.ref("WMS/$uid/css");

        final snapshot = await ref.get();
        if (snapshot.exists) {
          final data = snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            userRequests = data.entries
                .map((e) => Map<String, dynamic>.from(e.value))
                .toList();
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching requests: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Support Service"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Select Request Title'),
                    value: selectedIssue,
                    onChanged: (value) {
                      setState(() {
                        selectedIssue = value;
                      });
                    },
                    items: [
                      'Bug Report',
                      'Account Issue',
                      'Feature Request',
                      'Other'
                    ]
                        .map((issue) => DropdownMenuItem<String>(
                      value: issue,
                      child: Text(issue),
                    ))
                        .toList(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a request title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  if (selectedIssue == 'Other')
                    Column(
                      children: [
                        TextFormField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Enter Title',
                            hintText: 'Describe the issue briefly',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Enter Description',
                            hintText: 'Provide detailed information about the issue',
                          ),
                          maxLines: 4,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                      ],
                    )
                  else
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Enter Description',
                        labelStyle: const TextStyle(
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.bold,
                        ),
                        hintText: 'Describe the issue',
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.blueGrey, width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.blue, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setState(() {
                          imageFile = File(pickedFile.path);
                        });
                      }
                    },
                    icon: const Icon(Icons.image),
                    label: const Text("Upload Screenshot"),
                  ),
                  const SizedBox(height: 8),
                  if (imageFile != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.file(imageFile!, height: 150, fit: BoxFit.cover),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        _submitRequest();
                      }
                    },
                    child: const Text("Submit Request"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "Your Previous Requests",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (userRequests.isEmpty)
              const Text("No requests found."),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: userRequests.length,
              itemBuilder: (context, index) {
                final request = userRequests[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(request['issue'] ?? "No Title"),
                    subtitle: Text(request['description'] ?? "No Description"),
                    trailing: Text(request['timestamp']?.toString().split(' ').first ?? ""),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitRequest() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      final user = _auth.currentUser;

      if (user != null) {
        final uid = user.uid;
        final ref = _database.ref("WMS/$uid/css");
        final refcss = _database.ref();

        final requestData = {
          'UserId': uid,
          'title': titleController.text,
          'description': descriptionController.text,
          'issue': selectedIssue,
          'status': 'open',
          'WMSTYPE': 'WMS',
          'timestamp': DateTime.now().toString(),
        };

        if (imageFile != null) {
          final imageRef = _storage.ref().child('screenshots/${DateTime.now().millisecondsSinceEpoch}.jpg');
          await imageRef.putFile(imageFile!);
          final imageUrl = await imageRef.getDownloadURL();
          requestData['imageUrl'] = imageUrl;
        }

        await ref.push().set(requestData);
        await refcss.child("customerSupportRequests").push().set(requestData);
        _fetchUserRequests();

        setState(() {
          titleController.clear();
          descriptionController.clear();
          selectedIssue = null;
          imageFile = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Request submitted successfully.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting request: $e")),
      );
    } finally {
      // Dismiss loading dialog
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

}
