import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iptv_flutter_app/login.dart';
import 'package:iptv_flutter_app/videoplayer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import 'Services/api.dart';

void main() {
  runApp(moviespage());
}

class moviespage extends StatefulWidget {
  @override
  _moviespage createState() => _moviespage();
}

class _moviespage extends State<moviespage> {
  List<dynamic> channels = [];
  String selectedCategory = '';
  var jsonOk = '';
  int _selectedIndex = 0; // armazena o índice do botão selecionado
  List<Color> _buttonColors = List.generate(
    //lista de cores
    100,
    (index) => Colors.black,
  );

  @override
  void initState() {
    super.initState();
    fetchChannels();
  }

  Future<void> _showTokenExpiredPopup(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Token expirado'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Favor fazer login novamente.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => Loginpage()));
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showErrorPopup(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Erro ao se conectar com servidor'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Favor entrar em contato com administrador'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => Loginpage()));
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchChannels() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        apifunction('/iptv/movie'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final parsedResponse = jsonDecode(response.body);
      setState(() {
        channels = parsedResponse;
        selectedCategory = channels[0]['category'];
      });
    } catch (error) {
      if (error is http.Response &&
          error.statusCode == 401 &&
          error.statusCode == 500) {
        _showErrorPopup(context);
      } else {}
    }
    if (selectedCategory == null) {
      _showTokenExpiredPopup(context);
    }
  }

  void updateSelectedCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  void handleChannelPress(String link, context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(parametro: link)),
    );
  }

  waiting() {
    while (channels.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }
    return Padding(
      padding: EdgeInsets.only(top: 25, left: 10, right: 10),
      child: Row(children: [
        Expanded(
          flex: 1,
          child: Container(
            child: ListView.builder(
                itemCount: channels.length,
                itemBuilder: (context, index) {
                  final category = channels[index]['category'];
                  return StatefulBuilder(
                    builder: (BuildContext context,
                        StateSetter setState /*You can rename this!*/) {
                      return ElevatedButton(
                        onPressed: () {
                          updateSelectedCategory(category);
                          setState(() {
                            if (_selectedIndex == index) {
                              _selectedIndex = -1; // deselecionar o botão
                              _buttonColors[index] = Colors
                                  .black; // definir a cor preta para o botão deselecionado
                            } else {
                              if (_selectedIndex != -1) {
                                _buttonColors[_selectedIndex] = Colors
                                    .black; // definir a cor preta para o botão anteriormente selecionado
                              }
                              _selectedIndex = index; // selecionar o novo botão
                              _buttonColors[_selectedIndex] = Colors
                                  .red; // definir a cor vermelha para o botão selecionado
                            }
                          });
                        },
                        child: Text(
                          category,
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: Colors.white, fontSize: 10.sp),
                        ),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: _buttonColors[index],
                            side: BorderSide(width: 1, color: Colors.white)),
                      );
                    },
                  );
                }),
          ),
        ),
        Expanded(
            flex: 3,
            child: Container(
                child: Column(children: [
              Padding(
                padding: EdgeInsets.only(
                  left: 0,
                  top: 2.h,
                ),
                child: Text(
                  selectedCategory,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  children: channels
                      .where(
                          (channel) => channel['category'] == selectedCategory)
                      .expand((channel) => channel['resultList'])
                      .map((movie) => Expanded(
                            flex: 2,
                            child: Container(
                              height: 50.w,
                              child: ElevatedButton(
                                onPressed: () =>
                                    handleChannelPress(movie['link'], context),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.black,
                                  onPrimary: Colors.white,
                                ),
                                child: Column(
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                          height: 45.w,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            child: movie['logo'] != null &&
                                                    movie['logo'] != ''
                                                ? Image.network(
                                                    movie['logo'],
                                                    fit: BoxFit.scaleDown,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                  )
                                                : Image.asset(
                                                    'assets/images/notfound.png',
                                                    fit: BoxFit.scaleDown,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                  ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            color: Colors.black.withOpacity(1),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 2.h, horizontal: 5.w),
                                            child: Text(
                                              movie['dataName'],
                                              style: TextStyle(
                                                fontSize: 8.sp,
                                                color: Colors.white,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              )
            ])))
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
          title: 'IPTV Channels',
          home: Scaffold(backgroundColor: Colors.black, body: waiting()));
    });
  }
}
