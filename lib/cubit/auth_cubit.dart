import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'auth_state.dart';
import '../model/user_model.dart';
import '../api_service.dart';

class AuthCubit extends Cubit<AuthState> {
  final ApiService _apiService;
  
  AuthCubit(this._apiService) : super(AuthInitial()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      
      if (userJson != null) {
        final userMap = json.decode(userJson);
        final user = User.fromJson(userMap);
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    
    try {
      final response = await _apiService.login(email, password);
      
      if (response.statusCode == 200 && response.data is List && response.data.isNotEmpty) {
        final user = User.fromJson(response.data[0]); // Get first customer from list
        
        // Save user data locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', json.encode(user.toJson()));
        
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthError('Login failed. Please check your credentials.'));
      }
    } catch (e) {
      emit(AuthError('Login failed: ${e.toString()}'));
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    emit(AuthLoading());
    
    try {
      final response = await _apiService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );
      
      if (response.statusCode == 201) {
        final user = User.fromJson(response.data);
        
        // Save user data locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', json.encode(user.toJson()));
        
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthError('Registration failed. Please try again.'));
      }
    } catch (e) {
      emit(AuthError('Registration failed: ${e.toString()}'));
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Logout failed: ${e.toString()}'));
    }
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    Map<String, dynamic>? billing,
    Map<String, dynamic>? shipping,
  }) async {
    if (state is AuthAuthenticated) {
      final currentUser = (state as AuthAuthenticated).user;
      
      try {
        final response = await _apiService.updateCustomer(
          currentUser.id,
          firstName: firstName,
          lastName: lastName,
          phone: phone,
          billing: billing,
          shipping: shipping,
        );
        
        if (response.statusCode == 200) {
          final updatedUser = User.fromJson(response.data);
          
          // Update local storage
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user', json.encode(updatedUser.toJson()));
          
          emit(AuthAuthenticated(updatedUser));
        } else {
          emit(AuthError('Profile update failed.'));
        }
      } catch (e) {
        emit(AuthError('Profile update failed: ${e.toString()}'));
      }
    }
  }
} 