import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ime_international_phone_input/src/models/country_list.dart';
import 'package:ime_international_phone_input/src/models/country_model.dart';
import 'package:ime_international_phone_input/src/providers/country_provider.dart';
import 'package:ime_international_phone_input/src/utils/formatter/as_you_type_formatter.dart';
import 'package:ime_international_phone_input/src/utils/phone_number.dart';
import 'package:ime_international_phone_input/src/utils/phone_number/phone_number_util.dart';
import 'package:ime_international_phone_input/src/utils/selector_config.dart';
import 'package:ime_international_phone_input/src/utils/util.dart';
import 'package:ime_international_phone_input/src/utils/widget_view.dart';
import 'package:ime_international_phone_input/src/widgets/selector_button.dart';

/// Enum for [SelectorButton] types.
///
/// Available type includes:
///   * [PhoneInputSelectorType.DROPDOWN]
///   * [PhoneInputSelectorType.BOTTOM_SHEET]
///   * [PhoneInputSelectorType.DIALOG]
enum PhoneInputSelectorType { DROPDOWN, BOTTOM_SHEET, DIALOG }

/// A [TextFormField] for [InternationalPhoneNumberInput].
///
/// [initialValue] accepts a [PhoneNumber] this is used to set initial values
/// for phone the input field and the selector button
///
/// [selectorButtonOnErrorPadding] is a double which is used to align the selector
/// button with the input field when an error occurs
///
/// [locale] accepts a country locale which will be used to translation, if the
/// translation exist
///
/// [countries] accepts list of string on Country isoCode, if specified filters
/// available countries to match the [countries] specified.
class InternationalPhoneNumberInput extends StatefulWidget {
  final SelectorConfig selectorConfig;

  final ValueChanged<PhoneNumber>? onInputChanged;
  final ValueChanged<bool>? onInputValidated;

  final VoidCallback? onSubmit;
  final ValueChanged<String>? onFieldSubmitted;
  final String? Function(String?)? validator;
  final ValueChanged<PhoneNumber>? onSaved;

  final Key? fieldKey;
  final TextEditingController? textFieldController;
  final TextInputType keyboardType;
  final TextInputAction? keyboardAction;

  final PhoneNumber? initialValue;
  final String? labelText;
  final String? errorMessage;

  final double selectorButtonOnErrorPadding;

  /// Ignored if [setSelectorButtonAsPrefixIcon = true]
  final double spaceBetweenSelectorAndTextField;
  final int maxLength;

  final bool isEnabled;
  final bool formatInput;
  final bool autoFocus;
  final bool autoFocusSearch;
  final AutovalidateMode autoValidateMode;
  final bool ignoreBlank;
  final bool countrySelectorScrollControlled;

  final String? locale;

  final TextStyle? textStyle;
  final TextStyle? selectorTextStyle;
  final InputBorder? inputBorder;
  final InputDecoration? inputDecoration;
  final InputDecoration? searchBoxDecoration;
  final Color? cursorColor;
  final TextAlign textAlign;
  final TextAlignVertical textAlignVertical;
  final EdgeInsets scrollPadding;

  final FocusNode? focusNode;
  final Iterable<String>? autofillHints;

  final List<String>? countries;

  const InternationalPhoneNumberInput(
      {super.key,
      this.selectorConfig = const SelectorConfig(),
      required this.onInputChanged,
      this.onInputValidated,
      this.onSubmit,
      this.onFieldSubmitted,
      this.validator,
      this.onSaved,
      this.fieldKey,
      this.textFieldController,
      this.keyboardAction,
      this.keyboardType = TextInputType.phone,
      this.initialValue,
      this.labelText = 'Phone number',
      this.errorMessage = 'Invalid phone number',
      this.selectorButtonOnErrorPadding = 24,
      this.spaceBetweenSelectorAndTextField = 12,
      this.maxLength = 15,
      this.isEnabled = true,
      this.formatInput = true,
      this.autoFocus = false,
      this.autoFocusSearch = false,
      this.autoValidateMode = AutovalidateMode.disabled,
      this.ignoreBlank = false,
      this.countrySelectorScrollControlled = true,
      this.locale,
      this.textStyle,
      this.selectorTextStyle,
      this.inputBorder,
      this.inputDecoration,
      this.searchBoxDecoration,
      this.textAlign = TextAlign.start,
      this.textAlignVertical = TextAlignVertical.center,
      this.scrollPadding = const EdgeInsets.all(20.0),
      this.focusNode,
      this.cursorColor,
      this.autofillHints,
      this.countries});

