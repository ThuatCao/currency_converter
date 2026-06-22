import 'package:currency_converter/constants/color_util.dart';
import 'package:currency_converter/constants/app_localizations.dart';
import 'package:currency_converter/data/database.dart';
import 'package:flutter/material.dart';

class InputWidget extends StatelessWidget {
  final bool isDarkMode;
  final List<Currency> currencies;
  final TextEditingController sourceSearchController;
  final TextEditingController amountController;
  final List<Currency> filteredSourceCurrencies;
  final bool showSourceDropdown;
  final Function(String) onSourceSearchChanged;
  final Function(bool) onSourceDropdownToggle;
  final Function() onSourceTap;
  final Function(String) onAmountChanged;
  final Function(Currency) onSourceCurrencySelected;

  const InputWidget({
    super.key,
    required this.isDarkMode,
    required this.currencies,
    required this.sourceSearchController,
    required this.amountController,
    required this.filteredSourceCurrencies,
    required this.showSourceDropdown,
    required this.onSourceSearchChanged,
    required this.onSourceDropdownToggle,
    required this.onSourceTap,
    required this.onAmountChanged,
    required this.onSourceCurrencySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('from_currency'),
          style: const TextStyle(
            fontSize: 12,
            color: secondaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
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
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 2,
          ),
          child: Row(
            children: [
              // Searchable Dropdown for Currency A
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: sourceSearchController,
                      style: const TextStyle(
                        color: secondaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: context.tr('select'),
                        hintStyle: const TextStyle(
                          color: secondaryColor,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 12,
                        ),
                      ),
                      onChanged: onSourceSearchChanged,
                      onTap: onSourceTap,
                    ),
                    if (showSourceDropdown && filteredSourceCurrencies.isNotEmpty)
                      Container(
                        constraints: const BoxConstraints(
                          maxHeight: 150,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredSourceCurrencies.length,
                          itemBuilder: (context, index) {
                            final currency = filteredSourceCurrencies[index];
                            return ListTile(
                              dense: true,
                              title: Text(
                                currency.code,
                                style: const TextStyle(
                                  color: secondaryColor,
                                  fontSize: 12,
                                ),
                              ),
                              onTap: () {
                                onSourceCurrencySelected(currency);
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Input Field for Amount
              Expanded(
                flex: 2,
                child: TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(
                    color: secondaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: context.tr('amount_hint'),
                    hintStyle: const TextStyle(
                      color: secondaryColor,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                  ),
                  onChanged: onAmountChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


