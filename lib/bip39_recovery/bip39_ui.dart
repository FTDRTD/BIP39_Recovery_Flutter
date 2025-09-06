import 'package:flutter/material.dart';
import 'package:bip39_recovery_flutter/bip39_recovery/theme.dart';
import 'package:bip39_recovery_flutter/bip39_recovery/bip39_logic.dart';

// TODO: Implement internationalization (i18n)
Map<String, Map<String, String>> languages = {
  "en": {
    "window_title": "Offline BIP39 Mnemonic Recovery Tool",
    "welcome_header": "BIP39 Mnemonic Recovery",
    "select_length_prompt": "Please select the length of your seed phrase:",
    "12_words": "12 Words",
    "18_words": "18 Words",
    "24_words": "24 Words",
    "offline_warning": "This tool is 100% offline. No data is ever sent.",
    "wordlist_file_error_title": "Wordlist File Error",
    "wordlist_not_found": "Wordlist file '{filename}' not found!\n\nPlease ensure it is in the same directory as the script.",
    "wordlist_invalid_length": "The wordlist '{filename}' is invalid.\n\nIt contains {count} words, but it must contain exactly 2048.",
    "file_read_error_title": "File Read Error",
    "file_read_error_message": "An error occurred while reading the file: {error}",
    "recovering_word_title": "Recovering Word {current} of {total}",
    "enter_number_label": "Enter number (e.g., 2, 4, 256):",
    "add_number_button": "Add Number",
    "entered_numbers_label": "Entered Numbers: {numbers}",
    "current_word_label": "Current Word: {status}",
    "status_waiting": "(waiting for input)",
    "status_invalid_index": "[Sum: {sum}] -> INVALID INDEX",
    "status_valid_word": "[Sum: {sum}] -> Index {index} -> '{word}'",
    "confirm_and_next_button": "Confirm Word & Next",
    "recovered_words_header": "Recovered Words so far:",
    "invalid_input_title": "Invalid Input",
    "invalid_input_int_warning": "Please enter a valid whole number.",
    "invalid_input_power_of_2_warning": "Please enter a valid power of 2 (1, 2, 4, ..., 1024).",
    "duplicate_input_warning": "The number {num} has already been added for this word.",
    "no_input_title": "No Input",
    "no_input_warning": "Please add at least one number for this word.",
    "sum_error_title": "Error",
    "sum_error_message": "The sum of the numbers is invalid and does not correspond to a valid word.",
    "recovery_complete_header": "Recovery Successful!",
    "your_seed_phrase_is": "Your recovered BIP39 seed phrase is:",
    "security_note": "SECURITY NOTE: Please close this window after you have secured your phrase.",
    "restart_button": "Restart",
    "quit_button": "Quit",
  },
  "zh": {
    "window_title": "离线BIP39助记词恢复工具",
    "welcome_header": "BIP39 助记词恢复",
    "select_length_prompt": "请选择您的助记词短语长度：",
    "12_words": "12个单词",
    "18_words": "18个单词",
    "24_words": "24个单词",
    "offline_warning": "本工具为100%离线工具，绝不发送任何数据。",
    "wordlist_file_error_title": "词库文件错误",
    "wordlist_not_found": "词库文件 '{filename}' 未找到！\n\n请确保该文件与脚本在同一目录下。",
    "wordlist_invalid_length": "词库文件 '{filename}' 无效。\n\n它包含 {count} 个单词，但必须是2048个。",
    "file_read_error_title": "文件读取错误",
    "file_read_error_message": "读取文件时发生错误: {error}",
    "recovering_word_title": "正在恢复第 {current} / {total} 个单词",
    "enter_number_label": "输入数字 (例如 2, 4, 256):",
    "add_number_button": "添加数字",
    "entered_numbers_label": "已输入的数字: {numbers}",
    "current_word_label": "当前单词: {status}",
    "status_waiting": "(等待输入)",
    "status_invalid_index": "[总和: {sum}] -> 无效索引",
    "status_valid_word": "[总和: {sum}] -> 索引 {index} -> '{word}'",
    "confirm_and_next_button": "确认单词并继续",
    "recovered_words_header": "已恢复的单词:",
    "invalid_input_title": "无效输入",
    "invalid_input_int_warning": "请输入一个有效的整数。",
    "invalid_input_power_of_2_warning": "请输入一个有效的2的幂（1, 2, 4, ..., 1024）。",
    "duplicate_input_warning": "数字 {num} 已经为这个单词添加过了。",
    "no_input_title": "没有输入",
    "no_input_warning": "请至少为这个单词添加一个数字。",
    "sum_error_title": "错误",
    "sum_error_message": "数字总和无效，无法对应到一个有效的单词。",
    "recovery_complete_header": "恢复成功！",
    "your_seed_phrase_is": "您恢复的BIP39助记词短语是：",
    "security_note": "【安全提示】在您安全备份好助记词后，请关闭本窗口。",
    "restart_button": "重新开始",
    "quit_button": "退出",
  },
};

