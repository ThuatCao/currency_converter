import 'package:currency_converter/constants/color_util.dart';
import 'package:currency_converter/constants/app_localizations.dart';
import 'package:currency_converter/viewmodels/currency_converter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../di.dart';
import '../viewmodels/currency_bloc.dart';
import 'widgets/convert_widget.dart';

class CurrencyScreen extends StatelessWidget {
  final Function(bool)? onThemeToggle;

  const CurrencyScreen({super.key, this.onThemeToggle});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CurrencyBloc>(
          create: (context) =>
              locator<CurrencyBloc>()..add(InitializedAppCurrencyEvent()),
        ),
        BlocProvider<CurrencyConverterBloc>(
          create: (context) => locator<CurrencyConverterBloc>(),
        ),
      ],
      child: CurrencyView(onThemeToggle: onThemeToggle),
    );
  }
}

class CurrencyView extends StatefulWidget {
  final Function(bool)? onThemeToggle;

  const CurrencyView({super.key, this.onThemeToggle});

  @override
  State<CurrencyView> createState() => _CurrencyViewState();
}

class _CurrencyViewState extends State<CurrencyView> {
  bool _isDarkMode = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isDarkMode = Theme.of(context).brightness == Brightness.dark;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _toggleTheme() {
    _isDarkMode = !_isDarkMode;
    widget.onThemeToggle?.call(_isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

            // Initialize converter bloc with currencies
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final converterBloc = context.read<CurrencyConverterBloc>();
              if (converterBloc.state is CurrencyConverterInitial) {
                converterBloc.add(LoadLastSelectedCurrencyEvent(currencies: list));
              }
            });

            return Scaffold(
              appBar: AppBar(
                title: BlocBuilder<CurrencyConverterBloc, CurrencyConverterState>(
                  builder: (context, converterState) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('exchange_rate'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        if (converterState is CurrencyConverterLoaded &&
                            converterState.selectedCurrencyRate > 0)
                          Text(
                            "1 ${converterState.selectedCurrency} = ${(1/converterState.selectedCurrencyRate).toStringAsFixed(4)} USD",
                            style: const TextStyle(
                              fontSize: 12,
                              color: secondaryColor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                      ],
                    );
                  },
                ),
                backgroundColor: _isDarkMode ? Colors.black12 : Colors.white,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      context.read<CurrencyBloc>().add(
                        InitializedAppCurrencyEvent(),
                      );
                    },
                    tooltip: context.tr('reload'),
                  ),
                  IconButton(
                    icon: Icon(
                      _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      size: 24,
                      color: _isDarkMode ? primaryColor : secondaryColor,
                    ),
                    onPressed: _toggleTheme,
                    tooltip: _isDarkMode ? context.tr('light_mode') : context.tr('dark_mode'),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
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
                child: BlocBuilder<CurrencyConverterBloc, CurrencyConverterState>(
                  builder: (context, converterState) {
                    return Column(
                      children: [
                        // ===== CURRENCY CONVERTER SECTION (FIXED AT TOP) =====
                        ConvertWidget(
                          isDarkMode: _isDarkMode,
                          currencies: list,
                        ),
                        // ===== SCROLLABLE CONTENT =====
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                // Last Updated Time
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    currencyState.lastUpdatedText,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: currencyState.isFromCache
                                          ? Colors.orangeAccent
                                          : Colors.grey,
                                    ),
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
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: list.length,
                                    itemBuilder: (context, index) {
                                      final currency = list[index];
                                      return Card(

                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 6,
                                        ),
                                        elevation: 0.1,
                                        shadowColor: Colors.grey.withValues(alpha: 0.4),
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor:
                                                Theme.of(context).primaryColorLight,
                                            child: Text(
                                              currency.code.substring(
                                                0,
                                                currency.code.length > 2
                                                    ? 2
                                                    : currency.code.length,
                                              ),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                               // color: neutralColor,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            currency.code,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          trailing: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                currency.rate
                                                    .toStringAsFixed(4),
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: primaryColor,
                                                ),
                                              ),
                                              Text(context.tr('base_currency'), style: TextStyle(color: tertiaryColor, fontSize: 10),)
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
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

