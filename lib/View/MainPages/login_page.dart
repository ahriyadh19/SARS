import 'package:flutter/material.dart';
import 'package:sars/Control/Services/auth.dart';
import 'package:sars/View/BuildWidgetsData/loading.dart';
import 'package:sars/View/MainPages/forget_password.dart';
import 'package:sars/View/MainPages/registration_page.dart';

class LoginBuilder extends StatefulWidget {
  const LoginBuilder({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginPage();
}

class _LoginPage extends State {
  final AuthUserMethod _auth = AuthUserMethod();

  bool passwordVis = true;
  bool loading = false;
  static bool checker = true;

  static String errorMsgLogin = '';

  static List<String?> erorrTexts = List.generate(2, (i) => null);
  static List<TextEditingController> myControllerLogin =
      List.generate(2, (i) => TextEditingController());

  static setMsgErrorNull() {
    for (int i = 0; i < erorrTexts.length; i++) {
      erorrTexts[i] = null;
      errorMsgLogin = '';
    }
  }

  static setMyControllerLoginNull() {
    for (int i = 0; i < myControllerLogin.length; i++) {
      myControllerLogin[i].clear();
    }
  }

  setVisibility() {
    setState(() {
      passwordVis = !passwordVis;
    });
  }

  checkValidatorLogin() async {
    checker = true;
    setState(() {
      setMsgErrorNull();
      if (myControllerLogin[0].text.isEmpty) {
        erorrTexts[0] = 'User Name is required';
        checker = false;
      }
      if (myControllerLogin[1].text.isEmpty) {
        erorrTexts[1] = 'Password is required';
        checker = false;
      }

      if (myControllerLogin[1].text.length < 6) {
        erorrTexts[1] = 'Password should be at least 6 characters';
        checker = false;
      }
    });

    if (checker == true) {
      setState(() {
        loading = true;
      });
      dynamic result = await _auth.loginUserEmailPass(
          myControllerLogin[0].text, myControllerLogin[1].text);

      if (result == null) {
        checker = false;
        setState(() {
          loading = false;
          errorMsgLogin = _auth.getErrorMsg();
        });
      } else {
        setMsgErrorNull();
        setMyControllerLoginNull();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double newWidth = MediaQuery.of(context).size.width - 50;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(180, 0, 170, 179),
            Color.fromARGB(230, 0, 117, 122),
          ],
        )),
        alignment: Alignment.center,
        child: loading
            ? const Loading()
            : SingleChildScrollView(
                padding: const EdgeInsets.only(top: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SingleChildScrollView(
                      child: Center(
                          child: Column(children: [
                        Container(
                          alignment: Alignment.center,
                          width: newWidth,
                          margin: const EdgeInsets.all(20),
                          padding: const EdgeInsets.only(top: 15, bottom: 15),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Colors.black.withOpacity(0.3)),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                SizedBox(
                                    child: Image.asset(
                                  'assets/images/Logo1.png',
                                  width: 100,
                                  height: 100,
                                  filterQuality: FilterQuality.high,
                                )),
                                Text(
                                  'Welcome to SARS',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black.withOpacity(0.7)),
                                ),
                                const SizedBox(height: 15),
                                Container(
                                  margin: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: const Color.fromARGB(
                                          255, 169, 225, 228)),
                                  child: TextField(
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      icon: const Icon(
                                        Icons.email_rounded,
                                        color: Colors.black,
                                      ),
                                      labelText: 'Email',
                                      hintText: 'Enter Your User Email',
                                      labelStyle:
                                          const TextStyle(color: Colors.black),
                                      iconColor: Colors.black,
                                      errorText: erorrTexts[0],
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    controller: myControllerLogin[0],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: const Color.fromARGB(
                                          255, 169, 225, 228)),
                                  child: TextField(
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        icon: const Icon(
                                          Icons.lock_rounded,
                                          color: Colors.black,
                                        ),
                                        labelText: "Password",
                                        hintText: 'Password',
                                        errorText: erorrTexts[1],
                                        labelStyle: const TextStyle(
                                            color: Colors.black),
                                        iconColor: Colors.black,
                                        suffixIcon: IconButton(
                                            onPressed: setVisibility,
                                            icon: passwordVis
                                                ? const Icon(
                                                    Icons.visibility,
                                                    color: Colors.black,
                                                  )
                                                : const Icon(
                                                    Icons.visibility_off,
                                                    color: Colors.black,
                                                  ))),
                                    keyboardType: TextInputType.visiblePassword,
                                    obscureText: passwordVis,
                                    controller: myControllerLogin[1],
                                  ),
                                ),
                                const SizedBox(height: 5),
                                InkWell(
                                  child: const Text(
                                    'Forget Password',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 3, 7, 243),
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  onTap: () async => {
                                    await ForgetPassword()
                                        .showBottomBoxForgetPass(context)
                                  },
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(errorMsgLogin,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Colors.red, fontSize: 15.0)),
                                ),
                                const SizedBox(height: 4),
                                ElevatedButton(
                                  child: const Text(
                                    'Login',
                                    textAlign: TextAlign.center,
                                  ),
                                  style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(9.0),
                                              side: const BorderSide(
                                                  color: Color.fromARGB(
                                                      255, 141, 218, 221)))),
                                      elevation: MaterialStateProperty.all(30),
                                      backgroundColor: MaterialStateProperty.all(
                                          const Color.fromARGB(200, 0, 0, 0)),
                                      padding: MaterialStateProperty.all(
                                          const EdgeInsets.only(left: 112, right: 112)),
                                      textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 15))),
                                  onPressed: checkValidatorLogin,
                                ),
                                ElevatedButton(
                                  child: const Text(
                                    'Register',
                                    textAlign: TextAlign.center,
                                  ),
                                  style: ButtonStyle(
                                      elevation: MaterialStateProperty.all(30),
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(9.0),
                                              side: const BorderSide(
                                                  color: Color.fromARGB(
                                                      255, 141, 218, 221)))),
                                      backgroundColor: MaterialStateProperty.all(
                                          const Color.fromARGB(200, 0, 0, 0)),
                                      padding: MaterialStateProperty.all(
                                          const EdgeInsets.only(left: 105, right: 105)),
                                      textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 15))),
                                  onPressed: () => {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (_) => const RegistrationBuild(),
                                    ))
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        /*     Row(children: const [
                          Expanded(
                              child: Divider(
                            indent: 60,
                            endIndent: 20,
                            color: Colors.white,
                          )),
                          Text(
                            "Or Sign in with",
                            style: TextStyle(color: Colors.white),
                          ),
                          Expanded(
                              child: Divider(
                            indent: 20,
                            endIndent: 60,
                            color: Colors.white,
                          )),
                        ]), 
                         const SizedBox(height: 20),
                        Container(
                          alignment: Alignment.center,
                          width: 350,
                          height: 70,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(45),
                              color: Colors.black.withOpacity(0.08)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () {}, // Image tapped
                                child: Image.asset(
                                  'assets/icons/icons8_google_96px.png',
                                  fit: BoxFit.cover, // Fixes border issues
                                  width: 40,
                                  height: 40,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {}, // Image tapped
                                child: Image.asset(
                                  'assets/icons/icons8_Facebook_96px.png',
                                  fit: BoxFit.cover, // Fixes border issues
                                  width: 45,
                                  height: 45,
                                ),
                              ),
                            ],
                          ),
                        ), */
                      ])),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
