import 'package:flutter/material.dart';
import 'package:weather_app/l10n/app_localizations.dart';

class ErrorContainer extends StatelessWidget {
  String errorMessage;
  VoidCallback? onRetry;

  ErrorContainer({super.key, required this.errorMessage, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMessage,
              style: TextStyle(color: Colors.orange.shade800),
            ),
          ),
          TextButton(onPressed: onRetry, child: Text(AppLocalizations.of(context).tryAgain)),
        ],
      ),
    );
  }
}
