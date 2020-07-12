import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:todo/data/enums/viewstate.dart';
import 'package:todo/data/models/task.dart';
import 'package:todo/data/providers/todo_provider.dart';
import 'package:todo/data/utils/constants.dart';
import 'package:todo/data/utils/utilities.dart';
import 'package:todo/ui/uihelpers/size_config.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;

import '../approutes.dart';
import 'login.dart';

class TodosList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TodosListState();
  }
}

class TodosListState extends State<TodosList> {
  TodoProvider _todoProvider;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  bool isFilterApplied = false;
  final _firebaseAuth = FirebaseAuth.instance;


  Future onSelectNotification(String payload) {}

  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var android = AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = IOSInitializationSettings();
    var initSettings = InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(initSettings,
        onSelectNotification: onSelectNotification);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _todoProvider = Provider.of<TodoProvider>(context);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return ChangeNotifierProvider.value(
        value: _todoProvider,
        child: Consumer<TodoProvider>(
            builder: (context, provider, child) => ModalProgressHUD(
                inAsyncCall: _todoProvider.state == ViewState.Busy,
                child: Scaffold(
                    appBar: AppBar(
                      title:
                          Text('Todos', style: TextStyle(color: Colors.white)),
                      actions: <Widget>[
                        IconButton(
                            icon: Icon(Icons.filter_list),
                            color: Colors.white,
                            onPressed: _filter)
                      ],
                    ),
                    body: Container(
                        height: double.infinity,
                        width: double.infinity,
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeHorizontal * 4),
                        color: Colors.white,
                        child: StreamBuilder<List<Task>>(
                            stream: isFilterApplied
                                ? _todoProvider.filteredTasks
                                : _todoProvider.tasks,
                            builder: (BuildContext context,
                                AsyncSnapshot<List<Task>> snapshot) {
                              if (snapshot.hasError)
                                return errorWidget('Error: ${snapshot.error}');
                              switch (snapshot.connectionState) {
                                // Display if still loading data
                                case ConnectionState.waiting:
                                  return errorWidget('Loading...');
                                default:
                                  return snapshot.data.length > 0
                                      ? ListView(
                                          shrinkWrap: true,
                                          children:
                                              snapshot.data.map((Task task) {
                                            return Dismissible(
                                              key: Key(task.taskId.toString()),
                                              confirmDismiss:
                                                  (direction) async {
                                                if (direction ==
                                                    DismissDirection
                                                        .endToStart) {
                                                  final bool res =
                                                      await showConfirmationDialog(
                                                          task);
                                                  return res;
                                                } else {
                                                  await _todoProvider
                                                      .deleteTodo(task);
                                                  flutterLocalNotificationsPlugin
                                                      .cancel(task.taskId);
                                                  _todoProvider
                                                      .setState(ViewState.Idle);
                                                  return false;
                                                }
                                              },
                                              background:
                                                  slideRightBackground(),
                                              secondaryBackground:
                                                  slideLeftBackground(),
                                              child: ListTile(
                                                  title: Text(
                                                    task.taskName,
                                                    style: TextStyle(
                                                        fontSize: SizeConfig
                                                                .blockSizeHorizontal *
                                                            4),
                                                  ),
                                                  subtitle: Text(
                                                    DateFormat(dateTimeFormat)
                                                        .format(task.dateTime),
                                                    style: TextStyle(
                                                        fontSize: SizeConfig
                                                                .blockSizeHorizontal *
                                                            3.2),
                                                  )),
                                            );
                                          }).toList(),
                                        )
                                      : errorWidget(
                                          'No tasks found. Please add some task to your todo. ');
                              }
                            })),
                    floatingActionButton: FloatingActionButton(
                        onPressed: () => Navigator.pushNamed(context, addTodo),
                        child: Icon(Icons.add))))));
  }

  Widget errorWidget(errorMsg) {
    return Center(
        child: Text(errorMsg,
            style: TextStyle(
                color: Colors.grey,
                fontSize: SizeConfig.blockSizeHorizontal * 3.5)));
  }

  Widget slideLeftBackground() {
    return Container(
        color: Colors.red,
        child: Center(
          child: Text(
            'Delete',
            style: TextStyle(
                color: Colors.white,
                fontSize: SizeConfig.blockSizeHorizontal * 3.6),
            textAlign: TextAlign.center,
          ),
        ));
  }

  Widget slideRightBackground() {
    return Container(
        color: Colors.green,
        child: Center(
          child: Text(
            'Done',
            style: TextStyle(
                color: Colors.white,
                fontSize: SizeConfig.blockSizeHorizontal * 3.6),
            textAlign: TextAlign.center,
          ),
        ));
  }

  Future<bool> showConfirmationDialog(task) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Delete',
              style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal * 4),
            ),
            content: Text(
              'Are you sure you want to delete this task?',
              style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal * 3.8),
            ),
            actions: <Widget>[
              FlatButton(
                  child: Text('Yes',
                      style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal * 3.6,
                          color: Colors.teal)),
                  onPressed: () async {
                    await _todoProvider.deleteTodo(task);
                    Navigator.of(context).pop(true);
                  }),
              FlatButton(
                  child: Text('No',
                      style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal * 3.6,
                          color: Colors.black)),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  })
            ],
          );
        });
  }

  Future<void> _filter() async {
    isFilterApplied = true;
    final List<DateTime> picked = await DateRagePicker.showDatePicker(
        context: context,
        initialFirstDate: new DateTime.now(),
        initialLastDate: new DateTime.now(),
        firstDate: new DateTime(2015),
        lastDate: new DateTime(2025));
    if (picked != null && picked.length == 2) {
      _todoProvider.dateTimeRange.clear();
      _todoProvider.dateTimeRange.addAll(picked);
      _todoProvider.setState(ViewState.Idle);
    } else {
      Utilities().showToast('Pick the date range you want to filter');
    }
  }
}
