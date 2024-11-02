import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/migration_project_provider.dart';
import '../models/migration_project.dart';

class MigrationProjectsListPage extends StatefulWidget {
  const MigrationProjectsListPage({super.key});

  @override
  State<MigrationProjectsListPage> createState() => _MigrationProjectsListPageState();
}

class _MigrationProjectsListPageState extends State<MigrationProjectsListPage> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<MigrationProjectProvider>().fetchMigrationProjects());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Migration Projects', style: Theme.of(context).textTheme.headlineSmall),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search Migration Projects',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: Consumer<MigrationProjectProvider>(
              builder: (context, provider, child) {
                if (provider.migrationProjects.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                final filteredProjects = provider.migrationProjects.where((project) =>
                  project.name.toLowerCase().contains(_searchQuery)
                ).toList();
                return ListView.separated(
                  itemCount: filteredProjects.length,
                  separatorBuilder: (context, index) => Divider(height: 1),
                  itemBuilder: (context, index) {
                    final project = filteredProjects[index];
                    return ListTile(
                      title: Text(project.name, style: Theme.of(context).textTheme.titleMedium),
                      subtitle: Text('Deadline: ${project.deadline.toString().split(' ')[0]}'),
                      leading: Icon(Icons.assignment, color: Theme.of(context).primaryColor),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () => context.go('/migration-projects/${project.id}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/migration-projects/create'),
        tooltip: 'Add New Project',
        child: Icon(Icons.add),
      ),
    );
  }
}
