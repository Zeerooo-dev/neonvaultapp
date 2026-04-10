import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../theme.dart';
import '../models/snippet.dart';
import '../models/detail_result.dart';
import '../services/storage_service.dart';
import '../widgets/shared_widgets.dart';
import 'add_screen.dart';

class DetailScreen extends StatefulWidget {
  final Snippet snippet;
  final List<Snippet> allSnippets;

  const DetailScreen({
    super.key,
    required this.snippet,
    required this.allSnippets,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Snippet _snippet;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _snippet = widget.snippet;
  }

  void _goBack() {
    Navigator.pop(context, DetailResult(updated: _snippet));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goBack();
      },
      child: Scaffold(
        backgroundColor: NVColors.surface,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: NVColors.primaryLight),
            onPressed: _goBack,
          ),
          title: const Text(
            'Architect',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: NVColors.primaryLight,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: NVColors.primary),
              onPressed: _confirmDelete,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tags row
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._snippet.tags.map((t) => TagChip(tag: t)),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: NVColors.secondary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: NVColors.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: NVTheme.langColor(_snippet.language),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _snippet.language.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 10,
                            letterSpacing: 1.5,
                            color: NVColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Title
              Text(
                _snippet.title,
                style: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                  height: 1.1,
                  color: NVColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Code snippet • ${_snippet.timeAgo}',
                style: TextStyle(
                  fontSize: 13,
                  color: NVColors.onSurface.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 24),
              // Action bar
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _ActionBtn(
                      icon: _copied ? Icons.check : Icons.copy_outlined,
                      label: _copied ? 'Copied!' : 'Copy Code',
                      primary: true,
                      onTap: _copyCode,
                    ),
                    const SizedBox(width: 10),
                    _ActionBtn(
                      icon: Icons.edit_outlined,
                      label: 'Edit',
                      onTap: _editSnippet,
                    ),
                    const SizedBox(width: 10),
                    _ActionBtn(
                      icon: Icons.share_outlined,
                      label: 'Share',
                      onTap: () => _shareCode(),
                    ),
                    const SizedBox(width: 10),
                    _BookmarkBtn(
                      isSaved: _snippet.isSaved,
                      onTap: () => setState(() {
                        _snippet = _snippet.copyWith(
                          isSaved: !_snippet.isSaved,
                          updatedAt: _snippet.updatedAt,
                        );
                        HapticFeedback.lightImpact();
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Code block
              _CodeBlock(snippet: _snippet),
              const SizedBox(height: 24),
              // Metadata
              Row(
                children: [
                  Expanded(
                    child: _MetaCard(
                      icon: Icons.history,
                      title: 'Revision History',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _HistoryRow('Last modified', _snippet.timeAgo),
                          const SizedBox(height: 8),
                          _HistoryRow(
                            'Created',
                            _formatDate(_snippet.createdAt),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _MetaCard(
                      icon: Icons.info_outline,
                      title: 'Usage Stats',
                      child: Row(
                        children: [
                          _StatItem(
                            value: '${_snippet.copyCount}',
                            label: 'COPIES',
                          ),
                          Container(
                            width: 1,
                            height: 32,
                            color: NVColors.outline.withOpacity(0.2),
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          _StatItem(
                            value: '${_snippet.tags.length}',
                            label: 'TAGS',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ), // Scaffold
    ); // PopScope
  }

  void _copyCode() async {
    HapticFeedback.mediumImpact();
    await Clipboard.setData(ClipboardData(text: _snippet.code));
    setState(() {
      _snippet = _snippet.copyWith(
        copyCount: _snippet.copyCount + 1,
        updatedAt: _snippet.updatedAt,
      );
      _copied = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  Future<void> _shareCode() async {
    try {
      final ext = _extForLanguage(_snippet.language);
      final safeTitle = _snippet.title.replaceAll(
        RegExp(r'[^a-zA-Z0-9_\-]'),
        '_',
      );
      final fileName = '$safeTitle$ext';

      // Write to a temp file so we can share it as an actual file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(_snippet.code);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: _mimeForLanguage(_snippet.language))],
        subject: _snippet.title,
        text: '${_snippet.title} — shared from NeonVault',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not share: $e',
              style: const TextStyle(fontFamily: 'SpaceGrotesk'),
            ),
            backgroundColor: NVColors.surfaceContainerHigh,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  String _extForLanguage(String lang) {
    switch (lang.toLowerCase()) {
      case 'python':
        return '.py';
      case 'javascript':
        return '.js';
      case 'typescript':
        return '.ts';
      case 'dart':
        return '.dart';
      case 'swift':
        return '.swift';
      case 'rust':
        return '.rs';
      case 'go':
        return '.go';
      case 'css':
        return '.css';
      case 'html':
        return '.html';
      case 'kotlin':
        return '.kt';
      case 'java':
        return '.java';
      default:
        return '.txt';
    }
  }

  String _mimeForLanguage(String lang) {
    switch (lang.toLowerCase()) {
      case 'html':
        return 'text/html';
      case 'css':
        return 'text/css';
      default:
        return 'text/plain';
    }
  }

  void _editSnippet() async {
    final result = await Navigator.push<Snippet>(
      context,
      MaterialPageRoute(builder: (_) => AddScreen(existing: _snippet)),
    );
    if (result != null) setState(() => _snippet = result);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NVColors.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Snippet',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            color: NVColors.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${_snippet.title}"?',
          style: TextStyle(color: NVColors.onSurface.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: NVColors.primary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // close dialog
              // Delete the snippet file from disk
              await StorageService.deleteSnippetFile(_snippet);
              if (context.mounted) {
                Navigator.pop(context, DetailResult(deleted: true));
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day} ${_months[dt.month - 1]} ${dt.year}';

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
}

class _CodeBlock extends StatelessWidget {
  final Snippet snippet;
  const _CodeBlock({required this.snippet});

  @override
  Widget build(BuildContext context) {
    final lines = snippet.code.split('\n');
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: NVColors.outline.withOpacity(0.3)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [NVColors.primary.withOpacity(0.05), Colors.transparent],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // Header bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: NVColors.surfaceContainerLow.withOpacity(0.5),
              child: Row(
                children: [
                  _dot(NVColors.surfaceVariant),
                  const SizedBox(width: 6),
                  _dot(NVColors.secondary),
                  const SizedBox(width: 6),
                  _dot(NVColors.primary),
                  const Spacer(),
                  Text(
                    'READ ONLY',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 9,
                      letterSpacing: 2,
                      color: NVColors.outline,
                    ),
                  ),
                ],
              ),
            ),
            // Code body
            Container(
              color: NVColors.surface,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gutter
                    Container(
                      color: NVColors.surfaceContainerLow.withOpacity(0.5),
                      padding: const EdgeInsets.fromLTRB(0, 20, 14, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: lines
                            .asMap()
                            .keys
                            .map(
                              (i) => Text(
                                '${i + 1}',
                                style: TextStyle(
                                  fontFamily: 'JetBrainsMono',
                                  fontSize: 12,
                                  height: 1.8,
                                  color: NVColors.outline.withOpacity(0.4),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    // Code
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 24, 20),
                      child: Text(
                        snippet.code,
                        style: const TextStyle(
                          fontFamily: 'JetBrainsMono',
                          fontSize: 13,
                          height: 1.8,
                          color: NVColors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(Color c) => Container(
    width: 12,
    height: 12,
    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
  );
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool primary;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: primary ? NVColors.primary : NVColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
          border: primary
              ? null
              : Border.all(color: NVColors.outline.withOpacity(0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: primary ? NVColors.surface : NVColors.onSurface,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: primary ? NVColors.surface : NVColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookmarkBtn extends StatelessWidget {
  final bool isSaved;
  final VoidCallback onTap;
  const _BookmarkBtn({required this.isSaved, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: NVColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: NVColors.outline.withOpacity(0.15)),
        ),
        child: Icon(
          isSaved ? Icons.bookmark : Icons.bookmark_outline,
          color: isSaved ? NVColors.primary : NVColors.onSurface,
          size: 20,
        ),
      ),
    );
  }
}

class _MetaCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const _MetaCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NVColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NVColors.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: NVColors.primary),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: NVColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final String label;
  final String value;
  const _HistoryRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: NVColors.onSurface.withOpacity(0.7),
        ),
      ),
      Text(
        value,
        style: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 12,
          color: NVColors.outline,
        ),
      ),
    ],
  );
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: NVColors.onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 9,
            letterSpacing: 1.5,
            color: NVColors.outline.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
