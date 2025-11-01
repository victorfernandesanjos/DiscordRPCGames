/// Model for a game profile with process name and icon URL
class GameProfile {
  final String id;
  final String processName;
  final String displayName;
  final String? iconUrl;
  final String? largeImageKey;
  final String? largeImageText;
  final String? smallImageKey;
  final String? smallImageText;
  final String? details;
  final String? state;
  final bool enabled;

  GameProfile({
    required this.id,
    required this.processName,
    required this.displayName,
    this.iconUrl,
    this.largeImageKey,
    this.largeImageText,
    this.smallImageKey,
    this.smallImageText,
    this.details,
    this.state,
    this.enabled = true,
  });

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'processName': processName,
      'displayName': displayName,
      'iconUrl': iconUrl,
      'largeImageKey': largeImageKey,
      'largeImageText': largeImageText,
      'smallImageKey': smallImageKey,
      'smallImageText': smallImageText,
      'details': details,
      'state': state,
      'enabled': enabled,
    };
  }

  /// Create from JSON
  factory GameProfile.fromJson(Map<String, dynamic> json) {
    return GameProfile(
      id: json['id'] as String,
      processName: json['processName'] as String,
      displayName: json['displayName'] as String,
      iconUrl: json['iconUrl'] as String?,
      largeImageKey: json['largeImageKey'] as String?,
      largeImageText: json['largeImageText'] as String?,
      smallImageKey: json['smallImageKey'] as String?,
      smallImageText: json['smallImageText'] as String?,
      details: json['details'] as String?,
      state: json['state'] as String?,
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  /// Create a copy with modified fields
  GameProfile copyWith({
    String? id,
    String? processName,
    String? displayName,
    String? iconUrl,
    String? largeImageKey,
    String? largeImageText,
    String? smallImageKey,
    String? smallImageText,
    String? details,
    String? state,
    bool? enabled,
  }) {
    return GameProfile(
      id: id ?? this.id,
      processName: processName ?? this.processName,
      displayName: displayName ?? this.displayName,
      iconUrl: iconUrl ?? this.iconUrl,
      largeImageKey: largeImageKey ?? this.largeImageKey,
      largeImageText: largeImageText ?? this.largeImageText,
      smallImageKey: smallImageKey ?? this.smallImageKey,
      smallImageText: smallImageText ?? this.smallImageText,
      details: details ?? this.details,
      state: state ?? this.state,
      enabled: enabled ?? this.enabled,
    );
  }
}
