import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iptv_flutter_app/videoplayer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import 'Services/api.dart';
import 'login.dart';

void main() {
  runApp(const SeassonPage(parametro: null, category: null));
}

class SeassonPage extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final parametro;
  // ignore: prefer_typing_uninitialized_variables
  final category;

  const SeassonPage({Key? key, required this.parametro, required this.category})
      : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _SeassonPage createState() => _SeassonPage();
}

class _SeassonPage extends State<SeassonPage> {
  List<dynamic> channels = [];
  List<dynamic> channels2 = [];
  var selectedCategory = 0;
  int _selectedIndex = 0; // armazena o índice do botão selecionado
  final List<Color> _buttonColors = List.generate(
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
          title: const Text('Token expirado'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Favor fazer login novamente.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const Loginpage()));
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
          title: const Text('Erro ao se conectar com servidor'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Favor entrar em contato com administrador'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const Loginpage()));
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
        // ignore: use_build_context_synchronously
        _showErrorPopup(context);
      } else {}
    }
    if (channels2[0] == null) {
      // ignore: use_build_context_synchronously
      _showTokenExpiredPopup(context);
    }
  }

  waiting(channels) {
    while (channels.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return Padding(
      padding: const EdgeInsets.only(top: 25, left: 10, right: 10),
      child: Row(children: [
        Expanded(
          flex: 1,
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
                style: ElevatedButton.styleFrom(
                  side: const BorderSide(width: 1.0, color: Colors.white),
                  backgroundColor: _buttonColors[index],
                ),
                child: Text(
                  'Sesson ${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
            flex: 3,
            child: Column(children: [
              Expanded(
                  child: GridView.builder(
                      itemCount: channels2[selectedCategory].length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                      ),
                      itemBuilder: (context, index) {
                        final item = channels2[selectedCategory][index];

                        return Expanded(
                            flex: 2,
                            child: SizedBox(
                                height: 50.w,
                                child: ElevatedButton(
                                    onPressed: () => handleChannelPress(
                                        item['link'], context),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.black,
                                    ),
                                    child: Expanded(
                                      flex: 1,
                                      child: SizedBox(
                                        height: 50.w,
                                        child: ElevatedButton(
                                          onPressed: () => handleChannelPress(
                                              item['link'], context),
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            backgroundColor: Colors.black,
                                          ),
                                          child: Column(
                                            children: [
                                              Stack(
                                                children: [
                                                  SizedBox(
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
            ]))
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
      return const Image(
        image: AssetImage('assets/images/notfound.jpg'),
        height: 120,
      );
    } else {
      return Image.network(
        movielogo,
        height: 120,
        errorBuilder:
            (BuildContext context, Object exception, StackTrace? stackTrace) {
          return const Image(
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
