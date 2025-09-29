import 'dart:async';
import 'package:dala_ishchisi/application/network_info/network_info_bloc.dart';
import 'package:dala_ishchisi/application/region/region_bloc.dart';
import 'package:dala_ishchisi/common/localization/localization.dart';
import 'package:dala_ishchisi/common/providers/mbtile_provider.dart';
import 'package:dala_ishchisi/common/theme/app_colors.dart';
import 'package:dala_ishchisi/common/widgets/custom_appbar_back.dart';
import 'package:dala_ishchisi/common/widgets/custom_map_types.dart';
import 'package:dala_ishchisi/infrastructure/services/location/map_marker_controller.dart';
import 'package:dala_ishchisi/infrastructure/services/location/poly_editor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mbtiles/mbtiles.dart';

class ContourEditorView extends StatefulWidget {
  final String title;
  final LatLng initialPosition;
  final List<LatLng>? initialPoints;
  final double zoom;
  final bool isPolygon;
  final Function(List<LatLng> points)? onResult;
  final String regionId;

  const ContourEditorView({
    super.key,
    required this.title,
    required this.initialPosition,
    this.initialPoints,
    this.zoom = 19,
    this.isPolygon = false,
    this.onResult,
    required this.regionId,
  });

  @override
  State<ContourEditorView> createState() => _ContourEditorViewState();
}

class _ContourEditorViewState extends State<ContourEditorView> {
  final markerController = DragMarkerController();
  final Completer<GoogleMapController> mapController =
      Completer<GoogleMapController>();

  final pointIcon = BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueBlue,
  );
  final firstPointIcon = BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueGreen,
  );

  MbTiles? _offlineTiles;
  bool isOffline = false;

  var mapType = MapType.satellite;

  final points = <LatLng>[];
  var polyLines = <Polyline>{};
  var polygons = <Polygon>{};

  var isContourClosed = false;
  var hasIntersections = false;

  String? errorMessage;
  bool isErrorMessage = false;

  late final polyEditor = PolyEditor(
    addClosePathMarker: widget.isPolygon,
    points: points,
    pointIcon: pointIcon,
    firstPointIcon: firstPointIcon,
    markerController: markerController,
    onChanged: (_) => setState(_updatePolyline),
    onContourClosed: () {
      setState(() => isContourClosed = true);
      _showMessage(Words.contourClosed.str, false);
    },
    onPolygonUpdated: (updatedPolygons) =>
        setState(() => polygons = updatedPolygons),
    onValidationMessage: _showMessage,
  );

  @override
  void initState() {
    super.initState();
    if (widget.initialPoints?.isNotEmpty ?? false) {
      points.addAll(widget.initialPoints!);
    }
    context
        .read<NetworkInfoBloc>()
        .add(const NetworkInfoEvent.forceConnectionCheck());
  }

  void _setOfflineMap(String path) {
    if (path.isNotEmpty) {
      setState(() {
        _offlineTiles = MbTiles(mbtilesPath: path);
      });
    }
  }

  void _showMessage(String message, bool isError) {
    setState(() {
      errorMessage = message;
      isErrorMessage = isError;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: isError
            ? AppColors.red.shade5
            : (isContourClosed
                ? AppColors.blue.shade6
                : AppColors.green.shade5),
      ));
  }

  void _updatePolyline() {
    final strokeColor = polyEditor.hasIntersections
        ? AppColors.red.shade5
        : (polyEditor.isClosed
            ? AppColors.blue.shade6
            : AppColors.green.shade5);

    polyLines = {
      Polyline(
        polylineId: const PolylineId('main_line'),
        points: points,
        color: strokeColor,
        width: 5,
      ),
    };

    isContourClosed = polyEditor.isClosed;
    hasIntersections = polyEditor.hasIntersections;
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController.complete(controller);
    polyEditor.edit();
    setState(() {
      isContourClosed = polyEditor.isClosed;
      hasIntersections = polyEditor.hasIntersections;
    });
  }

  void _saveContour() {
    if (isContourClosed) {
      widget.onResult?.call(points);
      Navigator.pop(context);
    } else {
      _showMessage(Words.closeContour.str, true);
    }
  }

  void _zoomIn() async {
    final controller = await mapController.future;
    controller.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() async {
    final controller = await mapController.future;
    controller.animateCamera(CameraUpdate.zoomOut());
  }

  void _undoLastPoint() {
    if (polyEditor.undoLastPoint()) {
      setState(() {
        errorMessage = null;
        isContourClosed = polyEditor.isClosed;
        hasIntersections = polyEditor.hasIntersections;
      });
    }
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
      child: BlocBuilder<NetworkInfoBloc, NetworkInfoState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              leadingWidth: 100,
              leading: const CustomAppbarBack(),
              title: Text(widget.title),
              actions: [
                CupertinoButton(
                  minSize: 0,
                  padding: EdgeInsets.zero,
                  onPressed: points.isNotEmpty && !hasIntersections
                      ? _saveContour
                      : null,
                  child: Text(Words.save.str),
                ),
                const SizedBox(width: 12),
              ],
            ),
            body: Column(
              children: [
                if (errorMessage != null && isErrorMessage)
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    color: AppColors.red.shade5.withAlpha(25),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: AppColors.red.shade5),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            errorMessage!,
                            style: TextStyle(
                              color: AppColors.red.shade5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: Stack(
                    children: [
                      GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: widget.initialPosition,
                          zoom: widget.zoom,
                        ),
                        mapType: mapType,
                        markers: markerController.markers,
                        polylines: polyLines,
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                        polygons: polygons,
                        circles: {
                          Circle(
                            circleId: const CircleId('current'),
                            center: widget.initialPosition,
                            fillColor: AppColors.blue.shade3,
                            strokeColor: AppColors.blue.shade5,
                            radius: 3,
                            strokeWidth: 5,
                            zIndex: 1,
                          )
                        },
                        myLocationButtonEnabled: false,
                        onTap: (LatLng position) {
                          if (!isContourClosed) {
                            polyEditor.add(points, position);
                          } else {
                            _showMessage(Words.reopenToEdit.str, false);
                          }
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
                            spacing: 20,
                            children: [
                              FloatingActionButton(
                                heroTag: 'zoomIn',
                                backgroundColor: Colors.white,
                                onPressed: _zoomIn,
                                child: Icon(Icons.add,
                                    color: AppColors.blue.shade5),
                              ),
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
                      if (hasIntersections)
                        Positioned(
                          top: 16,
                          left: 16,
                          right: 16,
                          child: Card(
                            color: AppColors.red.shade5,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                Words.intersectionDetected.str,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            bottomNavigationBar: CustomMapTypes(
              mapType: mapType,
              onChange: (type) => setState(() => mapType = type),
            ),
            floatingActionButton: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (points.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: FloatingActionButton(
                      tooltip: Words.undoLastPoint.str,
                      backgroundColor: Colors.white,
                      onPressed: _undoLastPoint,
                      child: Icon(Icons.undo, color: AppColors.red.shade5),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
