import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../theme/app_colors.dart';

class SyncStatusIndicator extends StatelessWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        final results = snapshot.data;
        final bool isOffline = results == null || 
                               results.isEmpty || 
                               results.first == ConnectivityResult.none;

        if (isOffline) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_rounded, color: AppColors.secondaryTerracotta, size: 16),
              const SizedBox(width: 4),
              Text(
                'Offline Mode',
                style: TextStyle(
                  color: AppColors.secondaryTerracotta,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_done_rounded, color: AppColors.primaryGreen, size: 16),
            const SizedBox(width: 4),
            Text(
              'Synced',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }
}
