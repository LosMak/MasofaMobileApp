import 'dart:async';
import 'dart:io';

import 'package:dala_ishchisi/application/network_info/network_info_bloc.dart';
import 'package:dala_ishchisi/application/region/region_bloc.dart';
import 'package:dala_ishchisi/common/providers/mbtile_provider.dart';
import 'package:dala_ishchisi/common/theme/app_colors.dart';
import 'package:dala_ishchisi/common/widgets/custom_images.dart';
import 'package:dala_ishchisi/common/widgets/custom_map_types.dart';
import 'package:dala_ishchisi/presentation/pages/task/widgets/region_inherited_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_launcher/map_launcher.dart' as ml;
import 'package:mbtiles/mbtiles.dart';
import 'package:path_provider/path_provider.dart';

import 'widgets/map_appbar.dart';

class MapView extends StatefulWidget {
  final String title;
  final ml.Coords location;
  final String regionId;
  const MapView(
    this.title,
    this.location,
    this.regionId, {
    super.key,
  });

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final availableMaps = <ml.AvailableMap>[];
  final Completer<GoogleMapController> mapController =
      Completer<GoogleMapController>();
  var mapType = MapType.satellite;
  BitmapDescriptor? currentMarker;

  MbTiles? _offlineTiles;
  bool isOffline = false;

  @override
  void initState() {
    super.initState();
    ml.MapLauncher.installedMaps.then((value) {
      availableMaps
        ..clear()
        ..addAll(value);
      setState(() {});
    });
    setCustomMarkerIcon();

    context
        .read<NetworkInfoBloc>()
        .add(const NetworkInfoEvent.forceConnectionCheck());
  }

  void setCustomMarkerIcon() async {
    currentMarker = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      CustomImages.currentLocation.path,
    );
    setState(() {});
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController.complete(controller);
  }

  void _zoomIn() async {
    final controller = await mapController.future;
    controller.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() async {
    final controller = await mapController.future;
    controller.animateCamera(CameraUpdate.zoomOut());
  }

  void _setOfflineMap(String path) {
    if (path.isNotEmpty) {
      setState(() {
        _offlineTiles = MbTiles(mbtilesPath: path);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<NetworkInfoBloc, NetworkInfoState>(
          listener: (context, state) {
            if (!state.isConnected) {
              final bloc = context.read<RegionBloc>();
              bloc.add(RegionEvent.fetchCacheRegion(regionId: widget.regionId));
            }
            setState(() {
              isOffline = !state.isConnected;
            });
          },
        ),
        BlocListener<RegionBloc, RegionState>(
          listener: (context, state) {
            state.mapOrNull(
              cacheRegion: (value) => _setOfflineMap(value.path),
            );
          },
        ),
      ],
      child: Scaffold(
        appBar: MapAppbar(
          title: widget.title,
          location: widget.location,
          availableMaps: availableMaps,
        ),
        body: currentMarker == null
            ? const SizedBox()
            : Stack(
                children: [
                  GoogleMap(
                    mapType: mapType,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                          widget.location.latitude, widget.location.longitude),
                      zoom: 13,
                    ),
                    minMaxZoomPreference: isOffline
                        ? const MinMaxZoomPreference(11, 14)
                        : MinMaxZoomPreference.unbounded,
                    onMapCreated: _onMapCreated,
                    circles: {
                      Circle(
                        circleId: const CircleId("circle"),
                        center: LatLng(widget.location.latitude,
                            widget.location.longitude),
                        radius: 3,
                        strokeWidth: 1,
                        strokeColor: AppColors.red.shade1,
                        fillColor: AppColors.red.shade4,
                      ),
                    },
                    markers: {
                      Marker(
                        markerId: const MarkerId('bid'),
                        position: LatLng(
                          widget.location.latitude,
                          widget.location.longitude,
                        ),
                        infoWindow: InfoWindow(title: widget.title),
                      ),
                    },
                    tileOverlays: _offlineTiles != null && isOffline
                        ? {
                            TileOverlay(
                              tileOverlayId: TileOverlayId(widget.regionId),
                              tileProvider: MbTileProvider(_offlineTiles!),
                            ),
                          }
                        : const {},
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FloatingActionButton(
                            heroTag: 'zoomIn',
                            backgroundColor: Colors.white,
                            onPressed: _zoomIn,
                            child:
                                Icon(Icons.add, color: AppColors.blue.shade5),
                          ),
                          const SizedBox(height: 20),
                          FloatingActionButton(
                            heroTag: 'zoomOut',
                            backgroundColor: Colors.white,
                            onPressed: _zoomOut,
                            child: Icon(Icons.remove,
                                color: AppColors.blue.shade5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
        bottomNavigationBar: CustomMapTypes(
          mapType: mapType,
          onChange: (type) => setState(() => mapType = type),
        ),
      ),
    );
  }
}
