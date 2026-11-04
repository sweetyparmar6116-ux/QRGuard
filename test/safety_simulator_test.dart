import 'package:flutter_test/flutter_test.dart';
import 'package:madl_project/models/analysis_result.dart';
import 'package:madl_project/services/safety_simulator.dart';

Finding warning(String title, String description) => Finding(title: title, description: description);
AnalysisResult result(List<Finding> findings) => AnalysisResult(
      input: 'https://example.test',
      isValidUrl: true,
      riskLevel: findings.isEmpty ? RiskLevel.low : RiskLevel.medium,
      summary: 'test',
      findings: findings,
    );

void main() {
  test('credential wording scenario is educational', () {
    final scenarios = generateSafetyScenarios(result([warning('Potentially deceptive wording', 'Urgent verification requested')]));
    expect(scenarios.single.detectedWarning, 'Potentially deceptive wording');
    expect(scenarios.single.possibleScenario.toLowerCase(), contains('login'));
    expect(scenarios.single.consequences.toLowerCase(), contains('credentials'));
  });

  test('misleading brand scenario is generated', () {
    final scenarios = generateSafetyScenarios(result([warning('Deceptive or unusual URL structure', 'A paypal brand appears outside the brand domain')]));
    expect(scenarios.single.possibleScenario.toLowerCase(), contains('brand'));
  });

  test('shortener destination scenario is generated', () {
    final scenarios = generateSafetyScenarios(result([warning('URL shortener', 'Destination is hidden')]));
    expect(scenarios.single.possibleScenario.toLowerCase(), contains('redirect'));
  });

  test('IP address scenario is generated', () {
    final scenarios = generateSafetyScenarios(result([warning('IP-based host', 'Uses a numeric address')]));
    expect(scenarios.single.possibleScenario.toLowerCase(), contains('ip'));
  });

  test('unencrypted HTTP scenario is generated', () {
    final scenarios = generateSafetyScenarios(result([warning('Unencrypted HTTP', 'HTTP does not encrypt')]));
    expect(scenarios.single.possibleScenario.toLowerCase(), contains('unencrypted'));
  });

  test('suspicious structure scenario is generated', () {
    final scenarios = generateSafetyScenarios(result([warning('Misleading URL formatting', 'Authority uses an unusual structure')]));
    expect(scenarios.single.precautions.join(' '), contains('hostname'));
  });

  test('no warning produces safe-browsing education', () {
    final scenarios = generateSafetyScenarios(result([const Finding(
      title: 'HTTPS connection',
      description: 'HTTPS provides transport encryption.',
      isWarning: false,
    )]));

    expect(scenarios.single.detectedWarning, contains('No configured warning'));
    expect(scenarios.single.possibleScenario.toLowerCase(), contains('no specific attack'));
  });
}
