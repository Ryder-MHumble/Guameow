import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;
import '../utils/app_utils.dart';

/// 权限处理服务
class PermissionService {
  /// 检查并请求相册权限
  static Future<bool> checkAndRequestPhotosPermission(BuildContext context) async {
    try {
      // 检查当前权限状态
      permission_handler.PermissionStatus status = await AppUtils.checkPhotosPermission();
      
      if (status.isGranted) {
        // 已经有权限
        return true;
      }
      
      if (status.isPermanentlyDenied) {
        // 权限被永久拒绝，需要引导用户去设置页面开启
        if (context.mounted) {
          showPermissionSettingsDialog(context);
        }
        return false;
      }
      
      // 请求权限
      status = await AppUtils.requestPhotosPermission();
      
      if (status.isGranted) {
        // 用户同意了权限
        return true;
      } else {
        // 用户拒绝了权限
        if (status.isPermanentlyDenied && context.mounted) {
          showPermissionSettingsDialog(context);
        }
        return false;
      }
    } catch (e) {
      debugPrint('权限检查出错: $e');
      return false;
    }
  }
  
  /// 检查并请求存储权限（Android特定）
  static Future<bool> checkAndRequestStoragePermission(BuildContext context) async {
    if (!Platform.isAndroid) return true;
    
    try {
      // 检查当前权限状态
      permission_handler.PermissionStatus status;
      
      // Android 13+ (SDK 33+) 使用细粒度媒体权限
      if (await permission_handler.Permission.photos.status.isGranted) {
        return true;
      }
      
      // 请求权限
      status = await permission_handler.Permission.photos.request();
      
      if (status.isGranted) {
        // 用户同意了权限
        return true;
      } else {
        // 用户拒绝了权限
        if (status.isPermanentlyDenied && context.mounted) {
          showPermissionSettingsDialog(context);
        }
        return false;
      }
    } catch (e) {
      debugPrint('权限检查出错: $e');
      return false;
    }
  }
  
  /// 显示权限设置对话框
  static void showPermissionSettingsDialog(BuildContext context) {
    AppUtils.showAlertDialog(
      context: context,
      title: '需要相册权限',
      content: '保存图片需要访问您的相册权限。请前往设置页面开启权限。',
      confirmText: '前往设置',
      cancelText: '取消',
      onConfirm: () async {
        // 使用 try-catch 包裹打开设置的操作
        try {
          await AppUtils.openAppSettings();
        } catch (e) {
          debugPrint('打开应用设置失败: $e');
          if (context.mounted) {
            AppUtils.showSnackBar(
              context,
              message: '无法打开设置，请手动前往系统设置修改权限',
              backgroundColor: Colors.red,
            );
          }
        }
      },
    );
  }
  
  /// 检查相册权限状态
  static Future<permission_handler.PermissionStatus> checkPhotosPermissionStatus() async {
    return await AppUtils.checkPhotosPermission();
  }
} 