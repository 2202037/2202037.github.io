class BloodBankModel {
  final int id;
  final String bloodGroup;
  final int unitsAvailable;
  final String? hospitalName;
  final String? address;
  final String? phone;
  final double? distance;
  final DateTime? lastUpdated;

  const BloodBankModel({
    required this.id,
    required this.bloodGroup,
    required this.unitsAvailable,
    this.hospitalName,
    this.address,
    this.phone,
    this.distance,
    this.lastUpdated,
  });

  factory BloodBankModel.fromJson(Map<String, dynamic> json) {
    return BloodBankModel(
      id: json['id'] as int,
      bloodGroup: json['blood_group'] as String,
      unitsAvailable: json['units_available'] as int,
      hospitalName: json['hospital_name'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      distance: json['distance'] != null
          ? (json['distance'] as num).toDouble()
          : null,
      lastUpdated: json['last_updated'] != null
          ? DateTime.tryParse(json['last_updated'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'blood_group': bloodGroup,
        'units_available': unitsAvailable,
        if (hospitalName != null) 'hospital_name': hospitalName,
        if (address != null) 'address': address,
        if (phone != null) 'phone': phone,
        if (distance != null) 'distance': distance,
        if (lastUpdated != null) 'last_updated': lastUpdated!.toIso8601String(),
      };

  BloodAvailability get availability {
    if (unitsAvailable == 0) return BloodAvailability.unavailable;
    if (unitsAvailable <= 5) return BloodAvailability.critical;
    if (unitsAvailable <= 15) return BloodAvailability.moderate;
    return BloodAvailability.available;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is BloodBankModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

enum BloodAvailability {
  available,
  moderate,
  critical,
  unavailable;

  String get label {
    switch (this) {
      case BloodAvailability.available:
        return 'Available';
      case BloodAvailability.moderate:
        return 'Moderate';
      case BloodAvailability.critical:
        return 'Critical';
      case BloodAvailability.unavailable:
        return 'Unavailable';
    }
  }
}

// Blood inventory summary
class BloodInventoryItem {
  final String bloodGroup;
  final int units;

  const BloodInventoryItem({required this.bloodGroup, required this.units});

  BloodAvailability get availability {
    if (units == 0) return BloodAvailability.unavailable;
    if (units <= 5) return BloodAvailability.critical;
    if (units <= 15) return BloodAvailability.moderate;
    return BloodAvailability.available;
  }
}

List<BloodInventoryItem> get sampleInventory => const [
      BloodInventoryItem(bloodGroup: 'A+', units: 25),
      BloodInventoryItem(bloodGroup: 'A-', units: 8),
      BloodInventoryItem(bloodGroup: 'B+', units: 32),
      BloodInventoryItem(bloodGroup: 'B-', units: 3),
      BloodInventoryItem(bloodGroup: 'AB+', units: 15),
      BloodInventoryItem(bloodGroup: 'AB-', units: 0),
      BloodInventoryItem(bloodGroup: 'O+', units: 45),
      BloodInventoryItem(bloodGroup: 'O-', units: 12),
    ];
