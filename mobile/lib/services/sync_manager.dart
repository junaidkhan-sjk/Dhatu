import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'local_database.dart';
import 'dart:async';

class SyncManager extends ChangeNotifier {
  static final SyncManager _instance = SyncManager._internal();
  factory SyncManager() => _instance;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  
  bool _isOnline = false;
  bool _isSyncing = false;
  
  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;

  SyncManager._internal() {
    _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } catch (e) {
      debugPrint('Couldn\'t check connectivity status: \$e');
      return;
    }
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    bool online = result != ConnectivityResult.none;
    if (online != _isOnline) {
      _isOnline = online;
      notifyListeners();
      
      if (_isOnline) {
        syncPendingData();
      }
    }
  }

  Future<void> syncPendingData() async {
    if (!_isOnline || _isSyncing) return;
    
    _isSyncing = true;
    notifyListeners();

    try {
      final db = LocalDatabase.instance;
      final pendingTransactions = await db.getPendingTransactions();
      
      for (var tx in pendingTransactions) {
        // Here we would normally make the HTTP call to the backend
        // e.g. await ApiService.submitTransaction(tx);
        
        // Simulating network delay
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Update local status
        await db.updateTransactionSyncStatus(tx['id'], 'Synced');
      }
    } catch (e) {
      debugPrint('Sync failed: \$e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
  
  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
