import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/notification_service.dart';
import '../../models/user_model.dart';

class ProfileCompletionScreen extends StatefulWidget {
  final String role;

  const ProfileCompletionScreen({
    Key? key,
    required this.role,
  }) : super(key: key);

  @override
  State<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  bool _isLoading = false;
  String? _selectedCity;

  final List<String> _cities = [
    'Delhi',
    'Mumbai',
    'Bangalore',
    'Hyderabad',
    'Chennai',
    'Pune',
    'Kolkata',
    'Jaipur',
    'Noida',
    'Gurgaon',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Tell us about yourself',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'This information helps us personalize your experience',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 32),
              // Name Field
              Text(
                'Full Name',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter your full name',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // City Selection
              Text(
                'City',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCity,
                items: _cities
                    .map((city) => DropdownMenuItem(
                          value: city,
                          child: Text(city),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedCity = value);
                },
                decoration: InputDecoration(
                  hintText: 'Select your city',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Complete Button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ||
                          _nameController.text.isEmpty ||
                          _selectedCity == null
                      ? null
                      : _handleComplete,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Complete Profile'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleComplete() async {
    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      final firestoreService = FirestoreService();
      final notificationService = NotificationService();
      final user = authService.currentUser;

      if (user == null) throw Exception('User not authenticated');

      // Get FCM token for push notifications
      final fcmToken = await notificationService.getFCMToken();

      // Create user model with collected data
      final userModel = UserModel(
        uid: user.uid,
        phone: user.phoneNumber ?? '',
        name: _nameController.text.trim(),
        email: user.email ?? '',
        city: _selectedCity!,
        state: _getCityState(_selectedCity!), // Auto-populate state
        country: 'India',
        role: widget.role,
        createdAt: DateTime.now(),
        fcmToken: fcmToken, // Include FCM token
      );

      // Save user profile to Firestore
      await firestoreService.saveUserProfile(userModel);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profile saved and notifications enabled!'),
            duration: Duration(milliseconds: 1500),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 500));

        Navigator.of(context).pushNamedAndRemoveUntil(
          '/home',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getCityState(String city) {
    const stateMap = {
      'Delhi': 'Delhi',
      'Mumbai': 'Maharashtra',
      'Bangalore': 'Karnataka',
      'Hyderabad': 'Telangana',
      'Chennai': 'Tamil Nadu',
      'Pune': 'Maharashtra',
      'Kolkata': 'West Bengal',
      'Jaipur': 'Rajasthan',
      'Noida': 'Uttar Pradesh',
      'Gurgaon': 'Haryana',
    };
    return stateMap[city] ?? 'Unknown';
  }
}
