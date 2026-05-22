import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:toastification/toastification.dart';

class ToastService {
  static ToastificationItem? _loadingToast;

  static void showToast({
    required BuildContext context,
    required String message,
    String? description,
    ToastificationStyle style = ToastificationStyle.fillColored,
    ToastificationType type = ToastificationType.info,
    Alignment alignment = Alignment.topCenter,
    bool showProgressBar = false,
    bool applyBlurEffect = false,
    bool pauseOnHover = true,
    bool dragToClose = true,
    Duration autoCloseDuration = const Duration(seconds: 3),
  }) {
    Color backgroundColor;
    switch (type) {
      case ToastificationType.error:
        backgroundColor = const Color.fromARGB(255, 109, 14, 14); // dark red
        break;
      case ToastificationType.success:
        backgroundColor = Colors.green.shade700;
        break;
      case ToastificationType.warning:
        backgroundColor = Colors.orange.shade800;
        break;
      case ToastificationType.info:
        backgroundColor = Colors.blue.shade700;
        break;
    }

    toastification.show(
      context: context,
      showIcon: false,
      backgroundColor: backgroundColor, // 👈 apply color
      title: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.white, // 👈 better contrast on dark bg
            ),
      ),
      description: description == null
          ? null
          : Text(
              description,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
            ),
      style: style,
      type: type,
      alignment: alignment,
      showProgressBar: showProgressBar,
      applyBlurEffect: applyBlurEffect,
      pauseOnHover: pauseOnHover,
      dragToClose: dragToClose,
      autoCloseDuration: autoCloseDuration,
    );
  }

  static void showLoadingToast(BuildContext context,
      {required String message}) {
    dismissLoadingToastOnly();

    _loadingToast = toastification.show(
      context: context,
      showIcon: false,
      title: Row(
        children: [
          LoadingAnimationWidget.progressiveDots(
              color: const Color.fromARGB(255, 0, 41, 75), size: 20),
          const SizedBox(width: 20),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w500,
                color: const Color.fromARGB(255, 1, 34, 61)),
          ),
        ],
      ),
      style: ToastificationStyle.fillColored,
      type: ToastificationType.info,
      alignment: Alignment.topCenter,
      showProgressBar: false,
      pauseOnHover: true,
      dragToClose: false,
      closeOnClick: false,
      closeButtonShowType: CloseButtonShowType.none,
      autoCloseDuration: null,
    );
  }

  static void dismissLoadingToastOnly() {
    if (_loadingToast != null) {
      toastification.dismiss(_loadingToast!);
      _loadingToast = null;
    }
  }

  static void dismissLoadingToast(
      BuildContext context, String message, ToastificationType type,
      {String? description}) {
    dismissLoadingToastOnly();
    showToast(
        context: context,
        message: message,
        type: type,
        description: description);
  }
}
