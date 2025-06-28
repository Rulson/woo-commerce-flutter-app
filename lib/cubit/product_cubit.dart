import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../model/product_model.dart';
import '../model/category_model.dart';
import '../api_service.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ApiService apiService;
  ProductCubit(this.apiService) : super(ProductInitial());

  List<Product> _allProducts = [];
  List<Category> _categories = [];

  Future<void> fetchProducts({int perPage = 10, int page = 1}) async {
    emit(ProductLoading());
    try {
      final response = await apiService.getProducts(perPage: perPage, page: page);
      final List<dynamic> data = response.data;
      _allProducts = data.map((e) => Product.fromJson(e)).toList();
      emit(ProductLoaded(_allProducts));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> fetchCategories({int perPage = 10, int page = 1}) async {
    emit(CategoryLoading());
    try {
      final response = await apiService.getProductCategories(perPage: perPage, page: page);
      final List<dynamic> data = response.data;
      _categories = data.map((e) => Category.fromJson(e)).toList();
      emit(CategoryLoaded(_categories));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> fetchProductsByCategory({
    required int categoryId,
    int perPage = 10,
    int page = 1,
  }) async {
    emit(ProductLoading());
    try {
      final response = await apiService.getProductsByCategory(
        categoryId: categoryId,
        perPage: perPage,
        page: page,
      );
      final List<dynamic> data = response.data;
      final products = data.map((e) => Product.fromJson(e)).toList();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  void filterProductsByCategory(int? categoryId) {
    if (categoryId == null) {
      emit(ProductLoaded(_allProducts));
    } else {
      final filteredProducts = _allProducts.where((product) {
        // This is a simplified filter. In a real app, you'd need to check
        // if the product belongs to the selected category
        return product.name.toLowerCase().contains(
              _categories.firstWhere((cat) => cat.id == categoryId).name.toLowerCase(),
            );
      }).toList();
      emit(ProductLoaded(filteredProducts));
    }
  }

  List<Category> get categories => _categories;
  List<Product> get allProducts => _allProducts;
}