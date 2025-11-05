import 'package:flutter/material.dart';

class CustomPopupDialog {
  static void show(
      BuildContext context, {
        required String title,
        required String message,
        bool dismissable = false,
        IconData? icon,
        Color? iconColor,
        Color? backgroundColor,
        Duration? duration,
        VoidCallback? onClose,
        String? acceptButtonText,
        VoidCallback? onAcceptButtonPressed,
        String? rejectButtonText,
        VoidCallback? onRejectButtonPressed,
      }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showGeneralDialog(
      barrierLabel: title,
      barrierDismissible: dismissable,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: backgroundColor ?? colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null)
                  Icon(icon, color: iconColor ?? colorScheme.primary, size: 60),
                if (icon != null) const SizedBox(height: 15),
                Text(
                  title,
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.secondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                if ((acceptButtonText != null &&
                    onAcceptButtonPressed != null) ||
                    (rejectButtonText != null && onRejectButtonPressed != null))
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (rejectButtonText != null &&
                            onRejectButtonPressed != null)
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              onRejectButtonPressed();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.secondary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            child: Text(
                              rejectButtonText,
                              style: TextStyle(color: colorScheme.onSecondary),
                            ),
                          ),
                        if (acceptButtonText != null &&
                            onAcceptButtonPressed != null)
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              onAcceptButtonPressed();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            child: Text(acceptButtonText),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: child,
        );
      },
    );

    if (duration != null &&
        acceptButtonText == null &&
        rejectButtonText == null) {
      Future.delayed(duration, () {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        onClose?.call();
      });
    }
  }
}