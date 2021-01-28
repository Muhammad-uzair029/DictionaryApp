import 'dart:async';
import 'dart:convert';

// import 'package:DcitionaryApp/profaneCheck.dart';
import 'package:AnySearch/Variables.dart';
import 'package:AnySearch/Bloc_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:bad_words/bad_words.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';
import 'package:AnySearch/Bloc_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<ChangTransBloc>.value(
            value: ChangTransBloc(),
          ),
        ],
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: MyHomePage(),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
// Variable Class instance creation
  Variables _variables = new Variables();

  // Filter for badcheck worrdss
  final String filer = " off.";
  Filter filter = new Filter();
  // API and token that we recieve from OWLBOT website
  String _url = "https://owlbot.info/api/v4/dictionary/";
  String _token = "6f27c7a88b409703e898882838ebc06ccbc4c5d1";

  TextEditingController _controller = new TextEditingController();

  StreamController _streamController;
  Stream _stream;
  Timer _debounce;
  // used in Stream Builder

  bool isExpanded = false;
  bool descTextShowFlag = false;

  //====================== language Selectorrr===========================
  String dropdownValue;

  var translatedText;
  _seaarch() async {
    if (_controller.text == null || _controller.text.length == 0) {
      _streamController.add(null);
    }

    Response response = await get(_url + _controller.text.trim(),
        headers: {"Authorization": "Token " + _token});
    _streamController.add(json.decode(response.body));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _streamController = StreamController();
    _stream = _streamController.stream;
  }

  @override
  Widget build(BuildContext context) {
// Bloc
    final ChangTransBloc _transBloc = Provider.of<ChangTransBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Any Search"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 12.0, bottom: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  child: TextFormField(
                    textInputAction: TextInputAction.search,
                    onFieldSubmitted: (valeue) {
                      checkSpell(valeue);
                      _seaarch();
                    },
                    onChanged: (String text) {
                      if (_debounce?.isActive ?? false) _debounce.cancel();
                      _debounce = Timer(const Duration(milliseconds: 1000), () {
                        _seaarch();
                      });
                    },
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Search for a word",
                      contentPadding: const EdgeInsets.only(left: 24.0),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(8.0),
        child: StreamBuilder(
          stream: _stream,
          builder: (BuildContext ctx, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return Center(
                child: Text(
                  'Type a word to get its meaning 🤔',
                  style: TextStyle(fontSize: 18, color: Colors.blue),
                ),
              );
            }

            if (snapshot.data == "waiting") {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.data == 'NoData') {
              return Center(
                child: Text(
                  'No Defination 😭',
                  style: TextStyle(fontSize: 20, color: Colors.blue),
                ),
              );
            }

            return ListView.builder(
                itemCount: snapshot.data['definitions'].length,
                itemBuilder: (ctx, i) => ListBody(
                      children: [
                        Card(
                          color: Colors.grey[500],
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          margin:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: ExpansionTile(
                              // onExpansionChanged: (bool expanding) =>
                              //     setState(() => this.isExpanded = expanding),
                              backgroundColor: Colors.grey,
                              leading: snapshot.data['definitions'][i]
                                          ['image_url'] ==
                                      null
                                  ? CircleAvatar(
                                      backgroundColor: Colors.black,
                                      child: Icon(Icons.chevron_right),
                                      maxRadius: 25,
                                    )
                                  : CircleAvatar(
                                      maxRadius: 25,
                                      backgroundImage: NetworkImage(snapshot
                                          .data['definitions'][i]['image_url']),
                                    ),
                              title: Text(
                                _controller.text.trim() +
                                    "  (" +
                                    snapshot.data['definitions'][i]['type'] +
                                    ")",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: isExpanded
                                      ? FontWeight.w400
                                      : FontWeight.w300,
                                  color:
                                      isExpanded ? Colors.white : Colors.black,
                                ),
                              ),
                              children: [
                                Container(
                                  margin: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Defination:',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                      GestureDetector(
                                        onTap: () => {
                                          setState(() => descTextShowFlag =
                                              !descTextShowFlag)
                                        },
                                        child: snapshot
                                                .data['definitions'][i]
                                                    ['definition']
                                                .isNotEmpty
                                            ? AnimatedCrossFade(
                                                duration:
                                                    Duration(milliseconds: 400),
                                                crossFadeState: descTextShowFlag
                                                    ? CrossFadeState.showFirst
                                                    : CrossFadeState.showSecond,
                                                firstChild: Text(
                                                    snapshot.data['definitions']
                                                            [i]['definition']
                                                        .trimLeft(),
                                                    // textAlign: TextAlign.justify,
                                                    style: TextStyle(
                                                        height: 1.5,
                                                        fontSize: 17,
                                                        color: Colors.grey[900],
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                secondChild: Text(
                                                    snapshot.data['definitions']
                                                        [i]['definition'],
                                                    maxLines: 7,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        height: 1.5,
                                                        fontSize: 16,
                                                        color:
                                                            Colors.grey[1000],
                                                        fontWeight:
                                                            FontWeight.w400)),
                                              )
                                            : Container(),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Divider(
                                            endIndent: 100,
                                            color: Colors.white),
                                      ),
                                      snapshot.data['definitions'][i]['example']
                                                  .toString() !=
                                              'null'
                                          ? Text(
                                              'Example:',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            )
                                          : SizedBox(),
                                      snapshot.data['definitions'][i]['example']
                                                  .toString() !=
                                              'null'
                                          ? Text(
                                              snapshot.data['definitions'][i]
                                                      ['example']
                                                  .toString(),
                                              maxLines: 7,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  height: 1.5,
                                                  fontSize: 16,
                                                  color: Colors.grey[1000],
                                                  fontWeight: FontWeight.w400))
                                          : Container(),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Divider(
                                            endIndent: 100,
                                            color: Colors.white),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(
                                            "Translate Message in",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                          DropdownButton<String>(
                                            value: dropdownValue,
                                            icon: Icon(
                                              Icons
                                                  .arrow_drop_down_circle_outlined,
                                              color: Colors.white,
                                            ),
                                            iconSize: 30,
                                            elevation: 16,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                            underline: Container(
                                              height: 1,
                                              color: Colors.white,
                                            ),
                                            onChanged: (String newValue) {
                                              setState(() {
                                                dropdownValue = newValue;
                                                _transBloc.trans(
                                                    _controller.text,
                                                    dropdownValue);
                                                _transBloc.transSentence(
                                                    snapshot.data["definitions"]
                                                        [i]["definition"],
                                                    dropdownValue);
                                                _transBloc.transExample(
                                                    snapshot.data["definitions"]
                                                        [i]["example"],
                                                    dropdownValue);

                                                _transBloc
                                                    .translatedDefinitionWrod(
                                                        dropdownValue);
                                                _transBloc.translatedExWrod(
                                                    dropdownValue);
                                              });
                                            },
                                            items: _variables.lang
                                                .map((string, value) {
                                                  return MapEntry(
                                                    string,
                                                    DropdownMenuItem<String>(
                                                        value: value,
                                                        child: Text(
                                                          string,
                                                        )),
                                                  );
                                                })
                                                .values
                                                .toList(),
                                          ),
                                        ],
                                      ),

                                      ///   Drop Down Row Closedd;
                                      // show Word Definition Example
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          _transBloc.translatedSMS == null
                                              ? 'Select langauge to make translation  🤔'
                                              : _transBloc.translatedSMS
                                                  .toString(),
                                          style: TextStyle(
                                              height: 1.5,
                                              fontSize: 15,
                                              color: Colors.grey[900],
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Text(
                                        _transBloc.translatedDefWrod
                                                    .toString() ==
                                                null
                                            ? ''
                                            : _transBloc.translatedDefWrod
                                                .toString(),
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),

                                      ShowWDE(_transBloc.translatedSentence),

                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Divider(
                                            endIndent: 100,
                                            color: Colors.white),
                                      ),
                                      Text(
                                        _transBloc.translatedExampleWrod
                                            .toString(),
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),

                                      ShowWDE(_transBloc.translatedExample),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ));
          },
        ),
      ),
    );
  }

  Widget ShowWDE(var variable) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        variable.toString() == null ? ' ' : variable.toString(),
        style: TextStyle(
            height: 1.5,
            fontSize: 17,
            color: Colors.grey[900],
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget checkSpell(String text) {
    if (filter.isProfane(text)) {
      print('this is bad wordssss');
      Fluttertoast.showToast(
          msg: "This is bad word",
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 20);
    } else {
      print('not bad');
    }
  }
}
