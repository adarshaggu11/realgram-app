import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// SCREEN TEMPLATE 1: OTP LOGIN SCREEN
/// 
/// This is a template for the OTP phone authentication screen.
/// Replace with your own styling and branding.

class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({Key? key}) : super(key: key);

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _verifyPhoneNumber() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a phone number')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Format phone number
      String phoneNumber = '+91${_phoneController.text.replaceAll(RegExp(r'\D'), '')}';
      
      // TODO: Call AuthService.verifyPhoneNumber()
      // await authService.verifyPhoneNumber(
      //   phoneNumber,
      //   onCodeSent: (verificationId) {
      //     Navigator.push(context, MaterialPageRoute(
      //       builder: (_) => OTPVerificationScreen(verificationId: verificationId),
      //     ));
      //   },
      //   onError: (e) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(content: Text('Error: ${e.message}')),
      //     );
      //   },
      // );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RealGram'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter Your Phone Number',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'We\'ll send you an OTP to verify your number',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                prefixText: '+91 ',
                hintText: '98XXXXXX00',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyPhoneNumber,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Send OTP'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================

/// SCREEN TEMPLATE 2: PROPERTY UPLOAD SCREEN
/// 
/// Form-based property listing with image upload

class PropertyUploadScreen extends StatefulWidget {
  const PropertyUploadScreen({Key? key}) : super(key: key);

  @override
  State<PropertyUploadScreen> createState() => _PropertyUploadScreenState();
}

class _PropertyUploadScreenState extends State<PropertyUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();

  String _propertyType = 'plot';
  List<String> _selectedAmenities = [];
  List<String> _imageUrls = [];
  double? _latitude;
  double? _longitude;
  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImages() async {
    // TODO: Implement image picker + Firebase Storage upload
    // setState(() => _imageUrls.add(downloadUrl));
  }

  Future<void> _getCurrentLocation() async {
    // TODO: Implement geolocator
    // Position position = await Geolocator.getCurrentPosition();
    // setState(() {
    //   _latitude = position.latitude;
    //   _longitude = position.longitude;
    // });
  }

  Future<void> _submitProperty() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);

    try {
      // TODO: Create PropertyModel and save to Firestore
      // PropertyModel property = PropertyModel(
      //   ownerId: currentUser.uid,
      //   title: _titleController.text,
      //   description: _descriptionController.text,
      //   price: double.parse(_priceController.text),
      //   propertyType: _propertyType,
      //   latitude: _latitude!,
      //   longitude: _longitude!,
      //   geohash: calculateGeohash(_latitude, _longitude),
      //   imageUrls: _imageUrls,
      //   area: double.parse(_areaController.text),
      //   amenities: _selectedAmenities,
      //   createdAt: DateTime.now(),
      // );
      // await firestoreService.saveProperty(property);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Property uploaded successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Property')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Property Title'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _propertyType,
                items: ['plot', 'apartment', 'house', 'commercial']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _propertyType = v ?? 'plot'),
                decoration: const InputDecoration(labelText: 'Property Type'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price (₹)'),
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _areaController,
                decoration: const InputDecoration(labelText: 'Area (sqft)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _getCurrentLocation,
                child: const Text('📍 Pick Location'),
              ),
              if (_latitude != null)
                Text('Location: $_latitude, $_longitude'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _pickAndUploadImages,
                child: Text('📸 Add Images (\${_imageUrls.length})'),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isUploading ? null : _submitProperty,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isUploading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Upload Property'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================

/// SCREEN TEMPLATE 3: GEO FEED SCREEN
/// 
/// Shows nearby properties in a grid/list

class GeoFeedScreen extends StatefulWidget {
  const GeoFeedScreen({Key? key}) : super(key: key);

  @override
  State<GeoFeedScreen> createState() => _GeoFeedScreenState();
}

class _GeoFeedScreenState extends State<GeoFeedScreen> {
  List<dynamic> _properties = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNearbyProperties();
  }

  Future<void> _loadNearbyProperties() async {
    try {
      // TODO: Get user location
      // TODO: Generate geohash
      // TODO: Query Firestore nearby properties
      // List<PropertyModel> properties = await firestoreService
      //     .getNearbyProperties(geohashPrefix);
      
      setState(() {
        _properties = [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Properties')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _properties.isEmpty
              ? const Center(child: Text('No properties found'))
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: _properties.length,
                  itemBuilder: (context, index) {
                    // TODO: Build property card widget
                    return Card(
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              color: Colors.grey[300],
                              child: const Placeholder(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Property Title'),
                                Text('₹ Price'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
