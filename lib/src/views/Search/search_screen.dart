import 'dart:convert';

import 'package:fakebook_flutter_app/src/helpers/colors_constant.dart';
import 'package:fakebook_flutter_app/src/helpers/fetch_data.dart';
import 'package:fakebook_flutter_app/src/helpers/loading_post_screen.dart';
import 'package:fakebook_flutter_app/src/helpers/screen.dart';
import 'package:fakebook_flutter_app/src/helpers/shared_preferences.dart';
import 'package:fakebook_flutter_app/src/models/post.dart';
import 'package:fakebook_flutter_app/src/views/HomePage/TabBarView/HomeTab/post_widget_controller.dart';
import 'package:fakebook_flutter_app/src/views/Search/searched_controller.dart';
import 'package:fakebook_flutter_app/src/widgets/loading_shimmer.dart';
import 'package:fakebook_flutter_app/src/widgets/post/post_widget.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  @override
  _SaveSearchState createState() => _SaveSearchState();
}

class _SaveSearchState extends State<SearchPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  TextEditingController textController = new TextEditingController();
  bool is_searched = false;
  TabController _tabController;

  String username;
  String avatar;

  var refreshKey = GlobalKey<RefreshIndicatorState>();

  bool isLoading = false;
  List<dynamic> savedSearchList = List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(vsync: this, length: 3);

    StorageUtil.getUsername().then((value) => setState(() {
          username = value;
        }));
    StorageUtil.getAvatar().then((value) => setState(() {
          avatar = value;
        }));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => isLoading = true);
      await getSearch(onSuccess: (values) {
        setState(() {
          isLoading = false;
          savedSearchList = values;
        });
      }, onError: (msg) {
        setState(() => isLoading = false);
        print(msg);
      });
    });
  }

  Future<void> getSearch(
      {Function(List<dynamic>) onSuccess, Function(String) onError}) async {
    var response =
        await FetchData.getSaveSearchApi(await StorageUtil.getToken(), 0, 10);
    if (response.statusCode == 200) {
      try {
        dynamic jsonRaw = json.decode(response.body);
        List<dynamic> data = jsonRaw["data"];
        onSuccess(data);
      } catch (e) {
        onError("Something get wrong!");
      }
    } else {
      onError("Something get wrong! Status code ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottomOpacity: 1,
          elevation: 0.0,
          backgroundColor: kColorWhite,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_outlined,
              color: kColorBlack,
            ),
            onPressed: () {
              if (is_searched) {
                setState(() {
                  textController.text = "";
                  is_searched = false;
                });
              } else
                Navigator.pop(context);
            },
          ),
          title: Container(
            height: 45,
            padding: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(50),
            ),
            child: TextField(
              controller: textController,
              textAlignVertical: TextAlignVertical.center,
              autofocus: !is_searched,
              cursorWidth: 1,
              cursorHeight: 30,
              cursorColor: kColorGrey,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 5),
                border: InputBorder.none,
                hintText: 'Tìm kiếm',
                hintStyle: TextStyle(
                  fontSize: FontSize.s18,
                  color: kColorBlack,
                  //fontWeight: FontWeight.bold
                ),
                // TODO: Search Button
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      savedSearchList
                          .insert(0, {"keyword": textController.text});
                      textController.text = "";
                      is_searched = false;
                    });
                  },
                  icon: Icon(
                    Icons.close,
                    color: kColorBlack.withOpacity(0.8),
                    //size: ConstScreen.setSizeWidth(45),
                  ),
                ),
              ),
              style: TextStyle(fontSize: FontSize.s24, color: kColorBlack),
              maxLines: 1,
              onSubmitted: (value) {
                setState(() {
                  value.isNotEmpty ? is_searched = true : is_searched = false;
                });
              },
              onChanged: (value) {
                setState(() {
                  //isSearch = true;
                });
              },
            ),
          ),
          bottom: !is_searched
              ? null
              : TabBar(
                  indicatorColor: kColorBlue,
                  controller: _tabController,
                  unselectedLabelColor: kColorBlack,
                  labelColor: kColorBlue,
                  tabs: [
                    Tab(
                      text: "Tất cả",
                    ),
                    Tab(
                      text: "Bài viết",
                    ),
                    Tab(
                      text: "Mọi người",
                    ),
                  ],
                ),
        ),
        body: is_searched
            ? TabBarView(controller: _tabController, children: [
                ResultSearch(textController.text),
                ResultSearch(textController.text),
                Container()
              ])
            : buildSavedSearchBody(),
      ),
    );
  }

  Widget buildSavedSearchBody() {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : savedSearchList.isEmpty
            ? Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.1, left: 30),
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.indigo,
                      child: Icon(
                        Icons.search,
                        size: 80,
                      ),
                      radius: 48,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Hãy nhập vài từ để tìm kiếm trong",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text("FACEBOOK",
                        style: TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ))
            : Container(
                decoration: BoxDecoration(
                  border:
                      Border(top: BorderSide(color: kColorGrey, width: 0.2)),
                ),
                child: RefreshIndicator(
                  onRefresh: () async {
                    await getSearch(onSuccess: (values) {
                      setState(() {
                        isLoading = false;
                        savedSearchList = values;
                      });
                    }, onError: (msg) {
                      setState(() => isLoading = false);
                      print(msg);
                    });
                  },
                  child: ListView(
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        height: 45,
                        decoration: BoxDecoration(
                          border: Border(
                              bottom:
                                  BorderSide(color: kColorGrey, width: 0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Mới đây",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            FlatButton(
                                padding: EdgeInsets.symmetric(horizontal: 0),
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, "activity_diary_screen");
                                },
                                child: Text("CHỈNH SỬA")),
                          ],
                        ),
                      ),
                      ListView.builder(
                          padding: EdgeInsets.only(top: 3),
                          physics: ScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: savedSearchList.length,
                          itemBuilder: (context, index) {
                            String result = savedSearchList[index]['keyword'];
                            return FlatButton(
                              padding: EdgeInsets.all(0),
                              onPressed: () {
                                setState(() {
                                  textController.text = result;
                                  is_searched = true;
                                });
                              },
                              child: ListTile(
                                leading: Icon(Icons.search),
                                title: Text(result),
                                trailing: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        savedSearchList.removeAt(index);
                                      });
                                    },
                                    icon: Icon(Icons.close)),
                              ),
                            );
                          }),
                    ],
                  ),
                ),
              );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _tabController.dispose();
  }
}

