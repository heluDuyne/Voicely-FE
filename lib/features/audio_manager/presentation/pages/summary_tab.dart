import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../../domain/entities/audio_file.dart';

class SummaryTab extends StatefulWidget {
  final AudioFile audioFile;
  final bool hasSummary;
  final bool enabled;
  final VoidCallback onChanged;
  final VoidCallback? onSaved;

  const SummaryTab({
    super.key,
    required this.audioFile,
    required this.hasSummary,
    required this.enabled,
    required this.onChanged,
    this.onSaved,
  });

  @override
  State<SummaryTab> createState() => _SummaryTabState();
}

class _SummaryTabState extends State<SummaryTab> {
  late quill.QuillController _controller;
  late String _initialContent;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void dispose() {
    _controller.removeListener(_onContentChanged);
    _controller.dispose();
    super.dispose();
  }

  void _initializeController() {
    final summaryText = widget.audioFile.summary ?? '';
    if (widget.hasSummary && summaryText.trim().isNotEmpty) {
      final doc = quill.Document()..insert(0, summaryText);
      _controller = quill.QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
    } else {
      _controller = quill.QuillController.basic();
    }
    _initialContent = _getDocumentContent();
    _controller.addListener(_onContentChanged);
  }

  String _getDocumentContent() {
    return _controller.document.toPlainText().trim();
  }

  void _onContentChanged() {
    if (_getDocumentContent() != _initialContent) {
      widget.onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    if (!widget.enabled) {
      return _buildDisabledView();
    }

    if (!widget.hasSummary) {
      return _buildNoSummaryView();
    }

    return Column(
      children: [
        if (!isKeyboardVisible)
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: quill.QuillToolbar.simple(
              configurations: quill.QuillSimpleToolbarConfigurations(
                controller: _controller,
                sharedConfigurations: const quill.QuillSharedConfigurations(),
              ),
            ),
          ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF101822),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: quill.QuillEditor.basic(
                configurations: quill.QuillEditorConfigurations(
                  controller: _controller,
                  sharedConfigurations:
                      const quill.QuillSharedConfigurations(),
                  placeholder: 'Summary content...',
                ),
              ),
            ),
          ),
        ),
        if (!isKeyboardVisible)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF101822),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Save Summary'),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDisabledView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 80, color: Colors.grey[500]),
            const SizedBox(height: 24),
            const Text(
              'Summary Not Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Please transcribe the audio first before generating a summary.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSummaryView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.summarize, size: 80, color: Colors.grey[500]),
            const SizedBox(height: 24),
            const Text(
              'No Summary Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'This audio has not been summarized yet. Click the button below to generate a summary.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _handleGenerateSummary,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate Summary'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleGenerateSummary() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating summary...')),
    );
  }

  void _handleSave() {
    _initialContent = _getDocumentContent();
    widget.onSaved?.call();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Summary saved successfully')),
    );
  }
}