  @override
  State<StatefulWidget> createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InternationalPhoneNumberInput> {
  TextEditingController? controller;
  double selectorButtonBottomPadding = 0;

  Country? country;
  List<Country> countries = [];
  bool isNotValid = true;

  @override
  void initState() {
    super.initState();
    loadCountries();
    controller = widget.textFieldController ?? TextEditingController();
    initialiseWidget();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _InputWidgetView(
      state: this,
    );
  }

  @override
  void didUpdateWidget(InternationalPhoneNumberInput oldWidget) {
    loadCountries(previouslySelectedCountry: country);
    if (oldWidget.initialValue?.hash != widget.initialValue?.hash) {
      if (country!.alpha2Code != widget.initialValue?.isoCode) {
        loadCountries();
      }
      initialiseWidget();
    }
    super.didUpdateWidget(oldWidget);
  }

  /// [initialiseWidget] sets initial values of the widget
  void initialiseWidget() async {
    if (widget.initialValue != null) {
      if (widget.initialValue!.phoneNumber != null &&
          widget.initialValue!.phoneNumber!.isNotEmpty &&
          (await PhoneNumberUtil.isValidNumber(phoneNumber: widget.initialValue!.phoneNumber!, isoCode: widget.initialValue!.isoCode!))!) {
        String phoneNumber = await PhoneNumber.getParsableNumber(widget.initialValue!);

        controller!.text = widget.formatInput ? phoneNumber : phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

        phoneNumberControllerListener();
      }
    }
  }

  /// loads countries from [Countries.countryList] and selected Country
  void loadCountries({Country? previouslySelectedCountry}) {
    if (mounted) {
      List<Country> countries = CountryProvider.getCountriesData(countries: widget.countries);

      Country country = previouslySelectedCountry ??
          Utils.getInitialSelectedCountry(
            countries,
            widget.initialValue?.isoCode ?? '',
          );

      // Remove potential duplicates
      countries = countries.toSet().toList();

      final CountryComparator? countryComparator = widget.selectorConfig.countryComparator;
      if (countryComparator != null) {
        countries.sort(countryComparator);
      }

      setState(() {
        this.countries = countries;
        this.country = country;
      });
    }
  }

  /// Listener that validates changes from the widget, returns a bool to
  /// the `ValueCallback` [widget.onInputValidated]
  void phoneNumberControllerListener() {
    if (mounted) {
      String parsedPhoneNumberString = controller!.text.replaceAll(RegExp(r'[^\d+]'), '');

      getParsedPhoneNumber(parsedPhoneNumberString, country?.alpha2Code).then((phoneNumber) {
        if (phoneNumber == null) {
          String phoneNumber = '${country?.dialCode}$parsedPhoneNumberString';

          if (widget.onInputChanged != null) {
            widget.onInputChanged!(PhoneNumber(phoneNumber: phoneNumber, isoCode: country?.alpha2Code, dialCode: country?.dialCode));
          }

          if (widget.onInputValidated != null) {
            widget.onInputValidated!(false);
          }
          isNotValid = true;
        } else {
          if (widget.onInputChanged != null) {
            widget.onInputChanged!(PhoneNumber(phoneNumber: phoneNumber, isoCode: country?.alpha2Code, dialCode: country?.dialCode));
          }

          if (widget.onInputValidated != null) {
            widget.onInputValidated!(true);
          }
          isNotValid = false;
        }
      });
    }
  }

  /// Returns a formatted String of [phoneNumber] with [isoCode], returns `null`
  /// if [phoneNumber] is not valid or if an [Exception] is caught.
  Future<String?> getParsedPhoneNumber(String phoneNumber, String? isoCode) async {
    if (phoneNumber.isNotEmpty && isoCode != null) {
      try {
        bool? isValidPhoneNumber = await PhoneNumberUtil.isValidNumber(phoneNumber: phoneNumber, isoCode: isoCode);

        if (isValidPhoneNumber!) {
          return await PhoneNumberUtil.normalizePhoneNumber(phoneNumber: phoneNumber, isoCode: isoCode);
        }
      } on Exception {
        return null;
      }
    }
    return null;
  }

  /// Creates or Select [InputDecoration]
  InputDecoration getInputDecoration(InputDecoration? decoration) {
    InputDecoration value = decoration ??
        InputDecoration(
          border: widget.inputBorder ?? UnderlineInputBorder(),
          labelText: widget.labelText,
        );

    if (widget.selectorConfig.setSelectorButtonAsPrefixIcon) {
      return value.copyWith(
          prefixIcon: SelectorButton(
        country: country,
        countries: countries,
        onCountryChanged: onCountryChanged,
        selectorConfig: widget.selectorConfig,
        selectorTextStyle: widget.selectorTextStyle,
        searchBoxDecoration: widget.searchBoxDecoration,
        locale: locale,
        isEnabled: widget.isEnabled,
        autoFocusSearchField: widget.autoFocusSearch,
        isScrollControlled: widget.countrySelectorScrollControlled,
      ));
    }

    return value;
  }

  /// Validate the phone number when a change occurs
  void onChanged(String value) {
    phoneNumberControllerListener();
  }

  /// Validate and returns a validation error when [FormState] validate is called.
  ///
  /// Also updates [selectorButtonBottomPadding]
  String? validator(String? value) {
    bool isValid = isNotValid && (value!.isNotEmpty || widget.ignoreBlank == false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (isValid && widget.errorMessage != null) {
        setState(() {
          selectorButtonBottomPadding = widget.selectorButtonOnErrorPadding;
        });
      } else {
        setState(() {
          selectorButtonBottomPadding = 0;
        });
      }
    });

    return isValid ? widget.errorMessage : null;
  }

