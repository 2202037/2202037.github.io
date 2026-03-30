class DoctorModel {
  final int id;
  final String name;
  final String specialty;
  final double fee;
  final String? bio;
  final int? experienceYears;
  final String? imageUrl;
  final double? rating;
  final int? reviewCount;
  final double? distance;
  final String? clinicName;
  final String? clinicAddress;
  final String? phone;
  final String? email;
  final bool isAvailable;
  final List<String>? availableDays;

  const DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.fee,
    this.bio,
    this.experienceYears,
    this.imageUrl,
    this.rating,
    this.reviewCount,
    this.distance,
    this.clinicName,
    this.clinicAddress,
    this.phone,
    this.email,
    this.isAvailable = true,
    this.availableDays,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] as int,
      name: json['name'] as String,
      specialty: json['specialty'] as String,
      fee: (json['fee'] as num).toDouble(),
      bio: json['bio'] as String?,
      experienceYears: json['experience_years'] as int?,
      imageUrl: json['image_url'] as String?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      reviewCount: json['review_count'] as int?,
      distance: json['distance'] != null ? (json['distance'] as num).toDouble() : null,
      clinicName: json['clinic_name'] as String?,
      clinicAddress: json['clinic_address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      availableDays: (json['available_days'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'specialty': specialty,
        'fee': fee,
        if (bio != null) 'bio': bio,
        if (experienceYears != null) 'experience_years': experienceYears,
        if (imageUrl != null) 'image_url': imageUrl,
        if (rating != null) 'rating': rating,
        if (reviewCount != null) 'review_count': reviewCount,
        if (distance != null) 'distance': distance,
        if (clinicName != null) 'clinic_name': clinicName,
        if (clinicAddress != null) 'clinic_address': clinicAddress,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        'is_available': isAvailable,
        if (availableDays != null) 'available_days': availableDays,
      };

  String get initials {
    final parts = name.replaceAll('Dr. ', '').trim().split(' ');
    if (parts.isEmpty) return 'Dr';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  String get formattedFee => '₹${fee.toStringAsFixed(0)}';
  String get formattedDistance => distance != null
      ? '${distance!.toStringAsFixed(1)} km'
      : 'Distance N/A';
  String get formattedRating => rating?.toStringAsFixed(1) ?? 'N/A';
  String get formattedExperience => experienceYears != null
      ? '$experienceYears yr${experienceYears! > 1 ? 's' : ''}'
      : '';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DoctorModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// Sample data for development
List<DoctorModel> get sampleDoctors => [
      const DoctorModel(
        id: 1,
        name: 'Dr. Priya Sharma',
        specialty: 'Cardiologist',
        fee: 800,
        bio: 'Dr. Priya Sharma is a renowned cardiologist with over 15 years of experience in interventional cardiology. She specializes in complex cardiac procedures and preventive cardiology.',
        experienceYears: 15,
        rating: 4.8,
        reviewCount: 234,
        distance: 1.2,
        clinicName: 'Heart Care Clinic',
        clinicAddress: 'MG Road, Bangalore',
        isAvailable: true,
      ),
      const DoctorModel(
        id: 2,
        name: 'Dr. Rajesh Kumar',
        specialty: 'General Physician',
        fee: 500,
        bio: 'Dr. Rajesh Kumar is a highly experienced general physician with expertise in internal medicine and chronic disease management.',
        experienceYears: 10,
        rating: 4.6,
        reviewCount: 189,
        distance: 0.8,
        clinicName: 'HealthFirst Clinic',
        clinicAddress: 'Koramangala, Bangalore',
        isAvailable: true,
      ),
      const DoctorModel(
        id: 3,
        name: 'Dr. Anita Patel',
        specialty: 'Dermatologist',
        fee: 700,
        bio: 'Specialist in skin disorders, cosmetic dermatology, and hair loss treatment.',
        experienceYears: 8,
        rating: 4.7,
        reviewCount: 156,
        distance: 2.1,
        clinicName: 'SkinCare Center',
        clinicAddress: 'Indiranagar, Bangalore',
        isAvailable: false,
      ),
      const DoctorModel(
        id: 4,
        name: 'Dr. Suresh Reddy',
        specialty: 'Orthopedic',
        fee: 900,
        bio: 'Expert in joint replacement, sports injuries, and spine disorders.',
        experienceYears: 12,
        rating: 4.9,
        reviewCount: 302,
        distance: 3.5,
        clinicName: 'Bone & Joint Hospital',
        clinicAddress: 'HSR Layout, Bangalore',
        isAvailable: true,
      ),
      const DoctorModel(
        id: 5,
        name: 'Dr. Meera Nair',
        specialty: 'Pediatrician',
        fee: 600,
        bio: 'Dedicated pediatrician focusing on child development, vaccinations, and adolescent health.',
        experienceYears: 9,
        rating: 4.8,
        reviewCount: 278,
        distance: 1.8,
        clinicName: 'Little Stars Clinic',
        clinicAddress: 'Jayanagar, Bangalore',
        isAvailable: true,
      ),
    ];
