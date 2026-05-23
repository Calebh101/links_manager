import 'package:calebh101_server_flutter/calebh101_server_flutter.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text("New CLink"),
        centerTitle: true,
        actions: [
          PopupMenuButton(itemBuilder: (context) => [
            PopupMenuItem(onTap: () {
              showSnackBar(context, "This feature is not available.");
            }, child: Text("Advanced Logic")),
          ]),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Form(
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
            10.vert(),
            ElevatedButton(
              onPressed: () async {
                if (!key.validate()) return;
                SnackBarManager.show(context, "Loading...");
                final api = DefaultApi(client);
                final result = await request(() async => api.linkPut(linkPutRequest: LinkPutRequest(id: null, data: LinkGet200ResponseDataLogic(defaultUrl: urlController.text))));

                if (result?.t?.data != null) {
                  final t = result!.t!;
                  final id = t.data!.id;
                  Logger.print("New", "ID: $id");

                  if (context.mounted) {
                    SnackBarManager.show(context, t.message);
                    context.navigator.pop();
                  }
                } else if (result?.f != null) {
                  final f = result!.f!;
                  Logger.print("New", "Request failed: $f");
                  if (context.mounted) SnackBarManager.show(context, f.message ?? "Link not created. Unknown error: ${f.e}");
                } else {
                  Logger.print("New", "Request failed");
                  if (context.mounted) SnackBarManager.show(context, "An unhandled error has occurred. We don't know if your link was created or not.");
                }
              },
              style: ElevatedButton.styleFrom(
                fixedSize: Size(150, 70),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: TextStyle(
                  fontSize: 20,
                ),
              ),
              child: Text("Create"),
            ),
          ],
        ),
      ),
    );
  }
}