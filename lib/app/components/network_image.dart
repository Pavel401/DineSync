import 'package:cached_network_image/cached_network_image.dart';
import 'package:cho_nun_btk/app/constants/colors.dart';
import 'package:flutter/material.dart';

class CustomNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double size; // Size for both height and width for circular images
  final bool isCircular; // Whether the image should be circular
  final double borderWidth; // Border width for circular images
  final Color borderColor; // Border color
  final BoxFit fit; // Image fit
  final Widget? errorWidget; // Custom widget for error handling
  final Widget? placeholder; // Custom placeholder while loading

  const CustomNetworkImage({
    Key? key,
    required this.imageUrl,
    required this.size,
    this.isCircular = false,
    this.borderWidth = 2.0,
    this.borderColor = AppColors.primaryLight,
    this.fit = BoxFit.cover,
    this.errorWidget,
    this.placeholder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isCircular
        ? Container(
            height: size,
            width: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor,
                width: borderWidth,
              ),
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                height: size,
                width: size,
                fit: fit,
                placeholder: (context, url) =>
                    placeholder ?? const CircularProgressIndicator(),
                errorWidget: (context, url, error) =>
                    errorWidget ??
                    Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, color: Colors.red),
                    ),
              ),
            ),
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              height: size,
              width: size,
              fit: fit,
              placeholder: (context, url) =>
                  placeholder ?? const CircularProgressIndicator(),
              errorWidget: (context, url, error) =>
                  errorWidget ??
                  Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, color: Colors.red),
                  ),
            ),
          );
  }
}
