import 'package:AnySearch/Variables.dart';
import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

class ChangTransBloc extends ChangeNotifier {
  Variables _variables = new Variables();
  var translator = GoogleTranslator();

  String SMS = ' ',
      sentence = ' ',
      example = ' ',
      defWord = ' ',
      exDefWord = ' ';
  trans(String values, String dropdownValue) {
    translator.translate(values, from: 'en', to: dropdownValue).then((value) {
      SMS = value.toString();
      notifyListeners();
    });
  }

  transSentence(String values, String dropdownValue) {
    translator.translate(values, from: 'en', to: dropdownValue).then((value) {
      sentence = value.toString();
      notifyListeners();
    });
  }

  transExample(String values, String dropdownValue) {
    translator.translate(values, from: 'en', to: dropdownValue).then((value) {
      example = value.toString();
      notifyListeners();
    });
  }

  translatedDefinitionWrod(String dropdownValue) {
    translator
        .translate('Defination', from: 'en', to: dropdownValue)
        .then((value) {
      defWord = value.toString();
      notifyListeners();
    });
  }

  translatedExWrod(String dropdownValue) {
    translator
        .translate('Example', from: 'en', to: dropdownValue)
        .then((value) {
      exDefWord = value.toString();
      notifyListeners();
    });
  }

  String get translatedSMS => SMS;
  set translatedSMS(String updatedvalue) {
    SMS = updatedvalue;
    notifyListeners();
  }

  String get translatedSentence => sentence;
  set translatedSentence(String updatedvalue) {
    sentence = updatedvalue;
    notifyListeners();
  }

  String get translatedExample => example;
  set translatedExample(String updatedvalue) {
    example = updatedvalue;
    notifyListeners();
  }

  String get translatedDefWrod => defWord;
  set translatedDefWrod(String updatedvalue) {
    defWord = updatedvalue;
    notifyListeners();
  }

  String get translatedExampleWrod => exDefWord;
  set translatedExampleWrod(String updatedvalue) {
    exDefWord = updatedvalue;
    notifyListeners();
  }
}
