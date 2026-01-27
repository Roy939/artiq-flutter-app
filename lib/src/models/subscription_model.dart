class UserSubscription {
  final String userId;
  final SubscriptionTier tier;
  final String? stripeCustomerId;
  final String? stripeSubscriptionId;
  final DateTime? subscriptionStart;
  final DateTime? subscriptionEnd;
  final bool isActive;

  UserSubscription({
    required this.userId,
    required this.tier,
    this.stripeCustomerId,
    this.stripeSubscriptionId,
    this.subscriptionStart,
    this.subscriptionEnd,
    this.isActive = false,
  });

  bool get isPro => tier == SubscriptionTier.pro && isActive;
  bool get isFree => tier == SubscriptionTier.free || !isActive;

  // Free tier limits
  int get maxDesigns => isPro ? -1 : 5; // -1 means unlimited
  bool get hasWatermark => !isPro;
  bool get canExportJPG => isPro;
  bool get canExportPDF => isPro;
  List<String> get availableFonts => isPro 
      ? ['Roboto', 'Arial', 'Times New Roman', 'Courier New', 'Georgia', 'Verdana', 'Comic Sans MS', 'Impact']
      : ['Roboto', 'Arial'];

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      userId: json['userId'] as String,
      tier: SubscriptionTier.values.firstWhere(
        (e) => e.toString() == 'SubscriptionTier.${json['tier']}',
        orElse: () => SubscriptionTier.free,
      ),
      stripeCustomerId: json['stripeCustomerId'] as String?,
      stripeSubscriptionId: json['stripeSubscriptionId'] as String?,
      subscriptionStart: json['subscriptionStart'] != null
          ? _parseDateTime(json['subscriptionStart'])
          : null,
      subscriptionEnd: json['subscriptionEnd'] != null
          ? _parseDateTime(json['subscriptionEnd'])
          : null,
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  // Helper method to parse DateTime from both Firestore Timestamp and ISO8601 String
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    // Handle Firestore Timestamp
    if (value.runtimeType.toString() == 'Timestamp') {
      return (value as dynamic).toDate() as DateTime;
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'tier': tier.toString().split('.').last,
      'stripeCustomerId': stripeCustomerId,
      'stripeSubscriptionId': stripeSubscriptionId,
      'subscriptionStart': subscriptionStart?.toIso8601String(),
      'subscriptionEnd': subscriptionEnd?.toIso8601String(),
      'isActive': isActive,
    };
  }

  UserSubscription copyWith({
    String? userId,
    SubscriptionTier? tier,
    String? stripeCustomerId,
    String? stripeSubscriptionId,
    DateTime? subscriptionStart,
    DateTime? subscriptionEnd,
    bool? isActive,
  }) {
    return UserSubscription(
      userId: userId ?? this.userId,
      tier: tier ?? this.tier,
      stripeCustomerId: stripeCustomerId ?? this.stripeCustomerId,
      stripeSubscriptionId: stripeSubscriptionId ?? this.stripeSubscriptionId,
      subscriptionStart: subscriptionStart ?? this.subscriptionStart,
      subscriptionEnd: subscriptionEnd ?? this.subscriptionEnd,
      isActive: isActive ?? this.isActive,
    );
  }
}

enum SubscriptionTier {
  free,
  pro,
}
