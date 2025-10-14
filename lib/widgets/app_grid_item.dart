import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:glitter_launcher/controllers/app_controller.dart';

import '../database/database.dart';

class AppGridItem extends StatelessWidget {
  final App app;

  const AppGridItem({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    final appCtrl = Get.find<AppController>();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => appCtrl.launchApp(app.packageName),
        onLongPress: () => _showAppOptions(context),
        child: Container(
          width: 80,
          height: 100,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Get.theme.primaryColor.withOpacity(0.15),
                Get.theme.primaryColor.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Get.theme.primaryColor.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          // ✅ FIX: Constrain Column to available space using Flexible + Safe Text Size
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                flex: 6,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: ClipOval(child: _buildAppIcon()),
                ).animate().scale(duration: 200.ms, curve: Curves.elasticOut),
              ),
              const SizedBox(height: 6),
              Flexible(
                flex: 4,
                child: Center(
                  child: Text(
                    app.appName,
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 11, // ✅ slightly smaller
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppIcon() {
    try {
      if (app.customIconPath?.isNotEmpty ?? false) {
        return Image.file(File(app.customIconPath!), fit: BoxFit.contain);
      }
      if (app.icon?.isNotEmpty ?? false) {
        return Image.memory(app.icon!, fit: BoxFit.contain);
      }
    } catch (_) {}
    return const Icon(Icons.apps, color: Colors.white, size: 30);
  }

  void _showAppOptions(BuildContext context) {
    final appCtrl = Get.find<AppController>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.95),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Rename App'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Change Icon'),
            onTap: () {
              Navigator.pop(context);
              appCtrl.pickCustomIcon(app.packageName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Uninstall'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
