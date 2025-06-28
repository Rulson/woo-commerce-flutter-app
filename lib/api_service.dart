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
