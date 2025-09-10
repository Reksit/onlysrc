import 'package:flutter/material.dart';
import '../main.dart';

class ToastProvider with ChangeNotifier {
  final List<ToastModel> _toasts = [];

  List<ToastModel> get toasts => _toasts;

  void showToast(String message, ToastType type) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final toast = ToastModel(id: id, message: message, type: type);
    
    _toasts.add(toast);
    notifyListeners();

    // Auto remove after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      removeToast(id);
    });
  }

  void removeToast(String id) {
    _toasts.removeWhere((toast) => toast.id == id);
    notifyListeners();
  }

  void showSuccess(String message) => showToast(message, ToastType.success);
  void showError(String message) => showToast(message, ToastType.error);
  void showWarning(String message) => showToast(message, ToastType.warning);
  void showInfo(String message) => showToast(message, ToastType.info);
}