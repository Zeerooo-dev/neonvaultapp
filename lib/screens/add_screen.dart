import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../theme.dart';
import '../models/snippet.dart';
import '../widgets/shared_widgets.dart';
import '../services/formatter_service.dart';

class AddScreen extends StatefulWidget {
  final Snippet? existing;

  const AddScreen({super.key, this.existing});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final _titleCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();
  String _language = 'TypeScript';
  List<String> _tags = [];

  static const _languages = [
    // Web
    'TypeScript', 'JavaScript', 'HTML', 'CSS',
    // JVM / mobile
    'Java', 'Kotlin', 'Swift', 'Dart',
    // Systems
    'C', 'C++', 'C#', 'Rust', 'Go',
    // Scripting
    'Python', 'Ruby', 'PHP', 'Perl', 'Lua', 'R',
    // Shell
    'Bash', 'Shell', 'PowerShell',
    // Functional
    'Haskell', 'Elixir', 'Clojure', 'Scala',
    // Data / config
    'SQL', 'GraphQL', 'JSON', 'YAML', 'XML', 'Markdown',
    // Other
    'Terraform', 'Dockerfile', 'Assembly',
  ];

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final s = widget.existing!;
      _titleCtrl.text = s.title;
      _codeCtrl.text = s.code;
      _language = s.language;
      _tags = List.from(s.tags);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _codeCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NVColors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: NVColors.primaryLight),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Architect' : 'Architect',
          style: const TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: NVColors.primaryLight,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page title
            Text(
              _isEditing ? 'Edit Fragment' : 'Initialize New Fragment',
              style: const TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontWeight: FontWeight.w800,
                fontSize: 28,
                color: NVColors.primaryLight,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'ARCHITECT_VAULT_PROTOCOL_V8',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 10,
                letterSpacing: 2,
                color: NVColors.onSurface.withOpacity(0.25),
              ),
            ),
            const SizedBox(height: 32),

            // Title + Language row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _FieldBlock(
                    label: 'SNIPPET TITLE',
                    child: _StyledInput(
                      controller: _titleCtrl,
                      hint: 'e.g. Auth Middleware Pattern',
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _FieldBlock(
                    label: 'LANGUAGE',
                    child: _LangDropdown(
                      value: _language,
                      items: _languages,
                      onChanged: (v) => setState(() => _language = v!),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Tags
            _FieldBlock(
              label: 'METADATA TAGS',
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: NVColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_tags.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _tags
                            .map((t) => TagChip(
                                  tag: t,
                                  onDelete: () => setState(() => _tags.remove(t)),
                                ))
                            .toList(),
                      ),
                    if (_tags.isNotEmpty) const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _tagCtrl,
                            style: const TextStyle(
                              color: NVColors.primary,
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 13,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                              hintText: 'Add tag...',
                              hintStyle: TextStyle(
                                color: NVColors.onSurface.withOpacity(0.25),
                                fontFamily: 'SpaceGrotesk',
                                fontSize: 13,
                              ),
                            ),
                            onSubmitted: _addTag,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _addTag(_tagCtrl.text),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: NVColors.secondary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.add, size: 16, color: NVColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Code editor
            _FieldBlock(
              label: 'SOURCE CODE',
              child: Container(
                decoration: BoxDecoration(
                  color: NVColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: NVColors.surfaceVariant),
                ),
                clipBehavior: Clip.hardEdge,
                child: Column(
                  children: [
                    // Editor header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      color: NVColors.surfaceContainer.withOpacity(0.5),
                      child: Row(
                        children: [
                          _dot(NVColors.surfaceVariant.withOpacity(0.3)),
                          const SizedBox(width: 5),
                          _dot(NVColors.secondary.withOpacity(0.2)),
                          const SizedBox(width: 5),
                          _dot(NVColors.primary.withOpacity(0.1)),
                          const Spacer(),
                          Text(
                            'EDITOR v8.0',
                            style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 9,
                              letterSpacing: 2,
                              color: NVColors.primary.withOpacity(0.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Editor body
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Gutter
                          Container(
                            width: 40,
                            color: Colors.black.withOpacity(0.1),
                            padding: const EdgeInsets.fromLTRB(0, 16, 10, 16),
                            child: ValueListenableBuilder<TextEditingValue>(
                              valueListenable: _codeCtrl,
                              builder: (_, val, __) {
                                final lines = (val.text.isEmpty ? 1 : val.text.split('\n').length);
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: List.generate(
                                    lines.clamp(10, 100),
                                    (i) => Text(
                                      '${i + 1}',
                                      style: TextStyle(
                                        fontFamily: 'JetBrainsMono',
                                        fontSize: 11,
                                        height: 1.75,
                                        color: NVColors.outline.withOpacity(0.3),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          // Textarea
                          Expanded(
                            child: TextField(
                              controller: _codeCtrl,
                              maxLines: null,
                              minLines: 12,
                              style: const TextStyle(
                                fontFamily: 'JetBrainsMono',
                                fontSize: 13,
                                height: 1.75,
                                color: NVColors.primary,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
                                hintText: '// Paste or write your code here...',
                                hintStyle: TextStyle(
                                  fontFamily: 'JetBrainsMono',
                                  fontSize: 12,
                                  color: NVColors.outline.withOpacity(0.15),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Format + Save row
            Row(
              children: [
                // Format button
                Expanded(
                  child: GestureDetector(
                    onTap: _formatCode,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: NVColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: NVColors.outline.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.auto_fix_high, color: NVColors.primary, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Format',
                            style: const TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: NVColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Save button
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: _save,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: NVColors.secondary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock_outline, color: NVColors.surface, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            _isEditing ? 'Update Fragment' : 'Save Fragment',
                            style: const TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: NVColors.surface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _formatCode() {
    if (_codeCtrl.text.trim().isEmpty) return;
    HapticFeedback.lightImpact();
    final formatted = CodeFormatter.format(_codeCtrl.text, _language);
    // Preserve cursor at end
    _codeCtrl.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.auto_fix_high, color: NVColors.primary, size: 16),
            const SizedBox(width: 8),
            Text(
              'Code formatted!',
              style: const TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: NVColors.surfaceContainerHigh,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _addTag(String value) {
    final tag = value.trim();
    if (tag.isEmpty) return;
    final normalized = tag.startsWith('#') ? tag : '#$tag';
    if (!_tags.contains(normalized)) {
      setState(() => _tags.add(normalized));
    }
    _tagCtrl.clear();
  }

  void _save() {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a title', style: TextStyle(fontFamily: 'SpaceGrotesk')),
          backgroundColor: NVColors.surfaceContainerHigh,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    if (_codeCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter some code', style: TextStyle(fontFamily: 'SpaceGrotesk')),
          backgroundColor: NVColors.surfaceContainerHigh,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    final now = DateTime.now();

    final snippet = _isEditing
        ? widget.existing!.copyWith(
            title: _titleCtrl.text.trim(),
            code: _codeCtrl.text,
            language: _language,
            tags: _tags,
            updatedAt: now,
          )
        : Snippet(
            id: const Uuid().v4(),
            title: _titleCtrl.text.trim(),
            code: _codeCtrl.text,
            language: _language,
            tags: _tags,
            isSaved: false,
            createdAt: now,
            updatedAt: now,
          );

    Navigator.pop(context, snippet);
  }

  Widget _dot(Color c) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      );
}

// ─── Field Block ──────────────────────────────────────────────────────────────
class _FieldBlock extends StatelessWidget {
  final String label;
  final Widget child;

  const _FieldBlock({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 9,
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
            color: NVColors.primary.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _StyledInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _StyledInput({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: NVColors.onSurface, fontFamily: 'SpaceGrotesk', fontSize: 15),
      decoration: InputDecoration(
        filled: true,
        fillColor: NVColors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: NVColors.primary.withOpacity(0.4)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintText: hint,
        hintStyle: TextStyle(color: NVColors.onSurface.withOpacity(0.25), fontFamily: 'SpaceGrotesk', fontSize: 14),
      ),
    );
  }
}

class _LangDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _LangDropdown({required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: NVColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: NVColors.surfaceContainerHigh,
          style: const TextStyle(color: NVColors.onSurface, fontFamily: 'SpaceGrotesk', fontSize: 14),
          icon: const Icon(Icons.expand_more, color: NVColors.primary, size: 18),
          items: items.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
