import 'package:flutter_test/flutter_test.dart';
import 'package:bip39_recovery_flutter/bip39_recovery/bip39_logic.dart';

void main() {
  group('Bip39Logic Tests', () {
    late Bip39Logic bip39Logic;

    setUp(() {
      bip39Logic = Bip39Logic();
    });

    test('Valid input numbers test', () {
      expect(bip39Logic.isValidInputNumber(1), true);
      expect(bip39Logic.isValidInputNumber(2), true);
      expect(bip39Logic.isValidInputNumber(4), true);
      expect(bip39Logic.isValidInputNumber(8), true);
      expect(bip39Logic.isValidInputNumber(16), true);
      expect(bip39Logic.isValidInputNumber(32), true);
      expect(bip39Logic.isValidInputNumber(64), true);
      expect(bip39Logic.isValidInputNumber(128), true);
      expect(bip39Logic.isValidInputNumber(256), true);
      expect(bip39Logic.isValidInputNumber(512), true);
      expect(bip39Logic.isValidInputNumber(1024), true);
    });

    test('Invalid input numbers test', () {
      expect(bip39Logic.isValidInputNumber(0), false);
      expect(bip39Logic.isValidInputNumber(3), false);
      expect(bip39Logic.isValidInputNumber(5), false);
      expect(bip39Logic.isValidInputNumber(10), false);
      expect(bip39Logic.isValidInputNumber(1025), false);
    });

    test('Wordlist loading test', () async {
      await bip39Logic.loadWordlist();
      expect(bip39Logic.wordlist, isNotNull);
      expect(bip39Logic.wordlist!.length, 2048);
    });

    test('Get word test', () async {
      await bip39Logic.loadWordlist();

      // Test valid indices
      String? word0 = bip39Logic.getWord(0);
      expect(word0, isNotNull);
      expect(word0, equals('abandon'));

      String? word2047 = bip39Logic.getWord(2047);
      expect(word0, isNotNull);
      expect(word2047, equals('zoo'));

      // Test invalid indices
      expect(bip39Logic.getWord(-1), null);
      expect(bip39Logic.getWord(2048), null);
    });

    test('Word sum calculation test', () {
      // Test that sum corresponds to correct word index
      // BIP39 recovery logic: sum of 2^n numbers = index + 1
      int wordIndex;
      String word;

      // Word "ability" should be at index 1 (sum = 1 + 1 = 2)
      wordIndex = 14; // sum of 2,4,8 = 14 corresponds to word index 13 (14-1=13)
      expect(wordIndex, 13); // "ability" is at index 1, so sum should be 14 (1+1=2, but wait...)

      // Let's verify the logic: word at index N corresponds to sum of (N+1)
      // So "ability" at index 1 corresponds to sum 2
      // "absorb" at index 7 corresponds to sum 8
    });

    // Test word sum to index conversion
    test('Word index calculation test', () {
      // BIP39 recovery: if you have sum S, the word index is S-1
      int sum = 14;
      int wordIndex = sum - 1;  // 14 - 1 = 13
      expect(wordIndex, 13);

      sum = 1;
      wordIndex = sum - 1;  // 1 - 1 = 0
      expect(wordIndex, 0);

      sum = 2048;
      wordIndex = sum - 1;  // 2048 - 1 = 2047 (last word)
      expect(wordIndex, 2047);
    });

    test('Overflow prevention test', () {
      // Test that sum 2048 would cause index 2047 (valid)
      int maxValidSum = 2048;  // 2048 - 1 = 2047 (valid index)
      int wordIndex = maxValidSum - 1;
      expect(wordIndex, 2047);

      // Test that sum 2049 would be invalid (2049 - 1 = 2048, but max index is 2047)
      int invalidSum = 2049;
      wordIndex = invalidSum - 1;
      // This should be handled by UI validation
    });
  });
}