import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:bdk_flutter_quickstart/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  BdkFlutter bdkFlutter = BdkFlutter();
  String? displayText;
  String? address;
  String? balance;
  TextEditingController mnemonic = TextEditingController();
  TextEditingController recipientAddress = TextEditingController();
  TextEditingController amount = TextEditingController();

  generateMnemonicHandler() async {
    var res = await generateMnemonic(entropy: Entropy.ENTROPY256);
    setState(() {
      mnemonic.text = res;
      displayText = res;
    });
  }

  createOrRestoreWallet(
      String mnemonic, Network network, String? password) async {
    try {
      final res = await bdkFlutter.createWallet(mnemonic: mnemonic, network: network, password: password);
      setState(() {
        address = res.address;
        balance = res.balance.total.toString();
        displayText = "Wallet Created: ${address ?? "Error"}";
      });
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  getBalance() async {
    final res = await bdkFlutter.getBalance();
    setState(() {
      balance = res.total.toString();
      displayText = res.total.toString();
    });
  }

  getNewAddress() async {
    final res = await bdkFlutter.getNewAddress();
    setState(() {
      displayText = res;
      address = res;
    });
  }

  sendTx() async {
    final txid = await bdkFlutter.quickSend(
        recipient: recipientAddress.text.toString(),
        amount: int.parse(amount.text),
        feeRate: 1);
    setState(() {
      displayText = txid;
    });
  }
  syncWallet() async{
    bdkFlutter.syncWallet();
  }
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        /* Header */
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          leadingWidth: 80,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20, bottom: 10, top: 10),
              child: Image.asset("assets/bdk_logo.png"),
            )
          ],
          leading: const Icon(
            CupertinoIcons.bitcoin_circle_fill,
            color: Colors.orange,
            size: 40,
          ),
          title: Text("Bdk-Flutter Tutorial",
              style: Theme.of(context).textTheme.headline1),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
            child: Column(
              children: [
                /* Balance */
                StyledContainer(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Balance: ",
                            style: Theme.of(context).textTheme.headline2),
                        Text(" ${balance ?? "0"} Sats",
                            style: Theme.of(context).textTheme.bodyText1),
                      ],
                    )),
                /* Result */
                ResponseContainer(text: displayText ?? "No Response"),
                StyledContainer(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SubmitButton(
                              text: "Generate Mnemonic",
                              callback: () async {
                                await generateMnemonicHandler();
                              }),
                          TextFieldContainer(
                            child: TextFormField(
                                controller: mnemonic,
                                style: Theme.of(context).textTheme.bodyText1,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(8),
                                  hintText: "Enter your mnemonic here",
                                  hintStyle: TextStyle(
                                      color: Colors.black.withOpacity(.4),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10),
                                ),
                                keyboardType: TextInputType.multiline,
                                maxLines: 4),
                          ),

                          SubmitButton(
                            text: "Create Wallet",
                            callback: () async {
                              await createOrRestoreWallet(
                                  mnemonic.text, Network.TESTNET, "password");
                            },
                          ),
                          SubmitButton(
                            text: "Sync Wallet",
                            callback: ()  async{  await syncWallet(); },
                          ),
                          SubmitButton(
                            callback: () async {
                              await getBalance();
                            },
                            text: "Get Balance",
                          ),
                          SubmitButton(
                              callback: () async {
                                await getNewAddress();
                              },
                              text: "Get Address"),
                        ])),
                /* Send Transaction */
                StyledContainer(
                    child: Form(
                      key: _formKey,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextFieldContainer(
                              child: TextFormField(
                                controller: recipientAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your address';
                                  }
                                  return null;
                                },
                                style: Theme.of(context).textTheme.bodyText1,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                                  hintText: "Enter Address",
                                  hintStyle: TextStyle(
                                      color: Colors.black.withOpacity(.4),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10),
                                ),
                              ),
                            ),
                            TextFieldContainer(
                              child: TextFormField(
                                controller: amount,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the amount';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.number,
                                style: Theme.of(context).textTheme.bodyText1,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                                  hintText: "Enter Amount",
                                  hintStyle: TextStyle(
                                      color: Colors.black.withOpacity(.4),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10),
                                ),
                              ),
                            ),
                            SubmitButton(
                              text: "Send Bit",
                              callback: () async {
                                if (_formKey.currentState!.validate()) {
                                  await sendTx();
                                }
                              },
                            )
                          ]),
                    ))
              ],
            ),
          ),
        ));
  }
}
