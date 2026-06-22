import 'package:currency_converter/constants/color_util.dart';
import 'package:currency_converter/viewmodels/currency_converter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/database.dart';
import '../di.dart';
import '../viewmodels/currency_bloc.dart';

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
  final TextEditingController _amountController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isDarkMode = Theme.of(context).brightness == Brightness.dark;
  }

  @override
  void dispose() {
    _amountController.dispose();
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
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: primaryColor),
                  SizedBox(height: 16),
                  Text("Đang đồng bộ tỷ giá lần đầu từ Server..."),
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
                      "Ứng dụng sẽ tự động tải lại sau ${currencyState.retryCountdown} giây...",
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
                      label: const Text("Thử lại ngay"),
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
                        const Text(
                          "Tỷ giá Tiền Tệ",
                          style: TextStyle(
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
                    tooltip: 'Reload',
                  ),
                  IconButton(
                    icon: Icon(
                      _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      size: 24,
                      color: _isDarkMode ? primaryColor : secondaryColor,
                    ),
                    onPressed: _toggleTheme,
                    tooltip: _isDarkMode ? 'Light Mode' : 'Dark Mode',
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
                        // ===== CURRENCY CONVERTER SECTION =====
                        if (converterState is CurrencyConverterLoaded)
                          Container(
                            margin: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Theme.of(context).primaryColor,
                                  Theme.of(context)
                                      .primaryColor
                                      .withValues(alpha: 0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Currency A Input Section
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Từ tiền tệ",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: secondaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: _isDarkMode
                                              ? neutralDarkColor.withValues(
                                                  alpha: 0.1,
                                                )
                                              : neutralColor.withValues(
                                                  alpha: 0.1,
                                                ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: _isDarkMode
                                                ? neutralDarkColor
                                                : neutralColor,
                                            width: 1,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 2,
                                        ),
                                        child: Row(
                                          children: [
                                            // Dropdown for Currency A
                                            Expanded(
                                              flex: 1,
                                              child: DropdownButton<String>(
                                                value: converterState
                                                    .selectedCurrency,
                                                hint: const Text(
                                                  "Chọn",
                                                  style: TextStyle(
                                                    color: secondaryColor,
                                                  ),
                                                ),
                                                isExpanded: true,
                                                underline: const SizedBox(),
                                                dropdownColor:
                                                    Theme.of(context)
                                                        .primaryColor,
                                                style: const TextStyle(
                                                  color: secondaryColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                onChanged: (newValue) {
                                                  if (newValue != null) {
                                                    context
                                                        .read<
                                                            CurrencyConverterBloc>()
                                                        .add(
                                                          SelectSourceCurrencyEvent(
                                                            currencyCode:
                                                                newValue,
                                                          ),
                                                        );
                                                  }
                                                },
                                                items: list
                                                    .map<
                                                        DropdownMenuItem<
                                                            String>>((
                                                  Currency currency,
                                                ) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: currency.code,
                                                    child: Text(
                                                      currency.code,
                                                      style: const TextStyle(
                                                        color: secondaryColor,
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            // Input Field for Amount
                                            Expanded(
                                              flex: 2,
                                              child: TextField(
                                                controller:
                                                    _amountController,
                                                keyboardType: const TextInputType
                                                    .numberWithOptions(
                                                  decimal: true,
                                                ),
                                                style: const TextStyle(
                                                  color: secondaryColor,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                decoration: InputDecoration(
                                                  hintText: "0.00",
                                                  hintStyle: const TextStyle(
                                                    color: secondaryColor,
                                                    fontSize: 14,
                                                  ),
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                    horizontal: 8,
                                                    vertical: 12,
                                                  ),
                                                ),
                                                onChanged: (value) {
                                                  context
                                                      .read<
                                                          CurrencyConverterBloc>()
                                                      .add(
                                                        UpdateConversionAmountEvent(
                                                          amount: value,
                                                        ),
                                                      );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // Arrow/Exchange Icon
                                  Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: _isDarkMode
                                            ? neutralDarkColor.withValues(
                                                alpha: 0.2,
                                              )
                                            : neutralColor.withValues(
                                                alpha: 0.2,
                                              ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.arrow_downward,
                                        color: _isDarkMode
                                            ? neutralDarkColor
                                            : neutralColor,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Currency B Output Section
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Đến tiền tệ (${converterState.destinationCurrency})",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: secondaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: _isDarkMode
                                              ? neutralDarkColor.withValues(
                                                  alpha: 0.1,
                                                )
                                              : neutralColor.withValues(
                                                  alpha: 0.1,
                                                ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: _isDarkMode
                                                ? neutralDarkColor
                                                : neutralColor,
                                            width: 1,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${converterState.convertedAmount.toStringAsFixed(2)}",
                                                  style: const TextStyle(
                                                    fontSize: 28,
                                                    fontWeight: FontWeight.bold,
                                                    color: secondaryColor,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                if (converterState
                                                    .amount.isNotEmpty)
                                                  Text(
                                                    "${converterState.amount} ${converterState.selectedCurrency}",
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: secondaryColor,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            // Destination Currency Dropdown
                                            DropdownButton<String>(
                                              value: converterState
                                                  .destinationCurrency,
                                              underline: const SizedBox(),
                                              dropdownColor:
                                                  Theme.of(context)
                                                      .primaryColor,
                                              style: const TextStyle(
                                                color: secondaryColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              onChanged: (newValue) {
                                                if (newValue != null) {
                                                  context
                                                      .read<
                                                          CurrencyConverterBloc>()
                                                      .add(
                                                        SelectDestinationCurrencyEvent(
                                                          currencyCode:
                                                              newValue,
                                                        ),
                                                      );
                                                }
                                              },
                                              items: list
                                                  .map<
                                                      DropdownMenuItem<
                                                          String>>((
                                                Currency currency,
                                              ) {
                                                return DropdownMenuItem<
                                                    String>(
                                                  value: currency.code,
                                                  child: Text(
                                                    currency.code,
                                                    style: const TextStyle(
                                                      color: secondaryColor,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
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
                        Expanded(
                          child: list.isEmpty
                              ? const Center(
                                  child:
                                      Text("Không có dữ liệu hiển thị."),
                                )
                              : ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemCount: list.length,
                                  itemBuilder: (context, index) {
                                    final currency = list[index];
                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 6,
                                      ),
                                      elevation: 2,
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor:
                                              Colors.blue.shade100,
                                          child: Text(
                                            currency.code.substring(
                                              0,
                                              currency.code.length > 2
                                                  ? 2
                                                  : currency.code.length,
                                            ),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
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
                                        subtitle: const Text(
                                            "Base Currency: USD"),
                                        trailing: Text(
                                          currency.rate
                                              .toStringAsFixed(4),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
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

