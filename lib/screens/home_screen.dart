import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/product_cubit.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/product_card.dart';
import '../model/category_model.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Category? selectedCategory;

  @override
  void initState() {
    super.initState();
    context.read<ProductCubit>().fetchCategories();
    context.read<ProductCubit>().fetchProducts();
    
    // Load cart items if user is authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartCubit>().loadCart();
    });
  }

  void _onCategorySelected(Category? category) {
    setState(() {
      selectedCategory = category;
    });
    if (category != null) {
      context.read<ProductCubit>().fetchProductsByCategory(categoryId: category.id);
    } else {
      context.read<ProductCubit>().fetchProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Commerce Store'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              if (state is CartUpdated) {
                return Badge(
                  label: Text('${state.itemCount}'),
                  child: IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartScreen(),
                        ),
                      );
                    },
                  ),
                );
              }
              return IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CartScreen(),
                    ),
                  );
                },
              );
            },
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<AuthCubit>().logout();
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Fixed Category Filter at the top - Separate BlocBuilder
          BlocBuilder<ProductCubit, ProductState>(
            buildWhen: (previous, current) {
              // Only rebuild for category-related states
              return current is CategoryLoaded || current is CategoryLoading;
            },
            builder: (context, state) {
              if (state is CategoryLoaded) {
                return Container(
                  height: 80,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.categories.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: FilterChip(
                            label: const Text('All Products'),
                            selected: selectedCategory == null,
                            onSelected: (selected) {
                              _onCategorySelected(null);
                            },
                            selectedColor: Colors.blue[100],
                            checkmarkColor: Colors.blue,
                            avatar: selectedCategory == null 
                                ? const Icon(Icons.check_circle, size: 16, color: Colors.blue)
                                : null,
                            elevation: selectedCategory == null ? 4 : 1,
                          ),
                        );
                      }
                      final category = state.categories[index - 1];
                      final isSelected = selectedCategory?.id == category.id;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: FilterChip(
                          label: Text(
                            category.name,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            _onCategorySelected(selected ? category : null);
                          },
                          selectedColor: Colors.blue[100],
                          checkmarkColor: Colors.blue,
                          avatar: isSelected 
                              ? const Icon(Icons.check_circle, size: 16, color: Colors.blue)
                              : null,
                          elevation: isSelected ? 4 : 1,
                          backgroundColor: Colors.grey[200],
                        ),
                      );
                    },
                  ),
                );
              } else if (state is CategoryLoading) {
                return Container(
                  height: 80,
                  color: Colors.white,
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
              // If categories are not loaded yet, show a placeholder
              return Container(
                height: 80,
                color: Colors.white,
                child: const Center(child: Text('Loading categories...')),
              );
            },
          ),
          // Products Section - Separate BlocBuilder
          Expanded(
            child: BlocBuilder<ProductCubit, ProductState>(
              buildWhen: (previous, current) {
                // Only rebuild for product-related states
                return current is ProductLoaded || current is ProductLoading || current is ProductError;
              },
              builder: (context, state) {
                if (state is ProductLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ProductLoaded) {
                  if (state.products.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No products found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Try selecting a different category',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: state.products.length,
                    itemBuilder: (context, index) {
                      return ProductCard(product: state.products[index]);
                    },
                  );
                } else if (state is ProductError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${state.message}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            if (selectedCategory != null) {
                              context.read<ProductCubit>().fetchProductsByCategory(
                                categoryId: selectedCategory!.id,
                              );
                            } else {
                              context.read<ProductCubit>().fetchProducts();
                            }
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Welcome to our store!',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Select a category to browse products',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 