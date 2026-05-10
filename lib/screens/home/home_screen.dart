import 'package:flutter/material.dart';
import '../../core/responsive_layout.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: Scaffold(
        appBar: AppBar(title: const Text('POS Home')),
        body: const Center(child: Text('Mobile POS Home')),
      ),
      tabletBody: Scaffold(
        appBar: AppBar(title: const Text('POS Home')),
        body: const Center(child: Text('Tablet POS Home')),
      ),
      desktopBody: Scaffold(
        appBar: AppBar(title: const Text('POS Home')),
        body: const Center(child: Text('Desktop POS Home')),
      ),
    );
  }
}
