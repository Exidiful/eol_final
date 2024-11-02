import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/aws_service_provider.dart';

class AwsServiceDetailsPage extends StatelessWidget {
  final String id;

  const AwsServiceDetailsPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AWS Service Details')),
      body: Consumer<AwsServiceProvider>(
        builder: (context, provider, child) {
          final service = provider.awsServices.firstWhere((s) => s.id == id);
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Name: ${service.name}'),
                Text('Type: ${service.type}'),
                Text('Details: ${service.details}'),
                Text('End of Support: ${service.endOfSupportDeadline.toString()}'),
                ElevatedButton(
                  onPressed: () => context.go('/aws-services/edit/$id'),
                  child: const Text('Edit Service'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await provider.deleteAwsService(id);
                    context.go('/aws-services');
                  },
                  child: const Text('Delete Service'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
