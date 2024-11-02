import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/aws_service_provider.dart';
import '../models/aws_service.dart';

class CreateEditAwsServicePage extends StatefulWidget {
  final String? id;

  const CreateEditAwsServicePage({super.key, this.id});

  @override
  State<CreateEditAwsServicePage> createState() => _CreateEditAwsServicePageState();
}

class _CreateEditAwsServicePageState extends State<CreateEditAwsServicePage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _type;
  late String _details;
  late DateTime _endOfSupportDeadline;

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      final service = context.read<AwsServiceProvider>().awsServices.firstWhere((s) => s.id == widget.id);
      _name = service.name;
      _type = service.type;
      _details = service.details;
      _endOfSupportDeadline = service.endOfSupportDeadline;
    } else {
      _name = '';
      _type = '';
      _details = '';
      _endOfSupportDeadline = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.id != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit AWS Service' : 'Create AWS Service', style: Theme.of(context).textTheme.headlineSmall),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  initialValue: _name,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
                  onSaved: (value) => _name = value!,
                ),
                SizedBox(height: 16),
                TextFormField(
                  initialValue: _type,
                  decoration: InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter a type' : null,
                  onSaved: (value) => _type = value!,
                ),
                SizedBox(height: 16),
                TextFormField(
                  initialValue: _details,
                  decoration: InputDecoration(
                    labelText: 'Details',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) => value!.isEmpty ? 'Please enter details' : null,
                  onSaved: (value) => _details = value!,
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _endOfSupportDeadline,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                    );
                    if (date != null) {
                      setState(() => _endOfSupportDeadline = date);
                    }
                  },
                  icon: Icon(Icons.calendar_today),
                  label: Text('End of Support: ${_endOfSupportDeadline.toString().split(' ')[0]}'),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(isEditing ? 'Update' : 'Create'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final provider = context.read<AwsServiceProvider>();
      final service = AwsService(
        id: widget.id ?? '',
        name: _name,
        type: _type,
        details: _details,
        endOfSupportDeadline: _endOfSupportDeadline,
      );
      if (widget.id != null) {
        await provider.updateAwsService(service);
      } else {
        await provider.addAwsService(service);
      }
      context.go('/aws-services');
    }
  }
}
