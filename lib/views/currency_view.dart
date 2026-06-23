import 'package:currency_converter/constants/color_util.dart';
import 'package:currency_converter/constants/app_localizations.dart';
import 'package:currency_converter/viewmodels/currency_converter_bloc.dart';
import 'package:currency_converter/views/widgets/currency_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../di.dart';
import '../viewmodels/currency_bloc.dart';
import '../viewmodels/theme/theme_bloc.dart';
import 'list_currency_view.dart';
import 'widgets/convert_widget.dart';

class CurrencyScreen extends StatelessWidget {
  const CurrencyScreen({super.key});

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
      child: CurrencyView(),
    );
  }
}

class CurrencyView extends StatefulWidget {
  const CurrencyView({super.key});

  @override
  State<CurrencyView> createState() => _CurrencyViewState();
}

class _CurrencyViewState extends State<CurrencyView>
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
    final currentTheme = Theme.of(context);
    final isDarkMode = currentTheme.brightness == Brightness.dark;
    return AnimatedTheme(
      data: currentTheme,
      duration: Duration(microseconds: 400),
      curve: Curves.easeInOut,
      child: Scaffold(
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
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
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
                  converterBloc.add(
                    LoadLastSelectedCurrencyEvent(currencies: list),
                  );
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
                          const SizedBox(height: 8),
                          if (converterState is CurrencyConverterLoaded &&
                              converterState.selectedCurrencyRate > 0)
                            Text(
                              "1 ${converterState.selectedCurrency} = ${(1 / converterState.selectedCurrencyRate).toStringAsFixed(4)} USD",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                        ],
                      );
                    },
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(
                        isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        size: 24,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: () {
                        context.read<ThemeBloc>().add(
                          ToggleThemeEvent(
                            themeMode: isDarkMode
                                ? ThemeMode.dark
                                : ThemeMode.light,
                          ),
                        );
                      },
                      tooltip: isDarkMode
                          ? context.tr('light_mode')
                          : context.tr('dark_mode'),
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
                            isDarkMode: isDarkMode,
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
                                        SizedBox(
                                          width: 40,
                                          height: 40,
                                          child: Builder(
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
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                '20/${list.length} ${context.tr('currencies')}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              Expanded(child: SizedBox()),
                                              InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const ListCurrencyScreen(),
                                                    ),
                                                  );
                                                },
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      context.tr('view_more'),
                                                    ),
                                                    SizedBox(width: 4),
                                                    const Icon(
                                                      Icons.arrow_forward_ios,
                                                      size: 14,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        ListView.builder(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemExtent: 64,
                                          itemCount: 20,
                                          itemBuilder: (context, index) {
                                            final currency = list[index];
                                            return CurrencyItemWidget(
                                              currency: currency,
                                            );
                                          },
                                        ),
                                      ],
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
              body: Center(
                child: CircularProgressIndicator(color: primaryColor),
              ),
            );
          },
        ),
      ),
    );
  }
}
