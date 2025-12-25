import 'package:advisor_desk/domain/entities/ai_insight.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:share_plus/share_plus.dart';
import 'package:advisor_desk/presentation/features/advisor_desk_ai/widgets/thinking_process_indicator.dart';

class AdvisorDeskChatBubble extends StatelessWidget {
  final AiInsight insight;
  final bool isUserMessage;
  final VoidCallback? onDelete;

  const AdvisorDeskChatBubble({
    Key? key,
    required this.insight,
    required this.isUserMessage,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuad,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          mainAxisAlignment:
              isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUserMessage) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.auto_awesome,
                    color: theme.colorScheme.primary, size: 16),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: isUserMessage
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (!isUserMessage)
                    const ThinkingProcessIndicator(isThinking: false),
                  GestureDetector(
                    onLongPress: onDelete != null
                        ? () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: theme.colorScheme.surface,
                                title: Text('Delete Message?',
                                    style: TextStyle(
                                        color: theme.colorScheme.onSurface)),
                                content: Text(
                                  'Are you sure you want to delete this message?',
                                  style: TextStyle(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.8)),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: Text('Cancel',
                                        style: TextStyle(
                                            color: theme.colorScheme.primary)),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      onDelete!();
                                    },
                                    style: TextButton.styleFrom(
                                        foregroundColor:
                                            theme.colorScheme.error),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          }
                        : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: isUserMessage
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(20),
                          topRight: const Radius.circular(20),
                          bottomLeft: Radius.circular(isUserMessage ? 20 : 4),
                          bottomRight: Radius.circular(isUserMessage ? 4 : 20),
                        ),
                        boxShadow: [
                          if (!isUserMessage)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: isUserMessage
                          ? Text(
                              insight.message,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white,
                                height: 1.4,
                              ),
                            )
                          : MarkdownBody(
                              data: insight.message,
                              selectable: true,
                              styleSheet: MarkdownStyleSheet(
                                p: theme.textTheme.bodyLarge
                                    ?.copyWith(height: 1.5),
                                strong: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  height: 1.5,
                                ),
                                em: theme.textTheme.bodyLarge?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  height: 1.5,
                                ),
                                listBullet: theme.textTheme.bodyLarge
                                    ?.copyWith(height: 1.5),
                                h1: theme.textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                h2: theme.textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                h3: theme.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                blockSpacing: 12,
                                listIndent: 16,
                                listBulletPadding:
                                    const EdgeInsets.only(right: 8),
                              ),
                            ),
                    ),
                  ),
                  // Actions for AI responses
                  if (!isUserMessage) ...[
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildActionButton(
                            context,
                            icon: Icons.copy_rounded,
                            label: 'Copy',
                            onTap: () {
                              Clipboard.setData(
                                  ClipboardData(text: insight.message));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Copied to clipboard'),
                                  duration: const Duration(seconds: 1),
                                  backgroundColor: theme.colorScheme.primary,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            context,
                            icon: Icons.share_rounded,
                            label: 'Share',
                            onTap: () {
                              Share.share(insight.message);
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildIconButton(
                            context,
                            icon: Icons.thumb_up_alt_outlined,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Thanks for the feedback!'),
                                  duration: const Duration(seconds: 1),
                                  backgroundColor: theme.colorScheme.secondary,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildIconButton(
                            context,
                            icon: Icons.thumb_down_alt_outlined,
                            onTap: () {
                               ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('We\'ll try to do better!'),
                                  duration: const Duration(seconds: 1),
                                  backgroundColor: theme.colorScheme.secondary,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isUserMessage) ...[
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.secondary,
                child: const Icon(Icons.person, size: 16, color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14, color: theme.colorScheme.onSurface.withOpacity(0.7)),
            const SizedBox(width: 4),
            Text(label,
                style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(BuildContext context,
      {required IconData icon, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          shape: BoxShape.circle,
          border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
        ),
        child: Icon(icon,
            size: 14, color: theme.colorScheme.onSurface.withOpacity(0.7)),
      ),
    );
  }
}
