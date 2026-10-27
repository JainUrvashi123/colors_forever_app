class UserModel {
  final String userId;
  final String vdGroupId;
  final String parentId;
  final String fullName;
  final String active;
  final String company;
  final String logo;
  final int group;

  const UserModel({
    required this.userId,
    this.vdGroupId = '',
    required this.parentId,
    required this.fullName,
    required this.active,
    required this.company,
    required this.logo,
    required this.group,
  });

  bool get isActive => active == '1' || active.toLowerCase() == 'true';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id']?.toString() ?? '',
      vdGroupId: json['vd_group_id']?.toString() ?? json['group_id']?.toString() ?? '',
      parentId: json['parent_id']?.toString() ?? '',
      fullName: json['fullname']?.toString() ?? '',
      active: json['active']?.toString() ?? '0',
      company: json['company']?.toString() ?? '',
      logo: json['logo']?.toString() ?? '',
      group: json['group'] is int
          ? json['group'] as int
          : int.tryParse(json['group']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'vd_group_id': vdGroupId,
      'parent_id': parentId,
      'fullname': fullName,
      'active': active,
      'company': company,
      'logo': logo,
      'group': group,
    };
  }

  UserModel copyWith({
    String? userId,
    String? vdGroupId,
    String? parentId,
    String? fullName,
    String? active,
    String? company,
    String? logo,
    int? group,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      vdGroupId: vdGroupId ?? this.vdGroupId,
      parentId: parentId ?? this.parentId,
      fullName: fullName ?? this.fullName,
      active: active ?? this.active,
      company: company ?? this.company,
      logo: logo ?? this.logo,
      group: group ?? this.group,
    );
  }
}

class LoginResponse {
  final int status;
  final String message;
  final UserModel? user;

  const LoginResponse({
    required this.status,
    required this.message,
    this.user,
  });

  bool get isSuccess => status == 1 && user != null;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    UserModel? user;
    final details = json['details'];
    if (details is Map<String, dynamic>) {
      user = UserModel.fromJson(details);
    }

    return LoginResponse(
      status: json['status'] is int
          ? json['status'] as int
          : int.tryParse(json['status']?.toString() ?? '0') ?? 0,
      message: json['message']?.toString() ?? '',
      user: user,
    );
  }
}

class ForgotPasswordResponse {
  final int status;
  final String message;

  const ForgotPasswordResponse({
    required this.status,
    required this.message,
  });

  bool get isSuccess => status == 1;

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      status: json['status'] is int
          ? json['status'] as int
          : int.tryParse(json['status']?.toString() ?? '0') ?? 0,
      message: json['message']?.toString() ?? '',
    );
  }
}

class MarkupToggleResponse {
  final int status;
  final String message;
  final MarkupToggleDetails? details;

  const MarkupToggleResponse({
    required this.status,
    required this.message,
    this.details,
  });

  bool get isSuccess => status == 1;

  factory MarkupToggleResponse.fromJson(Map<String, dynamic> json) {
    MarkupToggleDetails? details;
    if (json['details'] is Map<String, dynamic>) {
      details = MarkupToggleDetails.fromJson(json['details'] as Map<String, dynamic>);
    }

    return MarkupToggleResponse(
      status: json['status'] is int
          ? json['status'] as int
          : int.tryParse(json['status']?.toString() ?? '0') ?? 0,
      message: json['message']?.toString() ?? '',
      details: details,
    );
  }
}

class MarkupToggleDetails {
  final String userId;
  final int isMarkup;
  final List<String> updated;

  const MarkupToggleDetails({
    required this.userId,
    required this.isMarkup,
    this.updated = const [],
  });

  bool get isMarkupActive => isMarkup == 1;

  factory MarkupToggleDetails.fromJson(Map<String, dynamic> json) {
    final updatedRaw = json['updated'];
    List<String> updatedList = [];
    if (updatedRaw is List) {
      updatedList = updatedRaw.map((e) => e.toString()).toList();
    }

    return MarkupToggleDetails(
      userId: json['user_id']?.toString() ?? '',
      isMarkup: json['is_markup'] is int
          ? json['is_markup'] as int
          : int.tryParse(json['is_markup']?.toString() ?? '0') ?? 0,
      updated: updatedList,
    );
  }
}

class LogoutResponse {
  final int status;
  final String message;

  const LogoutResponse({
    required this.status,
    required this.message,
  });

  bool get isSuccess => status == 1;

  factory LogoutResponse.fromJson(Map<String, dynamic> json) {
    return LogoutResponse(
      status: json['status'] is int
          ? json['status'] as int
          : int.tryParse(json['status']?.toString() ?? '0') ?? 0,
      message: json['message']?.toString() ?? '',
    );
  }
}
