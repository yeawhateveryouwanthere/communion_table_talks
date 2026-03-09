/// Represents a discount code stored in Firestore.
class DiscountCode {
  final String id;
  final String code;
  final String durationType; // 'month', 'threeMonths', 'year', 'permanent'
  final bool isActive;
  final String? description;

  DiscountCode({
    required this.id,
    required this.code,
    required this.durationType,
    this.isActive = true,
    this.description,
  });

  factory DiscountCode.fromMap(Map<String, dynamic> map, String documentId) {
    return DiscountCode(
      id: documentId,
      code: map['code'] ?? '',
      durationType: map['durationType'] ?? 'month',
      isActive: map['isActive'] ?? true,
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'durationType': durationType,
      'isActive': isActive,
      'description': description,
    };
  }
}
