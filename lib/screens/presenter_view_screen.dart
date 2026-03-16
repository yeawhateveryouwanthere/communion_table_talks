import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/presentation.dart';

/// A teleprompter-style view for presenting at the Lord's Table.
///
/// Shows large white text on a black background, designed to be
/// readable without glasses. The screen stays awake and hides
/// system UI to minimize distractions.
class PresenterViewScreen extends StatefulWidget {
  final Presentation presentation;

  const PresenterViewScreen({
    super.key,
    required this.presentation,
  });

  @override
  State<PresenterViewScreen> createState() => _PresenterViewScreenState();
}

class _PresenterViewScreenState extends State<PresenterViewScreen> {
  double _fontSize = 28.0;
  static const double _minFontSize = 20.0;
  static const double _maxFontSize = 44.0;
  static const double _fontSizeStep = 4.0;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    // Keep screen awake and go immersive
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // Lock to portrait so text doesn't reflow while presenting
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    // Restore normal system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([]);
    super.dispose();
  }

  void _increaseFontSize() {
    setState(() {
      _fontSize = (_fontSize + _fontSizeStep).clamp(_minFontSize, _maxFontSize);
    });
  }

  void _decreaseFontSize() {
    setState(() {
      _fontSize = (_fontSize - _fontSizeStep).clamp(_minFontSize, _maxFontSize);
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Main scrollable content
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  24,
                  _showControls ? 72 : 24,
                  24,
                  80,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Scripture reference
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Colors.white.withOpacity(0.4),
                            width: 3,
                          ),
                        ),
                      ),
                      child: Text(
                        widget.presentation.scripturePassage,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: _fontSize * 0.65,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                    SizedBox(height: _fontSize * 1.2),

                    // Body text — large, clear, white
                    ..._buildPresenterParagraphs(),
                  ],
                ),
              ),
            ),

            // Top controls bar — tap anywhere to toggle
            if (_showControls)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black,
                        Colors.black.withOpacity(0.0),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 4, 8, 16),
                      child: Row(
                        children: [
                          // Close button
                          IconButton(
                            icon: const Icon(Icons.close,
                                color: Colors.white, size: 26),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Spacer(),
                          // Font size controls
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.text_decrease,
                                      color: Colors.white, size: 20),
                                  onPressed: _fontSize > _minFontSize
                                      ? _decreaseFontSize
                                      : null,
                                  visualDensity: VisualDensity.compact,
                                  disabledColor: Colors.white.withOpacity(0.2),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8),
                                  child: Text(
                                    '${_fontSize.round()}',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.text_increase,
                                      color: Colors.white, size: 20),
                                  onPressed: _fontSize < _maxFontSize
                                      ? _increaseFontSize
                                      : null,
                                  visualDensity: VisualDensity.compact,
                                  disabledColor: Colors.white.withOpacity(0.2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Bottom hint — fades out
            if (_showControls)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black,
                        Colors.black.withOpacity(0.0),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(0, 24, 0, 16),
                  child: Center(
                    child: Text(
                      'Tap anywhere to hide controls',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Parse the HTML body text into large white paragraphs
  /// with bold/italic support.
  List<Widget> _buildPresenterParagraphs() {
    final paragraphs = widget.presentation.bodyText
        .split(RegExp(r'</?p>'))
        .where((s) => s.trim().isNotEmpty)
        .toList();

    return paragraphs.asMap().entries.map((entry) {
      final index = entry.key;
      final paragraph = entry.value.trim();

      return Padding(
        padding: EdgeInsets.only(
          bottom: index < paragraphs.length - 1 ? _fontSize * 0.8 : 0,
        ),
        child: _buildRichParagraph(paragraph),
      );
    }).toList();
  }

  Widget _buildRichParagraph(String html) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'<(/?)(em|strong|b|i)>');
    bool isBold = false;
    bool isItalic = false;

    int lastEnd = 0;
    for (final match in regex.allMatches(html)) {
      if (match.start > lastEnd) {
        final text = _cleanHtml(html.substring(lastEnd, match.start));
        if (text.isNotEmpty) {
          spans.add(TextSpan(
            text: text,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            ),
          ));
        }
      }

      final isClosing = match.group(1) == '/';
      final tag = match.group(2);

      if (tag == 'strong' || tag == 'b') {
        isBold = !isClosing;
      } else if (tag == 'em' || tag == 'i') {
        isItalic = !isClosing;
      }

      lastEnd = match.end;
    }

    if (lastEnd < html.length) {
      final text = _cleanHtml(html.substring(lastEnd));
      if (text.isNotEmpty) {
        spans.add(TextSpan(
          text: text,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
          ),
        ));
      }
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: Colors.white,
          fontSize: _fontSize,
          height: 1.6,
          fontWeight: FontWeight.w400,
        ),
        children:
            spans.isEmpty ? [TextSpan(text: _cleanHtml(html))] : spans,
      ),
    );
  }

  String _cleanHtml(String text) {
    return text
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
  }
}
