import 'package:cloud_firestore/cloud_firestore.dart';

class MigrationProject {
  String id;
  String name;
  List<String> awsServiceIds;
  String assignedEmployeeId;
  DateTime deadline;
  String status;

  MigrationProject({
    required this.id,
    required this.name,
    required this.awsServiceIds,
    required this.assignedEmployeeId,
    required this.deadline,
    required this.status,
  });

  factory MigrationProject.fromMap(Map<String, dynamic> map, String documentId) {
    return MigrationProject(
      id: documentId,
      name: map['name'],
      awsServiceIds: List<String>.from(map['awsServiceIds']),
      assignedEmployeeId: map['assignedEmployeeId'],
      deadline: (map['deadline'] as Timestamp).toDate(),
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'awsServiceIds': awsServiceIds,
      'assignedEmployeeId': assignedEmployeeId,
      'deadline': Timestamp.fromDate(deadline),
      'status': status,
    };
  }
}
