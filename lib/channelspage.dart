import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iptv_flutter_app/videoplayerchannels.dart';
import 'package:sizer/sizer.dart';
import 'Services/api.dart';

void main() {
  runApp(channelspage());
}

class channelspage extends StatefulWidget {
  @override
  _channelspage createState() => _channelspage();
}

class _channelspage extends State<channelspage> {
  List<dynamic> channels = [];
  String selectedCategory = '';

  @override
  void initState() {
    super.initState();
    fetchChannels();
  }

  Future<void> fetchChannels() async {
    final response = await http.get(apifunction('/iptv/channel'));
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
        height: 8.h,
      );
    } else {
      return Image.network(
        movielogo,
        height: 8.h,
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
        home: Scaffold(
            backgroundColor: Colors.black,
            body: Sizer(builder: (context, orientation, deviceType) {
              return Padding(
                padding: EdgeInsets.only(top: 3.h, left: 2.w, right: 2.w),
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
                                fontSize: 10.sp,
                                color: Colors.black,
                              ),
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
                                                style: TextStyle(
                                                  fontSize: 8.sp,
                                                ),
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
              );
            })));
  }
}
