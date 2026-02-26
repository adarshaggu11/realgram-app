import 'package:flutter/material.dart';
import '../../models/property_model.dart';
import 'property_detail_screen.dart';

class PropertyListScreen extends StatefulWidget {
  const PropertyListScreen({Key? key}) : super(key: key);

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  // Mock data for demo - will be replaced with Firestore queries
  final List<PropertyModel> _mockProperties = [
    PropertyModel(
      id: '1',
      ownerId: 'agent1',
      title: 'Luxury 3BHK Apartment',
      description: 'Modern apartment in prime location with all amenities',
      price: 8500000,
      propertyType: 'apartment',
      latitude: 28.6139,
      longitude: 77.2090,
      geohash: 'ttnfjfk',
      imageUrls: [
        'https://images.unsplash.com/photo-1545324418-cc1a9db6dab5?w=500'
      ],
      status: 'approved',
      createdAt: DateTime.now(),
      propertyAddress: 'New Delhi',
    ),
    PropertyModel(
      id: '2',
      ownerId: 'agent2',
      title: 'Plot in Dwarka',
      description: 'Commercial plot ready for development',
      price: 5000000,
      propertyType: 'plot',
      latitude: 28.5921,
      longitude: 77.0460,
      geohash: 'ttmwu8u',
      imageUrls: [
        'https://images.unsplash.com/photo-1560448204-e02f7cbb3bdf?w=500'
      ],
      status: 'approved',
      createdAt: DateTime.now(),
      propertyAddress: 'Dwarka, Delhi',
    ),
    PropertyModel(
      id: '3',
      ownerId: 'agent3',
      title: '4BHK Villa',
      description: 'Spacious villa with garden and parking',
      price: 15000000,
      propertyType: 'house',
      latitude: 28.7041,
      longitude: 77.1025,
      geohash: 'ttnh321',
      imageUrls: [
        'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=500'
      ],
      status: 'approved',
      createdAt: DateTime.now(),
      propertyAddress: 'Greater Kailash',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Properties'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => _showFilters(context),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _mockProperties.length,
        itemBuilder: (context, index) {
          final property = _mockProperties[index];
          return PropertyCard(
            property: property,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PropertyDetailScreen(property: property),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
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
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ['All', 'Plot', 'Apartment', 'House', 'Commercial']
                  .map((type) => FilterChip(
                        label: Text(type),
                        onSelected: (_) {},
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PropertyCard extends StatelessWidget {
  final PropertyModel property;
  final VoidCallback onTap;

  const PropertyCard({
    Key? key,
    required this.property,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: property.imageUrls.isNotEmpty
                      ? Image.network(
                          property.imageUrls[0],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.broken_image,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                        )
                      : Icon(
                          Icons.image,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(24),
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
            // Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹ ${(property.price / 10000000).toStringAsFixed(1)} Cr',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.propertyAddress ?? 'Location unavailable',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: Colors.grey[600],
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
