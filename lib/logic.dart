import 'package:calebh101_server_flutter/calebh101_server_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:links/home.dart';
import 'package:links/main.dart';
import 'package:localpkg_flutter/localpkg.dart';

class Path {
  final UniqueKey key = UniqueKey();
  List<LinkGet200ResponseDataLogicPathsInnerConditionsInner> conditions;

  FormKey? formKey;
  TextEditingController? url;

  Path({
    required this.conditions,
    this.formKey,
    this.url,
  });
}

class LogicChooseWidget extends StatefulWidget {
  final List<Path> paths;
  final void Function(int oldIndex, int newIndex) onReorder;

  const LogicChooseWidget({super.key, required this.paths, required this.onReorder});

  @override
  State<LogicChooseWidget> createState() => _LogicChooseWidgetState();
}

class _LogicChooseWidgetState extends State<LogicChooseWidget> {
  @override
  Widget build(BuildContext context) {
    final paths = widget.paths;

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: paths.length,
      itemBuilder: (context, i) {
        return LogicItem(
          path: paths[i],
          index: i,
          key: paths[i].key,
          onDelete: (i) => setState(() => paths.removeAt(i)),
        );
      },
      onReorder: widget.onReorder,
      buildDefaultDragHandles: false,
      footer: ListTile(
        title: Text("New Path"),
        onTap: () => setState(() => paths.add(Path(conditions: []))),
      ),
    );
  }
}

class LogicItem extends StatefulWidget {
  final int index;
  final Path path;
  final void Function(int i) onDelete;

  const LogicItem({super.key, required this.index, required this.path, required this.onDelete});

  @override
  State<LogicItem> createState() => _LogicItemState();
}

class _LogicItemState extends State<LogicItem> {
  late TextEditingController urlController;
  final key = FormKey();

  @override
  void initState() {
    widget.path.url ??= TextEditingController();
    urlController = widget.path.url!;

    urlController.text = widget.path.url?.text ?? "";
    widget.path.formKey = key;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final i = widget.index;
    final conditions = widget.path.conditions;
    final url = widget.path.url;

    return ListTile(
      leading: ReorderableDragStartListener(
        index: i,
        child: Icon(Icons.drag_handle),
      ),
      trailing: IconButton(onPressed: () async {
        if (await ConfirmationDialogue.show(context: context, title: "Are you sure?", description: "This will permanently remove this path for URL $url.") != true) return;
        widget.onDelete.call(i);
      }, icon: Icon(Icons.delete, color: Colors.red)),
      title: Form(
        key: key,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmptyTrimmed) return "Please provide a value.";
                  if (!isHttpUrl(value)) return "Invalid URL.";
                  if (conditions.isEmpty) return "You need to provide at least 1 condition.";

                  return null;
                },
                decoration: InputDecoration(
                  labelText: "Path #${i + 1} URL",
                ),
                controller: urlController,
              ),
            ],
          ),
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            ...conditions.mapIndexed((i, condition) {
              final value = getFromId(condition.type.value);
              final option = value.options.entries.firstWhere((x) => x.key == condition.value.value);

              return Chip(
                label: Text("${value.pretty}: ${option.value}"),
                deleteIcon: Icon(Icons.delete),
                onDeleted: () => setState(() {
                  conditions.removeAt(i);
                }),
              );
            }),
            PopupMenuButton(itemBuilder: (context) => [
              ...schema!.map((data) {
                return data.options.entries.map<PopupMenuEntry>((option) {
                  return PopupMenuItem(
                    onTap: () => setState(() {
                      conditions.add(LinkGet200ResponseDataLogicPathsInnerConditionsInner(type: PathType.values.firstWhere((x) => x.value == data.id.value), value: LinkGet200ResponseDataLogicPathsInnerConditionsInnerValueEnum.values.firstWhere((x) => x.value == option.key)));
                    }),
                    child: Text("${data.pretty}: ${option.value}"),
                  );
                });
              }).toList().flattenWith(PopupMenuDivider()),
            ], icon: Icon(Icons.add)),
          ],
        ),
      ),
    );
  }
}

extension JoinFlatten<T> on List<Iterable<T>> {
  List<T> flattenWith(T separator) {
    return asMap().entries.expand((entry) sync* {
      yield* entry.value;
      if (entry.key < length - 1) yield separator;
    }).toList();
  }
}