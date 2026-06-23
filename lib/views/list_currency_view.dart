import 'package:currency_converter/views/widgets/currency_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../constants/app_localizations.dart';
import '../constants/color_util.dart';
import '../di.dart';
import '../viewmodels/currency_bloc.dart';

class ListCurrencyScreen extends StatelessWidget {
  const ListCurrencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CurrencyBloc>(
      create: (context) =>
          locator<CurrencyBloc>()..add(InitializedAppCurrencyEvent()),
      child: ListCurrencyView(),
    );
    return ListCurrencyView();
  }
}

class ListCurrencyView extends StatefulWidget {
  const ListCurrencyView({super.key});

  @override
  State<ListCurrencyView> createState() => _ListCurrencyViewState();
}

class _ListCurrencyViewState extends State<ListCurrencyView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('currency_list'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: BlocConsumer<CurrencyBloc, CurrencyState>(
        listener: (context, state) {},
        builder: (context, currencyState) {
          if (currencyState is CurrencyFirstLoadProgress) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: primaryColor),
                  const SizedBox(height: 16),
                  Text(context.tr('loading_rates')),
                ],
              ),
            );
          }

          if (currencyState is CurrencyFirstLoadFailure) {
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
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<CurrencyBloc>().add(
                          InitializedAppCurrencyEvent(),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text(context.tr('retry_now')),
                    ),
                  ],
                ),
              ),
            );
          }

          if (currencyState is CurrencyLoadSuccess) {
            final list = currencyState.currencies;

            return Scaffold(
              body: RefreshIndicator(
                onRefresh: () async {
                  final bloc = context.read<CurrencyBloc>();
                  bloc.add(InitializedAppCurrencyEvent());

                  await bloc.stream.firstWhere(
                    (s) =>
                        s is CurrencyLoadSuccess ||
                        s is CurrencyFirstLoadFailure,
                  );
                },
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Last Updated Time
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              currencyState.isFromCache
                                  ? currencyState.lastUpdatedText
                                  : '${context.tr('last_update')}: ${currencyState.lastUpdatedText}',
                              style: TextStyle(fontSize: 14),
                            ),
                            Expanded(child: SizedBox()),
                            Builder(
                              builder: (context) {
                                return RotationTransition(
                                  turns: _animationController,
                                  // Gắn hiệu ứng xoay
                                  child: IconButton(
                                    icon: const Icon(Icons.refresh),
                                    onPressed: () {
                                      _animationController.forward(from: 0.0);
                                      context.read<CurrencyBloc>().add(
                                        InitializedAppCurrencyEvent(),
                                      );
                                    },
                                    tooltip: context.tr('reload'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      // Currency List
                      if (list.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(context.tr('no_data')),
                        )
                      else
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemExtent: 64,
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            final currency = list[index];
                            return CurrencyItemWidget(currency: currency);
                          },
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          }

          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: primaryColor)),
          );
        },
      ),
    );
  }
}
