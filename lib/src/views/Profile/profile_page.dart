import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fakebook_flutter_app/src/helpers/colors_constant.dart';
import 'package:fakebook_flutter_app/src/helpers/fetch_data.dart';
import 'package:fakebook_flutter_app/src/helpers/internet_connection.dart';
import 'package:fakebook_flutter_app/src/models/post.dart';
import 'package:fakebook_flutter_app/src/models/user.dart';
import 'package:fakebook_flutter_app/src/views/CreatePost/create_post_controller.dart';
import 'package:fakebook_flutter_app/src/views/HomePage/TabBarView/HomeTab/home_tab.dart';
import 'package:fakebook_flutter_app/src/views/HomePage/TabBarView/WatchTab/my_post.dart';
import 'package:fakebook_flutter_app/src/views/HomePage/TabBarView/WatchTab/watch_tab.dart';
import 'package:fakebook_flutter_app/src/views/Profile/friends_request_item.dart';
import 'package:fakebook_flutter_app/src/helpers/shared_preferences.dart';
import 'package:fakebook_flutter_app/src/views/Profile/models/friends.dart';
import 'package:flushbar/flushbar.dart';
import 'package:fakebook_flutter_app/src/widgets/single_image_view.dart';
import 'package:flutter/material.dart';
import 'package:fakebook_flutter_app/src/views/Profile/fake_data.dart';
import 'package:fakebook_flutter_app/src/views/Profile/friend_item.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:fakebook_flutter_app/src/views/Profile/friend_item_ViewAll.dart';
import 'package:http_parser/src/media_type.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin {
  UserModel myProfile;

  UserModel yourProfile;

  String username = '';
  String avatar = '';

  // ignore: non_constant_identifier_names
  String user_id = "";

  // ignore: non_constant_identifier_names
  String cover_image = '';
  String city = 'Hà Nội';
  String country = 'Việt Nam';
  String description = 'Description default';
  String numberOfFriends = '0';
  var requestedFriends = [];
  var friends = [];

  String asset_type;

  File image;

  bool isLoading = false;

  MultipartFile image_upload;

  var sothich;

  var nghenghiep;

  var songtai;

  var hoctai;

  var dentu;
  final ngheNghiepTextFieldController = TextEditingController();
  final hocTaiTextFieldController = TextEditingController();
  final songTaiTextFieldController = TextEditingController();
  final denTuTextFieldController = TextEditingController();

  bool _showPass = false;

  final passwordTextFieldController = TextEditingController();
  final newpasswordTextFieldController = TextEditingController();
  final repeatpasswordTextFieldController = TextEditingController();

  var password;
  var newpassword;
  var repeatpassword;

  final usernameTextFieldController = TextEditingController();





  bool isLoadingParent = false;
  List<PostModel> listPostReturn = new List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (!mounted) return;
    Future.delayed(Duration.zero, () {
      user_id = ModalRoute.of(context).settings.arguments;
    });

    StorageUtil.getUserInfo().then((value) => setState(() {
          myProfile = value;
        }));

    StorageUtil.getUid().then((value) => setState(() {
          user_id = value;
        }));

    StorageUtil.getUsername().then((value) => setState(() {
          username = value != null ? value : "Người dùng Fakebook";
        }));
    StorageUtil.getAvatar().then((value) => setState(() {
          avatar = value;
        }));
    StorageUtil.getCoverImage().then((value) => setState(() {
          cover_image = value;
        }));
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      setState(() => isLoading = true);
      await getUserInfo(onSuccess: (data) {
        setState(() {
          isLoading = false;

          user_id = data["data"]["_id"];
          username = data["data"]["username"];
          avatar = data["data"]["avatar"];
          cover_image = data["data"]["cover_image"];
          city = data["data"]["city"] ?? "Hà Nội";
          country = data["data"]["country"] ?? "Việt Nam";
          description = data["data"]["country"];
          numberOfFriends = data["data"]["friends"].length.toString();
          friends = data["data"]["friends"].length > 6
              ? data["data"]["friends"].sublist(0, 6)
              : data["data"]["friends"];
          requestedFriends = data["data"]["requestedFriends"];
          songtai = data["data"]["songtai"];
          dentu = data["data"]["dentu"];
          hoctai = data["data"]["hoctai"];
          sothich = data["data"]["sothich"];
          nghenghiep = data["data"]["nghenghiep"];
          yourProfile = new UserModel.detail(
              user_id,
              avatar,
              username,
              cover_image,
              city,
              country,
              description,
              numberOfFriends,
              requestedFriends,
              friends);
        });
      }, onError: (msg) {
        setState(() => isLoading = false);
        print(msg);
      });
    });
  }

  Future<void> getUserInfo(
      {Function(dynamic) onSuccess, Function(String) onError}) async {
    try {
      await FetchData.getUserInfo(
              await StorageUtil.getToken(), await StorageUtil.getUid())
          .then((value) {
        if (value.statusCode == 200) {
          var val = jsonDecode(value.body);
          print(val);
          if (val["code"] == 1000) {
            onSuccess(val);
          } else {
            onError("Thiếu param");
          }
        } else {
          onError("Lỗi server: ${value.statusCode}");
        }
      });
    } catch (e) {
      onError(e.toString());
    }
  }

  Future pickImage(String type) async {
    print("tai anh len");
    String apiLink = "https://api-fakebook.herokuapp.com/it4788/";

    BaseOptions options = BaseOptions(
        baseUrl: apiLink,
        responseType: ResponseType.plain,
        connectTimeout: 30000,
        receiveTimeout: 30000,
        validateStatus: (code) {
          if (code == 200) {
            return true;
          }
        });
    Dio dio = Dio(options);
    final _picker = ImagePicker();
    PickedFile pickedFile;
    pickedFile = await _picker.getImage(
      preferredCameraDevice: CameraDevice.front,
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        asset_type = 'image';
        image = File(pickedFile.path);
      });
      MultipartFile multipartFile = MultipartFile.fromBytes(
        image.readAsBytesSync(),
        filename: image.path.split('/').last,
        contentType: MediaType("image", "jpg"),
      );
      // image_upload =
      //     multipartFile;
      FormData image_form = new FormData.fromMap({type: multipartFile});
      try {
        String token = await StorageUtil.getToken();
        Response response = await dio.post(
          apiLink + "set_user_info?token=$token",
          data: image_form,
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          var responseJson = json.decode(response.data);
          // if(responseJson)
          if (responseJson["data"]["avatar"] != null) {
            setState(() {
              avatar = responseJson["data"]["avatar"];
            });
            await StorageUtil.setAvatar(responseJson["data"]["avatar"]);
            Flushbar(
              message: "Thay đổi ảnh thành công",
              duration: Duration(seconds: 3),
            )..show(context);
          }

          if (responseJson["data"]["cover_image"] != null) {
            setState(() {
              cover_image = responseJson["data"]["cover_image"];
            });
            await StorageUtil.setCoverImage(
                responseJson["data"]["cover_image"]);
            Flushbar(
              message: "Thay đổi ảnh thành công",
              duration: Duration(seconds: 3),
            )..show(context);
          }
          print(responseJson);
          return responseJson;
        } else if (response.statusCode == 401) {
          throw Exception("401 code");
        } else {
          throw Exception('Authentication Error');
        }
      } on DioError catch (exception) {
        print(exception.toString());
      }
    } else {
      setState(() {
        asset_type = '';
      });
    }
  }

  @override
  Widget build(BuildContext cx) {
    return new Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        brightness: Brightness.light,
        backgroundColor: kColorWhite,
        iconTheme: IconThemeData(color: kColorBlack),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_outlined),
          color: kColorBlack,
          onPressed: () => Navigator.pop(context),
        ),
        title: FlatButton(
          color: Colors.grey[200],
          onPressed: () {
            Navigator.pushNamed(context, "home_search_screen");
          },
          padding: EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(Icons.search),
              Text(
                'Tìm kiếm trong bài viết, ảnh ...',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
      body: new ListView(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.all(15.0),
            child: Stack(
              alignment: Alignment.bottomCenter,
              overflow: Overflow.visible,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        height: 200.0,
                        margin: EdgeInsets.only(bottom: 100.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10),
                                topLeft: Radius.circular(10)),
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: cover_image != null
                                    ? NetworkImage(cover_image)
                                    : AssetImage("assets/top_background.jpg"))),
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: <Widget>[
                            Positioned(
                              bottom: 2.0,
                              right: -15.0,
                              child: MaterialButton(
                                onPressed: () {
                                  showModalBottomSheet<void>(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(10),
                                            topLeft: Radius.circular(10)),
                                      ),
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Container(
                                          height: 170.0,
                                          child: Column(
                                            children: <Widget>[
                                              SizedBox(
                                                height: 20.0,
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: FlatButton(
                                                      height: 60.0,
                                                      child: Row(
                                                        children: <Widget>[
                                                          MaterialButton(
                                                            onPressed: () {},
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    224,
                                                                    228,
                                                                    228),
                                                            textColor:
                                                                Colors.white,
                                                            child: Icon(
                                                              Icons
                                                                  .image_rounded,
                                                              size: 18,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            // padding: EdgeInsets.all(10.0),
                                                            shape:
                                                                CircleBorder(),
                                                          ),
                                                          Text('Xem ảnh bìa',
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      16.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ],
                                                      ),
                                                      onPressed: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    SingleImageView(
                                                                        cover_image)));
                                                      },
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: FlatButton(
                                                      height: 60.0,
                                                      child: Row(
                                                        children: <Widget>[
                                                          MaterialButton(
                                                            onPressed: () {},
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    224,
                                                                    228,
                                                                    228),
                                                            textColor:
                                                                Colors.white,
                                                            child: Icon(
                                                              Icons
                                                                  .upload_rounded,
                                                              size: 28,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            // padding: EdgeInsets.all(0.0),
                                                            shape:
                                                                CircleBorder(),
                                                          ),
                                                          Text('Tải ảnh lên',
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      16.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ],
                                                      ),
                                                      onPressed: () async {
                                                        await pickImage(
                                                            "cover_image");
                                                      },
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      });
                                },
                                color: Color.fromARGB(255, 224, 228, 228),
                                textColor: Colors.white,
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 18,
                                  color: Colors.black,
                                ),
                                padding: EdgeInsets.all(0.0),
                                shape: CircleBorder(),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                Positioned(
                  top: 100.0,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet<void>(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10),
                                    topLeft: Radius.circular(10)),
                              ),
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  height: 170.0,
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 20.0,
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: FlatButton(
                                              height: 60.0,
                                              child: Row(
                                                children: <Widget>[
                                                  MaterialButton(
                                                    onPressed: () {},
                                                    color: Color.fromARGB(
                                                        255, 224, 228, 228),
                                                    textColor: Colors.white,
                                                    child: Icon(
                                                      Icons.image_rounded,
                                                      size: 18,
                                                      color: Colors.black,
                                                    ),
                                                    // padding: EdgeInsets.all(10.0),
                                                    shape: CircleBorder(),
                                                  ),
                                                  Text('Xem ảnh đại diện',
                                                      style: TextStyle(
                                                          fontSize: 16.0,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ],
                                              ),
                                              onPressed: () {
                                                if(avatar!="")
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            SingleImageView(
                                                                avatar)));
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: FlatButton(
                                              height: 60.0,
                                              child: Row(
                                                children: <Widget>[
                                                  MaterialButton(
                                                    onPressed: () {},
                                                    color: Color.fromARGB(
                                                        255, 224, 228, 228),
                                                    textColor: Colors.white,
                                                    child: Icon(
                                                      Icons.upload_rounded,
                                                      size: 28,
                                                      color: Colors.black,
                                                    ),
                                                    // padding: EdgeInsets.all(0.0),
                                                    shape: CircleBorder(),
                                                  ),
                                                  Text('Chọn ảnh đại diện',
                                                      style: TextStyle(
                                                          fontSize: 16.0,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ],
                                              ),
                                              onPressed: () async {
                                                await pickImage("avatar");
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              });
                        },
                        child: Container(
                          height: 190.0,
                          width: 190.0,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: avatar != null
                                      ? NetworkImage(avatar)
                                      : AssetImage("assets/avatar.jpg")),
                              border:
                                  Border.all(color: Colors.white, width: 6.0)),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(255, 224, 228, 228),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.camera_alt_rounded),
                          iconSize: 18,
                          color: Colors.black,
                          onPressed: () {
                            showModalBottomSheet<void>(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(10),
                                      topLeft: Radius.circular(10)),
                                ),
                                context: context,
                                builder: (BuildContext context) {
                                  return Container(
                                    height: 170.0,
                                    child: Column(
                                      children: <Widget>[
                                        SizedBox(
                                          height: 20.0,
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: FlatButton(
                                                height: 60.0,
                                                child: Row(
                                                  children: <Widget>[
                                                    MaterialButton(
                                                      onPressed: () {},
                                                      color: Color.fromARGB(
                                                          255, 224, 228, 228),
                                                      textColor: Colors.white,
                                                      child: Icon(
                                                        Icons.image_rounded,
                                                        size: 18,
                                                        color: Colors.black,
                                                      ),
                                                      // padding: EdgeInsets.all(10.0),
                                                      shape: CircleBorder(),
                                                    ),
                                                    Text('Xem ảnh đại diện',
                                                        style: TextStyle(
                                                            fontSize: 16.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ],
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              SingleImageView(
                                                                  avatar)));
                                                },
                                              ),
                                            )
                                          ],
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: FlatButton(
                                                height: 60.0,
                                                child: Row(
                                                  children: <Widget>[
                                                    MaterialButton(
                                                      onPressed: () {},
                                                      color: Color.fromARGB(
                                                          255, 224, 228, 228),
                                                      textColor: Colors.white,
                                                      child: Icon(
                                                        Icons.upload_rounded,
                                                        size: 28,
                                                        color: Colors.black,
                                                      ),
                                                      // padding: EdgeInsets.all(0.0),
                                                      shape: CircleBorder(),
                                                    ),
                                                    Text('Chọn ảnh đại diện',
                                                        style: TextStyle(
                                                            fontSize: 16.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ],
                                                ),
                                                onPressed: () async {
                                                  await pickImage("avatar");
                                                },
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                });
                          },
                        ),
                        // padding: EdgeInsets.all(0.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            // margin: EdgeInsets.only(top: 100.0),
            //alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  username ?? "Người dùng Fakebook",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0),
                )
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    ButtonTheme(
                      minWidth: MediaQuery.of(context).size.width * 0.73,
                      height: 39.0,
                      child: RaisedButton.icon(
                        onPressed: () {
                          print('Click Thêm vào tin');
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0))),
                        label: Text(
                          'Thêm vào tin',
                          style: TextStyle(color: Colors.white),
                        ),
                        icon: Icon(
                          Icons.add_circle,
                          color: Colors.white,
                        ),
                        textColor: Colors.white,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.fromLTRB(10.0, 0, 0, 0),
                      width: MediaQuery.of(context).size.width * 0.15,
                      child: FlatButton(
                        height: 39.0,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0))),
                        onPressed: () => {_personalPageSetting()},
                        color: Colors.black12,
                        child: Column(
                          // Replace with a Row for horizontal icon + text
                          children: <Widget>[
                            Icon(Icons.more_horiz),
                          ],
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(17.0, 0, 17.0, 0),
            child: const Divider(),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 0),
            child: Column(
              children: <Widget>[
                nghenghiep != null
                    ? Row(
                        children: <Widget>[
                          Icon(Icons.work),
                          SizedBox(width: 12.0),
                          Text(
                            'Nghề nghiệp ',
                            style: TextStyle(fontSize: 14.0),
                          ),
                          Text(
                            nghenghiep,
                            style: TextStyle(
                                fontSize: 14.0, fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    : SizedBox.shrink(),
                SizedBox(
                  height: 10.0,
                ),
                songtai != null
                    ? Row(
                        children: <Widget>[
                          Icon(Icons.house),
                          SizedBox(width: 12.0),
                          Text(
                            'Sống tại ',
                            style: TextStyle(fontSize: 14.0),
                          ),
                          Text(
                            songtai,
                            style: TextStyle(
                                fontSize: 14.0, fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    : SizedBox.shrink(),
                SizedBox(
                  height: 10.0,
                ),
                hoctai != null
                    ? Row(
                        children: <Widget>[
                          Icon(Icons.school),
                          SizedBox(width: 12.0),
                          Text(
                            'Học tại ',
                            style: TextStyle(fontSize: 14.0),
                          ),
                          Text(
                            hoctai,
                            style: TextStyle(
                                fontSize: 14.0, fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    : SizedBox.shrink(),
                SizedBox(
                  height: 10.0,
                ),
                dentu != null
                    ? Row(
                        children: <Widget>[
                          Icon(Icons.location_on),
                          SizedBox(width: 12.0),
                          Text(
                            'Đến từ ',
                            style: TextStyle(fontSize: 14.0),
                          ),
                          Text(
                            dentu,
                            style: TextStyle(
                                fontSize: 14.0, fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    : SizedBox.shrink(),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  children: <Widget>[
                    Icon(Icons.more_horiz),
                    SizedBox(width: 12.0),
                    Text(
                      'Xem thông tin giới thiệu của bạn ',
                      style: TextStyle(fontSize: 14.0),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: FlatButton(
                        height: 37.0,
                        child: Text(
                          'Chỉnh sửa chi tiết công khai',
                          style: TextStyle(color: Colors.blue),
                        ),
                        color: Color.fromARGB(205, 200, 223, 247),
                        onPressed: () {
                          _EditProfile();
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(0, 10.0, 0, 0),
            child: const Divider(),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 10.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Bạn bè',
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                    FlatButton(
                      padding: const EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                      child: Text(
                        'Tìm bạn bè',
                        style:
                            TextStyle(fontSize: 15.0, color: Colors.blueAccent),
                      ),
                      onPressed: () {
                        _FriendsRequest();
                      },
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text(
                      numberOfFriends != null
                          ? numberOfFriends + ' người bạn'
                          : '0 người bạn',
                      style: TextStyle(fontSize: 16.0, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 3.0),
            height: friends.length / 3 < 1 ? 165 : 330,
            child: GridView(
              physics: new NeverScrollableScrollPhysics(),
              children: friends
                  .map((eachFriend) => FriendItem(friends: eachFriend))
                  .toList(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  //maxCrossAxisExtent: MediaQuery.of(context).size.width * 0.33,
                  childAspectRatio: 6 / 9,
                  // crossAxisSpacing: 0.0,
                  mainAxisSpacing: 0),
            ),

            // child: GridView.count(
            //   padding: const EdgeInsets.all(17),
            //   crossAxisSpacing: 15,
            //   mainAxisSpacing: 30,
            //   crossAxisCount: 3,
            //   children: FAKE_FRIENDS
            //       .map((eachFriend) => FriendItem(friends: eachFriend))
            //       .toList(),
            // ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
            child: FlatButton(
              color: Color.fromARGB(109, 192, 195, 195),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
              ),
              minWidth: MediaQuery.of(context).size.width * 0.91,
              child: Text('Xem tất cả bạn bè'),
              onPressed: () {
                _ViewAllFriends();
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(0, 10.0, 0, 20.0),
            child: Divider(
              height: 20.0,
              thickness: 10.0,
              color: Color.fromARGB(120, 139, 141, 141),
            ),
          ),
          Container(
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 15.0,
                    ),
                    Text(
                      'Bài viết',
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                SizedBox(
                  height: 15.0,
                ),
                FlatButton(
                  height: 60.0,
                  child: Row(
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.fromLTRB(0, 0, 15.0, 0),
                        height: 40.0,
                        width: 40.0,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: avatar != null
                                    ? NetworkImage(avatar)
                                    : AssetImage("assets/avatar.jpg")),
                            border:
                                Border.all(color: Colors.white, width: 1.0)),
                      ),
                      Text('Bạn đang nghĩ gì?',
                          style:
                              TextStyle(fontSize: 14.0, color: Colors.black54)),
                    ],
                  ),
                  onPressed: () {
                    CreatePostController createPostController = new CreatePostController();
                    Navigator.pushNamed(context, "create_post").then((value) async {
                      if (value != null) {
                        setState(() {
                          isLoading = true;
                        });
                        Map<String, dynamic> postReturn = value;
                        createPostController
                            .onSubmitCreatePost(
                            images: postReturn["images"],
                            video: postReturn["video"],
                            described: postReturn["described"],
                            status: postReturn["status"],
                            state: postReturn["state"],
                            can_edit: postReturn["can_edit"],
                            asset_type: postReturn["asset_type"])
                            .then((val) {
                          setState(() {
                            isLoadingParent = false;
                            listPostReturn.insert(0, val);
                          });
                        });
                      }
                    });
                  },
                )
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(0, 10.0, 0, 20.0),
            child: Divider(
              height: 20.0,
              thickness: 10.0,
              color: Color.fromARGB(120, 139, 141, 141),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(0, 10.0, 0, 20.0),
            child: new ProfilePost(list: listPostReturn, isLoadingParent: isLoadingParent,),
          )
        ],
      ),
    );
  }

  void _personalPageSetting() {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeftWithFade,
            duration: Duration(milliseconds: 130),
            child: new Scaffold(
              appBar: new AppBar(
                leading: BackButton(
                  color: Colors.black,
                ),
                title: new Text(
                  'Cài đặt trang cá nhân',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 21.0,
                      fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
                backgroundColor: Colors.white,
              ),
              body: new Column(
                children: <Widget>[
                  SizedBox(
                    height: 15.0,
                  ),
                  FlatButton(
                    onPressed: () {
                      _EditProfile();
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.edit_outlined),
                        SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          'Chỉnh sửa trang cá nhân',
                          style: TextStyle(fontSize: 16.0),
                        )
                      ],
                    ),
                  ),
                  Divider(
                    height: 15.0,
                    color: Color.fromARGB(120, 139, 141, 141),
                  ),
                  FlatButton(
                    onPressed: () {
                      _SearchOnProfilePage();
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.search_rounded),
                        SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          'Tìm kiếm trên trang cá nhân',
                          style: TextStyle(fontSize: 16.0),
                        )
                      ],
                    ),
                  ),
                  Divider(
                    height: 30.0,
                    color: Color.fromARGB(120, 139, 141, 141),
                    thickness: 10.0,
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.only(left: 17.0, top: 10.0),
                    child: Text(
                      'Liên kết đến trang cá nhân của bạn',
                      style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.only(left: 17.0, top: 10.0, bottom: 5.0),
                    child: Text('Liên kết của riêng bạn trên FaceBook.'),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 5.0, right: 5.0),
                    child: Divider(
                      height: 10.0,
                      color: Color.fromARGB(120, 139, 141, 141),
                    ),
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.only(left: 17.0, bottom: 5.0),
                    child: Text(
                      'https://www.facebook.com/user',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.only(left: 17.0, bottom: 5.0),
                      child: RaisedButton(
                        onPressed: () {},
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            side: BorderSide(color: Colors.black)),
                        child: Text('Sao chép liên kết'),
                      )),
                ],
              ),
            )));
  }

  void _EditProfile() {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeftWithFade,
            duration: Duration(milliseconds: 130),
            child: new Scaffold(
              appBar: new AppBar(
                leading: BackButton(
                  color: Colors.black,
                ),
                title: new Text(
                  'Chỉnh sửa trang cá nhân',
                  style: TextStyle(color: Colors.black, fontSize: 19.0),
                ),
                backgroundColor: Colors.white,
              ),
              body: new ListView(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 15.0, top: 15.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Ảnh đại diện',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20.0),
                            ),
                            FlatButton(
                              onPressed: () {
                                pickImage("avatar");
                              },
                              child: Text(
                                'Chỉnh sửa',
                                style: TextStyle(
                                    color: Colors.blue, fontSize: 16.0),
                              ),
                            )
                          ],
                        ),
                        Container(
                          height: 150.0,
                          width: 150.0,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: avatar != null
                                    ? NetworkImage(avatar)
                                    : AssetImage("assets/avatar.jpg"),
                              )),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              right: 15.0, top: 10.0, bottom: 5.0),
                          child: Divider(
                            height: 15.0,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Ảnh bìa',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20.0),
                            ),
                            FlatButton(
                              onPressed: () {
                                pickImage("cover_image");
                              },
                              child: Text(
                                'Chỉnh sửa',
                                style: TextStyle(
                                    color: Colors.blue, fontSize: 16.0),
                              ),
                            )
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(right: 15.0, top: 10.0),
                          height: 200.0,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: cover_image != null
                                    ? NetworkImage(cover_image)
                                    : AssetImage("assets/top_background.jpg"),
                              )),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              right: 15.0, top: 10.0, bottom: 5.0),
                          child: Divider(
                            height: 15.0,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Thông tin cá nhân',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20.0),
                            ),
                            FlatButton(
                              onPressed: () async {
                                print("chỉnh sửa chi tiết");
                                var token = await StorageUtil.getToken();
                                Response response;
                                Dio dio = new Dio();
                                response = await dio.post(
                                    "https://api-fakebook.herokuapp.com/it4788/set_user_info?token=$token&username=${usernameTextFieldController.text}&password=${passwordTextFieldController.text}");
                                // setState(() {
                                //   nghenghiep = "";
                                //   hoctai = "";
                                //   songtai = "";
                                //   dentu = "";
                                // });
                                if (response.statusCode == 200) {
                                  var val = response.data["data"];
                                  setState(() {
                                    username = val["username"];
                                  });
                                }
                              },
                              child: Text(
                                'Chỉnh sửa',
                                style: TextStyle(
                                    color: Colors.blue, fontSize: 16.0),
                              ),
                            )
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(2.0, 5.0, 15.0, 0),
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Icon(Icons.work),
                                  SizedBox(width: 12.0),
                                  Text(
                                    'Tên hiển thị:',
                                    style: TextStyle(fontSize: 14.0),
                                  ),
                                ],
                              ),
                              TextField(
                                controller: usernameTextFieldController
                                  ..text = username ?? "",
                                decoration: InputDecoration(
                                  hintText: 'Ngô Bá Khá',
                                ),
                                // onChanged: (text) => {
                                //   setState(() {
                                //     nghenghiep = text;
                                //   })
                                // },
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              right: 15.0, top: 10.0, bottom: 1.0),
                          child: Divider(
                            height: 15.0,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Bảo mật',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20.0),
                            ),
                            FlatButton(
                              onPressed: () async {
                                print("thay đổi password");
                                var token = await StorageUtil.getToken();
                                Response response;
                                Dio dio = new Dio();
                                print(newpasswordTextFieldController.text);
                                response = await dio.post(
                                    "https://api-fakebook.herokuapp.com/it4788/change_password?token=$token&new_password=${newpasswordTextFieldController.text}&password=${passwordTextFieldController.text}");
                                // setState(() {
                                //   nghenghiep = "";
                                //   hoctai = "";
                                //   songtai = "";
                                //   dentu = "";
                                // });
                                print(response);
                                if (response.data["code"] == 1000) {
                                  Flushbar(
                                    message: "Thay đổi mật khẩu thành công",
                                    duration: Duration(seconds: 3),
                                  )..show(context);
                                } else {
                                  Flushbar(
                                    message:
                                        "Thay đổi mật khẩu không thành công",
                                    duration: Duration(seconds: 3),
                                  )..show(context);
                                }
                              },
                              child: Text(
                                'Chỉnh sửa',
                                style: TextStyle(
                                    color: Colors.blue, fontSize: 16.0),
                              ),
                            )
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(2.0, 5.0, 15.0, 0),
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Icon(Icons.house),
                                  SizedBox(width: 12.0),
                                  Text(
                                    'Mật khẩu cũ',
                                    style: TextStyle(fontSize: 14.0),
                                  ),
                                ],
                              ),
                              TextField(
                                controller: passwordTextFieldController
                                  ..text = password ?? "",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.black),
                                obscureText: !_showPass,
                                decoration: InputDecoration(
                                  hintText: "Mật khẩu cũ",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  prefixIcon: Icon(Icons.lock_outline,
                                      color: Color(0xff888888)),
                                  suffixIcon: Visibility(
                                    // visible: _password.isNotEmpty,
                                    visible: true,
                                    child: new GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          print(_showPass);
                                          _showPass = _showPass != null
                                              ? !_showPass
                                              : false;
                                        });
                                      },
                                      child: new Icon(
                                          _showPass != null && !_showPass
                                              ? Icons.visibility
                                              : Icons.visibility_off),
                                    ),
                                  ),
                                ),

                                // onChanged: (text) => {
                                //   setState(() {
                                //     songtai = text;
                                //   })
                                // },
                              ),
                              Row(
                                children: <Widget>[
                                  Icon(Icons.house),
                                  SizedBox(width: 12.0),
                                  Text(
                                    'Mật khẩu mới',
                                    style: TextStyle(fontSize: 14.0),
                                  ),
                                ],
                              ),
                              TextField(
                                controller: newpasswordTextFieldController
                                  ..text = password ?? "",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.black),
                                obscureText: !_showPass,
                                decoration: InputDecoration(
                                  hintText: "Mật khẩu mới",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  prefixIcon: Icon(Icons.lock_outline,
                                      color: Color(0xff888888)),
                                  suffixIcon: Visibility(
                                    // visible: _password.isNotEmpty,
                                    visible: true,
                                    child: new GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          print(_showPass);
                                          _showPass = _showPass != null
                                              ? !_showPass
                                              : false;
                                        });
                                      },
                                      child: new Icon(
                                          _showPass != null && !_showPass
                                              ? Icons.visibility
                                              : Icons.visibility_off),
                                    ),
                                  ),
                                ),

                                // onChanged: (text) => {
                                //   setState(() {
                                //     songtai = text;
                                //   })
                                // },
                              ),
                              Row(
                                children: <Widget>[
                                  Icon(Icons.house),
                                  SizedBox(width: 12.0),
                                  Text(
                                    'Nhắc lại mật khẩu',
                                    style: TextStyle(fontSize: 14.0),
                                  ),
                                ],
                              ),
                              TextField(
                                controller: repeatpasswordTextFieldController
                                  ..text = "",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.black),
                                obscureText: !_showPass,
                                decoration: InputDecoration(
                                  hintText: "Nhắc lại mật khẩu",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  prefixIcon: Icon(Icons.lock_outline,
                                      color: Color(0xff888888)),
                                  suffixIcon: Visibility(
                                    // visible: _password.isNotEmpty,
                                    visible: true,
                                    child: new GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          print(_showPass);
                                          _showPass = _showPass != null
                                              ? !_showPass
                                              : false;
                                        });
                                      },
                                      child: new Icon(
                                          _showPass != null && !_showPass
                                              ? Icons.visibility
                                              : Icons.visibility_off),
                                    ),
                                  ),
                                ),

                                // onChanged: (text) => {
                                //   setState(() {
                                //     songtai = text;
                                //   })
                                // },
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              right: 15.0, top: 10.0, bottom: 1.0),
                          child: Divider(
                            height: 15.0,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Chi tiết',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20.0),
                            ),
                            FlatButton(
                              onPressed: () async {
                                print("chỉnh sửa chi tiết");
                                var token = await StorageUtil.getToken();
                                Response response;
                                Dio dio = new Dio();
                                response = await dio.post(
                                    "https://api-fakebook.herokuapp.com/it4788/set_user_info?token=$token&songtai=${songTaiTextFieldController.text}&hoctai=${hocTaiTextFieldController.text}&dentu=${denTuTextFieldController.text}&nghenghiep=${ngheNghiepTextFieldController.text}");
                                // setState(() {
                                //   nghenghiep = "";
                                //   hoctai = "";
                                //   songtai = "";
                                //   dentu = "";
                                // });
                                if (response.statusCode == 200) {
                                  var val = response.data["data"];
                                  setState(() {
                                    nghenghiep = val["nghenghiep"];
                                    hoctai = val["hoctai"];
                                    songtai = val["songtai"];
                                    dentu = val["dentu"];
                                  });
                                }
                              },
                              child: Text(
                                'Chỉnh sửa',
                                style: TextStyle(
                                    color: Colors.blue, fontSize: 16.0),
                              ),
                            )
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(2.0, 5.0, 15.0, 0),
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Icon(Icons.work),
                                  SizedBox(width: 12.0),
                                  Text(
                                    'Nghề nghiệp:',
                                    style: TextStyle(fontSize: 14.0),
                                  ),
                                ],
                              ),
                              TextField(
                                controller: ngheNghiepTextFieldController
                                  ..text = nghenghiep ?? "",
                                decoration: InputDecoration(
                                  hintText: 'Bác sĩ',
                                ),
                                // onChanged: (text) => {
                                //   setState(() {
                                //     nghenghiep = text;
                                //   })
                                // },
                              ),
                              Row(
                                children: <Widget>[
                                  Icon(Icons.house),
                                  SizedBox(width: 12.0),
                                  Text(
                                    'Sống tại:',
                                    style: TextStyle(fontSize: 14.0),
                                  ),
                                ],
                              ),
                              TextField(
                                controller: songTaiTextFieldController
                                  ..text = songtai ?? "",
                                decoration: InputDecoration(
                                  hintText: 'Hà Nội, Việt Nam',
                                ),
                                // onChanged: (text) => {
                                //   setState(() {
                                //     songtai = text;
                                //   })
                                // },
                              ),
                              Row(
                                children: <Widget>[
                                  Icon(Icons.school),
                                  SizedBox(width: 12.0),
                                  Text(
                                    'Học tại:',
                                    style: TextStyle(fontSize: 14.0),
                                  ),
                                ],
                              ),
                              TextField(
                                controller: hocTaiTextFieldController
                                  ..text = hoctai ?? "",
                                decoration: InputDecoration(
                                  hintText: 'Trường Đại học Bách Khoa Hà Nội',
                                ),
                                // onChanged: (text) => {
                                //   setState(() {
                                //     hoctai = text;
                                //   })
                                // },
                              ),
                              Row(
                                children: <Widget>[
                                  Icon(Icons.location_on),
                                  SizedBox(width: 12.0),
                                  Text(
                                    'Đến từ:',
                                    style: TextStyle(fontSize: 14.0),
                                  ),
                                ],
                              ),
                              TextField(
                                controller: denTuTextFieldController
                                  ..text = dentu ?? "",
                                decoration: InputDecoration(
                                  hintText: 'Thái Nguyên, Việt Nam',
                                ),
                                // onChanged: (text) => {
                                //   setState(() {
                                //     dentu = text;
                                //   })
                                // },
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              right: 15.0, top: 10.0, bottom: 1.0),
                          child: Divider(
                            height: 15.0,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Sở thích',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20.0),
                            ),
                            FlatButton(
                              onPressed: () {},
                              child: Text(
                                'Thêm',
                                style: TextStyle(
                                    color: Colors.blue, fontSize: 16.0),
                              ),
                            )
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              right: 15.0, top: 1.0, bottom: 1.0),
                          child: Divider(
                            height: 15.0,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Liên kết',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20.0),
                            ),
                            FlatButton(
                              onPressed: () {},
                              child: Text(
                                'Thêm',
                                style: TextStyle(
                                    color: Colors.blue, fontSize: 16.0),
                              ),
                            )
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              right: 15.0, top: 1.0, bottom: 5.0),
                          child: Divider(
                            height: 15.0,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(right: 15.0, bottom: 15.0),
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: RaisedButton.icon(
                            elevation: 0,
                            onPressed: () {
                              print('Click chỉnh sửa thông tin giới thiệu');
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0))),
                            label: Text(
                              'Chỉnh sửa thông tin giới thiệu',
                              style: TextStyle(color: Colors.blue),
                            ),
                            icon: Icon(
                              Icons.person_outline_rounded,
                              color: Colors.blue,
                            ),
                            textColor: Colors.blue,
                            color: Color.fromARGB(205, 200, 223, 247),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )));
  }

  void _SearchOnProfilePage() {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeftWithFade,
            duration: Duration(milliseconds: 130),
            child: new Scaffold(
              appBar: new AppBar(
                leading: BackButton(
                  color: Colors.black,
                ),
                // actions: [searchBar.getSearchAction(context)],
                // actions: [SearchBar(
                //     inBar: false,
                //     setState: setState,
                //     onSubmitted: print,
                // ).getSearchAction(context)],
                backgroundColor: Colors.white,
              ),
              body: new ListView(
                children: [
                  SizedBox(
                    height: 35.0,
                  ),
                  Container(
                    height: 100.0,
                    width: 100.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: avatar != null
                              ? NetworkImage(avatar)
                              : AssetImage("assets/avatar.jpg")),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Center(
                    child: Text(
                      'Bạn đang tìm gì à?',
                      style: TextStyle(
                          fontSize: 17.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 65.0, left: 65.0, top: 20.0),
                    child: Text(
                      'Tìm kiếm trên trang cá nhân của THE MATRIX để xem bài viết, ảnh và các hoạt động hiển thị khác.',
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            )));
  }

  void _ViewAllFriends() async {
    bool activeAllFriend = true;
    var friends = [];
    if (await InternetConnection.isConnect()) {
      String token = await StorageUtil.getToken();

      var resGetUserFriends = await FetchData.getUserFriends(token, "0", "20");
      var dataGetUserFriends = await jsonDecode(resGetUserFriends.body);
      if (resGetUserFriends.statusCode == 200) {
        // setState(() {
        friends = dataGetUserFriends["data"]["friends"];
        // print(friends);
        // });
      } else {
        print("Lỗi server");
      }
    }

    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeftWithFade,
            duration: Duration(milliseconds: 5000),
            child: new Scaffold(
                appBar: new AppBar(
                  leading: BackButton(
                    color: Colors.black,
                  ),
                  title: Text(
                    username,
                    style: TextStyle(color: Colors.black, fontSize: 18.0),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.search_rounded),
                      iconSize: 30.0,
                      color: Colors.black,
                      onPressed: () {},
                    )
                  ],
                  backgroundColor: Colors.white,
                ),
                body: new Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          right: 15.0, left: 15.0, top: 12.0, bottom: 15.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Column(
                                children: [
                                  FlatButton(
                                    child: Text(
                                      'Tất cả',
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        activeAllFriend = !activeAllFriend;
                                      });
                                    },
                                    color: activeAllFriend == true
                                        ? Color.fromARGB(200, 200, 223, 247)
                                        : Color.fromARGB(100, 192, 195, 195),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30.0))),
                                  )
                                ],
                              ),
                              SizedBox(
                                width: 8.0,
                              ),
                              Column(
                                children: [
                                  FlatButton(
                                    child: Text(
                                      'Gần đây',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        activeAllFriend = !activeAllFriend;
                                      });
                                      print(activeAllFriend);
                                    },
                                    color: activeAllFriend == true
                                        ? Color.fromARGB(100, 192, 195, 195)
                                        : Color.fromARGB(200, 200, 223, 247),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30.0))),
                                  )
                                ],
                              )
                            ],
                          ),
                          Container(
                            height: 40.0,
                            margin: EdgeInsets.only(top: 10.0),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(50, 192, 195, 195),
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                hintStyle: TextStyle(fontSize: 14),
                                hintText: 'Tìm kiếm bạn bè',
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                contentPadding: EdgeInsets.all(0),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Row(
                            children: [
                              Text(
                                numberOfFriends != null
                                    ? numberOfFriends + ' người bạn'
                                    : '0 người bạn',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 19.0),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: GridView(
                        children: friends
                            .map((eachFriend) => FriendItemViewAll(
                                friend_item_ViewAll: eachFriend))
                            .toList(),
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent:
                                MediaQuery.of(context).size.width * 1,
                            childAspectRatio: 8 / 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10),
                      ),
                    )
                  ],
                ))));
  }

  void _FriendsRequest() {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeftWithFade,
            duration: Duration(milliseconds: 130),
            child: new Scaffold(
                appBar: new AppBar(
                  leading: BackButton(
                    color: Colors.black,
                  ),
                  title: Text(
                    'Lời mời kết bạn',
                    style: TextStyle(color: Colors.black, fontSize: 18.0),
                  ),
                  centerTitle: true,
                  actions: [
                    IconButton(
                      icon: Icon(Icons.more_horiz_rounded),
                      onPressed: () {
                        showModalBottomSheet<void>(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  topLeft: Radius.circular(10)),
                            ),
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                  height: 70,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: FlatButton(
                                              height: 60.0,
                                              child: Row(
                                                children: <Widget>[
                                                  Icon(
                                                    Icons
                                                        .arrow_forward_outlined,
                                                    size: 35.0,
                                                  ),
                                                  SizedBox(
                                                    width: 10.0,
                                                  ),
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.75,
                                                    child: Text(
                                                        'Xem lời mời đã gửi',
                                                        style: TextStyle(
                                                            fontSize: 16.0)),
                                                  )
                                                ],
                                              ),
                                              onPressed: () {},
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ));
                            });
                      },
                      color: Colors.black,
                    )
                  ],
                  backgroundColor: Colors.white,
                ),
                body: new Column(
                  children: [
                    Container(
                      margin:
                          EdgeInsets.only(left: 15.0, top: 12.0, bottom: 15.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Lời mời kết bạn',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0),
                              ),
                              FlatButton(
                                onPressed: () {
                                  showModalBottomSheet<void>(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(10),
                                            topLeft: Radius.circular(10)),
                                      ),
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Container(
                                            height: 200,
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: FlatButton(
                                                        height: 60.0,
                                                        child: Row(
                                                          children: <Widget>[
                                                            Icon(
                                                              Icons
                                                                  .auto_awesome,
                                                              size: 35.0,
                                                            ),
                                                            SizedBox(
                                                              width: 10.0,
                                                            ),
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.75,
                                                              child: Text(
                                                                  'Mặc định',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16.0)),
                                                            )
                                                          ],
                                                        ),
                                                        onPressed: () {},
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: FlatButton(
                                                        height: 60.0,
                                                        child: Row(
                                                          children: <Widget>[
                                                            Icon(
                                                              Icons
                                                                  .arrow_upward_rounded,
                                                              size: 35.0,
                                                            ),
                                                            SizedBox(
                                                              width: 10.0,
                                                            ),
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.75,
                                                              child: Text(
                                                                  'Lời mời mới nhất trước tiên',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16.0)),
                                                            )
                                                          ],
                                                        ),
                                                        onPressed: () {},
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: FlatButton(
                                                        height: 60.0,
                                                        child: Row(
                                                          children: <Widget>[
                                                            Icon(
                                                              Icons
                                                                  .arrow_downward_rounded,
                                                              size: 35.0,
                                                            ),
                                                            SizedBox(
                                                              width: 10.0,
                                                            ),
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.75,
                                                              child: Text(
                                                                  'Lời mời cũ nhất trước tiên',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16.0)),
                                                            )
                                                          ],
                                                        ),
                                                        onPressed: () {},
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ));
                                      });
                                },
                                child: Text(
                                  'Sắp xếp',
                                  style: TextStyle(
                                      color: Colors.blue, fontSize: 16.0),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    requestedFriends != null && requestedFriends.length > 0
                        ? Expanded(
                            child: GridView(
                              children: requestedFriends
                                  .map((eachFriend) => FriendRequestItem(
                                      friend_request_item: eachFriend))
                                  .toList(),
                              gridDelegate:
                                  SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent:
                                          MediaQuery.of(context).size.width * 1,
                                      childAspectRatio: 8 / 2.2,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10),
                            ),
                          )
                        : Text("Hiện chưa có lời mời kết bạn nào")
                  ],
                ))));
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
