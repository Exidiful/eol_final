import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import '../providers/aws_service_provider.dart';
import '../providers/migration_project_provider.dart';
import '../providers/employee_provider.dart';
import '../providers/theme_provider.dart';
import '../models/aws_service.dart';
import '../models/migration_project.dart';
import '../models/employee.dart';
import '../mock_data.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await Future.wait([
      context.read<AwsServiceProvider>().fetchAwsServices(),
      context.read<MigrationProjectProvider>().fetchMigrationProjects(),
      context.read<EmployeeProvider>().fetchEmployees(),
    ]);
  }

  Future<void> _uploadNewData() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        String content = String.fromCharCodes(result.files.first.bytes!);
        Map<String, dynamic> jsonData = json.decode(content);
        
        await MockData.updateData(jsonData);
        await _loadData();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data updated successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AWS Migration Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1E2632),
        actions: [
          IconButton(
            icon: Icon(Icons.upload_file),
            onPressed: _uploadNewData,
            tooltip: 'Upload new data.json',
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) => themeProvider.toggleTheme(value),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Consumer3<AwsServiceProvider, MigrationProjectProvider, EmployeeProvider>(
      builder: (context, awsProvider, projectProvider, employeeProvider, child) {
        if (awsProvider.isLoading || projectProvider.isLoading || employeeProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMetricsGrid(awsProvider, projectProvider, employeeProvider),
                SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildAwsServiceTypeChart(awsProvider),
                    ),
                    SizedBox(width: 24),
                    Expanded(
                      flex: 1,
                      child: _buildUpcomingDeadlines(projectProvider),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                _buildRecentActivities(awsProvider, projectProvider, employeeProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricsGrid(AwsServiceProvider awsProvider, MigrationProjectProvider projectProvider, EmployeeProvider employeeProvider) {
    return GridView.count(
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        _buildMetricCard('AWS Services', '${awsProvider.awsServices.length}', 'Total services to migrate', Icons.cloud, Colors.blue),
        _buildMetricCard('Migration Projects', '${projectProvider.migrationProjects.length}', 'Active projects', Icons.assignment, Colors.green),
        _buildMetricCard('Employees', '${employeeProvider.employees.length}', 'Assigned to projects', Icons.people, Colors.orange),
        _buildMetricCard('Pending Tasks', '${_calculatePendingTasks(projectProvider)}', 'Across all projects', Icons.pending_actions, Colors.red),
      ],
    );
  }

  int _calculatePendingTasks(MigrationProjectProvider projectProvider) {
    return projectProvider.migrationProjects
        .where((project) => project.deadline.isAfter(DateTime.now()))
        .length;
  }

  Widget _buildMetricCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Card(
      color: Color(0xFF2A3441),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 32),
            Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
            Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
            Text(subtitle, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildAwsServiceTypeChart(AwsServiceProvider awsProvider) {
    final serviceTypes = _getServiceTypeCounts(awsProvider.awsServices);
    return Card(
      color: Color(0xFF2A3441),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AWS Service Types', style: TextStyle(color: Colors.white, fontSize: 18)),
            SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.5,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: serviceTypes.values.reduce((a, b) => a > b ? a : b).toDouble(),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= serviceTypes.length) return Text('');
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              serviceTypes.keys.elementAt(value.toInt()),
                              style: TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString(), style: TextStyle(color: Colors.white, fontSize: 10));
                        },
                        reservedSize: 30,
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: serviceTypes.entries.map((entry) {
                    return BarChartGroupData(
                      x: serviceTypes.keys.toList().indexOf(entry.key),
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(),
                          color: Colors.blue,
                          width: 16,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, int> _getServiceTypeCounts(List<AwsService> services) {
    final counts = <String, int>{};
    for (var service in services) {
      counts[service.type] = (counts[service.type] ?? 0) + 1;
    }
    return counts;
  }

  Widget _buildUpcomingDeadlines(MigrationProjectProvider projectProvider) {
    final upcomingProjects = projectProvider.migrationProjects
        .where((p) => p.deadline.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
    return Card(
      color: Color(0xFF2A3441),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Upcoming Deadlines', style: TextStyle(color: Colors.white, fontSize: 18)),
            SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              itemCount: upcomingProjects.length,
              itemBuilder: (context, index) {
                final project = upcomingProjects[index];
                return ListTile(
                  title: Text(project.name, style: TextStyle(color: Colors.white)),
                  subtitle: Text(
                    'Deadline: ${DateFormat('MMM dd, yyyy').format(project.deadline)}',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: _getColorForDeadline(project.deadline),
                    child: Text('${index + 1}', style: TextStyle(color: Colors.white)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities(AwsServiceProvider awsProvider, MigrationProjectProvider projectProvider, EmployeeProvider employeeProvider) {
    return Card(
      color: Color(0xFF2A3441),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Activities', style: TextStyle(color: Colors.white, fontSize: 18)),
            SizedBox(height: 16),
            ListView(
              shrinkWrap: true,
              children: [
                _buildActivityItem('New AWS service added', 'EC2 Instance', Icons.add_circle),
                _buildActivityItem('Project deadline updated', 'Lambda Migration', Icons.update),
                _buildActivityItem('Employee assigned to project', 'RDS Migration', Icons.person_add),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String activity, String details, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(activity, style: TextStyle(color: Colors.white)),
      subtitle: Text(details, style: TextStyle(color: Colors.grey[400])),
      trailing: Text('2h ago', style: TextStyle(color: Colors.grey[400])),
    );
  }

  Color _getColorForDeadline(DateTime deadline) {
    final daysUntilDeadline = deadline.difference(DateTime.now()).inDays;
    if (daysUntilDeadline <= 7) {
      return Colors.red;
    } else if (daysUntilDeadline <= 30) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}
