import 'package:go_router/go_router.dart';
import '../pages/core_page.dart';
import '../pages/aws_service_details_page.dart';
import '../pages/migration_project_details_page.dart';
import '../pages/create_edit_aws_service_page.dart';
import '../pages/create_edit_migration_project_page.dart';
import '../pages/employee_details_page.dart';
import '../pages/create_edit_employee_page.dart';
import '../pages/dashboard_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const CorePage(),
      ),
      GoRoute(
        path: '/aws-services/:id',
        builder: (context, state) => AwsServiceDetailsPage(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/migration-projects/:id',
        builder: (context, state) => MigrationProjectDetailsPage(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/aws-services/create',
        builder: (context, state) => const CreateEditAwsServicePage(),
      ),
      GoRoute(
        path: '/aws-services/edit/:id',
        builder: (context, state) => CreateEditAwsServicePage(id: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/migration-projects/create',
        builder: (context, state) => const CreateEditMigrationProjectPage(),
      ),
      GoRoute(
        path: '/migration-projects/edit/:id',
        builder: (context, state) => CreateEditMigrationProjectPage(id: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/employees/:id',
        builder: (context, state) => EmployeeDetailsPage(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/employees/create',
        builder: (context, state) => const CreateEditEmployeePage(),
      ),
      GoRoute(
        path: '/employees/edit/:id',
        builder: (context, state) => CreateEditEmployeePage(id: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
    ],
  );
}
