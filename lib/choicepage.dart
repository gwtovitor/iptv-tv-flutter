import 'package:flutter/material.dart';
import 'package:iptv_flutter_app/series.dart';
import 'package:sizer/sizer.dart';

import 'channelspage.dart';
import 'login.dart';
import 'movies.dart';

void main() {
  runApp(choicepage());
}

class choicepage extends StatefulWidget {
  const choicepage({super.key});

  @override
  State<choicepage> createState() => _choicepageState();
}

class _choicepageState extends State<choicepage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Sizer(builder: (context, orientation, deviceType) {
      return Scaffold(
          backgroundColor: Colors.black,
          body: Padding(
            padding: EdgeInsets.only(top: 10.w),
            child: Column(children: [
              Container(
                padding: EdgeInsets.only(right: 5.h),
                alignment: Alignment.topRight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Loginpage()),
                    );
                  },
                  child: Text(
                    'Sair',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                      side: BorderSide(width: 1.0.sp, color: Colors.white),
                      backgroundColor: Colors.red),
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => channelspage()),
                    );
                  },
                  child: Text(
                    'Canais',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                      side: BorderSide(width: 1.0.sp, color: Colors.white),
                      backgroundColor: Colors.red),
                ),
              ),
              SizedBox(height: 5.w),
              Container(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => seriespage()),
                    );
                  },
                  child: Text(
                    'Series',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                      side: BorderSide(width: 1.0.sp, color: Colors.white),
                      backgroundColor: Colors.red),
                ),
              ),
              SizedBox(height: 5.w),
              Container(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => moviespage()),
                    );
                  },
                  child: Text(
                    'Filmes',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                      side: BorderSide(width: 1.0, color: Colors.white),
                      backgroundColor: Colors.red),
                ),
              ),
            ]),
          ));
    }));
  }
}
