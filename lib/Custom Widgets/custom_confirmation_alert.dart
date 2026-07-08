import 'package:clinical_ai_app/Custom%20Widgets/custom_button.dart';
import 'package:flutter/material.dart';

Future<dynamic> showCustomConfirmationAlert(String detail, BuildContext context, VoidCallback onPressed) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withAlpha(100),
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(detail, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: ElevatedButton(onPressed: () => Navigator.pop(context), child: Text("Cancel"),)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onPressed,
                        child: Text("OK"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
