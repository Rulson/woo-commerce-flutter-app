import 'package:flutter_dotenv/flutter_dotenv.dart';

// Load environment variables - these must be set in .env file
String get baseUrl {
  final url = dotenv.env['WOOCOMMERCE_BASE_URL'];
  if (url == null || url.isEmpty) {
    throw Exception('WOOCOMMERCE_BASE_URL not found in environment variables. Please check your .env file.');
  }
  return url;
}

String get consumerKey {
  final key = dotenv.env['WOOCOMMERCE_CONSUMER_KEY'];
  if (key == null || key.isEmpty) {
    throw Exception('WOOCOMMERCE_CONSUMER_KEY not found in environment variables. Please check your .env file.');
  }
  return key;
}

String get consumerSecret {
  final secret = dotenv.env['WOOCOMMERCE_CONSUMER_SECRET'];
  if (secret == null || secret.isEmpty) {
    throw Exception('WOOCOMMERCE_CONSUMER_SECRET not found in environment variables. Please check your .env file.');
  }
  return secret;
}

const String producctGetUrl = 'wp-json/wc/v3/products';
const String productCategoryGetUrl = 'wp-json/wc/v3/products/categories';
const String productsByCategoryUrl = 'wp-json/wc/v3/products';
const String createOrderUrl = 'wp-json/wc/v3/orders';
const String getCustomerUrl = 'wp-json/wc/v3/customers';
