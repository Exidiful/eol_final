import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/employee_provider.dart';
import '../models/employee.dart';

class EmployeesListPage extends StatefulWidget {
  const EmployeesListPage({super.key});

  @override
  State<EmployeesListPage> createState() => _EmployeesListPageState();
}

class _EmployeesListPageState extends State<EmployeesListPage> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<EmployeeProvider>().fetchEmployees());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employees', style: Theme.of(context).textTheme.headlineSmall),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search Employees',
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
            child: Consumer<EmployeeProvider>(
              builder: (context, provider, child) {
                if (provider.employees.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                final filteredEmployees = provider.employees.where((employee) =>
                  employee.name.toLowerCase().contains(_searchQuery) ||
                  employee.email.toLowerCase().contains(_searchQuery)
                ).toList();
                return ListView.separated(
                  itemCount: filteredEmployees.length,
                  separatorBuilder: (context, index) => Divider(height: 1),
                  itemBuilder: (context, index) {
                    final employee = filteredEmployees[index];
                    return ListTile(
                      title: Text(employee.name, style: Theme.of(context).textTheme.titleMedium),
                      subtitle: Text(employee.email),
                      leading: CircleAvatar(child: Text(employee.name[0])),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () => context.go('/employees/${employee.id}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/employees/create'),
        tooltip: 'Add New Employee',
        child: Icon(Icons.add),
      ),
    );
  }
}
