import 'package:flutter/material.dart';

import '../app.dart';
import '../models/analysis_result.dart';
import '../services/safety_simulator.dart';

class SafetySimulatorScreen extends StatelessWidget {
  const SafetySimulatorScreen({super.key, required this.analysis});

  final AnalysisResult analysis;

  @override
  Widget build(BuildContext context) {
    final scenarios = generateSafetyScenarios(analysis);
    return Scaffold(
      appBar: AppBar(title: const Text('QR Safety Simulator')),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: scenarios.length + 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _DisclaimerCard();
            }
            if (index == scenarios.length + 1) {
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'No QR code is executed and no website is opened by this simulator.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: QRGuardTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
              );
            }
            final scenario = scenarios[index - 1];
            return Card(
              margin: const EdgeInsets.only(top: 16),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Detected warning', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: QRGuardTheme.caution)),
                  const SizedBox(height: 6),
                  Text(scenario.detectedWarning, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 18),
                  Text('Possible scenario', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: QRGuardTheme.teal)),
                  const SizedBox(height: 6),
                  Text(scenario.possibleScenario),
                  const SizedBox(height: 18),
                  Text('Potential consequences', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: QRGuardTheme.highRisk)),
                  const SizedBox(height: 6),
                  Text(scenario.consequences),
                  const SizedBox(height: 18),
                  Text('Recommended precautions', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: QRGuardTheme.safe)),
                  const SizedBox(height: 8),
                  ...scenario.precautions.map((precaution) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('• $precaution'),
                      )),
                ]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DisclaimerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.info_outline_rounded, color: QRGuardTheme.caution),
          const SizedBox(width: 12),
          Expanded(child: Text(
            'These scenarios are hypothetical educational examples based on detected rules. They do not prove that this URL is malicious or that any consequence has occurred.',
            style: Theme.of(context).textTheme.bodyMedium,
          )),
        ]),
      ),
    );
  }
}
