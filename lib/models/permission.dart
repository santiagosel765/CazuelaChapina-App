class Permission {
  final int moduleId;
  bool canView;
  bool canCreate;
  bool canUpdate;
  bool canDelete;

  Permission({
    required this.moduleId,
    this.canView = false,
    this.canCreate = false,
    this.canUpdate = false,
    this.canDelete = false,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      moduleId: json['moduleId'] is int
          ? json['moduleId'] as int
          : int.tryParse(json['moduleId']?.toString() ?? '') ?? 0,
      canView: json['canView'] == true || json['canView'] == 'true',
      canCreate: json['canCreate'] == true || json['canCreate'] == 'true',
      canUpdate: json['canUpdate'] == true || json['canUpdate'] == 'true',
      canDelete: json['canDelete'] == true || json['canDelete'] == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'moduleId': moduleId,
      'canView': canView,
      'canCreate': canCreate,
      'canUpdate': canUpdate,
      'canDelete': canDelete,
    };
  }
}
