import 'package:flutter/material.dart';
import 'package:links/main.dart';
import 'package:localpkg_flutter/localpkg.dart';

class AddDialogue extends StatefulWidget {
  const AddDialogue({super.key});

  @override
  State<AddDialogue> createState() => _AddDialogueState();
}

class _AddDialogueState extends State<AddDialogue> {
  final key = FormKey();
  final urlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("New CLink"),
      content: Form(
        key: key,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: urlController,
                validator: (value) {
                  if (value == null || value.isEmptyTrimmed) return "Must not be empty.";
                  if (!isHttpUrl(value)) return "Invalid URL.";
                  return null;
                },
                decoration: InputDecoration(
                  labelText: "URL",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}