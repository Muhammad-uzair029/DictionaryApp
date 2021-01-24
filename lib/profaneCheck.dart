import 'dart:async';

import 'package:bad_words/bad_words.dart';
import 'package:flutter/material.dart';

class profaneCheck extends StatefulWidget {
  @override
  _profaneCheckState createState() => _profaneCheckState();
}

class _profaneCheckState extends State<profaneCheck> {
  final String filer = " off.";

  Filter filter = new Filter();
  Timer _debounce;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('asdasd')),
        body: Container(
            height: 100,
            width: 100,
            child: Column(children: <Widget>[
              new Padding(
                padding: EdgeInsets.all(30),
                child: TextField(
                  onChanged: (String text) {
                    if (_debounce?.isActive ?? false) _debounce.cancel();
                    _debounce = Timer(const Duration(milliseconds: 1000), () {
                      checkSpell(text);
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Search for a word",
                    contentPadding: const EdgeInsets.only(left: 24.0),
                    border: InputBorder.none,
                  ),
                ),
              )
            ])));
  }

  Widget checkSpell(String text) {
    if (filter.isProfane(text)) {
      print('this is bad wordssss');

      return Container(
        child: Text('this is bad wordssss'),
      );
    } else {
      print('nttt');
    }
  }
}
