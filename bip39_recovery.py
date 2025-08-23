# -*- coding: utf-8 -*-
"""
BIP39 Mnemonic Recovery Tool (Offline)

A PySide6-based graphical user interface application that helps users recover
their BIP39 mnemonic seed phrase in a 100% offline environment. The user
reconstructs each word by inputting a series of powers of 2 (corresponding
to the word's index in the BIP39 wordlist), ensuring the full seed phrase
is never typed or stored in one piece until the final recovery.

The application supports multiple languages (English, Chinese) and seed
phrase lengths (12, 18, 24 words).
"""

import os
import sys
from typing import List, Optional, Dict, Any, Set

# --- Import PySide6 components ---
from PySide6.QtWidgets import (
    QApplication,
    QMainWindow,
    QWidget,
    QVBoxLayout,
    QHBoxLayout,
    QPushButton,
    QLabel,
    QLineEdit,
    QTextEdit,
    QStackedWidget,
    QMessageBox,
    QFrame,
)
from PySide6.QtGui import QFont
from PySide6.QtCore import Qt

# --- 词典：用于国际化 (i18n) ---
LANGUAGES: Dict[str, Dict[str, str]] = {
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
}

# --- 配置和常量 ---
WORDLIST_FILE: str = "english.txt"
VALID_INPUT_NUMBERS: Set[int] = {2**i for i in range(11)}  # {1, 2, 4, ..., 1024}

# --- 主题调色板 ---
Theme: Dict[str, str] = {
    "BACKGROUND": "#F5F5F5",
    "CONTENT_BACKGROUND": "#FFFFFF",
    "PRIMARY": "#007BFF",
    "PRIMARY_HOVER": "#0056b3",
    "SECONDARY": "#6c757d",
    "SECONDARY_HOVER": "#545b62",
    "SUCCESS": "#28a745",
    "DANGER": "#dc3545",
    "TEXT": "#333333",
    "TEXT_SECONDARY": "#666666",
    "BORDER": "#DEE2E6",
}


# --- 资源路径函数 ---
def get_resource_path(relative_path: str) -> str:
    """
    获取资源文件的绝对路径，以兼容PyInstaller/Nuitka打包后的情况。

    Args:
        relative_path (str): 资源的相对路径。

    Returns:
        str: 资源的绝对路径。
    """
    if hasattr(sys, "_MEIPASS"):
        # 打包后运行
        return os.path.join(sys._MEIPASS, relative_path)
    try:
        # 正常脚本运行
        base_path = os.path.dirname(os.path.abspath(__file__))
    except NameError:
        # 在某些IDE的交互式环境中运行
        base_path = os.path.abspath(".")
    return os.path.join(base_path, relative_path)


