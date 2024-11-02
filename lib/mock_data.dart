import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'models/aws_service.dart';
import 'models/migration_project.dart';
import 'models/employee.dart';

class MockData {
  static List<AwsService> awsServices = [];
  static List<MigrationProject> migrationProjects = [];
  static List<Employee> employees = [];

  static Future<void> loadData() async {
    final jsonString = await rootBundle.loadString('assets/data.json');
    final jsonData = json.decode(jsonString);
    await _processData(jsonData);
  }

  static Future<void> updateData(Map<String, dynamic> jsonData) async {
    await _processData(jsonData);
  }

  static Future<void> _processData(Map<String, dynamic> jsonData) async {
    awsServices.clear();
    migrationProjects.clear();
    employees.clear();

    await _loadAwsServices(jsonData);
    _generateMigrationProjects();
    _generateEmployees();
  }

  static Future<void> _loadAwsServices(Map<String, dynamic> jsonData) async {
    int id = 1;
    void addServices(String key, String type) {
      final services = jsonData[key] as List?;
      if (services != null) {
        print('Loading $key: ${services.length} services');
        for (var serviceWrapper in services) {
          if (serviceWrapper != null) {
            final service = serviceWrapper is List ? serviceWrapper[0] : serviceWrapper;
            if (service is Map<String, dynamic>) {
              awsServices.add(AwsService(
                id: id.toString(),
                name: service['instanceid'] ?? service['functionname'] ?? service['dbinstanceidentifier'] ?? '',
                type: type,
                details: _generateDetails(service, type),
                endOfSupportDeadline: DateTime.now().add(Duration(days: 365 + id * 30 - (id % 5) * 180)), // Some services will be nearing EOS
              ));
              id++;
            }
          }
        }
      } else {
        print('No services found for $key');
      }
    }

    addServices('ec2instances', 'EC2 Instance');
    addServices('lambdafunctions', 'Lambda Function');
    addServices('rdsinstances', 'RDS Instance');

    print('Total loaded AWS services: ${awsServices.length}');
  }

  static String _generateDetails(Map<String, dynamic> service, String type) {
    if (type == 'EC2 Instance') {
      return 'OS: ${service['os'] ?? 'Unknown'}, OS Version: ${service['osversion'] ?? 'Unknown'}';
    } else if (type == 'Lambda Function') {
      return 'Runtime: ${service['runtime'] ?? 'Unknown'}';
    } else if (type == 'RDS Instance') {
      return 'Engine: ${service['engine'] ?? 'Unknown'}, Engine Version: ${service['engineversion'] ?? 'Unknown'}';
    }
    return '';
  }

  static void _generateMigrationProjects() {
    final projectStatuses = ['Not Started', 'In Progress', 'Completed', 'On Hold'];
    migrationProjects = [
      MigrationProject(
        id: '1',
        name: 'EC2 Migration Project',
        awsServiceIds: awsServices.where((s) => s.type == 'EC2 Instance').take(5).map((s) => s.id).toList(),
        assignedEmployeeId: '1',
        deadline: DateTime.now().add(Duration(days: 90)),
        status: projectStatuses[1], // In Progress
      ),
      MigrationProject(
        id: '2',
        name: 'Lambda Upgrade Project',
        awsServiceIds: awsServices.where((s) => s.type == 'Lambda Function').take(3).map((s) => s.id).toList(),
        assignedEmployeeId: '2',
        deadline: DateTime.now().add(Duration(days: 60)),
        status: projectStatuses[2], // Completed
      ),
      MigrationProject(
        id: '3',
        name: 'RDS Migration Project',
        awsServiceIds: awsServices.where((s) => s.type == 'RDS Instance').take(4).map((s) => s.id).toList(),
        assignedEmployeeId: '3',
        deadline: DateTime.now().add(Duration(days: 120)),
        status: projectStatuses[1], // In Progress
      ),
      MigrationProject(
        id: '4',
        name: 'Legacy System Retirement',
        awsServiceIds: awsServices.take(2).map((s) => s.id).toList(),
        assignedEmployeeId: '1',
        deadline: DateTime.now().add(Duration(days: 180)),
        status: projectStatuses[0], // Not Started
      ),
      MigrationProject(
        id: '5',
        name: 'Cloud Cost Optimization',
        awsServiceIds: awsServices.skip(5).take(3).map((s) => s.id).toList(),
        assignedEmployeeId: '2',
        deadline: DateTime.now().add(Duration(days: 45)),
        status: projectStatuses[3], // On Hold
      ),
    ];
  }

  static void _generateEmployees() {
    employees = [
      Employee(
        id: '1',
        name: 'Ali AlQattan',
        email: 'ali.alqattan@example.com',
        assignedMigrationProjectIds: ['1', '4'],
      ),
      Employee(
        id: '2',
        name: 'Nelson',
        email: 'nelson@example.com',
        assignedMigrationProjectIds: ['2', '5'],
      ),
      Employee(
        id: '3',
        name: 'Ahmad Radhi',
        email: 'ahmad.radhi@example.com',
        assignedMigrationProjectIds: ['3'],
      ),
      Employee(
        id: '4',
        name: 'Sarah Johnson',
        email: 'sarah.johnson@example.com',
        assignedMigrationProjectIds: [],
      ),
      Employee(
        id: '5',
        name: 'Michael Chen',
        email: 'michael.chen@example.com',
        assignedMigrationProjectIds: [],
      ),
    ];
  }
}
