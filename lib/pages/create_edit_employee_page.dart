import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/employee_provider.dart';
import '../models/employee.dart';

class CreateEditEmployeePage extends StatefulWidget {
  final String? id;

  const CreateEditEmployeePage({super.key, this.id});

  @override
  State<CreateEditEmployeePage> createState() => _CreateEditEmployeePageState();
}

class _CreateEditEmployeePageState extends State<CreateEditEmployeePage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _email;

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      final employee = context.read<EmployeeProvider>().employees.firstWhere((e) => e.id == widget.id);
      _name = employee.name;
      _email = employee.email;
    } else {
      _name = '';
      _email = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.id != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Employee' : 'Create Employee'),
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
              TextFormField(
                initialValue: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Please enter an email' : null,
                onSaved: (value) => _email = value!,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final provider = context.read<EmployeeProvider>();
                    final employee = Employee(
                      id: widget.id ?? '',
                      name: _name,
                      email: _email,
                      assignedMigrationProjectIds: [],
                    );
                    if (isEditing) {
                      await provider.updateEmployee(employee);
                    } else {
                      await provider.addEmployee(employee);
                    }
                    context.go('/employees');
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
