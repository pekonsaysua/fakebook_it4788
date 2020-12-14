import 'dart:convert';

import 'package:fakebook_flutter_app/src/helpers/colors_constant.dart';
import 'package:fakebook_flutter_app/src/helpers/fetch_data.dart';
import 'package:fakebook_flutter_app/src/helpers/parseDate.dart';
import 'package:fakebook_flutter_app/src/helpers/shared_preferences.dart';
import 'package:fakebook_flutter_app/src/widgets/loading_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class ActivityDiary extends StatefulWidget {
  @override
  _ActivityDiaryState createState() => _ActivityDiaryState();
}

class _ActivityDiaryState extends State<ActivityDiary> {
  var refreshKey = GlobalKey<RefreshIndicatorState>();

  List<dynamic> notifications = new List();

  bool isLoading = false;

  static const _pageSize = 2;

  final PagingController<int, dynamic> _pagingController = PagingController(
    firstPageKey: 0,
    invisibleItemsThreshold: 1,
  );

  var date1, date2;
  bool isDupllicate;
  bool isDelete;

  @override
  void initState() {
    // TODO: implement initState
    _pagingController.addPageRequestListener((pageKey) {
      getActivityDiary(pageKey);
    });
    super.initState();
  }

  Future<void> getActivityDiary(int pageKey) async {
    try {
      await FetchData.getSaveSearchApi(
              await StorageUtil.getToken(), pageKey, _pageSize)
          .then((value) {
        if (value.statusCode == 200) {
          var val = jsonDecode(value.body);
          if (val["code"] == 1000) {
            final newItems = val['data'];
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
        } else {
          _pagingController.error = "error server";
        }
      });
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_outlined,
            color: kColorBlack,
          ),
        ),
        title: Text(
          "Nhật ký hoạt động",
          style: TextStyle(color: kColorBlack),
        ),
        elevation: 0.0,
        backgroundColor: kColorWhite,
      ),
      //backgroundColor: kColorWhite,
      body: Container(
        child: RefreshIndicator(
          onRefresh: () async {
            refreshKey.currentState?.show(atTop: false);
            Future.sync(
              () => _pagingController.refresh(),
            );
            setState(() {
              isLoading = false;
            });
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                  child: FlatButton(
                padding: EdgeInsets.all(0),
                onPressed: () {
                  setState(() {
                    //_pagingController.itemList.clear();
                  });
                },
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                      border: Border.symmetric(horizontal: BorderSide(width: 0.2, color: kColorGrey))),
                  child: Center(
                    child: Text("Xóa các tìm kiếm"),
                  ),
                ),
              )),
              PagedSliverList<int, dynamic>(
                pagingController: _pagingController,
                builderDelegate: PagedChildBuilderDelegate<dynamic>(
                  itemBuilder: (context, item, index) {
                    if (date1 != ParseDate.parse(item["created"])) {
                      date1 = ParseDate.parse(item["created"]);
                      isDupllicate = false;
                    } else {
                      isDupllicate = true;
                    }

                    return Column(
                      children: [
                        if (!isDupllicate)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  ParseDate.parse(date1),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                          ),
                        ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 10),
                          leading: GestureDetector(
                            onTap: () {
                              print(index);
                            },
                            child: CircleAvatar(
                              backgroundColor: kColorBlue,
                              radius: 25.0,
                              child: Icon(Icons.search),
                            ),
                          ),
                          title: Padding(
                            padding: const EdgeInsets.all(0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                new Container(
                                  padding: EdgeInsets.symmetric(horizontal: 0),
                                  child: Column(
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "Bạn đã tìm kiếm trên facebook",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          '"' + item["keyword"] + '"',
                                          style: TextStyle(
                                              color: Colors.grey[600]),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 0),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Chỉ mình tôi",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        " . Đã ẩn khỏi trang cá nhân",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          trailing: Padding(
                            padding: const EdgeInsets.all(0),
                            child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _pagingController.itemList.removeAt(index);
                                  });
                                },
                                icon: Icon(Icons.clear)),
                          ),
                        ),
                      ],
                    );
                  },
                  firstPageProgressIndicatorBuilder: (_) => LoadingNewFeed(),
                  //newPageProgressIndicatorBuilder: (_) => NewPageProgressIndicator(),
                  noItemsFoundIndicatorBuilder: (_) => Center(
                    child: Text(_pagingController.error),
                  ),
                  //noMoreItemsIndicatorBuilder: (_) => NoMoreItemsIndicator(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
