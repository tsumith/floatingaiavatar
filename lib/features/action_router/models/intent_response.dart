class IntentResponse {
  /// Spoken reply to the user
  final String response;

  /// action type (used by IntentRouter)
  final String? type;

  /// Action payload for FeatureModules
  final Map<String, dynamic> parameters;

  const IntentResponse({
    required this.response,
    this.type,
    required this.parameters,
  });

  factory IntentResponse.fromJson(Map<String, dynamic> json) {
    return IntentResponse(
      response: (json['response'] ?? '').toString(),
      type: json['type']?.toString(),
      parameters: _parseParameters(json['parameters']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'response': response,
      'type': type,
      'parameters': parameters,
    };
  }

  /// ------------------------------------------------------------
  /// Helpers
  /// ------------------------------------------------------------

  static Map<String, dynamic> _parseParameters(dynamic raw) {
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return <String, dynamic>{};
  }

  /// True if this response contains an executable action
  bool get hasAction => type != null && type!.isNotEmpty;

  @override
  String toString() {
    return 'IntentResponse(type: $type, response: "$response", parameters: $parameters)';
  }
}