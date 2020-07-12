import 'package:flutter/material.dart';
import 'package:todo/data/enums/viewstate.dart';

class BaseProvider extends ChangeNotifier{
  ViewState _state = ViewState.Idle;

  ViewState get state => _state;

  void setState(ViewState viewState) {
    _state = viewState;
    notifyListeners();
  }

}