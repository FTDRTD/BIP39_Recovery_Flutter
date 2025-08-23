# BIP39 Recovery Tool (Flutter)

> **[中文版 (Chinese Version)](README_cn.md)**

A secure, offline BIP39 mnemonic recovery tool built with Flutter. This application helps users recover their BIP39 seed phrases in a completely offline environment, ensuring maximum security and privacy.

## Features

- **100% Offline**: No internet connection required - all operations performed locally
- **Secure Recovery**: Reconstructs words using powers of 2, never storing the complete phrase until final recovery
- **Multi-language Support**: Available in English and Chinese
- **Multiple Length Support**: Supports 12, 18, and 24-word seed phrases
- **BIP39 Standard Compliant**: Uses the official BIP39 English wordlist (2048 words)
- **Cross-platform**: Built with Flutter for iOS, Android, Windows, macOS, and Linux

## How It Works

1. **Select Length**: Choose your seed phrase length (12, 18, or 24 words)
2. **Input Numbers**: For each word, enter a series of powers of 2 (1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024)
3. **Recovery**: The tool calculates the word index from the sum and displays the corresponding BIP39 word
4. **Complete**: Once all words are recovered, view your complete seed phrase

## Security Features

- **Complete Offline Operation**: No data is ever transmitted or stored externally
- **No Complete Phrase Storage**: Individual words are only stored after each recovery step
- **Local Wordlist**: Uses locally stored BIP39 wordlist file
- **Secure Memory Handling**: Minimizes data retention in memory

## Installation

### Prerequisites

- Flutter SDK (3.9.0 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- VS Code or Android Studio

### Setup

1. Clone this repository:

   ```bash
   git clone [repository-url]
   cd bip39_recovery_flutter
   ```
2. Install dependencies:

   ```bash
   flutter pub get
   ```
3. Run the application:

   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                    # Application entry point
└── bip39_recovery/
    ├── bip39_logic.dart         # Core BIP39 logic and wordlist management
    ├── bip39_ui.dart           # Main UI components and screens
    ├── theme.dart              # Application theming
    └── wordlists/
        └── english.txt         # BIP39 English wordlist (2048 words)
```

## Usage Guide

### Starting Recovery

1. Launch the application
2. Select your preferred language (English/Chinese)
3. Choose your seed phrase length (12, 18, or 24 words)
4. Click the corresponding button to begin

### Recovering Words

1. For each word position, enter numbers that sum to the word's index + 1
2. Valid numbers are powers of 2: 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024
3. The tool will display the corresponding word as you add numbers
4. Click "Confirm Word & Next" to proceed to the next word

### Example

To recover the word at index 5 (the 6th word in the list):

- Enter: 1, 4 (1 + 4 = 5)
- The tool will display the corresponding BIP39 word
- Confirm and move to the next word

## Building for Production

### Android APK

```bash
flutter build apk --release
```

### iOS App Store

```bash
flutter build ios --release
```

### Desktop Applications

```bash
# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

## Dependencies

- `flutter`: UI framework
- `cupertino_icons`: iOS-style icons

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Security Considerations

- **Always verify the source code** before using for sensitive operations
- **Use on a secure, offline device** when recovering important seed phrases
- **Never share your seed phrase** with anyone or any online service
- **Double-check recovered words** against your original backup method

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Disclaimer

This tool is provided as-is for educational and backup recovery purposes. Users are responsible for ensuring the security of their own operations. Always maintain multiple secure backups of your seed phrases using established best practices.
