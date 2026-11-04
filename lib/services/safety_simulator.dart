import '../models/analysis_result.dart';
import '../models/safety_scenario.dart';

List<SafetyScenario> generateSafetyScenarios(AnalysisResult analysis) {
  final warnings = analysis.findings.where((finding) => finding.isWarning).toList();
  if (warnings.isEmpty) {
    return const [
      SafetyScenario(
        detectedWarning: 'No configured warning indicators detected',
        possibleScenario: 'No specific attack scenario is inferred because QRGuard did not match a configured warning. Continue to examine the exact domain and context.',
        consequences: 'Even ordinary links can lead to unexpected content; a clean rule-based result does not establish a website’s reputation or safety.',
        precautions: [
          'Verify the displayed domain before continuing.',
          'Avoid entering credentials or payment information on unfamiliar sites.',
          'Keep QRGuard rule-based results separate from definitive security guarantees.',
        ],
      ),
    ];
  }

  final scenarios = <SafetyScenario>[];
  for (final finding in warnings) {
    final title = finding.title.toLowerCase();
    if (title.contains('wording') || title.contains('credential') || title.contains('urgent')) {
      scenarios.add(SafetyScenario(
        detectedWarning: finding.title,
        possibleScenario: 'A deceptive website could imitate a legitimate login page and try to collect account credentials. The wording detection suggests urgency, but does not prove that an account-action request is malicious.',
        consequences: 'If real credentials were entered, an attacker could hypothetically misuse them to access an account or attempt reuse against other services.',
        precautions: const ['Verify the official domain independently.', 'Do not enter credentials after following a QR link.', 'Open the organization’s known website directly instead.'],
      ));
    } else if (title.contains('brand') || finding.description.toLowerCase().contains('brand')) {
      scenarios.add(SafetyScenario(
        detectedWarning: finding.title,
        possibleScenario: 'A page could imitate a familiar brand and display a misleading affiliation or login prompt, relying on the recognizable brand name to gain trust.',
        consequences: 'A user might share credentials, personal data, payment details or accept unintended permissions if a hypothetical imitation page were visited.',
        precautions: const ['Compare the complete domain with the organization’s official address.', 'Navigate from a trusted bookmark or app instead of the QR link.', 'Treat brand names alone as insufficient proof of authenticity.'],
      ));
    } else if (title.contains('shortener')) {
      scenarios.add(SafetyScenario(
        detectedWarning: finding.title,
        possibleScenario: 'A shortened link could hide its final destination behind a redirect, potentially routing a user to a page that behaves differently from what they expect.',
        consequences: 'The hidden destination could request sensitive information or display unexpected content, even though this finding alone does not prove an attack.',
        precautions: const ['Inspect the destination through a trusted redirect-checking service when appropriate.', 'Do not submit personal information if the destination is unexpected.', 'Ask the sender to provide the direct domain.'],
      ));
    } else if (title.contains('ip-based')) {
      scenarios.add(SafetyScenario(
        detectedWarning: finding.title,
        possibleScenario: 'An address could point directly to an IP-based server, where the visible identity and ownership of the destination are less immediately clear than with a named domain.',
        consequences: 'Unexpected infrastructure could collect submitted information or serve content unrelated to the expected service. QRGuard cannot verify ownership from the address alone.',
        precautions: const ['Confirm why an IP address was used.', 'Verify the destination through an independent trusted source.', 'Avoid entering credentials or payment information.'],
      ));
    } else if (title.contains('http') || finding.description.toLowerCase().contains('http does not encrypt')) {
      scenarios.add(SafetyScenario(
        detectedWarning: finding.title,
        possibleScenario: 'An unencrypted HTTP connection could allow network observers or intermediaries to inspect ordinary page data while it travels between the device and server.',
        consequences: 'Entered information could be exposed during transmission, especially on untrusted networks. This does not establish that the destination itself is malicious.',
        precautions: const ['Prefer a verified HTTPS version of the destination.', 'Do not submit passwords, payment details or private data over HTTP.', 'Avoid sensitive browsing on an untrusted network.'],
      ));
    } else if (title.contains('structure') ||
        title.contains('formatting') ||
        title.contains('user-info') ||
        title.contains('unicode')) {
      scenarios.add(SafetyScenario(
        detectedWarning: finding.title,
        possibleScenario: 'A carefully formatted hostname could visually resemble a trusted domain while resolving to a different owner or use unusual authority text to hide the actual destination.',
        consequences: 'A user might mistakenly trust the display or enter information into an unintended site. The formatting can contribute to deception without proving malicious ownership.',
        precautions: const ['Inspect the complete hostname character by character.', 'Watch for lookalike letters, Punycode and text before @.', 'Use the organization’s known app, bookmark or typed domain.'],
      ));
    }
  }

  return scenarios.isEmpty
      ? [
          SafetyScenario(
            detectedWarning: warnings.first.title,
            possibleScenario: 'QRGuard matched an unusual indicator, but this rule does not map to a predefined fictional scenario. The exact warning remains educational and separate from a confirmed threat.',
            consequences: 'No specific outcome can be attributed solely from this finding; possible effects depend on what the destination actually does.',
            precautions: const ['Review the exact warning and decoded URL.', 'Verify the destination independently.', 'Do not submit sensitive information without confidence in the destination.'],
          ),
        ]
      : scenarios;
}
