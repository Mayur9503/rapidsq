import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../state/emergency_enums.dart';

class ErrorStateSheet extends StatelessWidget {
  final ErrorStateType errorType;
  final VoidCallback onRetry;
  final VoidCallback onDismiss;

  const ErrorStateSheet({
    super.key,
    required this.errorType,
    required this.onRetry,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(errorType);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: config.iconBgColor,
            ),
            child: Icon(config.icon, color: config.iconColor, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            config.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            config.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.secondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Primary Resolution Action
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: Icon(config.primaryActionIcon, size: 20, color: Colors.white),
            label: Text(config.primaryActionText),
            style: ElevatedButton.styleFrom(
              backgroundColor: config.primaryActionColor,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(56),
            ),
          ),
          if (errorType == ErrorStateType.noAmbulanceAvailable) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                final uri = Uri.parse('tel:112');
                try {
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                } catch (_) {}
              },
              icon: const Icon(Icons.phone_in_talk, size: 20, color: Colors.white),
              label: const Text('EMERGENCY BACKUP: CALL 112'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
          const SizedBox(height: 12),

          // Secondary Fallback Action
          OutlinedButton.icon(
            onPressed: onDismiss,
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text('Return to Home'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
          ),
        ],
      ),
    );
  }

  _ErrorConfig _getConfig(ErrorStateType type) {
    switch (type) {
      case ErrorStateType.noAmbulanceAvailable:
        return _ErrorConfig(
          icon: Icons.emergency_share,
          iconColor: AppColors.error,
          iconBgColor: AppColors.errorContainer,
          title: "No Responder Accepted",
          description:
              "No responder accepted the emergency.",
          primaryActionText: "RETRY EMERGENCY DISPATCH",
          primaryActionIcon: Icons.refresh,
          primaryActionColor: AppColors.primary,
        );
      case ErrorStateType.networkUnavailable:
        return _ErrorConfig(
          icon: Icons.wifi_off,
          iconColor: AppColors.amber,
          iconBgColor: AppColors.amberContainer,
          title: "Telemetry Sync Disconnected",
          description:
              "Cellular data connection interrupted. ResQ can broadcast an offline SMS emergency triage beacon immediately.",
          primaryActionText: "SEND OFFLINE SMS BEACON",
          primaryActionIcon: Icons.sms,
          primaryActionColor: AppColors.inverseSurface,
        );
      case ErrorStateType.locationPermissionDenied:
        return _ErrorConfig(
          icon: Icons.location_disabled,
          iconColor: AppColors.primary,
          iconBgColor: AppColors.primaryFixed,
          title: "High-Precision GPS Required",
          description:
              "Ambulance navigation requires device location permission to calculate rapid road routing and ETA.",
          primaryActionText: "GRANT LOCATION ACCESS",
          primaryActionIcon: Icons.settings,
          primaryActionColor: AppColors.primary,
        );
      case ErrorStateType.requestCancelled:
        return _ErrorConfig(
          icon: Icons.cancel_outlined,
          iconColor: AppColors.secondary,
          iconBgColor: AppColors.surfaceContainerHigh,
          title: "Emergency Request Cancelled",
          description:
              "The dispatch signal was cancelled. Dispatchers and emergency units have been notified.",
          primaryActionText: "START NEW SOS",
          primaryActionIcon: Icons.refresh,
          primaryActionColor: AppColors.primary,
        );
    }
  }
}

class _ErrorConfig {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String description;
  final String primaryActionText;
  final IconData primaryActionIcon;
  final Color primaryActionColor;

  _ErrorConfig({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.description,
    required this.primaryActionText,
    required this.primaryActionIcon,
    required this.primaryActionColor,
  });
}
