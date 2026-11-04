import 'package:flutter/material.dart';

import '../app.dart';
import '../services/url_analyzer.dart';
import 'result_screen.dart';

class ManualUrlScreen extends StatefulWidget {
  const ManualUrlScreen({super.key});

  @override
  State<ManualUrlScreen> createState() => _ManualUrlScreenState();
}

class _ManualUrlScreenState extends State<ManualUrlScreen> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _submitting = false;
  String? _submissionError;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validateUrl(String? value) {
    if ((value?.trim() ?? '').isEmpty) return 'Enter a URL to analyze.';
    return null;
  }

  Future<void> _analyze() async {
    if (_submitting || !(_formKey.currentState?.validate() ?? false)) return;

    final input = _controller.text.trim();
    final analysis = analyzeUrl(input);
    if (!analysis.isValidUrl) {
      setState(() {
        _submissionError = analysis.findings.first.description;
      });
      return;
    }

    setState(() {
      _submissionError = null;
      _submitting = true;
    });
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ResultScreen(
          decodedContent: input,
          analysisOverride: analysis,
          returnLabel: 'Back to manual analysis',
        ),
      ),
    );
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analyze URL')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.link_rounded, size: 48, color: QRGuardTheme.teal),
                const SizedBox(height: 16),
                Text(
                  'Manual URL Analysis',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Paste a website address to review its local security indicators without opening it.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: QRGuardTheme.textSecondary,
                        height: 1.45,
                      ),
                  textAlign: TextAlign.center,
                ),
                if (_submissionError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _submissionError!,
                    key: const Key('manual-url-error'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: QRGuardTheme.highRisk,
                        ),
                  ),
                ],
                const SizedBox(height: 28),
                TextFormField(
                  controller: _controller,
                  enabled: !_submitting,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                  autocorrect: false,
                  maxLines: 3,
                  minLines: 1,
                  onFieldSubmitted: (_) => _analyze(),
                  validator: _validateUrl,
                  decoration: const InputDecoration(
                    labelText: 'URL',
                    hintText: 'https://example.com',
                    prefixIcon: Icon(Icons.language_rounded),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  key: const Key('manual-analyze-button'),
                  onPressed: _submitting ? null : _analyze,
                  icon: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.security_rounded),
                  label: Text(_submitting ? 'Analyzing...' : 'Analyze URL'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
