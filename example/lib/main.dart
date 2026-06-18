import 'package:flutter/material.dart';
import 'package:simple_chart/simple_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: .spaceAround,
        children: [
          Container(
            padding: .all(12),
            margin: .symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: .1),
              borderRadius: .circular(20),
            ),
            child: LineChart(
              values: [4, 120, 12, 34, 43, 89, 21],
              labels: ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'],
              hLinesColor: Colors.grey.shade600,
              xLabelHeight: 20,
            ),
          ),
          Container(
            padding: .all(12),
            margin: .symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: .1),
              borderRadius: .circular(20),
            ),
            child: BarChart(
              values: [4, 120, 12, 34, 43, 89, 21],
              labels: ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'],
            ),
          ),
        ],
      ),
    );
  }
}
