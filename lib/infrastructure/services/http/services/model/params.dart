class Params {
  final String? baseUrl;
  final bool requiredToken;
  final bool requiredRemote;
  final Duration? cacheDuration;

  Params({
    required this.baseUrl,
    required this.requiredToken,
    required this.requiredRemote,
    required this.cacheDuration,
  });

  @override
  bool operator ==(covariant Params other) {
    if (identical(this, other)) return true;

    return other.baseUrl == baseUrl &&
        other.requiredToken == requiredToken &&
        other.requiredRemote == requiredRemote &&
        other.cacheDuration == cacheDuration;
  }

  @override
  int get hashCode {
    return baseUrl.hashCode ^
        requiredToken.hashCode ^
        requiredRemote.hashCode ^
        cacheDuration.hashCode;
  }
}
