import 'package:cloud_firestore/cloud_firestore.dart';

class AwsService {
  String id;
  String name;
  String type;
  String details;
  DateTime endOfSupportDeadline;
  String? migrationProjectId;

  AwsService({
    required this.id,
    required this.name,
    required this.type,
    required this.details,
    required this.endOfSupportDeadline,
    this.migrationProjectId,
  });

  factory AwsService.fromMap(Map<String, dynamic> map, String documentId) {
    return AwsService(
      id: documentId,
      name: map['name'],
      type: map['type'],
      details: map['details'],
      endOfSupportDeadline: (map['endOfSupportDeadline'] as Timestamp).toDate(),
      migrationProjectId: map['migrationProjectId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'details': details,
      'endOfSupportDeadline': Timestamp.fromDate(endOfSupportDeadline),
      'migrationProjectId': migrationProjectId,
    };
  }
}
