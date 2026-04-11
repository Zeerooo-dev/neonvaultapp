/// Pure-Dart code formatter.
/// Applies language-specific indentation, brace/bracket spacing,
/// semicolon insertion, and whitespace normalisation — no external process needed.
class CodeFormatter {
  /// Entry point. Returns the formatted code string.
  static String format(String code, String language) {
    if (code.trim().isEmpty) return code;
    switch (language.toLowerCase()) {
      case 'javascript':
      case 'typescript':
        return _formatCStyle(code, semicolons: true, trailingCommas: true);
      case 'java':
      case 'c':
      case 'c++':
      case 'c#':
      case 'kotlin':
        return _formatCStyle(code, semicolons: true, trailingCommas: false);
      case 'dart':
        return _formatCStyle(code, semicolons: true, trailingCommas: true);
      case 'swift':
        return _formatCStyle(code, semicolons: false, trailingCommas: true);
      case 'go':
        return _formatCStyle(code, semicolons: false, trailingCommas: true);
      case 'rust':
        return _formatCStyle(code, semicolons: true, trailingCommas: true);
      case 'python':
        return _formatPython(code);
      case 'css':
        return _formatCss(code);
      case 'html':
        return _formatHtml(code);
      default:
        return _normaliseWhitespace(code);
    }
  }

  // ─── C-style formatter (JS/TS/Java/C/C++/C#/Dart/Swift/Go/Rust/Kotlin) ────

  static String _formatCStyle(
    String code, {
    required bool semicolons,
    required bool trailingCommas,
  }) {
    final lines = _splitLines(code);
    final result = <String>[];
    int indent = 0;
    const indentStr = '    '; // 4 spaces

    for (var i = 0; i < lines.length; i++) {
      var line = lines[i].trim();
      if (line.isEmpty) {
        // Collapse multiple blank lines into one
        if (result.isNotEmpty && result.last.trim().isNotEmpty) {
          result.add('');
        }
        continue;
      }

      // Decrease indent BEFORE printing if line starts with a closing brace
      final startsWithClose = line.startsWith('}') ||
          line.startsWith(')') ||
          line.startsWith(']');
      if (startsWithClose) indent = (indent - 1).clamp(0, 99);

      // Apply spacing fixes to the line itself
      line = _spaceBraces(line);
      line = _spaceOperators(line);
      line = _normaliseCommas(line);

      // Add semicolon if needed
      if (semicolons) line = _ensureSemicolon(line);

      result.add('${indentStr * indent}$line');

      // Increase indent AFTER printing if line ends with an open brace
      final endsWithOpen = line.endsWith('{') ||
          line.endsWith('(') ||
          line.endsWith('[');
      if (endsWithOpen) indent++;

      // Handle single-line blocks like `if (x) {` → `}`
      final openCount = '{(['.split('').fold(0, (n, c) => n + line.split(c).length - 1);
      final closeCount = '})]'.split('').fold(0, (n, c) => n + line.split(c).length - 1);
      if (openCount > closeCount) indent = (indent + (openCount - closeCount - (endsWithOpen ? 1 : 0))).clamp(0, 99);
      if (closeCount > openCount) indent = (indent - (closeCount - openCount - (startsWithClose ? 1 : 0))).clamp(0, 99);
    }

    return _collapseBlankLines(result.join('\n'));
  }

  // ─── Python formatter ────────────────────────────────────────────────────────

  static String _formatPython(String code) {
    final lines = _splitLines(code);
    final result = <String>[];
    int indent = 0;
    const indentStr = '    ';

    for (final raw in lines) {
      var line = raw.trimRight();
      final stripped = line.trimLeft();

      if (stripped.isEmpty) {
        if (result.isNotEmpty && result.last.trim().isNotEmpty) result.add('');
        continue;
      }

      // Detect dedent by counting leading spaces in original
      final originalIndent = line.length - stripped.length;
      final expectedIndent = indent * 4;

      // If the line is less indented than expected, adjust indent level
      if (originalIndent < expectedIndent) {
        indent = (originalIndent / 4).floor().clamp(0, 99);
      }

      var out = stripped;
      out = _spaceOperators(out);
      out = _normaliseCommas(out);

      result.add('${indentStr * indent}$out');

      // Increase indent after lines ending with :
      if (stripped.endsWith(':') &&
          !stripped.startsWith('#') &&
          !stripped.startsWith('"') &&
          !stripped.startsWith("'")) {
        indent++;
      }
    }

    return _collapseBlankLines(result.join('\n'));
  }

  // ─── CSS formatter ───────────────────────────────────────────────────────────

