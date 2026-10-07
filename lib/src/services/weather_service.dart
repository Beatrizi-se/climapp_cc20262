import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:climapp_cc20262/src/enums/enviroments_enum.dart';
import 'package:climapp_cc20262/src/models/weather_forecast_model.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  Future<List<WeatherForecastModel>> getWeatherForecast(
    List<String> listCitySearch,
  ) async {
    final enumEnv = EnviromentEnum.constants;
    final List<WeatherForecastModel> listCity = [];
    if (enumEnv.API_KEY.isEmpty) {
      throw HttpException(
        'API_KEY não configurada. Inicie o Climapp pelo VS Code e informe a chave da HG Brasil.',
      );
    }

    for (var city in listCitySearch) {
      final uri = Uri.parse(enumEnv.API_BASE_URL).replace(
        queryParameters: {'key': enumEnv.API_KEY, 'city_name': city},
      );
      final response = await http
          .get(uri)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw TimeoutException(
                "Deu ruim nas internet, vá botar crédito seu pobre",
              );
            },
          );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Resposta inválida da API HG Brasil.');
        }

        final results = decoded['results'];
        if (results is! Map<String, dynamic>) {
          final error = decoded['error'];
          final description = error is Map ? error['description'] : null;
          throw HttpException(
            description?.toString() ??
                'A API não retornou dados para $city. Verifique a chave e o nome da cidade.',
          );
        }

        final model = WeatherForecastModel.fromJson(results);
        listCity.add(model);
      } else {
        throw HttpException(
          'Deu ruim no HGBrasil, a culpa não é minha. Código: ${response.statusCode}',
        );
      }
    }
    return listCity;
  }
}
