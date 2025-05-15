import 'dart:async';
import 'dart:io';

import 'package:borlawms/Assistant/assistantmethods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../Model/WMSDB.dart';
import 'RecyclerMapRoute.dart';

class RecyclePage extends StatefulWidget {
  const RecyclePage({super.key});

  @override
  State<RecyclePage> createState() => _RecyclePageState();
}

class _RecyclePageState extends State<RecyclePage> {
  int _currentIndex = 0;

  // List of pages
  final List<Widget> _pages = [
    DashboardPage(),
    WalletPage(),
    RecyclingCompanyProfile(),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AssistantMethod.getCurrentOnlineUserInfo(context);
  }

  @override
  Widget build(BuildContext context) {
    var email = Provider.of<WMS>(context, listen: false).riderInfo?.email ?? "";
    var fclientname =
        Provider.of<WMS>(context, listen: false).riderInfo?.firstname ?? "";
    var lclientname =
        Provider.of<WMS>(context, listen: false).riderInfo?.lastname ?? "";
    var phoneNumber =
        Provider.of<WMS>(context, listen: false).riderInfo?.phone ?? "";
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  TextEditingController searchController = TextEditingController();
  String selectedCategory = 'All'; // Default dropdown value
  List<Map<dynamic, dynamic>> allItems = [];
  List<Map<dynamic, dynamic>> filteredItems = [];


  void fetchData() async {
    final database = FirebaseDatabase.instance.ref('recycle_items');
    final snapshot = await database.get();

    if (snapshot.value != null) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      List<Map<dynamic, dynamic>> items = data.entries.map((entry) {
        return {
          'key': entry.key,
          ...entry.value as Map<dynamic, dynamic>,
        };
      }).toList();

      setState(() {
        allItems = items;
        filteredItems = allItems;
      });
    }
  }

  void filterItems(String query, String category) {
    setState(() {
      filteredItems = allItems.where((item) {
        final itemType = item['RecycleType']?.toString().toLowerCase() ?? '';
        final description = item['description']?.toString().toLowerCase() ?? '';
        final matchesQuery = query.isEmpty ||
            itemType.contains(query.toLowerCase()) ||
            description.contains(query.toLowerCase());
        final matchesCategory =
            category == 'All' || itemType == category.toLowerCase();

        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  Future<void> openGoogleMaps(String location) async {
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location)}');

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }


  String email = "";
  String fclientname = "";
  String lclientname = "";
  String phoneNumber = "";
  bool isDataLoaded = false;

  final List<String> categories = ['All', 'Plastic', 'Metal', 'Glass'];

  @override
  void initState() {
    super.initState();
    fetchData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final riderInfo = Provider.of<WMS>(context, listen: false).riderInfo;
      setState(() {
        email = riderInfo?.email ?? "";
        fclientname = riderInfo?.firstname ?? "";
        lclientname = riderInfo?.lastname ?? "";
        phoneNumber = riderInfo?.phone ?? "";
        isDataLoaded = true;
      });
    });
  }

  String getTimeBasedSalutation() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  // void filterItems(String query, String category) {
  //   // TODO: Implement filtering logic
  //   // Example:
  //   // filteredItems = allItems.where((item) => item['RecycleType'].contains(query)).toList();
  //   setState(() {});
  // }

  // void openGoogleMaps(String? location) {
  //   // TODO: Implement map opening
  //   // You can use url_launcher package
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _showSignOutDialog(context),
          ),
        ],
      ),
      body: isDataLoaded
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${getTimeBasedSalutation()}, $fclientname!',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildStatsCard(),
            const SizedBox(height: 20),
            _buildSearchAndFilter(),
            const SizedBox(height: 20),
            Expanded(child: _buildItemList()),
          ],
        ),
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Waste Collected',
              style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: 0.75,
            backgroundColor: Colors.grey[300],
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: searchController,
            onChanged: (value) => filterItems(value, selectedCategory),
            decoration: InputDecoration(
              hintText: 'Search recycle items...',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              suffixIcon: const Icon(Icons.search, color: Colors.green),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () async {
            final String? selected = await showDialog<String>(
              context: context,
              builder: (context) => SimpleDialog(
                title: const Text('Select Category'),
                children: categories
                    .map((category) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, category),
                  child: Text(category),
                ))
                    .toList(),
              ),
            );
            if (selected != null) {
              setState(() {
                selectedCategory = selected;
                filterItems(searchController.text, selectedCategory);
              });
            }
          },
          child: Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.filter_alt_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildItemList() {
    return filteredItems.isEmpty
        ? const Center(child: Text('No items found'))
        : ListView.builder(
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return GestureDetector(
          onTap: (){
            final locationData = item['client_Coordinates']; // should be a Map with 'lat' and 'lng'
            final destination = LatLng(locationData['latitude'], locationData['longitude']);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MapRoutePage(
                  destination: destination,
                  weight: item['weight'] ?? '0kg',
                  paused: item['paused'] ?? 'No',
                ),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: item['image_url'] != null
                  ? Image.network(
                item['image_url'],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
                  : const Icon(Icons.image_not_supported),
              title: Text(item['RecycleType'] ?? 'Unknown'),
              subtitle:
              Text(item['description'] ?? 'No description available'),
              trailing: IconButton(
                icon: const Icon(Icons.directions),
                onPressed: () => openGoogleMaps(item['location']),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you certain you want to sign out?'),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Yes', style: TextStyle(color: Colors.black)),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(
                  context, "/SignIn", (route) => false);
            },
          ),
        ],
      ),
    );
  }
}

class WalletPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wallet'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text('\$9.999',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green)),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      InfoChip('12', 'Transaction'),
                      InfoChip('8', 'Progress'),
                      InfoChip('4', 'Waiting'),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) => ListTile(
                  // leading: CircleAvatar(
                  //   child: Icon(Icons.recycling),
                  // ),
                  // title: Text('Soda Can'),
                  // subtitle: Text('1.0 Kg'),
                  // trailing: Text(
                  //   '+ 2.099\$',
                  //   style: TextStyle(color: Colors.green),
                  // ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecyclingCompanyProfile extends StatefulWidget {
  @override
  _RecyclingCompanyProfileState createState() =>
      _RecyclingCompanyProfileState();
}

class _RecyclingCompanyProfileState extends State<RecyclingCompanyProfile> {
  final UserService _userService = UserService();
  Map<String, dynamic>? _companyData;
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<Map<String, dynamic>>? _dataSubscription;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _directorNameController;
  late TextEditingController _companyNameController;
  late TextEditingController _gpsController;
  late TextEditingController _employeesController;
  late TextEditingController _mobileController;
  late TextEditingController _ghanaCardController;
  late TextEditingController _landmarkController;
  late TextEditingController _locationController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _initializeEmptyControllers();
    _setupRealtimeListener();
  }

  void _initializeEmptyControllers() {
    _directorNameController = TextEditingController();
    _companyNameController = TextEditingController();
    _gpsController = TextEditingController();
    _employeesController = TextEditingController();
    _mobileController = TextEditingController();
    _ghanaCardController = TextEditingController();
    _landmarkController = TextEditingController();
    _locationController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
  }

  void _setupRealtimeListener() {
    _dataSubscription = _userService.getUserDataStream().listen(
      (data) {
        setState(() {
          _companyData = data;
          _isLoading = false;
          _updateControllersWithData();
        });
      },
      onError: (error) {
        setState(() {
          _errorMessage = 'Failed to load user data: ${error.toString()}';
          _isLoading = false;
        });
      },
    );
  }

  void _updateControllersWithData() {
    if (_companyData == null) return;

    _directorNameController.text =
        _companyData!['wasteManagementInfo']['DirectorName'] ?? '';
    _companyNameController.text =
        _companyData!['wasteManagementInfo']['FullName'] ?? '';
    _gpsController.text =
        _companyData!['wasteManagementInfo']['GPSAddress'] ?? '';
    _employeesController.text =
        _companyData!['wasteManagementInfo']['employees']?.toString() ?? '';
    _mobileController.text =
        _companyData!['wasteManagementInfo']['ghMobileNumber'] ?? '';
    _ghanaCardController.text =
        _companyData!['wasteManagementInfo']['ghanaCardNumber'] ?? '';
    _landmarkController.text =
        _companyData!['wasteManagementInfo']['landmark'] ?? '';
    _locationController.text =
        _companyData!['wasteManagementInfo']['location'] ?? '';
    _emailController.text = _companyData!['email'] ?? '';
    _phoneController.text = _companyData!['phone'] ?? '';
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    _directorNameController.dispose();
    _companyNameController.dispose();
    _gpsController.dispose();
    _employeesController.dispose();
    _mobileController.dispose();
    _ghanaCardController.dispose();
    _landmarkController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      // Here you would upload the image to storage and update the URL
    }
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _saveChanges();
      }
    });
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate() && _companyData != null) {
      try {
        final updatedData = {
          'email': _emailController.text,
          'phone': _phoneController.text,
          'wasteManagementInfo': {
            ..._companyData!['wasteManagementInfo'], // Preserve existing data
            'DirectorName': _directorNameController.text,
            'FullName': _companyNameController.text,
            'GPSAddress': _gpsController.text,
            'employees': _employeesController.text,
            'ghMobileNumber': _mobileController.text,
            'ghanaCardNumber': _ghanaCardController.text,
            'landmark': _landmarkController.text,
            'location': _locationController.text,
          },
        };

        await _userService.updateUserData(updatedData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: ${e.toString()}')),
        );
      }
    }
  }

  void _addNewBranch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBranchPage(
          onBranchAdded: (newBranch) async {
            try {
              // Get current branches or initialize empty list
              final branches = List<Map<String, dynamic>>.from(
                  _companyData?['branches'] ?? []);

              branches.add(newBranch);

              await _userService.updateUserData({
                'branches': branches,
              });
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Failed to add branch: ${e.toString()}')),
              );
            }
          },
        ),
      ),
    );
  }

  void _editBranch(int index) {
    final branches =
        List<Map<String, dynamic>>.from(_companyData?['branches'] ?? []);
    if (index >= branches.length) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBranchPage(
          branch: branches[index],
          onBranchAdded: (updatedBranch) async {
            try {
              final updatedBranches = List<Map<String, dynamic>>.from(
                  _companyData?['branches'] ?? []);

              updatedBranches[index] = updatedBranch;

              await _userService.updateUserData({
                'branches': updatedBranches,
              });
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Failed to update branch: ${e.toString()}')),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    if (_companyData == null) {
      return Center(child: Text('No company data available'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Company Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _toggleEditing,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image Section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (_companyData!['riderImageUrl'] != null &&
                                  _companyData!['riderImageUrl'].isNotEmpty)
                              ? NetworkImage(_companyData!['riderImageUrl'])
                              : AssetImage('assets/default_company.png')
                                  as ImageProvider,
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(Icons.camera_alt, color: Colors.white),
                            onPressed: _pickImage,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Company Information Section
              Text(
                'Company Information',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Divider(),

              _buildEditableField(
                label: 'Company Name',
                controller: _companyNameController,
                icon: Icons.business,
              ),
              _buildEditableField(
                label: 'Director Name',
                controller: _directorNameController,
                icon: Icons.person,
              ),
              // Add all other fields as before...

              // Branches Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Branches',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (_isEditing)
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: _addNewBranch,
                    ),
                ],
              ),
              Divider(),
              if (_companyData?['branches'] != null)
                ...List<Widget>.from(
                  (_companyData!['branches'] as List).map((branch) {
                    final index =
                        (_companyData!['branches'] as List).indexOf(branch);
                    return _buildBranchCard(
                      Map<String, dynamic>.from(branch),
                      index,
                    );
                  }),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: _isEditing
          ? TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                prefixIcon: Icon(icon),
                border: OutlineInputBorder(),
              ),
              keyboardType: keyboardType,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter $label';
                }
                return null;
              },
            )
          : ListTile(
              leading: Icon(icon),
              title: Text(label),
              subtitle: Text(controller.text),
            ),
    );
  }

  Widget _buildBranchCard(Map<String, dynamic> branch, int index) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  branch['branchName'] ?? 'Unnamed Branch',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (_isEditing)
                  IconButton(
                    icon: Icon(Icons.edit, size: 20),
                    onPressed: () => _editBranch(index),
                  ),
              ],
            ),
            SizedBox(height: 8),
            Text('Location: ${branch['branchLocation'] ?? 'Not specified'}'),
            Text('GPS: ${branch['branchGPS'] ?? 'Not specified'}'),
            Text('Phone: ${branch['branchPhone'] ?? 'Not specified'}'),
          ],
        ),
      ),
    );
  }
}

