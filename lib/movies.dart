import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iptv_flutter_app/videoplayer.dart';
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

  @override
  void initState() {
    super.initState();
    fetchChannels();
  }

  Future<void> fetchChannels() async {
    final response = await http.get(apifunction('/iptv/movie'));
    final parsedResponse = jsonDecode(response.body);

    setState(() {
      channels = parsedResponse;
      selectedCategory = channels[0]['category'];
    });
  }

  void updateSelectedCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  logo(movielogo) {
    if (movielogo == '') {
      return Image(
        image: AssetImage('assets/images/notfound.jpg'),
        height: 10.h,
      );
    } else {
      return Image.network(
        movielogo,
        height: 10.h,
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
    return Sizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
          title: 'IPTV Channels',
          home: Scaffold(
              backgroundColor: Colors.black,
              body: Padding(
                padding: EdgeInsets.only(top: 25, left: 10, right: 10),
                child: Row(children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      child: ListView.builder(
                        itemCount: channels.length,
                        itemBuilder: (context, index) {
                          final category = channels[index]['category'];
                          return ElevatedButton(
                            onPressed: () => updateSelectedCategory(category),
                            child: Text(
                              category,
                              style: TextStyle(
                                  color: Colors.black, fontSize: 10.sp),
                            ),
                            style: ElevatedButton.styleFrom(
                                side:
                                    BorderSide(width: 1.0, color: Colors.white),
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
                        Padding(
                          padding: const EdgeInsets.only(left: 8, top: 0),
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
                                .where((channel) =>
                                    channel['category'] == selectedCategory)
                                .expand((channel) => channel['resultList'])
                                .map((movie) => Padding(
                                      padding: EdgeInsets.all(5),
                                      child: ElevatedButton(
                                        onPressed: () => handleChannelPress(
                                            movie['link'], context),
                                        style: ElevatedButton.styleFrom(
                                          primary: Color.fromARGB(255, 0, 0, 0),
                                          onPrimary: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            side: BorderSide(
                                                color: Colors.white, width: 2),
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Padding(
                                                padding: EdgeInsets.all(10),
                                                child: logo(movie['logo'])),
                                            Padding(
                                              padding: EdgeInsets.all(0),
                                              child: Text(
                                                movie['dataName'],
                                                textAlign: TextAlign.center,
                                                style:
                                                    TextStyle(fontSize: 10.sp),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        )
                      ])))
                ]),
              )));
    });
  }
}
