import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/cart_item_model.dart';
import '../model/product_model.dart';
import '../api_service.dart';
import 'auth_state.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final ApiService _apiService;
  
  CartCubit(this._apiService) : super(CartInitial());

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  double get totalAmount {
    return _items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  int get itemCount {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  // Load cart items from WooCommerce
  Future<void> loadCart() async {
    final authState = _getAuthState();
    if (authState is! AuthAuthenticated) {
      emit(CartUpdated(_items, totalAmount, itemCount));
      return;
    }

    emit(CartLoading());
    
    try {
      final response = await _apiService.getCartItems(authState.user.id);
      
      if (response.statusCode == 200 && response.data is List) {
        _items.clear();
        
        for (final cartItemData in response.data) {
          // Fetch product details for each cart item
          final productResponse = await _apiService.getProducts();
          if (productResponse.statusCode == 200 && productResponse.data is List) {
            final products = productResponse.data as List;
            final productData = products.firstWhere(
              (p) => p['id'] == cartItemData['product_id'],
              orElse: () => null,
            );
            
            if (productData != null) {
              final product = Product.fromJson(productData);
              final cartItem = CartItem.fromJson(cartItemData, product);
              _items.add(cartItem);
            }
          }
        }
        
        emit(CartUpdated(_items, totalAmount, itemCount));
      } else {
        emit(CartError('Failed to load cart items'));
      }
    } catch (e) {
      emit(CartError('Failed to load cart: ${e.toString()}'));
    }
  }

  Future<void> addItem(Product product) async {
    final authState = _getAuthState();
    if (authState is! AuthAuthenticated) {
      // Fallback to local cart if not authenticated
      _addItemLocally(product);
      return;
    }

    try {
      final existingItem = _items.firstWhere(
        (item) => item.product.id == product.id,
        orElse: () => CartItem(
          id: 0,
          productId: product.id,
          product: product,
          quantity: 0,
          price: _parseProductPrice(product.price),
          totalPrice: 0,
          createdAt: DateTime.now(),
        ),
      );

      final newQuantity = existingItem.quantity + 1;
      
      if (existingItem.id == 0) {
        // Create new cart item
        final response = await _apiService.createCartItem(
          authState.user.id,
          product.id,
          newQuantity,
        );
        
        if (response.statusCode == 201) {
          final cartItem = CartItem.fromJson(response.data, product);
          _items.add(cartItem);
        }
      } else {
        // Update existing cart item
        final response = await _apiService.updateCartItem(
          existingItem.id,
          newQuantity,
        );
        
        if (response.statusCode == 200) {
          final updatedItem = CartItem.fromJson(response.data, product);
          final index = _items.indexWhere((item) => item.id == existingItem.id);
          if (index >= 0) {
            _items[index] = updatedItem;
          }
        }
      }
      
      emit(CartUpdated(_items, totalAmount, itemCount));
    } catch (e) {
      emit(CartError('Failed to add item: ${e.toString()}'));
    }
  }

  Future<void> removeItem(int productId) async {
    final authState = _getAuthState();
    if (authState is! AuthAuthenticated) {
      // Fallback to local cart if not authenticated
      _removeItemLocally(productId);
      return;
    }

    try {
      final existingItem = _items.firstWhere(
        (item) => item.product.id == productId,
      );

      if (existingItem.quantity > 1) {
        // Update quantity
        final response = await _apiService.updateCartItem(
          existingItem.id,
          existingItem.quantity - 1,
        );
        
        if (response.statusCode == 200) {
          final updatedItem = CartItem.fromJson(response.data, existingItem.product);
          final index = _items.indexWhere((item) => item.id == existingItem.id);
          if (index >= 0) {
            _items[index] = updatedItem;
          }
        }
      } else {
        // Delete cart item
        final response = await _apiService.deleteCartItem(existingItem.id);
        
        if (response.statusCode == 200) {
          _items.removeWhere((item) => item.id == existingItem.id);
        }
      }
      
      emit(CartUpdated(_items, totalAmount, itemCount));
    } catch (e) {
      emit(CartError('Failed to remove item: ${e.toString()}'));
    }
  }

  Future<void> clearCart() async {
    final authState = _getAuthState();
    if (authState is! AuthAuthenticated) {
      // Fallback to local cart if not authenticated
      _items.clear();
      emit(CartUpdated(_items, totalAmount, itemCount));
      return;
    }

    try {
      final response = await _apiService.clearCart(authState.user.id);
      
      if (response.statusCode == 200) {
        _items.clear();
        emit(CartUpdated(_items, totalAmount, itemCount));
      } else {
        emit(CartError('Failed to clear cart'));
      }
    } catch (e) {
      emit(CartError('Failed to clear cart: ${e.toString()}'));
    }
  }

  // Local cart methods for unauthenticated users
  void _addItemLocally(Product product) {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    final productPrice = _parseProductPrice(product.price);
    
    if (existingIndex >= 0) {
      final currentQuantity = _items[existingIndex].quantity;
      final newQuantity = currentQuantity + 1;
      final newTotalPrice = productPrice * newQuantity;
      
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: newQuantity,
        totalPrice: newTotalPrice,
      );
    } else {
      _items.add(CartItem(
        id: DateTime.now().millisecondsSinceEpoch,
        productId: product.id,
        product: product,
        quantity: 1,
        price: productPrice,
        totalPrice: productPrice,
        createdAt: DateTime.now(),
      ));
    }
    
    emit(CartUpdated(_items, totalAmount, itemCount));
  }

  void _removeItemLocally(int productId) {
    final existingIndex = _items.indexWhere((item) => item.product.id == productId);
    
    if (existingIndex >= 0) {
      if (_items[existingIndex].quantity > 1) {
        final currentQuantity = _items[existingIndex].quantity;
        final newQuantity = currentQuantity - 1;
        final productPrice = _parseProductPrice(_items[existingIndex].product.price);
        final newTotalPrice = productPrice * newQuantity;
        
        _items[existingIndex] = _items[existingIndex].copyWith(
          quantity: newQuantity,
          totalPrice: newTotalPrice,
        );
      } else {
        _items.removeAt(existingIndex);
      }
      
      emit(CartUpdated(_items, totalAmount, itemCount));
    }
  }

  // Helper method to get auth state
  AuthState? _getAuthState() {
    try {
      // This is a simplified approach - in a real app, you'd inject the auth cubit
      return null; // Will fallback to local cart
    } catch (e) {
      return null;
    }
  }

  double _parseProductPrice(String? price) {
    if (price == null) {
      throw Exception("Invalid price format");
    }
    return double.parse(price);
  }
} 