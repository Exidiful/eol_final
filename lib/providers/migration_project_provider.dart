import 'package:flutter/foundation.dart';
import '../models/migration_project.dart';
import '../mock_data.dart';
import '../services/firebase_service.dart';

class MigrationProjectProvider extends ChangeNotifier {
  List<MigrationProject> _migrationProjects = [];
  bool _isLoading = false;

  List<MigrationProject> get migrationProjects => _migrationProjects;
  bool get isLoading => _isLoading;

  MigrationProjectProvider() {
    _migrationProjects = MockData.migrationProjects;
  }

  Future<void> fetchMigrationProjects() async {
    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, this would fetch from Firestore
      // For now, we'll just use the mock data with a delay to simulate network request
      await Future.delayed(Duration(seconds: 1));
      _migrationProjects = MockData.migrationProjects;
    } catch (e) {
      print('Error fetching migration projects: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMigrationProject(MigrationProject project) async {
    try {
      final docRef = await FirebaseService.firestore.collection('migration_projects').add(project.toMap());
      project.id = docRef.id;
      _migrationProjects.add(project);
      notifyListeners();
    } catch (e) {
      print('Error adding migration project: $e');
    }
  }

  Future<void> updateMigrationProject(MigrationProject project) async {
    try {
      await FirebaseService.firestore.collection('migration_projects').doc(project.id).update(project.toMap());
      final index = _migrationProjects.indexWhere((p) => p.id == project.id);
      if (index != -1) {
        _migrationProjects[index] = project;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating migration project: $e');
    }
  }

  Future<void> deleteMigrationProject(String id) async {
    try {
      await FirebaseService.firestore.collection('migration_projects').doc(id).delete();
      _migrationProjects.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting migration project: $e');
    }
  }
}
