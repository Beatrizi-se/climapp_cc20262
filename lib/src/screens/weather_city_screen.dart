import 'package:climapp_cc20262/src/enums/enviroments_enum.dart';
import 'package:climapp_cc20262/src/models/weather_forecast_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WeatherCityScreen extends StatefulWidget {
  const WeatherCityScreen({required this.weatherForecastModel, super.key});

  final WeatherForecastModel weatherForecastModel;

  @override
  _WeatherCityScreenState createState() => _WeatherCityScreenState();
}

class _WeatherCityScreenState extends State<WeatherCityScreen> {
  EnviromentEnum envEnum = EnviromentEnum.constants;
  final CarouselController _controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF05051F),
      appBar: AppBar(
        backgroundColor: Color(0xFF00457D),
        centerTitle: true,
        title: Text(
          widget.weatherForecastModel.cityName,
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Color(0xFF00457D), Color(0xFF05051F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: .all(16),
          child: Column(
            crossAxisAlignment: .stretch,
            children: [
              Container(
                padding: .all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF4463D5),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Hoje: ${widget.weatherForecastModel.date}',
                      style: TextStyle(fontSize: 20, fontWeight: .w600),
                    ),
                    SvgPicture.network(
                      '${envEnum.IMAGE_URL}${widget.weatherForecastModel.conditionSlug}.svg',
                      placeholderBuilder: (_) => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Icon(
                          Icons.cloud_outlined,
                          color: Colors.white,
                          size: 54,
                        ),
                      ),
                    ),
                    Text(
                      '${widget.weatherForecastModel.temp}°',
                      style: TextStyle(fontSize: 50, fontWeight: .bold),
                    ),
                    Text(
                      widget.weatherForecastModel.description,
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Icon(
                          Icons.thermostat,
                          color: Colors.redAccent,
                          size: 33,
                        ),
                        Text(
                          "Min/Max:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 21,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            widget.weatherForecastModel.forecast.isNotEmpty
                                ? "${widget.weatherForecastModel.forecast[0].min}°/${widget.weatherForecastModel.forecast[0].max}°"
                                : "--°/--°",
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: 21),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 250),
                child: CarouselView(
                  controller: _controller,
                  itemExtent: 200,
                  shrinkExtent: 200,
                  children: List<Widget>.generate(
                    widget.weatherForecastModel.forecast.length,
                    (int index) => Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Color(0xFF05051F).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.weatherForecastModel.forecast[index].weekday,
                            style: TextStyle(fontSize: 20, fontWeight: .w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '(${widget.weatherForecastModel.forecast[index].date})',
                            style: TextStyle(fontSize: 16),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Image.network(
                              "${envEnum.MOON_PHASE_URL}${widget.weatherForecastModel.forecast[index].moonPhase}.png",
                              errorBuilder:
                                  (context, error, stackTrace) => const Icon(
                                    Icons.nightlight_round,
                                    color: Colors.amberAccent,
                                    size: 36,
                                  ),
                            ),
                          ),
                          Text(
                            '${widget.weatherForecastModel.forecast[index].min.toString()}/${widget.weatherForecastModel.forecast[index].max.toString()}°',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
