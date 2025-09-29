import 'package:dala_ishchisi/common/localization/localization.dart';
import 'package:dala_ishchisi/common/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomMapTypes extends StatelessWidget {
  final MapType mapType;
  final Function(MapType mapType)? onChange;

  const CustomMapTypes({
    super.key,
    this.mapType = MapType.satellite,
    this.onChange,
  });

  final _mapTypes = const <MapType>[
    MapType.terrain,
    MapType.satellite,
    MapType.hybrid
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: ListView.separated(
              itemCount: _mapTypes.length,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              separatorBuilder: (_, i) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final model = _mapTypes[i];
                return CupertinoButton(
                  minSize: 0,
                  padding: EdgeInsets.zero,
                  onPressed: () => onChange?.call(model),
                  child: Column(
                    spacing: 4,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        alignment: Alignment.center,
                        decoration: ShapeDecoration(
                          color: AppColors.blue.shade1.withAlpha(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: model == mapType
                                  ? AppColors.blue.shade3
                                  : AppColors.blue.shade1,
                              width: 2,
                            ),
                          ),
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/${_mapTypes[i].name}.svg',
                          height: 24,
                          colorFilter: ColorFilter.mode(
                            AppColors.blue.shade5,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      Text(
                        str(_mapTypes[i].name),
                        style: TextStyle(
                          color: model == mapType
                              ? AppColors.blue.shade5
                              : AppColors.gray.shade9,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
