import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  static String get storeUrl {
    if (Platform.isAndroid) {
      return 'https://play.google.com/store/apps/details?id=com.socialfaculty.eavesdrop';
    } else {
      return 'https://apps.apple.com/ng/app/alter-ego-know-all-yourselves/id6759404823';
    }
  }

  static Future<void> captureAndShare(
    BuildContext context,
    GlobalKey key, {
    required String text,
    required String subject,
  }) async {
    try {
      // Ensure we are not in the middle of a frame
      await Future.delayed(const Duration(milliseconds: 100));
      
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      // If it's still marked as needing paint, wait one more frame
      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/alter_ego_share.png').create();
      await imagePath.writeAsBytes(pngBytes);

      if (!context.mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      
      await Share.shareXFiles(
        [XFile(imagePath.path)],
        text: '$text\n\nDownload Alter Ego: $storeUrl',
        subject: subject,
        sharePositionOrigin: box != null ? box.localToGlobal(Offset.zero) & box.size : null,
      );
    } catch (e) {
      debugPrint('Error sharing: $e');
    }
  }

  static Future<void> shareText(BuildContext context, String text) async {
    final box = context.findRenderObject() as RenderBox?;
    await Share.share(
      '$text\n\n$storeUrl',
      sharePositionOrigin: box != null ? box.localToGlobal(Offset.zero) & box.size : null,
    );
  }
}
