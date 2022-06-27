import 'dart:convert';

import 'package:etherwallet/components/wallet/balance.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/dialog/alert.dart';
import 'components/menu/main_menu.dart';
import 'components/wallet/change_network.dart';
import 'context/wallet/wallet_provider.dart';
import 'package:http/http.dart' as http;

class WalletMainPage extends HookWidget {
  const WalletMainPage(this.title, {Key? key}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    final store = useWallet(context);
    final address = store.state.address;
    final network = store.state.network;

    useEffect(() {
      store.initialise();
    }, []);

    useEffect(
      () => store.listenTransfers(address, network),
      [address, network],
    );

    // Future<Map<String, double>> getBalance() async {
    //   final prefs = await SharedPreferences.getInstance();
    //   final String? test = prefs.getString('token');
    //   var tokens = null;
    //   var client = http.Client();
    //   var nis = 0.0;
    //   var jd = 0.0;
    //   var usd = 0.0;
    //   try {
    //     var response = await client.get(
    //         Uri.parse("https://ethers-wallet.herokuapp.com/balance"),
    //         headers: {'Authorization': "Bearer " + test!});
    //     var decodedResponse =
    //         jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    //     nis = decodedResponse['status']['nis'] / 10000 as double;
    //     jd = decodedResponse['status']['jd'] / 10000 as double;
    //     usd = decodedResponse['status']['usd'] / 10000 as double;
    //     // var value = json.decode(uri);
    //     // print(usd);
    //   } catch (e) {
    //     print(e);
    //   }
    //   Map<String, double> data = {};
    //   data['nis'] = nis;
    //   data['jd'] = jd;
    //   data['usd'] = usd;
    //   return data;
    // }

    return Scaffold(
      drawer: MainMenu(
        network: network,
        address: address,
        onReset: () => Alert(
            title: 'Warning',
            text:
                'Without your seed phrase or private key you cannot restore your wallet balance',
            actions: [
              TextButton(
                child: const Text('cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text('reset'),
                onPressed: () async {
                  await store.resetWallet();
                  Navigator.popAndPushNamed(context, '/');
                },
              )
            ]).show(context),
        onRevealKey: () => Alert(
            title: 'Private key',
            text:
                'WARNING: In production environment the private key should be protected with password.\r\n\r\n${store.getPrivateKey() ?? "-"}',
            actions: [
              TextButton(
                child: const Text('close'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text('copy and close'),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: store.getPrivateKey()));
                  Navigator.of(context).pop();
                },
              ),
            ]).show(context),
      ),
      appBar: AppBar(
        title: Text(title),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: !store.state.loading
                  ? () async {
                      await store.refreshBalance();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Balance updated'),
                        duration: Duration(milliseconds: 800),
                      ));
                    }
                  : null,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              Navigator.of(context)
                  .pushNamed('/transfer', arguments: store.state.network);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ChangeNetwork(
              onChange: store.changeNetwork,
              currentValue: store.state.network,
              loading: store.state.loading,
            ),
            const SizedBox(height: 10),
            Balance(
              address: store.state.address,
              ethBalance: store.state.ethBalance,
              tokenBalance: store.state.tokenBalance,
              symbol: network.config.symbol,
              // values: getBalance(),
            )
          ],
        ),
      ),
    );
  }
}
