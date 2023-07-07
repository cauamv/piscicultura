import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_gauges/gauges.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int leituraAmonia = 0;
  String gravidadeAmonia = "";

  int leituraNivelAgua = 0;
  String gravidadeNivelAgua = "";

  int leituraTemperatura = 0;
  String gravidadeTemperatura = "";

  int leituraPh = 0;
  String gravidadePh = "";

  int leituraQualidadeAgua = 0;
  String gravidadeQualidadeAgua = "";

  Timer? timer;

  @override
  void initState() {
    super.initState();
    buscarApi();
    timer = Timer.periodic(const Duration(seconds: 30), (_) => buscarApi());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> buscarApi() async {
    const String apiUrl =
        'https://api.tago.io/data?query=last_item&variables=leituratemperatura&variables=leituranivelagua&variables=leituraamonia&variables=gravidadenivelagua&variables=gravidadetemperatura&variables=gravidadeamonia';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        HttpHeaders.authorizationHeader: '0bf84c95-fa9d-4f40-9389-4e6a65001b4a',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);

      setState(() {
        leituraTemperatura = responseBody['result'][0]['value'];
        leituraNivelAgua = responseBody['result'][1]['value'];
        leituraAmonia = responseBody['result'][2]['value'];
        leituraPh = responseBody['result'][6]['value'];
        leituraQualidadeAgua = responseBody['result'][7]['value'];

        gravidadeNivelAgua = "${responseBody['result'][3]['value']}";
        gravidadeTemperatura = "${responseBody['result'][4]['value']}";
        gravidadeAmonia = "${responseBody['result'][5]['value']}";
        gravidadePh = "${responseBody['result'][8]['value']}";
        gravidadeQualidadeAgua = "${responseBody['result'][9]['value']}";
      });
    } else {
      // Handle error
      print('Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Monitoramento de Água'),
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue[200]!, Colors.white],
              stops: const [0.2, 0.8],
            ),
          ),
         child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  _buildDataCard(
                    'Leitura de Amônia',
                    leituraAmonia.toDouble(),
                    gravidadeAmonia,
                    Colors.green,
                    Colors.yellow,
                    Colors.red,
                    Icons.thermostat_outlined,
                  ),
                  _buildDataCard(
                    'Leitura de Nível de Água',
                    leituraNivelAgua.toDouble(),
                    gravidadeNivelAgua,
                    Colors.green,
                    Colors.yellow,
                    Colors.red,
                    Icons.waves_outlined,
                  ),
                  _buildDataCard(
                    'Leitura de Temperatura',
                    leituraTemperatura.toDouble(),
                    gravidadeTemperatura,
                    Colors.green,
                    Colors.red,
                    Colors.red,
                    Icons.thermostat_outlined,
                  ),
                  _buildDataCard(
                    'Leitura de pH',
                    leituraPh.toDouble(),
                    gravidadePh,
                    Colors.green,
                    Colors.yellow,
                    Colors.red,
                    Icons.thermostat_outlined,
                  ),
                  _buildDataCard(
                    'Leitura de Qualidade da Água',
                    leituraQualidadeAgua.toDouble(),
                    gravidadeQualidadeAgua,
                    Colors.green,
                    Colors.yellow,
                    Colors.red,
                    Icons.thermostat_outlined,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildDataCard(
    String title,
    double value,
    String gravity,
    Color idealColor,
    Color belowColor,
    Color aboveColor,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(
                icon,
                size: 40,
              ),
              title: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildRadialGauge(value, idealColor, belowColor, aboveColor),
            const SizedBox(height: 5),
            _buildRangeLabel(gravity, idealColor, belowColor, aboveColor),
          ],
        ),
      ),
    );
  }

  Widget _buildRadialGauge(
    double value,
    Color idealColor,
    Color belowColor,
    Color aboveColor,
  ) {
    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
          minimum: 0,
          maximum: 100,
          showLabels: false,
          showTicks: false,
          axisLineStyle: AxisLineStyle(
            thickness: 0.15,
            cornerStyle: CornerStyle.bothCurve,
            color: Colors.grey[300],
            thicknessUnit: GaugeSizeUnit.factor,
          ),
          radiusFactor: 0.5,
          pointers: <GaugePointer>[
            RangePointer(
              value: value,
              width: 0.15,
              sizeUnit: GaugeSizeUnit.factor,
              gradient: SweepGradient(
                colors: [idealColor, belowColor, aboveColor],
                stops: [0.25, 0.5, 0.75],
              ),
            ),
            MarkerPointer(
              value: value,
              color: Colors.black,
              markerType: MarkerType.triangle,
              markerHeight: 10,
              markerWidth: 10,
            ),
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
              widget: Container(
                child: Text(
                  value.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              angle: 90,
              positionFactor: 0.4,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRangeLabel(
    String gravity,
    Color idealColor,
    Color belowColor,
    Color aboveColor,
  ) {
    return Row(
      children: [
        _buildLabel('Ideal', idealColor),
        _buildLabel('Abaixo', belowColor),
        _buildLabel('Acima', aboveColor),
      ],
    );
  }
    Widget _buildLabel(String text, Color color) {
    return Expanded(
      child: Container(
        height: 20,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}