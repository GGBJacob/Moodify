import 'package:flutter/material.dart';

class PageTemplate extends StatelessWidget
{

  final List<Widget> children;

  ///Adds a constant padding on top of the page and wraps all `children` in the `Expanded` widget
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

  /// Wraps all passed `children` with the `Expanded` widget if they are compatible.
  ///
  /// Widgets that cannot be wrapped in `Expanded` will remain unchanged.
  List<Widget> _wrapWithExpanded(List<Widget> children) {
    return children.map((child) {
      if (_canBeExpanded(child)) {
        return Expanded(child: child);
      }
      return child;
    }).toList();
  }

  bool _canBeExpanded(Widget widget) {
    return widget is! Spacer && widget is! SizedBox;
  }

  ///Builds a `SizedBox` with a height equal to 3% of device's height
  static Widget buildBottomSpacing(BuildContext context) {
    return SizedBox(height: MediaQuery.of(context).size.height * 0.03);
  }

  ///Returns a `Column` with the title surrounded by `SizedBox` of constant height on either side
  static Column buildPageTitle(String title)
  {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          title,
          style: TextStyle(fontSize: 45),
        ),
        const SizedBox(height: 20)
      ],
    );
  }
}