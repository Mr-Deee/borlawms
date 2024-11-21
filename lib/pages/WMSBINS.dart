import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ViewMyBinsPage extends StatefulWidget {
  const ViewMyBinsPage({Key? key}) : super(key: key);

  @override
  State<ViewMyBinsPage> createState() => _ViewMyBinsPageState();
}

class _ViewMyBinsPageState extends State<ViewMyBinsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  Map<String, dynamic>? wasteManagementInfo;
  List<dynamic>? pickupBins;

  @override
  void initState() {
    super.initState();
    _fetchUserWasteManagementInfo();
  }

  Future<void> _fetchUserWasteManagementInfo() async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        final ref = _database.ref("WMS/${user.uid}/wasteManagementInfo");
        final snapshot = await ref.get();

        if (snapshot.exists) {
          final data = Map<String, dynamic>.from(snapshot.value as Map);
          setState(() {
            wasteManagementInfo = data;

            // If pickupBins exists, handle it as a List directly
            if (data['pickupBins'] != null) {
              List<dynamic> rawBins = data['pickupBins'];  // Directly use the list
              pickupBins = rawBins.map((bin) {
                return {
                  'image': bin['image'],
                  'bintypename': bin['bintypename'],
                  'price': bin['price'],
                };
              }).toList();
            } else {
              pickupBins = [];
            }
          });
        } else {
          setState(() {
            wasteManagementInfo = null;
          });
        }
      }
    } catch (e) {
      print("Error fetching waste management info: $e");
    }
  }

  // Method to handle the editing of a bin
  Future<void> _editBin(int index) async {
    final bin = pickupBins![index];
    TextEditingController bintypenameController =
    TextEditingController(text: bin['bintypename']);
    TextEditingController priceController =
    TextEditingController(text: bin['price'].toString());
    String? image = bin['image'];

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Bin"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: bintypenameController,
                  decoration: const InputDecoration(labelText: "Bin Type Name"),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: "Price"),
                  keyboardType: TextInputType.number,
                ),
                // You can add a field for image URL or a file picker if necessary.
                TextField(
                  controller: TextEditingController(text: image),
                  decoration: const InputDecoration(labelText: "Image URL"),
                  onChanged: (val) {
                    image = val;  // Update the image URL when the user changes it.
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  pickupBins![index] = {
                    'image': image,
                    'bintypename': bintypenameController.text,
                    'price': double.tryParse(priceController.text) ?? 0.0,
                  };
                });
                Navigator.of(context).pop(); // Close the dialog

                // Optionally, update the data in Firebase
                _updateBinInDatabase(index);
              },
              child: const Text("Save Changes"),
            ),
          ],
        );
      },
    );
  }

  // Method to update the bin in Firebase
  Future<void> _updateBinInDatabase(int index) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final ref = _database.ref("WMS/${user.uid}/wasteManagementInfo");
        await ref.update({
          'pickupBins': pickupBins,
        });
        print('Bin updated successfully');
      }
    } catch (e) {
      print("Error updating bin: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bins"),
        centerTitle: true,
      ),
      body: wasteManagementInfo == null
          ? const Center(
        child: Text(
          "No data available.",
          style: TextStyle(fontSize: 16),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 16),
            const Text(
              "Pickup Bins:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            pickupBins == null || pickupBins!.isEmpty
                ? const Text("No bins assigned.")
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pickupBins!.length,
              itemBuilder: (context, index) {
                final bin = pickupBins![index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 82,
                    child: Card(
                      child: ListTile(
                        leading: bin['image'] != null
                            ? Image.asset(
                          bin['image'],
                          width: 50,
                          height: 80,
                          fit: BoxFit.cover,
                        )
                            : const Icon(Icons.image_not_supported),
                        title: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "${bin['bintypename'] ?? 'N/A'}",
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _editBin(index); // Call edit function
                                  },
                                ),
                              ],
                            ),
                            Text("GHS${bin['price'] ?? 'N/A'}"),


                          ],
                        ),
                        // trailing:
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
