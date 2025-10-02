import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  String transcribedText = "";
  String? selectedFilePath;

  void transcribeAudio() {
    // TODO: Implement logic to transcribe audio file
    setState(() {
      transcribedText = "Transcribed text will appear here.";
    });
  }

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFilePath = result.files.single.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Screen')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: transcribeAudio,
              child: const Text('Transcript'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickFile,
              child: const Text('Pick File'),
            ),
            const SizedBox(height: 16),
            if (selectedFilePath != null)
              Text('Selected File: $selectedFilePath'),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: transcribedText),
              maxLines: null,
              readOnly: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Transcribed Text',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
