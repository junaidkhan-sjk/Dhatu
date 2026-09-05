class ScoreBreakdown {
  final int distanceScore;
  final int priceScore;
  final int pickupScore;
  final int authorizationScore;

  ScoreBreakdown({
    required this.distanceScore,
    required this.priceScore,
    required this.pickupScore,
    required this.authorizationScore,
  });

  factory ScoreBreakdown.fromJson(Map<String, dynamic> json) {
    return ScoreBreakdown(
      distanceScore: (json['distanceScore'] as num?)?.toInt() ?? 0,
      priceScore: (json['priceScore'] as num?)?.toInt() ?? 0,
      pickupScore: (json['pickupScore'] as num?)?.toInt() ?? 0,
      authorizationScore: (json['authorizationScore'] as num?)?.toInt() ?? 0,
    );
  }
}

class RecyclerRank {
  final String recyclerId;
  final String name;
  final String address;
  final String phone;
  final String? email;
  final String authorizationStatus;
  final String authorizationDetails;
  final double offeredRateInrPerKg;
  final bool pickupAvailable;
  final double distanceKm;
  final int totalScore;
  final ScoreBreakdown scoreBreakdown;

  RecyclerRank({
    required this.recyclerId,
    required this.name,
    required this.address,
    required this.phone,
    this.email,
    required this.authorizationStatus,
    required this.authorizationDetails,
    required this.offeredRateInrPerKg,
    required this.pickupAvailable,
    required this.distanceKm,
    required this.totalScore,
    required this.scoreBreakdown,
  });

  factory RecyclerRank.fromJson(Map<String, dynamic> json) {
    return RecyclerRank(
      recyclerId: json['recyclerId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString(),
      authorizationStatus: json['authorizationStatus']?.toString() ?? 'authorized',
      authorizationDetails: json['authorizationDetails']?.toString() ?? '',
      offeredRateInrPerKg: (json['offeredRateInrPerKg'] as num?)?.toDouble() ?? 0.0,
      pickupAvailable: json['pickupAvailable'] == true,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
      totalScore: (json['totalScore'] as num?)?.toInt() ?? 0,
      scoreBreakdown: ScoreBreakdown.fromJson(json['scoreBreakdown'] ?? {}),
    );
  }
}
