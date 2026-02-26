import 'package:cloud_firestore/cloud_firestore.dart';

class PropertyModel {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final double price;
  final String propertyType; // plot, apartment, house, commercial
  final double latitude;
  final double longitude;
  final String geohash;
  final List<String> imageUrls;
  final String? videoUrl;
  final String status; // pending, approved, rejected
  final int boostLevel; // 0-5
  final bool featured;
  final int views;
  final int favorites;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final String? areaUnit; // sqft, sqm
  final double? area;
  final String? propertyAddress;
  final List<String> amenities;
  final bool verified;

  PropertyModel({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.price,
    required this.propertyType,
    required this.latitude,
    required this.longitude,
    required this.geohash,
    required this.imageUrls,
    this.videoUrl,
    this.status = 'pending',
    this.boostLevel = 0,
    this.featured = false,
    this.views = 0,
    this.favorites = 0,
    required this.createdAt,
    this.approvedAt,
    this.areaUnit = 'sqft',
    this.area,
    this.propertyAddress,
    this.amenities = const [],
    this.verified = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'price': price,
      'propertyType': propertyType,
      'latitude': latitude,
      'longitude': longitude,
      'geohash': geohash,
      'imageUrls': imageUrls,
      'videoUrl': videoUrl,
      'status': status,
      'boostLevel': boostLevel,
      'featured': featured,
      'views': views,
      'favorites': favorites,
      'createdAt': createdAt,
      'approvedAt': approvedAt,
      'areaUnit': areaUnit,
      'area': area,
      'propertyAddress': propertyAddress,
      'amenities': amenities,
      'verified': verified,
    };
  }

  factory PropertyModel.fromMap(Map<String, dynamic> map, String documentId) {
    return PropertyModel(
      id: documentId,
      ownerId: map['ownerId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      propertyType: map['propertyType'] ?? 'plot',
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      geohash: map['geohash'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      videoUrl: map['videoUrl'],
      status: map['status'] ?? 'pending',
      boostLevel: map['boostLevel'] ?? 0,
      featured: map['featured'] ?? false,
      views: map['views'] ?? 0,
      favorites: map['favorites'] ?? 0,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      approvedAt: map['approvedAt'] is Timestamp
          ? (map['approvedAt'] as Timestamp).toDate()
          : null,
      areaUnit: map['areaUnit'] ?? 'sqft',
      area: (map['area'])?.toDouble(),
      propertyAddress: map['propertyAddress'],
      amenities: List<String>.from(map['amenities'] ?? []),
      verified: map['verified'] ?? false,
    );
  }

  factory PropertyModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    return PropertyModel.fromMap(doc.data() ?? {}, doc.id);
  }
}
