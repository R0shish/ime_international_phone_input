import 'package:flutter/material.dart';
import 'package:ime_international_phone_input/src/models/country_model.dart';
import 'package:ime_international_phone_input/src/utils/selector_config.dart';
import 'package:ime_international_phone_input/src/widgets/countries_search_list_widget.dart';
import 'package:ime_international_phone_input/src/widgets/input_widget.dart';
import 'package:ime_international_phone_input/src/widgets/item.dart';

/// [SelectorButton]
class SelectorButton extends StatelessWidget {
  final List<Country> countries;
  final Country? country;
  final InputDecoration? decoration;
  final SelectorConfig selectorConfig;
  final TextStyle? selectorTextStyle;
  final InputDecoration? searchBoxDecoration;
  final bool autoFocusSearchField;
  final String? locale;
  final bool isEnabled;
  final bool isScrollControlled;

  final ValueChanged<Country?> onCountryChanged;

  const SelectorButton({
    super.key,
    required this.countries,
    required this.country,
    required this.selectorConfig,
    required this.selectorTextStyle,
    required this.searchBoxDecoration,
    required this.autoFocusSearchField,
    required this.locale,
    required this.onCountryChanged,
    required this.isEnabled,
    required this.isScrollControlled,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return selectorConfig.selectorType == PhoneInputSelectorType.DROPDOWN
        ? countries.isNotEmpty && countries.length > 1
            ? DropdownButtonHideUnderline(
                child: DropdownButton<Country>(
                  hint: Item(
                    country: country,
                    showFlag: selectorConfig.showFlags,
                    useEmoji: selectorConfig.useEmoji,
                    leadingPadding: selectorConfig.leadingPadding,
                    trailingSpace: selectorConfig.trailingSpace,
                    textStyle: selectorTextStyle,
                  ),
                  value: country,
                  items: mapCountryToDropdownItem(countries),
                  onChanged: isEnabled ? onCountryChanged : null,
                ),
              )
            : Item(
                country: country,
                showFlag: selectorConfig.showFlags,
                useEmoji: selectorConfig.useEmoji,
                leadingPadding: selectorConfig.leadingPadding,
                trailingSpace: selectorConfig.trailingSpace,
                textStyle: selectorTextStyle,
              )
        : Container(
            alignment: Alignment.centerLeft,
            width: 117,
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline, width: 1.4),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: MaterialButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              highlightElevation: 0,
              padding: EdgeInsets.zero,
              minWidth: 0,
              onPressed: selectorConfig.isSelectorEnabled
                  ? countries.isNotEmpty && countries.length > 1 && isEnabled
                      ? () async {
                          Country? selected;
                          if (selectorConfig.selectorType == PhoneInputSelectorType.BOTTOM_SHEET) {
                            selected = await showCountrySelectorBottomSheet(context, countries);
                          } else {
                            selected = await showCountrySelectorDialog(context, countries);
                          }

                          if (selected != null) {
                            onCountryChanged(selected);
                          }
                        }
                      : null
                  : null,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0, left: 12.0),
                child: Item(
                  country: country,
                  showFlag: selectorConfig.showFlags,
                  useEmoji: selectorConfig.useEmoji,
                  leadingPadding: selectorConfig.leadingPadding,
                  trailingSpace: selectorConfig.trailingSpace,
                  textStyle: selectorTextStyle,
                ),
              ),
            ),
          );
  }

  /// Converts the list [countries] to `DropdownMenuItem`
  List<DropdownMenuItem<Country>> mapCountryToDropdownItem(List<Country> countries) {
    return countries.map((country) {
      return DropdownMenuItem<Country>(
        value: country,
        child: Item(
          country: country,
          showFlag: selectorConfig.showFlags,
          useEmoji: selectorConfig.useEmoji,
          textStyle: selectorTextStyle,
          withCountryNames: false,
          trailingSpace: selectorConfig.trailingSpace,
        ),
      );
    }).toList();
  }

  /// shows a Dialog with list [countries] if the [PhoneInputSelectorType.DIALOG] is selected
  Future<Country?> showCountrySelectorDialog(BuildContext inheritedContext, List<Country> countries) {
    return showDialog(
      context: inheritedContext,
      barrierDismissible: true,
      builder: (BuildContext context) => AlertDialog(
        content: Directionality(
          textDirection: Directionality.of(inheritedContext),
          child: SizedBox(
            width: double.maxFinite,
            child: CountrySearchListWidget(
              countries,
              locale,
              searchBoxDecoration: searchBoxDecoration,
              showFlags: selectorConfig.showFlags,
              useEmoji: selectorConfig.useEmoji,
              autoFocus: autoFocusSearchField,
            ),
          ),
        ),
      ),
    );
  }

  /// shows a Dialog with list [countries] if the [PhoneInputSelectorType.BOTTOM_SHEET] is selected
  Future<Country?> showCountrySelectorBottomSheet(BuildContext inheritedContext, List<Country> countries) {
    return showModalBottomSheet(
      context: inheritedContext,
      clipBehavior: Clip.hardEdge,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
      useSafeArea: selectorConfig.useBottomSheetSafeArea,
      builder: (BuildContext context) {
        return Stack(children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: DraggableScrollableSheet(
              builder: (BuildContext context, ScrollController controller) {
                return Directionality(
                  textDirection: Directionality.of(inheritedContext),
                  child: Container(
                    decoration: ShapeDecoration(
                      color: Theme.of(context).canvasColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                    ),
                    child: CountrySearchListWidget(
                      countries,
                      locale,
                      searchBoxDecoration: searchBoxDecoration,
                      scrollController: controller,
                      showFlags: selectorConfig.showFlags,
                      useEmoji: selectorConfig.useEmoji,
                      autoFocus: autoFocusSearchField,
                    ),
                  ),
                );
              },
            ),
          ),
        ]);
      },
    );
  }
}
