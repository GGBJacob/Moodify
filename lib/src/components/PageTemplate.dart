import 'package:flutter/material.dart';

class PageTemplate extends StatelessWidget
{

  final List<Widget> children;

  const PageTemplate({Key? key, required this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top),
            ..._wrapWithExpanded(children),
          ],
        ),
      ),
    );
  }

  /// Funkcja owija dzieci w Expanded, jeśli mogą być rozciągnięte
  List<Widget> _wrapWithExpanded(List<Widget> children) {
    return children.map((child) {
      if (_canBeExpanded(child)) {
        return Expanded(child: child);
      }
      return child;
    }).toList();
  }

  /// Sprawdza, czy widget można owijać w Expanded
  bool _canBeExpanded(Widget widget) {
    return widget is! Spacer && widget is! SizedBox;
  }

  static Widget buildBottomSpacing(BuildContext context) {
    return SizedBox(height: MediaQuery.of(context).size.height * 0.03);
  }

}