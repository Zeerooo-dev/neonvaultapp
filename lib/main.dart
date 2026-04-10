import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'models/snippet.dart';
import 'services/storage_service.dart';
import 'screens/library_screen.dart';
import 'screens/saved_screen.dart';
import 'screens/tags_screen.dart';
import 'screens/add_screen.dart';
import 'widgets/shared_widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF131d22),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const NeonVaultApp());
}

class NeonVaultApp extends StatelessWidget {
  const NeonVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeonVault',
      debugShowCheckedModeBanner: false,
      theme: NVTheme.dark,
      home: const RootScreen(),
    );
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _navIndex = 0;
  List<Snippet> _snippets = [];
  bool _loading = true;
  String? _vaultPath;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final snippets = await StorageService.loadAll();
    final path = await StorageService.getVaultPath();
    if (mounted) {
      setState(() {
        _snippets = snippets;
        _vaultPath = path;
        _loading = false;
      });
      // Show vault path notification on first load
      _showVaultInfo(path);
    }
  }

  void _showVaultInfo(String path) {
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📁 NeonVault folder created',
                style: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                path,
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.6),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          backgroundColor: NVColors.surfaceContainerHigh,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          duration: const Duration(seconds: 4),
        ),
      );
    });
  }

  Future<void> _updateSnippet(Snippet updated) async {
    setState(() {
      final idx = _snippets.indexWhere((s) => s.id == updated.id);
      if (idx >= 0) _snippets[idx] = updated;
    });
    await StorageService.saveAll(_snippets);
  }

  Future<void> _deleteSnippet(String id) async {
    setState(() => _snippets.removeWhere((s) => s.id == id));
    await StorageService.saveAll(_snippets);
  }

  Future<void> _addSnippet(Snippet snippet) async {
    setState(() => _snippets.insert(0, snippet));
    await StorageService.saveAll(_snippets);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: NVColors.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'NeonVault',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontWeight: FontWeight.w800,
                  fontSize: 36,
                  color: NVColors.primaryLight,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: NVColors.primary.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading vault...',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 13,
                  color: NVColors.onSurface.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: NVColors.surface,
      body: IndexedStack(
        index: _navIndex,
        children: [
          LibraryScreen(
            snippets: _snippets,
            onSnippetUpdated: _updateSnippet,
            onSnippetDeleted: _deleteSnippet,
            onSnippetAdded: _addSnippet,
          ),
          SavedScreen(
            snippets: _snippets,
            onSnippetUpdated: _updateSnippet,
            onSnippetDeleted: _deleteSnippet,
          ),
          TagsScreen(
            snippets: _snippets,
            onSnippetUpdated: _updateSnippet,
          ),
          AddScreen(),
        ],
      ),
      bottomNavigationBar: NVBottomNav(
        currentIndex: _navIndex == 3 ? 3 : _navIndex,
        onTap: (i) {
          if (i == 3) {
            // Navigate to add screen as a full route
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddScreen()),
            ).then((result) {
              if (result is Snippet) _addSnippet(result);
            });
          } else {
            setState(() => _navIndex = i);
          }
        },
      ),
    );
  }
}
