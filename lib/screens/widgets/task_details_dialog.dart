import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:to_do_application/services/database/media/data_provider.dart';
import 'package:to_do_application/services/database/users/data_provider.dart';

class TaskDetailsDialog extends StatefulWidget {
  const TaskDetailsDialog({super.key});

  @override
  TaskDetailsDialogState createState() => TaskDetailsDialogState();
}

class TaskDetailsDialogState extends State<TaskDetailsDialog> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  FilePickerResult? result;
  bool uploading = false;
  String?
      _selectedFileName; // Local variable to store the name of the selected file

  void clearTextFields() {
    setState(() {
      titleController.clear();
      detailsController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Task Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              maxLines: 2,
              controller: detailsController,
              decoration: InputDecoration(
                labelText: 'Details',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () async {
                result = await FilePicker.platform.pickFiles();

                if (result != null) {
                  setState(() {
                    _selectedFileName = result?.files.single.name;
                  });
                } else {
                  // User canceled the picker
                }
              },
              child: const Text("Upload Image"),
            ),
            Text(
              _selectedFileName ?? '',
              overflow: TextOverflow.fade,
            ), // Show the selected file name
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: uploading
                ? null
                : () async {
                    setState(() {
                      uploading = true;
                    });

                    String title = titleController.text;
                    String details = detailsController.text;
                    bool taskStatus = false;
                    if (result != null) {
                      final File file = File(result!.files.single.path!);
                      final int id =
                          DateTime.now().microsecondsSinceEpoch.toInt();
                      await MediaProvider.uploadImage(
                        file,
                        id,
                      );

                      taskProvider.createTask(
                        title,
                        details,
                        taskStatus,
                        id,
                      );
                    } else {
                      taskProvider.createTask(
                        title,
                        details,
                        taskStatus,
                        null,
                      );
                    }
                    clearTextFields();

                    setState(() {
                      uploading =
                          false; // Set the flag to false when uploading is complete
                    });

                    Navigator.of(context).pop();
                  },
            child: uploading
                ? SizedBox(
                    width: 24, // Adjust the width to your desired size
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.deepPurpleAccent[600],
                      strokeWidth: 4,
                    )) // Show the circular progress indicator while uploading
                : Text('Add Task'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
