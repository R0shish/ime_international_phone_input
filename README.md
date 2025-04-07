# International Phone Number Input v2

[![Pub Version](https://img.shields.io/pub/v/ime_international_phone_input)](https://pub.dev/packages/ime_international_phone_input)
[![License](https://img.shields.io/github/license/SahanMonaara/ime_international_phone_input)](LICENSE)

`ime_international_phone_input` is a Flutter package that provides a customizable international phone number input widget. This package allows developers to easily integrate phone number input fields into their Flutter applications, supporting validation and formatting for different countries.

## Features

- Supports international phone number input.
- Customizable input field.
- Auto-formatting and validation of phone numbers.
- Country code picker with flag icons.
- Lightweight and easy to integrate.

## Installation

Add `ime_international_phone_input` to your `pubspec.yaml` file:

```yaml
dependencies:
  ime_international_phone_input: ^0.0.2
```

Then, run `flutter pub get` to install the package.

## Usage

Here's a basic example of how to use the `ime_international_phone_input` package:

```dart
import 'package:flutter/material.dart';
import 'package:ime_international_phone_input/ime_international_phone_input.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('International Phone Number Input'),
        ),
        body: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String phoneNumber;
  PhoneNumber number = PhoneNumber(isoCode: 'US');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: InternationalPhoneNumberInput(
        onInputChanged: (PhoneNumber number) {
          print(number.phoneNumber);
        },
        onInputValidated: (bool value) {
          print(value);
        },
        selectorConfig: SelectorConfig(
          selectorType: PhoneInputSelectorType.DROPDOWN,
        ),
        ignoreBlank: false,
        autoValidateMode: AutovalidateMode.disabled,
        initialValue: number,
        textFieldController: TextEditingController(),
        formatInput: true,
        keyboardType:
            TextInputType.numberWithOptions(signed: true, decimal: true),
        inputBorder: OutlineInputBorder(),
        onSaved: (PhoneNumber number) {
          phoneNumber = number.phoneNumber;
        },
      ),
    );
  }
}
```

## Documentation

For more detailed documentation and examples, please refer to the [package documentation on pub.dev](https://pub.dev/packages/ime_international_phone_input).

## Contributing

Contributions are welcome! Please open an issue or submit a pull request with your changes. Make sure to follow the existing code style and include tests for any new features or bug fixes.

1. Fork the repository.
2. Create a new branch: `git checkout -b my-branch-name`.
3. Make your changes and commit them: `git commit -m 'Add new feature'`.
4. Push to the branch: `git push origin my-branch-name`.
5. Submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgements

- [intl_phone_number_input](https://pub.dev/packages/intl_phone_number_input) for providing the base implementation.
