import 'package:flutter/material.dart';
import 'package:stock_count/utils/error_message_parser.dart';

class ProfessionalErrorDialog extends StatelessWidget {
  final String title;
  final String errorMessage;
  final String? actionText;
  final VoidCallback? onAction;
  final bool canRetry;

  const ProfessionalErrorDialog({
    super.key,
    required this.title,
    required this.errorMessage,
    this.actionText,
    this.onAction,
    this.canRetry = true,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String errorMessage,
    String? actionText,
    VoidCallback? onAction,
    bool canRetry = true,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ProfessionalErrorDialog(
          title: title,
          errorMessage: errorMessage,
          actionText: actionText,
          onAction: onAction,
          canRetry: canRetry,
        );
      },
    );
  }

  static Future<void> showLeaveApplicationError({
    required BuildContext context,
    required String rawErrorMessage,
    VoidCallback? onRetry,
  }) {
    final friendlyMessage = ErrorMessageParser.parseLeaveApplicationError(rawErrorMessage);
    final icon = ErrorMessageParser.getErrorIcon(rawErrorMessage);
    
    return show(
      context: context,
      title: '$icon Leave Application Failed',
      errorMessage: friendlyMessage,
      actionText: onRetry != null ? 'Try Again' : null,
      onAction: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.error_outline_rounded,
              color: theme.colorScheme.error,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Please review your information and try again. Contact support if the issue persists.',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurfaceVariant,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Close'),
            ),
            if (canRetry && onAction != null) ...[
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onAction?.call();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(actionText ?? 'Retry'),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Success dialog for positive feedback
class ProfessionalSuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onAction;
  final String? actionText;

  const ProfessionalSuccessDialog({
    super.key,
    required this.title,
    required this.message,
    this.onAction,
    this.actionText,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onAction,
    String? actionText,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return ProfessionalSuccessDialog(
          title: title,
          message: message,
          onAction: onAction,
          actionText: actionText,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: Colors.green,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: TextStyle(
          fontSize: 14,
          height: 1.5,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      actions: [
        if (onAction != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onAction?.call();
            },
            child: Text(actionText ?? 'View Details'),
          ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }
}