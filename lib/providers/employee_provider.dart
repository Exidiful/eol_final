import 'package:flutter/foundation.dart';
import '../models/employee.dart';
import '../mock_data.dart';
import '../services/firebase_service.dart';

class EmployeeProvider extends ChangeNotifier {
  List<Employee> _employees = [];
  bool _isLoading = false;

  List<Employee> get employees => _employees;
  bool get isLoading => _isLoading;

  EmployeeProvider() {
    _employees = MockData.employees;
  }

  Future<void> fetchEmployees() async {
    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, this would fetch from Firestore
      // For now, we'll just use the mock data with a delay to simulate network request
      await Future.delayed(Duration(seconds: 1));
      _employees = MockData.employees;
    } catch (e) {
      print('Error fetching employees: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addEmployee(Employee employee) async {
    try {
      final docRef = await FirebaseService.firestore.collection('employees').add(employee.toMap());
      employee.id = docRef.id;
      _employees.add(employee);
      notifyListeners();
    } catch (e) {
      print('Error adding employee: $e');
    }
  }

  Future<void> updateEmployee(Employee employee) async {
    try {
      await FirebaseService.firestore.collection('employees').doc(employee.id).update(employee.toMap());
      final index = _employees.indexWhere((e) => e.id == employee.id);
      if (index != -1) {
        _employees[index] = employee;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating employee: $e');
    }
  }

  Future<void> deleteEmployee(String id) async {
    try {
      await FirebaseService.firestore.collection('employees').doc(id).delete();
      _employees.removeWhere((e) => e.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting employee: $e');
    }
  }
}
