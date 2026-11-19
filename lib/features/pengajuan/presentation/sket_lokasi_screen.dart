import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/constants.dart';

enum MapTileSource {
  osm('OSM', 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
  googleStreet('Google Street', 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}'),
  googleHybrid('Google Hybrid', 'https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}'),
  googleSatellite('Google Satelit', 'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}');

  final String label;
  final String url;
  const MapTileSource(this.label, this.url);
}

enum MapDrawTool { marker, polygon, none }

class SketLokasiScreen extends StatefulWidget {
  final String? initialGeoJson;
  final void Function(String geoJson)? onSave;

  const SketLokasiScreen({super.key, this.initialGeoJson, this.onSave});

  @override
  State<SketLokasiScreen> createState() => _SketLokasiScreenState();
}

class _SketLokasiScreenState extends State<SketLokasiScreen> {
  final MapController _mapController = MapController();
  MapTileSource _selectedTile = MapTileSource.googleHybrid;
  MapDrawTool _activeTool = MapDrawTool.marker;
  bool _showLayerPicker = false;

  LatLng? _markerPoint;
  final List<LatLng> _polygonPoints = [];

  @override
  void initState() {
    super.initState();
    _parseInitialGeoJson();
  }

  void _parseInitialGeoJson() {
    if (widget.initialGeoJson == null || widget.initialGeoJson!.isEmpty) return;
    try {
      final map = jsonDecode(widget.initialGeoJson!) as Map<String, dynamic>;
      
      // Handle FeatureCollection format or simple Geometry
      Map<String, dynamic>? geom;
      if (map['type'] == 'FeatureCollection' && map['features'] is List) {
        final features = map['features'] as List;
        if (features.isNotEmpty) {
          geom = features[0]['geometry'] as Map<String, dynamic>?;
        }
      } else {
        geom = map;
      }

      if (geom != null) {
        final type = geom['type'] as String?;
        if (type == 'Point') {
          final coords = geom['coordinates'] as List;
          _activeTool = MapDrawTool.marker;
          _markerPoint = LatLng(
            (coords[1] as num).toDouble(),
            (coords[0] as num).toDouble(),
          );
        } else if (type == 'Polygon') {
          final rings = geom['coordinates'] as List;
          final ring = rings.first as List;
          _activeTool = MapDrawTool.polygon;
          for (var i = 0; i < ring.length; i++) {
            final c = ring[i] as List;
            final pt = LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble());
            if (i == ring.length - 1 &&
                _polygonPoints.isNotEmpty &&
                pt == _polygonPoints.first) {
              continue;
            }
            _polygonPoints.add(pt);
          }
        }
      }
    } catch (_) {}
  }

