import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:yay_thant/config/dataconfig.dart';
import 'package:yay_thant/constants/colors.dart';
import 'package:yay_thant/constants/textstyle.dart';
import 'package:yay_thant/function_provider.dart';
import 'package:yay_thant/globals.dart';
import 'package:yay_thant/pages/more/change_pw_page.dart';
import 'package:yay_thant/pages/more/languages_page.dart';
import 'package:yay_thant/widgets/custom_avater.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  String appVersionNumber = "";
  String language = '';
  String domain = "";
  String loginType = "";
  Map<String, dynamic> userData = {};
  final _dataConfig = Dataconfig();

  initData() {
    userData = _dataConfig.getCurrentUserData();
  }

  Future<void> _getAppVersion() async {
    appVersionNumber = await getAppVersion();
    setState(() {});
  }

  @override
  void initState() {
    _getAppVersion();
    initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // header
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.15,
          ),
          CustomAvater(
            imageURL: userData["avatar"] == "" ? null : userData["avatar"],
            name: userData["name"].toString(),
            radius: 100,
            fontSize: 40,
          ),
          const SizedBox(height: 10),
          _buildInfoText(userData["name"], 24, FontWeight.w600),
          const SizedBox(height: 10),
          _buildInfoText(filterUserRole(userData["role"]), 17, FontWeight.w400),
          const SizedBox(height: 10),
          _buildInfoText(userData["phone"], 14, FontWeight.w400),
          // setting
          const SizedBox(height: 20),
          _buildSettingsOptions(context),
          // logout
          const SizedBox(height: 25),
          _buildLogoutButton(context),
          // version
          const SizedBox(height: 30),
          Center(
            child: Text(
              '${'version'.tr()} $appVersionNumber',
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoText(String text, double fontSize, FontWeight fontWeight) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.black,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: 1.2,
        // Use ap priate height factor
        letterSpacing: -0.24,
      ),
    );
  }

  Widget _buildSettingsOptions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('settings'.tr()),
        _buildSettingsCard(context),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: labelTextStyle,
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          // _buildSettingsOption(
          //   context,
          //   'about_us'.tr(),
          //   Icons.info,
          //   () => Navigator.push(
          //     context,
          //     MaterialPageRoute(builder: (context) => const AboutUsPage()),
          //   ),
          // ),
          _buildSettingsOption(
            context,
            'change_psw'.tr(),
            Icons.lock,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ChangePasswordPage()),
            ),
          ),
          _buildSettingsOption(
            context,
            'lang'.tr(),
            Icons.language,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LanguagePage()),
            ),
            trailing: Row(
              children: [
                Text(
                  context.locale.toString() == 'my' ? "မြန်မာ" : "English",
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios,
                    size: 18, color: Color(0xFFD1D5DB)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsOption(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
            trailing ??
                const Icon(Icons.arrow_forward_ios,
                    size: 18, color: Color(0xFFD1D5DB)),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLogoutDialog(context),
      child: Container(
        width: double.infinity,
        height: 48,
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(color: Colors.white),
        alignment: Alignment.center,
        child: Text(
          "logout".tr(),
          style: TextStyle(
            color: primaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.2,
          ),
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Center(
            child: Text(
              'log_out_acc'.tr(),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 19,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "no".tr(),
                style: TextStyle(
                    color: primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                Functionprovider().logout(isExpired: false);
              },
              child: Text(
                "yes".tr(),
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
