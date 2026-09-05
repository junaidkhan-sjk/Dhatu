class PriceBoardCard {
  final String category;
  final double currentRateInrPerKg;
  final double minRateInrPerKg;
  final double maxRateInrPerKg;
  final String trendPercent;
  final int sampleSize;
  final String lastUpdated;
  final String dataMaturity;

  PriceBoardCard({
    required this.category,
    required this.currentRateInrPerKg,
    required this.minRateInrPerKg,
    required this.maxRateInrPerKg,
    required this.trendPercent,
    required this.sampleSize,
    required this.lastUpdated,
    required this.dataMaturity,
  });

  factory PriceBoardCard.fromJson(Map<String, dynamic> json) {
    return PriceBoardCard(
      category: json['category']?.toString() ?? 'PCB',
      currentRateInrPerKg: (json['currentRateInrPerKg'] as num?)?.toDouble() ?? 0.0,
      minRateInrPerKg: (json['minRateInrPerKg'] as num?)?.toDouble() ?? 0.0,
      maxRateInrPerKg: (json['maxRateInrPerKg'] as num?)?.toDouble() ?? 0.0,
      trendPercent: json['trendPercent']?.toString() ?? '0%',
      sampleSize: (json['sampleSize'] as num?)?.toInt() ?? 0,
      lastUpdated: json['lastUpdated']?.toString() ?? '',
      dataMaturity: json['dataMaturity']?.toString() ?? 'synthetic',
    );
  }
}

class PriceHistoryPoint {
  final String date;
  final double priceInr;
  final double quotedPriceInr;
  final String area;

  PriceHistoryPoint({
    required this.date,
    required this.priceInr,
    required this.quotedPriceInr,
    required this.area,
  });

  factory PriceHistoryPoint.fromJson(Map<String, dynamic> json) {
    return PriceHistoryPoint(
      date: json['date']?.toString() ?? '',
      priceInr: (json['priceInr'] as num?)?.toDouble() ?? 0.0,
      quotedPriceInr: (json['quotedPriceInr'] as num?)?.toDouble() ?? 0.0,
      area: json['area']?.toString() ?? '',
    );
  }
}
