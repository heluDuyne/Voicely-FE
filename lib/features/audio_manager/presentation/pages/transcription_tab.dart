import 'package:flutter/material.dart';
import '../../domain/entities/audio_file.dart';

class TranscriptionTab extends StatefulWidget {
  final AudioFile audioFile;
  final bool hasTranscript;
  final VoidCallback onChanged;
  final VoidCallback? onSaved;

  const TranscriptionTab({
    super.key,
    required this.audioFile,
    required this.hasTranscript,
    required this.onChanged,
    this.onSaved,
  });

  @override
  State<TranscriptionTab> createState() => _TranscriptionTabState();
}

class _TranscriptionTabState extends State<TranscriptionTab> {
  late final TextEditingController _controller;
  late String _initialText;

  @override
  void initState() {
    super.initState();
    _initialText = widget.audioFile.transcription ?? '';
    _controller = TextEditingController(text: _initialText);
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_controller.text != _initialText) {
      widget.onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    if (!widget.hasTranscript) {
      return _buildNoTranscriptView();
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              maxLines: null,
              style: const TextStyle(fontSize: 16, height: 1.5),
              decoration: const InputDecoration(
                hintText: 'Transcript content...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(16),
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
                  child: const Text('Save Transcript'),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNoTranscriptView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 80,
              color: Colors.grey[500],
            ),
            const SizedBox(height: 24),
            const Text(
              'No Transcript Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'This audio has not been transcribed yet. Click the button below to start transcription.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _handleTranscribe,
              icon: const Icon(Icons.mic_none),
              label: const Text('Transcribe Audio'),
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

  void _handleTranscribe() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transcription started...')),
    );
  }

  void _handleSave() {
    _initialText = _controller.text;
    widget.onSaved?.call();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transcript saved successfully')),
    );
  }
}
