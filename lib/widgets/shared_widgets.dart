import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../models/snippet.dart';

// ─── Bottom Nav Bar ───────────────────────────────────────────────────────────
class NVBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const NVBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: NVColors.surfaceContainer.withOpacity(0.85),
        border: Border(
          top: BorderSide(color: NVColors.outline.withOpacity(0.1)),
        ),
        boxShadow: [
          BoxShadow(
            color: NVColors.onSurface.withOpacity(0.04),
            blurRadius: 40,
            offset: const Offset(0, -20),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.inventory_2_outlined, label: 'LIBRARY', index: 0, current: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.bookmark_outline, label: 'SAVED', index: 1, current: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.sell_outlined, label: 'TAGS', index: 2, current: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.add_box_outlined, label: 'ADD', index: 3, current: currentIndex, onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int current;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isActive ? NVColors.primaryLight : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? NVColors.primaryLight : NVColors.onSurface.withOpacity(0.4),
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 9,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
                color: isActive ? NVColors.primaryLight : NVColors.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Snippet Card ─────────────────────────────────────────────────────────────
class SnippetCard extends StatefulWidget {
  final Snippet snippet;
  final VoidCallback onTap;
  final VoidCallback onBookmark;
  final VoidCallback onCopy;

  const SnippetCard({
    super.key,
    required this.snippet,
    required this.onTap,
    required this.onBookmark,
    required this.onCopy,
  });

  @override
  State<SnippetCard> createState() => _SnippetCardState();
}

class _SnippetCardState extends State<SnippetCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverCtrl;
  late Animation<double> _elevAnim;

  @override
  void initState() {
    super.initState();
    _hoverCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _elevAnim = Tween<double>(begin: 0, end: -4).animate(
      CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _hoverCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _elevAnim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _elevAnim.value),
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) => _hoverCtrl.forward(),
        onTapUp: (_) {
          _hoverCtrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _hoverCtrl.reverse(),
        child: Container(
          decoration: BoxDecoration(
            color: NVColors.surfaceContainer,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: NVColors.outline.withOpacity(0.1),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: NVColors.secondary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _iconForLang(widget.snippet.language),
                      color: NVColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.snippet.title,
                          style: const TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.snippet.timeAgo.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 10,
                            letterSpacing: 1.2,
                            color: NVColors.primaryLight.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onBookmark,
                    child: Icon(
                      widget.snippet.isSaved
                          ? Icons.bookmark
                          : Icons.bookmark_outline,
                      color: widget.snippet.isSaved
                          ? NVColors.primary
                          : NVColors.onSurface.withOpacity(0.3),
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Code Preview
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF050b0e),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: NVColors.outline.withOpacity(0.06),
                  ),
                ),
                child: Text(
                  widget.snippet.code.split('\n').take(2).join('\n'),
                  style: const TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 12,
                    color: Color(0xFFD9E4EB),
                    height: 1.6,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.fade,
                ),
              ),
              const SizedBox(height: 14),
              // Footer
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: NVColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: NVTheme.langColor(widget.snippet.language),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.snippet.language,
                          style: const TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 11,
                            color: NVColors.primaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: widget.onCopy,
                    child: Icon(Icons.copy_outlined,
                        color: NVColors.onSurface.withOpacity(0.35), size: 18),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.share_outlined,
                      color: NVColors.onSurface.withOpacity(0.35), size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForLang(String lang) {
    switch (lang.toLowerCase()) {
      case 'python': return Icons.data_object;
      case 'javascript':
      case 'typescript': return Icons.terminal;
      case 'swift':
      case 'kotlin': return Icons.phone_android;
      case 'css':
      case 'html': return Icons.palette;
      case 'dart': return Icons.flutter_dash;
      default: return Icons.code;
    }
  }
}

// ─── Language Chip ────────────────────────────────────────────────────────────
class LangChip extends StatelessWidget {
  final String language;
  final bool selected;
  final VoidCallback onTap;

  const LangChip({
    super.key,
    required this.language,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? NVColors.secondary.withOpacity(0.25) : NVColors.surfaceContainer,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected ? NVColors.primary.withOpacity(0.4) : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: NVTheme.langColor(language),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              language,
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? NVColors.primaryLight : NVColors.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tag Chip ─────────────────────────────────────────────────────────────────
class TagChip extends StatelessWidget {
  final String tag;
  final VoidCallback? onDelete;

  const TagChip({super.key, required this.tag, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 10,
        right: onDelete != null ? 4 : 10,
        top: 4,
        bottom: 4,
      ),
      decoration: BoxDecoration(
        color: NVColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: NVColors.outline.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: const TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 12,
              color: NVColors.primary,
            ),
          ),
          if (onDelete != null) ...[
            const SizedBox(width: 2),
            GestureDetector(
              onTap: onDelete,
              child: Icon(Icons.close, size: 14, color: NVColors.primary.withOpacity(0.6)),
            ),
          ],
        ],
      ),
    );
  }
}
