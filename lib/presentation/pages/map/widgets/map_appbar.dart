import 'package:dala_ishchisi/common/theme/app_colors.dart';
import 'package:dala_ishchisi/common/widgets/custom_appbar_back.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:map_launcher/map_launcher.dart';

class MapAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Coords location;
  final List<AvailableMap> availableMaps;

  const MapAppbar({
    super.key,
    required this.title,
    required this.location,
    required this.availableMaps,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: 100,
      leading: const CustomAppbarBack(),
      title: Text(title),
      actions: [
        PopupMenuButton<AvailableMap>(
          onSelected: (map) => map.showMarker(title: title, coords: location),
          color: Theme.of(context).appBarTheme.backgroundColor,
          itemBuilder: (BuildContext context) {
            return availableMaps.map((AvailableMap map) {
              return PopupMenuItem<AvailableMap>(
                value: map,
                child: Row(
                  spacing: 6,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SvgPicture.asset(map.icon, height: 30),
                    ),
                    Expanded(child: Text(map.mapName)),
                  ],
                ),
              );
            }).toList();
          },
          child: CupertinoButton(
            minSize: 0,
            padding: const EdgeInsets.all(4),
            onPressed: null,
            child: Icon(
              CupertinoIcons.arrow_turn_up_right,
              color: AppColors.blue.shade5,
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
