class PharmacyProductModel {
  final int id;
  final String name;
  final String category;
  final double price;
  final double? discountedPrice;
  final String? description;
  final String? imageUrl;
  final String? manufacturer;
  final bool inStock;
  final int? stockCount;
  final bool requiresPrescription;

  const PharmacyProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.discountedPrice,
    this.description,
    this.imageUrl,
    this.manufacturer,
    this.inStock = true,
    this.stockCount,
    this.requiresPrescription = false,
  });

  factory PharmacyProductModel.fromJson(Map<String, dynamic> json) {
    return PharmacyProductModel(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      discountedPrice: json['discounted_price'] != null
          ? (json['discounted_price'] as num).toDouble()
          : null,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      manufacturer: json['manufacturer'] as String?,
      inStock: json['in_stock'] as bool? ?? true,
      stockCount: json['stock_count'] as int?,
      requiresPrescription: json['requires_prescription'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'price': price,
        if (discountedPrice != null) 'discounted_price': discountedPrice,
        if (description != null) 'description': description,
        if (imageUrl != null) 'image_url': imageUrl,
        if (manufacturer != null) 'manufacturer': manufacturer,
        'in_stock': inStock,
        if (stockCount != null) 'stock_count': stockCount,
        'requires_prescription': requiresPrescription,
      };

  double get effectivePrice => discountedPrice ?? price;
  String get formattedPrice => '₹${effectivePrice.toStringAsFixed(0)}';
  bool get hasDiscount => discountedPrice != null && discountedPrice! < price;
  int get discountPercent => hasDiscount
      ? ((price - discountedPrice!) / price * 100).round()
      : 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PharmacyProductModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class CartItem {
  final PharmacyProductModel product;
  final int quantity;

  const CartItem({required this.product, this.quantity = 1});

  double get total => product.effectivePrice * quantity;
  String get formattedTotal => '₹${total.toStringAsFixed(0)}';
}

// Sample products
List<PharmacyProductModel> get sampleProducts => [
      const PharmacyProductModel(
        id: 1,
        name: 'Paracetamol 500mg',
        category: 'Medicines',
        price: 30,
        discountedPrice: 25,
        description: 'For fever and mild to moderate pain relief',
        manufacturer: 'Sun Pharma',
        inStock: true,
      ),
      const PharmacyProductModel(
        id: 2,
        name: 'Vitamin C 1000mg',
        category: 'Vitamins',
        price: 299,
        discountedPrice: 249,
        description: 'Immunity booster with natural citrus flavor',
        manufacturer: 'HealthVit',
        inStock: true,
      ),
      const PharmacyProductModel(
        id: 3,
        name: 'Blood Pressure Monitor',
        category: 'Devices',
        price: 1500,
        discountedPrice: 1299,
        description: 'Digital automatic blood pressure monitor',
        manufacturer: 'Omron',
        inStock: true,
      ),
      const PharmacyProductModel(
        id: 4,
        name: 'Hand Sanitizer 500ml',
        category: 'Personal Care',
        price: 150,
        description: '70% alcohol-based hand sanitizer',
        manufacturer: 'Dettol',
        inStock: true,
      ),
      const PharmacyProductModel(
        id: 5,
        name: 'N95 Face Mask (Pack of 5)',
        category: 'Personal Care',
        price: 250,
        discountedPrice: 199,
        description: 'High filtration efficiency face masks',
        inStock: true,
      ),
      const PharmacyProductModel(
        id: 6,
        name: 'Amoxicillin 250mg',
        category: 'Medicines',
        price: 85,
        description: 'Antibiotic for bacterial infections',
        manufacturer: 'Cipla',
        inStock: true,
        requiresPrescription: true,
      ),
    ];

const List<String> productCategories = [
  'All',
  'Medicines',
  'Vitamins',
  'Personal Care',
  'Devices',
  'Skincare',
  'Baby Care',
];
