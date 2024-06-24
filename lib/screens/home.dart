import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../widgets/widgets.dart';

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
    var res = await (await Mnemonic.create(WordCount.words12)).asString();

    setState(() {
      mnemonic.text = res;
      displayText = res;
    });
  }

  Future<List<Descriptor>> getDescriptors(String mnemonicStr) async {
    final descriptors = <Descriptor>[];
    try {
      for (var e in [KeychainKind.externalChain, KeychainKind.internalChain]) {
        final mnemonic = await Mnemonic.fromString(mnemonicStr);
        final descriptorSecretKey = await DescriptorSecretKey.create(
          network: Network.signet,
          mnemonic: mnemonic,
        );
        final descriptor = await Descriptor.newBip86(
            secretKey: descriptorSecretKey,
            network: Network.signet,
            keychain: e);
        descriptors.add(descriptor);
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
      setState(() {
        wallet = res;
      });
      var addressInfo = await getNewAddress();
      address = await addressInfo.address.asString();
      setState(() {
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
    if (kDebugMode) {
      print(res);
    }
    setState(() {
      balance = balanceObj.total.toString();
      displayText = res;
    });
  }

  Future<AddressInfo> getNewAddress() async {
    final res =
        await wallet.getAddress(addressIndex: const AddressIndex.increase());
    if (kDebugMode) {
      print(res.address);
    }
    address = await res.address.asString();
    setState(() {
      displayText = address;
    });
    return res;
  }

  sendTx(String addressStr, int amount) async {
    try {
      final txBuilder = TxBuilder();
      final address =
          await Address.fromString(s: addressStr, network: Network.signet);
      final script = await address.scriptPubkey();

      final psbt = await txBuilder
          .addRecipient(script, amount)
          .feeRate(1.0)
          .finish(wallet);
      final isFinalized = await wallet.sign(psbt: psbt.$1);
      if (isFinalized) {
        final tx = await psbt.$1.extractTx();
        final res = await blockchain.broadcast(transaction: tx);
        debugPrint(res);
      } else {
        debugPrint("psbt not finalized!");
      }

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
        config: const BlockchainConfig.esplora(
          config: EsploraConfig(
            baseUrl: 'https://mutinynet.ltbl.io/api',
            stopGap: 10,
          ),
        ),
      );
    } on Exception catch (e) {
      setState(() {
        displayText = "Error: ${e.toString()}";
      });
    }
  }

  syncWallet() async {
    wallet.sync(blockchain: blockchain);
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
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
                BalanceContainer(
                  text: "${balance ?? "0"} Sats",
                ),
                /* Result */
                ResponseContainer(
                  text: displayText ?? " ",
                ),
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
                            style: Theme.of(context).textTheme.bodyLarge,
                            keyboardType: TextInputType.multiline,
                            maxLines: 5,
                            decoration: const InputDecoration(
                                hintText: "Enter your mnemonic")),
                      ),
                      SubmitButton(
                        text: "Create Wallet",
                        callback: () async {
                          await createOrRestoreWallet(mnemonic.text,
                              Network.signet, "password", "m/84'/1'/0'");
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
                  key: formKey,
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
                            style: Theme.of(context).textTheme.bodyLarge,
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
                            style: Theme.of(context).textTheme.bodyLarge,
                            decoration: const InputDecoration(
                              hintText: "Enter Amount",
                            ),
                          ),
                        ),
                        SubmitButton(
                          text: "Send Bit",
                          callback: () async {
                            if (formKey.currentState!.validate()) {
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
