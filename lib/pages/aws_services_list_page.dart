import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/aws_service_provider.dart';
import '../models/aws_service.dart';

class AwsServicesListPage extends StatefulWidget {
  const AwsServicesListPage({super.key});

  @override
  State<AwsServicesListPage> createState() => _AwsServicesListPageState();
}

class _AwsServicesListPageState extends State<AwsServicesListPage> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = context.read<AwsServiceProvider>();
      provider.fetchAwsServices();
      print('AwsServicesListPage initialized with ${provider.awsServices.length} services');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AWS Services', style: Theme.of(context).textTheme.headlineSmall),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Search AWS Services',
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
            SizedBox(height: 16),
            Expanded(
              child: Consumer<AwsServiceProvider>(
                builder: (context, provider, child) {
                  print('Building AWS Services List. Total services: ${provider.awsServices.length}');
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (provider.awsServices.isEmpty) {
                    return const Center(child: Text('No AWS services found.'));
                  }
                  final filteredServices = provider.awsServices.where((service) =>
                    service.name.toLowerCase().contains(_searchQuery) ||
                    service.type.toLowerCase().contains(_searchQuery)
                  ).toList();
                  print('Filtered services: ${filteredServices.length}');
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return constraints.maxWidth > 600
                        ? _buildGridView(filteredServices)
                        : _buildListView(filteredServices);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/aws-services/create'),
        tooltip: 'Add New Service',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildListView(List<AwsService> services) {
    return ListView.separated(
      itemCount: services.length,
      separatorBuilder: (context, index) => Divider(height: 1),
      itemBuilder: (context, index) {
        final service = services[index];
        return ListTile(
          title: Text(service.name, style: Theme.of(context).textTheme.titleMedium),
          subtitle: Text(service.type),
          leading: Icon(Icons.cloud, color: Theme.of(context).primaryColor),
          trailing: Icon(Icons.chevron_right),
          onTap: () => context.go('/aws-services/${service.id}'),
        );
      },
    );
  }

  Widget _buildGridView(List<AwsService> services) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return Card(
          child: InkWell(
            onTap: () => context.go('/aws-services/${service.id}'),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.name, style: Theme.of(context).textTheme.titleMedium),
                  Text(service.type, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
