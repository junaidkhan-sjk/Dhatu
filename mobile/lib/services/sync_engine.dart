import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lot_model.dart';
import 'api_service.dart';

class SyncEngine extends ChangeNotifier {
  static final SyncEngine _instance = SyncEngine._internal();
  factory SyncEngine() => _instance;
  SyncEngine._internal();

  final List<MaterialLot> _localLots = [];
  bool _isSyncing = false;

  List<MaterialLot> get localLots => List.unmodifiable(_localLots);
  bool get isSyncing => _isSyncing;

  int get offlineCount =>
      _localLots.where((l) => l.syncState == SyncState.savedOffline).length;
  int get syncedCount =>
      _localLots.where((l) => l.syncState == SyncState.synced).length;
  int get attentionCount =>
      _localLots.where((l) => l.syncState == SyncState.attentionRequired).length;

  Future<void> init() async {
    await loadOfflineQueue();
    await fetchServerLots();
    syncPendingQueue();
  }

  Future<void> loadOfflineQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? raw = prefs.getString('dhatu_offline_lots');
      if (raw != null) {
        final List list = json.decode(raw);
        _localLots.clear();
        for (var item in list) {
          _localLots.add(MaterialLot.fromJson(item));
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[SyncEngine] Load queue error: $e');
    }
  }

  Future<void> saveOfflineQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = json.encode(_localLots.map((l) => l.toJson()).toList());
      await prefs.setString('dhatu_offline_lots', encoded);
    } catch (e) {
      debugPrint('[SyncEngine] Save queue error: $e');
    }
  }

  // Create lot locally first (Offline-First Guarantee)
  Future<MaterialLot> addOfflineLot({
    required String category,
    String? subCategory,
    required double weightKg,
    required double estMinInr,
    required double estMaxInr,
    String? imageUrl,
  }) async {
    final clientLotId = 'DH-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final lot = MaterialLot(
      id: clientLotId,
      collectorId: 'user-collector-01',
      collectorName: 'Ramesh (कबाड़ी)',
      material: MaterialItem(
        id: 'mat-$clientLotId',
        category: category,
        subCategory: subCategory ?? 'Standard Grade',
        imageUrl: imageUrl ?? '/uploads/sample_pcb.jpg',
        approxWeightKg: weightKg,
        condition: 'good',
        estimatedValueMinInr: estMinInr,
        estimatedValueMaxInr: estMaxInr,
        dataMaturity: 'field_collected',
      ),
      weightKg: weightKg,
      quotedPriceInr: (estMinInr + estMaxInr) / 2,
      dateTime: DateTime.now().toIso8601String(),
      paymentStatus: 'pending',
      transactionStatus: 'draft',
      syncState: SyncState.savedOffline,
      dataMaturity: 'field_collected',
    );

    _localLots.insert(0, lot);
    await saveOfflineQueue();
    notifyListeners();

    // Trigger asynchronous background sync
    syncPendingQueue();

    return lot;
  }

  // Fetch all lots from server and merge
  Future<void> fetchServerLots() async {
    try {
      final serverLots = await ApiService().getLots();
      for (final sLot in serverLots) {
        final existingIndex = _localLots.indexWhere((l) => l.id == sLot.id);
        if (existingIndex >= 0) {
          _localLots[existingIndex] = sLot;
        } else {
          _localLots.add(sLot);
        }
      }
      await saveOfflineQueue();
      notifyListeners();
    } catch (e) {
      debugPrint('[SyncEngine] Server fetch error: $e');
    }
  }

  // Background sync engine batch processor
  Future<void> syncPendingQueue() async {
    if (_isSyncing) return;
    final pending = _localLots
        .where((l) => l.syncState == SyncState.savedOffline || l.syncState == SyncState.attentionRequired)
        .toList();

    if (pending.isEmpty) return;

    _isSyncing = true;
    notifyListeners();

    final api = ApiService();
    final url = Uri.parse('${api.baseUrl}/sync/batch');

    try {
      final payload = pending
          .map((l) => {
                'clientLotId': l.id,
                'category': l.material.category,
                'subCategory': l.material.subCategory,
                'approxWeightKg': l.weightKg,
                'estimatedValueMinInr': l.material.estimatedValueMinInr,
                'estimatedValueMaxInr': l.material.estimatedValueMaxInr,
                'imageUrl': l.material.imageUrl,
                'dataMaturity': 'field_collected',
              })
          .toList();

      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'items': payload}),
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final results = data['results'] as List;

        for (var resItem in results) {
          final clientLotId = resItem['clientLotId'];
          final status = resItem['status'];
          final targetIndex = _localLots.indexWhere((l) => l.id == clientLotId);

          if (targetIndex >= 0) {
            final old = _localLots[targetIndex];
            _localLots[targetIndex] = MaterialLot(
              id: old.id,
              collectorId: old.collectorId,
              collectorName: old.collectorName,
              material: old.material,
              weightKg: old.weightKg,
              quotedPriceInr: old.quotedPriceInr,
              finalPriceInr: old.finalPriceInr,
              recyclerId: old.recyclerId,
              recyclerName: old.recyclerName,
              collectionArea: old.collectionArea,
              handoverArea: old.handoverArea,
              dateTime: old.dateTime,
              paymentStatus: old.paymentStatus,
              paymentMethod: old.paymentMethod,
              transactionStatus: old.transactionStatus,
              syncState: status == 'synced' ? SyncState.synced : SyncState.attentionRequired,
              dataMaturity: old.dataMaturity,
              traceability: old.traceability,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('[SyncEngine] Sync error: $e');
    } finally {
      _isSyncing = false;
      await saveOfflineQueue();
      notifyListeners();
    }
  }
}
