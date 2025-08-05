import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yay_thant/function_provider.dart';

final _provider = Functionprovider();

class CustomAvater extends StatelessWidget {
  final String? imageURL;
  final String name;
  final double radius;
  final double fontSize;
  const CustomAvater({
    super.key,
    this.imageURL,
    required this.name,
    required this.radius,
    required this.fontSize,
  });
  @override
  Widget build(BuildContext context) {
    return imageURL != null && imageURL!.isNotEmpty
        ? ClipOval(
            child: CachedNetworkImage(
              imageUrl: imageURL!,
              width: radius,
              height: radius,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                // radius: radius,
                // backgroundColor: _provider.getBackgroundColor(name),
                width: radius,
                height: radius,
                decoration: BoxDecoration(
                  color: _provider.getBackgroundColor(name),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: Text(
                    name.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                      color: _provider.getTextColor(name),
                    ),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: radius,
                height: radius,
                decoration: BoxDecoration(
                  color: _provider.getBackgroundColor(name),
                  borderRadius: BorderRadius.circular(50),
                ),
                // radius: radius,
                // backgroundColor: _provider.getBackgroundColor(name),
                child: Center(
                  child: Text(
                    name.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                      color: _provider.getTextColor(name),
                    ),
                  ),
                ),
              ),
            ),
          )
        : Container(
            // radius: radius,
            // backgroundColor: _provider.getBackgroundColor(name),
            width: radius,
            height: radius,
            decoration: BoxDecoration(
              color: _provider.getBackgroundColor(name),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Center(
              child: Text(
                name.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
                  color: _provider.getTextColor(name),
                ),
              ),
            ),
          );
  }
}
