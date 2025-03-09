import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'modules/style/app_theme.dart';
import 'pages/main_container.dart';
import 'pages/splash/splash_screen.dart';
import 'dart:developer' as developer;

void main() {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 设置首选方向
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
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

// 全局导航键，用于在任何地方访问导航器
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // 添加应用生命周期观察者
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // 移除应用生命周期观察者
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 处理应用生命周期变化
    developer.log('App lifecycle state changed to: $state');
    
    // 当应用从后台恢复时，刷新当前页面
    if (state == AppLifecycleState.resumed) {
      // 可以在这里添加恢复应用状态的逻辑
      _checkPermissionsAfterResume();
    } else if (state == AppLifecycleState.paused) {
      // 应用进入后台
      developer.log('App went to background');
    }
  }
  
  // 应用从后台恢复时检查权限变化
  void _checkPermissionsAfterResume() async {
    try {
      // 这里可以添加检查权限变化的逻辑
      // 例如，如果用户从设置页面返回，可以检查之前被拒绝的权限是否已被授予
      developer.log('Checking permissions after app resume');
    } catch (e) {
      developer.log('Error checking permissions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '卦喵',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [NavigatorObserverWithLogging()],
      navigatorKey: navigatorKey, // 使用全局导航键
      theme: ThemeData(
        primarySwatch: Colors.pink, 
        fontFamily: 'PingFang SC',
        // 使用colorScheme替代已弃用的errorColor
        colorScheme: ColorScheme.light(
          primary: Colors.pink,
          error: Colors.red,
        ),
        // 添加页面过渡动画
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MainContainer(),
        '/splash': (context) => const SplashScreen(),
      },
      // 添加全局错误处理
      builder: (context, child) {
        // 添加错误边界
        return Material(
          type: MaterialType.transparency,
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}
