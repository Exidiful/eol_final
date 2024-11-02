import 'package:flutter/foundation.dart';
import '../models/aws_service.dart';
import '../mock_data.dart';
import '../services/firebase_service.dart';

class AwsServiceProvider extends ChangeNotifier {
  List<AwsService> _awsServices = [];
  bool _isLoading = false;

  List<AwsService> get awsServices => _awsServices;
  bool get isLoading => _isLoading;

  AwsServiceProvider() {
    fetchAwsServices();
  }

  Future<void> fetchAwsServices() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Use the mock data directly
      _awsServices = List.from(MockData.awsServices); // Create a new list
      print('AwsServiceProvider loaded ${_awsServices.length} services');
      for (var service in _awsServices) {
        print('Service: ${service.name}, Type: ${service.type}');
      }
    } catch (e) {
      print('Error fetching AWS services: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAwsService(AwsService service) async {
    try {
      final docRef = await FirebaseService.firestore.collection('aws_services').add(service.toMap());
      service.id = docRef.id;
      _awsServices.add(service);
      notifyListeners();
    } catch (e) {
      print('Error adding AWS service: $e');
    }
  }

  Future<void> updateAwsService(AwsService service) async {
    try {
      await FirebaseService.firestore.collection('aws_services').doc(service.id).update(service.toMap());
      final index = _awsServices.indexWhere((s) => s.id == service.id);
      if (index != -1) {
        _awsServices[index] = service;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating AWS service: $e');
    }
  }

  Future<void> deleteAwsService(String id) async {
    try {
      await FirebaseService.firestore.collection('aws_services').doc(id).delete();
      _awsServices.removeWhere((s) => s.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting AWS service: $e');
    }
  }
}
