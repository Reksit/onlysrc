import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/auth_provider.dart';
import 'providers/toast_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/landing_page.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/verify_otp_screen.dart';
import 'screens/dashboards/student_dashboard.dart';
import 'screens/dashboards/professor_dashboard.dart';
import 'screens/dashboards/alumni_dashboard.dart';
import 'screens/dashboards/management_dashboard.dart';
import 'utils/routes.dart';
import 'utils/theme.dart';

void main() {
  runApp(const EduConnectApp());
}

class EduConnectApp extends StatelessWidget {
  const EduConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ToastProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp(
            title: 'EduConnect',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            initialRoute: authProvider.isAuthenticated ? _getInitialRoute(authProvider.user?.role) : AppRoutes.splash,
            routes: {
              AppRoutes.splash: (context) => const SplashScreen(),
              AppRoutes.landing: (context) => const LandingPage(),
              AppRoutes.login: (context) => const LoginScreen(),
              AppRoutes.register: (context) => const RegisterScreen(),
              AppRoutes.verifyOtp: (context) => const VerifyOtpScreen(),
              AppRoutes.studentDashboard: (context) => const StudentDashboard(),
              AppRoutes.professorDashboard: (context) => const ProfessorDashboard(),
              AppRoutes.alumniDashboard: (context) => const AlumniDashboard(),
              AppRoutes.managementDashboard: (context) => const ManagementDashboard(),
            },
            builder: (context, child) {
              return Stack(
                children: [
                  child!,
                  Consumer<ToastProvider>(
                    builder: (context, toastProvider, _) {
                      return toastProvider.toasts.isNotEmpty
                          ? Positioned(
                              top: MediaQuery.of(context).padding.top + 16,
                              right: 16,
                              child: Column(
                                children: toastProvider.toasts
                                    .map((toast) => ToastWidget(toast: toast))
                                    .toList(),
                              ),
                            )
                          : const SizedBox.shrink();
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  String _getInitialRoute(String? role) {
    switch (role) {
      case 'STUDENT':
        return AppRoutes.studentDashboard;
      case 'PROFESSOR':
        return AppRoutes.professorDashboard;
      case 'ALUMNI':
        return AppRoutes.alumniDashboard;
      case 'MANAGEMENT':
        return AppRoutes.managementDashboard;
      default:
        return AppRoutes.landing;
    }
  }
}

class ToastWidget extends StatelessWidget {
  final ToastModel toast;

  const ToastWidget({super.key, required this.toast});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getBackgroundColor(toast.type),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getBorderColor(toast.type)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIcon(toast.type),
            color: _getIconColor(toast.type),
            size: 20,
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              toast.message,
              style: TextStyle(
                color: _getTextColor(toast.type),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => context.read<ToastProvider>().removeToast(toast.id),
            child: Icon(
              Icons.close,
              color: _getIconColor(toast.type),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Colors.green.shade50;
      case ToastType.error:
        return Colors.red.shade50;
      case ToastType.warning:
        return Colors.orange.shade50;
      case ToastType.info:
        return Colors.blue.shade50;
    }
  }

  Color _getBorderColor(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Colors.green.shade200;
      case ToastType.error:
        return Colors.red.shade200;
      case ToastType.warning:
        return Colors.orange.shade200;
      case ToastType.info:
        return Colors.blue.shade200;
    }
  }

  Color _getTextColor(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Colors.green.shade800;
      case ToastType.error:
        return Colors.red.shade800;
      case ToastType.warning:
        return Colors.orange.shade800;
      case ToastType.info:
        return Colors.blue.shade800;
    }
  }

  Color _getIconColor(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Colors.green.shade600;
      case ToastType.error:
        return Colors.red.shade600;
      case ToastType.warning:
        return Colors.orange.shade600;
      case ToastType.info:
        return Colors.blue.shade600;
    }
  }

  IconData _getIcon(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle;
      case ToastType.error:
        return Icons.error;
      case ToastType.warning:
        return Icons.warning;
      case ToastType.info:
        return Icons.info;
    }
  }
}

enum ToastType { success, error, warning, info }

class ToastModel {
  final String id;
  final String message;
  final ToastType type;

  ToastModel({
    required this.id,
    required this.message,
    required this.type,
  });
}