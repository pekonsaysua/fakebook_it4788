import 'package:emoji_picker/emoji_picker.dart';
import 'package:fakebook_flutter_app/src/apis/api_send.dart';
import 'package:fakebook_flutter_app/src/helpers/colors_constant.dart';
import 'package:fakebook_flutter_app/src/helpers/epandaple_text.dart';
import 'package:fakebook_flutter_app/src/helpers/parseDate.dart';
import 'package:fakebook_flutter_app/src/helpers/read_more_text.dart';
import 'package:fakebook_flutter_app/src/helpers/shared_preferences.dart';
import 'package:fakebook_flutter_app/src/models/comment.dart';
import 'package:fakebook_flutter_app/src/models/post.dart';
import 'package:fakebook_flutter_app/src/views/HomePage/TabBarView/HomeTab/home_tab_controller.dart';
import 'package:fakebook_flutter_app/src/views/HomePage/TabBarView/HomeTab/post_widget_controller.dart';
import 'package:fakebook_flutter_app/src/views/Profile/friend_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../helpers/parseDate.dart';
import 'package:readmore/readmore.dart';

import '../loading_shimmer.dart';

HomeController homeController = new HomeController();

class CommentWidget extends StatefulWidget {
  PostModel post;
  PostController controller;
  String username;
  bool autoFocus;

