import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Connectivity service for monitoring online/offline status
/// 
/// Provides real-time connectivity status and stream for app-wide monitoring
class ConnectivityService {
  static final ConnectivityService instance = ConnectivityService._init();
  
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();
  
  bool _isOnline = true;
  StreamSubscription? _connectivitySubscription;

  ConnectivityService._init();

  /// Get current online status
  bool get isOnline => _isOnline;

  /// Stream of connectivity changes
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    print('📡 Initializing connectivity service...');

    // Check initial connectivity
    await _checkConnectivity();

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) {
      _handleConnectivityChange(results);
    });

    print('✅ Connectivity service initialized');
  }

  /// Check current connectivity status
  Future<void> _checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _handleConnectivityChange(results);
    } catch (e) {
      print('❌ Error checking connectivity: $e');
      _updateStatus(false);
    }
  }

  /// Handle connectivity change
  void _handleConnectivityChange(List<ConnectivityResult> results) {
    // Check if any result indicates connectivity
    final hasConnection = results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet);

    _updateStatus(hasConnection);
  }

  /// Update connectivity status
  void _updateStatus(bool isOnline) {
    if (_isOnline != isOnline) {
      _isOnline = isOnline;
      _connectivityController.add(isOnline);
      
      if (isOnline) {
        print('✅ Connection restored');
      } else {
        print('📴 Connection lost - entering offline mode');
      }
    }
  }

  /// Manually check connectivity
  Future<bool> checkConnection() async {
    await _checkConnectivity();
    return _isOnline;
  }

  /// Dispose connectivity service
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController.close();
    print('🔒 Connectivity service disposed');
  }
}
