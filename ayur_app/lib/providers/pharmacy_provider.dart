import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../models/pharmacy_product_model.dart';
import '../core/constants/api_constants.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class PharmacyState {
  final List<PharmacyProductModel> products;
  final List<PharmacyProductModel> filteredProducts;
  final List<CartItem> cartItems;
  final bool isLoading;
  final String? error;
  final String selectedCategory;
  final String searchQuery;

  const PharmacyState({
    this.products = const [],
    this.filteredProducts = const [],
    this.cartItems = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategory = 'All',
    this.searchQuery = '',
  });

  int get cartCount => cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get cartTotal =>
      cartItems.fold(0.0, (sum, item) => sum + item.total);
  String get formattedCartTotal => '₹${cartTotal.toStringAsFixed(0)}';

  PharmacyState copyWith({
    List<PharmacyProductModel>? products,
    List<PharmacyProductModel>? filteredProducts,
    List<CartItem>? cartItems,
    bool? isLoading,
    String? error,
    String? selectedCategory,
    String? searchQuery,
    bool clearError = false,
  }) {
    return PharmacyState(
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      cartItems: cartItems ?? this.cartItems,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class PharmacyNotifier extends StateNotifier<PharmacyState> {
  final ApiService _apiService;

  PharmacyNotifier(this._apiService) : super(const PharmacyState()) {
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _apiService.get(ApiConstants.pharmacyProducts);
      final data = response.data as Map<String, dynamic>;
      final list = (data['products'] as List<dynamic>? ??
              data['data'] as List<dynamic>? ??
              [])
          .map((e) =>
              PharmacyProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(
        products: list,
        filteredProducts: list,
        isLoading: false,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        products: sampleProducts,
        filteredProducts: sampleProducts,
        isLoading: false,
        error: mapDioError(e).message,
      );
    } catch (_) {
      state = state.copyWith(
        products: sampleProducts,
        filteredProducts: sampleProducts,
        isLoading: false,
      );
    }
  }

  void filterByCategory(String category) {
    state = state.copyWith(selectedCategory: category);
    _applyFilters();
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = state.products;
    if (state.selectedCategory != 'All') {
      filtered =
          filtered.where((p) => p.category == state.selectedCategory).toList();
    }
    if (state.searchQuery.isNotEmpty) {
      final q = state.searchQuery.toLowerCase();
      filtered = filtered
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.category.toLowerCase().contains(q))
          .toList();
    }
    state = state.copyWith(filteredProducts: filtered);
  }

  void addToCart(PharmacyProductModel product) {
    final cartItems = List<CartItem>.from(state.cartItems);
    final existingIndex =
        cartItems.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      cartItems[existingIndex].quantity++;
    } else {
      cartItems.add(CartItem(product: product));
    }
    state = state.copyWith(cartItems: cartItems);
  }

  void removeFromCart(int productId) {
    final cartItems = state.cartItems
        .where((item) => item.product.id != productId)
        .toList();
    state = state.copyWith(cartItems: cartItems);
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }
    final cartItems = state.cartItems.map((item) {
      if (item.product.id == productId) {
        item.quantity = quantity;
      }
      return item;
    }).toList();
    state = state.copyWith(cartItems: cartItems);
  }

  void clearCart() {
    state = state.copyWith(cartItems: []);
  }
}

final pharmacyProvider =
    StateNotifierProvider<PharmacyNotifier, PharmacyState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return PharmacyNotifier(apiService);
});
