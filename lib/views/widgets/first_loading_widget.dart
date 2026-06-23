import 'package:flutter/material.dart';

import '../../constants/app_localizations.dart';
import '../../constants/color_util.dart';

class FirstLoadingWidget extends StatelessWidget {
  const FirstLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
     return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Theme.of(context).primaryColor),
          const SizedBox(height: 16),
          Text(context.tr('loading_rates')),
        ],
      ),
    );
  }
}
