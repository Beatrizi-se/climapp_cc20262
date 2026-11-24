import 'package:climapp_cc20262/src/enums/enviroments_enum.dart';
import 'package:climapp_cc20262/src/models/weather_forecast_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';

class CompassInfoPanelWidget extends StatelessWidget {
  const CompassInfoPanelWidget({
    required this.position,
    required this.heading,
    required this.accuracy,
    this.weather,
    super.key,
  });

  final LatLng position;
  final double heading;
  final double? accuracy;
  final WeatherForecastModel? weather;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            const Color(0xFF00457D).withValues(alpha: 0.95),
            const Color(0xFF05051F).withValues(alpha: 0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        border: Border.all(
          color: const Color(0xFF4463D5).withValues(alpha: 0.7),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _HeadingBadge(heading: heading),
              const SizedBox(width: 12),
              Expanded(child: _CoordinatesCard(position: position)),
            ],
          ),
          if (weather != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0x1FFFFFFF),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  if (weather!.conditionSlug.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: SvgPicture.network(
                        '${EnviromentEnum.constants.IMAGE_URL}${weather!.conditionSlug}.svg',
                        width: 32,
                        height: 32,
                        placeholderBuilder:
                            (_) => const Icon(
                              Icons.wb_sunny_outlined,
                              color: Colors.white,
                              size: 28,
                            ),
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weather!.cityName.isNotEmpty
                              ? weather!.cityName
                              : 'Localização Atual',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          weather!.description,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${weather!.temp}°C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeadingBadge extends StatelessWidget {
  const _HeadingBadge({required this.heading});

  final double heading;

  static const List<String> _directions = [
    'N',
    'NE',
    'L',
    'SE',
    'S',
    'SO',
    'O',
    'NO',
  ];

  @override
  Widget build(BuildContext context) {
    final double normalizedHeading = (heading % 360 + 360) % 360;
    final int directionIndex = ((normalizedHeading + 22.5) ~/ 45) % 8;
    final String cardinal = _directions[directionIndex];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF4463D5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.explore_outlined, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          Text(
            '${normalizedHeading.toStringAsFixed(0)}° $cardinal',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoordinatesCard extends StatelessWidget {
  const _CoordinatesCard({required this.position});

  final LatLng position;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x15FFFFFF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Coordenadas',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            '${position.latitude.toStringAsFixed(4)}, '
            '${position.longitude.toStringAsFixed(4)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
