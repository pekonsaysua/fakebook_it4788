import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class SingleImageView extends StatefulWidget {
  String url;

  SingleImageView(this.url);

  @override
  _SingleImageViewState createState() => _SingleImageViewState();
}

class _SingleImageViewState extends State<SingleImageView> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: PhotoViewGallery.builder(
      scrollPhysics: const BouncingScrollPhysics(),
      builder: (BuildContext context, int index) {
        return PhotoViewGalleryPageOptions(
          imageProvider: widget.url == null
              ? AssetImage("assets/avatar.jpg")
              : NetworkImage(widget.url),
          heroAttributes: PhotoViewHeroAttributes(tag: "Anh dai dien"),
          minScale: PhotoViewComputedScale.contained * 0.9,
          maxScale: PhotoViewComputedScale.contained * 2,
          initialScale: PhotoViewComputedScale.contained * 0.9,
        );
      },
      itemCount: 1,
      loadingBuilder: (context, event) => Center(
        child: Container(
          width: 20.0,
          height: 20.0,
          child: CircularProgressIndicator(
            value: event == null
                ? 0
                : event.cumulativeBytesLoaded / event.expectedTotalBytes,
          ),
        ),
      ),
    ));
  }
}

// ...
