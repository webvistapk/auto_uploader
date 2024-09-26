import 'package:flutter/material.dart';
import 'package:flutter_sliding_toast/flutter_sliding_toast.dart';

class ToastNotifier {
  // Function to show success toast
  static void showSuccessToast(BuildContext context, String message) {
    InteractiveToast.slideSuccess(
      context,
      title: Text(
        message,
        style: const TextStyle(color: Colors.green),
      ),
      toastSetting: const SlidingToastSetting(
        toastStartPosition: ToastPosition.right,
        toastAlignment: Alignment.topRight,
        displayDuration: Duration(seconds: 2),
      ),
    );
  }

  // Function to show error toast
  static void showErrorToast(BuildContext context, String message) {
    InteractiveToast.slideError(
      context,
      title: Text(
        message,
        style: const TextStyle(color: Colors.red),
      ),
      toastSetting: const SlidingToastSetting(
        toastStartPosition: ToastPosition.left,
        toastAlignment: Alignment.bottomLeft,
        displayDuration: Duration(seconds: 2),
      ),
    );
  }
}
