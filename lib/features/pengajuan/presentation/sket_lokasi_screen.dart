import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/utils/constants.dart';

enum MapDrawMode { marker, polygon }

class SketLokasiScreen extends StatefulWidget {
  final String? initialGeoJson;
  final void Function(String geoJson)? onSave;

  const SketLokasiScreen({super.key, this.initialGeoJson, this.onSave});

  @override
  State<SketLokasiScreen> createState() => _SketLokasiScreenState();
}

class _SketLokasiScreenState extends State<SketLokasiScreen> {
  final MapController _mapController = MapController();
  MapDrawMode _mode = MapDrawMode.marker;
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
      final type = map['type'] as String?;
      if (type == 'Point') {
        final coords = map['coordinates'] as List;
        _mode = MapDrawMode.marker;
        _markerPoint = LatLng(
          (coords[1] as num).toDouble(),
          (coords[0] as num).toDouble(),
        );
      } else if (type == 'Polygon') {
        final rings = map['coordinates'] as List;
        final ring = rings.first as List;
        _mode = MapDrawMode.polygon;
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
    } catch (_) {}
  }

  void _handleTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      if (_mode == MapDrawMode.marker) {
        _markerPoint = point;
      } else {
        _polygonPoints.add(point);
      }
    });
  }

  void _undo() {
    setState(() {
      if (_mode == MapDrawMode.marker) {
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

  bool get _canSave {
    if (_mode == MapDrawMode.marker) return _markerPoint != null;
    return _polygonPoints.length >= 3;
  }

  String _buildGeoJson() {
    if (_mode == MapDrawMode.marker && _markerPoint != null) {
      return jsonEncode({
        'type': 'Point',
        'coordinates': [_markerPoint!.longitude, _markerPoint!.latitude],
      });
    }
    final coords = _polygonPoints
        .map((p) => [p.longitude, p.latitude])
        .toList();
    if (coords.isNotEmpty) {
      coords.add(coords.first);
    }
    return jsonEncode({
      'type': 'Polygon',
      'coordinates': [coords],
    });
  }

  void _save() {
    if (!_canSave) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _mode == MapDrawMode.marker
                ? 'Ketuk peta untuk meletakkan titik lokasi.'
                : 'Polygon membutuhkan minimal 3 titik.',
          ),
        ),
      );
      return;
    }
    final geoJson = _buildGeoJson();
    widget.onSave?.call(geoJson);
    Navigator.of(context).pop(geoJson);
  }

  @override
  Widget build(BuildContext context) {
    final center = _markerPoint ??
        (_polygonPoints.isNotEmpty
            ? _polygonPoints.first
            : const LatLng(AppConstants.defaultLat, AppConstants.defaultLng));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sket / Denah Lokasi'),
        actions: [
          TextButton(
            onPressed: _canSave ? _save : null,
            child: const Text(
              'Simpan',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: AppConstants.defaultZoom,
              onTap: _handleTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.elayanan.pbb.e_layanan_pbb_mobile',
              ),
              if (_mode == MapDrawMode.polygon && _polygonPoints.length >= 3)
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: _polygonPoints,
                      color: const Color(0xFF0F4C3A).withValues(alpha: 0.25),
                      borderColor: const Color(0xFF0F4C3A),
                      borderStrokeWidth: 2.5,
                    ),
                  ],
                ),
              if (_mode == MapDrawMode.polygon && _polygonPoints.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _polygonPoints,
                      color: const Color(0xFF0F4C3A),
                      strokeWidth: 2,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  if (_mode == MapDrawMode.marker && _markerPoint != null)
                    Marker(
                      point: _markerPoint!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: Color(0xFFB91C1C),
                        size: 38,
                      ),
                    ),
                  if (_mode == MapDrawMode.polygon)
                    ..._polygonPoints.asMap().entries.map(
                          (e) => Marker(
                            point: e.value,
                            width: 26,
                            height: 26,
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F4C3A),
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: Text(
                                '${e.key + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                ],
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
            ],
          ),
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SegmentedButton<MapDrawMode>(
                      segments: const [
                        ButtonSegment(
                          value: MapDrawMode.marker,
                          label: Text('Marker (Titik)'),
                          icon: Icon(Icons.place_outlined, size: 18),
                        ),
                        ButtonSegment(
                          value: MapDrawMode.polygon,
                          label: Text('Polygon (Bidang)'),
                          icon: Icon(Icons.polyline_outlined, size: 18),
                        ),
                      ],
                      selected: {_mode},
                      onSelectionChanged: (val) {
                        setState(() => _mode = val.first);
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _mode == MapDrawMode.marker
                                ? (_markerPoint == null
                                    ? 'Ketuk peta untuk menandai titik objek.'
                                    : 'Titik: ${_markerPoint!.latitude.toStringAsFixed(5)}, ${_markerPoint!.longitude.toStringAsFixed(5)}')
                                : 'Titik polygon: ${_polygonPoints.length} (minimal 3 titik)',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Urungkan titik terakhir',
                          onPressed: _undo,
                          icon: const Icon(Icons.undo, size: 20),
                        ),
                        IconButton(
                          tooltip: 'Hapus semua',
                          onPressed: _clear,
                          icon: const Icon(Icons.delete_outline, size: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
