import 'package:cloud_firestore/cloud_firestore.dart';

class LeadModel {
  final String id;
  final String propertyId;
  final String buyerId;
  final String agentId;
  final String status; // new, contacted, visited, interested, rejected, closed
  final DateTime createdAt;
  final DateTime? contactedAt;
  final String? notes;
  final String leadSource; // contact_button, chat_started, schedule_visit

  LeadModel({
    required this.id,
    required this.propertyId,
    required this.buyerId,
    required this.agentId,
    this.status = 'new',
    required this.createdAt,
    this.contactedAt,
    this.notes,
    this.leadSource = 'contact_button',
  });

  Map<String, dynamic> toMap() {
    return {
      'propertyId': propertyId,
      'buyerId': buyerId,
      'agentId': agentId,
      'status': status,
      'createdAt': createdAt,
      'contactedAt': contactedAt,
      'notes': notes,
      'leadSource': leadSource,
    };
  }

  factory LeadModel.fromMap(Map<String, dynamic> map, String documentId) {
    return LeadModel(
      id: documentId,
      propertyId: map['propertyId'] ?? '',
      buyerId: map['buyerId'] ?? '',
      agentId: map['agentId'] ?? '',
      status: map['status'] ?? 'new',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      contactedAt: map['contactedAt'] is Timestamp
          ? (map['contactedAt'] as Timestamp).toDate()
          : null,
      notes: map['notes'],
      leadSource: map['leadSource'] ?? 'contact_button',
    );
  }

  factory LeadModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    return LeadModel.fromMap(doc.data() ?? {}, doc.id);
  }
}
