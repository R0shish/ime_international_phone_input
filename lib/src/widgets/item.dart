import 'package:flutter/material.dart';
import 'package:ime_international_phone_input/src/models/country_model.dart';
import 'package:ime_international_phone_input/src/utils/util.dart';

/// [Item]
class Item extends StatelessWidget {
  final Country? country;
  final bool? showFlag;
  final bool? useEmoji;
  final TextStyle? textStyle;
  final bool withCountryNames;
  final double? leadingPadding;
  final bool trailingSpace;

  const Item({
    super.key,
    this.country,
    this.showFlag,
    this.useEmoji,
    this.textStyle,
    this.withCountryNames = false,
    this.leadingPadding = 12,
    this.trailingSpace = true,
  });

  @override
  Widget build(BuildContext context) {
    String dialCode = (country?.dialCode ?? '');
    if (trailingSpace) {
      dialCode = dialCode.padRight(5, "   ");
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(width: leadingPadding),
        _Flag(
          country: country,
          showFlag: showFlag,
          useEmoji: useEmoji,
        ),
        Text(
          dialCode,
          textDirection: TextDirection.ltr,
          style: textStyle,
        ),
      ],
    );
  }
}

class _Flag extends StatelessWidget {
  final Country? country;
  final bool? showFlag;
  final bool? useEmoji;

  const _Flag({this.country, this.showFlag, this.useEmoji});

  @override
  Widget build(BuildContext context) {
    return country != null && showFlag!
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
            child: Container(
              child: useEmoji!
                  ? Text(
                      Utils.generateFlagEmojiUnicode(country?.alpha2Code ?? ''),
                      style: Theme.of(context).textTheme.headlineSmall,
                    )
                  : SizedBox(
                      height: 24,
                      width: 24,
                      child: CircleAvatar(
                        backgroundImage: AssetImage(
                          country!.flagUri,
                        ),
                      ),
                    ),
            ),
          )
        : SizedBox.shrink();
  }
}
