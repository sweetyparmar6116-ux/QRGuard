class SafetyScenario {
  const SafetyScenario({
    required this.detectedWarning,
    required this.possibleScenario,
    required this.consequences,
    required this.precautions,
  });

  final String detectedWarning;
  final String possibleScenario;
  final String consequences;
  final List<String> precautions;
}
