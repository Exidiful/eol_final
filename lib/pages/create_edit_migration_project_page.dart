import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/migration_project_provider.dart';
import '../models/migration_project.dart';

class CreateEditMigrationProjectPage extends StatefulWidget {
  final String? id;

  const CreateEditMigrationProjectPage({super.key, this.id});

  @override
  State<CreateEditMigrationProjectPage> createState() => _CreateEditMigrationProjectPageState();
}

class _CreateEditMigrationProjectPageState extends State<CreateEditMigrationProjectPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late DateTime _deadline;
  late String _assignedEmployeeId;
  List<String> _awsServiceIds = [];

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      final project = context.read<MigrationProjectProvider>().migrationProjects.firstWhere((p) => p.id == widget.id);
      _name = project.name;
      _deadline = project.deadline;
      _assignedEmployeeId = project.assignedEmployeeId;
      _awsServiceIds = project.awsServiceIds;
    } else {
      _name = '';
      _deadline = DateTime.now().add(const Duration(days: 30));
      _assignedEmployeeId = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.id != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Migration Project' : 'Create Migration Project'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
                onSaved: (value) => _name = value!,
              ),
              ElevatedButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _deadline,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                  );
                  if (date != null) {
                    setState(() => _deadline = date);
                  }
                },
                child: Text('Deadline: ${_deadline.toString().split(' ')[0]}'),
              ),
              TextFormField(
                initialValue: _assignedEmployeeId,
                decoration: const InputDecoration(labelText: 'Assigned Employee ID'),
                validator: (value) => value!.isEmpty ? 'Please enter an employee ID' : null,
                onSaved: (value) => _assignedEmployeeId = value!,
              ),
              // TODO: Implement multi-select for AWS services
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final provider = context.read<MigrationProjectProvider>();
                    final project = MigrationProject(
                      id: widget.id ?? '',
                      name: _name,
                      deadline: _deadline,
                      assignedEmployeeId: _assignedEmployeeId,
                      awsServiceIds: _awsServiceIds, status: 'In Progress',
                    );
                    if (isEditing) {
                      await provider.updateMigrationProject(project);
                    } else {
                      await provider.addMigrationProject(project);
                    }
                    context.go('/migration-projects');
                  }
                },
                child: Text(isEditing ? 'Update' : 'Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
