import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../models/snippet.dart';
import '../models/detail_result.dart';
import '../widgets/shared_widgets.dart';
import 'detail_screen.dart';
import 'add_screen.dart';

class LibraryScreen extends StatefulWidget {
  final List<Snippet> snippets;
  final Function(Snippet) onSnippetUpdated;
  final Function(String) onSnippetDeleted;
  final Function(Snippet) onSnippetAdded;

  const LibraryScreen({
    super.key,
    required this.snippets,
    required this.onSnippetUpdated,
    required this.onSnippetDeleted,
    required this.onSnippetAdded,
  });

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _sort = 'latest';

  List<Snippet> get _sorted {
    final list = List<Snippet>.from(widget.snippets);
    if (_sort == 'popular') {
      list.sort((a, b) => b.copyCount.compareTo(a.copyCount));
    } else {
      list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }
    return list;
  }

  Map<String, int> get _langCounts {
    final counts = <String, int>{};
    for (final s in widget.snippets) {
      counts[s.language] = (counts[s.language] ?? 0) + 1;
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final sorted = _sorted;
    return Scaffold(
      backgroundColor: NVColors.surface,
      appBar: AppBar(
        toolbarHeight: 64,
        title: const Text(
          'NeonVault',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontWeight: FontWeight.w800,
            fontSize: 22,
            letterSpacing: -0.5,
            color: NVColors.primaryLight,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: NVColors.primaryLight),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _SnippetSearchDelegate(
                  snippets: widget.snippets,
                  onTap: (s) => _openDetail(s),
                ),
              );
            },
          ),
          const _AvatarWidget(),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero Bento ──
                  _HeroSection(snippetCount: widget.snippets.length, langCounts: _langCounts),
                  const SizedBox(height: 32),
                  // ── Section Header ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recent Library',
                            style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontWeight: FontWeight.w700,
                              fontSize: 22,
                              color: NVColors.onSurface,
                            ),
                          ),
                          Text(
                            'Your latest synced code fragments',
                            style: TextStyle(
                              fontSize: 13,
                              color: NVColors.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _SortBtn(label: 'Latest', active: _sort == 'latest', onTap: () => setState(() => _sort = 'latest')),
                          const SizedBox(width: 6),
                          _SortBtn(label: 'Popular', active: _sort == 'popular', onTap: () => setState(() => _sort = 'popular')),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // ── Snippet Grid ──
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == sorted.length) return _AddNewCard(onTap: _openAdd);
                  final s = sorted[index];
                  return SnippetCard(
                    snippet: s,
                    onTap: () => _openDetail(s),
                    onBookmark: () {
                      HapticFeedback.lightImpact();
                      widget.onSnippetUpdated(s.copyWith(isSaved: !s.isSaved, updatedAt: s.updatedAt));
                    },
                    onCopy: () {
                      HapticFeedback.mediumImpact();
                      Clipboard.setData(ClipboardData(text: s.code));
                      widget.onSnippetUpdated(s.copyWith(copyCount: s.copyCount + 1, updatedAt: s.updatedAt));
                      ScaffoldMessenger.of(context).showSnackBar(
                        _snackBar('Copied to clipboard!'),
                      );
                    },
                  );
                },
                childCount: sorted.length + 1,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        backgroundColor: NVColors.primary,
        foregroundColor: NVColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  void _openDetail(Snippet s) async {
    final result = await Navigator.push<DetailResult>(
      context,
      MaterialPageRoute(builder: (_) => DetailScreen(snippet: s, allSnippets: widget.snippets)),
    );
    if (result != null) {
      if (result.deleted) {
        widget.onSnippetDeleted(s.id);
      } else if (result.updated != null) {
        widget.onSnippetUpdated(result.updated!);
      }
    }
  }

  void _openAdd() async {
    final result = await Navigator.push<Snippet>(
      context,
      MaterialPageRoute(builder: (_) => const AddScreen()),
    );
    if (result != null) widget.onSnippetAdded(result);
  }

  SnackBar _snackBar(String msg) => SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'SpaceGrotesk')),
        backgroundColor: NVColors.surfaceContainerHigh,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      );
}

class _HeroSection extends StatelessWidget {
  final int snippetCount;
  final Map<String, int> langCounts;

