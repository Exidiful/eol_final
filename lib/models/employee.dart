
class Employee {
  String id;
  String name;
  String email;
  List<String> assignedMigrationProjectIds;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.assignedMigrationProjectIds,
  });

  factory Employee.fromMap(Map<String, dynamic> map, String documentId) {
    return Employee(
      id: documentId,
      name: map['name'],
      email: map['email'],
      assignedMigrationProjectIds: List<String>.from(map['assignedMigrationProjectIds']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'assignedMigrationProjectIds': assignedMigrationProjectIds,
    };
  }
}