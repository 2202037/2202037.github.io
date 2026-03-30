class ClinicModel {
  final int id;
  final String name;
  final String address;
  final String? phone;
  final String? email;
  final String? imageUrl;
  final double? rating;
  final int? reviewCount;
  final double? distance;
  final double? latitude;
  final double? longitude;
  final String? openingHours;
  final bool isOpen;
  final List<String>? specialties;

  const ClinicModel({
    required this.id,
    required this.name,
    required this.address,
    this.phone,
    this.email,
    this.imageUrl,
    this.rating,
    this.reviewCount,
    this.distance,
    this.latitude,
    this.longitude,
    this.openingHours,
    this.isOpen = true,
    this.specialties,
  });

  factory ClinicModel.fromJson(Map<String, dynamic> json) {
    return ClinicModel(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      imageUrl: json['image_url'] as String?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      reviewCount: json['review_count'] as int?,
      distance: json['distance'] != null ? (json['distance'] as num).toDouble() : null,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      openingHours: json['opening_hours'] as String?,
      isOpen: json['is_open'] as bool? ?? true,
      specialties: (json['specialties'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        if (imageUrl != null) 'image_url': imageUrl,
        if (rating != null) 'rating': rating,
        if (reviewCount != null) 'review_count': reviewCount,
        if (distance != null) 'distance': distance,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (openingHours != null) 'opening_hours': openingHours,
        'is_open': isOpen,
        if (specialties != null) 'specialties': specialties,
      };

  String get formattedDistance =>
      distance != null ? '${distance!.toStringAsFixed(1)} km' : '';
  String get formattedRating => rating?.toStringAsFixed(1) ?? 'N/A';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ClinicModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
