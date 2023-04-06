import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iptv_flutter_app/videoplayer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import 'Services/api.dart';
import 'login.dart';

void main() {
  runApp(seassonspage(parametro: null, category: null));
}

class seassonspage extends StatefulWidget {
  final parametro;
  final category;

  seassonspage({Key? key, required this.parametro, required this.category})
      : super(key: key);
  @override
  _seassonspage createState() => _seassonspage();
}

class _seassonspage extends State<seassonspage> {
  List<dynamic> channels = [];
  List<dynamic> channels2 = [];
  var selectedCategory = 0;
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
        apifunction('/iptv/serie'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final parsedResponse = jsonDecode(response.body);
      setState(() {
        channels = parsedResponse;
        channels2 =
            channels[widget.category]['series'][widget.parametro]['episodes'];
      });
    } catch (error) {
      if (error is http.Response &&
          error.statusCode == 401 &&
          error.statusCode == 500) {
        _showErrorPopup(context);
      } else {}
    }
    if (channels2[0] == null) {
      _showTokenExpiredPopup(context);
    }
  }

  waiting(channels) {
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
              itemCount: channels2.length,
              itemBuilder: (context, index) {
                return ElevatedButton(
                  onPressed: () {
                    updateSelectedCategory(index);
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
                    'Sesson ${index + 1}',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    side: BorderSide(width: 1.0, color: Colors.white),
                    backgroundColor: _buttonColors[index],
                  ),
                );
              },
            ),
          ),
        ),
        Expanded(
            flex: 3,
            child: Container(
                child: Column(children: [
              Expanded(
                  child: GridView.builder(
                      itemCount: channels2[selectedCategory].length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                      ),
                      itemBuilder: (context, index) {
                        final item = channels2[selectedCategory][index];

                        return Expanded(
                            flex: 2,
                            child: Container(
                                height: 50.w,
                                child: ElevatedButton(
                                    onPressed: () => handleChannelPress(
                                        item['link'], context),
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.black,
                                      onPrimary: Colors.white,
                                    ),
                                    child: Expanded(
                                      flex: 1,
                                      child: Container(
                                        height: 50.w,
                                        child: ElevatedButton(
                                          onPressed: () => handleChannelPress(
                                              item['link'], context),
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
                                                    width: double.infinity,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                      child: item['logo'] !=
                                                                  null &&
                                                              item['logo'] != ''
                                                          ? Image.network(
                                                              item['logo'],
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                              width: double
                                                                  .infinity,
                                                              height: double
                                                                  .infinity,
                                                            )
                                                          : Image.asset(
                                                              'assets/images/notfound.png',
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                              width: double
                                                                  .infinity,
                                                              height: double
                                                                  .infinity,
                                                            ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    bottom: 0,
                                                    left: 0,
                                                    right: 0,
                                                    child: Container(
                                                      color: Colors.black
                                                          .withOpacity(1),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 2.h,
                                                              horizontal: 5.w),
                                                      child: Text(
                                                        item['dataName'],
                                                        style: TextStyle(
                                                          fontSize: 8.sp,
                                                          color: Colors.white,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ))));
                      }))
            ])))
      ]),
    );
  }

  void updateSelectedCategory(category) {
    setState(() {
      selectedCategory = category;
    });
  }

  Widget logo(String movielogo) {
    if (movielogo == '') {
      return Image(
        image: AssetImage('assets/images/notfound.jpg'),
        height: 120,
      );
    } else {
      return Image.network(
        movielogo,
        height: 120,
        errorBuilder:
            (BuildContext context, Object exception, StackTrace? stackTrace) {
          return Image(
            image: AssetImage('assets/images/notfound.jpg'),
            height: 120,
          );
        },
      );
    }
  }

  void handleChannelPress(String link, context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(parametro: link)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'IPTV Channels',
        home: Sizer(builder: (context, orientation, deviceType) {
          return Scaffold(
              backgroundColor: Colors.black, body: waiting(channels));
        }));
  }
}
