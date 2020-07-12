import 'package:flutter/cupertino.dart';

class Task {
  int taskId;
  String docId;
  String taskName;
  DateTime dateTime;
  bool isDone = false;

  Task(
      {@required this.taskId,
      @required this.taskName,
      @required this.dateTime,
      @required this.isDone,this.docId});
}
