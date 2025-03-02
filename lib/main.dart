import 'package:flutter/material.dart';
import 'modules/style/app_theme.dart';
import 'pages/main_container.dart';
import 'pages/splash/splash_screen.dart';
import 'dart:developer' as developer;

void main() {
  runApp(const MyApp());
}

// 添加导航器观察者以便调试导航问题
class NavigatorObserverWithLogging extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    developer.log('didPush: ${route.settings.name}, previousRoute: ${previousRoute?.settings.name}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    developer.log('didPop: ${route.settings.name}, previousRoute: ${previousRoute?.settings.name}');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    developer.log('didRemove: ${route.settings.name}, previousRoute: ${previousRoute?.settings.name}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    developer.log('didReplace: new - ${newRoute?.settings.name}, old - ${oldRoute?.settings.name}');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '卦喵',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [NavigatorObserverWithLogging()],
      navigatorKey: GlobalKey<NavigatorState>(), // 添加全局导航键
      theme: ThemeData(primarySwatch: Colors.pink, fontFamily: 'PingFang SC'),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const MainContainer(),
      },
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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
