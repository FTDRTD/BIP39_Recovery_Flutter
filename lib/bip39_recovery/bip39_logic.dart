import 'package:flutter/services.dart' show rootBundle;

class Bip39Logic {
  static const String wordlistPath = 'lib/bip39_recovery/wordlists/english.txt';
  static const Set<int> validInputNumbers = {
    1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024
  };

  List<String>? _wordlist;
  List<String>? get wordlist => _wordlist; // Public getter for _wordlist

  Future<List<String>?> loadWordlist() async {
    if (_wordlist != null) {
      return _wordlist;
    }
    try {
      String content = await rootBundle.loadString(wordlistPath);
      List<String> words = content
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();

      if (words.length != 2048) {
        // TODO: Handle error - invalid wordlist length
        print('Error: Wordlist has ${words.length} words, expected 2048.');
        return null;
      }
      _wordlist = words;
      return _wordlist;
    } catch (e) {
      // TODO: Handle error - file read error
      print('Error loading wordlist: $e');
      return null;
    }
  }

  String? getWord(int index) {
    if (_wordlist == null || index < 0 || index >= _wordlist!.length) {
      return null;
    }
    return _wordlist![index];
  }

  bool isValidInputNumber(int number) {
    return validInputNumbers.contains(number);
  }
}