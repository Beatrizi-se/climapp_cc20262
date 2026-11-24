import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../controller/list_city_controller.dart';
import '../models/weather_forecast_model.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';
import '../widgets/city_map_marker_widget.dart';
import '../widgets/compass_info_panel_widget.dart';
import '../widgets/compass_status_widgets.dart';
import '../widgets/compass_user_marker_widget.dart';
import '../widgets/floating_compass_widget.dart';

class CompassMapScreen extends StatefulWidget {
  const CompassMapScreen({super.key});

  @override
  State<CompassMapScreen> createState() => _CompassMapScreenState();
}

class _CompassMapScreenState extends State<CompassMapScreen> {
  final LocationService _locationService = LocationService();
  final WeatherService _weatherService = WeatherService();
  final MapController _mapController = MapController();

  LatLng? _currentPosition;
  WeatherForecastModel? _currentWeather;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final position = await _locationService.determinePosition();
      final weather = await _weatherService.getWeatherByLocation(
        position.latitude,
        position.longitude,
      );
      if (!mounted) return;

      setState(() {
        _currentPosition = position;
        _currentWeather = weather;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _recenterMap() {
    final position = _currentPosition;
    if (position != null) {
      _mapController.move(position, 16.0);
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final position = _currentPosition;

    return Scaffold(
      backgroundColor: const Color(0xFF05051F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00457D),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Navegação e Sensores',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (position != null && !_isLoading)
            IconButton(
              onPressed: _recenterMap,
              tooltip: 'Centralizar na minha localização',
              icon: const Icon(Icons.my_location, color: Colors.white),
            ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Color(0xFF00457D), Color(0xFF05051F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const CompassLoadingWidget()
            : _errorMessage != null
            ? CompassErrorWidget(
                errorMessage: _errorMessage!,
                onRetry: _loadLocation,
              )
            : _CompassMapView(
                mapController: _mapController,
                currentPosition: position!,
                weather: _currentWeather,
              ),
      ),
    );
  }
}

class _CompassMapView extends StatelessWidget {
  const _CompassMapView({
    required this.mapController,
    required this.currentPosition,
    this.weather,
  });

  final MapController mapController;
  final LatLng currentPosition;
  final WeatherForecastModel? weather;

  static const Map<String, LatLng> _knownCoordinates = {
    'aracaju': LatLng(-10.9472, -37.0731),
    'itabaiana': LatLng(-10.6850, -37.4253),
    'salvador': LatLng(-12.9777, -38.5016),
    'curitiba': LatLng(-25.4284, -49.2733),
    'são paulo': LatLng(-23.5505, -46.6333),
    'sao paulo': LatLng(-23.5505, -46.6333),
    'rio de janeiro': LatLng(-22.9068, -43.1729),
    'brasília': LatLng(-15.7975, -47.8919),
    'brasilia': LatLng(-15.7975, -47.8919),
    'belo horizonte': LatLng(-19.9167, -43.9345),
    'fortaleza': LatLng(-3.7319, -38.5267),
    'recife': LatLng(-8.0476, -34.8770),
    'porto alegre': LatLng(-30.0346, -51.2177),
    'florianópolis': LatLng(-27.5954, -48.5480),
    'florianopolis': LatLng(-27.5954, -48.5480),
    'manaus': LatLng(-3.1190, -60.0217),
    'belém': LatLng(-1.4558, -48.4902),
    'belem': LatLng(-1.4558, -48.4902),
    'goiânia': LatLng(-16.6869, -49.2648),
    'goiania': LatLng(-16.6869, -49.2648),
  };

  LatLng? _resolveCoordinates(String name) {
    final clean = name.toLowerCase().split(',').first.trim();
    return _knownCoordinates[clean];
  }

  @override
  Widget build(BuildContext context) {
    final cityController = context.watch<ListCityController>();
    final cityMarkers = <Marker>[];

    final distanceCalculator = const Distance();
    for (final city in cityController.allCities) {
      final coords = _resolveCoordinates(
        city.cityName.isNotEmpty ? city.cityName : city.city,
      );
      if (coords != null) {
        final double distanceInKm = distanceCalculator.as(
          LengthUnit.Kilometer,
          currentPosition,
          coords,
        );
        // Não sobrepõe o balão da cidade caso o usuário já esteja nela
        if (distanceInKm > 15.0) {
          cityMarkers.add(
            Marker(
              point: coords,
              width: 120,
              height: 48,
              child: CityMapMarkerWidget(city: city),
            ),
          );
        }
      }
    }

    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        final double heading = snapshot.data?.heading ?? 0.0;
        final double? accuracy = snapshot.data?.accuracy;

        return Stack(
          children: [
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: currentPosition,
                initialZoom: 16.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'br.dev.yago.climapp_cc20262',
                ),
                MarkerLayer(
                  markers: [
                    ...cityMarkers,
                    Marker(
                      point: currentPosition,
                      width: 60,
                      height: 60,
                      child: CompassUserMarkerWidget(heading: heading),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 16,
              right: 16,
              child: FloatingCompassWidget(heading: heading),
            ),
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: CompassInfoPanelWidget(
                position: currentPosition,
                heading: heading,
                accuracy: accuracy,
                weather: weather,
              ),
            ),
          ],
        );
      },
    );
  }
}
