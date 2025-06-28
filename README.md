# Flutter E-Commerce App

A modern Flutter e-commerce mobile application (Android & iOS) with WooCommerce integration, featuring product browsing, cart management, and checkout functionality.

## Features

### Core Features
- **Product Browsing**: Browse products with images, descriptions, and pricing
- **Category Filtering**: Filter products by categories with a persistent category filter
- **Shopping Cart**: Add/remove items, update quantities, and view cart total
- **Checkout Process**: Complete checkout with shipping information and payment options
- **Payment Methods**: Support for both credit card and cash on delivery
- **WooCommerce Integration**: Full integration with WooCommerce REST API

### Technical Features
- **State Management**: BLoC pattern with Cubit for cart and product management
- **API Integration**: RESTful API calls with Dio HTTP client
- **Error Handling**: Comprehensive error handling and user feedback
- **Responsive Design**: Modern UI with Material Design components
- **Debug Support**: cURL logging for API debugging


## Setup Instructions

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / VS Code
- For Android development: Android SDK and emulator/device
- For iOS development: Xcode (macOS only) and iOS simulator/device
- WooCommerce store with REST API access

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd e_commerce
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Environment Variables**
   
   The project includes a `.env` file with the actual WooCommerce API credentials. This file is already configured and ready to use.
   
   If you need to use different credentials, edit the `.env` file:
   ```env
   # Your WooCommerce store URL 
   WOOCOMMERCE_BASE_URL=https://your-domain.com/
   
   # WooCommerce REST API credentials
   # Get these from WooCommerce → Settings → Advanced → REST API
   WOOCOMMERCE_CONSUMER_KEY=your_consumer_key_here
   WOOCOMMERCE_CONSUMER_SECRET=your_consumer_secret_here
   ```
   
   **Note**: The `.env` file contains sensitive information and is already added to `.gitignore` to prevent it from being committed to version control.

4. **Run the app**
   ```bash
   flutter run
   ```

## Configuration

### WordPress Setup

1. **Set Permalinks**
   - Go to WordPress Dashboard → Settings → Permalinks
   - Select "Post name" option
   - Click "Save Changes"

### WooCommerce Setup

1. **Enable REST API**
   - Go to WooCommerce → Settings → Advanced → REST API
   - Click "Add Key"
   - Set permissions to "Read/Write"
   - Copy the Consumer Key and Consumer Secret

2. **Required WooCommerce Settings**
   - Ensure products are published and visible
   - Set up shipping zones and methods
   - Configure payment gateways (Stripe for card payments, COD for cash)

### API Endpoints

The app uses the following WooCommerce REST API endpoints:
- `GET /wp-json/wc/v3/products` - Fetch products
- `GET /wp-json/wc/v3/products/categories` - Fetch categories
- `GET /wp-json/wc/v3/customers` - Get customer by email
- `POST /wp-json/wc/v3/customers` - Create customer
- `POST /wp-json/wc/v3/orders` - Create order

## Project Structure

```
lib/
├── api_constant.dart          # API endpoint constants
├── api_service.dart           # WooCommerce API service
├── main.dart                  # App entry point
├── cubit/                     # State management
│   ├── cart_cubit.dart        # Cart state management
│   ├── cart_state.dart        # Cart state definitions
│   ├── product_cubit.dart     # Product state management
│   └── product_state.dart     # Product state definitions
├── model/                     # Data models
│   ├── cart_item_model.dart   # Cart item model
│   ├── category_model.dart    # Category model
│   └── product_model.dart     # Product model
├── screens/                   # App screens
│   ├── home_screen.dart       # Main product browsing screen
│   ├── cart_screen.dart       # Shopping cart screen
│   └── checkout_screen.dart   # Checkout process screen
└── widgets/                   # Reusable widgets
    └── product_card.dart      # Product display widget
```

## Dependencies

"Key dependencies used in this project (can be substituted with alternatives or removed entirely):"

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.3          # State management
  dio: ^5.3.2                   # HTTP client
  dio_intercept_to_curl: ^0.2.0 # cURL logging for API debugging
  cached_network_image: ^3.3.0  # Image caching
  flutter_badge: ^0.0.3         # Badge widget for cart
```

## Usage

### Browsing Products
1. Launch the app to see the home screen with products
2. Use the category filter at the top to browse specific categories
3. Tap on a product to view details and add to cart

### Managing Cart
1. Add products to cart from the product grid
2. View cart by tapping the cart icon in the app bar
3. Update quantities or remove items in the cart screen
4. Proceed to checkout when ready

### Checkout Process
1. Fill in shipping information (name, email, address, etc.)
2. Select payment method (credit card or cash on delivery)
3. Review order summary
4. Place order to complete the purchase

## Debugging

### API Debugging
The app includes a cURL interceptor that logs all API requests. Check the console output for:
- cURL commands for manual testing
- Request headers and body
- Response status and data
- Error details

### Common Issues

1. **404 Errors**: Check if the base URL ends with a trailing slash
2. **Authentication Errors**: Verify consumer key and secret
3. **Product Loading Issues**: Ensure products are published in WooCommerce
4. **Order Creation Failures**: Check WooCommerce order settings and payment methods
5. **Environment Variable Errors**: If you see errors about missing environment variables:
   - Ensure the `.env` file exists in the project root
   - Check that the `.env` file contains all required variables
   - Verify the variable names match exactly (case-sensitive)
   - Make sure there are no extra spaces or quotes around values

## Security

- API credentials are stored in the `.env` file (environment variables) for security
- The `.env` file is added to `.gitignore` to prevent committing secrets to version control
- The app will throw clear error messages if environment variables are missing
- HTTPS is required for WooCommerce API communication
- Customer data is transmitted securely via HTTPS
- Never commit the `.env` file to version control
- The `env.example` file serves as a template without real credentials

## Deployment

### Android
```bash
# Development
flutter build apk --debug

# Release
flutter build apk --release
```

### iOS
```bash
# Development
flutter build ios --debug

# Release
flutter build ios --release
```

### Production Setup
1. Configure production environment variables in `.env`
2. Test on real devices
3. For App Store: Use Xcode to archive and upload
4. For Play Store: Create signed APK or App Bundle

**Note**: This app is designed for mobile platforms (Android and iOS) only.

