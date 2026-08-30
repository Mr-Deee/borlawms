import 'dart:io';
import 'dart:ui';
import 'package:borlawms/pages/progressdialog.dart';
import 'package:borlawms/pages/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'addwmsdetails.dart';

final DatabaseReference WMSDB = FirebaseDatabase.instance.ref().child("WMS");

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> with SingleTickerProviderStateMixin {
  // Controllers
  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _usernamecontroller = TextEditingController();
  final TextEditingController _phonecontroller = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Image data
  dynamic _riderImage;
  final ImagePicker _imagePicker = ImagePicker();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _agreeToTerms = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  User? firebaseUser;
  User? currentfirebaseUser;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
    _emailcontroller.dispose();
    _usernamecontroller.dispose();
    _phonecontroller.dispose();
    _passwordcontroller.dispose();
    _confirmPasswordController.dispose();
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
    Colors.black.withOpacity(0.3),
    Colors.black.withOpacity(0.6),
    ],
    ),
    ),
    ),

    // Blur Effect
    Positioned.fill(
    child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
    child: Container(
    color: Colors.black.withOpacity(0.2),
    ),
    ),
    ),

    // Main Content
    SafeArea(
    child: FadeTransition(
    opacity: _fadeAnimation,
    child: Center(
    child: SingleChildScrollView(
    physics: const BouncingScrollPhysics(),
    padding: const EdgeInsets.symmetric(horizontal: 24.0),
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    // Header
    _buildHeader(),

    const SizedBox(height: 24),

    // Profile Image
    _buildProfileImage(),

    const SizedBox(height: 24),

    // Form
    Form(
    key: _formKey,
    child: Column(
    children: [
    _buildTextField(
    controller: _usernamecontroller,
    hintText: "Username",
    icon: Icons.person_outline_rounded,
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please enter your username';
    }
    if (value.length < 3) {
    return 'Username must be at least 3 characters';
    }
    return null;
    },
    ),
    const SizedBox(height: 14),
    _buildTextField(
    controller: _phonecontroller,
    hintText: "Phone Number",
    icon: Icons.phone_outlined,
    keyboardType: TextInputType.phone,
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please enter your phone number';
    }
    if (value.length < 10) {
    return 'Please enter a valid phone number';
    }
    return null;
    },
    ),
    const SizedBox(height: 14),
    _buildTextField(
    controller: _emailcontroller,
    hintText: "Email Address",
    icon: Icons.email_outlined,
    keyboardType: TextInputType.emailAddress,
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
    return 'Please enter a valid email';
    }
    return null;
    },
    ),
    const SizedBox(height: 14),
    _buildPasswordField(
    controller: _passwordcontroller,
    hintText: "Password",
    obscureText: _obscurePassword,
    onToggle: () {
    setState(() {
    _obscurePassword = !_obscurePassword;
    });
    },
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please enter a password';
    }
    if (value.length < 6) {
    return 'Password must be at least 6 characters';
    }
    return null;
    },
    ),
    const SizedBox(height: 14),
    _buildPasswordField(
    controller: _confirmPasswordController,
    hintText: "Confirm Password",
    obscureText: _obscureConfirmPassword,
    onToggle: () {
    setState(() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    });
    },
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please confirm your password';
    }
    if (value != _passwordcontroller.text) {
    return 'Passwords do not match';
    }
    return null;
    },
    ),
    ],
    ),
    ),

    const SizedBox(height: 20),

    // Terms and Conditions
    _buildTermsAndConditions(),

    const SizedBox(height: 20),

    // Sign Up Button
    _buildSignUpButton(),

    const SizedBox(height: 16),

    // Sign In Link
    _buildSignInLink(),

    const SizedBox(height: 20),
    ]
    ),
    ),
    ),
    ),
    ),

    // Loading Overlay
    if (_isLoading) _buildLoadingOverlay(),
    ],
    ),
    );
    }

  // ==================== UI Components ====================

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Image.asset(
            'assets/images/wms.png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "Create Account",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Join us and start managing waste efficiently",
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.7),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF19AF5F).withOpacity(0.3),
                    const Color(0xFF0D7C3F).withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF19AF5F).withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipOval(
                child: _riderImage != null
                    ? (kIsWeb
                    ? Image.memory(
                  _riderImage as Uint8List,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                )
                    : Image.file(
                  _riderImage as File,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ))
                    : Image.asset(
                  "assets/images/imgicon.png",
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF19AF5F),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF19AF5F).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _riderImage != null ? "Tap to change" : "Add profile photo",
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: Colors.white.withOpacity(0.5),
          ),
          hintText: hintText,
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.lock_outline_rounded,
            color: Colors.white.withOpacity(0.5),
          ),
          suffixIcon: IconButton(
            onPressed: onToggle,
            icon: Icon(
              obscureText
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.white.withOpacity(0.5),
              size: 20,
            ),
          ),
          hintText: hintText,
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

  Widget _buildTermsAndConditions() {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _agreeToTerms,
            onChanged: (value) {
              setState(() {
                _agreeToTerms = value ?? false;
              });
            },
            activeColor: const Color(0xFF19AF5F),
            checkColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            side: BorderSide(
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.7),
              ),
              children: [
                const TextSpan(text: "I agree to the "),
                TextSpan(
                  text: "Terms of Service",
                  style: const TextStyle(
                    color: Color(0xFF19AF5F),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: " and "),
                TextSpan(
                  text: "Privacy Policy",
                  style: const TextStyle(
                    color: Color(0xFF19AF5F),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: (_isLoading || !_agreeToTerms) ? null : () => _registerUser(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF19AF5F),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          disabledBackgroundColor: Colors.grey.shade600,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Create Account",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_rounded,
              size: 20,
              color: Colors.white.withOpacity(0.8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SignIn()),
            );
          },
          child: const Text(
            "Sign In",
            style: TextStyle(
              color: Color(0xFF19AF5F),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 40,
                width: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF19AF5F)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Creating your account...",
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== Functions ====================

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _riderImage = bytes;
          });
        } else {
          setState(() {
            _riderImage = File(pickedFile.path);
          });
        }
        Fluttertoast.showToast(
          msg: "Image selected successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error picking image: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<String> _uploadImageToStorage(dynamic imageData) async {
    if (imageData == null) return '';

    final String fileName = 'profile_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

    try {
      if (kIsWeb) {
        await storageRef.putData(imageData as Uint8List);
      } else {
        await storageRef.putFile(imageData as File);
      }
      final String downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Image upload failed: $e');
      return '';
    }
  }

  Future<void> _registerUser(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreeToTerms) {
      Fluttertoast.showToast(
        msg: "Please agree to the Terms and Conditions",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: _emailcontroller.text.trim(),
        password: _passwordcontroller.text.trim(),
      );

      firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Upload image
        final riderImageUrl = await _uploadImageToStorage(_riderImage);

        // Send email verification
        await firebaseUser!.sendEmailVerification();

        // Save user data
        Map<String, dynamic> userDataMap = {
          'riderImageUrl': riderImageUrl,
          'email': _emailcontroller.text.trim(),
          'Username': _usernamecontroller.text.trim(),
          'phone': _phonecontroller.text.trim(),
          'Password': _passwordcontroller.text.trim(),
          'detailsComp': false,
          'createdAt': DateTime.now().toIso8601String(),
          'uid': firebaseUser!.uid,
        };

        await WMSDB.child(firebaseUser!.uid).set(userDataMap);

        currentfirebaseUser = firebaseUser;

        setState(() => _isLoading = false);

        // Show success messages
        Fluttertoast.showToast(
          msg: "Account created successfully!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        Fluttertoast.showToast(
          msg: "Verification email sent to your inbox",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
        );

        // Navigate to next screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AddWmsDetails()),
              (Route<dynamic> route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      String message = _getAuthErrorMessage(e);
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } catch (e) {
      setState(() => _isLoading = false);
      Fluttertoast.showToast(
        msg: "An error occurred: ${e.toString()}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please sign in.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      default:
        return 'Registration failed: ${e.message}';
    }
  }
}