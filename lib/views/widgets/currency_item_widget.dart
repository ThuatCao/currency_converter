import 'package:flutter/material.dart';

import '../../constants/app_localizations.dart';
import '../../constants/color_util.dart';
import '../../data/database.dart';

class CurrencyItemWidget extends StatelessWidget {
  final Currency currency;

  const CurrencyItemWidget({super.key, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0.1,
      shadowColor: Colors.grey.withValues(alpha: 0.4),
      child: ListTile(
        leading: CircleAvatar(
          //backgroundColor: Theme.of(context).primaryColorLight,
          child: Text(
            currency.code.substring(
              0,
              currency.code.length > 2 ? 2 : currency.code.length,
            ),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              // color: neutralColor,
            ),
          ),
        ),
        title: Text(
          currency.code,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '1 USD',
              style: TextStyle(color: tertiaryColor, fontSize: 10),
            ),
            Text(
              '= ${currency.rate.toStringAsFixed(5)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
