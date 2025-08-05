import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:yay_thant/api/api.dart';
import 'package:yay_thant/constants/constant_variables.dart';
import 'package:yay_thant/function_provider.dart';
import 'package:yay_thant/pages/Tab/tabs_page.dart';
import 'package:yay_thant/widgets/custom_button.dart';
import 'package:yay_thant/widgets/custom_textfield.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordObscureText = true;
  final _api = API();
  bool _isLoading = false;

  _login() async {
    _isLoading = true;
    var body = {
      "phone": _phoneController.text,
      "password": _passwordController.text,
    };
    setState(() {});
    final success = await _api.login(jsonEncode(body));
    setState(() {
      _isLoading = false;
      if (success == true) {
        currentUserData = dataconfig.getCurrentUserData();
        print("user role >> ${currentUserData["role"]}");
        if (currentUserData["role"] == 0) {
          setState(() {
            isDeliveryMan = true;
          });
        } else {
          setState(() {
            isDeliveryMan = false;
          });
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TabsPage(
              currentIndex: 1,
              tabsList: isDeliveryMan ? tabsListForDeli : tabsListForMgr,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight(context) * 0.1),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.35,
                      width: MediaQuery.of(context).size.height * 0.35,
                      child: Image.asset(
                        "assets/images/YayD_logo.png",
                        scale: 2,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  CustomTextfieldWithLabel(
                    controller: _phoneController,
                    hintText: "",
                    label: "ph",
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    labelMargin: EdgeInsets.symmetric(horizontal: 20),
                    prefixIcon: null,
                    suffixIcon: null,
                    obscureText: false,
                    onChanged: (value) {},
                    onSubmitted: (value) {},
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  CustomTextfieldWithLabel(
                    controller: _passwordController,
                    hintText: '',
                    label: "psw",
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    labelMargin: EdgeInsets.symmetric(horizontal: 20),
                    prefixIcon: null,
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _passwordObscureText = !_passwordObscureText;
                        });
                      },
                      child: Icon(
                        _passwordObscureText
                            ? Icons.visibility
                            : Icons.visibility_off,
                        size: 20,
                      ),
                    ),
                    obscureText: _passwordObscureText,
                    onChanged: (value) {},
                    onSubmitted: (value) {},
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: CustomButton(
                      buttonText: 'login',
                      isLoading: _isLoading,
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      onTap: () async {
                        Functionprovider()
                            .checkInternetConnection()
                            .then((result) {
                          if (result) {
                            setState(() {
                              _login();
                            });
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
