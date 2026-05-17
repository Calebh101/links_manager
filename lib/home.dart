import 'package:calebh101_server_flutter/calebh101_server_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:links/main.dart';
import 'package:links/new.dart';
import 'package:localpkg_flutter/functions.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  LinksGet200Response? data;
  String? error;

  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() async {
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Clinks"),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () async {
            await showDialog(context: context, builder: (context) => AddDialogue());
            reload();
          }, icon: Icon(Icons.add)),
        ],
      ),
      body: data != null && data!.data != null ? Builder(builder: (context) {
        final links = data!.data!.links;

        return ListView.builder(itemCount: links.length, itemBuilder: (context, i) => LinkWidget(link: links[i]));
      }) : (error != null ? Center(child: Text("Error: $error")) : Center(child: CircularProgressIndicator())),
    );
  }
}

class LinkWidget extends StatefulWidget {
  final LinksGet200ResponseDataLinksInner link;
  const LinkWidget({super.key, required this.link});

  @override
  State<LinkWidget> createState() => _LinkWidgetState();
}

class _LinkWidgetState extends State<LinkWidget> {
  @override
  Widget build(BuildContext context) {
    final link = widget.link;

    return ListTile(
      title: Text(link.id),
      subtitle: Text(DateFormat('MMMM d, yyyy, h:mm a', Localizations.localeOf(context).toLanguageTag()).format(link.created)),
    );
  }
}