class BIP39RecoveryApp(QMainWindow):
    """
    BIP39助记词恢复工具的主应用窗口类。
    管理UI状态、页面切换和恢复逻辑。
    """

    def __init__(self) -> None:
        """初始化应用程序"""
        super().__init__()
        self.wordlist: Optional[List[str]] = self.load_wordlist()
        if not self.wordlist:
            # 如果词库加载失败，则无法继续
            sys.exit(1)

        # --- 状态变量 ---
        self.mnemonic_length: int = 0
        self.current_word_index: int = 0
        self.recovered_words: List[str] = []
        self.current_word_sum: int = 0
        self.current_word_inputs: List[int] = []
        self.current_lang: str = "zh"
        self.T = lambda key: LANGUAGES[self.current_lang].get(key, key)

        # --- 窗口和UI设置 ---
        self.setFixedSize(700, 650)
        self.setup_styles()

        self.stacked_widget = QStackedWidget()
        self.setCentralWidget(self.stacked_widget)

        # --- 页面定义 ---
        self.welcome_widget = QWidget()
        self.recovery_widget = QWidget()
        self.result_widget = QWidget()

        self.create_welcome_page()
        self.create_recovery_page()
        self.create_result_page()

        self.stacked_widget.addWidget(self.welcome_widget)
        self.stacked_widget.addWidget(self.recovery_widget)
        self.stacked_widget.addWidget(self.result_widget)

        self.update_ui_text()

    def show_message(self, level: str, title: str, message: str) -> None:
        """
        显示一个模式对话框消息。

        Args:
            level (str): 消息级别 ('error', 'warning', 'info').
            title (str): 对话框标题。
            message (str): 要显示的消息内容。
        """
        box = QMessageBox(self)
        box.setWindowTitle(title)
        box.setText(message)
        icon = {
            "error": QMessageBox.Icon.Critical,
            "warning": QMessageBox.Icon.Warning,
        }.get(level, QMessageBox.Icon.Information)
        box.setIcon(icon)
        box.exec()

    def load_wordlist(self) -> Optional[List[str]]:
        """
        从文件中加载BIP39词库。

        Returns:
            Optional[List[str]]: 如果成功，返回包含2048个单词的列表；否则返回None。
        """
        wordlist_path = get_resource_path(WORDLIST_FILE)
        if not os.path.exists(wordlist_path):
            self.show_message(
                "error",
                LANGUAGES["en"]["wordlist_file_error_title"],
                LANGUAGES["en"]["wordlist_not_found"].format(filename=WORDLIST_FILE),
            )
            return None
        try:
            with open(wordlist_path, "r", encoding="utf-8") as f:
                words = [line.strip() for line in f if line.strip()]
            if len(words) != 2048:
                self.show_message(
                    "error",
                    LANGUAGES["en"]["wordlist_file_error_title"],
                    LANGUAGES["en"]["wordlist_invalid_length"].format(
                        filename=WORDLIST_FILE, count=len(words)
                    ),
                )
                return None
            return words
        except Exception as e:
            self.show_message(
                "error",
                LANGUAGES["en"]["file_read_error_title"],
                LANGUAGES["en"]["file_read_error_message"].format(error=e),
            )
            return None

    def setup_styles(self) -> None:
        """应用全局Qt样式表 (QSS) 来美化UI。"""
        self.setStyleSheet(f"""
            QMainWindow, QWidget {{
                background-color: {Theme["BACKGROUND"]};
                font-family: 'Segoe UI', 'Microsoft YaHei', 'Helvetica';
                font-size: 14px;
            }}
            QFrame#Card {{
                background-color: {Theme["CONTENT_BACKGROUND"]};
                border-radius: 8px;
                border: 1px solid {Theme["BORDER"]};
            }}
            QLabel {{
                color: {Theme["TEXT"]};
            }}
            QLabel#HeaderLabel {{
                font-size: 26px;
                font-weight: 600;
                color: {Theme["TEXT"]};
            }}
            QLabel#PromptLabel {{
                color: {Theme["TEXT_SECONDARY"]};
            }}
            QLabel#ResultLabel {{
                font-family: 'Courier New', 'monospace';
                font-size: 18px;
                font-weight: bold;
                color: {Theme["SUCCESS"]};
            }}
            QLabel#ErrorLabel {{
                color: {Theme["DANGER"]};
                font-weight: 500;
            }}
            QPushButton {{
                min-height: 40px;
                font-size: 15px;
                font-weight: 500;
                border-radius: 6px;
                border: 1px solid {Theme["BORDER"]};
                background-color: {Theme["CONTENT_BACKGROUND"]};
            }}
            QPushButton:hover {{
                background-color: #f8f9fa;
            }}
            QPushButton#PrimaryButton {{
                background-color: {Theme["PRIMARY"]};
                color: white;
                border: none;
            }}
            QPushButton#PrimaryButton:hover {{
                background-color: {Theme["PRIMARY_HOVER"]};
            }}
            QPushButton#QuitButton {{
                background-color: {Theme["SECONDARY"]};
                color: white;
                border: none;
            }}
            QPushButton#QuitButton:hover {{
                background-color: {Theme["SECONDARY_HOVER"]};
            }}
            QLineEdit, QTextEdit {{
                border: 1px solid {Theme["BORDER"]};
                border-radius: 6px;
                padding: 8px;
                font-size: 14px;
                background-color: #FFFFFF;
            }}
            QLineEdit:focus, QTextEdit:focus {{
                border-color: {Theme["PRIMARY"]};
            }}
            QTextEdit {{
                font-family: 'Courier New', monospace;
            }}
            QFrame#LangSwitcher {{
                border: 1px solid {Theme["BORDER"]};
                border-radius: 6px;
            }}
            QPushButton#LangButton {{
                border: none;
                min-height: 28px;
                font-size: 13px;
                padding: 5px 15px;
            }}
            QPushButton#LangButton[active="true"] {{
                background-color: {Theme["PRIMARY"]};
                color: white;
            }}
        """)

    def create_page_layout(self, parent_widget: QWidget) -> QVBoxLayout:
        """
        创建一个标准的页面布局模板，包含语言切换器和居中的卡片。

        Args:
            parent_widget (QWidget): 此布局所属的父级控件。

        Returns:
            QVBoxLayout: 用于在卡片内部添加具体控件的布局。
        """
        page_layout = QVBoxLayout(parent_widget)
        page_layout.setContentsMargins(0, 10, 0, 10)

        # --- 语言切换器 ---
        lang_switcher_layout = QHBoxLayout()
        lang_switcher_layout.addStretch()
        lang_switcher_frame = QFrame()
        lang_switcher_frame.setObjectName("LangSwitcher")
        lang_switcher_hbox = QHBoxLayout(lang_switcher_frame)
        lang_switcher_hbox.setContentsMargins(0, 0, 0, 0)
        lang_switcher_hbox.setSpacing(0)

        self.en_button = QPushButton("English")
        self.en_button.setObjectName("LangButton")
        self.en_button.setProperty("active", self.current_lang == "en")
        self.en_button.clicked.connect(lambda: self.set_language("en"))
        lang_switcher_hbox.addWidget(self.en_button)

        self.zh_button = QPushButton("中文")
        self.zh_button.setObjectName("LangButton")
        self.zh_button.setProperty("active", self.current_lang == "zh")
        self.zh_button.clicked.connect(lambda: self.set_language("zh"))
        lang_switcher_hbox.addWidget(self.zh_button)

        lang_switcher_layout.addWidget(lang_switcher_frame)
        lang_switcher_layout.addSpacing(20)
        page_layout.addLayout(lang_switcher_layout)

        # --- 居中卡片布局 ---
        centered_layout = QHBoxLayout()
        centered_layout.addStretch()
        card_frame = QFrame()
        card_frame.setObjectName("Card")
        card_frame.setFixedWidth(550)
        card_layout = QVBoxLayout(card_frame)
        card_layout.setContentsMargins(40, 40, 40, 40)
        card_layout.setSpacing(20)
        centered_layout.addWidget(card_frame)
        centered_layout.addStretch()

        page_layout.addStretch(1)
        page_layout.addLayout(centered_layout)
        page_layout.addStretch(2)

        return card_layout

    def create_welcome_page(self) -> None:
        """创建欢迎页面，让用户选择助记词长度。"""
        layout = self.create_page_layout(self.welcome_widget)

        self.welcome_header = QLabel()
        self.welcome_header.setObjectName("HeaderLabel")
        self.welcome_header.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(self.welcome_header)

        self.select_prompt = QLabel()
        self.select_prompt.setObjectName("PromptLabel")
        self.select_prompt.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(self.select_prompt)
        layout.addSpacing(20)

        self.button12 = QPushButton()
        self.button12.clicked.connect(lambda: self.start_recovery(12))
        layout.addWidget(self.button12)

        self.button18 = QPushButton()
        self.button18.clicked.connect(lambda: self.start_recovery(18))
        layout.addWidget(self.button18)

        self.button24 = QPushButton()
        self.button24.clicked.connect(lambda: self.start_recovery(24))
        layout.addWidget(self.button24)

        layout.addStretch()

        self.offline_warning = QLabel()
        self.offline_warning.setObjectName("PromptLabel")
        self.offline_warning.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(self.offline_warning)

    def create_recovery_page(self) -> None:
        """创建单词恢复页面，包含输入、状态显示和已恢复单词列表。"""
        layout = self.create_page_layout(self.recovery_widget)

        self.recovery_title_label = QLabel()
        self.recovery_title_label.setObjectName("HeaderLabel")
        layout.addWidget(self.recovery_title_label)

        input_layout = QHBoxLayout()
        self.enter_num_label = QLabel()
        input_layout.addWidget(self.enter_num_label)
        self.number_entry = QLineEdit()
        self.number_entry.setFixedWidth(120)
        self.number_entry.returnPressed.connect(self.add_number)
        input_layout.addWidget(self.number_entry)
        self.add_button = QPushButton()
        self.add_button.setObjectName("PrimaryButton")
        self.add_button.clicked.connect(self.add_number)
        input_layout.addWidget(self.add_button)
        input_layout.addStretch()
        layout.addLayout(input_layout)

        self.current_inputs_label = QLabel()
        self.current_inputs_label.setWordWrap(True)
        layout.addWidget(self.current_inputs_label)

        self.current_word_label = QLabel()
        self.current_word_label.setObjectName("ResultLabel")
        layout.addWidget(self.current_word_label)

        self.next_word_button = QPushButton()
        self.next_word_button.setObjectName("PrimaryButton")
        self.next_word_button.clicked.connect(self.process_next_word)
        layout.addWidget(self.next_word_button)

        layout.addSpacing(15)

        self.recovered_words_header_label = QLabel()
        self.recovered_words_header_label.setObjectName("PromptLabel")
        layout.addWidget(self.recovered_words_header_label)

        self.recovered_words_display = QTextEdit()
        self.recovered_words_display.setReadOnly(True)
        self.recovered_words_display.setFixedHeight(80)
        layout.addWidget(self.recovered_words_display)

    def create_result_page(self) -> None:
        """创建最终结果页面，显示完整的助记词。"""
        layout = self.create_page_layout(self.result_widget)

        self.result_header = QLabel()
        self.result_header.setObjectName("HeaderLabel")
        self.result_header.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(self.result_header)

        self.result_prompt = QLabel()
        self.result_prompt.setObjectName("PromptLabel")
        self.result_prompt.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(self.result_prompt)

        self.result_text = QTextEdit()
        self.result_text.setReadOnly(True)
        self.result_text.setFixedHeight(120)
        layout.addWidget(self.result_text)

        self.security_note = QLabel()
        self.security_note.setObjectName("ErrorLabel")
        self.security_note.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(self.security_note)

        layout.addSpacing(20)

        self.restart_button = QPushButton()
        self.restart_button.setObjectName("PrimaryButton")
        self.restart_button.clicked.connect(
            lambda: self.stacked_widget.setCurrentWidget(self.welcome_widget)
        )
        layout.addWidget(self.restart_button)

        self.quit_button = QPushButton()
        self.quit_button.setObjectName("QuitButton")
        self.quit_button.clicked.connect(self.close)
        layout.addWidget(self.quit_button)

    def set_language(self, lang_code: str) -> None:
        """
        设置并应用新的界面语言。

        Args:
            lang_code (str): 语言代码 ('en' 或 'zh')。
        """
        self.current_lang = lang_code
        self.T = lambda key: LANGUAGES[self.current_lang].get(key, key)
        self.en_button.setProperty("active", lang_code == "en")
        self.zh_button.setProperty("active", lang_code == "zh")
        # 刷新样式以应用active状态
        for btn in [self.en_button, self.zh_button]:
            self.style().unpolish(btn)
            self.style().polish(btn)
        self.update_ui_text()

    def update_ui_text(self) -> None:
        """根据当前语言更新所有界面上的文本。"""
        self.setWindowTitle(self.T("window_title"))
        # 欢迎页面
        self.welcome_header.setText(self.T("welcome_header"))
        self.select_prompt.setText(self.T("select_length_prompt"))
        self.button12.setText(self.T("12_words"))
        self.button18.setText(self.T("18_words"))
        self.button24.setText(self.T("24_words"))
        self.offline_warning.setText(self.T("offline_warning"))
        # 恢复页面
        self.enter_num_label.setText(self.T("enter_number_label"))
        self.add_button.setText(self.T("add_number_button"))
        self.next_word_button.setText(self.T("confirm_and_next_button"))
        self.recovered_words_header_label.setText(self.T("recovered_words_header"))
        self.update_recovery_display()  # 更新动态文本
        # 结果页面
        self.result_header.setText(self.T("recovery_complete_header"))
        self.result_prompt.setText(self.T("your_seed_phrase_is"))
        self.security_note.setText(self.T("security_note"))
        self.restart_button.setText(self.T("restart_button"))
        self.quit_button.setText(self.T("quit_button"))

    def start_recovery(self, length: int) -> None:
        """
        开始一个新的恢复流程。

        Args:
            length (int): 助记词的长度 (12, 18, or 24)。
        """
        self.mnemonic_length = length
        self.current_word_index = 0
        self.recovered_words = []
        self.reset_current_word()
        self.update_recovery_display()
        self.stacked_widget.setCurrentWidget(self.recovery_widget)
        self.number_entry.setFocus()

    def add_number(self) -> None:
        """处理用户输入的数字，并将其添加到当前单词的计算中。"""
        try:
            num_str = self.number_entry.text().strip()
            if not num_str:
                return
            num = int(num_str)

            if num not in VALID_INPUT_NUMBERS:
                self.show_message(
                    "warning",
                    self.T("invalid_input_title"),
                    self.T("invalid_input_power_of_2_warning"),
                )
            elif num in self.current_word_inputs:
                self.show_message(
                    "warning",
                    self.T("invalid_input_title"),
                    self.T("duplicate_input_warning").format(num=num),
                )
            else:
                self.current_word_inputs.append(num)
                self.current_word_sum += num
                self.update_recovery_display()
        except ValueError:
            self.show_message(
                "warning",
                self.T("invalid_input_title"),
                self.T("invalid_input_int_warning"),
            )
        finally:
            self.number_entry.clear()

    def process_next_word(self) -> None:
        """确认当前单词并进入下一个单词的恢复流程。"""
        if not self.current_word_inputs:
            self.show_message(
                "warning", self.T("no_input_title"), self.T("no_input_warning")
            )
            return

        word_index = self.current_word_sum - 1
        if self.wordlist and 0 <= word_index < len(self.wordlist):
            word = self.wordlist[word_index]
            self.recovered_words.append(word)
            self.current_word_index += 1

            if self.current_word_index >= self.mnemonic_length:
                self.show_final_result()
            else:
                self.reset_current_word()
                self.update_recovery_display()
                self.number_entry.setFocus()
        else:
            self.show_message(
                "error", self.T("sum_error_title"), self.T("sum_error_message")
            )

    def reset_current_word(self) -> None:
        """重置用于计算当前单词的状态变量。"""
        self.current_word_sum = 0
        self.current_word_inputs = []
        if hasattr(self, "number_entry"):
            self.number_entry.clear()

    def update_recovery_display(self) -> None:
        """更新恢复页面上的所有动态文本标签。"""
        if not hasattr(self, "recovery_title_label"):
            return  # UI尚未创建

        title_text = self.T("recovering_word_title").format(
            current=self.current_word_index + 1, total=self.mnemonic_length
        )
        self.recovery_title_label.setText(title_text)

        inputs_str = ", ".join(map(str, sorted(self.current_word_inputs)))
        self.current_inputs_label.setText(
            self.T("entered_numbers_label").format(numbers=inputs_str)
        )

        status_text = ""
        if self.current_word_sum > 0:
            word_index = self.current_word_sum - 1
            if self.wordlist and 0 <= word_index < len(self.wordlist):
                word = self.wordlist[word_index]
                status_text = self.T("status_valid_word").format(
                    sum=self.current_word_sum, index=word_index + 1, word=word
                )
            else:
                status_text = self.T("status_invalid_index").format(
                    sum=self.current_word_sum
                )
        else:
            status_text = self.T("status_waiting")
        self.current_word_label.setText(
            self.T("current_word_label").format(status=status_text)
        )

        self.recovered_words_display.setPlainText(" ".join(self.recovered_words))

    def show_final_result(self) -> None:
        """显示最终恢复的助记词短语。"""
        final_phrase = " ".join(self.recovered_words)
        self.result_text.setPlainText(final_phrase)
        self.stacked_widget.setCurrentWidget(self.result_widget)


if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = BIP39RecoveryApp()
    window.show()
    sys.exit(app.exec())
