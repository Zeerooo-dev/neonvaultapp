import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../models/snippet.dart';
import '../widgets/shared_widgets.dart';
import 'detail_screen.dart';

class SavedScreen extends StatelessWidget {
  final List<Snippet> snippets;
  final Function(Snippet) onSnippetUpdated;
  final Function(String) onSnippetDeleted;

  const SavedScreen({
    super.key,
    required this.snippets,
    required this.onSnippetUpdated,
    required this.onSnippetDeleted,
  });

  List<Snippet> get _saved => snippets.where((s) => s.isSaved).toList();

  @override
  Widget build(BuildContext context) {
    final saved = _saved;
    return Scaffold(
      backgroundColor: NVColors.surface,
      appBar: AppBar(
        title: const Text(
          'Saved',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontWeight: FontWeight.w800,
            fontSize: 22,
            letterSpacing: -0.5,
            color: NVColors.primaryLight,
          ),
        ),
      ),
      body: saved.isEmpty
          ? _EmptyState()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              itemCount: saved.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) {
                final s = saved[i];
                return SnippetCard(
                  snippet: s,
                  onTap: () => _open(context, s),
                  onBookmark: () {
                    HapticFeedback.lightImpact();
                    onSnippetUpdated(s.copyWith(isSaved: false, updatedAt: s.updatedAt));
                  },
                  onCopy: () {
                    Clipboard.setData(ClipboardData(text: s.code));
                    onSnippetUpdated(s.copyWith(copyCount: s.copyCount + 1, updatedAt: s.updatedAt));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Copied!', style: TextStyle(fontFamily: 'SpaceGrotesk')),
                        backgroundColor: NVColors.surfaceContainerHigh,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  void _open(BuildContext context, Snippet s) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(snippet: s, allSnippets: snippets)));
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: NVColors.surfaceContainer,
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Icon(Icons.bookmark_outline, color: NVColors.primary, size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            'No saved snippets yet',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: NVColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bookmark snippets to see them here',
            style: TextStyle(
              fontSize: 14,
              color: NVColors.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}
