import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo/data/enums/viewstate.dart';
import 'package:todo/data/models/task.dart';
import 'package:todo/data/providers/base_provider.dart';

class TodoProvider extends BaseProvider {
  CollectionReference todoCollection = Firestore.instance.collection('todos');
  List<DateTime> dateTimeRange = List();

  Stream<List<Task>> get tasks => todoCollection
          .orderBy('dateTime', descending: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.documents
            .map((doc) => Task(
                taskId: doc['taskId'],
                taskName: doc['taskName'],
                dateTime: doc['dateTime'].toDate(),
                isDone: doc['isDone'],docId: doc.documentID))
            .toList();
      });

  Stream<List<Task>> get filteredTasks => todoCollection
          .orderBy('dateTime', descending: false)
          .where('dateTime', isLessThanOrEqualTo: dateTimeRange[1])
          .where('dateTime', isGreaterThanOrEqualTo: dateTimeRange[0])
          .snapshots()
          .map((snapshot) {
        return snapshot.documents
            .map((doc) => Task(
                taskId: doc['taskId'],
                taskName: doc['taskName'],
                dateTime: doc['dateTime'].toDate(),
                isDone: doc['isDone'],docId: doc.documentID))
            .toList();
      });

  Future<void> deleteTodo(Task task) async {
    todoCollection.document(task.docId).delete().then((value) => print('deleted'),
        onError: (error) {
      print('notdeletd');
    });
    setState(ViewState.Idle);
  }

  Future<void> addNewTask(Task task) async {
    setState(ViewState.Busy);
    await todoCollection.add({
      'taskId': task.taskId,
      'taskName': task.taskName,
      'dateTime': task.dateTime,
      'isDone': task.isDone
    });
    setState(ViewState.Idle);
  }
}
