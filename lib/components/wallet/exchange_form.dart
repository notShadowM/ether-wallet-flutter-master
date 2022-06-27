import 'dart:convert';

import 'package:etherwallet/components/form/paper_form.dart';
import 'package:etherwallet/components/form/paper_input.dart';
import 'package:etherwallet/components/form/paper_validation_summary.dart';
import 'package:etherwallet/context/transfer/wallet_transfer_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ExchangeForm extends HookWidget {
  const ExchangeForm({
    Key? key,
    required this.address,
    required this.onSubmit,
  }) : super(key: key);

  final String? address;
  final void Function(String address, String amount) onSubmit;

  @override
  Widget build(BuildContext context) {
    final toController = useTextEditingController(text: address);
    final amountController = useTextEditingController();
    final tokenTypeController = useTextEditingController();
    final transferStore = useWalletTransfer(context);

    useEffect(() {
      if (address != null)
        toController.value = TextEditingValue(text: address!);
    }, [address]);

    void sendData(String receiver, String type, String value) async {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString("token");
      var client = http.Client();
      try {
        var response = await client.post(
            Uri.parse("https://ethers-wallet.herokuapp.com/transfer"),
            headers: {
              'Authorization': "Bearer " + token!,
              'Content-type': 'application/x-www-form-urlencoded',
              'Accept': 'application/json'
            },
            body: {
              'receiver': receiver,
              'type': type,
              'value': value
            });
        var decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map;
        var uri = decodedResponse['token'] as String;
        print(uri);
        await prefs.setString('token', uri);
      } catch (e) {
        print(e);
      }
    }

    return Center(
      child: Container(
        margin: const EdgeInsets.all(25),
        child: SingleChildScrollView(
          child: PaperForm(
            padding: 30,
            actionButtons: <Widget>[
              ElevatedButton(
                child: const Text('Exchange now'),
                onPressed: () => sendData(
                    toController.value.text,
                    tokenTypeController.value.text,
                    amountController.value.text),
              )
            ],
            children: <Widget>[
              if (transferStore.state.errors != null)
                PaperValidationSummary(transferStore.state.errors!.toList()),
              PaperInput(
                controller: toController,
                labelText: 'To',
                hintText: 'Type the destination address',
              ),
              PaperInput(
                controller: amountController,
                labelText: 'Amount',
                hintText: 'And amount',
              ),
              PaperInput(
                controller: tokenTypeController,
                labelText: 'Type',
                hintText: 'The name',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
