import 'package:flutter/material.dart';

import '../models/rider-model.dart';
import '../services/rider_service.dart';

class RiderProvider extends ChangeNotifier {
  final RiderService _service = RiderService();

  RiderModel? _rider;
  bool _isLoading = false;
  String? _errorMessage;

  RiderModel? get rider => _rider;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _rider != null;

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String? msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      _rider = await _service.loginRider(email, password);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String cnic,
    required String licenseNumber,
    required String vehicleModel,
    required String vehicleNumber,
    String? sellerId,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      await _service.registerRider(
        name: name,
        email: email,
        password: password,
        phone: phone,
        address: address,
        cnic: cnic,
        licenseNumber: licenseNumber,
        vehicleModel: vehicleModel,
        vehicleNumber: vehicleNumber,
        sellerId: sellerId,
      );
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _service.logoutRider();
    _rider = null;
    notifyListeners();
  }

  Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    _setLoading(true);
    _setError(null);
    try {
      await _service.changePassword(currentPassword, newPassword);
      return true;
    } catch (e) {
      _setError('Current password is incorrect.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _setError(null);
    try {
      await _service.forgotPassword(email);
      return true;
    } catch (e) {
      _setError('Email not found. Please check and try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshProfile() async {
    if (_rider == null) return;
    final updated = await _service.getRiderProfile(_rider!.uid);
    if (updated != null) {
      _rider = updated;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    if (_rider == null) return false;
    _setLoading(true);
    _setError(null);
    try {
      await _service.updateRiderProfile(_rider!.uid, data);
      await refreshProfile();
      return true;
    } catch (e) {
      _setError('Failed to update profile.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}