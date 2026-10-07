import 'package:climapp_cc20262/src/controller/list_city_controller.dart';
import 'package:climapp_cc20262/src/screens/weather_city_screen.dart';
import 'package:climapp_cc20262/src/widgets/city_tile_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListCityScreen extends StatefulWidget {
  const ListCityScreen({super.key});

  @override
  State<ListCityScreen> createState() => _ListCityScreenState();
}

class _ListCityScreenState extends State<ListCityScreen> {
  final TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Color(0xFF00457D), Color(0xFF05051F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: 25),
              TextField(
                style: const TextStyle(color: Colors.white),
                controller: textController,
                onChanged: (query) {
                  context.read<ListCityController>().filterCities(query);
                },
                decoration: const InputDecoration(
                  fillColor: Color(0x15FFFFFF),
                  filled: true,
                  hintText: 'Digite uma cidade',
                  hintStyle: TextStyle(color: Colors.white),
                  suffixIcon: Icon(Icons.search, color: Colors.white),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Consumer<ListCityController>(
                builder: (context, controller, child) {
                  final country = controller.deviceCountry;
                  final message = country.isEmpty
                      ? 'Identificando país/região do dispositivo...'
                      : country == 'Deu Ruim'
                      ? 'País/região do dispositivo indisponível'
                      : 'País/região do dispositivo: $country';

                  return Row(
                    children: [
                      const Icon(
                        Icons.public,
                        size: 18,
                        color: Color(0xFFB9D6FF),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          message,
                          style: const TextStyle(
                            color: Color(0xFFB9D6FF),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Consumer<ListCityController>(
                  builder: (context, controller, child) {
                    if (controller.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.errorMessage.isNotEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            controller.errorMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }
                    if (controller.filteredCities.isEmpty) {
                      return const Center(
                        child: Text(
                          'Nenhuma cidade encontrada.',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: controller.filteredCities.length,
                      itemBuilder: (context, index) {
                        final city = controller.filteredCities[index];
                        return CityTileWidget(
                          cityName: city.cityName,
                          icon: city.conditionSlug,
                          temperature: city.temp,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WeatherCityScreen(
                                  weatherForecastModel: city,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
