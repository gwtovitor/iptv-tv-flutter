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
  final _focusNodeEdituser = FocusNode();
  final _textEdituser = TextEditingController();
  final _textEditpass = TextEditingController();
  final _focusNodeEditpass = FocusNode();
  bool _isFocusedwpp = false;
  bool _isFocusedLogin = false;
  bool _isFocusedPass = false;
  bool _isFocusedUser = false;
  bool foco = false;
  bool foco2 = false;
  var user = '';
  var password = '';
  var errorMessage = '';
  var isLoading = true;
  List<dynamic> channels = [];
  String selectedCategory = '';

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

  Future<void> iniciando(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
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
    } else {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const choicepage()));
    }
  }

  Future<void> login(BuildContext context) async {
    try {
      final url = apifunction('/login');
      final headers = {'Content-Type': 'application/json'};
      final body =
          json.encode({'username': user.toLowerCase(), 'password': password});
      final response = await http.post(url, headers: headers, body: body);

      if (json.decode(response.body)['message'] ==
          'User or Password invalid.') {
        setState(() {
          errorMessage = 'Usuario ou senha invalido';
          isLoading = true;
        });
        Timer(const Duration(seconds: 5), () {
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
        Timer(const Duration(seconds: 5), () {
          setState(() {
            errorMessage = '';
          });
        });
      } else {
        final token = json.decode(response.body)['token'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', token);
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const choicepage()));
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao conectar-se com servidor';
        isLoading = true;
      });
      Timer(const Duration(seconds: 5), () {
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
                  return const Color.fromARGB(255, 142, 192, 233);
                } else {
                  return Colors.blue;
                }
              })),
              onPressed: () {
                if (user == '' || password == '') {
                  setState(() {
                    errorMessage = 'Preencha usuário e senha';
                  });
                  Timer(const Duration(seconds: 5), () {
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
              child: const Text('Login')));
    } else {
      return const CircularProgressIndicator(color: Colors.red);
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
                        child: Row(
                          children: [
                            SizedBox(
                              width: 28.h,
                              child: TextField(
                                controller: _textEdituser,
                                focusNode: _focusNodeEdituser,
                                onEditingComplete: () {
                                  setState(() {
                                    foco = false;
                                  });
                                },
                                enabled: foco,
                                decoration: InputDecoration(
                                  labelText: "Digite o Usuario",
                                  labelStyle:
                                      const TextStyle(color: Colors.black),
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
                            Padding(
                                padding: EdgeInsets.only(left: 60.w),
                                child: Focus(
                                  focusNode: _focusNodeEdituser,
                                  onFocusChange: (hasFocus) {
                                    setState(() {
                                      _isFocusedUser = hasFocus;
                                    });
                                  },
                                  child: ElevatedButton(
                                    style: ButtonStyle(backgroundColor:
                                        MaterialStateProperty.resolveWith<
                                            Color>((states) {
                                      if (_isFocusedUser) {
                                        return const Color.fromARGB(
                                            255, 142, 192, 233);
                                      } else {
                                        return Colors.blue;
                                      }
                                    })),
                                    onPressed: () {
                                      setState(() {
                                        foco = true;
                                      });
                                      Timer(const Duration(milliseconds: 500),
                                          () {
                                        FocusScope.of(context)
                                            .requestFocus(_focusNodeEdituser);
                                      });
                                    },
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(Icons.edit),
                                      ],
                                    ), // ),
                                  ),
                                )),
                          ],
                        )),
                    SizedBox(height: 4.w),
                    Container(
                        width: 70.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 28.h,
                              child: TextField(
                                controller: _textEditpass,
                                focusNode: _focusNodeEditpass,
                                onEditingComplete: () {
                                  setState(() {
                                    foco2 = false;
                                  });
                                },
                                enabled: foco2,
                                obscureText: true,
                                decoration: InputDecoration(
                                    labelText: "Digite a Senha",
                                    labelStyle:
                                        const TextStyle(color: Colors.black),
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
                            Padding(
                                padding: EdgeInsets.only(left: 60.w),
                                child: Focus(
                                  focusNode: _focusNodeEditpass,
                                  onFocusChange: (hasFocus) {
                                    setState(() {
                                      _isFocusedPass = hasFocus;
                                    });
                                  },
                                  child: ElevatedButton(
                                    style: ButtonStyle(backgroundColor:
                                        MaterialStateProperty.resolveWith<
                                            Color>((states) {
                                      if (_isFocusedPass) {
                                        return const Color.fromARGB(
                                            255, 142, 192, 233);
                                      } else {
                                        return Colors.blue;
                                      }
                                    })),
                                    onPressed: () {
                                      setState(() {
                                        foco2 = true;
                                      });
                                      Timer(const Duration(milliseconds: 500),
                                          () {
                                        FocusScope.of(context)
                                            .requestFocus(_focusNodeEditpass);
                                      });
                                    },
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(Icons.edit),
                                      ],
                                    ), // ),
                                  ),
                                )),
                          ],
                        )),
                    SizedBox(height: 5.w),
                    loading(context),
                    SizedBox(height: 1.w),
                    Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                    SizedBox(height: 1.w),
                    Focus(
                        onFocusChange: (hasFocus) {
                          setState(() {
                            _isFocusedwpp = hasFocus;
                          });
                        },
                        child: TextButton(
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
                                    ? const Color.fromARGB(255, 150, 203, 241)
                                    : Colors.blue),
                          ),
                        )),
                    SizedBox(height: 1.w),
                    const Text(
                      'Devs: GwTo / D3Gs',
                      style: TextStyle(color: Colors.white, fontSize: 10),
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
