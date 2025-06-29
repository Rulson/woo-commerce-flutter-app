import 'package:dio/dio.dart';
import 'package:dio_intercept_to_curl/dio_intercept_to_curl.dart';
import 'api_constant.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  ApiService() {
    _dio.interceptors.add(DioInterceptToCurl());
  }

  Future<Response> getProducts({int perPage = 10, int page = 1}) async {
    try {
      final response = await _dio.get(
        producctGetUrl,
        queryParameters: {
          'consumer_key': consumerKey,
          'consumer_secret': consumerSecret,
          'per_page': perPage,
          'page': page,
        },
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> getProductCategories({
    int perPage = 10,
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        productCategoryGetUrl,
        queryParameters: {
          'consumer_key': consumerKey,
          'consumer_secret': consumerSecret,
          'per_page': perPage,
          'page': page,
        },
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> getProductsByCategory({
    required int categoryId,
    int perPage = 10,
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        productsByCategoryUrl,
        queryParameters: {
          'consumer_key': consumerKey,
          'consumer_secret': consumerSecret,
          'category': categoryId,
          'per_page': perPage,
          'page': page,
        },
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await _dio.post(
        createOrderUrl,
        queryParameters: {
          'consumer_key': consumerKey,
          'consumer_secret': consumerSecret,
        },
        data: orderData,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> getCustomerByEmail(String email) async {
    try {
      final response = await _dio.get(
        getCustomerUrl,
        queryParameters: {
          'consumer_key': consumerKey,
          'consumer_secret': consumerSecret,
          'email': email,
        },
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> createCustomer(Map<String, dynamic> customerData) async {
    try {
      final response = await _dio.post(
        getCustomerUrl,
        queryParameters: {
          'consumer_key': consumerKey,
          'consumer_secret': consumerSecret,
        },
        data: customerData,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> login(String email, String password) async {
    try {
      // First, try to find the customer by email
      final customerResponse = await _dio.get(
        getCustomerUrl,
        queryParameters: {
          'consumer_key': consumerKey,
          'consumer_secret': consumerSecret,
          'email': email,
        },
      );
      
      if (customerResponse.data is List && customerResponse.data.isNotEmpty) {
        // Customer exists, return the customer data
        return customerResponse;
      } else {
        // Customer not found
        throw Exception('Invalid email or password');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    try {
      final response = await _dio.post(
        getCustomerUrl,
        queryParameters: {
          'consumer_key': consumerKey,
          'consumer_secret': consumerSecret,
        },
        data: {
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
          'username': email.split('@').first, // Use email prefix as username
          'billing': {
            'first_name': firstName,
            'last_name': lastName,
            'email': email,
            'phone': phone ?? '',
          },
          'shipping': {
            'first_name': firstName,
            'last_name': lastName,
          },
        },
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> updateCustomer(
    int customerId, {
    String? firstName,
    String? lastName,
    String? phone,
    Map<String, dynamic>? billing,
    Map<String, dynamic>? shipping,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      
      if (firstName != null) updateData['first_name'] = firstName;
      if (lastName != null) updateData['last_name'] = lastName;
      if (phone != null) updateData['phone'] = phone;
      if (billing != null) updateData['billing'] = billing;
      if (shipping != null) updateData['shipping'] = shipping;

      final response = await _dio.put(
        '$getCustomerUrl/$customerId',
        queryParameters: {
          'consumer_key': consumerKey,
          'consumer_secret': consumerSecret,
        },
        data: updateData,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Cart Management Endpoints
  Future<Response> createCartItem(int customerId, int productId, int quantity) async {
    try {
      final response = await _dio.post(
        'wp-json/wc/v3/cart-items',
        queryParameters: {
          'consumer_key': consumerKey,
          'consumer_secret': consumerSecret,
        },
        data: {
          'customer_id': customerId,
          'product_id': productId,
          'quantity': quantity,
        },
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> getCartItems(int customerId) async {
    try {
      final response = await _dio.get(
        'wp-json/wc/v3/cart-items',
        queryParameters: {
          'consumer_key': consumerKey,
          'consumer_secret': consumerSecret,
          'customer_id': customerId,
        },
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> updateCartItem(int cartItemId, int quantity) async {
    try {
      final response = await _dio.put(
        'wp-json/wc/v3/cart-items/$cartItemId',
        queryParameters: {
          'consumer_key': consumerKey,
          'consumer_secret': consumerSecret,
        },
        data: {
          'quantity': quantity,
        },
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> deleteCartItem(int cartItemId) async {
    try {
      final response = await _dio.delete(
        'wp-json/wc/v3/cart-items/$cartItemId',
        queryParameters: {
          'consumer_key': consumerKey,
          'consumer_secret': consumerSecret,
        },
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> clearCart(int customerId) async {
    try {
      final response = await _dio.delete(
        'wp-json/wc/v3/cart-items',
        queryParameters: {
          'consumer_key': consumerKey,
          'consumer_secret': consumerSecret,
          'customer_id': customerId,
        },
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        return 'Server error: ${e.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}
