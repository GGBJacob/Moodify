import 'package:flutter/material.dart';

class CustomBlock extends StatelessWidget {
  final Widget child;

  const CustomBlock({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
        widthFactor: 0.9,
        child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color:  Colors.black12,
                  blurRadius: 5.0,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            padding: EdgeInsets.all(15.0),
            child:child
        )
    );
  }
}
