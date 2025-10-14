import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:glitter_launcher/controllers/app_controller.dart';
import 'package:glitter_launcher/widgets/app_grid_item.dart';

import '../database/database.dart';

class FrequentAppsSection extends StatelessWidget {
  const FrequentAppsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final appCtrl = Get.find<AppController>();
    return FutureBuilder<List<App>>(
      future: appCtrl.getFrequentApps(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No frequent apps yet', style: TextStyle(color: Colors.white)),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(20),
          child: MasonryGridView.count(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) => AppGridItem(app: snapshot.data![index]),
          ),
        );
      },
    );
  }
}