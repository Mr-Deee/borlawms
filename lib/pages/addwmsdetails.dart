import 'dart:io';
import 'dart:ui';
import 'package:borlawms/pages/progressdialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:borlawms/pages/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_selector/file_selector.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../widgets/BinSale.dart';
import '../widgets/RecycleForm.dart';
import '../widgets/WMSFORM.dart';

class AddWmsDetails extends StatefulWidget {
  const AddWmsDetails({super.key});

  @override
  State<AddWmsDetails> createState() => _AddWmsDetailsState();
}

class _AddWmsDetailsState extends State<AddWmsDetails> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _database = FirebaseDatabase.instance.ref();
  final _storage = FirebaseStorage.instance;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<Map<String, dynamic>> _pickupBins = [];
  List<Map<String, dynamic>> _sellingBins = [];
  bool _sellsBins = false;
  File? _logoFile;
  File? _CompRegFile;
  File? _registrationDocFile;
  Uint8List? _registrationDocBytes;
  String _selectedType = 'Waste Management Service';
  bool _acceptScheduledRequests = false;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg4.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),

          // Blur Effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.black.withOpacity(0.1),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      _buildHeader(),
                      const SizedBox(height: 24),

                      // Stepper Progress
                      _buildStepper(),
                      const SizedBox(height: 24),

                      // Type Selection
                      _buildTypeSelection(),
                      const SizedBox(height: 20),

                      // Conditional Forms
                      _buildConditionalForm(),
                      const SizedBox(height: 24),

                      // Submit Button
                      _buildSubmitButton(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== UI Components ====================

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF19AF5F).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF19AF5F).withOpacity(0.3),
                ),
              ),
              child: const Icon(
                Icons.business_center_rounded,
                color: Color(0xFF19AF5F),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Complete Your Profile",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  "Tell us more about your business",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          _buildStepIndicator(0, "Type"),
          Expanded(
            child: Container(
              height: 2,
              color: _currentStep > 0
                  ? const Color(0xFF19AF5F)
                  : Colors.white.withOpacity(0.2),
            ),
          ),
          _buildStepIndicator(1, "Details"),
          Expanded(
            child: Container(
              height: 2,
              color: _currentStep > 1
                  ? const Color(0xFF19AF5F)
                  : Colors.white.withOpacity(0.2),
            ),
          ),
          _buildStepIndicator(2, "Files"),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = _currentStep >= step;
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFF19AF5F) : Colors.white.withOpacity(0.2),
            border: Border.all(
              color: isActive ? const Color(0xFF19AF5F) : Colors.white.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              "${step + 1}",
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white60,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? Colors.white70 : Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSelection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Select Service Type",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedType,
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.category_rounded,
                  color: Color(0xFF19AF5F),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Waste Management Service',
                  child: Text('Waste Management Service'),
                ),
                DropdownMenuItem(
                  value: 'Recycling',
                  child: Text('Recycling'),
                ),
                DropdownMenuItem(
                  value: 'Bin Sale',
                  child: Text('Bin Sale'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionalForm() {
    switch (_selectedType) {
      case 'Waste Management Service':
        return WasteManagementForm();
      case 'Recycling':
        return RecyclingForm();
      case 'Bin Sale':
        return SellingBinsWidget();
      default:
        return Container();
    }
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF19AF5F),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle_rounded, size: 20),
            SizedBox(width: 8),
            Text(
              "Submit & Continue",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Helper Methods ====================

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return  ProgressDialog(message: "Saving your details...");
      },
    );

    try {
      User? user = _auth.currentUser;
      if (user == null) {
        if (mounted) {
          Navigator.of(context).pop();
          _showSnackBar("User not signed in", Colors.red);
        }
        return;
      }

      String userId = user.uid;

      // Upload files
      String? logoUrl;
      String? CompRegUrl;
      String? regDocUrl;

      if (_logoFile != null) {
        logoUrl = await _uploadFile(_logoFile!, 'company_logos');
      }
      if (_CompRegFile != null) {
        CompRegUrl = await _uploadFile(_CompRegFile!, 'Comp_reg');
      }
      if (_registrationDocFile != null) {
        regDocUrl = await _uploadFile(_registrationDocFile!, 'registration_documents');
      }

      // Build form data
      Map<String, dynamic> formData = {
        'pickupBins': _pickupBins,
        'sellsBins': _sellsBins,
        'sellingBins': _sellingBins,
        'logoUrl': logoUrl ?? '',
        'BusinessCertUrl': CompRegUrl ?? '',
        'registrationDocUrl': regDocUrl ?? '',
        'landmark': _landmarkController.text.toString(),
        'location': _locationController.text.toString(),
        'employeesCount': _employeesController.text.toString(),
        'ghMobileNumber': _ghMobileNumberController.text.toString(),
        'ghanaCardNumber': _ghanaCardNumberController.text.toString(),
        'availableFor': _acceptScheduledRequests ? 'scheduled' : 'instant',
        'WMSTYPE': _selectedType,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Save to database
      await _database
          .child('WMS')
          .child(userId)
          .child('wasteManagementInfo')
          .set(formData);

      // Update root WMS node
      await _database.child('WMS').child(userId).update({
        'availableFor': _acceptScheduledRequests ? 'scheduled' : 'instant',
        'detailsComp': true,
        'WMSTYPE': _selectedType,
      });

      if (mounted) {
        Navigator.of(context).pop(); // close progress dialog

        // Show success message
        _showSnackBar("Profile completed successfully!", Colors.green);

        // Navigate back to SignIn
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SignIn()),
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // close progress dialog
        _showSnackBar("Error: ${e.toString()}", Colors.red);
      }
    }
  }

  Future<String> _uploadFile(File file, String folderName) async {
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_${Path.basename(file.path)}';
      Reference reference = _storage.ref().child('$folderName/$fileName');
      UploadTask uploadTask = reference.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Upload failed: $e');
      return '';
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// ==================== Text Editing Controllers ====================
TextEditingController _landmarkController = TextEditingController();
TextEditingController _locationController = TextEditingController();
TextEditingController _employeesController = TextEditingController();
TextEditingController _ghMobileNumberController = TextEditingController();
TextEditingController _ghanaCardNumberController = TextEditingController();
Uint8List? _registrationDocBytes;

// ==================== WASTE MANAGEMENT FORM ====================
class WasteManagementForm extends StatefulWidget {
  const WasteManagementForm({super.key});

  @override
  State<WasteManagementForm> createState() => _WasteManagementFormState();
}

class _WasteManagementFormState extends State<WasteManagementForm> {
  final ImagePicker _imagePicker = ImagePicker();
  File? _logoFile;
  File? _CompRegFile;
  List<Map<String, dynamic>> _pickupBins = [];
  bool _acceptScheduledRequests = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Business Information", Icons.business_rounded),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _landmarkController,
            hint: "Landmark / Location Description",
            icon: Icons.location_on_rounded,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _locationController,
            hint: "Detailed Location",
            icon: Icons.map_rounded,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _employeesController,
            hint: "Number of Employees",
            icon: Icons.people_rounded,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _ghMobileNumberController,
            hint: "Ghana Mobile Number",
            icon: Icons.phone_android_rounded,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _ghanaCardNumberController,
            hint: "Ghana Card Number",
            icon: Icons.credit_card_rounded,
          ),
          const SizedBox(height: 20),

          _buildSectionTitle("Business Documents", Icons.description_rounded),
          const SizedBox(height: 12),
          _buildImageUploadButton(
            label: "Upload Company Logo",
            icon: Icons.image_rounded,
            onPressed: () async {
              final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
              if (pickedFile != null) {
                setState(() {
                  _logoFile = File(pickedFile.path);
                });
              }
            },
            file: _logoFile,
          ),
          const SizedBox(height: 12),
          _buildImageUploadButton(
            label: "Upload Business Registration",
            icon: Icons.assignment_rounded,
            onPressed: () async {
              final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
              if (pickedFile != null) {
                setState(() {
                  _CompRegFile = File(pickedFile.path);
                });
              }
            },
            file: _CompRegFile,
          ),
          const SizedBox(height: 20),

          _buildSectionTitle("Schedule Preferences", Icons.schedule_rounded),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Accept Scheduled Requests",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "Allow customers to schedule pickups in advance",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _acceptScheduledRequests,
                  onChanged: (value) {
                    setState(() {
                      _acceptScheduledRequests = value;
                    });
                  },
                  activeColor: const Color(0xFF19AF5F),
                  inactiveTrackColor: Colors.white.withOpacity(0.2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF19AF5F), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $hint';
          }
          return null;
        },
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.4)),
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.4),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          errorStyle: TextStyle(
            color: Colors.red.shade300,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    File? file,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF19AF5F), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  file != null ? Path.basename(file.path) : label,
                  style: TextStyle(
                    color: file != null ? Colors.white : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
              Icon(
                file != null ? Icons.check_circle_rounded : Icons.cloud_upload_rounded,
                color: file != null ? const Color(0xFF19AF5F) : Colors.white.withOpacity(0.3),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== RECYCLING FORM ====================
class RecyclingForm extends StatefulWidget {
  const RecyclingForm({super.key});

  @override
  State<RecyclingForm> createState() => _RecyclingFormState();
}

class _RecyclingFormState extends State<RecyclingForm> {
  final ImagePicker _imagePicker = ImagePicker();
  File? _logoFile;
  File? _CompRegFile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Recycling Information", Icons.recycling_rounded),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _landmarkController,
            hint: "Landmark / Location Description",
            icon: Icons.location_on_rounded,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _locationController,
            hint: "Detailed Location",
            icon: Icons.map_rounded,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _ghMobileNumberController,
            hint: "Ghana Mobile Number",
            icon: Icons.phone_android_rounded,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),
          _buildSectionTitle("Business Documents", Icons.description_rounded),
          const SizedBox(height: 12),
          _buildImageUploadButton(
            label: "Upload Company Logo",
            icon: Icons.image_rounded,
            onPressed: () async {
              final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
              if (pickedFile != null) {
                setState(() {
                  _logoFile = File(pickedFile.path);
                });
              }
            },
            file: _logoFile,
          ),
          const SizedBox(height: 12),
          _buildImageUploadButton(
            label: "Upload Business Registration",
            icon: Icons.assignment_rounded,
            onPressed: () async {
              final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
              if (pickedFile != null) {
                setState(() {
                  _CompRegFile = File(pickedFile.path);
                });
              }
            },
            file: _CompRegFile,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFFA726), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $hint';
          }
          return null;
        },
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.4)),
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.4),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          errorStyle: TextStyle(
            color: Colors.red.shade300,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    File? file,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFFFFA726), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  file != null ? Path.basename(file.path) : label,
                  style: TextStyle(
                    color: file != null ? Colors.white : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
              Icon(
                file != null ? Icons.check_circle_rounded : Icons.cloud_upload_rounded,
                color: file != null ? const Color(0xFFFFA726) : Colors.white.withOpacity(0.3),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== SELLING BINS WIDGET ====================
class SellingBinsWidget extends StatefulWidget {
  const SellingBinsWidget({super.key});

  @override
  State<SellingBinsWidget> createState() => _SellingBinsWidgetState();
}

class _SellingBinsWidgetState extends State<SellingBinsWidget> {
  List<Map<String, dynamic>> _sellingBins = [];
  final ImagePicker _imagePicker = ImagePicker();
  File? _logoFile;
  File? _CompRegFile;

  void _addBin() {
    setState(() {
      _sellingBins.add({
        'image': null,
        'price': '',
        'binType': '',
      });
    });
  }

  void _removeBin(int index) {
    setState(() {
      _sellingBins.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Bin Sale Information", Icons.shopping_cart_rounded),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _landmarkController,
            hint: "Landmark / Location Description",
            icon: Icons.location_on_rounded,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _locationController,
            hint: "Detailed Location",
            icon: Icons.map_rounded,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _ghMobileNumberController,
            hint: "Ghana Mobile Number",
            icon: Icons.phone_android_rounded,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),
          _buildSectionTitle("Bins for Sale", Icons.inventory_rounded),
          const SizedBox(height: 12),
          ..._sellingBins.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> bin = entry.value;
            return _buildBinCard(bin, index);
          }),
          const SizedBox(height: 12),
          _buildAddBinButton(),
          const SizedBox(height: 20),
          _buildSectionTitle("Business Documents", Icons.description_rounded),
          const SizedBox(height: 12),
          _buildImageUploadButton(
            label: "Upload Company Logo",
            icon: Icons.image_rounded,
            onPressed: () async {
              final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
              if (pickedFile != null) {
                setState(() {
                  _logoFile = File(pickedFile.path);
                });
              }
            },
            file: _logoFile,
          ),
          const SizedBox(height: 12),
          _buildImageUploadButton(
            label: "Upload Business Registration",
            icon: Icons.assignment_rounded,
            onPressed: () async {
              final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
              if (pickedFile != null) {
                setState(() {
                  _CompRegFile = File(pickedFile.path);
                });
              }
            },
            file: _CompRegFile,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF42A5F5), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $hint';
          }
          return null;
        },
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.4)),
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.4),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          errorStyle: TextStyle(
            color: Colors.red.shade300,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildBinCard(Map<String, dynamic> bin, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: bin['binType'],
                  style: const TextStyle(color: Colors.white),
                  dropdownColor: Colors.grey[900],
                  decoration: InputDecoration(
                    labelText: 'Bin Type',
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    border: InputBorder.none,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Borla Extra - 660L', child: Text('Borla Extra - 660L')),
                    DropdownMenuItem(value: 'Borla Plus - 360L', child: Text('Borla Plus - 360L')),
                    DropdownMenuItem(value: 'Borla Large - 240L', child: Text('Borla Large - 240L')),
                    DropdownMenuItem(value: 'Borla Standard - 140L', child: Text('Borla Standard - 140L')),
                    DropdownMenuItem(value: 'Borla Medium - 100L', child: Text('Borla Medium - 100L')),
                    DropdownMenuItem(value: 'Borla Bag', child: Text('Borla Bag')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      bin['binType'] = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => _removeBin(index),
                icon: const Icon(Icons.delete_rounded, color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Price (GHS)',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
              prefixIcon: const Icon(Icons.attach_money_rounded, color: Color(0xFF42A5F5)),
              border: InputBorder.none,
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              bin['price'] = value;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddBinButton() {
    return Container(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _addBin,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: const Color(0xFF42A5F5).withOpacity(0.3),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_rounded, color: Color(0xFF42A5F5)),
            const SizedBox(width: 8),
            Text(
              "Add Bin for Sale",
              style: TextStyle(
                color: const Color(0xFF42A5F5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    File? file,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF42A5F5), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  file != null ? Path.basename(file.path) : label,
                  style: TextStyle(
                    color: file != null ? Colors.white : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
              Icon(
                file != null ? Icons.check_circle_rounded : Icons.cloud_upload_rounded,
                color: file != null ? const Color(0xFF42A5F5) : Colors.white.withOpacity(0.3),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}