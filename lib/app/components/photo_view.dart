import 'package:cached_network_image/cached_network_image.dart';
import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

class PhotoViewScreen extends StatefulWidget {
  final String imageUrl;
  final String heroId;
  const PhotoViewScreen(
      {super.key, required this.imageUrl, required this.heroId});

  @override
  State<PhotoViewScreen> createState() => _PhotoViewScreenState();
}

class _PhotoViewScreenState extends State<PhotoViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Preview',
          style: TextStyle(color: AppColors.onPrimaryLight),
        ),
        backgroundColor: AppColors.primaryLight,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.chevron_left, color: AppColors.onPrimaryLight),
          iconSize: 30,
        ),
      ),
      body: Container(
        color: AppColors.onPrimaryLight, // Background color for better contrast
        child: PhotoView(
          imageProvider: CachedNetworkImageProvider(widget.imageUrl),
          heroAttributes: PhotoViewHeroAttributes(tag: widget.heroId),
          backgroundDecoration: BoxDecoration(
            color:
                AppColors.onPrimaryLight, // Matches the surrounding container
          ),
          loadingBuilder: (context, event) {
            return Center(
              child: CircularProgressIndicator(
                value: event == null
                    ? null
                    : event.cumulativeBytesLoaded /
                        (event.expectedTotalBytes ?? 1),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Text(
                'Failed to load image',
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }
}
