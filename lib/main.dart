import 'package:calebh101_server_flutter/calebh101_server_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:links/home.dart';

late ApiClient client;

bool isHttpUrl(String url) {
  final uri = Uri.tryParse(url);
  return uri != null && (uri.scheme == 'http' || uri.scheme == 'https') && uri.hasAuthority;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  client = Calebh101Client.setup(kDebugMode ? Calebh101Client.localBasePath() : Calebh101Client.publicBasePath());
  await setAuth(client);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CLinks',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Home(),
    );
  }
}