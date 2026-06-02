import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_colors.dart';

/// Live vendor-tracking map using OpenStreetMap tiles (flutter_map) — no Google
/// Maps / API key. Recenters to follow the vendor as location updates arrive.
class LiveTrackingMap extends StatefulWidget {
  final double? vendorLat;
  final double? vendorLon;
  final String? vendorName;

  const LiveTrackingMap({
    super.key,
    this.vendorLat,
    this.vendorLon,
    this.vendorName,
  });

  @override
  State<LiveTrackingMap> createState() => _LiveTrackingMapState();
}

class _LiveTrackingMapState extends State<LiveTrackingMap> {
  final MapController _controller = MapController();
  static const LatLng _indiaCenter = LatLng(20.5937, 78.9629);

  LatLng? get _vendor => (widget.vendorLat != null && widget.vendorLon != null)
      ? LatLng(widget.vendorLat!, widget.vendorLon!)
      : null;

  @override
  void didUpdateWidget(covariant LiveTrackingMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final v = _vendor;
    if (v != null &&
        (oldWidget.vendorLat != widget.vendorLat ||
            oldWidget.vendorLon != widget.vendorLon)) {
      // Follow the vendor. Done post-frame so the map is laid out & ready.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _controller.move(v, 15);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = _vendor;
    return FlutterMap(
      mapController: _controller,
      options: MapOptions(
        initialCenter: v ?? _indiaCenter,
        initialZoom: v != null ? 15 : 5,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.servlivo.customer',
        ),
        if (v != null)
          MarkerLayer(
            markers: [
              Marker(
                point: v,
                width: 44,
                height: 44,
                child: const Icon(Icons.two_wheeler, color: AppColors.primary, size: 38),
              ),
            ],
          ),
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution('© OpenStreetMap contributors'),
          ],
        ),
      ],
    );
  }
}
