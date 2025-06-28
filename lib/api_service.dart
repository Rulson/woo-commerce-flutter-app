import 'package:dio/dio.dart';
import 'api_constant.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  static const String consumerKey =
      'ck_d6d77c247d4d496be2e4712a9dcefd18ccdcd41a';
  static const String consumerSecret =
      'cs_698a5dc09f7f622c920ea2eb76ffa527fe945489';

  ApiService() {
    _dio.interceptors.add(CurlInterceptor());
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

class CurlInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final curl = _buildCurlCommand(options);
    print('🌐 cURL Command:');
    print(curl);
    print('📤 Request Headers: ${options.headers}');
    if (options.data != null) {
      print('📦 Request Body: ${options.data}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('📥 Response Status: ${response.statusCode}');
    print('📥 Response Headers: ${response.headers}');
    print('📥 Response Data: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('❌ Error: ${err.message}');
    print('❌ Error Type: ${err.type}');
    print('❌ Error Response: ${err.response?.data}');
    super.onError(err, handler);
  }

  String _buildCurlCommand(RequestOptions options) {
    final buffer = StringBuffer();
    buffer.write('curl --location');
    buffer.write(' -X ${options.method.toUpperCase()}');

    // Add headers
    options.headers.forEach((key, value) {
      if (key != 'content-length') {
        buffer.write(' -H "$key: $value"');
      }
    });

    // Construct the URL properly
    String url = options.baseUrl;
    if (!url.endsWith('/') && !options.path.startsWith('/')) {
      url += '/';
    }
    url += options.path;

    // Add query parameters
    if (options.queryParameters.isNotEmpty) {
      final queryString = options.queryParameters.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');
      url += '?$queryString';
    }

    buffer.write(' \'$url\'');

    // Add body for POST/PUT requests
    if (options.data != null &&
        (options.method == 'POST' ||
            options.method == 'PUT' ||
            options.method == 'PATCH')) {
      if (options.data is Map) {
        buffer.write(' -d \'${options.data}\'');
      } else {
        buffer.write(' -d "${options.data}"');
      }
    }

    return buffer.toString();
  }
}
