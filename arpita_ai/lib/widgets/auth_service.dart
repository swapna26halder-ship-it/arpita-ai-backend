
import 'dart:convert';
import 'package:arpita_ai/config/api_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  static const String baseUrl =  ApiConfig.baseUrl;

  static const String _accessTokenKey = 'access_token';
  static const String _tokenTypeKey = 'token_type';

  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type':
              'application/json',
        },
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      );

      Map<String, dynamic>? data;

      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      } catch (_) {
        data = null;
      }

      if (response.statusCode == 200) {
        final accessToken = data?['access_token'];
        final tokenType = data?['token_type'];

        if (accessToken is! String ||
            accessToken.isEmpty ||
            tokenType is! String ||
            tokenType.isEmpty) {
          return const LoginResult.failure(
            'Invalid authentication response from server.',
          );
        }

        await _storage.write(
          key: _accessTokenKey,
          value: accessToken,
        );

        await _storage.write(
          key: _tokenTypeKey,
          value: tokenType,
        );

        return LoginResult.success(
          accessToken: accessToken,
          tokenType: tokenType,
        );
      }

      final detail = data?['detail'];

      return LoginResult.failure(
        detail?.toString() ??
            'Login failed. Please check your credentials.',
      );
    } catch (_) {
      return const LoginResult.failure(
        'Unable to connect to the server.',
      );
    }
  }

  Future<String?> getAccessToken() async {
    return _storage.read(
      key: _accessTokenKey,
    );
  }

  Future<String?> getTokenType() async {
    return _storage.read(
      key: _tokenTypeKey,
    );
  }

  Future<Map<String, String>> authorizationHeaders() async {
    final token = await getAccessToken();
    final tokenType = await getTokenType();

    if (token == null || token.isEmpty) {
      return {};
    }

    return {
      'Authorization':
          '${tokenType ?? 'Bearer'} $token',
    };
  }

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();

    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    await _storage.delete(
      key: _accessTokenKey,
    );

    await _storage.delete(
      key: _tokenTypeKey,
    );
  }
  Future<LoginResult> register({
  required String username,
  required String email,
  required String password,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username.trim(),
        'email': email.trim(),
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return const LoginResult.registered();
        
    }

    return LoginResult.failure(
      data['detail']?.toString() ?? 'Registration failed',
    );
  } catch (e) {
    return LoginResult.failure(
      'Something went wrong. Please try again.',
    );
  }
}


}

class LoginResult {
  final bool success;
  final String? message;
  final String? accessToken;
  final String? tokenType;

  const LoginResult._({
    required this.success,
    this.message,
    this.accessToken,
    this.tokenType,
  });
  const LoginResult.registered()
    : this._(
        success: true,
        message: 'Registration successful',
      );
  const LoginResult.success({
    required String accessToken,
    required String tokenType,
  }) : this._(
          success: true,
          accessToken: accessToken,
          tokenType: tokenType,
        );

  const LoginResult.failure(String message)
      : this._(
          success: false,
          message: message,
        );
}