  void _handleTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _showLayerPicker = false;
      if (_activeTool == MapDrawTool.marker) {
        _markerPoint = point;
      } else if (_activeTool == MapDrawTool.polygon) {
        _polygonPoints.add(point);
      }
    });
  }

  void _undo() {
    setState(() {
      if (_activeTool == MapDrawTool.marker) {
        _markerPoint = null;
      } else if (_polygonPoints.isNotEmpty) {
        _polygonPoints.removeLast();
      }
    });
  }

  void _clear() {
    setState(() {
      _markerPoint = null;
      _polygonPoints.clear();
    });
  }

  void _zoomIn() {
    _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1);
  }

  void _zoomOut() {
    _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1);
  }

  void _recenter() {
    final target = _markerPoint ??
        (_polygonPoints.isNotEmpty
            ? _polygonPoints.first
            : const LatLng(AppConstants.defaultLat, AppConstants.defaultLng));
    _mapController.move(target, AppConstants.defaultZoom);
  }

  String get _currentGeoJsonPreview {
    if (_markerPoint != null) {
      final lon = _markerPoint!.longitude.toStringAsFixed(6);
      final lat = _markerPoint!.latitude.toStringAsFixed(6);
      return '{"type":"FeatureCollection","features":[{"type":"Feature","properties":{},"geometry":{"type":"Point","coordinates":[$lon,$lat]}}]}';
    } else if (_polygonPoints.length >= 3) {
      final coords = _polygonPoints
          .map((p) => [
                double.parse(p.longitude.toStringAsFixed(6)),
                double.parse(p.latitude.toStringAsFixed(6))
              ])
          .toList();
      coords.add(coords.first);
      return jsonEncode({
        "type": "FeatureCollection",
        "features": [
          {
            "type": "Feature",
            "properties": {},
            "geometry": {"type": "Polygon", "coordinates": [coords]}
          }
        ]
      });
    }
    return '';
  }

  bool get _canSave {
    if (_activeTool == MapDrawTool.marker) return _markerPoint != null;
    return _polygonPoints.length >= 3;
  }

  void _save() {
    if (!_canSave) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _activeTool == MapDrawTool.marker
                ? 'Klik peta untuk meletakkan titik koordinat.'
                : 'Polygon membutuhkan minimal 3 titik sudut.',
          ),
        ),
      );
      return;
    }

    // PRD format WGS84 GeoJSON Point / Polygon
    String resultString;
    if (_markerPoint != null) {
      resultString = jsonEncode({
        'type': 'Point',
        'coordinates': [_markerPoint!.longitude, _markerPoint!.latitude],
      });
    } else {
      final coords = _polygonPoints
          .map((p) => [p.longitude, p.latitude])
          .toList();
      coords.add(coords.first);
      resultString = jsonEncode({
        'type': 'Polygon',
        'coordinates': [coords],
      });
    }

    widget.onSave?.call(resultString);
    Navigator.of(context).pop(resultString);
  }

  @override
  Widget build(BuildContext context) {
    final preview = _currentGeoJsonPreview;
    final initialCenter = _markerPoint ??
        (_polygonPoints.isNotEmpty
            ? _polygonPoints.first
            : const LatLng(AppConstants.defaultLat, AppConstants.defaultLng));

    return Scaffold(
      backgroundColor: const Color(0xFF1E242B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF263238),
        foregroundColor: Colors.white,
        title: const Text(
          'SKET / DENAH LOKASI OBJEK PAJAK',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _canSave ? _save : null,
            icon: const Icon(Icons.check, color: Colors.white, size: 18),
            label: const Text(
              'Gunakan',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Banner Input Preview Bar (Sesuai Web Asli: Peta + GeoJSON Field)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFFECEFF1),
            child: Row(
              children: [
                const SizedBox(
                  width: 50,
                  child: Text(
                    'Peta',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Color(0xFF37474F),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFCFD8DC)),
                    ),
                    child: Text(
                      preview.isNotEmpty
                          ? preview
                          : 'Klik ikon penanda di kiri lalu klik pada peta untuk menentukan lokasi...',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: preview.isNotEmpty
                            ? const Color(0xFF263238)
                            : Colors.grey[500],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Area Map Leaflet Style
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: initialCenter,
                    initialZoom: 15.5,
                    onTap: _handleTap,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: _selectedTile.url,
                      userAgentPackageName: 'com.elayanan.pbb.e_layanan_pbb_mobile',
                    ),
                    if (_polygonPoints.length >= 3)
                      PolygonLayer(
                        polygons: [
                          Polygon(
                            points: _polygonPoints,
                            color: const Color(0xFF1E88E5).withValues(alpha: 0.35),
                            borderColor: const Color(0xFF0D47A1),
                            borderStrokeWidth: 2.5,
                          ),
                        ],
                      ),
                    if (_polygonPoints.length >= 2)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _polygonPoints,
                            color: const Color(0xFF0D47A1),
                            strokeWidth: 2.5,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        if (_markerPoint != null)
                          Marker(
                            point: _markerPoint!,
                            width: 36,
                            height: 48,
                            alignment: Alignment.topCenter,
                            child: const Icon(
                              Icons.location_on,
                              color: Color(0xFF1E88E5),
                              size: 44,
                              shadows: [
                                Shadow(
                                  color: Colors.black45,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                          ),
                        ..._polygonPoints.asMap().entries.map(
                              (e) => Marker(
                                point: e.value,
                                width: 22,
                                height: 22,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E88E5),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: const [
                                      BoxShadow(color: Colors.black38, blurRadius: 4),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${e.key + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      ],
                    ),
                    RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution(
                          _selectedTile == MapTileSource.osm
                              ? '© OpenStreetMap contributors'
                              : 'Map data © Google',
                        ),
                      ],
                    ),
                  ],
                ),

                // Leaflet-style Left Toolbar (Zoom, Home, Marker, Polygon, Clear)
                Positioned(
                  top: 16,
                  left: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFB0BEC5)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildToolButton(
                          icon: Icons.add,
                          tooltip: 'Perbesar (+)',
                          onTap: _zoomIn,
                        ),
                        const Divider(height: 1, color: Color(0xFFCFD8DC)),
                        _buildToolButton(
                          icon: Icons.remove,
                          tooltip: 'Perkecil (-)',
                          onTap: _zoomOut,
                        ),
                        const Divider(height: 1, color: Color(0xFFCFD8DC)),
                        _buildToolButton(
                          icon: Icons.home_outlined,
                          tooltip: 'Pusat Solo',
                          onTap: _recenter,
                        ),
                        const Divider(height: 1, color: Color(0xFFCFD8DC)),
                        _buildToolButton(
                          icon: Icons.room,
                          tooltip: 'Mode Marker (Titik)',
                          isActive: _activeTool == MapDrawTool.marker,
                          activeColor: const Color(0xFF1E88E5),
                          onTap: () {
                            setState(() => _activeTool = MapDrawTool.marker);
                          },
                        ),
                        const Divider(height: 1, color: Color(0xFFCFD8DC)),
                        _buildToolButton(
                          icon: Icons.polyline,
                          tooltip: 'Mode Polygon (Bidang Tanah)',
                          isActive: _activeTool == MapDrawTool.polygon,
                          activeColor: const Color(0xFF1E88E5),
                          onTap: () {
                            setState(() => _activeTool = MapDrawTool.polygon);
                          },
                        ),
                        const Divider(height: 1, color: Color(0xFFCFD8DC)),
                        _buildToolButton(
                          icon: Icons.undo,
                          tooltip: 'Hapus Titik Terakhir',
                          onTap: _undo,
                        ),
                        const Divider(height: 1, color: Color(0xFFCFD8DC)),
                        _buildToolButton(
                          icon: Icons.delete_outline,
                          tooltip: 'Hapus Semua',
                          onTap: _clear,
                        ),
                      ],
                    ),
                  ),
                ),

                // Leaflet-style Right Layer Switcher (OSM, Google Street, Google Hybrid, Google Satellite)
                Positioned(
                  top: 16,
                  right: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () => setState(() => _showLayerPicker = !_showLayerPicker),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFB0BEC5)),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 4),
                            ],
                          ),
                          child: const Icon(
                            Icons.layers_outlined,
                            size: 24,
                            color: Color(0xFF37474F),
                          ),
                        ),
                      ),
                      if (_showLayerPicker) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFB0BEC5)),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 6),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: MapTileSource.values.map((tile) {
                              final isSelected = _selectedTile == tile;
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedTile = tile;
                                    _showLayerPicker = false;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isSelected
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_unchecked,
                                        size: 16,
                                        color: isSelected
                                            ? const Color(0xFF1E88E5)
                                            : Colors.grey,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        tile.label,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.normal,
                                          color: const Color(0xFF263238),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Status Tool Helper pill at bottom
                Positioned(
                  bottom: 14,
                  left: 20,
                  right: 20,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(color: Colors.black45, blurRadius: 6),
                        ],
                      ),
                      child: Text(
                        _activeTool == MapDrawTool.marker
                            ? (_markerPoint == null
                                ? 'Ketuk peta untuk meletakkan titik lokasi'
                                : 'Titik terpilih: ${_markerPoint!.latitude.toStringAsFixed(5)}, ${_markerPoint!.longitude.toStringAsFixed(5)}')
                            : 'Mode Bidang: ${_polygonPoints.length} titik (min. 3 titik)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    bool isActive = false,
    Color? activeColor,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          color: isActive ? (activeColor ?? AppTheme.primary).withValues(alpha: 0.15) : Colors.transparent,
          child: Icon(
            icon,
            size: 20,
            color: isActive ? (activeColor ?? AppTheme.primary) : const Color(0xFF37474F),
          ),
        ),
      ),
    );
  }
}
