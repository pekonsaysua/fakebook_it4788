import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fakebook_flutter_app/src/apis/api_send.dart';
import 'package:fakebook_flutter_app/src/helpers/colors_constant.dart';
import 'package:fakebook_flutter_app/src/helpers/fetch_data.dart';
import 'package:fakebook_flutter_app/src/helpers/shared_preferences.dart';
import 'package:fakebook_flutter_app/src/models/post.dart';
import 'package:fakebook_flutter_app/src/views/CreatePost/create_post_controller.dart';
import 'package:fakebook_flutter_app/src/views/HomePage/TabBarView/HomeTab/home_tab.dart';
import 'package:fakebook_flutter_app/src/views/HomePage/TabBarView/HomeTab/post_widget_controller.dart';
import 'package:fakebook_flutter_app/src/widgets/loading_shimmer.dart';
import 'package:fakebook_flutter_app/src/widgets/post/header_post_widget.dart';
import 'package:fakebook_flutter_app/src/widgets/post/post_widget.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class CharacterListView extends StatefulWidget {
  @override
  _CharacterListViewState createState() => _CharacterListViewState();
}

class _CharacterListViewState extends State<CharacterListView>
    with AutomaticKeepAliveClientMixin {
  String username;
  String avatar;

  var refreshKey = GlobalKey<RefreshIndicatorState>();

  static const _pageSize = 1;

  final PagingController<int, PostModel> _pagingController = PagingController(
    firstPageKey: 0,
    invisibleItemsThreshold: 1,
  );

  @override
  void initState() {
    postController = new List();
    StorageUtil.getUsername().then((value) => setState(() {
          username = value;
        }));
    StorageUtil.getAvatar().then((value) => setState(() {
          avatar = value;
        }));

    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
    _getConversations();
  }

  Future<void> _getConversations() async {
    var res = await FetchData.getListConversation(
        await StorageUtil.getToken(), "0", "20");
    var data = await jsonDecode(res.body);
    print(data);
    if (res.statusCode == 200) {
      // friends = data["data"]["friends"];
      StorageUtil.setConversations(data["data"]);
    } else {
      print("Lỗi server");
    }
  }

  List<PostModel> parsePosts(Map<String, dynamic> json) {
    List<PostModel> temp;
    try {
      temp = (json['posts'] as List).map((x) => PostModel.fromJson(x)).toList();
    } catch (e) {
      print(e.toString());
    }
    return temp;
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      await ApiService.getListPosts(await StorageUtil.getToken(), pageKey, 2)
          .then((val) {
        if (val["code"] == 1000) {
          final newItems = parsePosts(val['data']);
          final isLastPage = newItems.length < _pageSize;
          if (isLastPage) {
            _pagingController.appendLastPage(newItems);
          } else {
            final nextPageKey = pageKey + newItems.length;
            _pagingController.appendPage(newItems, nextPageKey);
          }
        } else {
          _pagingController.error = "No data";
        }
      });
    } catch (error) {
      _pagingController.error = error;
    }
  }
/*
  @override
  void didUpdateWidget(CharacterListView oldWidget) {
    if (oldWidget._pagingController != widget._pagingController) {
      _pagingController.refresh();
    }
    super.didUpdateWidget(oldWidget);
  }

 */

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: () async {
          refreshKey.currentState?.show(atTop: false);
          Future.sync(
            () => _pagingController.refresh(),
          );
          setState(() {
            list.clear();
            isLoading = false;
          });
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  buildCreatePost(),
                  buildPostReturn(),
                ],
              ),
            ),
            PagedSliverList<int, PostModel>(
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<PostModel>(
                itemBuilder: (context, item, index) {
                  return PostWidget(
                    post: item,
                    controller: new PostController(),
                    username: username,
                  );
                },
                firstPageProgressIndicatorBuilder: (_) => LoadingNewFeed(),
                //newPageProgressIndicatorBuilder: (_) => NewPageProgressIndicator(),
                //noMoreItemsIndicatorBuilder: (_) => NoMoreItemsIndicator(),
              ),
            ),
          ],
        ),
      );

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  bool isLoading = false;
  List<PostModel> list = new List();
  CreatePostController createPostController = new CreatePostController();

  Widget buildCreatePost() {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: kColorWhite,
      margin: EdgeInsets.all(0),
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: Row(
        //mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            child: CircleAvatar(
              backgroundColor: kColorGrey,
              radius: 28.0,
              backgroundImage: avatar == null
                  ? AssetImage('assets/avatar.jpg')
                  : NetworkImage(avatar),
            ),
          ),
          SizedBox(width: 15.0),
          FlatButton(
            padding: EdgeInsets.only(
                right: MediaQuery.of(context).size.width / 3, left: 30),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                  color: Colors.grey, width: 1, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              'Bạn đang nghĩ gì?',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            onPressed: () {
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
                      isLoading = false;
                      list.insert(0, val);
                    });
                  });
                }
              });
            },
          )
        ],
      ),
    );
  }

  Widget buildPostReturn() {
    print(isLoading);
    if (list.isEmpty) {
      print(isLoading.toString() + "empty");
      if (isLoading) {
        if (isLoading == true)
          return Container(
            height: 60,
            margin: EdgeInsets.only(top: 8),
            color: kColorWhite,
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: kColorGrey,
                  radius: 20.0,
                  backgroundImage: avatar == null
                      ? AssetImage('assets/avatar.jpg')
                      : NetworkImage(avatar),
                ),
                SizedBox(width: 7.0),
                Text(username,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0)),
                //SizedBox(height: 0.0),
                Expanded(child: SizedBox()),
                CircularProgressIndicator(),
              ],
            ),
          );
      } else {
        return SizedBox.shrink();
      }
    } else
      return Column(
        children: [
          if (isLoading == true)
            Container(
              height: 60,
              margin: EdgeInsets.only(top: 8),
              color: kColorWhite,
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: kColorGrey,
                    radius: 20.0,
                    backgroundImage: avatar == null
                        ? AssetImage('assets/avatar.jpg')
                        : NetworkImage(avatar),
                  ),
                  SizedBox(width: 7.0),
                  Text(username,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17.0)),
                  //SizedBox(height: 0.0),
                  Expanded(child: SizedBox()),
                  CircularProgressIndicator(),
                ],
              ),
            ),
          Column(
            children: [
              for (var i in list)
                PostWidget(
                  username: username,
                  controller: new PostController(),
                  post: i,
                )
            ],
          ),
        ],
      );
  }
}
