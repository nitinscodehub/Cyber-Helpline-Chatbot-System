import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final Function(String)? onActionPressed;
  final Function()? onLongPress;
  final bool showAvatar;

  const MessageBubble({
    super.key,
    required this.message,
    this.onActionPressed,
    this.onLongPress,
    this.showAvatar = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onLongPress: onLongPress != null ? () => onLongPress!() : null,
        child: Row(
          mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!message.isUser && showAvatar) _buildAvatar(context, isDark),
            if (!message.isUser && showAvatar) const SizedBox(width: 8),
            
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: _buildDecoration(context, isDark),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Priority/Type indicators
                    if (message.type == MessageType.emergency)
                      _buildEmergencyBadge(context)
                    else if (message.priority == MessagePriority.high)
                      _buildHighPriorityBadge(context)
                    else if (message.type == MessageType.crime)
                      _buildCrimeBadge(context, message.crimeType)
                    else if (message.type == MessageType.info)
                      _buildInfoBadge(context),
                    
                    // Message text with formatting
                    _buildMessageText(context, isDark),
                    
                    // Metadata (if any)
                    if (message.metadata != null && message.metadata!.isNotEmpty)
                      _buildMetadata(context),
                    
                    // Evidence image (if any)
                    if (message.imageUrl != null)
                      _buildEvidenceImage(context),
                    
                    // Timestamp
                    _buildTimestamp(context, isDark),
                    
                    // Divider before actions
                    if (message.hasActions) ...[
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                    ],
                    
                    // Action buttons with animation
                    if (message.hasActions)
                      _buildActionButtons(context),
                  ],
                ),
              ),
            ),
            
            if (message.isUser && showAvatar) const SizedBox(width: 8),
            if (message.isUser && showAvatar) _buildAvatar(context, isDark, isUser: true),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, bool isDark, {bool isUser = false}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (isUser ? Colors.blue : Colors.grey).withAlpha(51),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 18,
        backgroundColor: isUser 
            ? Colors.blue.shade500 
            : isDark ? Colors.grey.shade800 : Colors.blue.shade100,
        child: Icon(
          isUser ? Icons.person : _getBotIcon(),
          size: 18,
          color: isUser ? Colors.white : (isDark ? Colors.white : Colors.blue),
        ),
      ),
    );
  }

  IconData _getBotIcon() {
    if (message.type == MessageType.emergency) return Icons.warning;
    if (message.type == MessageType.crime) return Icons.gavel;
    if (message.type == MessageType.fraud) return Icons.money_off;
    if (message.type == MessageType.info) return Icons.info;
    if (message.type == MessageType.system) return Icons.settings;
    return Icons.support_agent;
  }

  BoxDecoration _buildDecoration(BuildContext context, bool isDark) {
    final borderRadius = message.isUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          );

    if (message.isUser) {
      return BoxDecoration(
        color: isDark ? Colors.blue.shade700 : Colors.blue.shade500,
        borderRadius: borderRadius,
        boxShadow: _getShadow(isDark ? Colors.blue.shade900 : Colors.blue.shade200),
      );
    }

    // Bot message - color based on type/priority
    Color backgroundColor;
    Color borderColor = Colors.transparent;

    switch (message.type) {
      case MessageType.emergency:
        backgroundColor = isDark ? Colors.red.shade900.withAlpha(77) : Colors.red.shade50;
        borderColor = isDark ? Colors.red.shade700 : Colors.red.shade200;
        break;
      case MessageType.crime:
      case MessageType.fraud:
        backgroundColor = isDark ? Colors.orange.shade900.withAlpha(77) : Colors.orange.shade50;
        borderColor = isDark ? Colors.orange.shade700 : Colors.orange.shade200;
        break;
      case MessageType.info:
        backgroundColor = isDark ? Colors.blue.shade900.withAlpha(77) : Colors.blue.shade50;
        borderColor = isDark ? Colors.blue.shade700 : Colors.blue.shade200;
        break;
      case MessageType.system:
        backgroundColor = isDark ? Colors.grey.shade800 : Colors.grey.shade100;
        borderColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
        break;
      default:
        // Priority-based
        switch (message.priority) {
          case MessagePriority.high:
            backgroundColor = isDark ? Colors.orange.shade900.withAlpha(77) : Colors.orange.shade50;
            borderColor = isDark ? Colors.orange.shade700 : Colors.orange.shade200;
            break;
          case MessagePriority.medium:
            backgroundColor = isDark ? Colors.yellow.shade900.withAlpha(77) : Colors.yellow.shade50;
            borderColor = isDark ? Colors.yellow.shade700 : Colors.yellow.shade200;
            break;
          default:
            backgroundColor = isDark ? Colors.grey.shade800 : Colors.grey.shade100;
        }
    }

    return BoxDecoration(
      color: backgroundColor,
      border: borderColor != Colors.transparent
          ? Border.all(color: borderColor, width: 1.5)
          : null,
      borderRadius: borderRadius,
      boxShadow: _getShadow(borderColor != Colors.transparent ? borderColor : Colors.grey.shade300),
    );
  }

  List<BoxShadow> _getShadow(Color color) {
    return [
      BoxShadow(
        color: color.withAlpha(26),
        blurRadius: 5,
        offset: const Offset(0, 2),
      ),
    ];
  }

  Widget _buildEmergencyBadge(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.red, Colors.orange],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withAlpha(77),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.warning_amber_rounded, color: Colors.white, size: 14),
          SizedBox(width: 6),
          Text(
            'EMERGENCY',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighPriorityBadge(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.priority_high, color: Colors.white, size: 12),
          SizedBox(width: 4),
          Text(
            'HIGH PRIORITY',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrimeBadge(BuildContext context, String? crimeType) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.purple,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.gavel, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            crimeType ?? 'CRIME REPORT',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.info, color: Colors.white, size: 12),
          SizedBox(width: 4),
          Text(
            'INFO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageText(BuildContext context, bool isDark) {
    final text = message.text;
    final textColor = message.isUser 
        ? Colors.white 
        : (isDark ? Colors.white : Colors.black87);

    // Check for bullet points
    if (text.contains('•') || text.contains('·')) {
      return _buildBulletPoints(text, textColor);
    }

    // Check for numbered lists
    if (RegExp(r'^\d+\.').hasMatch(text)) {
      return _buildNumberedList(text, textColor);
    }

    // Check for markdown bold
    if (text.contains('**')) {
      return _buildRichText(text, textColor);
    }

    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 15,
        color: textColor,
        height: 1.4,
      ),
    );
  }

  Widget _buildBulletPoints(String text, Color textColor) {
    final lines = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.trim().startsWith('•') || line.trim().startsWith('·')) {
          return Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Text(
                    line.substring(1).trim(),
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: textColor,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return Text(
          line,
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: textColor,
            height: 1.4,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNumberedList(String text, Color textColor) {
    final lines = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        final match = RegExp(r'^(\d+)\.\s*(.*)').firstMatch(line);
        if (match != null) {
          final number = match.group(1);
          final content = match.group(2);
          return Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$number. ', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Text(
                    content ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: textColor,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return Text(
          line,
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: textColor,
            height: 1.4,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRichText(String text, Color textColor) {
    final parts = text.split('**');
    final spans = <TextSpan>[];
    
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isEmpty) continue;
      
      spans.add(
        TextSpan(
          text: parts[i],
          style: TextStyle(
            fontWeight: i % 2 == 1 ? FontWeight.bold : FontWeight.normal,
            color: textColor,
          ),
        ),
      );
    }
    
    return RichText(
      text: TextSpan(
        style: GoogleFonts.poppins(fontSize: 15, height: 1.4),
        children: spans,
      ),
    );
  }

  Widget _buildMetadata(BuildContext context) {
    if (message.metadata == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(13),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: message.metadata!.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Text(
                  '${entry.key}: ',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: message.isUser ? Colors.white70 : Colors.grey.shade700,
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.value.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: message.isUser ? Colors.white70 : Colors.grey.shade700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEvidenceImage(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: NetworkImage(message.imageUrl!),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withAlpha(128),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '📸 Evidence',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimestamp(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (message.crimeId != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'ID: ${message.crimeId}',
                style: TextStyle(
                  color: message.isUser ? Colors.white70 : Colors.grey.shade500,
                  fontSize: 8,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            message.isToday ? message.formattedTime : message.formattedDate,
            style: TextStyle(
              color: message.isUser ? Colors.white70 : Colors.grey.shade500,
              fontSize: 10,
            ),
          ),
          if (message.isUser)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(
                Icons.done_all,
                size: 12,
                color: Colors.white70,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (message.buttons == null) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: message.buttons!.map((button) {
        final isDanger = button.isDanger ?? false;
        final priority = button.priority ?? 999;
        
        return AnimatedContainer(
          duration: Duration(milliseconds: 200 + (priority * 50)),
          curve: Curves.easeOut,
          child: ElevatedButton(
            onPressed: () {
              if (onActionPressed != null) {
                onActionPressed!(button.action);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDanger ? Colors.red : button.getButtonColor(),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: isDanger ? 4 : 2,
              shadowColor: isDanger ? Colors.red.withAlpha(77) : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (button.icon != null) ...[
                  Icon(button.icon, size: 16),
                  const SizedBox(width: 6),
                ],
                Text(
                  button.label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isDanger) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.warning, size: 12),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}