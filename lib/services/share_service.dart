import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'permission_service.dart';
import '../utils/app_utils.dart';

class ShareService {
  // 将Widget转换为图片
  static Future<Uint8List?> captureWidget(GlobalKey key) async {
    try {
      final RenderRepaintBoundary boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        return byteData.buffer.asUint8List();
      }
      return null;
    } catch (e) {
      debugPrint('截图出错: $e');
      return null;
    }
  }

  // 保存图片到临时目录并返回文件路径
  static Future<String?> saveImageToTemp(Uint8List imageBytes, {String fileName = 'fortune_report.png'}) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(imageBytes);
      return file.path;
    } catch (e) {
      debugPrint('保存图片到临时目录出错: $e');
      return null;
    }
  }

  // 保存图片到相册
  static Future<bool> saveImageToGallery(Uint8List imageBytes, {BuildContext? context}) async {
    try {
      // 如果提供了context，使用PermissionService进行权限检查
      if (context != null) {
        bool hasPermission = await PermissionService.checkAndRequestPhotosPermission(context);
        if (!hasPermission) {
          return false;
        }
      } else {
        // 兼容旧代码，直接请求权限
        if (Platform.isAndroid || Platform.isIOS) {
          final status = await permission_handler.Permission.photos.request();
          if (!status.isGranted) {
            return false;
          }
        }
      }
      
      try {
        final result = await ImageGallerySaver.saveImage(
          imageBytes, 
          quality: 100,
          name: "卦喵命理详解_${DateTime.now().millisecondsSinceEpoch}"
        );
        
        debugPrint('保存结果: $result');
        return result['isSuccess'] ?? false;
      } catch (e) {
        debugPrint('保存图片到相册出错: $e');
        return false;
      }
    } catch (e) {
      debugPrint('权限处理出错: $e');
      return false;
    }
  }

  // 分享图片到社交媒体
  static Future<void> shareImage(Uint8List imageBytes, {String text = '卦喵命理详解'}) async {
    try {
      final imagePath = await saveImageToTemp(imageBytes);
      if (imagePath != null) {
        await Share.shareXFiles(
          [XFile(imagePath)],
          text: text,
          subject: '卦喵命理详解分享',
        );
      }
    } catch (e) {
      debugPrint('分享图片出错: $e');
    }
  }

  // 显示分享菜单
  static Future<void> showShareOptions(
    BuildContext context, 
    GlobalKey widgetKey,
    {String shareText = '来自卦喵的命理详解分享'}
  ) async {
    // 先检查权限状态，如果已经被永久拒绝，直接显示设置对话框
    if (Platform.isIOS || Platform.isAndroid) {
      final status = await PermissionService.checkPhotosPermissionStatus();
      if (status.isPermanentlyDenied) {
        if (context.mounted) {
          PermissionService.showPermissionSettingsDialog(context);
          return;
        }
      }
    }
    
    final imageBytes = await captureWidget(widgetKey);
    
    if (imageBytes == null) {
      if (context.mounted) {
        AppUtils.showSnackBar(
          context,
          message: '生成分享图片失败，请重试',
          backgroundColor: Colors.red,
        );
      }
      return;
    }

    // 创建预览图片
    final previewImage = Image.memory(
      imageBytes,
      height: 200,
      fit: BoxFit.contain,
    );

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            '分享命理详解',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: previewImage,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildShareOption(
                  context,
                  icon: Icons.save_alt,
                  label: '保存到相册',
                  onTap: () async {
                    // 先关闭底部菜单
                    Navigator.pop(context);
                    
                    // 检查权限并保存
                    await _saveImageWithPermissionCheck(context, imageBytes, isLongImage: false);
                  },
                ),
                _buildShareOption(
                  context,
                  icon: Icons.share,
                  label: '分享到社交',
                  onTap: () {
                    Navigator.pop(context);
                    shareImage(imageBytes, text: shareText);
                  },
                ),
                _buildShareOption(
                  context,
                  icon: Icons.copy,
                  label: '生成长图',
                  onTap: () async {
                    // 先关闭底部菜单
                    Navigator.pop(context);
                    
                    // 检查权限并保存
                    await _saveImageWithPermissionCheck(context, imageBytes, isLongImage: true);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
  
  // 检查权限并保存图片的辅助方法
  static Future<void> _saveImageWithPermissionCheck(
    BuildContext context, 
    Uint8List imageBytes, 
    {bool isLongImage = false}
  ) async {
    // 显示保存中提示
    if (context.mounted) {
      AppUtils.showSnackBar(
        context,
        message: isLongImage ? '长图生成中...' : '正在保存到相册...',
      );
    }
    
    // 检查权限
    bool hasPermission = await PermissionService.checkAndRequestPhotosPermission(context);
    
    if (!hasPermission) {
      if (context.mounted) {
        AppUtils.showSnackBar(
          context,
          message: '无法保存图片，请授予相册权限',
          backgroundColor: Colors.red,
        );
      }
      return;
    }
    
    // 保存图片
    final success = await saveImageToGallery(imageBytes);
    
    if (context.mounted) {
      AppUtils.showSnackBar(
        context,
        message: success 
          ? (isLongImage ? '长图已保存到相册' : '已保存到相册') 
          : '保存失败，请重试',
        backgroundColor: success ? Colors.green : Colors.red,
      );
    }
  }

  // 构建分享选项按钮
  static Widget _buildShareOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: theme.primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
} 