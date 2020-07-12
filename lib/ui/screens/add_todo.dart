import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:todo/data/enums/viewstate.dart';
import 'package:todo/data/models/task.dart';
import 'package:todo/data/providers/todo_provider.dart';
import 'package:todo/data/utils/constants.dart';
import 'package:todo/data/utils/utilities.dart';
import 'package:todo/data/utils/validator.dart';
import 'package:todo/ui/uihelpers/size_config.dart';

class AddTodo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddTodoState();
  }
}

class AddTodoState extends State<AddTodo> {
  TodoProvider _todoProvider;
  TextEditingController _nameController = TextEditingController();
  DateTime dateTime;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _todoProvider = Provider.of<TodoProvider>(context);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: _todoProvider,
        child: Consumer<TodoProvider>(
            builder: (context, provider, child) => ModalProgressHUD(
                inAsyncCall: provider.state == ViewState.Busy,
                child: Scaffold(
                    appBar: AppBar(
                      title: Text('Add Task',
                          style: TextStyle(color: Colors.white)),
                      actions: <Widget>[
                        IconButton(
                            icon: Icon(Icons.done),
                            color: Colors.white,
                            onPressed: _addTask)
                      ],
                    ),
                    body: Container(
                        height: double.infinity,
                        width: double.infinity,
                        child: Padding(
                          padding: EdgeInsets.all(
                              SizeConfig.blockSizeHorizontal * 4),
                          // Align widgets in a vertical column
                          child: Column(
                            // Passing multiple widgets as children to Column
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                  padding: EdgeInsets.only(
                                      bottom:
                                          SizeConfig.blockSizeHorizontal * 4),
                                  child: TextField(
                                      autofocus: true,
                                      controller: _nameController,
                                      decoration: InputDecoration(
                                          labelText:
                                              'Enter name for your task'))),
                              Padding(
                                padding: EdgeInsets.only(
                                    bottom: SizeConfig.blockSizeHorizontal * 4),
                                child: dateTime == null
                                    ? RaisedButton(
                                        // Calling the callback with the supplied email and password
                                        onPressed: () async {
                                          DatePicker.showDateTimePicker(context,
                                              minTime: DateTime.now(),
                                              currentTime: DateTime.now(),
                                              onConfirm: (date) async {
                                            dateTime = date;
                                            _todoProvider
                                                .setState(ViewState.Idle);
                                          }, onCancel: () {
                                            dateTime = null;
                                          });
                                        },
                                        child: Text(
                                          'Select Date',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        // Setting the primary color on the button
                                        color: Colors.teal,
                                      )
                                    : Padding(
                                        padding: EdgeInsets.only(
                                            bottom:
                                                SizeConfig.blockSizeHorizontal *
                                                    4),
                                        child: Text(
                                          dateTime != null
                                              ? DateFormat(dateTimeFormat).format(dateTime)
                                              : 'Select Date',
                                          textAlign: TextAlign.start,
                                        )),
                              )
                            ],
                          ),
                        ))))));
  }

  _addTask() async {
    FocusScope.of(context).requestFocus(new FocusNode());
    if (Validator.isEmpty(_nameController.text)) {
      Utilities().showToast('Please enter the task name.');
    } else if (dateTime==null) {
      Utilities().showToast('Please select atleast one date. ');
    } else {
      Task task = Task(
          taskId: UniqueKey().hashCode,
          taskName: _nameController.text,
          dateTime: dateTime,
          isDone: false);
      await _todoProvider.addNewTask(task);
      await scheduleNotification(task);
      Navigator.pop(context);
    }
  }

  scheduleNotification(Task task) async {
    var android = AndroidNotificationDetails(
        'channel id', 'channel name', 'channel description');
    var iOS = IOSNotificationDetails();
    var platform = NotificationDetails(android, iOS);
    await FlutterLocalNotificationsPlugin().schedule(task.taskId,
        task.taskName, 'Your ${task.taskName} is yet to be completed. ', dateTime, platform);
  }
}
