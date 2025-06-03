import 'package:flutter/material.dart';

class DaZuoPage extends StatefulWidget {
  const DaZuoPage({super.key});

  @override
  State<DaZuoPage> createState() => _DaZuoPageState();
}

class _DaZuoPageState extends State<DaZuoPage> {
  Map<String, dynamic>? _routeParams;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get route arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      setState(() {
        _routeParams = args;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('打坐')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('打坐'),
            if (_routeParams != null)
              Text('接收到的参数: ${_routeParams.toString()}'),
          ],
        ),
      ),
    );
  }
}
