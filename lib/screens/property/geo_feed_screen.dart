import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/property_model.dart';
import '../../services/firestore_service.dart';
import 'property_detail_screen.dart';

class GeoFeedScreen extends StatefulWidget {
  const GeoFeedScreen({Key? key}) : super(key: key);

  @override
  State<GeoFeedScreen> createState() => _GeoFeedScreenState();
}

class _GeoFeedScreenState extends State<GeoFeedScreen> {
  late FirestoreService _firestoreService;
  List<PropertyModel> _properties = [];
  bool _isLoading = true;
  String? _errorMessage;
  // Position? _userLocation;
  dynamic _userLocation;
  String _selectedPropertyType = 'all';
  double _minPrice = 0;
  double _maxPrice = 10000000;

  final List<String> _propertyTypes = [
    'all',
    'plot',
    'apartment',
    'house',
    'commercial'
  ];

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService();
    _initializeGeoFeed();
  }

  Future<void> _initializeGeoFeed() async {
    try {
      // TODO: Restore location permission request when geolocator is working
      // Request location permission
      // LocationPermission permission = await Geolocator.checkPermission();
      // if (permission == LocationPermission.denied) {
      //   permission = await Geolocator.requestPermission();
      // }
      // if (permission == LocationPermission.deniedForever) {
      //   setState(() {
      //     _errorMessage = 'Location permission is required to discover properties';
      //     _isLoading = false;
      //   });
      //   return;
      // }

      // Get user's current location
      // _userLocation = await Geolocator.getCurrentPosition(
      //   desiredAccuracy: LocationAccuracy.high,
      // );

      // Load nearby properties
      await _loadNearbyProperties();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading location: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadNearbyProperties() async {
    try {
      setState(() => _isLoading = true);

      if (_userLocation == null) {
        setState(() {
          _errorMessage = 'Unable to get your location';
          _isLoading = false;
        });
        return;
      }

      // Query nearby properties using coordinates and radius
      final properties = await _firestoreService.getNearbyPropertiesByCoordinates(
        _userLocation!.latitude,
        _userLocation!.longitude,
        radiusKm: 50, // 50km radius (adjustable)
        limit: 30,
      );

      // Filter by type and price
      final filtered = properties.where((p) {
        final typeMatch = _selectedPropertyType == 'all' ||
            p.propertyType.toLowerCase() == _selectedPropertyType;
        final priceMatch = p.price >= _minPrice && p.price <= _maxPrice;
        return typeMatch && priceMatch;
      }).toList();

      setState(() {
        _properties = filtered;
        _errorMessage = null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading properties: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Properties'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : _properties.isEmpty
                  ? _buildEmptyState()
                  : _buildPropertyFeed(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loadNearbyProperties,
        label: const Text('Refresh'),
        icon: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(_errorMessage!),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _initializeGeoFeed,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No properties found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyFeed() {
    return RefreshIndicator(
      onRefresh: _loadNearbyProperties,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _properties.length,
        itemBuilder: (context, index) {
          final property = _properties[index];
          return PropertyGridCard(
            property: property,
            userLocation: _userLocation,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PropertyDetailScreen(property: property),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      builder: (_) => FilterBottomSheet(
        selectedType: _selectedPropertyType,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        onApply: (type, minP, maxP) {
          setState(() {
            _selectedPropertyType = type;
            _minPrice = minP;
            _maxPrice = maxP;
          });
          _loadNearbyProperties();
          Navigator.pop(context);
        },
      ),
    );
  }
}

class PropertyGridCard extends StatelessWidget {
  final PropertyModel property;
  // final Position? userLocation;
  final dynamic userLocation;
  final VoidCallback onTap;

  const PropertyGridCard({
    Key? key,
    required this.property,
    this.userLocation,
    required this.onTap,
  }) : super(key: key);

  double? _calculateDistance() {
    // TODO: Restore geo distance calculation after geolocator is working
    // if (userLocation == null) return null;
    // final distance = Geolocator.distanceBetween(
    //   userLocation!.latitude,
    //   userLocation!.longitude,
    //   property.latitude,
    //   property.longitude,
    // );
    // return distance / 1000; // Convert to km
    return null;
  }

  String _formatPrice(double price) {
    var priceValue = price.toInt();
    if (priceValue >= 10000000) {
      return '₹${(priceValue / 10000000).toStringAsFixed(1)}Cr';
    } else if (priceValue >= 100000) {
      return '₹${(priceValue / 100000).toStringAsFixed(1)}L';
    } else {
      return '₹${priceValue.toString()}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final distance = _calculateDistance();

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with type badge
            Stack(
              children: [
                Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: property.imageUrls.isNotEmpty
                      ? Image.network(
                          property.imageUrls[0],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Icon(Icons.image, size: 64, color: Colors.grey[400]),
                          ),
                        )
                      : Center(
                          child: Icon(Icons.image, size: 64, color: Colors.grey[400]),
                        ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      property.propertyType.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
              ],
            ),
            // Info section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatPrice(property.price),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.propertyAddress ?? 'No address',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (distance != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${distance.toStringAsFixed(1)} km away',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  final String selectedType;
  final double minPrice;
  final double maxPrice;
  final Function(String type, double minP, double maxP) onApply;

  const FilterBottomSheet({
    Key? key,
    required this.selectedType,
    required this.minPrice,
    required this.maxPrice,
    required this.onApply,
  }) : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String _selectedType;
  late RangeValues _priceRange;

  final List<String> _types = ['all', 'plot', 'apartment', 'house', 'commercial'];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.selectedType;
    _priceRange = RangeValues(widget.minPrice, widget.maxPrice);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filters',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          Text(
            'Property Type',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: _types
                .map((type) => FilterChip(
                      label: Text(type.toUpperCase()),
                      selected: _selectedType == type,
                      onSelected: (selected) {
                        setState(() => _selectedType = type);
                      },
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
          Text(
            'Price Range',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 10000000,
            onChanged: (values) {
              setState(() => _priceRange = values);
            },
          ),
          Text(
            '₹${(_priceRange.start / 100000).toStringAsFixed(0)}L - ₹${(_priceRange.end / 10000000).toStringAsFixed(1)}Cr',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                widget.onApply(_selectedType, _priceRange.start, _priceRange.end);
              },
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}