class Bip39RecoveryScreen extends StatefulWidget {
  const Bip39RecoveryScreen({super.key});

  @override
  State<Bip39RecoveryScreen> createState() => _Bip39RecoveryScreenState();
}

class _Bip39RecoveryScreenState extends State<Bip39RecoveryScreen> {
  final Bip39Logic _bip39Logic = Bip39Logic();
  String _currentLang = "zh"; // Default language
  late Function(String) T;

  int _mnemonicLength = 0;
  int _currentWordIndex = 0;
  List<String> _recoveredWords = [];
  int _currentWordSum = 0;
  List<int> _currentWordInputs = [];
  final PageController _pageController = PageController();
  final TextEditingController _numberEntryController = TextEditingController();
  final FocusNode _numberEntryFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeLanguage();
    _bip39Logic.loadWordlist().then((_) {
      if (_bip39Logic.wordlist == null) {
        // Handle wordlist loading error, e.g., show an alert
        _showMessage(
          'Error',
          languages['en']!['wordlist_file_error_title']!,
          languages['en']!['wordlist_not_found']!.replaceFirst('{filename}', Bip39Logic.wordlistPath),
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _numberEntryController.dispose();
    _numberEntryFocus.dispose();
    super.dispose();
  }

  void _initializeLanguage() {
    T = (key) => languages[_currentLang]![key] ?? key;
  }

  void _setLanguage(String langCode) {
    setState(() {
      _currentLang = langCode;
      _initializeLanguage();
    });
  }

  void _showMessage(String level, String title, String message) {
    // TODO: Implement a proper Flutter dialog for messages
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: level == 'error' ? AppTheme.danger : AppTheme.primary,
      ),
    );
  }

  Widget _buildPageLayout({required Widget child}) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 550),
        padding: const EdgeInsets.all(20.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLanguageSwitcher(),
                const SizedBox(height: 20),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSwitcher() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.border),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              _buildLangButton("English", "en"),
              _buildLangButton("中文", "zh"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLangButton(String text, String langCode) {
    bool isActive = _currentLang == langCode;
    return TextButton(
      onPressed: () => _setLanguage(langCode),
      style: TextButton.styleFrom(
        backgroundColor: isActive ? AppTheme.primary : AppTheme.contentBackground,
        foregroundColor: isActive ? Colors.white : AppTheme.text,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        minimumSize: const Size(0, 28),
      ),
      child: Text(text, style: TextStyle(fontSize: 13)),
    );
  }

  void _startRecovery(int length) {
    setState(() {
      _mnemonicLength = length;
      _currentWordIndex = 0;
      _recoveredWords = [];
      _resetCurrentWord();
    });
    _pageController.jumpToPage(1); // Navigate to recovery page
    // 聚焦到输入框以开始输入
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _numberEntryFocus.requestFocus();
    });
  }

  void _resetCurrentWord() {
    _currentWordSum = 0;
    _currentWordInputs = [];
    _numberEntryController.clear();
    // 重新聚焦输入框，改善连续输入体验
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _numberEntryFocus.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(T("window_title")),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe
        children: [
          _buildWelcomePage(),
          _buildRecoveryPage(),
          _buildResultPage(),
        ],
      ),
    );
  }

  Widget _buildWelcomePage() {
    return _buildPageLayout(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            T("welcome_header"),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: AppTheme.text,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            T("select_length_prompt"),
            style: const TextStyle(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          _buildLengthButton(T("12_words"), 12),
          const SizedBox(height: 10),
          _buildLengthButton(T("18_words"), 18),
          const SizedBox(height: 10),
          _buildLengthButton(T("24_words"), 24),
          const SizedBox(height: 40),
          Text(
            T("offline_warning"),
            style: const TextStyle(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLengthButton(String text, int length) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _startRecovery(length),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 40),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          backgroundColor: AppTheme.contentBackground,
          foregroundColor: AppTheme.text,
          side: const BorderSide(color: AppTheme.border),
        ),
        child: Text(text),
      ),
    );
  }

  Widget _buildRecoveryPage() {
    return _buildPageLayout(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            T("recovering_word_title").replaceFirst('{current}', (_currentWordIndex + 1).toString()).replaceFirst('{total}', _mnemonicLength.toString()),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: AppTheme.text,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _numberEntryController,
                  focusNode: _numberEntryFocus,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: T("enter_number_label"),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppTheme.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppTheme.primary),
                    ),
                  ),
                  onSubmitted: (_) => _addNumber(),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _addNumber,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: Text(T("add_number_button")),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            T("entered_numbers_label").replaceFirst('{numbers}', _currentWordInputs.map((e) => e.toString()).join(', ')),
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 10),
          Text(
            T("current_word_label").replaceFirst('{status}', _getCurrentWordStatus()),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.success,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _processNextWord,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: Text(T("confirm_and_next_button")),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            T("recovered_words_header"),
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 5),
          Container(
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.border),
              borderRadius: BorderRadius.circular(6),
              color: AppTheme.contentBackground,
            ),
            padding: const EdgeInsets.all(8),
            child: SingleChildScrollView(
              child: Text(
                _recoveredWords.join(' '),
                style: const TextStyle(fontFamily: 'Courier New, monospace'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrentWordStatus() {
    if (_currentWordSum == 0) {
      return T("status_waiting");
    }
    int wordIndex = _currentWordSum - 1;
    if (_bip39Logic.wordlist != null && wordIndex >= 0 && wordIndex < _bip39Logic.wordlist!.length) {
      String word = _bip39Logic.wordlist![wordIndex];
      return T("status_valid_word").replaceFirst('{sum}', _currentWordSum.toString()).replaceFirst('{index}', (wordIndex + 1).toString()).replaceFirst('{word}', word);
    } else {
      return T("status_invalid_index").replaceFirst('{sum}', _currentWordSum.toString());
    }
  }

  void _addNumber() {
    String numStr = _numberEntryController.text.trim();
    if (numStr.isEmpty) {
      return;
    }
    try {
      int num = int.parse(numStr);
      if (!_bip39Logic.isValidInputNumber(num)) {
        _showMessage(
          'warning',
          T("invalid_input_title"),
          T("invalid_input_power_of_2_warning"),
        );
      } else if (_currentWordInputs.contains(num) && num != 1) {
        _showMessage(
          'warning',
          T("invalid_input_title"),
          T("duplicate_input_warning").replaceFirst('{num}', num.toString()),
        );
      } else if (_currentWordInputs.where((n) => n == 1).length >= 3) {
        _showMessage(
          'warning',
          T("invalid_input_title"),
          "数字1最多只能重复两次。",
        );
      } else {
        setState(() {
          _currentWordInputs.add(num);
          _currentWordInputs.sort(); // Keep inputs sorted for display
          _currentWordSum += num;
        });
        // 重新聚焦以保持连续输入的便利性
        _numberEntryFocus.requestFocus();
      }
    } on FormatException {
      _showMessage(
        'warning',
        T("invalid_input_title"),
        T("invalid_input_int_warning"),
      );
    } finally {
      _numberEntryController.clear();
    }
  }

  void _processNextWord() {
    if (_currentWordInputs.isEmpty) {
      _showMessage('warning', T("no_input_title"), T("no_input_warning"));
      return;
    }

    int wordIndex = _currentWordSum - 1;
    if (_bip39Logic.wordlist != null && wordIndex >= 0 && wordIndex < _bip39Logic.wordlist!.length) {
      String word = _bip39Logic.wordlist![wordIndex];
      setState(() {
        _recoveredWords.add(word);
        _currentWordIndex++;
      });

      if (_currentWordIndex >= _mnemonicLength) {
        _showFinalResult();
      } else {
        _resetCurrentWord();
      }
    } else {
      _showMessage('error', T("sum_error_title"), T("sum_error_message"));
    }
  }

  void _showFinalResult() {
    // Navigate to result page
    _pageController.jumpToPage(2);
  }

  Widget _buildResultPage() {
    return _buildPageLayout(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            T("recovery_complete_header"),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: AppTheme.text,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            T("your_seed_phrase_is"),
            style: const TextStyle(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.border),
              borderRadius: BorderRadius.circular(6),
              color: AppTheme.contentBackground,
            ),
            padding: const EdgeInsets.all(8),
            child: SingleChildScrollView(
              child: Text(
                _recoveredWords.join(' '),
                style: const TextStyle(fontFamily: 'Courier New, monospace', fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.success),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            T("security_note"),
            style: const TextStyle(
              color: AppTheme.danger,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _pageController.jumpToPage(0);
                setState(() {
                  _mnemonicLength = 0;
                  _currentWordIndex = 0;
                  _recoveredWords = [];
                  _resetCurrentWord();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: Text(T("restart_button")),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(), // Or exit the app
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondary,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: Text(T("quit_button")),
            ),
          ),
        ],
      ),
    );
  }
}