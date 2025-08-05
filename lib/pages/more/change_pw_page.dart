import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:yay_thant/api/api.dart';
import 'package:yay_thant/function_provider.dart';
import 'package:yay_thant/widgets/custom_appbar.dart';
import 'package:yay_thant/widgets/custom_button.dart';
import 'package:yay_thant/widgets/custom_textfield.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool currentObsecureText = true;
  bool newObsecureText = true;
  bool confirmObsecureText = true;
  bool isLoading = false;

  void updatePassword() async {
    isLoading = true;
    setState(() {});
    var param = jsonEncode({
      "oldPassword": _currentPasswordController.text,
      "newPassword": _newPasswordController.text
    });
    final success = await API().changePassword(param);
    if (success) {
      Navigator.pop(context);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        title: "change_psw",
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
            ),
            CustomTextfieldWithLabel(
              controller: _currentPasswordController,
              hintText: '',
              prefixIcon: null,
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    currentObsecureText = !currentObsecureText;
                  });
                },
                child: Icon(
                  currentObsecureText ? Icons.visibility : Icons.visibility_off,
                  size: 20,
                ),
              ),
              obscureText: currentObsecureText,
              onChanged: (value) {},
              onSubmitted: (value) {},
              label: "current_psw",
            ),
            CustomTextfieldWithLabel(
              controller: _newPasswordController,
              hintText: '',
              prefixIcon: null,
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    newObsecureText = !newObsecureText;
                  });
                },
                child: Icon(
                  newObsecureText ? Icons.visibility : Icons.visibility_off,
                  size: 20,
                ),
              ),
              obscureText: newObsecureText,
              onChanged: (value) {},
              onSubmitted: (value) {},
              label: "new_psw",
            ),
            CustomTextfieldWithLabel(
              controller: _confirmPasswordController,
              hintText: '',
              prefixIcon: null,
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    confirmObsecureText = !confirmObsecureText;
                  });
                },
                child: Icon(
                  confirmObsecureText ? Icons.visibility : Icons.visibility_off,
                  size: 20,
                ),
              ),
              obscureText: confirmObsecureText,
              onChanged: (value) {},
              onSubmitted: (value) {},
              label: "confirm_psw",
            ),
            CustomButton(
              buttonText: "confirm_txt",
              isLoading: isLoading,
              onTap: () async {
                Functionprovider().checkInternetConnection().then((result) {
                  if (result) {
                    updatePassword();
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
