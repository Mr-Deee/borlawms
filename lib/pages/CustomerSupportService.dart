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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Support Service"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Dropdown for request title
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

              // Conditional input for title and description
              if (selectedIssue == 'Other')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Enter Description',
                        labelStyle: const TextStyle(
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.bold,
                        ),
                        hintText: 'Describe the issue',
                        hintStyle: const TextStyle(color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.blueGrey, width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.blue, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.blueGrey, width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
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
                ),


               SizedBox(height: 16),

              // Image upload
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

              // Display uploaded image
              if (imageFile != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(imageFile!, height: 150, fit: BoxFit.cover),
                ),

              const SizedBox(height: 16),

              // Submit button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    // Handle form submission
                    _submitRequest();
                  }
                },
                child: const Text("Submit Request"),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> _submitRequest() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent closing the dialog by tapping outside
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      final user = _auth.currentUser;

      if (user != null) {
        final uid = user.uid;
        final ref = _database.ref("WMS/$uid"); // Path for user's waste management info
        final refcss = _database.ref();       // Root reference for global customer support requests

        // Prepare data to be saved
        final requestData = {
          'UserId': uid,
          'title': titleController.text,
          'description': descriptionController.text,
          'issue': selectedIssue,
          'timestamp': DateTime.now().toString(),
        };

        // Check if there is an image to upload
        String? imageUrl;
        if (imageFile != null) {
          // Upload image to Firebase Storage
          final imageRef = _storage.ref().child('screenshots/${DateTime.now().millisecondsSinceEpoch}.jpg');
          await imageRef.putFile(imageFile!);
          imageUrl = await imageRef.getDownloadURL();
        }

        // Save the data in Realtime Database under the current user
        await refcss.child('customerSupportRequests').push().set(requestData);

        // Save the same data under a new child called 'css'
        await ref.child('css').push().set({
          'title': titleController.text,
          'description': descriptionController.text,
          'imageUrl': imageUrl, // if image is uploaded
          'timestamp': DateTime.now().toString(),
        });

        // Reset the form
        setState(() {
          titleController.clear();
          descriptionController.clear();
          selectedIssue = null;
          imageFile = null;
        });

        // Dismiss loading dialog
        Navigator.pop(context);

        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Request Submitted"),
            content: const Text(
                "Your request has been submitted successfully.\nOur team will get back to you shortly."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Dismiss loading dialog
      Navigator.pop(context);

      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text("An error occurred: $e"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }


}

