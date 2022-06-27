import 'dart:convert';
// import 'dart:ffi';

import 'package:etherwallet/components/copyButton/copy_button.dart';
import 'package:etherwallet/utils/eth_amount_formatter.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Balance extends StatefulWidget {
  const Balance({
    Key? key,
    required this.address,
    required this.ethBalance,
    required this.tokenBalance,
    required this.symbol,
    // required this.values,
  }) : super(key: key);

  final String? address;
  final BigInt? ethBalance;
  final BigInt? tokenBalance;
  final String? symbol;
  // final Future<Map<String, double>> values;

  @override
  State<Balance> createState() => _BalanceState();
}

class _BalanceState extends State<Balance> {
  Future<Map<String, double>> getBalance() async {
    final prefs = await SharedPreferences.getInstance();
    final String? test = prefs.getString('token');
    var tokens = null;
    var client = http.Client();
    var nis = 0.0;
    var jd = 0.0;
    var usd = 0.0;
    try {
      var response = await client.get(
          Uri.parse("https://ethers-wallet.herokuapp.com/balance"),
          headers: {'Authorization': "Bearer " + test!});
      var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      nis = decodedResponse['status']['nis'] / 10000 as double;
      jd = decodedResponse['status']['jd'] / 10000 as double;
      usd = decodedResponse['status']['usd'] / 10000 as double;
      // var value = json.decode(uri);
    } catch (e) {
      print(e);
    }
    Map<String, double> data = {};
    data['nis'] = nis;
    data['jd'] = jd;
    data['usd'] = usd;
    // print(data);
    return data;
  }

  var data = {"nis": 0.0, "usd": 0.0, "jd": 0.0};
  @override
  void initState() {
    // data = getBalance().then((value) {
    //   setState(() {
    //     data = value;
    //   });
    // });
    // print("hello");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    // print(values);
    final mediaQuery = MediaQuery.of(context);
    getBalance().then((value) {
      data = value;
      // print(data);
      setState(() {});
    });

    // print("test");
    // print(data);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(super.widget.address ?? ''),
          const SizedBox(height: 10),
          CopyButton(
            text: const Text('Copy address'),
            value: super.widget.address,
          ),
          if (super.widget.address != null &&
              (mediaQuery.orientation == Orientation.portrait || kIsWeb))
            QrImage(
              data: super.widget.address!,
              size: 150.0,
            ),
          Text(
            '${data['nis']} nis \n'
            '${data['usd']} usd \n'
            '${data['jd']} jd \n',
            style:
                Theme.of(context).textTheme.bodyText2?.apply(fontSizeDelta: 6),
          ),
          Text(
            '${EthAmountFormatter(super.widget.ethBalance).format()} ${super.widget.symbol}',
            style: Theme.of(context)
                .textTheme
                .bodyText2
                ?.apply(color: Colors.blueGrey),
          )
        ],
      ),
    );
  }
}
