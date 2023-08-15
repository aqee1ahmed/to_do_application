import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:to_do_application/screens/widgets/task_details_dialog.dart';
import 'package:to_do_application/services/database/media/data_provider.dart';
import 'package:to_do_application/services/database/users/data_provider.dart';
import 'package:file_picker/file_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  TextEditingController titleController = TextEditingController();
  TextEditingController detailsController = TextEditingController();
  TextEditingController updateTitleController = TextEditingController();
  TextEditingController updateDetailsController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    detailsController.dispose();
    updateTitleController.dispose();
    updateDetailsController.dispose();
    super.dispose();
  }

  void clearTextFields() {
    setState(() {
      updateTitleController.clear();
      updateDetailsController.clear();
    });
  }

  String? _selectedFileName;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 25)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add, size: 30),
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (context) {
              return TaskDetailsDialog();
            },
          );
        },
      ),
      body: StreamBuilder(
        stream: taskProvider.fetchTask(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData) {
            final tasks = snapshot.data!.docs;

            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index].data();
                final documentId = tasks[index].id;
                return ListTile(
                  title: Text(
                    task['title'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      decoration: task['taskStatus']
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  subtitle: Text(
                    task['details'],
                    maxLines: 1,
                    style: TextStyle(
                      fontWeight: FontWeight.w100,
                      overflow: TextOverflow.ellipsis,
                      fontSize: 15,
                      decoration: task['taskStatus']
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        checkColor: Colors.white,
                        value: task['taskStatus'],
                        onChanged: (bool? value) {
                          taskProvider.updateTask(
                            documentId,
                            value ?? false,
                          );
                        },
                      ),
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.black54,
                        child: Icon(
                          task['taskStatus']
                              ? Icons.download_done_outlined
                              : Icons.pending_actions_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () async {
                            await showDialog(
                              context: context,
                              builder: (context) {
                                return BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 2,
                                    sigmaY: 2,
                                  ),
                                  child: AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    elevation: 5.0,
                                    title: Text('Update Task Details'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          controller: updateTitleController,
                                          decoration: InputDecoration(
                                            labelText: 'Update Title',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        TextField(
                                          maxLines: 2,
                                          controller: updateDetailsController,
                                          decoration: InputDecoration(
                                            labelText: 'Update Details',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () {
                                          String updateTitle =
                                              updateTitleController.text;
                                          String updateDetails =
                                              updateDetailsController.text;

                                          taskProvider.updateTaskDetails(
                                              documentId,
                                              updateTitle,
                                              updateDetails);
                                          clearTextFields();

                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: const Text(
                                                'Task Updated Successfully!!',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                              backgroundColor:
                                                  Colors.deepPurple[50],
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              showCloseIcon: true,
                                              closeIconColor: Colors.black,
                                            ),
                                          );
                                        },
                                        child: const Text('Update Task'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          clearTextFields();
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Cancel'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          taskProvider.deleteTask(documentId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Task Deleted Successfully!!',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700),
                              ),
                              backgroundColor: Colors.deepPurple[50],
                              behavior: SnackBarBehavior.floating,
                              showCloseIcon: true,
                              closeIconColor: Colors.black,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Text("No Data"),
            );
          }
        },
      ),
    );
  }
}
