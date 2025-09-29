import 'package:dala_ishchisi/application/bid/bid_bloc.dart';
import 'package:dala_ishchisi/common/theme/app_colors.dart';
import 'package:dala_ishchisi/common/widgets/custom_map_image.dart';
import 'package:dala_ishchisi/domain/models/meta_model.dart';
import 'package:dala_ishchisi/main.dart';
import 'package:dala_ishchisi/presentation/pages/map/map_page.dart';
import 'package:dala_ishchisi/presentation/routes/app_router.gr.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroicons/heroicons.dart';

class TaskLocation extends StatelessWidget {
  const TaskLocation({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BidBloc, BidState>(
      buildWhen: (old, e) => old.bid != e.bid,
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Region, District
            if (state.bid.district.nameStr.isNotEmpty)
              Row(
                spacing: 6,
                children: [
                  HeroIcon(
                    HeroIcons.mapPin,
                    color: AppColors.gray.shade5,
                    size: 18,
                  ),
                  Expanded(
                    child: Text(
                      "${state.bid.region.nameStr}, ${state.bid.district.nameStr}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.gray.shade5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            if (state.bid.district.nameStr.isNotEmpty)
              const SizedBox(height: 16),

            /// Map
            CupertinoButton(
              minSize: 0,
              padding: EdgeInsets.zero,
              onPressed: () {
                router.push(MapRoute(
                  title: state.bid.description,
                  location: Location(lat: state.bid.lat, long: state.bid.lng),
                  regionId: state.bid.regionId,
                ));
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: Stack(
                    children: [
                      CustomMapImage(
                        latitude: state.bid.lat,
                        longitude: state.bid.lng,
                        imageWidth: MediaQuery.sizeOf(context).width - 64,
                        imageHeight: 200,
                      ),
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        alignment: Alignment.center,
                        color: Colors.black.withAlpha(70),
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          width: 120,
                          padding: const EdgeInsets.all(8),
                          decoration: ShapeDecoration(
                            color: AppColors.gray.shade0.withAlpha(40),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: AppColors.gray.shade0,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            shadows: const [
                              BoxShadow(
                                color: Color(0x1118274B),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                                spreadRadius: -2,
                              ),
                              BoxShadow(
                                color: Color(0x0A18274B),
                                blurRadius: 7,
                                offset: Offset(0, 2),
                                spreadRadius: -2,
                              ),
                            ],
                          ),
                          child: Column(
                            spacing: 8,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                spacing: 8,
                                children: [
                                  const Text(
                                    'X',
                                    style: TextStyle(
                                      fontFeatures: [
                                        FontFeature.tabularFigures(),
                                      ],
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${state.bid.lat}',
                                      style: const TextStyle(
                                        fontFeatures: [
                                          FontFeature.tabularFigures(),
                                        ],
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                spacing: 8,
                                children: [
                                  const Text(
                                    'Y',
                                    style: TextStyle(
                                      fontFeatures: [
                                        FontFeature.tabularFigures(),
                                      ],
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "${state.bid.lng}",
                                      style: const TextStyle(
                                        fontFeatures: [
                                          FontFeature.tabularFigures(),
                                        ],
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
