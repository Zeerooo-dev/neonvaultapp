import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../models/snippet.dart';

class StorageService {
  static const String _folderName = 'NeonVault';
  static const String _indexFile = 'snippets_index.json';

  static Future<Directory> getVaultDirectory() async {
    Directory baseDir;
    if (Platform.isAndroid) {
      // Use external storage for Android so it's accessible in file manager
      final dirs = await getExternalStorageDirectories();
      baseDir = dirs != null && dirs.isNotEmpty
          ? dirs.first
          : await getApplicationDocumentsDirectory();
    } else if (Platform.isIOS) {
      baseDir = await getApplicationDocumentsDirectory();
    } else {
      baseDir = await getApplicationDocumentsDirectory();
    }

    final vaultDir = Directory('${baseDir.path}/$_folderName');
    if (!await vaultDir.exists()) {
      await vaultDir.create(recursive: true);
    }
    return vaultDir;
  }

  static Future<String> getVaultPath() async {
    final dir = await getVaultDirectory();
    return dir.path;
  }

  static Future<List<Snippet>> loadAll() async {
    try {
      final dir = await getVaultDirectory();
      final indexFile = File('${dir.path}/$_indexFile');

      if (!await indexFile.exists()) {
        // Seed with sample snippets on first launch
        final samples = _sampleSnippets();
        await saveAll(samples);
        return samples;
      }

      final content = await indexFile.readAsString();
      final List<dynamic> jsonList = jsonDecode(content);
      return jsonList.map((j) => Snippet.fromJson(j)).toList();
    } catch (e) {
      return _sampleSnippets();
    }
  }

  static Future<void> saveAll(List<Snippet> snippets) async {
    final dir = await getVaultDirectory();
    final indexFile = File('${dir.path}/$_indexFile');
    final jsonStr = jsonEncode(snippets.map((s) => s.toJson()).toList());
    await indexFile.writeAsString(jsonStr);

    // Also save each snippet as an individual .txt file for easy access
    for (final snippet in snippets) {
      final ext = _extForLanguage(snippet.language);
      final safeTitle = snippet.title.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
      final snippetFile = File('${dir.path}/${safeTitle}_${snippet.id.substring(0, 6)}$ext');
      await snippetFile.writeAsString(snippet.code);
    }
  }

  static Future<void> save(Snippet snippet, List<Snippet> allSnippets) async {
    final idx = allSnippets.indexWhere((s) => s.id == snippet.id);
    if (idx >= 0) {
      allSnippets[idx] = snippet;
    } else {
      allSnippets.insert(0, snippet);
    }
    await saveAll(allSnippets);
  }

  static Future<void> delete(String id, List<Snippet> allSnippets) async {
    allSnippets.removeWhere((s) => s.id == id);
    await saveAll(allSnippets);
  }

  static Future<void> deleteSnippetFile(Snippet snippet) async {
    try {
      final dir = await getVaultDirectory();
      final ext = _extForLanguage(snippet.language);
      final safeTitle = snippet.title.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
      final snippetFile = File('${dir.path}/${safeTitle}_${snippet.id.substring(0, 6)}$ext');
      if (await snippetFile.exists()) {
        await snippetFile.delete();
      }
    } catch (_) {
      // Best-effort file deletion
    }
  }

  static String _extForLanguage(String lang) {
    switch (lang.toLowerCase()) {
      case 'python': return '.py';
      case 'javascript': return '.js';
      case 'typescript': return '.ts';
      case 'dart': return '.dart';
      case 'swift': return '.swift';
      case 'rust': return '.rs';
      case 'go': return '.go';
      case 'css': return '.css';
      case 'html': return '.html';
      case 'kotlin': return '.kt';
      default: return '.txt';
    }
  }

  static List<Snippet> _sampleSnippets() {
    final now = DateTime.now();
    return [
      Snippet(
        id: 'sample-001',
        title: 'FastAPI Auth Middleware',
        code: '''@app.middleware("http")
async def add_process_time_header(
    request: Request, 
    call_next
):
    start_time = time.time()
    response = await call_next(request)
    process_time = time.time() - start_time
    response.headers["X-Process-Time"] = str(process_time)
    return response''',
        language: 'Python',
        tags: ['#backend', '#auth', '#fastapi'],
        isSaved: true,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        copyCount: 14,
      ),
      Snippet(
        id: 'sample-002',
        title: 'Debounce Function',
        code: '''const debounce = (fn, delay) => {
  let timeoutId;
  return (...args) => {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => {
      fn.apply(this, args);
    }, delay);
  };
};

// Usage:
const search = debounce(fetchResults, 300);''',
        language: 'JavaScript',
        tags: ['#utility', '#performance'],
        isSaved: false,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(hours: 5)),
        copyCount: 28,
      ),
      Snippet(
        id: 'sample-003',
        title: 'Glassmorphism Preset',
        code: '''.glass {
  backdrop-filter: blur(16px) saturate(180%);
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.15);
  border-radius: 16px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
}''',
        language: 'CSS',
        tags: ['#ui', '#design', '#glass'],
        isSaved: true,
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 1)),
        copyCount: 42,
      ),
      Snippet(
        id: 'sample-004',
        title: 'Supabase Auth Provider',
        code: '''import { createContext, useContext, useState, useEffect } from 'react';
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
);

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);

  useEffect(() => {
    const { data: authListener } =
      supabase.auth.onAuthStateChange((event, session) => {
        setUser(session?.user ?? null);
      });
    return () => authListener.subscription.unsubscribe();
  }, []);

  return (
    <AuthContext.Provider value={{ user }}>
      {children}
    </AuthContext.Provider>
  );
};''',
        language: 'TypeScript',
        tags: ['#auth', '#react', '#supabase'],
        isSaved: false,
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 2)),
        copyCount: 142,
      ),
      Snippet(
        id: 'sample-005',
        title: 'SwiftUI Glassmorphism',
        code: '''struct GlassyModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: 24)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(.white.opacity(0.15), lineWidth: 1)
            )
    }
}

extension View {
    func glassy() -> some View {
        modifier(GlassyModifier())
    }
}''',
        language: 'Swift',
        tags: ['#ui', '#ios', '#swiftui'],
        isSaved: true,
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(days: 1)),
        copyCount: 33,
      ),
    ];
  }
}
