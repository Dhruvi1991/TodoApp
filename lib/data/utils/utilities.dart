import 'package:fluttertoast/fluttertoast.dart';

class Utilities {
  static final Utilities _instance = new Utilities._internal();

  factory Utilities() {
    return _instance;
  }

  Utilities._internal();

  showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 5);
  }
}