import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:yay_thant/constants/colors.dart';
import 'package:yay_thant/widgets/custom_appbar.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key,});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    // Initialize the selected language based on the current locale
    _initializeSelectedLanguage(context);

    return Scaffold(
      appBar: customAppBar(
        title: "languages", 
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            size: 20,
            color: Color(0xFF1D1F1F),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: PopScope(
        canPop: false,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 15),
          children: [
            _buildLanguageOption('English'),
            _buildLanguageOption('မြန်မာ'),
          ],
        ),
      ),
    );
  }

  // Build language selection option
  Widget _buildLanguageOption(String language) {
    final isSelected = _selectedLanguage == language;

    return GestureDetector(
      onTap: () => _selectLanguage(language),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              language,
              style: TextStyle(
                color: isSelected
                    ? primaryColor
                    : Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                color: primaryColor,
              ),
          ],
        ),
      ),
    );
  }

  // Initialize the selected language based on the current locale
  void _initializeSelectedLanguage(BuildContext context) {
    final localeString = context.locale.toString();
    if (localeString == 'my') {
      _selectedLanguage = "မြန်မာ";
    } else {
      _selectedLanguage = "English";
    }
  }

  // Handle language selection
  void _selectLanguage(String language) async {
    setState(() {
      _selectedLanguage = language;
    });

    final newLocale = _getLocaleFromLanguage(language);
    if (newLocale != null) {
      context.setLocale(newLocale);
      // Force a rebuild to apply the new locale immediately
      WidgetsBinding.instance.performReassemble();
    }
  }

  // Get the locale from the language string
  Locale? _getLocaleFromLanguage(String language) {
    switch (language) {
      case 'English':
        return const Locale('en');
      case 'မြန်မာ':
        return const Locale('my');
      default:
        return null;
    }
  }

}
