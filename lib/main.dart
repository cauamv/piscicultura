import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
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

        gravidadeNivelAgua = "${responseBody['result'][3]['value']}";
        gravidadeTemperatura = "${responseBody['result'][4]['value']}";
        gravidadeAmonia = "${responseBody['result'][5]['value']}";
      });
    } else {
      // Handle error
      print('Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Monitoramento de Água'),
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildDataGauge(
                    'Leitura de Amônia',
                    leituraAmonia.toDouble(),
                    gravidadeAmonia,
                    Colors.green,
                    Colors.yellow,
                    Colors.red,
                  ),
                  _buildDataGauge(
                    'Leitura de Nível de Água',
                    leituraNivelAgua.toDouble(),
                    gravidadeNivelAgua,
                    Colors.green,
                    Colors.yellow,
                    Colors.red,
                  ),
                  _buildDataGauge(
                    'Leitura de Temperatura',
                    leituraTemperatura.toDouble(),
                    gravidadeTemperatura,
                    Colors.green,
                    Colors.red,
                    Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataGauge(
    String title,
    double value,
    String gravity,
    Color idealColor,
    Color belowColor,
    Color aboveColor,
  ) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            SfRadialGauge(
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
            ),
            const SizedBox(height: 5),
            _buildRangeLabel(gravity, idealColor, belowColor, aboveColor),
          ],
        ),
      ),
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
