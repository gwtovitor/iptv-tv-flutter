import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iptv_flutter_app/videoplayer.dart';

import 'Services/api.dart';

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

  @override
  void initState() {
    super.initState();
    fetchChannels();
  }

  Future<void> fetchChannels() async {
    final response = await http.get(apifunction('/iptv/serie'));
    final parsedResponse = jsonDecode(response.body);
    setState(() {
      channels = parsedResponse;
      channels2 =
          channels[widget.category]['series'][widget.parametro]['episodes'];
    });
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
                final category = channels2;

                return ElevatedButton(
                  onPressed: () => updateSelectedCategory(index),
                  child: Text(
                    'Sesson ${index + 1}',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                      side: BorderSide(width: 1.0, color: Colors.white),
                      backgroundColor: Colors.red),
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

                        return Padding(
                          padding: EdgeInsets.all(5),
                          child: ElevatedButton(
                            onPressed: () =>
                                handleChannelPress(item['link'], context),
                            style: ElevatedButton.styleFrom(
                              primary: Color.fromARGB(255, 0, 0, 0),
                              onPrimary: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: Colors.white, width: 2),
                              ),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                    padding: EdgeInsets.all(10),
                                    child: logo(item['logo'])),
                                Padding(
                                  padding: EdgeInsets.all(0),
                                  child: Text(
                                    item['dataName'],
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
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
        home: Scaffold(backgroundColor: Colors.black, body: waiting(channels)));
  }
}
