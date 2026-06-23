import 'package:flutter/material.dart';

import '../../constants/app_localizations.dart';
import '../../viewmodels/currency/currency_bloc.dart';

class FirstLoadFailureWidget extends StatelessWidget {
  final CurrencyFirstLoadFailure currencyState;
  final Function() onRetry;
  const FirstLoadFailureWidget({super.key, required this.currencyState, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off,
              size: 64,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            Text(
              currencyState.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "${context.tr('retry_in')} ${currencyState.retryCountdown} ${context.tr('retry_seconds')}",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                onRetry();
              },
              icon: const Icon(Icons.refresh),
              label: Text(context.tr('retry_now')),
            ),
          ],
        ),
      ),
    );
  }
}
