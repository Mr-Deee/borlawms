import 'dart:io';
import 'package:borlawms/pages/progressdialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class WasteManagementForm extends StatefulWidget {
  @override
  _WasteManagementFormState createState() => _WasteManagementFormState();
}

class _WasteManagementFormState extends State<WasteManagementForm> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _database = FirebaseDatabase.instance.ref();
  final _storage = FirebaseStorage.instance;
  final _picker = ImagePicker();

  List<_BinItem> _pickupBins = [];

  bool _acceptScheduledRequests = false;
  bool _acceptSubscriptionRequests = false;

  File? _logoFile;
  File? _compRegFile;
  File? _registrationDocFile;

  final _companyNameCtrl = TextEditingController();
  final _directorNameCtrl = TextEditingController();
  final _landmarkCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _gpsCtrl = TextEditingController();
  final _employeesCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _ghanaCardCtrl = TextEditingController();

  bool _isSubmitting = false;
  bool _isFetchingLocation = false;

  @override
  void initState() {
    super.initState();
    _fetchExistingData();
    _addEmptyBin();
  }

  void _addEmptyBin() {
    setState(() {
      _pickupBins.add(_BinItem());
    });
  }

  void _removeBinAt(int index) {
    setState(() {
      _pickupBins.removeAt(index);
    });
  }

  Future<void> _fetchExistingData() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      final ref = _database.child("WMS/${user.uid}/wasteManagementInfo");
      final snapshot = await ref.get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          _companyNameCtrl.text = data['CompanyName'] ?? '';
          _directorNameCtrl.text = data['DirectorName'] ?? '';
          _landmarkCtrl.text = data['landmark'] ?? '';
          _locationCtrl.text = data['location'] ?? '';
          _gpsCtrl.text = data['gps'] ?? '';
          _employeesCtrl.text = data['employees'] ?? '';
          _phoneCtrl.text = data['ghMobileNumber'] ?? '';
          _ghanaCardCtrl.text = data['ghanaCardNumber'] ?? '';
          _acceptScheduledRequests = data['acceptScheduledRequests'] ?? false;
          _acceptSubscriptionRequests = data['acceptSubscriptionRequests'] ?? false;

          if (data['pickupBins'] != null) {
            final List<dynamic> binsData = data['pickupBins'];
            _pickupBins = binsData.map((bin) {
              final c = TextEditingController(text: bin['price']?.toString() ?? '');
              return _BinItem(
                imagePath: bin['image'],
                typeName: bin['bintypename'],
                priceController: c,
              );
            }).toList();
          }
        });
      }
    } catch (e) {
      print("Error loading data: $e");
    }
  }

  // -------- Location & GPS Auto-fetch ----------
  Future<void> _getCurrentLocation() async {
    setState(() => _isFetchingLocation = true);

    // 1. Check permissions
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationError("Location services are disabled. Please enable them.");
      setState(() => _isFetchingLocation = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showLocationError("Location permission denied. Cannot fetch location.");
        setState(() => _isFetchingLocation = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showLocationError("Location permission permanently denied. Please enable from app settings.");
      setState(() => _isFetchingLocation = false);
      return;
    }

    try {
      // 2. Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 3. Reverse geocoding to get address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address = [
          place.street,
          place.locality,
          place.administrativeArea,
          place.postalCode,
          place.country
        ].where((e) => e != null && e.isNotEmpty).join(", ");

        // Update both fields
        setState(() {
          _locationCtrl.text = address;
          _gpsCtrl.text = "${position.latitude}, ${position.longitude}";
        });
      } else {
        // Fallback: only coordinates
        setState(() {
          _gpsCtrl.text = "${position.latitude}, ${position.longitude}";
          _locationCtrl.text = "Unknown address (coordinates only)";
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location updated successfully"), backgroundColor: Colors.green),
      );
    } catch (e) {
      _showLocationError("Failed to get location: $e");
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  void _showLocationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  void dispose() {
    _companyNameCtrl.dispose();
    _directorNameCtrl.dispose();
    _landmarkCtrl.dispose();
    _locationCtrl.dispose();
    _gpsCtrl.dispose();
    _employeesCtrl.dispose();
    _phoneCtrl.dispose();
    _ghanaCardCtrl.dispose();
    for (var bin in _pickupBins) {
      bin.priceController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Service Preferences", Icons.toggle_on),
            const SizedBox(height: 8),
            _buildToggleCard(
              title: "Accept scheduled requests",
              subtitle: "Customers can book a pickup for a future date/time.",
              value: _acceptScheduledRequests,
              onChanged: (v) => setState(() => _acceptScheduledRequests = v),
            ),
            const SizedBox(height: 12),
            _buildToggleCard(
              title: "Accept subscription requests",
              subtitle: "Allow customers to sign up for recurring waste collection.",
              value: _acceptSubscriptionRequests,
              onChanged: (v) => setState(() => _acceptSubscriptionRequests = v),
            ),
            const SizedBox(height: 28),

            _buildSectionHeader("Pickup Bins", Icons.delete_sweep),
            const SizedBox(height: 4),
            Text(
              "Add the types of bins you collect and your price per bin.",
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _pickupBins.isEmpty
                  ? _buildEmptyBinsPlaceholder()
                  : Column(
                children: _pickupBins.asMap().entries.map((entry) {
                  return _buildBinCard(entry.value, entry.key);
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: OutlinedButton.icon(
                onPressed: _addEmptyBin,
                icon: const Icon(Icons.add, size: 18),
                label: const Text("Add another bin"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green.shade700,
                  side: BorderSide(color: Colors.green.shade300),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
            const SizedBox(height: 28),

            _buildSectionHeader("Company Details", Icons.business),
            const SizedBox(height: 16),
            _buildUploadTilesRow(),
            const SizedBox(height: 24),
            _buildTextField(_companyNameCtrl, Icons.business, "Company Name", "Enter legal name"),
            _buildTextField(_directorNameCtrl, Icons.person, "Director Name", "Full name of director"),
            _buildTextField(_landmarkCtrl, Icons.landscape, "Landmark", "Nearby landmark or area"),
            // Location field with suffix icon
            _buildTextField(
              _locationCtrl,
              Icons.location_on,
              "Location",
              "Full address (auto-fetch available)",
              suffixIcon: _isFetchingLocation
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : IconButton(
                icon: Icon(Icons.my_location, color: Colors.green.shade700),
                onPressed: _getCurrentLocation,
                tooltip: "Get current location",
              ),
            ),
            // GPS Address field with suffix icon
            _buildTextField(
              _gpsCtrl,
              Icons.gps_fixed,
              "GPS Address",
              "e.g. GA-123-4567 or auto-filled coordinates",
              suffixIcon: _isFetchingLocation
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : IconButton(
                icon: Icon(Icons.gps_not_fixed, color: Colors.green.shade700),
                onPressed: _getCurrentLocation,
                tooltip: "Get current GPS coordinates",
              ),
            ),
            _buildTextField(_employeesCtrl, Icons.people, "Number of Employees", "Total staff count", isNumber: true),
            _buildTextField(_phoneCtrl, Icons.phone, "Phone Number", "e.g. 024XXXXXXX", isNumber: true),
            _buildTextField(_ghanaCardCtrl, Icons.card_membership, "Ghana Card Number", "e.g. GHA-123456789-1"),
            const SizedBox(height: 32),

            _buildSubmitButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ==================== UI Components ====================

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.green.shade700, size: 28),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
        ),
      ],
    );
  }

  Widget _buildToggleCard({required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.green,
        activeTrackColor: Colors.green.shade100,
      ),
    );
  }

  Widget _buildEmptyBinsPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(Icons.delete_outline, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text("No bins added", style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text("Tap '+' to add your first bin", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildBinCard(_BinItem bin, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 90,
                      height: 90,
                      color: Colors.grey.shade100,
                      child: Image.asset(
                        bin.imagePath ?? 'assets/images/choose.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(Icons.image_not_supported, color: Colors.grey.shade400),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: bin.imagePath != null && bin.typeName != null
                              ? '${bin.imagePath}|${bin.typeName}'
                              : null,
                          decoration: InputDecoration(
                            labelText: "Bin Type",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          items: const [
                            DropdownMenuItem(child: Text('Borla Extra - 660L'), value: 'assets/images/660l.png|Borla Extra - 660L'),
                            DropdownMenuItem(child: Text('Borla Plus - 360L'), value: 'assets/images/360l.png|Borla Plus - 360L'),
                            DropdownMenuItem(child: Text('Borla Large - 240L'), value: 'assets/images/240L.png|Borla Large - 240L'),
                            DropdownMenuItem(child: Text('Borla Standard - 140L'), value: 'assets/images/140.png|Borla Standard - 140L'),
                            DropdownMenuItem(child: Text('Borla Medium - 100L'), value: 'assets/images/100l.png|Borla Medium - 100L'),
                            DropdownMenuItem(child: Text('Borla Bag'), value: 'assets/images/plasticbag.png|Borla Bag'),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              final parts = value.split('|');
                              setState(() {
                                bin.imagePath = parts[0];
                                bin.typeName = parts[1];
                              });
                            }
                          },
                          validator: (v) => v == null ? 'Select bin type' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: bin.priceController,
                          decoration: InputDecoration(
                            labelText: "Price (GHS)",
                            prefixIcon: Icon(Icons.attach_money, color: Colors.green.shade600),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Enter price';
                            if (double.tryParse(v) == null) return 'Enter a valid number';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => _showRemoveBinDialog(index),
                  tooltip: "Remove bin",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRemoveBinDialog(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Remove bin"),
        content: const Text("Are you sure you want to remove this bin type?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeBinAt(index);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Remove"),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadTilesRow() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.spaceEvenly,
      children: [
        _buildUploadTile("Company Logo", Icons.business_center, _logoFile, (f) => _logoFile = f, () => _logoFile = null),
        _buildUploadTile("Business Reg.", Icons.description, _compRegFile, (f) => _compRegFile = f, () => _compRegFile = null),
        _buildUploadTile("Reg. Document", Icons.assignment, _registrationDocFile, (f) => _registrationDocFile = f, () => _registrationDocFile = null),
      ],
    );
  }

  Widget _buildUploadTile(String title, IconData icon, File? file, Function(File) onPick, VoidCallback onRemove) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: () async {
                final result = await _picker.pickImage(source: ImageSource.gallery);
                if (result != null) onPick(File(result.path));
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: file != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(file, fit: BoxFit.cover),
                )
                    : Icon(icon, size: 40, color: Colors.grey.shade500),
              ),
            ),
            if (file != null)
              Positioned(
                top: -8,
                right: -8,
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.redAccent,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.close, size: 14, color: Colors.white),
                    onPressed: onRemove,
                  ),
                ),
              ),
          ],
        ),
        if (file != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              file.path.split('/').last.length > 15
                  ? '${file.path.split('/').last.substring(0, 12)}...'
                  : file.path.split('/').last,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController ctrl, IconData icon, String label, String hint,
      {bool isNumber = false, Widget? suffixIcon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.green.shade600),
          labelText: label,
          hintText: hint,
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.green.shade400, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return '$label is required';
          if (isNumber && label == 'Phone Number' && !RegExp(r'^0[0-9]{9}$').hasMatch(value.trim())) {
            return 'Enter a valid 10-digit phone number';
          }
          if (label == 'Ghana Card Number' && value.trim().length < 10) {
            return 'Enter a valid Ghana Card number';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: SizedBox(
        width: 220,
        height: 52,
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)]),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Container(
              alignment: Alignment.center,
              child: _isSubmitting
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
                  : const Text('Submit Details', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== Submission Logic ====================

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickupBins.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least one pickup bin")),
      );
      return;
    }

    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not logged in')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final logoUrl = _logoFile != null ? await _uploadFile(_logoFile!, 'CompanyLogo') : null;
      final compRegUrl = _compRegFile != null ? await _uploadFile(_compRegFile!, 'CompanyRegistration') : null;
      final regDocUrl = _registrationDocFile != null ? await _uploadFile(_registrationDocFile!, 'BusinessRegistration') : null;

      final binsData = _pickupBins.map((bin) => {
        'image': bin.imagePath,
        'bintypename': bin.typeName,
        'price': bin.priceController.text.trim(),
      }).toList();

      final formData = {
        'pickupBins': binsData,
        'WMSTYPE': 'WMS',
        'CompanyName': _companyNameCtrl.text.trim(),
        'DirectorName': _directorNameCtrl.text.trim(),
        'logoUrl': logoUrl,
        'compRegUrl': compRegUrl,
        'registrationDocUrl': regDocUrl,
        'detailsComp': true,
        'gps': _gpsCtrl.text.trim(),
        'landmark': _landmarkCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'employees': _employeesCtrl.text.trim(),
        'ghMobileNumber': _phoneCtrl.text.trim(),
        'ghanaCardNumber': _ghanaCardCtrl.text.trim(),
        'acceptScheduledRequests': _acceptScheduledRequests,
        'acceptSubscriptionRequests': _acceptSubscriptionRequests,
      };

      await _database
          .child('WMS')
          .child(user.uid)
          .child('wasteManagementInfo')
          .update(formData);
      await _database.child('WMS').child(user.uid).update({'detailsComp': true});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data submitted successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<String> _uploadFile(File file, String folder) async {
    final ref = _storage.ref().child('$folder/${Path.basename(file.path)}');
    final upload = await ref.putFile(file);
    return await upload.ref.getDownloadURL();
  }
}

class _BinItem {
  String? imagePath;
  String? typeName;
  final TextEditingController priceController;

  _BinItem({this.imagePath, this.typeName, TextEditingController? priceController})
      : priceController = priceController ?? TextEditingController();
}