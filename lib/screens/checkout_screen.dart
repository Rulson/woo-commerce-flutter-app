import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../cubit/cart_cubit.dart';
import '../api_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  
  String _selectedPaymentMethod = 'card'; // 'card' or 'cash'
  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state is CartUpdated) {
            if (state.items.isEmpty) {
              return const Center(
                child: Text('Your cart is empty'),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Summary
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Order Summary',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...state.items.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item.product.name} x${item.quantity}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  Text(
                                    '\$${item.totalPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '\$${state.totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Shipping Information
                    const Text(
                      'Shipping Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _cityController,
                            decoration: const InputDecoration(
                              labelText: 'City',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your city';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _zipCodeController,
                            decoration: const InputDecoration(
                              labelText: 'ZIP Code',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your ZIP code';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Payment Information
                    const Text(
                      'Payment Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Payment Method Selection
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Payment Method',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: const Text('Credit/Debit Card'),
                                    value: 'card',
                                    groupValue: _selectedPaymentMethod,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedPaymentMethod = value!;
                                      });
                                    },
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: const Text('Cash on Delivery'),
                                    value: 'cash',
                                    groupValue: _selectedPaymentMethod,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedPaymentMethod = value!;
                                      });
                                    },
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Card Payment Fields (only show if card is selected)
                    if (_selectedPaymentMethod == 'card') ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _cardNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Card Number',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: _selectedPaymentMethod == 'card' ? (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter card number';
                          }
                          if (value.length < 16) {
                            return 'Please enter a valid card number';
                          }
                          return null;
                        } : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _expiryController,
                              decoration: const InputDecoration(
                                labelText: 'MM/YY',
                                border: OutlineInputBorder(),
                              ),
                              validator: _selectedPaymentMethod == 'card' ? (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter expiry date';
                                }
                                return null;
                              } : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _cvvController,
                              decoration: const InputDecoration(
                                labelText: 'CVV',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: _selectedPaymentMethod == 'card' ? (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter CVV';
                                }
                                if (value.length < 3) {
                                  return 'Please enter a valid CVV';
                                }
                                return null;
                              } : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    // Cash on Delivery Info
                    if (_selectedPaymentMethod == 'cash') ...[
                      const SizedBox(height: 16),
                      Card(
                        color: Colors.blue[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.money, color: Colors.blue[700]),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Cash on Delivery',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[700],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Pay with cash when your order is delivered',
                                      style: TextStyle(
                                        color: Colors.blue[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 32),

                    // Place Order Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _placeOrder(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          _selectedPaymentMethod == 'cash' 
                              ? 'Place Order (Cash on Delivery)'
                              : 'Place Order',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void _placeOrder(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      // Store references before async operation
      final cartCubit = context.read<CartCubit>();
      
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // First, try to find existing customer by email
        Response customerResponse;
        int customerId;
        
        try {
          customerResponse = await _apiService.getCustomerByEmail(_emailController.text);
          if (customerResponse.data is List && customerResponse.data.isNotEmpty) {
            // Customer exists, use their ID
            customerId = customerResponse.data[0]['id'];
          } else {
            // Customer doesn't exist, create new one
            final customerData = {
              'email': _emailController.text,
              'first_name': _nameController.text.split(' ').first,
              'last_name': _nameController.text.split(' ').length > 1 
                  ? _nameController.text.split(' ').skip(1).join(' ') 
                  : '',
              'billing': {
                'first_name': _nameController.text.split(' ').first,
                'last_name': _nameController.text.split(' ').length > 1 
                    ? _nameController.text.split(' ').skip(1).join(' ') 
                    : '',
                'address_1': _addressController.text,
                'address_2': '',
                'city': _cityController.text,
                'state': '',
                'postcode': _zipCodeController.text,
                'country': 'US',
                'email': _emailController.text,
                'phone': _phoneController.text,
              },
              'shipping': {
                'first_name': _nameController.text.split(' ').first,
                'last_name': _nameController.text.split(' ').length > 1 
                    ? _nameController.text.split(' ').skip(1).join(' ') 
                    : '',
                'address_1': _addressController.text,
                'address_2': '',
                'city': _cityController.text,
                'state': '',
                'postcode': _zipCodeController.text,
                'country': 'US',
              },
            };
            
            final newCustomerResponse = await _apiService.createCustomer(customerData);
            customerId = newCustomerResponse.data['id'];
          }
        } catch (e) {
          // If getting customer fails, create a new one
          final customerData = {
            'email': _emailController.text,
            'first_name': _nameController.text.split(' ').first,
            'last_name': _nameController.text.split(' ').length > 1 
                ? _nameController.text.split(' ').skip(1).join(' ') 
                : '',
            'billing': {
              'first_name': _nameController.text.split(' ').first,
              'last_name': _nameController.text.split(' ').length > 1 
                  ? _nameController.text.split(' ').skip(1).join(' ') 
                  : '',
              'address_1': _addressController.text,
              'address_2': '',
              'city': _cityController.text,
              'state': '',
              'postcode': _zipCodeController.text,
              'country': 'US',
              'email': _emailController.text,
              'phone': _phoneController.text,
            },
            'shipping': {
              'first_name': _nameController.text.split(' ').first,
              'last_name': _nameController.text.split(' ').length > 1 
                  ? _nameController.text.split(' ').skip(1).join(' ') 
                  : '',
              'address_1': _addressController.text,
              'address_2': '',
              'city': _cityController.text,
              'state': '',
              'postcode': _zipCodeController.text,
              'country': 'US',
            },
          };
          
          final newCustomerResponse = await _apiService.createCustomer(customerData);
          customerId = newCustomerResponse.data['id'];
        }
        
        // Build order data for WooCommerce API with customer ID
        final orderData = _buildOrderData(customerId);
        
        // Call the actual API to create order
        await _apiService.createOrder(orderData);
        
        if (!mounted) return;
        
        // Store context before async operation
        final navigatorContext = context;
        
        Navigator.pop(navigatorContext); // Close loading dialog
        
        // Show success dialog
        showDialog(
          context: navigatorContext,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Order Placed Successfully!'),
            content: Text(
              _selectedPaymentMethod == 'cash'
                  ? 'Thank you for your purchase! Your order will be delivered and you can pay with cash upon delivery. You will receive an email confirmation shortly.'
                  : 'Thank you for your purchase. You will receive an email confirmation shortly.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext); // Close dialog
                  cartCubit.clearCart(); // Clear cart
                  Navigator.popUntil(navigatorContext, (route) => route.isFirst); // Go to home
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } catch (error) {
        if (!mounted) return;
        
        final navigatorContext = context;
        Navigator.pop(navigatorContext); // Close loading dialog
        
        // Show error dialog
        showDialog(
          context: navigatorContext,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Order Failed'),
            content: Text('Failed to place order: $error'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Map<String, dynamic> _buildOrderData([int? customerId]) {
    final cartState = context.read<CartCubit>().state;
    if (cartState is! CartUpdated) {
      throw Exception('Cart is empty');
    }

    // Build line items from cart
    final lineItems = cartState.items.map((item) => {
      'product_id': item.product.id,
      'quantity': item.quantity,
    }).toList();

    // Build order data according to WooCommerce API
    final orderData = {
      'payment_method': _selectedPaymentMethod == 'cash' ? 'cod' : 'stripe',
      'payment_method_title': _selectedPaymentMethod == 'cash' 
          ? 'Cash on Delivery' 
          : 'Credit Card',
      'set_paid': _selectedPaymentMethod != 'cash', // Only mark as paid for card payments
      'billing': {
        'first_name': _nameController.text.split(' ').first,
        'last_name': _nameController.text.split(' ').length > 1 
            ? _nameController.text.split(' ').skip(1).join(' ') 
            : '',
        'address_1': _addressController.text,
        'address_2': '',
        'city': _cityController.text,
        'state': '',
        'postcode': _zipCodeController.text,
        'country': 'US',
        'email': _emailController.text,
        'phone': _phoneController.text,
      },
      'shipping': {
        'first_name': _nameController.text.split(' ').first,
        'last_name': _nameController.text.split(' ').length > 1 
            ? _nameController.text.split(' ').skip(1).join(' ') 
            : '',
        'address_1': _addressController.text,
        'address_2': '',
        'city': _cityController.text,
        'state': '',
        'postcode': _zipCodeController.text,
        'country': 'US',
      },
      'line_items': lineItems,
      'shipping_lines': [
        {
          'method_id': 'flat_rate',
          'method_title': 'Flat Rate',
          'total': '10.00',
        }
      ],
    };

    // Add customer ID if provided
    if (customerId != null) {
      orderData['customer_id'] = customerId;
    }

    return orderData;
  }
} 