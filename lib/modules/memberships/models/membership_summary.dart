class MembershipSummary {
  final String? userId;
  final String? membershipId;
  final String? planId;
  final String? planCode;
  final String? planName;
  final String? membershipStatus;
  final DateTime? startedAt;
  final DateTime? expiresAt;
  final DateTime? canceledAt;
  final List<LedgerEntry> lastTenLedgerEntries;
  final DateTime queryTimestamp;

  MembershipSummary({
    this.userId,
    this.membershipId,
    this.planId,
    this.planCode,
    this.planName,
    this.membershipStatus,
    this.startedAt,
    this.expiresAt,
    this.canceledAt,
    required this.lastTenLedgerEntries,
    required this.queryTimestamp,
  });

  factory MembershipSummary.fromJson(Map<String, dynamic> json) {
    return MembershipSummary(
      userId: json['user_id'],
      membershipId: json['membership_id'],
      planId: json['plan_id'],
      planCode: json['plan_code'],
      planName: json['plan_name'],
      membershipStatus: json['membership_status'],
      startedAt: json['started_at'] != null 
          ? DateTime.parse(json['started_at']) 
          : null,
      expiresAt: json['expires_at'] != null 
          ? DateTime.parse(json['expires_at']) 
          : null,
      canceledAt: json['canceled_at'] != null 
          ? DateTime.parse(json['canceled_at']) 
          : null,
      lastTenLedgerEntries: (json['last_ten_ledger_entries'] as List? ?? [])
          .map((e) => LedgerEntry.fromJson(e))
          .toList(),
      queryTimestamp: DateTime.parse(json['query_timestamp']),
    );
  }
}

class LedgerEntry {
  final String id;
  final String source;
  final String type;
  final double? amount;
  final int? quantity;
  final String unitType;
  final String? entitlementCode;
  final String? correlationReferenceId;
  final DateTime createdAt;

  LedgerEntry({
    required this.id,
    required this.source,
    required this.type,
    this.amount,
    this.quantity,
    required this.unitType,
    this.entitlementCode,
    this.correlationReferenceId,
    required this.createdAt,
  });

  factory LedgerEntry.fromJson(Map<String, dynamic> json) {
    return LedgerEntry(
      id: json['id'],
      source: json['source'],
      type: json['type'],
      amount: json['amount']?.toDouble(),
      quantity: json['quantity'],
      unitType: json['unit_type'],
      entitlementCode: json['entitlement_code'],
      correlationReferenceId: json['correlation_reference_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  String get displayValue {
    if (unitType == 'currency' && amount != null) {
      return '\$${amount!.toStringAsFixed(2)}';
    } else if (unitType == 'quantity' && quantity != null) {
      return '$quantity';
    }
    return '-';
  }
}
