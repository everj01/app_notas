import 'package:flutter/material.dart';

import '../models/note.dart';
import '../theme.dart';
import '../utils/date_format.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;

  const NoteCard({super.key, required this.note, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Color(note.color);
    final isWhite = color.value == 0xFFFFFFFF;

    return Material(
      color: color,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: isWhite ? Border.all(color: const Color(0xFFE6E5F0)) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (note.title.isNotEmpty)
                Text(
                  note.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              if (note.title.isNotEmpty && note.content.isNotEmpty)
                const SizedBox(height: 8),
              Expanded(
                child: Text(
                  note.content,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: AppColors.textDark.withValues(alpha: 0.75),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                formatDate(note.updatedAt),
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