class ResultSearch extends StatefulWidget {
  String searchText;

  ResultSearch(this.searchText);

  @override
  _ResultSearchState createState() => _ResultSearchState();
}

class _ResultSearchState extends State<ResultSearch>
    with AutomaticKeepAliveClientMixin {
  String username;
  String avatar;

  var refreshKey = GlobalKey<RefreshIndicatorState>();

  List<PostModel> listPostModel = new List();
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    StorageUtil.getUsername().then((value) => setState(() {
          username = value;
        }));
    StorageUtil.getAvatar().then((value) => setState(() {
          avatar = value;
        }));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => isLoading = true);
      await search(onSuccess: (values) {
        setState(() {
          isLoading = false;
          listPostModel = values;
          postController = new List(listPostModel.length);
        });
      }, onError: (msg) {
        setState(() => isLoading = false);
        print(msg);
      });
    });
  }

  List<PostModel> parsePosts(Map<String, dynamic> json) {
    List<PostModel> temp;
    try {
      temp = List<PostModel>.from(
          json['data'].map((x) => PostModel.fromJson(x)).toList());
    } catch (e) {
      print(e.toString());
    }
    return temp;
  }

  Future<void> search(
      {Function(List<PostModel>) onSuccess, Function(String) onError}) async {
    List<PostModel> list = List();
    try {
      await FetchData.searchApi(await StorageUtil.getToken(), widget.searchText,
              await StorageUtil.getUid(), 0, 10)
          .then((value) {
        if (value.statusCode == 200) {
          var val = jsonDecode(value.body);
          print(val);
          if (val["code"] == 1000) {
            list = parsePosts(val);
            onSuccess(list);
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

  @override
  Widget build(BuildContext context) {
    return buildAllSearch();
  }

  Widget buildAllSearch() {
    return Container(
      color: Colors.grey[300],
      child: isLoading
          ? LoadingNewFeed()
          : listPostModel.length == 0
              ? Container(
                  padding: EdgeInsets.only(top: 100),
                  child: Column(
                    children: [
                      Icon(
                        Icons.search,
                        size: 100,
                        color: Colors.grey[100],
                      ),
                      Text("Rất tiếc, chúng tôi không tìm thấy kết"),
                      Text("quả nào phù hợp"),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.only(top: 3),
                  physics: ScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: listPostModel.length,
                  itemBuilder: (context, index) {
                    return PostWidget(
                      post: listPostModel[index],
                      controller: new PostController(),
                      username: username,
                    );
                  }),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
