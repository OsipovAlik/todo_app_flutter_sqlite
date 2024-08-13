import 'package:flutter/material.dart';
import 'package:todo_sqlite/models/task.dart';
import 'package:todo_sqlite/services/database_services.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseServices _databaseServices = DatabaseServices.instance;
  String? _inputValue = null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('ToDo'),
      ),
      body: _tasksList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(context: context, builder: (_) => _addTaskDialog());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _addTaskDialog() {
    return AlertDialog(
      title: const Text(
        'Add Task',
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            onChanged: (value) {
              setState(() {
                _inputValue = value;
              });
            },
            decoration: const InputDecoration(
                border: OutlineInputBorder(), hintText: 'Add Task...'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MaterialButton(
                color: Colors.green,
                child: const Text(
                  'Add',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                onPressed: () {
                  if (_inputValue == null || _inputValue == '') {
                    return;
                  }
                  _databaseServices.addTask(_inputValue!);

                  setState(() {
                    _inputValue = null;
                  });

                  Navigator.pop(context);
                }),
          )
        ],
      ),
    );
  }

  Widget _tasksList() {
    return FutureBuilder(
        future: _databaseServices.getTasks(),
        builder: (context, snapshot) {
          return ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                Task task = snapshot.data![index];
                return Container(
                  margin: const EdgeInsets.all(10),
                  color: task.status == 1 ? Colors.blueGrey : Colors.blueAccent,
                  height: 50,
                  child: ListTile(
                    leading: MaterialButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (_) => _alertDialog(task));
                      },
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      task.content,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                    trailing: Checkbox(
                        value: task.status == 1,
                        onChanged: (value) {
                          _databaseServices.updateTaskStatus(
                              task.id, value == true ? 1 : 0);
                          setState(() {});
                        }),
                  ),
                );
              });
        });
  }

  Widget _alertDialog(task) {
    return AlertDialog(
      title: const Text(
        'Delete Task',
        textAlign: TextAlign.center,
      ),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MaterialButton(
              color: Colors.red,
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'No',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
          MaterialButton(
            color: Colors.green,
            onPressed: () {
              _databaseServices.deleteTask(task.id);
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Yes',
                style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
