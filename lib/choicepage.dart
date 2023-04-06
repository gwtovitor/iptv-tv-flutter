import 'package:flutter/material.dart';
import 'package:iptv_flutter_app/series.dart';
import 'package:sizer/sizer.dart';

import 'channelspage.dart';
import 'login.dart';
import 'movies.dart';

void main() {
  runApp(const ChoicePage());
}

class ChoicePage extends StatefulWidget {
  const ChoicePage({super.key});

  @override
  State<ChoicePage> createState() => _ChoicePageState();
}

class _ChoicePageState extends State<ChoicePage> {
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
                      MaterialPageRoute(
                          builder: (context) => const Loginpage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      side: BorderSide(width: 1.0.sp, color: Colors.white),
                      backgroundColor: Colors.red),
                  child: const Text(
                    'Sair',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ChannelsPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      side: BorderSide(width: 1.0.sp, color: Colors.white),
                      backgroundColor: Colors.red),
                  child: const Text(
                    'Canais',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
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
                  style: ElevatedButton.styleFrom(
                      side: BorderSide(width: 1.0.sp, color: Colors.white),
                      backgroundColor: Colors.red),
                  child: const Text(
                    'Series',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5.w),
              Container(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MoviesPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      side: const BorderSide(width: 1.0, color: Colors.white),
                      backgroundColor: Colors.red),
                  child: const Text(
                    'Filmes',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ]),
          ));
    }));
  }
}
