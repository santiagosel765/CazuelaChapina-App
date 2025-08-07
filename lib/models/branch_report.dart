class BranchReport {
  final int branchId;
  final String branchName;
  final int salesCount;
  final double totalAmount;

  BranchReport({
    required this.branchId,
    required this.branchName,
    required this.salesCount,
    required this.totalAmount,
  });

  factory BranchReport.fromJson(Map<String, dynamic> json) {
    return BranchReport(
      branchId: json['branchId'] is int
          ? json['branchId'] as int
          : int.tryParse(json['branchId']?.toString() ?? '') ?? 0,
      branchName: json['branchName']?.toString() ?? '',
      salesCount: json['salesCount'] is int
          ? json['salesCount'] as int
          : int.tryParse(json['salesCount']?.toString() ?? '') ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
    );
  }
}
