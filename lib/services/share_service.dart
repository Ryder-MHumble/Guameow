import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

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
  static Future<bool> saveImageToGallery(Uint8List imageBytes) async {
    try {
      // 请求存储权限
      if (Platform.isAndroid || Platform.isIOS) {
        final status = await Permission.photos.request();
        if (!status.isGranted) {
          return false;
        }
      }
      
      final result = await ImageGallerySaver.saveImage(
        imageBytes, 
        quality: 100,
        name: "卦喵命理详解_${DateTime.now().millisecondsSinceEpoch}"
      );
      
      return result['isSuccess'] ?? false;
    } catch (e) {
      debugPrint('保存图片到相册出错: $e');
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
    final imageBytes = await captureWidget(widgetKey);
    
    if (imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('生成分享图片失败，请重试'))
      );
      return;
    }

    // 创建预览图片
    final previewImage = Image.memory(
      imageBytes,
      height: 200,
      fit: BoxFit.contain,
    );

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
                    Navigator.pop(context);
                    final success = await saveImageToGallery(imageBytes);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? '已保存到相册' : '保存失败，请检查权限设置'),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ),
                      );
                    }
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
                    Navigator.pop(context);
                    // 显示生成中提示
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('长图生成中...'))
                      );
                    }
                    
                    // 保存到相册并显示完成提示
                    final success = await saveImageToGallery(imageBytes);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? '长图已保存到相册' : '生成失败，请检查权限设置'),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ),
                      );
                    }
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