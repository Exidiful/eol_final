import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/employee_provider.dart';
import '../providers/migration_project_provider.dart';

class EmployeeDetailsPage extends StatelessWidget {
  final String id;

  const EmployeeDetailsPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Employee Details')),
      body: Consumer2<EmployeeProvider, MigrationProjectProvider>(
        builder: (context, employeeProvider, projectProvider, child) {
          final employee = employeeProvider.employees.firstWhere((e) => e.id == id);
          final assignedProjects = projectProvider.migrationProjects
              .where((p) => employee.assignedMigrationProjectIds.contains(p.id))
              .toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${employee.name}', style: Theme.of(context).textTheme.titleLarge),
                Text('Email: ${employee.email}', style: Theme.of(context).textTheme.bodyLarge),
                SizedBox(height: 16),
                Text('Assigned Projects:', style: Theme.of(context).textTheme.titleLarge),
                Expanded(
                  child: ListView.builder(
                    itemCount: assignedProjects.length,
                    itemBuilder: (context, index) {
                      final project = assignedProjects[index];
                      return ListTile(
                        title: Text(project.name),
                        subtitle: Text('Deadline: ${project.deadline.toString().split(' ')[0]}'),
                        onTap: () => context.go('/migration-projects/${project.id}'),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () => context.go('/employees/edit/$id'),
                  child: const Text('Edit Employee'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
