import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:bdk_flutter_quickstart/widgets/widgets.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Wallet wallet;
  late Blockchain blockchain;
  String? displayText;
  String? address;
  String? balance;
  TextEditingController mnemonic = TextEditingController();
  TextEditingController recipientAddress = TextEditingController();
  TextEditingController amount = TextEditingController();

  generateMnemonicHandler() async {
    var res = await Mnemonic.create(WordCount.Words12);
    setState(() {
      mnemonic.text = res.asString();
      displayText = res.asString();
    });
  }

  Future<List<String>> getDescriptors(String mnemonic) async {
    final descriptors = <String>[];
    try {
      for (var e in ["m/84'/1'/0'/0", "m/84'/1'/0'/1"]) {
        final mnemonicObj = await Mnemonic.fromString(mnemonic);
        final descriptorSecretKey = await DescriptorSecretKey.create(
          network: Network.Testnet,
          mnemonic: mnemonicObj,
        );
        final derivationPath = await DerivationPath.create(path: e);
        final derivedXprv = await descriptorSecretKey.derive(derivationPath);
        final derivedXprvStr = await derivedXprv.asString();
        descriptors.add("wpkh($derivedXprvStr)");
      }
      return descriptors;
    } on Exception catch (e) {
      setState(() {
        displayText = "Error : ${e.toString()}";
      });
      rethrow;
    }
  }

  createOrRestoreWallet(
      String mnemonic, Network network, String? password, String path) async {
    try {
      final descriptors = await getDescriptors(mnemonic);
      await blockchainInit();
      final res = await Wallet.create(
          descriptor: descriptors[0],
          changeDescriptor: descriptors[1],
          network: network,
          databaseConfig: const DatabaseConfig.memory());
      var addressInfo = await res.getAddress(addressIndex: AddressIndex.New);
      setState(() {
        address = addressInfo.address;
        wallet = res;
        displayText = "Wallet Created: $address";
      });
    } on Exception catch (e) {
      setState(() {
        displayText = "Error: ${e.toString()}";
      });
    }
  }

  getBalance() async {
    final balanceObj = await wallet.getBalance();
    final res = "Total Balance: ${balanceObj.total.toString()}";
    print(res);
    setState(() {
      balance = balanceObj.total.toString();
      displayText = res;
    });
  }

  getNewAddress() async {
    final res = await wallet.getAddress(addressIndex: AddressIndex.New);
    print(res.address);
    setState(() {
      displayText = res.address;
      address = res.address;
    });
  }

  sendTx(String addressStr, int amount) async {
    try {
      final txBuilder = TxBuilder();
      final address = await Address.create(address: addressStr);
      final script = await address.scriptPubKey();
      final psbt = await txBuilder
          .addRecipient(script, amount)
          .feeRate(1.0)
          .finish(wallet);
      final sbt = await wallet.sign(psbt);
      await blockchain.broadcast(sbt);
      setState(() {
        displayText = "Successfully broadcast $amount Sats to $addressStr";
      });
    } on Exception catch (e) {
      setState(() {
        displayText = "Error: ${e.toString()}";
      });
    }
  }

  blockchainInit() async {
    try {
      blockchain = await Blockchain.create(
          config: BlockchainConfig.electrum(
              config: ElectrumConfig(
                  stopGap: 10,
                  timeout: 5,
                  retry: 5,
                  url: "ssl://electrum.blockstream.info:60002")));
    } on Exception catch (e) {
      setState(() {
        displayText = "Error: ${e.toString()}";
      });
    }
  }

  syncWallet() async {
    wallet.sync(blockchain);
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        /* Header */
        appBar: buildAppBar(context),
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
                            keyboardType: TextInputType.multiline,
                            maxLines: 5,
                            decoration: const InputDecoration(
                                hintText: "Enter your mnemonic")),
                      ),
                      SubmitButton(
                        text: "Create Wallet",
                        callback: () async {
                          await createOrRestoreWallet(mnemonic.text,
                              Network.Testnet, "password", "m/84'/1'/0'");
                        },
                      ),
                      SubmitButton(
                        text: "Sync Wallet",
                        callback: () async {
                          await syncWallet();
                        },
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
                            decoration: const InputDecoration(
                              hintText: "Enter Address",
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
                            decoration: const InputDecoration(
                              hintText: "Enter Amount",
                            ),
                          ),
                        ),
                        SubmitButton(
                          text: "Send Bit",
                          callback: () async {
                            if (_formKey.currentState!.validate()) {
                              await sendTx(recipientAddress.text,
                                  int.parse(amount.text));
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
