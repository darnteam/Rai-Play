import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  // Login user
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'accept': 'application/json',
        },
        body: {
          'username': username,
          'password': password,
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception(_getLoginErrorMessage(responseData));
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Unable to connect to server. Please check your internet connection.');
    }
  }

  // Sign up user
  static Future<Map<String, dynamic>> signup(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return responseData;
      } else {
        throw Exception(_getSignupErrorMessage(responseData));
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Unable to connect to server. Please check your internet connection.');
    }
  }

  // Helper method to format login error messages
  static String _getLoginErrorMessage(Map<String, dynamic> response) {
    if (response['detail'] is List) {
      final errors = response['detail'] as List;
      // Check for missing fields
      if (errors.any((e) => e['type'] == 'missing')) {
        return 'Please fill in all required fields';
      }
      // Check for incorrect credentials
      if (errors.any((e) => e['msg']?.toString().contains('credentials') ?? false)) {
        return 'Incorrect username or password';
      }
      // Generic validation error
      return 'Please check your input and try again';
    } else if (response['detail'] is String) {
      final error = response['detail'] as String;
      if (error.toLowerCase().contains('credentials')) {
        return 'Incorrect username or password';
      }
      if (error.toLowerCase().contains('inactive')) {
        return 'Account is inactive. Please contact support.';
      }
      return error;
    }
    return 'Login failed. Please try again.';
  }

  // Helper method to format signup error messages
  static String _getSignupErrorMessage(Map<String, dynamic> response) {
    if (response['detail'] is List) {
      final errors = response['detail'] as List;
      // Check for existing user
      if (errors.any((e) => e['msg']?.toString().contains('already registered') ?? false)) {
        return 'Username or email is already registered';
      }
      // Check for invalid email
      if (errors.any((e) => e['msg']?.toString().contains('email') ?? false)) {
        return 'Please enter a valid email address';
      }
      // Check for password requirements
      if (errors.any((e) => e['msg']?.toString().contains('password') ?? false)) {
        return 'Password does not meet requirements';
      }
      // Generic validation error
      return 'Please check your input and try again';
    } else if (response['detail'] is String) {
      final error = response['detail'] as String;
      if (error.toLowerCase().contains('already registered')) {
        return 'Username or email is already registered';
      }
      return error;
    }
    return 'Sign up failed. Please try again.';
  }

  static Future<String> chat(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['reply'] as String;
      } else {
        throw Exception('Failed to get chat response');
      }
    } catch (e) {
      throw Exception('Error connecting to chat service: $e');
    }
  }
}
