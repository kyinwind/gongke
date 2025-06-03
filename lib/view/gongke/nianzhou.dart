import 'package:flutter/material.dart';

class NianzhouPage extends StatefulWidget {
  const NianzhouPage({super.key});

  @override
  State<NianzhouPage> createState() => _NianzhouPageState();
}

class _NianzhouPageState extends State<NianzhouPage> {
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
      appBar: AppBar(title: const Text('念咒')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('念咒'),
            if (_routeParams != null)
              Text('接收到的参数: ${_routeParams.toString()}'),
          ],
        ),
      ),
    );
  }
}
