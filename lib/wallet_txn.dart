import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// void main() {
//   runApp(
//     MyApp(
//       items: List<ListItem>.generate(
//         1000,
//         (i) => i % 6 == 0
//             ? HeadingItem('Heading $i')
//             : MessageItem('Sender $i', 'Message body $i'),
//       ),
//     ),
//   );
// }

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyApp();
  // const MyApp();

}

class _MyApp extends State<MyApp> {
  final List<ListItem> items = [];
  Future<Map<String, double>> getTxn() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("token");
    var client = http.Client();
    try {
      var response = await client.post(
          Uri.parse("https://ethers-wallet.herokuapp.com/txns"),
          headers: {
            'Authorization': "Bearer " + token!,
            'Content-type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json'
          },
          body: {
            'type': "ALL",
          });
      var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      var uri = decodedResponse['status'] as List;
      uri.forEach((e) {
        items.add(MessageItem('from: ${e['from']} \n to: ${e['to']}',
            '${e['value']} ${e['tokenSymbol']}'));
      });
      setState(() {});
    } catch (e) {
      print(e);
    }
    Map<String, double> data = {};

    // print(data);
    return data;
  }

  @override
  Widget build(BuildContext context) {
    getTxn();
    const title = 'Mixed List';

    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(title),
        ),
        body: ListView.builder(
          // Let the ListView know how many items it needs to build.
          itemCount: items.length,
          // Provide a builder function. This is where the magic happens.
          // Convert each item into a widget based on the type of item it is.
          itemBuilder: (context, index) {
            final item = items[index];

            return ListTile(
              title: item.buildTitle(context),
              subtitle: item.buildSubtitle(context),
            );
          },
        ),
      ),
    );
  }
}

/// The base class for the different types of items the list can contain.
abstract class ListItem {
  /// The title line to show in a list item.
  Widget buildTitle(BuildContext context);

  /// The subtitle line, if any, to show in a list item.
  Widget buildSubtitle(BuildContext context);
}

/// A ListItem that contains data to display a heading.
class HeadingItem implements ListItem {
  final String heading;

  HeadingItem(this.heading);

  @override
  Widget buildTitle(BuildContext context) {
    return Text(
      heading,
      style: Theme.of(context).textTheme.headline5,
    );
  }

  @override
  Widget buildSubtitle(BuildContext context) => const SizedBox.shrink();
}

/// A ListItem that contains data to display a message.
class MessageItem implements ListItem {
  final String sender;
  final String body;

  MessageItem(this.sender, this.body);

  @override
  Widget buildTitle(BuildContext context) => Text(sender);

  @override
  Widget buildSubtitle(BuildContext context) => Text(body);
}