  /// Changes Selector Button Country and Validate Change.
  void onCountryChanged(Country? country) {
    setState(() {
      this.country = country;
    });
    phoneNumberControllerListener();
  }

  void _phoneNumberSaved() {
    if (mounted) {
      String parsedPhoneNumberString = controller!.text.replaceAll(RegExp(r'[^\d+]'), '');

      String phoneNumber = '${country?.dialCode ?? ''}$parsedPhoneNumberString';

      widget.onSaved?.call(
        PhoneNumber(phoneNumber: phoneNumber, isoCode: country?.alpha2Code, dialCode: country?.dialCode),
      );
    }
  }

  /// Saved the phone number when form is saved
  void onSaved(String? value) {
    _phoneNumberSaved();
  }

  /// Corrects duplicate locale
  String? get locale {
    if (widget.locale == null) return null;

    if (widget.locale!.toLowerCase() == 'nb' || widget.locale!.toLowerCase() == 'nn') {
      return 'no';
    }
    return widget.locale;
  }
}

class _InputWidgetView extends WidgetView<InternationalPhoneNumberInput, _InputWidgetState> {
  @override
  final _InputWidgetState state;

  const _InputWidgetView({required this.state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    final countryCode = state.country?.alpha2Code ?? '';
    final dialCode = state.country?.dialCode ?? '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        if (!widget.selectorConfig.setSelectorButtonAsPrefixIcon) ...[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: 56,
                child: SelectorButton(
                  decoration: state.getInputDecoration(widget.inputDecoration),
                  country: state.country,
                  countries: state.countries,
                  onCountryChanged: state.onCountryChanged,
                  selectorConfig: widget.selectorConfig,
                  selectorTextStyle: widget.selectorTextStyle,
                  searchBoxDecoration: widget.searchBoxDecoration,
                  locale: state.locale,
                  isEnabled: widget.isEnabled,
                  autoFocusSearchField: widget.autoFocusSearch,
                  isScrollControlled: widget.countrySelectorScrollControlled,
                ),
              ),
              SizedBox(
                height: state.selectorButtonBottomPadding,
              ),
            ],
          ),
          SizedBox(width: widget.spaceBetweenSelectorAndTextField),
        ],
        Flexible(
          child: TextFormField(
            textDirection: TextDirection.ltr,
            controller: state.controller,
            cursorColor: widget.cursorColor,
            focusNode: widget.focusNode,
            enabled: widget.isEnabled,
            autofocus: widget.autoFocus,
            keyboardType: widget.keyboardType,
            textInputAction: widget.keyboardAction,
            style: widget.textStyle,
            decoration: state.getInputDecoration(widget.inputDecoration),
            textAlign: widget.textAlign,
            textAlignVertical: widget.textAlignVertical,
            onEditingComplete: widget.onSubmit,
            onFieldSubmitted: widget.onFieldSubmitted,
            autovalidateMode: widget.autoValidateMode,
            autofillHints: widget.autofillHints,
            validator: widget.validator ?? state.validator,
            onSaved: state.onSaved,
            scrollPadding: widget.scrollPadding,
            inputFormatters: [
              LengthLimitingTextInputFormatter(widget.maxLength),
              widget.formatInput
                  ? AsYouTypeFormatter(
                      isoCode: countryCode,
                      dialCode: dialCode,
                      onInputFormatted: (TextEditingValue value) {
                        state.controller!.value = value;
                      },
                    )
                  : FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: state.onChanged,
          ),
        )
      ],
    );
  }
}
