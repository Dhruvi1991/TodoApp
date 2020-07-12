import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:todo/data/providers/todo_provider.dart';
import 'package:todo/ui/approutes.dart';
import 'package:todo/ui/screens/todos_list.dart';

import 'ui/screens/add_todo.dart';
import 'ui/screens/login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => TodoProvider(),
        child: MaterialApp(
            title: 'Todo',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.teal,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: _firebaseAuth.currentUser() != null ? TodosList() : Login(),
            routes: <String, WidgetBuilder>{
              addTodo: (BuildContext context) => AddTodo(),
              todoList: (BuildContext context) => TodosList(),
            }));
  }
}
