import 'package:flutter/material.dart';
import 'package:ime_international_phone_input/src/models/country_model.dart';
import 'package:ime_international_phone_input/src/utils/util.dart';

/// Creates a list of Countries with a search textfield.
class CountrySearchListWidget extends StatefulWidget {
  final List<Country> countries;
  final InputDecoration? searchBoxDecoration;
  final String? locale;
  final ScrollController? scrollController;
  final bool autoFocus;
  final bool? showFlags;
  final bool? useEmoji;

  const CountrySearchListWidget(
    this.countries,
    this.locale, {
    super.key,
    this.searchBoxDecoration,
    this.scrollController,
    this.showFlags,
    this.useEmoji,
    this.autoFocus = false,
  });

  @override
  CountrySearchListWidgetState createState() => CountrySearchListWidgetState();
}

class CountrySearchListWidgetState extends State<CountrySearchListWidget> {
  late final TextEditingController _searchController = TextEditingController();
  late List<Country> filteredCountries;

  @override
  void initState() {
    final String value = _searchController.text.trim();
    filteredCountries = Utils.filterCountries(
      countries: widget.countries,
      locale: widget.locale,
      value: value,
    );
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Returns [InputDecoration] of the search box
  InputDecoration getSearchBoxDecoration() {
    return widget.searchBoxDecoration ?? InputDecoration(labelText: 'Search by country name or dial code');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextFormField(
            decoration: getSearchBoxDecoration(),
            controller: _searchController,
            autofocus: widget.autoFocus,
            onChanged: (value) {
              final String value = _searchController.text.trim();
              return setState(
                () => filteredCountries = Utils.filterCountries(
                  countries: widget.countries,
                  locale: widget.locale,
                  value: value,
                ),
              );
            },
          ),
        ),
        Flexible(
          child: ListView.builder(
            controller: widget.scrollController,
            shrinkWrap: true,
            itemCount: filteredCountries.length,
            itemBuilder: (BuildContext context, int index) {
              Country country = filteredCountries[index];

              return DirectionalCountryListTile(
                country: country,
                locale: widget.locale,
                showFlags: widget.showFlags!,
                useEmoji: widget.useEmoji!,
              );
              // return ListTile(
              //   key: Key(TestHelper.countryItemKeyValue(country.alpha2Code)),
              //   leading: widget.showFlags!
              //       ? _Flag(country: country, useEmoji: widget.useEmoji)
              //       : null,
              //   title: Align(
              //     alignment: AlignmentDirectional.centerStart,
              //     child: Text(
              //       '${Utils.getCountryName(country, widget.locale)}',
              //       textDirection: Directionality.of(context),
              //       textAlign: TextAlign.start,
              //     ),
              //   ),
              //   subtitle: Align(
              //     alignment: AlignmentDirectional.centerStart,
              //     child: Text(
              //       '${country.dialCode ?? ''}',
              //       textDirection: TextDirection.ltr,
              //       textAlign: TextAlign.start,
              //     ),
              //   ),
              //   onTap: () => Navigator.of(context).pop(country),
              // );
            },
          ),
        ),
      ],
    );
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}

class DirectionalCountryListTile extends StatelessWidget {
  final Country country;
  final String? locale;
  final bool showFlags;
  final bool useEmoji;

  const DirectionalCountryListTile({
    super.key,
    required this.country,
    required this.locale,
    required this.showFlags,
    required this.useEmoji,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: (showFlags ? _Flag(country: country, useEmoji: useEmoji) : null),
      title: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          '${Utils.getCountryName(country, locale)}',
          textDirection: Directionality.of(context),
          textAlign: TextAlign.start,
        ),
      ),
      subtitle: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          country.dialCode ?? '',
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.start,
        ),
      ),
      onTap: () => Navigator.of(context).pop(country),
    );
  }
}

class _Flag extends StatelessWidget {
  final Country? country;
  final bool? useEmoji;

  const _Flag({this.country, this.useEmoji});

  @override
  Widget build(BuildContext context) {
    return country != null
        ? Container(
            child: useEmoji!
                ? Text(
                    Utils.generateFlagEmojiUnicode(country?.alpha2Code ?? ''),
                    style: Theme.of(context).textTheme.headlineSmall,
                  )
                : country?.flagUri != null
                    ? CircleAvatar(
                        backgroundImage: AssetImage(country!.flagUri),
                      )
                    : SizedBox.shrink(),
          )
        : SizedBox.shrink();
  }
}
