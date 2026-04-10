import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../models/snippet.dart';
import '../widgets/shared_widgets.dart';
import 'detail_screen.dart';

class TagsScreen extends StatefulWidget {
  final List<Snippet> snippets;
  final Function(Snippet) onSnippetUpdated;

  const TagsScreen({super.key, required this.snippets, required this.onSnippetUpdated});

  @override
  State<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends State<TagsScreen> {
  String _searchQuery = '';
  String? _selectedLanguage;
  String? _selectedTag;
  final _searchCtrl = TextEditingController();

  List<String> get _allTags {
    final tags = <String>{};
    for (final s in widget.snippets) {
      tags.addAll(s.tags);
    }
    return tags.toList()..sort();
  }

  Map<String, int> get _langCounts {
    final counts = <String, int>{};
    for (final s in widget.snippets) {
      counts[s.language] = (counts[s.language] ?? 0) + 1;
    }
    return Map.fromEntries(
      counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
  }

  List<Snippet> get _filtered {
    return widget.snippets.where((s) {
      final matchesSearch = _searchQuery.isEmpty ||
          s.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.code.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.language.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.tags.any((t) => t.toLowerCase().contains(_searchQuery.toLowerCase()));
      final matchesLang = _selectedLanguage == null || s.language == _selectedLanguage;
      final matchesTag = _selectedTag == null || s.tags.contains(_selectedTag);
      return matchesSearch && matchesLang && matchesTag;
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final langCounts = _langCounts;
    final tags = _allTags;

    return Scaffold(
      backgroundColor: NVColors.surface,
      appBar: AppBar(
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
      ),
      body: CustomScrollView(
        slivers: [
          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: NVColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Icon(Icons.search, color: NVColors.primary, size: 22),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        style: const TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          color: NVColors.onSurface,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          hintText: 'Search snippets, tags, or languages...',
                          hintStyle: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            color: NVColors.onSurface.withOpacity(0.3),
                            fontSize: 14,
                          ),
                        ),
                        onChanged: (v) => setState(() => _searchQuery = v),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, color: NVColors.primary, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Languages section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel('LANGUAGES'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: langCounts.entries.map((e) {
                      return LangChip(
                        language: e.key,
                        selected: _selectedLanguage == e.key,
                        onTap: () => setState(() {
                          _selectedLanguage = _selectedLanguage == e.key ? null : e.key;
                        }),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel('POPULAR TAGS'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags.map((t) {
                      final isSelected = _selectedTag == t;
                      return GestureDetector(
                        onTap: () => setState(() {
                          _selectedTag = _selectedTag == t ? null : t;
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? NVColors.secondary.withOpacity(0.25)
                                : NVColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? NVColors.primary.withOpacity(0.4)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Text(
                            t,
                            style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 12,
                              color: isSelected ? NVColors.primaryLight : NVColors.secondary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),
                  // Results header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Search Results',
                              style: TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                color: NVColors.onSurface,
                              ),
                            ),
                            TextSpan(
                              text: '  ${filtered.length} matches',
                              style: TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontSize: 14,
                                color: NVColors.primary.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_selectedLanguage != null || _selectedTag != null || _searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedLanguage = null;
                              _selectedTag = null;
                              _searchQuery = '';
                              _searchCtrl.clear();
                            });
                          },
                          child: const Text(
                            'Clear filters',
                            style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: NVColors.primary,
                              decoration: TextDecoration.underline,
                              decorationColor: NVColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Results
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: filtered.isEmpty
                ? SliverToBoxAdapter(child: _EmptyResults())
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final s = filtered[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _ResultCard(
                            snippet: s,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailScreen(snippet: s, allSnippets: widget.snippets),
                              ),
                            ),
                            onCopy: () {
                              HapticFeedback.mediumImpact();
                              Clipboard.setData(ClipboardData(text: s.code));
                              widget.onSnippetUpdated(s.copyWith(copyCount: s.copyCount + 1, updatedAt: s.updatedAt));
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
                            onBookmark: () {
                              HapticFeedback.lightImpact();
                              widget.onSnippetUpdated(s.copyWith(isSaved: !s.isSaved, updatedAt: s.updatedAt));
                            },
                          ),
                        );
                      },
                      childCount: filtered.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final Snippet snippet;
  final VoidCallback onTap;
  final VoidCallback onCopy;
  final VoidCallback onBookmark;

  const _ResultCard({
    required this.snippet,
    required this.onTap,
    required this.onCopy,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: NVColors.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: NVColors.outline.withOpacity(0.1)),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        snippet.title,
                        style: const TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        snippet.code.split('\n').first,
                        style: TextStyle(
                          fontSize: 12,
                          color: NVColors.onSurface.withOpacity(0.4),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: NVColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: NVColors.primary.withOpacity(0.2)),
                  ),
                  child: Text(
                    snippet.language.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 9,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                      color: NVColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Code preview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF050b0e),
                borderRadius: BorderRadius.circular(10),
                border: Border(left: BorderSide(color: NVColors.primary.withOpacity(0.3), width: 3)),
              ),
              child: Text(
                snippet.code.split('\n').take(4).join('\n'),
                style: const TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 12,
                  height: 1.6,
                  color: NVColors.primaryLight,
                ),
                maxLines: 4,
                overflow: TextOverflow.fade,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Wrap(
                  spacing: 6,
                  children: snippet.tags.take(2).map((t) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: NVColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      t,
                      style: TextStyle(fontSize: 11, color: NVColors.onSurface.withOpacity(0.5)),
                    ),
                  )).toList(),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onCopy,
                  child: Icon(Icons.copy_outlined, size: 18, color: NVColors.onSurface.withOpacity(0.35)),
                ),
                const SizedBox(width: 14),
                GestureDetector(
                  onTap: onBookmark,
                  child: Icon(
                    snippet.isSaved ? Icons.bookmark : Icons.bookmark_outline,
                    size: 18,
                    color: snippet.isSaved ? NVColors.primary : NVColors.onSurface.withOpacity(0.35),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 11,
          letterSpacing: 2,
          fontWeight: FontWeight.w700,
          color: NVColors.primary.withOpacity(0.7),
        ),
      );
}

class _EmptyResults extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: NVColors.surfaceContainer,
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Icon(Icons.terminal, color: NVColors.primary, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              'End of results for current filters.',
              style: TextStyle(color: NVColors.onSurface.withOpacity(0.4)),
            ),
          ],
        ),
      );
}
