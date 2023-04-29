import 'package:fakebook_flutter_app/src/helpers/colors_constant.dart';
import 'package:fakebook_flutter_app/src/widgets/base_widget.dart';
import 'package:fakebook_flutter_app/src/models/user.dart';
import 'package:fakebook_flutter_app/src/views/Signup/signup_step1_name.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  var dataReturn = "";
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      dataReturn = ModalRoute.of(context).settings.arguments;
      if (ModalRoute.of(context).settings.arguments != null) {
        if (dataReturn == "Đăng ký thành công, bạn có thể bắt đầu đăng nhập") {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Đăng ký thành công"),
                  content: Text(dataReturn ?? "hihi"),
                  actions: [
                    FlatButton(
                        onPressed: () {
                          // Navigator.pop(context);
                          Navigator.pushNamed(context, "login_screen");
                        },
                        child: Text("OK"))
                  ],
                );
              });
        } else {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Đăng ký không thành công"),
                  content: Text(dataReturn ?? "hihi"),
                  actions: [
                    FlatButton(
                        onPressed: () {
                          // Navigator.pop(context);
                          Navigator.popAndPushNamed(context, "signup_screen");
                        },
                        child: Text("OK"))
                  ],
                );
              });
        }
      }
    });
  }

  UserModel userInput = new UserModel.empty();
  @override
  Widget build(BuildContext context) {
    //String dataReturn = ModalRoute.of(context).settings.arguments??"";
    return Scaffold(
      resizeToAvoidBottomInset: false,
      //resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        leading: IconButton(
          color: kColorBlack,
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.blue),
        title: Text(
          'Tạo tài khoản',
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
        elevation: 0,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
        constraints: BoxConstraints.expand(),
        color: Colors.white,
        child: Column(
          children: [
            Center(
              child: Container(
                  width: MediaQuery.of(context).size.width / 1.5,
                  height: MediaQuery.of(context).size.width / 1.5,
                  padding: EdgeInsets.fromLTRB(15, 40, 15, 15),
                  child: Image.asset('assets/image_signup.png')),
            ),
            Text(
              "Tham gia facebook",
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  children: [
                    Text(
                      "Chúng tôi sẽ giúp bạn tạo tài khoản mới sau một vài bước",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: RaisedButton(
                          onPressed: () async {
                            print(userInput.id);
                            Navigator.pushNamed(context, "signup_step1",
                                arguments: userInput);
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all((Radius.circular(8)))),
                          color: Colors.blue,
                          child: Text(
                            "Tiếp",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SizedBox(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: FlatButton(
                onPressed: () {
                  print("ok");
                  Navigator.pop(context);
                },
                padding: EdgeInsets.all(0),
                //minWidth: 20,
                child: buildTextPress("Bạn đã có tài khoản?", Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
