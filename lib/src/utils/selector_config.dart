import 'package:flutter/material.dart';
import 'package:ime_international_phone_input/src/models/country_model.dart';
import 'package:ime_international_phone_input/src/widgets/input_widget.dart';

/// [CountryComparator] takes two countries: A and B.
///
/// Should return -1 if A precedes B, 0 if A is equal to B and 1 if B precedes A
typedef CountryComparator = int Function(Country, Country);

/// [SelectorConfig] contains selector button configurations
class SelectorConfig {
  /// [selectorType], for selector button type
  final PhoneInputSelectorType selectorType;

  /// [showFlags], displays flag along side countries info on selector button
  /// and list items within the selector
  final bool showFlags;

  /// [useEmoji], uses emoji flags instead of png assets
  final bool useEmoji;

  /// [countryComparator], sort the country list according to the comparator.
  ///
  /// Sorting is disabled by default
  final CountryComparator? countryComparator;

  /// [setSelectorButtonAsPrefixIcon], this sets/places the selector button inside the [TextField] as a prefixIcon.
  final bool setSelectorButtonAsPrefixIcon;

  /// Space before the flag icon
  final double? leadingPadding;

  /// Add white space for short dial code
  final bool trailingSpace;

  /// Use safe area for selectorType=BOTTOM_SHEET
  final bool useBottomSheetSafeArea;
  final bool isSelectorEnabled;

  const SelectorConfig({
    this.selectorType = PhoneInputSelectorType.BOTTOM_SHEET,
    this.setSelectorButtonAsPrefixIcon = false,
    this.trailingSpace = true,
    this.showFlags = true,
    this.useEmoji = true,
    this.leadingPadding = 0,
    this.countryComparator,
    this.isSelectorEnabled = true,
    this.useBottomSheetSafeArea = false,
  });
}
