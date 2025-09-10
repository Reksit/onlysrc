import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class ApiService {
  static const String baseUrl = 'https://backend-7y12.onrender.com/api';
  static late Dio _dio;

  static void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Request interceptor to add auth token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final errorMessage = error.response?.data?['message'] ?? 
                              error.response?.data ?? '';
          
          // Only handle actual authentication failures
          if (errorMessage.toString().toLowerCase().contains('unauthorized') ||
              errorMessage.toString().toLowerCase().contains('invalid token') ||
              errorMessage.toString().toLowerCase().contains('token expired') ||
              errorMessage.toString().toLowerCase().contains('access denied')) {
            
            print('Authentication token invalid, clearing storage');
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('token');
            await prefs.remove('user');
          }
        }
        handler.next(error);
      },
    ));
  }

  // Auth API
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/signin', data: {
        'email': email,
        'password': password,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<String> register(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post('/auth/signup', data: userData);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<String> verifyOTP(String email, String otp) async {
    try {
      final response = await _dio.post('/auth/verify-otp', data: {
        'email': email,
        'otp': otp,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<String> resendOTP(String email) async {
    try {
      final response = await _dio.post('/auth/resend-otp?email=$email');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Assessment API
  static Future<Map<String, dynamic>> generateAIAssessment(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/assessments/generate-ai', data: data);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<List<Assessment>> getStudentAssessments() async {
    try {
      final response = await _dio.get('/assessments/student');
      return (response.data as List)
          .map((json) => Assessment.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> submitAssessment(String assessmentId, Map<String, dynamic> submission) async {
    try {
      final response = await _dio.post('/assessments/$assessmentId/submit', data: submission);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<List<Assessment>> getProfessorAssessments() async {
    try {
      final response = await _dio.get('/assessments/professor');
      return (response.data as List)
          .map((json) => Assessment.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> createAssessment(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/assessments', data: data);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<List<Map<String, dynamic>>> searchStudents(String query) async {
    try {
      final response = await _dio.get('/assessments/search-students?query=$query');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Task API
  static Future<List<Task>> getUserTasks() async {
    try {
      final response = await _dio.get('/tasks');
      return (response.data as List)
          .map((json) => Task.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Task> createTask(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/tasks', data: data);
      return Task.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Task> generateRoadmap(String taskId) async {
    try {
      final response = await _dio.post('/tasks/$taskId/roadmap');
      return Task.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Task> updateTaskStatus(String taskId, String status) async {
    try {
      final response = await _dio.put('/tasks/$taskId/status', data: {'status': status});
      return Task.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Chat API
  static Future<Map<String, dynamic>> sendAIMessage(String message) async {
    try {
      final response = await _dio.post('/chat/ai', data: {'message': message});
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<List<Map<String, dynamic>>> getConversations() async {
    try {
      final response = await _dio.get('/chat/conversations');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final response = await _dio.get('/chat/users');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<List<ChatMessage>> getChatHistory(String userId) async {
    try {
      final response = await _dio.get('/chat/history/$userId');
      return (response.data as List)
          .map((json) => ChatMessage.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<ChatMessage> sendMessage(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/chat/send', data: data);
      return ChatMessage.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<void> markMessagesAsRead(String userId) async {
    try {
      await _dio.put('/chat/mark-read/$userId');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Alumni Directory API
  static Future<List<AlumniProfile>> getAllVerifiedAlumni() async {
    try {
      final response = await _dio.get('/api/alumni-directory');
      return (response.data as List)
          .map((json) => AlumniProfile.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<List<AlumniProfile>> getAllVerifiedAlumniForAlumni() async {
    try {
      final response = await _dio.get('/api/alumni-directory/for-alumni');
      return (response.data as List)
          .map((json) => AlumniProfile.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Events API
  static Future<List<Event>> getApprovedEvents() async {
    try {
      final response = await _dio.get('/api/events/approved');
      return (response.data as List)
          .map((json) => Event.fromJson(json))
          .toList();
    } catch (e) {
      // Fallback to debug endpoint
      try {
        final fallbackResponse = await _dio.get('/debug/events');
        final events = fallbackResponse.data['events'] as List? ?? [];
        return events.map((json) => Event.fromJson(json)).toList();
      } catch (fallbackError) {
        print('Fallback events API also failed: $fallbackError');
        throw _handleError(e);
      }
    }
  }

  static Future<void> updateAttendance(String eventId, bool attending) async {
    try {
      await _dio.post('/api/events/$eventId/attendance', data: {'attending': attending});
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Job Board API
  static Future<List<Job>> getJobs() async {
    try {
      final response = await _dio.get('/jobs');
      return (response.data as List)
          .map((json) => Job.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Job> createJob(Map<String, dynamic> jobData) async {
    try {
      final response = await _dio.post('/jobs', data: jobData);
      return Job.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Job> updateJob(String jobId, Map<String, dynamic> jobData) async {
    try {
      final response = await _dio.put('/jobs/$jobId', data: jobData);
      return Job.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<void> deleteJob(String jobId) async {
    try {
      await _dio.delete('/jobs/$jobId');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Alumni Event Request API
  static Future<String> submitAlumniEventRequest(Map<String, dynamic> requestData) async {
    try {
      final response = await _dio.post('/api/alumni-events/request', data: requestData);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Connection API
  static Future<void> sendConnectionRequest(String recipientId, String message) async {
    try {
      await _dio.post('/connections/send-request', data: {
        'recipientId': recipientId,
        'message': message,
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<List<Map<String, dynamic>>> getPendingConnectionRequests() async {
    try {
      final response = await _dio.get('/connections/pending');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<void> acceptConnectionRequest(String connectionId) async {
    try {
      await _dio.post('/connections/$connectionId/accept');
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<void> rejectConnectionRequest(String connectionId) async {
    try {
      await _dio.post('/connections/$connectionId/reject');
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> getConnectionStatus(String userId) async {
    try {
      final response = await _dio.get('/connections/status/$userId');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Activity API
  static Future<void> logActivity(String type, String description) async {
    try {
      await _dio.post('/activities', data: {
        'type': type,
        'description': description,
      });
    } catch (e) {
      // Don't throw error for activity logging failures
      print('Failed to log activity: $e');
    }
  }

  static Future<Map<String, dynamic>> getHeatmapData(String userId) async {
    try {
      final response = await _dio.get('/activities/heatmap/$userId');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Resume API
  static Future<Map<String, dynamic>> uploadResume(File file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
      });
      final response = await _dio.post('/resumes/upload', data: formData);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<List<Map<String, dynamic>>> getMyResumes() async {
    try {
      final response = await _dio.get('/resumes/my');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>?> getCurrentResume() async {
    try {
      final response = await _dio.get('/resumes/current');
      return response.data;
    } catch (e) {
      return null; // No current resume is fine
    }
  }

  static Future<void> activateResume(String resumeId) async {
    try {
      await _dio.put('/resumes/$resumeId/activate');
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<void> deleteResume(String resumeId) async {
    try {
      await _dio.delete('/resumes/$resumeId');
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> analyzeResumeATS(String resumeId) async {
    try {
      final response = await _dio.post('/resumes/$resumeId/analyze-ats');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Circular API
  static Future<void> createCircular(Map<String, dynamic> data) async {
    try {
      await _dio.post('/circulars', data: data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<List<Circular>> getMyReceivedCirculars() async {
    try {
      final response = await _dio.get('/circulars/my-received');
      return (response.data as List)
          .map((json) => Circular.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<List<Circular>> getMySentCirculars() async {
    try {
      final response = await _dio.get('/circulars/my-sent');
      return (response.data as List)
          .map((json) => Circular.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<void> markCircularAsRead(String circularId) async {
    try {
      await _dio.post('/circulars/$circularId/read');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Management API
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _dio.get('/management/stats');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<List<Map<String, dynamic>>> getAlumniApplications() async {
    try {
      final response = await _dio.get('/management/alumni');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<String> approveAlumni(String alumniId, bool approved) async {
    try {
      final response = await _dio.put('/management/alumni/$alumniId/status', data: {'approved': approved});
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Student Profile API
  static Future<Map<String, dynamic>> getMyProfile() async {
    try {
      final response = await _dio.get('/students/my-profile');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<void> updateMyProfile(Map<String, dynamic> profileData) async {
    try {
      await _dio.put('/students/my-profile', data: profileData);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Alumni Profile API
  static Future<Map<String, dynamic>> getAlumniProfile() async {
    try {
      final response = await _dio.get('/alumni/my-profile');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<void> updateAlumniProfile(Map<String, dynamic> profileData) async {
    try {
      await _dio.put('/alumni/my-profile', data: profileData);
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> getAlumniStats() async {
    try {
      final response = await _dio.get('/alumni/stats');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Password Change API
  static Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await _dio.post('/auth/change-password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Attendance API
  static Future<List<Map<String, dynamic>>> getStudentsForAttendance(String department, String className) async {
    try {
      final response = await _dio.get('/attendance/students?department=${Uri.encodeComponent(department)}&className=$className');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<void> submitAttendance(Map<String, dynamic> attendanceData) async {
    try {
      await _dio.post('/attendance/submit', data: attendanceData);
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<List<Map<String, dynamic>>> getAttendanceRecords(String? className) async {
    try {
      final url = className != null ? '/attendance/professor/records?className=$className' : '/attendance/professor/records';
      final response = await _dio.get(url);
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> getStudentAttendanceSummary() async {
    try {
      final response = await _dio.get('/attendance/student/my-summary');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Error handling
  static String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final data = error.response!.data;
        if (data is Map<String, dynamic>) {
          return data['message'] ?? data['error'] ?? 'An error occurred';
        } else if (data is String) {
          return data;
        }
      }
      return error.message ?? 'Network error occurred';
    }
    return error.toString();
  }
}