import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iptv_flutter_app/videoplayerchannels.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'Services/api.dart';
import 'login.dart';

void main() {
  runApp(const ChannelsPage());
}

class ChannelsPage extends StatefulWidget {
  const ChannelsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ChannelsPage createState() => _ChannelsPage();
}

class _ChannelsPage extends State<ChannelsPage> {
  List<dynamic> channels = [];
  String selectedCategory = '';
  var jsonOk = '';
  int _selectedIndex = 0; // armazena o índice do botão selecionado
  final List<Color> _buttonColors = List.generate(
    //lista de cores
    100,
    (index) => Colors.black,
  );

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
        apifunction('/iptv/channel'),
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
        // ignore: use_build_context_synchronously
        _showErrorPopup(context);
      } else {}
    }

    // ignore: unnecessary_null_comparison
    if (selectedCategory[0] == null) {
      // ignore: use_build_context_synchronously
      _showTokenExpiredPopup(context);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchChannels();
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
      return const Center(child: CircularProgressIndicator());
    }
    return Padding(
      padding: EdgeInsets.only(top: 3.h, left: 2.w, right: 2.w),
      child: Row(children: [
        Expanded(
          flex: 1,
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
                      style: ElevatedButton.styleFrom(
                        side: const BorderSide(width: 1.0, color: Colors.white),
                        backgroundColor: _buttonColors[index],
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                );
              }),
        ),
        Expanded(
            flex: 3,
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 0),
                child: Text(
                  selectedCategory,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.sp,
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
                            child: SizedBox(
                              height: 45.w,
                              child: ElevatedButton(
                                onPressed: () =>
                                    handleChannelPress(movie['link'], context),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.black,
                                ),
                                child: Column(
                                  children: [
                                    Stack(
                                      children: [
                                        SizedBox(
                                          height: 40.w,
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
            ]))
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'IPTV Channels',
        home: Scaffold(
            backgroundColor: Colors.black,
            body: Sizer(builder: (context, orientation, deviceType) {
              return waiting();
            })));
  }
}
