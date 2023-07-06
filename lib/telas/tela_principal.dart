import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart';


class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}


class _TelaPrincipalState extends State<TelaPrincipal> {
  @override

  void initState() {
    super.initState();
    buscarApi();
  }

  int leituraAmonia = 0;
  String gravidadeAmonia = "";

  int leituraNivelAgua = 0;
  String gravidadeNivelAgua = "";

  int leituraTemperatura = 0;
  String gravidadeTemperatura = "";
    
  Future<void> buscarApi() async {

    String urlDadosPiscicultura = 'https://api.tago.io/data?query=last_item&variables=leituratemperatura&variables=leituranivelagua&variables=leituraamonia&variables=gravidadenivelagua&variables=gravidadetemperatura&variables=gravidadeamonia';

    Response respostaPisciculta = await get(
      headers: {
      HttpHeaders.authorizationHeader: '0bf84c95-fa9d-4f40-9389-4e6a65001b4a',
    },
      Uri.parse(urlDadosPiscicultura)
    );

    Map mapBody = json.decode(respostaPisciculta.body);

    
    setState(() {
      leituraTemperatura = mapBody['result'][0]['value'];
      leituraNivelAgua = mapBody['result'][1]['value'];
      leituraAmonia = mapBody['result'][2]['value'];
      
      gravidadeNivelAgua = "${mapBody['result'][3]['value']}";
      gravidadeTemperatura = "${mapBody['result'][4]['value']}";
      gravidadeAmonia = "${mapBody['result'][5]['value']}";
    });
   }

  @override
  Widget build(BuildContext context) {

    criaBody() {
      return  Column(
        children: [
          Text("$leituraAmonia"),
          Text("$leituraNivelAgua"),
          Text("$leituraTemperatura"),          
          Text(gravidadeAmonia),
          Text(gravidadeNivelAgua),
          Text(gravidadeTemperatura),
          
        ],
      );
    }

    return  Scaffold(
      body: criaBody(),
    );
  }
}