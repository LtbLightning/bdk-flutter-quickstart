import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  final String text;
  final VoidCallback callback;

  const SubmitButton({super.key, required this.text, required this.callback});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        margin: const EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(5)),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        width: double.infinity,
        child: Center(
          child: Text(text, style: Theme.of(context).textTheme.labelLarge),
        ),
      ),
    );
  }
}

class TextFieldContainer extends StatelessWidget {
  final Widget child;

  const TextFieldContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2.5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 2, color: Theme.of(context).primaryColor)),
      child: child,
    );
  }
}

class StyledContainer extends StatelessWidget {
  final Widget child;

  const StyledContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 2,
            color: Theme.of(context).primaryColor,
          )),
      child: child,
    );
  }
}

class BalanceContainer extends StatelessWidget {
  final String text;

  const BalanceContainer({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        width: double.infinity,
        child: StyledContainer(
          child: SelectableText.rich(
            TextSpan(
              children: <TextSpan>[
                TextSpan(
                    text: "Balance: ",
                    style: Theme.of(context).textTheme.displayMedium),
                TextSpan(
                    text: text, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ));
  }
}

class ResponseContainer extends StatelessWidget {
  final String text;

  const ResponseContainer({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        width: double.infinity,
        child: StyledContainer(
          child: SelectableText.rich(
            TextSpan(
              children: <TextSpan>[
                TextSpan(
                    text: "Response: ",
                    style: Theme.of(context).textTheme.displayMedium),
                TextSpan(
                    text: text, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ));
  }
}

AppBar buildAppBar(BuildContext context) {
  return AppBar(
    leadingWidth: 80,
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 20, bottom: 10, top: 10),
        child: Image.asset("assets/bdk_logo.png"),
      )
    ],
    leading: Icon(
      CupertinoIcons.bitcoin_circle_fill,
      color: Theme.of(context).secondaryHeaderColor,
      size: 40,
    ),
    title: Text("Bdk-Flutter Tutorial",
        style: Theme.of(context).textTheme.displayLarge),
  );
}
