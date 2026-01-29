import 'subscription_model.dart' show SubscriptionTier;

class PromoCode {
  final String code;
  final int durationMonths;
  final SubscriptionTier tier;
  final DateTime? expiresAt;
  final bool isActive;

  PromoCode({
    required this.code,
    required this.durationMonths,
    required this.tier,
    this.expiresAt,
    this.isActive = true,
  });

  bool get isValid {
    if (!isActive) return false;
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) {
      return false;
    }
    return true;
  }

  factory PromoCode.fromJson(Map<String, dynamic> json) {
    return PromoCode(
      code: json['code'] as String,
      durationMonths: json['durationMonths'] as int,
      tier: SubscriptionTier.values.firstWhere(
        (e) => e.toString() == 'SubscriptionTier.${json['tier']}',
        orElse: () => SubscriptionTier.pro,
      ),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'durationMonths': durationMonths,
      'tier': tier.toString().split('.').last,
      'expiresAt': expiresAt?.toIso8601String(),
      'isActive': isActive,
    };
  }
}


// Predefined promo codes
class PromoCodes {
  static final Map<String, PromoCode> codes = {
    'PRODUCTHUNT': PromoCode(
      code: 'PRODUCTHUNT',
      durationMonths: 3,
      tier: SubscriptionTier.pro,
      expiresAt: null, // No expiration
      isActive: true,
    ),
    // Add more promo codes here as needed
  };

  static PromoCode? validate(String code) {
    final promoCode = codes[code.toUpperCase()];
    if (promoCode != null && promoCode.isValid) {
      return promoCode;
    }
    return null;
  }
}
