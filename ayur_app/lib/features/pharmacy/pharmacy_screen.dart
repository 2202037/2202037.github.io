import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../models/pharmacy_product_model.dart';
import '../../providers/pharmacy_provider.dart';

class PharmacyScreen extends ConsumerWidget {
  const PharmacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pharmState = ref.watch(pharmacyProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pharmacy'),
        automaticallyImplyLeading: false,
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () => context.push('/cart'),
                icon: const Icon(Icons.shopping_cart_rounded),
              ),
              if (pharmState.cartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${pharmState.cartCount}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(pharmacyProvider.notifier).fetchProducts(),
        color: AppColors.primary,
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                onChanged: (q) =>
                    ref.read(pharmacyProvider.notifier).search(q),
                decoration: InputDecoration(
                  hintText: 'Search medicines, products...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            // Category chips
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: productCategories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = productCategories[index];
                  final isSelected =
                      pharmState.selectedCategory == cat;
                  return FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => ref
                        .read(pharmacyProvider.notifier)
                        .filterByCategory(cat),
                    selectedColor: AppColors.primary,
                    checkmarkColor: Colors.white,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      color: isSelected
                          ? Colors.white
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Products grid
            Expanded(
              child: pharmState.isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    )
                  : pharmState.filteredProducts.isEmpty
                      ? const Center(child: Text('No products found'))
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.72,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: pharmState.filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product =
                                pharmState.filteredProducts[index];
                            return _ProductCard(
                              product: product,
                              onAddToCart: () => ref
                                  .read(pharmacyProvider.notifier)
                                  .addToCart(product),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final PharmacyProductModel product;
  final VoidCallback onAddToCart;

  const _ProductCard({required this.product, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image placeholder
          Container(
            height: 110,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    _getCategoryIcon(product.category),
                    size: 50,
                    color: AppColors.primary.withOpacity(0.6),
                  ),
                ),
                if (product.hasDiscount)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${product.discountPercent}% OFF',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                if (product.requiresPrescription)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Rx',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  product.category,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.formattedPrice,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        if (product.hasDiscount)
                          Text(
                            '₹${product.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              color: AppColors.textHint,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                    GestureDetector(
                      onTap: onAddToCart,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'medicines':
        return Icons.medication_rounded;
      case 'vitamins':
        return Icons.health_and_safety_rounded;
      case 'devices':
        return Icons.monitor_heart_rounded;
      case 'personal care':
        return Icons.clean_hands_rounded;
      case 'skincare':
        return Icons.face_retouching_natural_rounded;
      case 'baby care':
        return Icons.child_care_rounded;
      default:
        return Icons.local_pharmacy_rounded;
    }
  }
}
