import 'package:flutter/material.dart';

class CurrencyView extends StatefulWidget {
  const CurrencyView({super.key});

  @override
  State<CurrencyView> createState() => _CurrencyViewState();
}

class _CurrencyViewState extends State<CurrencyView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: const Center(
          child: Text("Currency View"),
        ),
      ),
    );
  }
}
