import 'package:climapp_cc20262/src/enums/enviroments_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CityTileWidget extends StatelessWidget {
  const CityTileWidget({
    required this.cityName,
    required this.icon,
    required this.temperature,
    required this.onTap,
    super.key,
  });

  final String cityName;
  final String icon;
  final int temperature;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    const EnviromentEnum envEnum = EnviromentEnum.constants;
    return Container(
      decoration: BoxDecoration(
        color: Color(0xff15ffffff),
        borderRadius: BorderRadius.circular(15),
      ),
      margin: .symmetric(vertical: 10),
      child: ListTile(
        onTap: onTap,
        leading: SvgPicture.network(
          '${envEnum.IMAGE_URL}$icon.svg',
          width: 36,
          height: 36,
          placeholderBuilder: (context) => const Icon(
            Icons.cloud_outlined,
            color: Colors.white70,
            size: 32,
          ),
        ),
        titleTextStyle: TextStyle(fontSize: 20),
        textColor: Colors.white,
        title: Text(cityName, textAlign: .center),
        trailing: Text(
          '${temperature.toString()}°C',
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
      ),
    );
  }
}