class AddBranchPage extends StatefulWidget {
  final Map<String, dynamic>? branch;
  final Function(Map<String, dynamic>) onBranchAdded;

  AddBranchPage({this.branch, required this.onBranchAdded});

  @override
  _AddBranchPageState createState() => _AddBranchPageState();
}

class _AddBranchPageState extends State<AddBranchPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _gpsController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.branch?['branchName'] ?? '');
    _locationController =
        TextEditingController(text: widget.branch?['branchLocation'] ?? '');
    _gpsController =
        TextEditingController(text: widget.branch?['branchGPS'] ?? '');
    _phoneController =
        TextEditingController(text: widget.branch?['branchPhone'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _gpsController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveBranch() {
    if (_formKey.currentState!.validate()) {
      final newBranch = {
        'branchName': _nameController.text,
        'branchLocation': _locationController.text,
        'branchGPS': _gpsController.text,
        'branchPhone': _phoneController.text,
      };
      widget.onBranchAdded(newBranch);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.branch == null ? 'Add New Branch' : 'Edit Branch'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Branch Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter branch name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter location';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _gpsController,
                decoration: InputDecoration(
                  labelText: 'GPS Address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter GPS address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveBranch,
                child: Text('Save Branch'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String title;
  final IconData icon;

  CategoryItem(this.title, this.icon);

  Future<void> _fetchAndShowRecycleItems(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      DatabaseReference databaseReference =
          FirebaseDatabase.instance.ref().child('recycle_items');
      final snapshot = await databaseReference
          .orderByChild('RecycleType')
          .equalTo(title)
          .get();

      Navigator.pop(context); // Close the loading dialog

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>? ?? {};
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('$title RecycleType'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: data.entries.map((entry) {
                    final item = entry.value as Map<dynamic, dynamic>;
                    return ListTile(
                      title: Text(item['Description'] ?? 'Unnamed Item'),
                      subtitle: Text('Weight: ${item['size'] ?? 'N/A'}'),
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No items found in this category.')),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close the loading dialog
      print('Error fetching items: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to fetch items. Please try again later.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _fetchAndShowRecycleItems(context),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.green.withOpacity(0.1),
            child: Icon(icon, color: Colors.green),
          ),
          SizedBox(height: 5),
          Text(title, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

class UserService {
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref().child("WMS");
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user's recycling company data
  Future<Map<String, dynamic>> getCurrentUserData() async {
    print(_database);

    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      DatabaseReference ref = _database.child('${user.uid}');
      print("ref$ref");

      DatabaseEvent event = await ref.once();

      if (event.snapshot.value == null) {
        throw Exception('User data not found');
      }

      return Map<String, dynamic>.from(event.snapshot.value as Map);
    } catch (e) {
      print('Error fetching user data: $e');
      rethrow;
    }
  }

  // Update user data
  Future<void> updateUserData(Map<String, dynamic> data) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      await _database.child('${user.uid}').update(data);
    } catch (e) {
      print('Error updating user data: $e');
      rethrow;
    }
  }

  // Listen for realtime updates
  Stream<Map<String, dynamic>> getUserDataStream() {
    User? user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    return _database.child('${user.uid}').onValue.map((event) {
      if (event.snapshot.value == null) {
        throw Exception('User data not found');
      }
      return Map<String, dynamic>.from(event.snapshot.value as Map);
    });
  }
}

// Reusable Chip Widget
class InfoChip extends StatelessWidget {
  final String count;
  final String label;

  InfoChip(this.count, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}


