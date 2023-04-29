import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fakebook_flutter_app/src/apis/api_send.dart';
import 'package:fakebook_flutter_app/src/helpers/fetch_data.dart';
import 'package:fakebook_flutter_app/src/helpers/internet_connection.dart';
import 'package:fakebook_flutter_app/src/helpers/parseDate.dart';
import 'package:fakebook_flutter_app/src/helpers/shared_preferences.dart';
import 'package:fakebook_flutter_app/src/helpers/validator.dart';
import 'package:fakebook_flutter_app/src/models/post.dart';
import 'package:fakebook_flutter_app/src/models/user.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:platform_device_id/platform_device_id.dart';

class CreatePostController {
  StreamController _addPost = new StreamController.broadcast();
  Stream get addPostStream => _addPost.stream;

  String error;

  Future<PostModel> onSubmitCreatePost(
      {final List<MultipartFile> images,
      final MultipartFile video,
      final String described,
      final String status,
      final String state,
      final bool can_edit,
      final String asset_type}) async {
    PostModel post;
    try {
      await ApiService.createPost(await StorageUtil.getToken(), images, video,
              described, status, state, can_edit, asset_type)
          .then((val) async {
        if (val["code"] == 1000) {
          var json = await val["data"];
          post = new PostModel(
            asset_type == 'video' ? VideoPost.fromJson(json['video']) : null,
            [],
            [],
            json["_id"],
            described,
            state,
            status,
            ParseDate.parse(json["created"]),
            json["modified"],
            json["like"].toString(),
            json["is_liked"],
            json["comment"].toString(),
            AuthorPost(await StorageUtil.getUid(),
                await StorageUtil.getAvatar(), await StorageUtil.getUsername()),
            List<ImagePost>.from(
                json['image'].map((x) => ImagePost.fromJson(x)).toList()),
          );
          //print(post.toJson());
        } else {}
      });
    } catch (e) {
      print(e.toString());
    }
    return post;
  }

  void dispose() {
    _addPost.close();
  }
}
