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

  String _keyInterpolate(String key, String path) {
    if (key.contains("/*")) {
      final res = key.replaceAll("/*", "$path/*");
      return res;
    } else {
      final res = "$key$path/*";
      return res;
    }
  }

  String createDescriptor(String secretKey) {
    final res = _keyInterpolate("wpkh($secretKey)", "/0");
    print(res);
    return res;
  }

  String createChangeDescriptor(String secretKey) {
    final res = _keyInterpolate("wpkh($secretKey)", "/1");
    print(res);
    return res;
  }

  generateMnemonicHandler() async {
    var res = await generateMnemonic(wordCount: WordCount.Words12);
    setState(() {
      mnemonic.text = res;
      displayText = res;
    });
  }

  Future<String> createDescriptorSecret(String mnemonic, String path) async {
    try {
      final descriptorSecretKey = DescriptorSecretKey(
        network: Network.Testnet,
        mnemonic: mnemonic,
      );
      final derivationPath = await DerivationPath().create(path: path);
      final extendedXprv = await descriptorSecretKey.derive(derivationPath);
      final extendedXprvStr = await extendedXprv.asString();
      return extendedXprvStr;
    } on Exception {
      rethrow;
    }
  }

  createOrRestoreWallet(
      String mnemonic, Network network, String? password, String path) async {
    try {
      final extendedXprv = await createDescriptorSecret(mnemonic, path);
      final descriptor = createDescriptor(extendedXprv);
      final changeDescriptor = createChangeDescriptor(extendedXprv);
      await blockchainInit();
      final res = await Wallet().create(
          descriptor: descriptor,
          changeDescriptor: changeDescriptor,
          network: network,
          databaseConfig: const DatabaseConfig.memory());
      var addressInfo = await res.getAddress(addressIndex: AddressIndex.New);
      setState(() {
        address = addressInfo.address;
        wallet = res;
        displayText = "Wallet Created: ${address ?? "Error"}";
      });
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  getBalance() async {
    final res = await wallet.getBalance();
    setState(() {
      balance = res.total.toString();
      displayText = res.total.toString();
    });
  }

  getNewAddress() async {
    final res = await wallet.getAddress(addressIndex: AddressIndex.New);
    setState(() {
      displayText = res.address;
      address = res.address;
    });
  }

  sendTx(String addressStr, int amount) async {
    final txBuilder = TxBuilder();
    final address = await Address().create(address: addressStr);
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
  }

  blockchainInit() async {
    blockchain = await Blockchain().create(
        config: BlockchainConfig.electrum(
            config: ElectrumConfig(
                stopGap: 10,
                timeout: 5,
                retry: 5,
                url: "ssl://electrum.blockstream.info:60002")));
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
