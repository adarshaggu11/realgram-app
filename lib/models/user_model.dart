import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String role; // buyer, agent, builder, admin
  final String name;
  final String phone;
  final String email;
  final String city;
  final String state;
  final String country;
  final double? latitude;
  final double? longitude;
  final bool verified;
  final String? subscriptionType; // free, premium, agent_pro
  final DateTime? subscriptionExpiry;
  final DateTime createdAt;
  final String? profileImageUrl;
  final int totalListings;
  final int totalLeads;
  final double avgRating;
  final String? fcmToken; // Firebase Cloud Messaging token for push notifications

  UserModel({
    required this.uid,
    required this.role,
    required this.name,
    required this.phone,
    required this.email,
    required this.city,
    required this.state,
    required this.country,
    this.latitude,
    this.longitude,
    this.verified = false,
    this.subscriptionType = 'free',
    this.subscriptionExpiry,
    required this.createdAt,
    this.profileImageUrl,
    this.totalListings = 0,
    this.totalLeads = 0,
    this.avgRating = 0.0,
    this.fcmToken,
  });

  // Convert to Firestore JSON
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'role': role,
      'name': name,
      'phone': phone,
      'email': email,
      'city': city,
      'state': state,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'verified': verified,
      'subscriptionType': subscriptionType,
      'subscriptionExpiry': subscriptionExpiry,
      'createdAt': createdAt,
      'profileImageUrl': profileImageUrl,
      'totalListings': totalListings,
      'totalLeads': totalLeads,
      'avgRating': avgRating,
      'fcmToken': fcmToken,
    };
  }

  // Create from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      uid: documentId,
      role: map['role'] ?? 'buyer',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      country: map['country'] ?? '',
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      verified: map['verified'] ?? false,
      subscriptionType: map['subscriptionType'] ?? 'free',
      subscriptionExpiry: map['subscriptionExpiry'] is Timestamp
          ? (map['subscriptionExpiry'] as Timestamp).toDate()
          : null,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      profileImageUrl: map['profileImageUrl'],
      totalListings: map['totalListings'] ?? 0,
      totalLeads: map['totalLeads'] ?? 0,
      avgRating: (map['avgRating'] ?? 0).toDouble(),
      fcmToken: map['fcmToken'],
    );
  }

  // Create from Firestore snapshot
  factory UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    return UserModel.fromMap(doc.data() ?? {}, doc.id);
  }

  // Copy with method
  UserModel copyWith({
    String? uid,
    String? role,
    String? name,
    String? phone,
    String? email,
    String? city,
    String? state,
    String? country,
    double? latitude,
    double? longitude,
    bool? verified,
    String? subscriptionType,
    DateTime? subscriptionExpiry,
    DateTime? createdAt,
    String? profileImageUrl,
    int? totalListings,
    int? totalLeads,
    double? avgRating,
    String? fcmToken,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      role: role ?? this.role,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      verified: verified ?? this.verified,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      createdAt: createdAt ?? this.createdAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      totalListings: totalListings ?? this.totalListings,
      totalLeads: totalLeads ?? this.totalLeads,
      avgRating: avgRating ?? this.avgRating,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
