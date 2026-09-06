import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/lot_model.dart';
import '../models/price_model.dart';
import '../models/recycler_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Dynamic base URL: Physical Android device / LAN / ADB reverse
  String get baseUrl {
    if (kIsWeb) return 'http://localhost:5000/api';
    if (defaultTargetPlatform == TargetPlatform.android) {
      // ADB reverse maps 127.0.0.1:5000 directly to host PC
      return 'http://127.0.0.1:5000/api';
    }
    return 'http://localhost:5000/api';
  }

  // AI Classification
  Future<Map<String, dynamic>> classifyImage(String imageHint, {String? explicitCategory}) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/ai/classify'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'imageHint': imageHint,
          'explicitCategory': explicitCategory,
        }),
      );
      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
    } catch (e) {
      debugPrint('[ApiService] Classify fallback: $e');
    }

    // Offline fallback heuristic
    return {
      'category': explicitCategory ?? 'PCB',
      'subCategory': 'Green FR-4 Motherboard',
      'confidencePercent': 88,
      'detectedFeatures': ['Rectangular footprint', 'Dense traces'],
      'suggestedHandling': 'Keep dry; avoid snapping board traces.',
      'isHazardous': false,
    };
  }

  // Value Estimation
  Future<Map<String, dynamic>> estimateValue(String category, double weightKg) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/ai/estimate-value'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'category': category,
          'weightKg': weightKg,
          'locationArea': 'Mumbai',
        }),
      );
      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
    } catch (e) {
      debugPrint('[ApiService] Value estimate fallback: $e');
    }

    // Offline rule-based fallback (±15%)
    final rates = {'PCB': 135.0, 'Battery': 85.0, 'Cable': 240.0, 'CRT': 35.0, 'Motor': 195.0};
    final rate = rates[category] ?? 100.0;
    final base = weightKg * rate;
    return {
      'category': category,
      'weightKg': weightKg,
      'avgBaseRateInrPerKg': rate,
      'estimatedValueMinInr': (base * 0.85).round(),
      'estimatedValueMaxInr': (base * 1.15).round(),
      'disclaimer': 'अनुमानित मूल्य / Estimated range, not final price.',
    };
  }

  // Recycler Matching
  Future<List<RecyclerRank>> getMatchedRecyclers(String category, {double lat = 19.076, double lng = 72.8777}) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/recyclers/match'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'category': category,
          'lat': lat,
          'lng': lng,
        }),
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final rankings = data['rankings'] as List;
        return rankings.map((r) => RecyclerRank.fromJson(r)).toList();
      }
    } catch (e) {
      debugPrint('[ApiService] Matching fallback: $e');
    }

    return [
      RecyclerRank(
        recyclerId: 'rec-001',
        name: 'EcoMetals Green Yard Pvt Ltd',
        address: 'Plot 42, Dharavi Link Road, Mumbai',
        phone: '+91 9876543211',
        authorizationStatus: 'authorized',
        authorizationDetails: 'MPCB/EW-REG/2024/0981',
        offeredRateInrPerKg: 140.0,
        pickupAvailable: true,
        distanceKm: 3.2,
        totalScore: 94,
        scoreBreakdown: ScoreBreakdown(
          distanceScore: 94,
          priceScore: 92,
          pickupScore: 100,
          authorizationScore: 100,
        ),
      ),
      RecyclerRank(
        recyclerId: 'rec-003',
        name: 'Navi Mumbai Precious Metal Extraction',
        address: 'TTC Industrial Area, Rabale, Navi Mumbai',
        phone: '+91 9892110099',
        authorizationStatus: 'authorized',
        authorizationDetails: 'CPCB/EW-REF/MUM-8874',
        offeredRateInrPerKg: 155.0,
        pickupAvailable: false,
        distanceKm: 18.5,
        totalScore: 86,
        scoreBreakdown: ScoreBreakdown(
          distanceScore: 63,
          priceScore: 100,
          pickupScore: 40,
          authorizationScore: 100,
        ),
      ),
    ];
  }

  // Price Board
  Future<List<PriceBoardCard>> getPriceBoard() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/prices/board'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final board = data['board'] as List;
        return board.map((c) => PriceBoardCard.fromJson(c)).toList();
      }
    } catch (e) {
      debugPrint('[ApiService] Price board fallback: $e');
    }

    return [
      PriceBoardCard(
        category: 'PCB',
        currentRateInrPerKg: 135.0,
        minRateInrPerKg: 120.0,
        maxRateInrPerKg: 150.0,
        trendPercent: '+4.2%',
        sampleSize: 24,
        lastUpdated: DateTime.now().toIso8601String(),
        dataMaturity: 'synthetic',
      ),
      PriceBoardCard(
        category: 'Cable',
        currentRateInrPerKg: 240.0,
        minRateInrPerKg: 225.0,
        maxRateInrPerKg: 260.0,
        trendPercent: '+6.1%',
        sampleSize: 30,
        lastUpdated: DateTime.now().toIso8601String(),
        dataMaturity: 'synthetic',
      ),
      PriceBoardCard(
        category: 'Battery',
        currentRateInrPerKg: 85.0,
        minRateInrPerKg: 75.0,
        maxRateInrPerKg: 95.0,
        trendPercent: '+2.0%',
        sampleSize: 18,
        lastUpdated: DateTime.now().toIso8601String(),
        dataMaturity: 'synthetic',
      ),
      PriceBoardCard(
        category: 'Motor',
        currentRateInrPerKg: 195.0,
        minRateInrPerKg: 180.0,
        maxRateInrPerKg: 215.0,
        trendPercent: '+3.5%',
        sampleSize: 15,
        lastUpdated: DateTime.now().toIso8601String(),
        dataMaturity: 'synthetic',
      ),
      PriceBoardCard(
        category: 'CRT',
        currentRateInrPerKg: 35.0,
        minRateInrPerKg: 30.0,
        maxRateInrPerKg: 42.0,
        trendPercent: '0%',
        sampleSize: 12,
        lastUpdated: DateTime.now().toIso8601String(),
        dataMaturity: 'synthetic',
      ),
    ];
  }

  // Price History
  Future<List<PriceHistoryPoint>> getPriceHistory(String category, {String range = '30d'}) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/prices/history?category=$category&range=$range'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final points = data['points'] as List;
        return points.map((p) => PriceHistoryPoint.fromJson(p)).toList();
      }
    } catch (e) {
      debugPrint('[ApiService] History fallback: $e');
    }

    return [
      PriceHistoryPoint(date: 'Day 1', priceInr: 130.0, quotedPriceInr: 135.0, area: 'Mumbai'),
      PriceHistoryPoint(date: 'Day 8', priceInr: 132.0, quotedPriceInr: 138.0, area: 'Mumbai'),
      PriceHistoryPoint(date: 'Day 15', priceInr: 134.0, quotedPriceInr: 140.0, area: 'Mumbai'),
      PriceHistoryPoint(date: 'Day 22', priceInr: 137.0, quotedPriceInr: 142.0, area: 'Mumbai'),
      PriceHistoryPoint(date: 'Today', priceInr: 140.0, quotedPriceInr: 145.0, area: 'Mumbai'),
    ];
  }

  // Get My Lots
  Future<List<MaterialLot>> getLots() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/lots'));
      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        return data.map((l) => MaterialLot.fromJson(l)).toList();
      }
    } catch (e) {
      debugPrint('[ApiService] Fetch lots error: $e');
    }
    return [];
  }

  // Create Lot
  Future<MaterialLot?> createLot(Map<String, dynamic> lotData) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/lots'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(lotData),
      );
      if (res.statusCode == 201) {
        return MaterialLot.fromJson(json.decode(res.body));
      }
    } catch (e) {
      debugPrint('[ApiService] Create lot network error: $e');
    }
    return null;
  }

  // Match Lot with Recycler
  Future<bool> matchLot(String lotId, String recyclerId) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/transactions/$lotId/match'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'recyclerId': recyclerId}),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Accept Offer
  Future<bool> acceptOffer(String lotId) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/transactions/$lotId/accept-offer'),
        headers: {'Content-Type': 'application/json'},
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Complete Handover
  Future<bool> handoverLot(String lotId, double finalWeightKg, {String? photoUrl}) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/transactions/$lotId/handover'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'finalWeightKg': finalWeightKg,
          'handoverPhotoUrl': photoUrl ?? '/uploads/sample_handover.jpg',
          'handoverArea': 'EcoMetals Main Yard',
        }),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Earnings Summary
  Future<Map<String, dynamic>> getEarningsSummary() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/earnings/summary'));
      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
    } catch (e) {
      debugPrint('[ApiService] Earnings fallback: $e');
    }

    return {
      'todayEarningsInr': 2030,
      'totalEarningsInr': 8575,
      'pendingEarningsInr': 3600,
      'completedCount': 2,
      'pendingCount': 2,
      'totalWeightKg': 89.5,
      'recentPayouts': [],
    };
  }
}
