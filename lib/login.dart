import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './utils/dimensions.dart';
import 'call.dart';

class Login extends StatefulWidget {
  final SharedPreferences prefs;

  Login(this.prefs);

  State createState() => LoginState();
}

class LoginState extends State<Login> {
  InputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Colors.purple, width: 3));

  final controller = new TextEditingController();

  bool settingUsername = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (height == null || width == null) {
      width = MediaQuery.of(context).size.width;
      height = MediaQuery.of(context).size.height;
    }
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            width: width,
            height: height,
            child: Padding(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: width * 0.035,
                  mainAxisSpacing: width * 0.035,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  return Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.purple));
                },
                shrinkWrap: true,
              ),
              padding:
                  EdgeInsets.only(/*left: width * 0.1, right: width * 0.1*/),
            ),
          ),
          Center(
              child: ClipRect(
                  //width: width,
                  //height: height,
                  child: BackdropFilter(
            filter: ImageFilter.blur(sigmaY: 2, sigmaX: 2),
            child: Container(
              width: width,
              height: height,
              color: Colors.white.withOpacity(0),
              child: Center(
                child: Container(
                  width: width,
                  height: height * 0.5,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                          top: BorderSide(color: Colors.black, width: 2),
                          bottom: BorderSide(color: Colors.black, width: 2))),
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Text(
                          "Enter your Username",
                          style: TextStyle(fontSize: 17),
                        ),
                        Expanded(
                          child: SizedBox(),
                        ),
                        Container(
                          child: TextField(
                            controller: controller,
                            decoration: InputDecoration(
                              enabledBorder: border,
                              disabledBorder: border,
                              focusedBorder: border,
                            ),
                          ),
                          width: width * 0.6,
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        FlatButton(
                          child: Text("Done"),
                          onPressed: () async {
                            if (controller.text.length != 0) {
                              setState(() {
                                settingUsername = true;
                              });
                              await widget.prefs
                                  .setString("username", controller.text);
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (con) =>
                                          MakeCall(controller.text)),
                                  (route) => false);
                            }
                          },
                        ),
                        Expanded(
                          child: SizedBox(),
                        )
                      ],
                    ),
                  ),
                  padding: EdgeInsets.all(8),
                ),
              ),
            ),
          ))),
          settingUsername
              ? Container(
                  child: Center(child: CircularProgressIndicator()),
                  color: Colors.black.withOpacity(0.5),
                )
              : SizedBox()
        ],
      ),
    );
  }
}
