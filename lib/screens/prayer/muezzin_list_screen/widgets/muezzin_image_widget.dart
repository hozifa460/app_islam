import 'dart:io';
import 'package:flutter/material.dart';

import '../../more/data/muezzin_catalog.dart';
import '../../more/services/adhan_image_cache_service.dart';

class MuezzinImageWidget extends StatelessWidget {
  final MuezzinInfo muezzin;

  const MuezzinImageWidget({super.key, required this.muezzin});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: AdhanImageCacheService.instance.getLocalPath(muezzin.id),
      builder: (context, snapshot) {
        final localPath = snapshot.data;

        if (localPath != null && localPath.isNotEmpty) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.file(File(localPath), fit: BoxFit.cover),
              Container(color: Colors.black.withValues(alpha: 0.25)),
            ],
          );
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              muezzin.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  color: Colors.black12,
                  child: const Center(
                    child: Icon(Icons.person,
                        color: Colors.white54, size: 30),
                  ),
                );
              },
            ),
            Container(color: Colors.black.withValues(alpha: 0.25)),
          ],
        );
      },
    );
  }
}