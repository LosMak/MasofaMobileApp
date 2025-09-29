import 'package:cached_network_image/cached_network_image.dart';
import 'package:dala_ishchisi/common/constants/app_constants.dart';
import 'package:dala_ishchisi/common/constants/app_globals.dart';
import 'package:dala_ishchisi/common/widgets/custom_shimmer.dart';
import 'package:flutter/material.dart';

class CustomMapImage extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double zoom;
  final double imageWidth;
  final double imageHeight;

  const CustomMapImage({
    super.key,
    required this.latitude,
    required this.longitude,
    this.zoom = 12,
    this.imageWidth = 250,
    this.imageHeight = 250,
  });

  @override
  Widget build(BuildContext context) {
    final lang = AppGlobals.lang == 'en' ? 'en_US' : 'ru_RU';
    String mapUrl = 'https://static-maps.yandex.ru/v1?'
        'll=$longitude,$latitude'
        '&lang=$lang'
        '&size=${imageWidth.toInt()},${imageHeight.toInt()}'
        '&z=${zoom.toInt()}'
        '&pt=$longitude,$latitude,pm2dom1'
        '&apikey=${AppConstants.yandexApiKey}';

    return CachedNetworkImage(
      imageUrl: mapUrl,
      placeholder: (context, url) => CustomShimmer(
        child: Icon(Icons.image_outlined, size: imageWidth * 0.7),
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }
}
