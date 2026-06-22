import 'package:currency_converter/constants/color_util.dart';
import 'package:currency_converter/constants/app_localizations.dart';
import 'package:currency_converter/data/database.dart';
import 'package:flutter/material.dart';

class OutputWidget extends StatelessWidget {
  final bool isDarkMode;
  final List<Currency> currencies;
  final TextEditingController destinationSearchController;
  final List<Currency> filteredDestinationCurrencies;
  final bool showDestinationDropdown;
  final double convertedAmount;
  final String selectedCurrency;
  final String amount;
  final String destinationCurrency;
  final Function(String) onDestinationSearchChanged;
  final Function(bool) onDestinationDropdownToggle;
  final Function() onDestinationTap;
  final Function(Currency) onDestinationCurrencySelected;

  const OutputWidget({
    super.key,
    required this.isDarkMode,
    required this.currencies,
    required this.destinationSearchController,
    required this.filteredDestinationCurrencies,
    required this.showDestinationDropdown,
    required this.convertedAmount,
    required this.selectedCurrency,
    required this.amount,
    required this.destinationCurrency,
    required this.onDestinationSearchChanged,
    required this.onDestinationDropdownToggle,
    required this.onDestinationTap,
    required this.onDestinationCurrencySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${context.tr('to_currency')} ($destinationCurrency)",
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
            color: isDarkMode
                ? neutralDarkColor.withValues(
                    alpha: 0.1,
                  )
                : neutralColor.withValues(
                    alpha: 0.1,
                  ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? neutralDarkColor : neutralColor,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    convertedAmount.toStringAsFixed(4),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (amount.isNotEmpty)
                    Text(
                      "$amount $selectedCurrency",
                      style: const TextStyle(
                        fontSize: 12,
                        color: secondaryColor,
                      ),
                    ),
                ],
              ),
              // Searchable Destination Currency Dropdown
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextField(
                      controller: destinationSearchController,
                      style: const TextStyle(
                        color: secondaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 0,
                        ),
                        hintText: destinationCurrency,
                        hintStyle: const TextStyle(
                          color: secondaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onChanged: onDestinationSearchChanged,
                      onTap: onDestinationTap,
                    ),
                    if (showDestinationDropdown &&
                        filteredDestinationCurrencies.isNotEmpty)
                      Container(
                        alignment: Alignment.centerRight,
                        constraints: const BoxConstraints(
                          maxHeight: 150,
                          maxWidth: 150,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredDestinationCurrencies.length,
                          itemBuilder: (context, index) {
                            final currency =
                                filteredDestinationCurrencies[index];
                            return ListTile(
                              dense: true,
                              title: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  currency.code,
                                  style: const TextStyle(
                                    color: secondaryColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              onTap: () {
                                onDestinationCurrencySelected(currency);
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


