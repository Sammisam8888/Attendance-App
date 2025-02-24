import 'package:flutter/material.dart';

class FingerprintWidget extends StatelessWidget {
  final Function onTap;
  final String buttonText;

  FingerprintWidget({required this.onTap, required this.buttonText});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onTap(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.fingerprint),
          SizedBox(width: 8),
          Text(buttonText),
        ],
      ),
    );
  }
}