  static String _formatCss(String code) {
    // Expand to one-declaration-per-line
    final expanded = code
        .replaceAll(RegExp(r'\s*\{\s*'), ' {\n    ')
        .replaceAll(RegExp(r';\s*(?![\n])'), ';\n    ')
        .replaceAll(RegExp(r'\s*\}\s*'), '\n}\n');

    final lines = _splitLines(expanded);
    final result = <String>[];
    int indent = 0;

    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty) {
        if (result.isNotEmpty && result.last.trim().isNotEmpty) result.add('');
        continue;
      }
      if (line == '}') {
        indent = (indent - 1).clamp(0, 99);
        result.add('}');
        result.add('');
        continue;
      }
      result.add('${'    ' * indent}$line');
      if (line.endsWith('{')) indent++;
    }

    return _collapseBlankLines(result.join('\n')).trim();
  }

  // ─── HTML formatter ──────────────────────────────────────────────────────────

  static String _formatHtml(String code) {
    // Very basic: indent inside block-level tags
    const blockTags = ['html', 'head', 'body', 'div', 'section', 'article',
      'header', 'footer', 'nav', 'main', 'ul', 'ol', 'table', 'thead',
      'tbody', 'tr', 'form', 'script', 'style'];

    final tagPattern = RegExp(r'<(/?)(\w+)([^>]*)>');
    final lines = _splitLines(code);
    final result = <String>[];
    int indent = 0;

    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty) continue;

      // Check for closing tag at start
      final closingMatch = RegExp(r'^</(\w+)').firstMatch(line);
      if (closingMatch != null &&
          blockTags.contains(closingMatch.group(1)!.toLowerCase())) {
        indent = (indent - 1).clamp(0, 99);
      }

      result.add('${'    ' * indent}$line');

      // Check for opening tag (not self-closing)
      final openMatch = tagPattern.firstMatch(line);
      if (openMatch != null &&
          openMatch.group(1) != '/' &&
          !line.contains('/>') &&
          blockTags.contains(openMatch.group(2)!.toLowerCase())) {
        // Don't indent if the closing tag is on the same line
        if (!line.contains('</${openMatch.group(2)}')) {
          indent++;
        }
      }
    }

    return result.join('\n');
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  static List<String> _splitLines(String code) =>
      code.replaceAll('\r\n', '\n').split('\n');

  static String _normaliseWhitespace(String code) {
    return _collapseBlankLines(
      _splitLines(code).map((l) => l.trimRight()).join('\n'),
    );
  }

  static String _collapseBlankLines(String code) {
    return code.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
  }

  /// Add spaces around operators: = == != <= >= && || += -= etc.
  static String _spaceOperators(String line) {
    if (_isComment(line) || _isStringOnly(line)) return line;

    var out = line;
    // Already spaced operators should not double-space
    // Handle == != <= >= before = to avoid breaking them
    out = out.replaceAllMapped(
      RegExp(r'(?<![=!<>&|+\-*/])([=!<>+\-*/%&|]{1,2})(?!=)(?![=>&|])'),
      (m) {
        final op = m.group(1)!;
        // Skip -> => :: /** */ #
        if (op == '->' || op == '=>' || op == '::' || op == '*' && out.contains('/*')) return m.group(0)!;
        final before = out.substring(0, m.start);
        final after = out.substring(m.end);
        if (before.isNotEmpty && before[before.length - 1] != ' ') {
          return ' $op';
        }
        return m.group(0)!;
      },
    );

    // Ensure single space after keywords
    for (final kw in ['if', 'for', 'while', 'switch', 'return', 'else', 'catch']) {
      out = out.replaceAll(RegExp('\\b$kw\\('), '$kw (');
      out = out.replaceAll(RegExp('\\b$kw\\{'), '$kw {');
    }

    return out;
  }

  /// Ensure single space after commas
  static String _normaliseCommas(String line) {
    return line.replaceAll(RegExp(r',(?!\s)'), ', ');
  }

  /// Add a space before { and after }
  static String _spaceBraces(String line) {
    var out = line;
    out = out.replaceAll(RegExp(r'([^\s])\{'), r'$1 {');
    // Fix the replaceAllMapped approach for this
    out = out.replaceAllMapped(
      RegExp(r'([^\s])\{'),
      (m) => '${m.group(1)} {',
    );
    return out;
  }

  /// Add missing semicolons to lines that need them (heuristic)
  static String _ensureSemicolon(String line) {
    if (line.isEmpty) return line;
    if (_isComment(line)) return line;

    final last = line[line.length - 1];
    // Lines that should NOT get semicolons
    if (last == ';' || last == '{' || last == '}' ||
        last == ',' || last == '(' || last == ')' ||
        last == ':' || last == '\\') {
      return line;
    }
    // Decorator / annotation lines
    if (line.trimLeft().startsWith('@')) return line;
    // Preprocessor
    if (line.trimLeft().startsWith('#')) return line;
    // Import / export lines typically end with from '...' or just the path
    if (line.contains("import ") && (last == "'" || last == '"')) {
      return '$line;';
    }
    // Assignment, return, throw, const/var/let/final declarations
    final trimmed = line.trimLeft();
    if (trimmed.startsWith('return ') ||
        trimmed.startsWith('throw ') ||
        trimmed.startsWith('const ') ||
        trimmed.startsWith('var ') ||
        trimmed.startsWith('let ') ||
        trimmed.startsWith('final ') ||
        trimmed.startsWith('int ') ||
        trimmed.startsWith('String ') ||
        trimmed.startsWith('bool ') ||
        trimmed.startsWith('double ') ||
        trimmed.startsWith('float ') ||
        RegExp(r'^\w+\s*=\s*').hasMatch(trimmed)) {
      if (last != ';') return '$line;';
    }

    return line;
  }

  static bool _isComment(String line) {
    final t = line.trimLeft();
    return t.startsWith('//') || t.startsWith('*') || t.startsWith('/*') || t.startsWith('#');
  }

  static bool _isStringOnly(String line) {
    final t = line.trim();
    return (t.startsWith('"') && t.endsWith('"')) ||
        (t.startsWith("'") && t.endsWith("'")) ||
        (t.startsWith('`') && t.endsWith('`'));
  }
}
