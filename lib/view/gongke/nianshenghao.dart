import 'package:flutter/material.dart';

class NianShengHaoPage extends StatefulWidget {
  const NianShengHaoPage({super.key});

  @override
  State<NianShengHaoPage> createState() => _NianShengHaoPageState();
}

class _NianShengHaoPageState extends State<NianShengHaoPage> {
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
      appBar: AppBar(title: const Text('念诵佛菩萨圣号')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('念诵佛菩萨圣号'),
            if (_routeParams != null)
              Text('接收到的参数: ${_routeParams.toString()}'),
          ],
        ),
      ),
    );
  }
}
