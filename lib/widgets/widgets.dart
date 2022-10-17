import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  final String text;
  final VoidCallback callback;
  const SubmitButton({Key? key, required this.text, required this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        margin: const EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
            color: Colors.blue.withOpacity(.8),
            borderRadius: BorderRadius.circular(5)),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        width: double.infinity,
        child: Center(
          child: Text(text,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13)),
        ),
      ),
    );
  }
}

class TextFieldContainer extends StatelessWidget {
  final Widget child;
  const TextFieldContainer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2.5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 2, color: Colors.blue.withOpacity(.8))),
      child: child,
    );
  }
}

class StyledContainer extends StatelessWidget {
  final Widget child;
  const StyledContainer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              width: 2, color: Colors.blue.withOpacity(.8).withOpacity(.6))),
      child: child,
    );
  }
}
class ResponseContainer extends StatelessWidget {
  final String text;
  const ResponseContainer({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Container(
        margin: const EdgeInsets.only(bottom: 5),
        padding:
        const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        decoration: BoxDecoration(
            color: Colors.blue.withOpacity(.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                width: 2, color: Colors.blue.withOpacity(.8))),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Response: ",
                style: Theme.of(context).textTheme.headline2),
            Text("\"$text\"",
                style: Theme.of(context).textTheme.bodyText1),
          ],
        ));
  }
}