  CommentWidget(this.post, this.controller, this.username, this.autoFocus);

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget>
    with AutomaticKeepAliveClientMixin {
  ScrollController _scrollController = new ScrollController();

  TextEditingController _textEditingController = new TextEditingController();
  var numLines = 1;
  bool isLoading = false;
  bool isError = false;

  var myComment = "";

  String username;
  String avatar;
  var myListComment = new List<CommentModel>();

  static const _pageSize = 2;

  final PagingController<int, CommentModel> _pagingController =
      PagingController(firstPageKey: 0, invisibleItemsThreshold: 1);

  @override
  void initState() {
    StorageUtil.getUsername().then((value) => setState(() {
          username = value;
        }));
    StorageUtil.getAvatar().then((value) => setState(() {
          avatar = value;
        }));

    _pagingController.addPageRequestListener((pageKey) {
      _fetchComment(pageKey);
    });
    super.initState();
  }

  List<CommentModel> parseComment(Map<String, dynamic> json) {
    List<CommentModel> temp;
    try {
      temp =
          (json['data'] as List).map((x) => CommentModel.fromJson(x)).toList();
    } catch (e) {
      print(e.toString());
    }
    return temp;
  }

  Future<void> _fetchComment(int pageKey) async {
    try {
      await ApiService.getComment(
              await StorageUtil.getToken(), widget.post.id, pageKey, _pageSize)
          .then((val) {
        if (val["code"] == 1000) {
          final newItems = parseComment(val);
          final isLastPage = newItems.length < _pageSize;
          if (isLastPage) {
            _pagingController.appendLastPage(newItems);
          } else {
            final nextPageKey = pageKey + newItems.length;
            _pagingController.appendPage(newItems, nextPageKey);
          }
        } else {
          _pagingController.error = "jvsvn";
        }
      });
    } catch (error) {
      _pagingController.error = error;
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.only(top: 10),
      bottom: true,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        //resizeToAvoidBottomPadding: true,
        body: widget.post.comment == "0"
            ? Column(
                children: [
                  if (widget.post.like != "0") bottomSheetHeader(),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(top: 100),
                      child: Column(
                        children: [
                          Icon(Icons.mode_comment, size: 150, color: Colors.grey[200],),
                          Text(
                              "Chưa có bình luận nào", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: kColorGrey),),
                          Text("Hãy là người đầu tiên bình luận"),
                        ],
                      ),
                    ),
                  ),
                  bottomSheetFooter(),
                ],
              )
            : Column(
                children: [
                  bottomSheetHeader(),
                  Expanded(child: bottomSheetComment(context)),
                  bottomSheetFooter(),
                ],
              ),
        //bottomSheet: bottomSheetFooter(),
      ),
    );
  }

  Widget bottomSheetHeader() {
    return StreamBuilder(
        stream: widget.controller.isLikedStream,
        builder: (context, snapshot1) {
          var data1 = snapshot1.data ?? widget.post.is_liked;
          return StreamBuilder(
              stream: widget.controller.likeNumberStream,
              builder: (context, snapshot2) {
                var data2 = snapshot2.data ?? widget.post.like;
                return Container(
                  margin: EdgeInsets.only(top: 0),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: kColorGrey, width: 0.4)),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.thumb_up_alt_outlined,
                                size: 14, color: kColorBlack),
                            SizedBox(
                              width: 2,
                            ),
                            data1
                                ? data2 == "1"
                                    ? Text(
                                        widget.username,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: kColorBlack),
                                      )
                                    : Text(
                                        "Bạn và " +
                                            "${int.parse(data2) - 1}" +
                                            " người khác",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: kColorBlack),
                                      )
                                : Text(data2,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: kColorBlack)),
                            SizedBox(
                              width: 8,
                            ),
                            Icon(
                              Icons.arrow_forward_ios_outlined,
                              color: kColorBlack,
                            ),
                          ],
                        ),
                        IconButton(
                            onPressed: () {
                              widget.controller
                                  .likeBehavior(!data1, data2, widget.post.id);
                            },
                            icon: data1
                                ? Icon(
                                    FontAwesomeIcons.solidThumbsUp,
                                    size: 20.0,
                                    color: kColorBlue,
                                  )
                                : Icon(
                                    FontAwesomeIcons.thumbsUp,
                                    size: 20.0,
                                    color: kColorBlack,
                                  )),
                      ],
                    ),
                  ),
                );
              });
        });
  }

  Widget bottomSheetFooter() {
    return ConstrainedBox(
      constraints: new BoxConstraints(
        minHeight: 8,
        maxHeight: 106,
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(width: 0.6, color: kColorGrey)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
                padding: EdgeInsets.only(bottom: 5),
                child: GestureDetector(
                  child: Icon(
                    Icons.camera_alt_outlined,
                    size: 32,
                  ),
                )),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(numLines == 1 ? 45 : 20),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textEditingController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: "Viết bình luận...",
                        border: InputBorder.none,
                      ),
                      autofocus: widget.autoFocus,
                      onChanged: (value) {
                        setState(() {
                          numLines = '\n'.allMatches(value).length + 1;
                        });
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        GestureDetector(
                          child: Icon(Icons.emoji_emotions_outlined),
                          onTap: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (_) {
                                  return SizedBox(
                                    height: 235,
                                    child: EmojiPicker(
                                      rows: 3,
                                      columns: 7,
                                      buttonMode: ButtonMode.MATERIAL,
                                      numRecommended: 10,
                                      onEmojiSelected: (emoji, category) {
                                        _textEditingController.text +=
                                            emoji.emoji;
                                        print(emoji.emoji);
                                      },
                                    ),
                                  );
                                });
                          },
                        ),
                        SizedBox(
                          width: 7,
                        ),
                        GestureDetector(
                            onTap: () async {
                              if (_textEditingController.text != "") {
                                setState(() {
                                  myComment = _textEditingController.text;
                                  _textEditingController.text = "";
                                  widget.autoFocus = false;
                                  isLoading = true;
                                  isError = false;
                                });
                                if (_scrollController.hasClients)
                                  _scrollController.animateTo(
                                    _scrollController.position.maxScrollExtent,
                                    duration: Duration(seconds: 1),
                                    curve: Curves.fastOutSlowIn,
                                  );
                                await widget.controller
                                    .setComment(widget.post.id, myComment,
                                        widget.post.comment)
                                    .then((value) async {
                                  if (value == "ok") {
                                    setState(() {
                                      widget.post.comment =
                                          "${int.parse(widget.post.comment) + 1}";
                                      isLoading = false;
                                    });
                                    myListComment.clear();
                                    var b = new CommentModel(
                                        widget.post.id,
                                        new CommentPoster(
                                            await StorageUtil.getUid(),
                                            await StorageUtil.getAvatar(),
                                            await StorageUtil.getUsername()),
                                        myComment,
                                        DateTime.now().toString());
                                    myListComment.add(b);
                                    _pagingController
                                        .appendLastPage(myListComment);
                                  } else if (value == "loi mang") {
                                    setState(() {
                                      isLoading = false;
                                      isError = true;
                                    });
                                  }
                                });
                              }
                            },
                            child: Icon(
                              Icons.send,
                              color: kColorBlue,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomSheetComment(context) {
    return ListView(
      children: [
        PagedListView<int, CommentModel>(
          scrollController: _scrollController,
          physics: ScrollPhysics(),
          padding: EdgeInsets.all(0),
          shrinkWrap: true,
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<CommentModel>(
            itemBuilder: (context, item, index) => ListTile(
              leading: GestureDetector(
                onTap: () async {
                  var myId = await StorageUtil.getUid();
                  if (item.poster.id == myId) {
                    Navigator.pushNamed(context, 'profile_page',
                        arguments: myId);
                  } else
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FriendProfile(
                                  friendId: item.poster.id,
                                )));
                },
                child: CircleAvatar(
                  backgroundColor: kColorGrey,
                  radius: 25.0,
                  backgroundImage: item.poster.avatar == null
                      ? AssetImage('assets/avatar.jpg')
                      : NetworkImage(item.poster.avatar),
                ),
              ),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  new Container(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      color: Colors.grey[300],
                    ),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            item.poster.username,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ExpandableText(
                            item.comment,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text(ParseDate.parse(item.created)),
                      FlatButton(
                        minWidth: 10,
                        height: 5,
                        padding: EdgeInsets.all(0),
                        onPressed: () {},
                        child: Text(
                          "Thích",
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      FlatButton(
                        minWidth: 10,
                        height: 5,
                        padding: EdgeInsets.all(0),
                        onPressed: () {},
                        child: Text(
                          "Trả lời",
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            firstPageProgressIndicatorBuilder: (_) => LoadingComment(),
          ),
        ),
        if (isLoading)
          ListTile(
            leading: GestureDetector(
              onTap: () {
                print(username);
              },
              child: CircleAvatar(
                backgroundColor: kColorGrey,
                radius: 25.0,
                backgroundImage: avatar == null
                    ? AssetImage('assets/avatar.jpg')
                    : NetworkImage(avatar),
              ),
            ),
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                new Container(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    color: Colors.grey[300],
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          username,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ExpandableText(
                          myComment,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [Text("Đang đăng...")],
                )
              ],
            ),
          ),
        if (isError)
          Center(
            child: Column(
              children: [
                Text("Viet binh luan trong khi offline"),
              ],
            ),
          ),
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
