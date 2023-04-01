import 'package:flutter/material.dart';

class VirtualKeyboard extends StatelessWidget {
  final TextEditingController textEditingController;
  final width;

  VirtualKeyboard({
    required this.textEditingController,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: width),
      child: Column(
        children: <Widget>[
          buildKeyboardRow(
              context, ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']),
          buildKeyboardRow(
              context, ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p']),
          buildKeyboardRow(
              context, ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l']),
          buildKeyboardRow(context, ['z', 'x', 'c', 'v', 'b', 'n', 'm']),
          buildKeyboardRow(
              context, [' ', '.', 'Proximo', 'Anterior', 'Backspace']),
        ],
      ),
    );
  }

  Widget buildKeyboardRow(BuildContext context, List<String> keys) {
    return Container(
      padding: EdgeInsets.all(0.2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: keys.map((key) {
          return buildKeyboardButton(context, key);
        }).toList(),
      ),
    );
  }

  Widget buildKeyboardButton(BuildContext context, String key) {
    if (key == 'Backspace') {
      return IconButton(
        icon: Icon(
          Icons.backspace,
          color: Colors.white,
        ),
        onPressed: () {
          if (textEditingController.text.isNotEmpty) {
            textEditingController.text = textEditingController.text
                .substring(0, textEditingController.text.length - 1);
          }
        },
      );
    } else if (key == 'Proximo') {
      return ElevatedButton(
        child: Text(key),
        onPressed: () {
          textEditingController.text += key;
        },
      );
    } else if (key == 'Anterior') {
      return ElevatedButton(
        child: Text(key),
        onPressed: () {
          textEditingController.text += key;
        },
      );
    } else {
      return ElevatedButton(
        child: Text(key),
        onPressed: () {
          textEditingController.text += key;
        },
      );
    }
  }
}
