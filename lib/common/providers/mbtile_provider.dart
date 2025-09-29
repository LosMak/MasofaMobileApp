import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mbtiles/mbtiles.dart';

class MbTileProvider extends TileProvider {
  final MbTiles mbProvider;

  MbTileProvider(this.mbProvider);

  @override
  Future<Tile> getTile(int x, int y, int? zoom) async {
    final imageBytes = mbProvider.getTile(
      z: zoom!,
      x: x,
      y: y,
    );

    if (imageBytes != null && imageBytes.isNotEmpty) {
      return Tile(256, 256, imageBytes);
    } else {
      return TileProvider.noTile;
    }
  }
}
