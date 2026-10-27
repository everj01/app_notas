import 'package:flutter/material.dart';

import '../data/database_helper.dart';
import '../models/note.dart';
import '../theme.dart';
import '../utils/date_format.dart';

class NoteEditorScreen extends StatefulWidget {
  final int userId;
  final Note? note;

  const NoteEditorScreen({super.key, required this.userId, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  late int _color;

  bool get _isNew => widget.note == null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.note?.title ?? '');
    _contentCtrl = TextEditingController(text: widget.note?.content ?? '');
    _color = widget.note?.color ?? AppColors.noteColors.first.value;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  bool get _hasChanges {
    final original = widget.note;
    if (original == null) {
      return _titleCtrl.text.trim().isNotEmpty ||
          _contentCtrl.text.trim().isNotEmpty;
    }
    return _titleCtrl.text != original.title ||
        _contentCtrl.text != original.content ||
        _color != original.color;
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La nota está vacía')),
      );
      return;
    }

    final note = (widget.note ??
            Note(
              userId: widget.userId,
              title: '',
              content: '',
              color: _color,
              updatedAt: DateTime.now(),
            ))
        .copyWith(
      title: title,
      content: content,
      color: _color,
      updatedAt: DateTime.now(),
    );

    await DatabaseHelper.instance.saveNote(note);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar nota'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    await DatabaseHelper.instance.deleteNote(widget.note!.id!, widget.userId);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<bool> _confirmDiscard() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Descartar cambios'),
        content: const Text('Tienes cambios sin guardar.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Seguir editando'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final background = Color(_color);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (!_hasChanges || await _confirmDiscard()) {
          navigator.pop(false);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        color: background,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            actions: [
              if (!_isNew)
                IconButton(
                  tooltip: 'Eliminar',
                  onPressed: _delete,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              Padding(
                padding: const EdgeInsets.only(right: 12, left: 4),
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 42),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                  ),
                  onPressed: _save,
                  icon: const Icon(Icons.check_rounded, size: 20),
                  label: const Text('Guardar'),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    children: [
                      TextField(
                        controller: _titleCtrl,
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Título',
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      if (!_isNew)
                        Padding(
                          padding: const EdgeInsets.only(top: 6, bottom: 4),
                          child: Text(
                            'Editado: ${formatDate(widget.note!.updatedAt)}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _contentCtrl,
                        maxLines: null,
                        minLines: 12,
                        autofocus: _isNew,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: AppColors.textDark,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Escribe algo...',
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
                _ColorPicker(
                  selected: _color,
                  onSelected: (c) => setState(() => _color = c),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelected;

  const _ColorPicker({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: const Color(0xFFE6E5F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: AppColors.noteColors.map((color) {
          final value = color.value;
          final isSelected = value == selected;
          return GestureDetector(
            onTap: () => onSelected(value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : const Color(0xFFD9D8E6),
                  width: isSelected ? 2.6 : 1,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, size: 18, color: AppColors.primary)
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }
}
