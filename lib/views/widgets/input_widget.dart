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
                ? neutralDarkColor.withValues(alpha: 0.1)
                : neutralColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            // border: Border.all(
            //   color: isDarkMode ? neutralDarkColor : neutralColor,
            //   width: 1,
            // ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              // Searchable Dropdown for Currency A
              SizedBox(
                width: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        // border: Border.all(
                        //   color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
                        //   width: 1,
                        // ),
                        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                      ),
                      child: TextField(
                        controller: sourceSearchController,
                        style: const TextStyle(
                          //  color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: context.tr('select'),
                          hintStyle: const TextStyle(color: Colors.white),
                          // suffixIcon: IconButton(
                          //   icon: const Icon(Icons.clear,size: 16),
                          //   onPressed: () => sourceSearchController.clear(),
                          // ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 12,
                          ),
                        ),
                        onChanged: onSourceSearchChanged,
                        onTap: onSourceTap,
                      ),
                    ),
                    if (showSourceDropdown &&
                        filteredSourceCurrencies.isNotEmpty)
                      Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        decoration: BoxDecoration(
                          color: Theme.of(context).highlightColor,
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
                                  // color: secondaryColor,
                                  fontSize: 12,
                                ),
                              ),
                              onTap: () {
                                onSourceCurrencySelected(currency);
                                FocusManager.instance.primaryFocus?.unfocus();
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