  const _HeroSection({required this.snippetCount, required this.langCounts});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Featured card
        Expanded(
          flex: 2,
          child: Container(
            height: 200,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [NVColors.surfaceVariant, NVColors.surface],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: NVColors.outline.withOpacity(0.2)),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -8,
                  right: -8,
                  child: Icon(
                    Icons.terminal,
                    size: 100,
                    color: NVColors.primary.withOpacity(0.07),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: NVColors.secondary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        'FEATURED COLLECTION',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 9,
                          letterSpacing: 1.5,
                          color: NVColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Modern\nReact Hooks',
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        height: 1.1,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Essential 2024 patterns',
                      style: TextStyle(
                        fontSize: 12,
                        color: NVColors.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),
        // Stats card
        Expanded(
          child: Container(
            height: 200,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: NVColors.surfaceContainer,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: NVColors.outline.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$snippetCount',
                  style: const TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontWeight: FontWeight.w800,
                    fontSize: 40,
                    color: NVColors.primary,
                    height: 1,
                  ),
                ),
                Text(
                  'Snippets',
                  style: TextStyle(
                    fontSize: 13,
                    color: NVColors.onSurface.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${langCounts.length} languages',
                  style: TextStyle(
                    fontSize: 11,
                    color: NVColors.onSurface.withOpacity(0.35),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: -6,
                  children: langCounts.keys.take(4).map((lang) {
                    return Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: NVTheme.langColor(lang).withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: NVColors.surface, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          lang.substring(0, 2).toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: NVTheme.langColor(lang),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AddNewCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AddNewCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: NVColors.outline.withOpacity(0.2),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: NVColors.surfaceContainer,
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Icon(Icons.add, color: NVColors.primary),
            ),
            const SizedBox(height: 12),
            const Text(
              'Create New\nSnippet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontWeight: FontWeight.w700,
                color: Color(0x99D9E4EB),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Cmd + N',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 11,
                color: NVColors.onSurface.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _SortBtn({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? NVColors.surfaceContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: active ? NVColors.primary : NVColors.onSurface.withOpacity(0.4),
          ),
        ),
      ),
    );
  }
}

class _AvatarWidget extends StatelessWidget {
  const _AvatarWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: NVColors.surfaceContainerHigh,
        border: Border.all(color: NVColors.outline.withOpacity(0.2)),
      ),
      child: const Icon(Icons.person_outline, color: NVColors.primaryLight, size: 18),
    );
  }
}

// ─── Search Delegate ──────────────────────────────────────────────────────────
class _SnippetSearchDelegate extends SearchDelegate<Snippet?> {
  final List<Snippet> snippets;
  final Function(Snippet) onTap;

  _SnippetSearchDelegate({required this.snippets, required this.onTap});

  @override
  ThemeData appBarTheme(BuildContext context) => Theme.of(context).copyWith(
        appBarTheme: const AppBarTheme(backgroundColor: NVColors.surfaceContainerLow),
        inputDecorationTheme: const InputDecorationTheme(
          border: InputBorder.none,
          hintStyle: TextStyle(color: NVColors.primary, fontFamily: 'SpaceGrotesk'),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: NVColors.onSurface, fontFamily: 'SpaceGrotesk'),
        ),
      );

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(icon: const Icon(Icons.clear, color: NVColors.primary), onPressed: () => query = ''),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back, color: NVColors.primaryLight),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _buildList();

  @override
  Widget buildSuggestions(BuildContext context) => _buildList();

  Widget _buildList() {
    final results = query.isEmpty
        ? snippets
        : snippets.where((s) =>
            s.title.toLowerCase().contains(query.toLowerCase()) ||
            s.language.toLowerCase().contains(query.toLowerCase()) ||
            s.tags.any((t) => t.toLowerCase().contains(query.toLowerCase()))).toList();

    return Container(
      color: NVColors.surface,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: results.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final s = results[i];
          return GestureDetector(
            onTap: () => onTap(s),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: NVColors.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: NVColors.outline.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.title, style: const TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w600, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(s.language, style: TextStyle(fontSize: 12, color: NVTheme.langColor(s.language))),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: NVColors.primary),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

