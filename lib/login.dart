import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Services/api.dart';
import 'choicepage.dart';
import 'package:sizer/sizer.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({Key? key, context}) : super(key: key);

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  bool _isFocusedwpp = false;
  bool _isFocusedLogin = false;
  var user = '';
  var password = '';
  var errorMessage = '';
  var isLoading = true;

  Future<void> iniciando(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      print(token);
    } else {
      return;
    }
  }

  Future<void> login(BuildContext context) async {
    try {
      final url = apifunction('/login');
      final headers = {'Content-Type': 'application/json'};
      final body =
          json.encode({'username': user.toLowerCase(), 'password': password});
      final response = await http.post(url, headers: headers, body: body);
      print(json.decode(response.body)['message']);
      if (json.decode(response.body)['message'] ==
          'User or Password invalid.') {
        setState(() {
          errorMessage = 'Usuario ou senha invalido';
          isLoading = true;
        });
        Timer(Duration(seconds: 5), () {
          setState(() {
            errorMessage = '';
          });
        });
      } else if (json.decode(response.body)['message'] == 'Payment expired.') {
        setState(() {
          errorMessage =
              'Usuario expirado, favor entrar em contato com o administrador';
          isLoading = true;
        });
        Timer(Duration(seconds: 5), () {
          setState(() {
            errorMessage = '';
          });
        });
      } else {
        final token = json.decode(response.body)['token'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', token);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => choicepage()));
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao conectar-se com servidor';
        isLoading = true;
      });
      Timer(Duration(seconds: 5), () {
        setState(() {
          errorMessage = '';
        });
      });
    }
  }

  loading(context) {
    if (isLoading) {
      return Focus(
          onFocusChange: (hasFocus) {
            setState(() {
              _isFocusedLogin = hasFocus;
            });
          },
          child: ElevatedButton(
              style: ButtonStyle(backgroundColor:
                  MaterialStateProperty.resolveWith<Color>((states) {
                if (_isFocusedLogin) {
                  return Color.fromARGB(255, 142, 192, 233);
                } else {
                  return Colors.blue;
                }
              })),
              onPressed: () {
                if (user == '' || password == '') {
                  setState(() {
                    errorMessage = 'Preencha usuário e senha';
                  });
                  Timer(Duration(seconds: 5), () {
                    setState(() {
                      errorMessage = '';
                    });
                  });
                } else {
                  login(context);
                  setState(() {
                    isLoading = false;
                  });
                }
              },
              child: Text('Login')));
    } else {
      return CircularProgressIndicator(color: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(),
          child: Scaffold(
            body: Sizer(builder: (context, orientation, deviceType) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 10.w),
                    Container(
                      alignment: Alignment.center,
                      child: const Text(
                        "TELEVIDO",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.w,
                    ),
                    Container(
                      width: 70.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: "Digite o Usuario",
                          labelStyle: TextStyle(color: Colors.black),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 5.w, vertical: 2.w),
                        ),
                        onChanged: (String texto) {
                          setState(() {
                            user = texto;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 4.w),
                    Container(
                      width: 70.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                            labelText: "Digite a Senha",
                            labelStyle: TextStyle(color: Colors.black),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 5.w, vertical: 2.w)),
                        onChanged: (String texto) {
                          setState(() {
                            password = texto;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 5.w),
                    loading(context),
                    SizedBox(height: 1.w),
                    Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                    SizedBox(height: 1.w),
                    TextButton(
                      onPressed: () async {
                        const url = 'https://wa.me/5581986716936';
                        // ignore: deprecated_member_use
                        if (await canLaunch(url)) {
                          // ignore: deprecated_member_use
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                      child: Text(
                        'Contato: (81) 98671-6936',
                        style: TextStyle(
                            color: _isFocusedwpp
                                ? Color.fromARGB(255, 150, 203, 241)
                                : Colors.blue),
                      ),
                    ),
                    SizedBox(height: 1.w),
                    Text(
                      'Devs: GwTo / D3Gs',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ],
                ),
              );
            }),
            backgroundColor: Colors.black,
            extendBodyBehindAppBar: true,
          ),
        ),
      ),
    );
  }
}
