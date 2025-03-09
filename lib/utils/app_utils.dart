import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;

/// 应用工具类
class AppUtils {
  /// 检查应用是否在前台
  static bool isAppInForeground = true;
  
  /// 打开应用设置页面
  static Future<bool> openAppSettings() async {
    try {
      return await permission_handler.openAppSettings();
    } catch (e) {
      debugPrint('打开应用设置失败: $e');
      return false;
    }
  }
  
  /// 检查相册权限
  static Future<permission_handler.PermissionStatus> checkPhotosPermission() async {
    if (Platform.isIOS) {
      return await permission_handler.Permission.photos.status;
    } else if (Platform.isAndroid) {
      // Android 13+ (SDK 33+) 使用细粒度媒体权限
      return await permission_handler.Permission.photos.status;
    }
    return permission_handler.PermissionStatus.granted; // 默认返回已授权
  }
  
  /// 请求相册权限
  static Future<permission_handler.PermissionStatus> requestPhotosPermission() async {
    if (Platform.isIOS) {
      return await permission_handler.Permission.photos.request();
    } else if (Platform.isAndroid) {
      // Android 13+ (SDK 33+) 使用细粒度媒体权限
      return await permission_handler.Permission.photos.request();
    }
    return permission_handler.PermissionStatus.granted; // 默认返回已授权
  }
  
  /// 显示提示对话框
  static Future<void> showAlertDialog({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = '确定',
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            if (cancelText != null)
              TextButton(
                child: Text(cancelText),
                onPressed: () {
                  Navigator.of(context).pop();
                  onCancel?.call();
                },
              ),
            TextButton(
              child: Text(confirmText),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm?.call();
              },
            ),
          ],
        );
      },
    );
  }
  
  /// 显示底部提示
  static void showSnackBar(
    BuildContext context, {
    required String message,
    Color backgroundColor = Colors.black87,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
      ),
    );
  }
} 