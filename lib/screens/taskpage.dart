import 'package:flutter/material.dart';
import 'package:todo_list/dbhelper.dart';
import 'package:todo_list/models/task.dart';
import 'package:todo_list/models/todo.dart';
import 'package:todo_list/widgets.dart';

class TaskPage extends StatefulWidget {
  final Task task;
  TaskPage({@required this.task});

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {

  String taskTitle = "";
  String taskDescription = "";
  DatabaseHelper dbHelper = DatabaseHelper();
  int taskId = 0;

  FocusNode titleFocus;
  FocusNode descriptionFocus;
  FocusNode todoFocus;

  bool contentVisible = false;

  @override
  void initState() {
    if (widget.task != null) {
      contentVisible = true;
      taskTitle = widget.task.title;
      taskDescription = widget.task.description;
      taskId = widget.task.id;
    }

    titleFocus = FocusNode();
    descriptionFocus = FocusNode();
    todoFocus = FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    titleFocus.dispose();
    descriptionFocus.dispose();
    todoFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 24.0,
                      bottom: 6.0,
                    ),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Image(
                              image: AssetImage(
                                'assets/images/back_arrow_icon.png'),
                            ),
                          ),
                        ),
                        Expanded(
                            child: TextField(
                              focusNode: titleFocus,
                              onSubmitted: (value) async {
                                if (value != "") {
                                  if (widget.task == null) {
                                    Task newTask = Task(title: value);
                                    taskId = await dbHelper.insertTask(newTask);
                                    setState(() {
                                      contentVisible = true;
                                      taskTitle = value;
                                    });
                                    print("New task Id: $taskId");
                                  }
                                  else {
                                    dbHelper.updateTaskTitle(taskId, value);
                                    print("Task updated");
                                  }
                                  descriptionFocus.requestFocus();
                                }
                              },
                              controller: TextEditingController()..text = taskTitle,
                              decoration: InputDecoration(
                                hintText: "Enter the task title",
                                hintStyle: TextStyle(
                                  fontWeight: FontWeight.normal,
                                ),
                                border: InputBorder.none,
                              ),
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF211551)
                              ),
                            ),
                        )
                      ],
                    ),
                  ),
                  Visibility(
                    visible: contentVisible,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: 12.0,
                      ),
                      child: TextField(
                        focusNode: descriptionFocus,
                        onSubmitted: (value) async {
                          if (value != "") {
                            if (taskId != 0) {
                               await dbHelper.updateTaskDescription(taskId, value);
                               taskDescription = value;
                            }
                          }
                          todoFocus.requestFocus();
                        },
                        controller: TextEditingController()..text = taskDescription,
                        decoration: InputDecoration(
                          hintText: "Enter description for the task here...",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 18.0,
                          )
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: contentVisible,
                    child: FutureBuilder(
                      initialData: [],
                      future: dbHelper.getTodo(taskId),
                      builder: (context, snapshot) {
                        return Expanded(
                          child: ListView.builder(
                            itemCount: snapshot.data.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () async {
                                  if (snapshot.data[index].isDone == 0) {
                                    await dbHelper.updateTodoDone(snapshot.data[index].id, 1);
                                  } else {
                                    await dbHelper.updateTodoDone(snapshot.data[index].id, 0);
                                  }
                                  setState(() {});
                                },
                                child: TodoWidget(
                                  text: snapshot.data[index].title,
                                  isDone: snapshot.data[index].isDone == 0 ? false : true,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Visibility(
                    visible: contentVisible,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 20.0,
                            height: 20.0,
                            margin: EdgeInsets.only(
                              right: 12.0,
                            ),
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(45.0),
                                border: Border.all(
                                    color: Color(0xFF86829D),
                                    width: 1.5
                                )
                            ),
                            child: Image(
                              image: AssetImage(
                                  'assets/images/check_icon.png'
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              focusNode: todoFocus,
                              controller: TextEditingController()..text = "",
                              onSubmitted: (value) async {
                                if (value != "") {
                                  if (taskId != 0) {
                                    DatabaseHelper dbHelper = DatabaseHelper();
                                    Todo newTodo = Todo(
                                      title: value,
                                      isDone: 0,
                                      taskId: taskId,
                                    );
                                    await dbHelper.insertTodo(newTodo);
                                    setState(() {});
                                    todoFocus.requestFocus();
                                  } else {
                                    print("Task doesn't exist");
                                  }
                                }
                              },
                              decoration: InputDecoration(
                                hintText: "Enter TODO item...",
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Visibility(
                visible: contentVisible,
                child: Positioned(
                  bottom: 24.0,
                  right: 24.0,
                  child: GestureDetector(
                    onTap: () async {
                      if (taskId != 0) {
                        await dbHelper.deleteTask(taskId);
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      width: 60.0,
                      height: 60.0,
                      decoration: BoxDecoration(
                          color: Color(0xFFFF4141),
                          borderRadius: BorderRadius.circular(45.0)
                      ),
                      child: Image(
                        image: AssetImage(
                            "assets/images/delete_icon.png"
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
