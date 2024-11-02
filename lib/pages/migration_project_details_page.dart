import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/migration_project_provider.dart';

class MigrationProjectDetailsPage extends StatelessWidget {
  final String id;

  const MigrationProjectDetailsPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Migration Project Details')),
      body: Consumer<MigrationProjectProvider>(
        builder: (context, provider, child) {
          final project = provider.migrationProjects.firstWhere((p) => p.id == id);
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Name: ${project.name}'),
                Text('Deadline: ${project.deadline.toString().split(' ')[0]}'),
                Text('Assigned Employee ID: ${project.assignedEmployeeId}'),
                Text('AWS Services: ${project.awsServiceIds.join(', ')}'),
                ElevatedButton(
                  onPressed: () => context.go('/migration-projects/edit/$id'),
                  child: const Text('Edit Project'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await provider.deleteMigrationProject(id);
                    context.go('/migration-projects');
                  },
                  child: const Text('Delete Project'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
