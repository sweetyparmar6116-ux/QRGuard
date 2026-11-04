enum RiskLevel { low, medium, high }

class Finding {
	const Finding({
		required this.title,
		required this.description,
		this.isWarning = true,
	});

	final String title;
	final String description;
	final bool isWarning;
}

class AnalysisResult {
	const AnalysisResult({
		required this.input,
		required this.isValidUrl,
		required this.riskLevel,
		required this.summary,
		required this.findings,
	});

	final String input;
	final bool isValidUrl;
	final RiskLevel riskLevel;
	final String summary;
	final List<Finding> findings;
}
