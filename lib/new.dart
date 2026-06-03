import 'dart:async';

import 'package:calebh101_server_flutter/calebh101_server_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:links/logic.dart';
import 'package:links/main.dart';
import 'package:localpkg_flutter/localpkg.dart';

class ExistingLinkData {
  final LinksGet200ResponseDataLinksInner link;
  final FutureOr<void> Function(Completer<bool> completer) onDelete;

  const ExistingLinkData({required this.link, required this.onDelete});
}

class EditLinkPage extends StatefulWidget {
  final ExistingLinkData? existing;
  final List<LinksGet200ResponseDataLinksInner> currentLinks;

  const EditLinkPage({super.key, required this.currentLinks, this.existing});

  @override
  State<EditLinkPage> createState() => _EditLinkPageState();
}

class _EditLinkPageState extends State<EditLinkPage> {
  final key = FormKey();
  final urlController = TextEditingController();

  bool advancedLogic = false;
  List<Path> paths = [];

  bool get editing => widget.existing != null;
  bool get hasLogic => advancedLogic && paths.isNotEmpty;

  bool validate() {
    bool result = true;

    for (final x in paths) {
      if (x.formKey?.validate() != true) result = false;
    }

    if (key.validate() == false) result = false;
    return result;
  }

  @override
  void initState() {
    if (editing) {
      final existing = widget.existing!.link;

      urlController.text = existing.logic.defaultUrl;
      paths = existing.logic.paths.map((x) => Path(conditions: x.conditions, url: TextEditingController()..text = x.url)).toList();
      advancedLogic = paths.isNotEmpty;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? "Editing CLink ${widget.existing!.link.id}" : "New CLink"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
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

                          final exists = hasLogic ? null : widget.currentLinks.firstWhereOrNull((x) => x.logic.paths.isEmpty && x.id != widget.existing?.link.id && x.logic.defaultUrl == value);
                          if (exists != null) return "You already have a link with this URL (${exists.id}).";
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
              if (advancedLogic == false) TextButton(onPressed: () => setState(() {
                advancedLogic = true;
              }), child: Text("Show Advanced Logic")) else LogicChooseWidget(paths: paths, onReorder: (oldIndex, newIndex) {
                if (newIndex > oldIndex) newIndex--;
                final item = paths.removeAt(oldIndex);
                paths.insert(newIndex, item);
                setState(() {});
              }),
              10.vert(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (!validate()) return;
                      SnackBarManager.show(context, "Loading...");

                      final existing = widget.existing?.link;
                      final api = DefaultApi(client);
                      final result = await request(() async => api.linkPut(linkPutRequest: LinkPutRequest(id: existing?.id, data: LinkGet200ResponseDataLogic(defaultUrl: urlController.text, paths: paths.map((x) {
                        return LinkGet200ResponseDataLogicPathsInner(url: x.url!.text, conditions: x.conditions);
                      }).toList()))));

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
                    child: Text(editing ? "Save" : "Create"),
                  ),
                  if (widget.existing != null)
                  ElevatedButton(
                    onPressed: () async {
                      final link = widget.existing!.link;
                      if (await ConfirmationDialogue.show(context: context, title: "Are you sure?", description: "This will permanently delete link ${link.id} (${link.logic.defaultUrl}, ${link.logic.paths.isEmpty ? "no logic" : "has logic"}). This cannot be undone.") != true) return;

                      final completer = Completer<bool>();
                      await widget.existing!.onDelete.call(completer);
                      if (await completer.future && context.mounted) context.navigator.pop();
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(150, 70),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: TextStyle(
                        fontSize: 20,
                        color: Colors.red,
                      ),
                    ),
                    child: Text("Delete"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}