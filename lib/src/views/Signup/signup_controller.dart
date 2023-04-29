import 'dart:convert';
import 'package:fakebook_flutter_app/src/helpers/fetch_data.dart';
import 'package:fakebook_flutter_app/src/helpers/internet_connection.dart';
import 'package:fakebook_flutter_app/src/helpers/shared_preferences.dart';
import 'package:fakebook_flutter_app/src/helpers/validator.dart';
import 'package:fakebook_flutter_app/src/models/user.dart';
import 'package:flutter/material.dart';
import 'package:platform_device_id/platform_device_id.dart';

class SignupController {
  String _error;

  String get error => _error;

  set error(String value) {
    _error = value;
  }

  Future<String> onSubmitSignup({
    final UserModel user,
  }) async {
    String result = '';
    error = "";

    //TODO: Sign up function
    try {
      if (await InternetConnection.isConnect()) {
        await FetchData.signUpApi(
                user.phone, user.password,user.username, await PlatformDeviceId.getDeviceId)
            .then((value) async {
          if (value.statusCode == 200) {
            var val = jsonDecode(value.body);
            print(val);
            if (val["code"] == 1000) {
              result = 'login_screen';
              error = "Đăng ký thành công, bạn có thể bắt đầu đăng nhập";
            } else if (val["code"] == 9996) {
              result = 'signup_screen';
              error = "User đã tồn tại";
            } else
              error = "Không thể đăng ký";
          } else {
            error = "Lỗi server";
          }
        });
      } else
        error =
            "Rất tiếc, không thể đăng ký. Vui lòng kiểm tra kết nối internet";
    } catch (e) {
      error = "Ứng dụng lỗi: " + e.toString();
    }
    return result;
  }
}
