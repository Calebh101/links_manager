import 'package:calebh101_server_flutter/calebh101_server_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:links/main.dart';
import 'package:links/new.dart';
import 'package:localpkg_flutter/functions.dart';
import 'package:localpkg_flutter/localpkg.dart';
import 'package:url_launcher/url_launcher_string.dart';

typedef PathType = LinkGet200ResponseDataLogicPathsInnerConditionsInnerTypeEnum;

List<LinkOptionsGet200ResponseDataInner>? schema;

enum SortMode<T extends LinksGet200ResponseDataLinksInner> {
  mostUsed("Most Used"),
  leastUsed("Least Used"),
  lastUsed("Recently Used"),
  lastUsedReverse("Least Recently Used"),
  youngestToOldest("Newest First"),
  oldestToYoungest("Oldest First"),
  ;

  final String pretty;
  const SortMode(this.pretty);

  int sort(T a, T b) {
    return switch (this) {
      mostUsed => b.uses.compareTo(a.uses),
      leastUsed => a.uses.compareTo(b.uses),
      lastUsed => switch ((a.used, b.used)) {
        (null, null) => b.created.compareTo(a.created),
        (null, _) => 1,
        (_, null) => -1,
        (_, _) => b.used!.compareTo(a.used!),
      },
      lastUsedReverse => switch ((a.used, b.used)) {
        (null, null) => a.created.compareTo(b.created),
        (null, _) => 1,
        (_, null) => -1,
        (_, _) => a.used!.compareTo(b.used!),
      },
      youngestToOldest => b.created.compareTo(a.created),
      oldestToYoungest => a.created.compareTo(b.created),
    };
  }
}

/// Unsafe.
LinkOptionsGet200ResponseDataInner getFromId(String id) {
  return schema!.firstWhere((x) => x.id.value == id);
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  LinksGet200Response? data;
  String? error;
  SortMode sorting = SortMode.youngestToOldest;

  bool search = false;
  TextEditingController searchController = TextEditingController();
  FocusNode searchNode = FocusNode();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await client.request((DefaultApi api) => api.linkOptionsGet(), onData: (data) {
      schema = data.data;
      reload();
    }, onError: (e) {
      setState(() {
        error = e.message;
      });
    });
  }

  Future<void> reload() async {
    setState(() {
      data = null;
      error = null;
    });

    onNeedsLogin = (e) async {
      await context.navigator.push(MaterialPageRoute(builder: (context) => LoginPage(client: client)));
      reload();
    };

    final response = await request(() => DefaultApi(client).linksGet());
    data = response?.t;

    if (response?.f != null) {
      error = response?.f?.message;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final addButton = IconButton(onPressed: () async {
      await showDialog(context: context, builder: (context) => EditLinkPage(currentLinks: data?.data?.links ?? []));
      reload();
    }, icon: Icon(Icons.add));

    return Scaffold(
      appBar: AppBar(
        title: search ? TextFormField(
          focusNode: searchNode,
          controller: searchController,
          onChanged: (value) => setState(() {}),
        ) : Text("CLinks"),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {
            setState(() {
              search = !search;
              searchNode.requestFocus();
            });
          }, icon: search ? Icon(Icons.cancel_outlined) : Icon(Icons.search)),
          PopupMenuButton(itemBuilder: (context) => SortMode.values.map((x) {
            return PopupMenuItem(child: Text(x.pretty), onTap: () {
              setState(() {
                sorting = x;
              });
            });
          }).toList(), icon: Icon(Icons.sort)),
          addButton,
        ],
        leading: IconButton(onPressed: () => reload(), icon: Icon(Icons.refresh)),
      ),
      body: data != null && data!.data != null ? Builder(builder: (context) {
        final links = data!.data!.links.where((x) {
          if (!search || searchController.text.isEmptyTrimmed) return true;

          bool contains(List<String> a) {
            return a.any((y) => y.toLowerCase().contains(searchController.text.toLowerCase()));
          }

          return contains([
            x.id,
            x.logic.defaultUrl,
            ...x.logic.paths.map((x) => x.url),
          ]);
        }).sorted(sorting.sort);

        if (links.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Hey there!").fontSize(24),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "You haven't created any links yet! Click ",
                      ),
                      WidgetSpan(
                        child: addButton,
                      ),
                      TextSpan(
                        text: " to get started.",
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        }

        return ListView.builder(itemCount: links.length, itemBuilder: (context, i) => LinkWidget(link: links[i], currentLinks: links, reload: reload));
      }) : (error != null ? Center(child: Text("Error: $error")) : Center(child: CircularProgressIndicator())),
    );
  }
}

class LinkWidget extends StatefulWidget {
  final LinksGet200ResponseDataLinksInner link;
  final List<LinksGet200ResponseDataLinksInner> currentLinks;
  final VoidCallback reload;

  const LinkWidget({super.key, required this.link, required this.currentLinks, required this.reload});

  @override
  State<LinkWidget> createState() => _LinkWidgetState();
}

class _LinkWidgetState extends State<LinkWidget> {
  @override
  Widget build(BuildContext context) {
    final link = widget.link;
    final url = "https://links.calebh101.net/${link.id}";

    return ListTile(
      title: SelectableText.rich(
        TextSpan(
          text: url,
          style: TextStyle(
            color: Colors.blue,
          ),
          recognizer: TapGestureRecognizer()..onTap = () async {
            if (await canLaunchUrlString(url)) await launchUrlString(url);
          },
        ),
      ),
      subtitle: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: "${{"Created": link.created, "Last Used": ?link.used}.entries.map((x) => "${x.key}: ${DateFormat('MMMM d, yyyy, h:mm a', Localizations.localeOf(context).toLanguageTag()).format(x.value.toLocal())}").join("\n")}\nUses: ${link.uses}\n",
            ),
            TextSpan(
              text: link.logic.defaultUrl,
              style: TextStyle(
                color: Colors.blue,
              ),
              recognizer: TapGestureRecognizer()..onTap = () async {
                if (await canLaunchUrlString(link.logic.defaultUrl)) await launchUrlString(link.logic.defaultUrl);
              },
            ),
            TextSpan(
              text: link.logic.paths.isEmpty ? "" : "*",
            ),
          ],
        ),
      ),
      isThreeLine: true,
      trailing: IconButton(onPressed: () async {
        final page = EditLinkPage(currentLinks: widget.currentLinks, existing: ExistingLinkData(link: link, onDelete: (completer) async {
          await client.request((DefaultApi api) => api.linkDelete(accountSessionDeleteRequest: AccountSessionDeleteRequest(id: link.id)), onData: (data) {
            showSnackBar(context, data.message);
            completer.complete(true);
            widget.reload.call();
          }, onError: (e) {
            showSnackBar(context, e.message ?? "Unable to delete link. An unknown error occurred.");
            completer.complete(false);
          });
        }));

        await showDialog(context: context, builder: (context) => page);
        widget.reload();
      }, icon: Icon(Icons.edit)),
    );
  }
}