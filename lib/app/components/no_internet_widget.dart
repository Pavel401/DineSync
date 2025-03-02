import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CustomNoInternetWidget extends StatelessWidget {
  CustomNoInternetWidget(
      {Key? key,
      this.textWidget = _textWidget,
      this.imageWidget,
      required this.color})
      : super(key: key);

  final Widget textWidget;
  final Widget? imageWidget;
  final Color color;

  static const Widget _textWidget = Text(
    "No Internet Connection",
    textAlign: TextAlign.center,
    style: TextStyle(
        fontSize: 18.0, color: Colors.black54, fontWeight: FontWeight.bold),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              imageWidget ??
                  Lottie.asset('assets/no_internet_connection.json',
                      package: 'flutter_empty_illustration',
                      width: 450,
                      fit: BoxFit.cover),
              SizedBox(height: 20, width: 20),
              textWidget,
            ],
          ),
        ));
  }
}
