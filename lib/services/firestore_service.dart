import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:math';
import '../models/user_model.dart';
import '../models/property_model.dart';
import '../models/chat_model.dart';
import '../models/lead_model.dart';

class FirestoreService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  // Collections
  static const String usersCollection = 'users';
  static const String propertiesCollection = 'properties';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';
  static const String leadsCollection = 'leads';

  // ==================== USERS ====================

  /// Create or update user profile
  Future<void> saveUserProfile(UserModel user) async {
    try {
      await _firebaseFirestore
          .collection(usersCollection)
          .doc(user.uid)
          .set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  /// Get user profile
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final doc = await _firebaseFirestore
          .collection(usersCollection)
          .doc(userId)
          .get();
      if (doc.exists) {
        return UserModel.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Stream user profile
  Stream<UserModel?> getUserProfileStream(String userId) {
    return _firebaseFirestore
        .collection(usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromSnapshot(doc) : null);
  }

  // ==================== PROPERTIES ====================

  /// Save property listing
  Future<String> saveProperty(PropertyModel property) async {
    try {
      final docRef = await _firebaseFirestore
          .collection(propertiesCollection)
          .add(property.toMap());
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  /// Update property
  Future<void> updateProperty(String propertyId, PropertyModel property) async {
    try {
      await _firebaseFirestore
          .collection(propertiesCollection)
          .doc(propertyId)
          .set(property.toMap(), SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  /// Get single property
  Future<PropertyModel?> getProperty(String propertyId) async {
    try {
      final doc = await _firebaseFirestore
          .collection(propertiesCollection)
          .doc(propertyId)
          .get();
      if (doc.exists) {
        return PropertyModel.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Get nearby properties by geohash prefix (radius search)
  Future<List<PropertyModel>> getNearbyProperties(
    String geohashPrefix, {
    int limit = 20,
  }) async {
    try {
      final querySnapshot = await _firebaseFirestore
          .collection(propertiesCollection)
          .where('geohash', isGreaterThanOrEqualTo: geohashPrefix)
          .where('geohash', isLessThan: '${geohashPrefix}z')
          .where('status', isEqualTo: 'approved')
          .orderBy('geohash')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => PropertyModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get nearby properties by latitude/longitude with approximate radius
  /// Uses geohashing for efficient querying
  Future<List<PropertyModel>> getNearbyPropertiesByCoordinates(
    double latitude,
    double longitude, {
    int radiusKm = 50,
    int limit = 20,
  }) async {
    try {
      // Generate geohash prefix (first 4 chars covers roughly 20km²)
      final geohashPrefix = _generateGeohash(latitude, longitude, precision: 4);
      
      final querySnapshot = await _firebaseFirestore
          .collection(propertiesCollection)
          .where('geohash', isGreaterThanOrEqualTo: geohashPrefix)
          .where('geohash', isLessThan: '${geohashPrefix}z')
          .where('status', isEqualTo: 'approved')
          .orderBy('geohash')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      // Convert to PropertyModel and filter by actual radius
      final properties = querySnapshot.docs
          .map((doc) => PropertyModel.fromSnapshot(doc))
          .toList();

      // Filter by actual distance (geohash is approximate)
      return properties.where((property) {
        final distance = _calculateDistance(
          latitude,
          longitude,
          property.latitude,
          property.longitude,
        );
        return distance <= radiusKm;
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Generate geohash from coordinates (simplified)
  /// For production, use proper geohashing library
  String _generateGeohash(double lat, double lng, {int precision = 4}) {
    // Simplified geohashing - for production use geohash package
    // This is a placeholder implementation
    final latStr = lat.toStringAsFixed(2).replaceAll('.', '').padRight(6, '0');
    final lngStr = lng.toStringAsFixed(2).replaceAll('.', '').padRight(6, '0');
    return (latStr + lngStr).substring(0, precision);
  }

  /// Calculate distance between two coordinates in km
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadiusKm = 6371;
    final double dLat = _toRadian(lat2 - lat1);
    final double dLon = _toRadian(lon2 - lon1);
    final double a = (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(_toRadian(lat1)) *
            cos(_toRadian(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2));
    final double c = 2 * asin(sqrt(a));
    return earthRadiusKm * c;
  }

  double _toRadian(double degree) {
    return degree * (3.141592653589793 / 180);
  }

  /// Get properties by owner
  Future<List<PropertyModel>> getPropertiesByOwner(String ownerId) async {
    try {
      final querySnapshot = await _firebaseFirestore
          .collection(propertiesCollection)
          .where('ownerId', isEqualTo: ownerId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PropertyModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Delete property
  Future<void> deleteProperty(String propertyId) async {
    try {
      await _firebaseFirestore
          .collection(propertiesCollection)
          .doc(propertyId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  // ==================== CHATS & MESSAGES ====================

  /// Create or get chat
  Future<String> createChat(ChatModel chat) async {
    try {
      final docRef = await _firebaseFirestore
          .collection(chatsCollection)
          .add(chat.toMap());
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  /// Get user chats
  Stream<List<ChatModel>> getUserChats(String userId) {
    return _firebaseFirestore
        .collection(chatsCollection)
        .where('buyerId', isEqualTo: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ChatModel.fromSnapshot(doc)).toList());
  }

  /// Send message
  Future<void> sendMessage(MessageModel message) async {
    try {
      await _firebaseFirestore
          .collection(chatsCollection)
          .doc(message.chatId)
          .collection(messagesCollection)
          .add(message.toMap());

      // Update chat lastMessage and lastMessageTime
      await _firebaseFirestore.collection(chatsCollection).doc(message.chatId).update({
        'lastMessage': message.text,
        'lastMessageTime': message.timestamp,
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Get messages for chat
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firebaseFirestore
        .collection(chatsCollection)
        .doc(chatId)
        .collection(messagesCollection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MessageModel.fromSnapshot(doc)).toList());
  }

  // ==================== LEADS ====================

  /// Create lead
  Future<String> createLead(LeadModel lead) async {
    try {
      final docRef =
          await _firebaseFirestore.collection(leadsCollection).add(lead.toMap());
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  /// Get leads for agent
  Future<List<LeadModel>> getLeadsForAgent(String agentId) async {
    try {
      final querySnapshot = await _firebaseFirestore
          .collection(leadsCollection)
          .where('agentId', isEqualTo: agentId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => LeadModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Update lead status
  Future<void> updateLeadStatus(String leadId, String status) async {
    try {
      await _firebaseFirestore
          .collection(leadsCollection)
          .doc(leadId)
          .update({'status': status});
    } catch (e) {
      rethrow;
    }
  }

  // ==================== STORAGE ====================

  /// Upload file to storage
  Future<String> uploadFile(
    String filePath,
    String storagePath,
  ) async {
    try {
      final ref = _firebaseStorage.ref(storagePath);
      final task = ref.putFile(File(filePath));
      final snapshot = await task;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  /// Delete file from storage
  Future<void> deleteFile(String storagePath) async {
    try {
      await _firebaseStorage.ref(storagePath).delete();
    } catch (e) {
      rethrow;
    }
  }
}
