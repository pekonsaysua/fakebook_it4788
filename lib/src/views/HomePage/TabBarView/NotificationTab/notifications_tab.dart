import 'dart:convert';

import 'package:fakebook_flutter_app/src/apis/api_send.dart';
import 'package:fakebook_flutter_app/src/helpers/colors_constant.dart';
import 'package:fakebook_flutter_app/src/helpers/fetch_data.dart';
import 'package:fakebook_flutter_app/src/helpers/shared_preferences.dart';
import 'package:fakebook_flutter_app/src/views/HomePage/TabBarView/NotificationTab/notifications_controller.dart';
import 'package:fakebook_flutter_app/src/widgets/loading_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:fakebook_flutter_app/src/widgets/notification_widget.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class NotificationsTab extends StatefulWidget {
  @override
  _NotificationsTabState createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab>
    with AutomaticKeepAliveClientMixin {
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  NotificationController notificationController = new NotificationController();

  List<dynamic> notifications = new List();

  bool isLoading = false;

  static const _pageSize = 2;

  final PagingController<int, dynamic> _pagingController = PagingController(
    firstPageKey: 0,
    invisibleItemsThreshold: 1,
  );

  @override
  void initState() {
    // TODO: implement initState

    _pagingController.addPageRequestListener((pageKey) {
      getNotification(pageKey);
    });
    super.initState();
  }

  Future<void> getNotification(int pageKey) async {
    try {
      await FetchData.getNotification(await StorageUtil.getToken(),
              pageKey.toString(), _pageSize.toString())
          .then((value) {
        if (value.statusCode == 200) {
          var val = jsonDecode(value.body);
          print(val);
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

  Future<void> _refresh() async {
    refreshKey.currentState?.show(atTop: false);
    setState(() => isLoading = true);
    await notificationController.getNotification(onSuccess: (values) {
      setState(() {
        isLoading = false;
        notifications = values;
      });
    }, onError: (msg) {
      setState(() => isLoading = false);
      print(msg);
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      color: kColorWhite,
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
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 15.0, 0.0, 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Thông báo',
                        style: TextStyle(
                            fontSize: 25.0, fontWeight: FontWeight.bold)),
                    Container(
                      decoration: new BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.search),
                        color: Colors.black,
                        tooltip: 'search',
                        onPressed: () {
                          Navigator.pushNamed(
                              context, "home_search_screen");
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            PagedSliverList<int, dynamic>(
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<dynamic>(
                itemBuilder: (context, item, index) {
                  return NotificationWidget(notification: item);
                },
                firstPageProgressIndicatorBuilder: (_) => LoadingNewFeed(),
                //newPageProgressIndicatorBuilder: (_) => NewPageProgressIndicator(),
                //noItemsFoundIndicatorBuilder: (_) =>
                //noMoreItemsIndicatorBuilder: (_) => NoMoreItemsIndicator(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /*

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorWhite,
      body: RefreshIndicator(
          key: refreshKey,
          onRefresh: _refresh,
          child: isLoading
              ? LoadingNewFeed()
              : ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.only(top: 0),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15.0, 15.0, 0.0, 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Thông báo',
                              style: TextStyle(
                                  fontSize: 25.0, fontWeight: FontWeight.bold)),
                          Container(
                            decoration: new BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.search),
                              color: Colors.black,
                              tooltip: 'search',
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, "home_search_screen");
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    for (var notification in notifications)
                      NotificationWidget(notification: notification)
                  ],
                )),
    );
  }

  */

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
