import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<ChartData> amoniaData = [];
  List<ChartData> nivelAguaData = [];
  List<ChartData> temperaturaData = [];
  List<ChartData> phData = [];
  List<ChartData> qualidadeAguaData = [];
  String gravidadeAmoniaData = '';
  String gravidadeTemperaturaData = '';
  String gravidadeNivelAguaData = '';
  String gravidadePhData = '';
  String gravidadeQualidadeAguaData = '';

  Timer? timer;

  @override
  void initState() {
    super.initState();
    buscarApi();
    timer = Timer.periodic(const Duration(seconds: 2), (_) => buscarApi());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> buscarApi() async {
    const String apiUrl =
        'https://api.tago.io/data?query=last_item&variables=leituratemperatura&variables=leituranivelagua&variables=leituraamonia&variables=gravidadenivelagua&variables=gravidadetemperatura&variables=gravidadeamonia&variables=leituraph&variables=leituraqualidadeagua&variables=gravidadeph&variables=gravidadequalidadeagua';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        HttpHeaders.authorizationHeader: '0bf84c95-fa9d-4f40-9389-4e6a65001b4a',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);

      setState(() {
        final int leituraAmonia = responseBody['result'][2]['value'];
        final int leituraNivelAgua = responseBody['result'][1]['value'];
        final int leituraTemperatura = responseBody['result'][0]['value'];
        final int leituraPh = responseBody['result'][6]['value'];
        final int leituraQualidadeAgua = responseBody['result'][7]['value'];

        final String gravidadeAmonia = responseBody['result'][5]['value'];
        final String gravidadeNivelAgua = responseBody['result'][3]['value'];
        final String gravidadeTemperatura = responseBody['result'][4]['value'];
        final String gravidadePh = responseBody['result'][8]['value'];
        final String gravidadeQualidadeAgua =
            responseBody['result'][9]['value'];

        amoniaData.add(ChartData(leituraAmonia.toDouble()));
        nivelAguaData.add(ChartData(leituraNivelAgua.toDouble()));
        temperaturaData.add(ChartData(leituraTemperatura.toDouble()));
        phData.add(ChartData(leituraPh.toDouble()));
        qualidadeAguaData.add(ChartData(leituraQualidadeAgua.toDouble()));

        gravidadeAmoniaData = gravidadeAmonia.toString();
        gravidadeNivelAguaData = gravidadeNivelAgua.toString();
        gravidadeTemperaturaData = gravidadeTemperatura.toString();
        gravidadePhData = gravidadePh.toString();
        gravidadeQualidadeAguaData = gravidadeQualidadeAgua.toString();
      });
    } else {
      // Handle error
      print('Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.blue[600]!.withOpacity(0.5),
          elevation: 0,
          title: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Text(
              'Monitoramento de Água',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(1),
              ),
            ),
          ),
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue[600]!, Colors.blue[300]!, Colors.white],
              stops: const [0.2, 0.4, 0.9],
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
                      amoniaData,
                      gravidadeAmoniaData,
                      Icons.bubble_chart_outlined,
                    ),
                    _buildDataCard(
                      'Leitura de Nível de Água',
                      nivelAguaData,
                      gravidadeNivelAguaData,
                      Icons.water_outlined,
                    ),
                    _buildDataCard(
                      'Leitura de Temperatura',
                      temperaturaData,
                      gravidadeTemperaturaData.isNotEmpty
                          ? gravidadeTemperaturaData.toString()
                          : '',
                      Icons.thermostat_outlined,
                    ),
                    _buildDataCard(
                      'Leitura de pH',
                      phData,
                      gravidadePhData.isNotEmpty
                          ? gravidadePhData.toString()
                          : '',
                      Icons.science_outlined,
                    ),
                    _buildDataCard(
                      'Leitura de qualidade da água',
                      qualidadeAguaData,
                      gravidadeQualidadeAguaData,
                      Icons.invert_colors_outlined,
                    ),
                    _buildFooter(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(10),
      child: Text(
        '© 2023 SENAI - by Cauã, Soraya, Raul Gustavo & Jean',
        style: TextStyle(
          color: Colors.blue[600]!.withOpacity(1.0),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDataCard(
    String title,
    List<ChartData> data,
    String gravidade,
    IconData iconData,
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
                iconData,
                size: 40,
                color: Colors.blue[800],
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
            _buildLineChart(data),
            const SizedBox(height: 5),
            Center(
              child: Text(
                'Gravidade: $gravidade',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(List<ChartData> data) {
    return SizedBox(
      height: 200,
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        series: <ChartSeries>[
          LineSeries<ChartData, String>(
            dataSource: data,
            xValueMapper: (ChartData sales, _) => sales.time,
            yValueMapper: (ChartData sales, _) => sales.value,
            color: Colors.blue[800],
          ),
        ],
      ),
    );
  }
}

class ChartData {
  final String time;
  final double value;

  ChartData(this.value)
      : time = DateFormat("hh':'MM':'ss").format(DateTime.now());
}

