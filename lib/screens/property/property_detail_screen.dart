import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/property_model.dart';

class PropertyDetailScreen extends StatefulWidget {
  final PropertyModel property;
  // final Position? userLocation;
  final dynamic userLocation;

  const PropertyDetailScreen({
    Key? key,
    required this.property,
    this.userLocation,
  }) : super(key: key);

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _isSaved = false;
  late PageController _imageController;
  int _currentImageIndex = 0;
  late TabController _tabController;
  bool _showFullDescription = false;

  @override
  void initState() {
    super.initState();
    _imageController = PageController();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _imageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  String _formatPrice(double price) {
    var priceValue = price.toInt();
    if (priceValue >= 10000000) {
      return '₹${(priceValue / 10000000).toStringAsFixed(1)}Cr';
    } else if (priceValue >= 100000) {
      return '₹${(priceValue / 100000).toStringAsFixed(1)}L';
    } else {
      return '₹${(priceValue / 1000).toStringAsFixed(0)}K';
    }
  }

  String _formatArea(double? area) {
    return area != null ? '${area.toInt()} sq. ft.' : 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Image Carousel with Floating Header
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            leading: _buildBackButton(context),
            actions: [
              _buildSaveButton(),
              _buildShareButton(),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image Carousel
                  PageView.builder(
                    controller: _imageController,
                    onPageChanged: (index) {
                      setState(() => _currentImageIndex = index);
                    },
                    itemCount: widget.property.imageUrls.isEmpty
                        ? 1
                        : widget.property.imageUrls.length,
                    itemBuilder: (context, index) {
                      if (widget.property.imageUrls.isEmpty) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.image,
                              size: 64, color: Colors.grey[400]),
                        );
                      }
                      return Image.network(
                        widget.property.imageUrls[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.broken_image,
                              size: 64, color: Colors.grey[400]),
                        ),
                      );
                    },
                  ),
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Image counter
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_currentImageIndex + 1}/${widget.property.imageUrls.isEmpty ? 1 : widget.property.imageUrls.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // Type badge
                  Positioned(
                    top: 80,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.property.propertyType.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Property Header Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.property.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.location_on,
                                    size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    widget.property.propertyAddress ?? 'No address',
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
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatPrice(widget.property.price),
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_formatArea(widget.property.area)}',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Trust badges & stats
                  _buildTrustBadges(context),
                  const SizedBox(height: 20),
                  // Key specs in a row
                  _buildKeySpecs(context),
                ],
              ),
            ),
          ),
          // Tabs section
          SliverToBoxAdapter(
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Details'),
                Tab(text: 'Amenities'),
                Tab(text: 'Reviews'),
              ],
            ),
          ),
          // Tab content
          SliverFillRemaining(
            hasScrollBody: false,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDetailsTab(context),
                _buildAmenitiesTab(context),
                _buildReviewsTab(context),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildActionBar(context),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          _isSaved ? Icons.favorite : Icons.favorite_outline,
          color: _isSaved ? Colors.red : Colors.white,
        ),
        onPressed: () {
          setState(() => _isSaved = !_isSaved);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isSaved
                  ? 'Added to wishlist'
                  : 'Removed from wishlist'),
              duration: const Duration(milliseconds: 800),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShareButton() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.share, color: Colors.white),
        onPressed: () {
          Share.share(
            '${widget.property.title}\n${widget.property.propertyAddress}\n${_formatPrice(widget.property.price)}\n\nCheck out this property on RealGram!',
            subject: widget.property.title,
          );
        },
      ),
    );
  }

  Widget _buildTrustBadges(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _TrustBadge(icon: Icons.verified, label: 'Verified'),
          const SizedBox(width: 8),
          _TrustBadge(
            icon: Icons.remove_red_eye,
            label: '1.2K views',
            color: Colors.blue,
          ),
          const SizedBox(width: 8),
          _TrustBadge(
            icon: Icons.favorite,
            label: '247 saved',
            color: Colors.red,
          ),
          const SizedBox(width: 8),
          _TrustBadge(
            icon: Icons.schedule,
            label: 'Updated today',
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildKeySpecs(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _SpecCard(
          icon: Icons.aspect_ratio,
          label: 'Area',
          value: _formatArea(widget.property.area),
        ),
        _SpecCard(
          icon: Icons.home,
          label: 'Type',
          value: widget.property.propertyType.toUpperCase(),
        ),
        _SpecCard(
          icon: Icons.check_circle,
          label: 'Status',
          value: 'Approved',
        ),
      ],
    );
  }

  Widget _buildDetailsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About this property',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.property.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                  height: 1.6,
                ),
          ),
          const SizedBox(height: 32),
          // Documents section
          Text(
            'Documents',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          _DocumentTile(title: 'Property Registration', status: 'Verified'),
          _DocumentTile(title: 'No Objection Certificate', status: 'Available'),
          _DocumentTile(title: 'Legal Compliance', status: 'Verified'),
        ],
      ),
    );
  }

  Widget _buildAmenitiesTab(BuildContext context) {
    if (widget.property.amenities.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text('No amenities listed',
              style: Theme.of(context).textTheme.labelMedium),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: widget.property.amenities
                .map(
                  (amenity) => Chip(
                    avatar: Icon(_getAmenityIcon(amenity)),
                    label: Text(amenity),
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating summary
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '4.8',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: List.generate(
                            5,
                            (i) => Icon(
                              Icons.star,
                              size: 14,
                              color: i < 4 ? Colors.amber : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '324 reviews',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Sample reviews
          _ReviewCard(
            name: 'Raj Kumar',
            rating: 5,
            comment:
                'Excellent property! Well-maintained and great location. Agent was very helpful.',
            date: '2 weeks ago',
          ),
          const SizedBox(height: 12),
          _ReviewCard(
            name: 'Priya Singh',
            rating: 5,
            comment: 'Perfect for my family. Good neighborhood and safe.',
            date: '1 month ago',
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tour scheduled for tomorrow at 2 PM'),
                    ),
                  );
                },
                icon: const Icon(Icons.calendar_today),
                label: const Text('Schedule Tour'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Opening chat with agent...'),
                    ),
                  );
                },
                icon: const Icon(Icons.message),
                label: const Text('Chat'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAmenityIcon(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'parking':
        return Icons.directions_car;
      case 'gym':
        return Icons.fitness_center;
      case 'pool':
        return Icons.pool;
      case 'garden':
        return Icons.grass;
      case 'wifi':
        return Icons.wifi;
      case 'air conditioning':
        return Icons.ac_unit;
      default:
        return Icons.check_circle;
    }
  }
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _TrustBadge({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (color ?? Colors.green).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (color ?? Colors.green).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color ?? Colors.green),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color ?? Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SpecCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final String title;
  final String status;

  const _DocumentTile({
    required this.title,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isVerified = status == 'Verified';
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                status,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isVerified ? Colors.green : Colors.blue,
                    ),
              ),
            ],
          ),
          Icon(
            isVerified ? Icons.verified : Icons.download,
            color: isVerified ? Colors.green : Colors.blue,
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String name;
  final int rating;
  final String comment;
  final String date;

  const _ReviewCard({
    required this.name,
    required this.rating,
    required this.comment,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                date,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                Icons.star,
                size: 14,
                color: i < rating ? Colors.amber : Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            comment,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[700],
                ),
          ),
        ],
      ),
    );
  }
