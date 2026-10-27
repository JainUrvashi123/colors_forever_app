class UserProfileDetails {
  final String userId;
  final String groupId;
  final String parentId;
  final String username;
  final String email;
  final String fullName;
  final String mobile;
  final String active;
  final String companyName;
  final String companyLogo;
  final String companyWebsite;
  final String fax;
  final String address;

  const UserProfileDetails({
    required this.userId,
    required this.groupId,
    required this.parentId,
    required this.username,
    required this.email,
    required this.fullName,
    required this.mobile,
    required this.active,
    required this.companyName,
    required this.companyLogo,
    required this.companyWebsite,
    required this.fax,
    required this.address,
  });

  factory UserProfileDetails.fromJson(Map<String, dynamic> json) {
    return UserProfileDetails(
      userId: json['CD_USER_ID']?.toString() ?? '',
      groupId: json['CD_GROUP_ID']?.toString() ?? '',
      parentId: json['CD_PARENT_ID']?.toString() ?? '',
      username: json['SN_USERNAME']?.toString() ?? '',
      email: json['NM_USER_EMAIL']?.toString() ?? '',
      fullName: json['NM_USER_FULLNAME']?.toString() ?? '',
      mobile: json['SN_USER_MOBILE']?.toString() ?? '',
      active: json['FL_USER_ACTIVE']?.toString() ?? '1',
      companyName: json['NM_COMPANY_NAME']?.toString() ?? '',
      companyLogo: json['SN_COMPANY_LOGO']?.toString() ?? '',
      companyWebsite: json['NM_COMPANY_WEBSITE']?.toString() ?? '',
      fax: json['FAX']?.toString() ?? '',
      address: json['ADDRESS']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CD_USER_ID': userId,
      'CD_GROUP_ID': groupId,
      'CD_PARENT_ID': parentId,
      'SN_USERNAME': username,
      'NM_USER_EMAIL': email,
      'NM_USER_FULLNAME': fullName,
      'SN_USER_MOBILE': mobile,
      'FL_USER_ACTIVE': active,
      'NM_COMPANY_NAME': companyName,
      'SN_COMPANY_LOGO': companyLogo,
      'NM_COMPANY_WEBSITE': companyWebsite,
      'FAX': fax,
      'ADDRESS': address,
    };
  }
}

class VendorMarkup {
  final String pricingId;
  final String userId;
  final String parentMarkup;
  final String userMarkup;
  final String markupType;
  final String type;
  final String isPriceHide;
  final String isMarkup;

  const VendorMarkup({
    required this.pricingId,
    required this.userId,
    required this.parentMarkup,
    required this.userMarkup,
    required this.markupType,
    required this.type,
    required this.isPriceHide,
    required this.isMarkup,
  });

  bool get isMarkupActive => isMarkup == '1' || isMarkup == 'true';
  bool get isPriceHidden => isPriceHide == '1' || isPriceHide == 'true';

  factory VendorMarkup.fromJson(Map<String, dynamic> json) {
    return VendorMarkup(
      pricingId: json['PRICING_ID']?.toString() ?? '',
      userId: json['CD_USER_ID']?.toString() ?? '',
      parentMarkup: json['PARENT_MARKUP']?.toString() ?? '0',
      userMarkup: json['USER_MARKUP']?.toString() ?? '0',
      markupType: json['MARKUP_TYPE']?.toString() ?? 'rapwise',
      type: json['TYPE']?.toString() ?? '',
      isPriceHide: json['IS_PRICE_HIDE']?.toString() ?? '0',
      isMarkup: json['IS_MARKUP']?.toString() ?? '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PRICING_ID': pricingId,
      'CD_USER_ID': userId,
      'PARENT_MARKUP': parentMarkup,
      'USER_MARKUP': userMarkup,
      'MARKUP_TYPE': markupType,
      'TYPE': type,
      'IS_PRICE_HIDE': isPriceHide,
      'IS_MARKUP': isMarkup,
    };
  }
}

class UserProfileResponse {
  final int status;
  final String message;
  final UserProfileDetails? details;
  final VendorMarkup? diamondMarkup;
  final VendorMarkup? jewelryMarkup;
  final VendorMarkup? meleeMarkup;

  const UserProfileResponse({
    required this.status,
    required this.message,
    this.details,
    this.diamondMarkup,
    this.jewelryMarkup,
    this.meleeMarkup,
  });

  bool get isSuccess => status == 1 && details != null;

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    UserProfileDetails? detailsObj;
    VendorMarkup? diamondObj;
    VendorMarkup? jewelryObj;
    VendorMarkup? meleeObj;

    final dataMap = json['data'];
    if (dataMap is Map<String, dynamic>) {
      // details array
      final detailsList = dataMap['details'];
      if (detailsList is List && detailsList.isNotEmpty) {
        detailsObj = UserProfileDetails.fromJson(detailsList.first as Map<String, dynamic>);
      }

      // vendor_markup_d
      final dList = dataMap['vendor_markup_d'];
      if (dList is List && dList.isNotEmpty) {
        diamondObj = VendorMarkup.fromJson(dList.first as Map<String, dynamic>);
      }

      // vendor_markup_j
      final jList = dataMap['vendor_markup_j'];
      if (jList is List && jList.isNotEmpty) {
        jewelryObj = VendorMarkup.fromJson(jList.first as Map<String, dynamic>);
      }

      // vendor_markup_m
      final mList = dataMap['vendor_markup_m'];
      if (mList is List && mList.isNotEmpty) {
        meleeObj = VendorMarkup.fromJson(mList.first as Map<String, dynamic>);
      }
    }

    return UserProfileResponse(
      status: json['status'] is int
          ? json['status'] as int
          : int.tryParse(json['status']?.toString() ?? '0') ?? 0,
      message: json['message']?.toString() ?? '',
      details: detailsObj,
      diamondMarkup: diamondObj,
      jewelryMarkup: jewelryObj,
      meleeMarkup: meleeObj,
    );
  }

  factory UserProfileResponse.fromSubmitData(ProfileSubmitData submitData, UserProfileResponse? existingProfile) {
    final detailsObj = submitData.details ?? existingProfile?.details;
    final userId = submitData.userId.isNotEmpty ? submitData.userId : (existingProfile?.details?.userId ?? '25');

    return UserProfileResponse(
      status: 1,
      message: 'Profile has been updated successfully!',
      details: UserProfileDetails(
        userId: userId,
        groupId: detailsObj?.groupId ?? existingProfile?.details?.groupId ?? '4',
        parentId: detailsObj?.parentId ?? existingProfile?.details?.parentId ?? '20',
        username: detailsObj?.username ?? existingProfile?.details?.username ?? '',
        email: detailsObj?.email ?? existingProfile?.details?.email ?? '',
        fullName: submitData.name.isNotEmpty ? submitData.name : (detailsObj?.fullName ?? ''),
        mobile: submitData.phone.isNotEmpty ? submitData.phone : (detailsObj?.mobile ?? ''),
        active: detailsObj?.active ?? existingProfile?.details?.active ?? '1',
        companyName: submitData.company.isNotEmpty ? submitData.company : (detailsObj?.companyName ?? ''),
        companyLogo: submitData.companyLogo.isNotEmpty ? submitData.companyLogo : (detailsObj?.companyLogo ?? ''),
        companyWebsite: submitData.website.isNotEmpty ? submitData.website : (detailsObj?.companyWebsite ?? ''),
        fax: detailsObj?.fax ?? existingProfile?.details?.fax ?? '',
        address: detailsObj?.address ?? existingProfile?.details?.address ?? '',
      ),
      diamondMarkup: VendorMarkup(
        pricingId: existingProfile?.diamondMarkup?.pricingId ?? '104',
        userId: userId,
        parentMarkup: existingProfile?.diamondMarkup?.parentMarkup ?? '0',
        userMarkup: submitData.markupD,
        markupType: existingProfile?.diamondMarkup?.markupType ?? 'moneywise',
        type: 'diamond',
        isPriceHide: submitData.price,
        isMarkup: submitData.isDiamondWork,
      ),
      jewelryMarkup: VendorMarkup(
        pricingId: existingProfile?.jewelryMarkup?.pricingId ?? '105',
        userId: userId,
        parentMarkup: existingProfile?.jewelryMarkup?.parentMarkup ?? '0',
        userMarkup: submitData.markupJ,
        markupType: existingProfile?.jewelryMarkup?.markupType ?? 'moneywise',
        type: 'jewelry',
        isPriceHide: submitData.price,
        isMarkup: submitData.isDiamondWork,
      ),
      meleeMarkup: VendorMarkup(
        pricingId: existingProfile?.meleeMarkup?.pricingId ?? '113',
        userId: userId,
        parentMarkup: existingProfile?.meleeMarkup?.parentMarkup ?? '0',
        userMarkup: submitData.markupM,
        markupType: existingProfile?.meleeMarkup?.markupType ?? 'moneywise',
        type: 'melle',
        isPriceHide: submitData.price,
        isMarkup: submitData.isDiamondWork,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': {
        'details': details != null ? [details!.toJson()] : [],
        'vendor_markup_d': diamondMarkup != null ? [diamondMarkup!.toJson()] : [],
        'vendor_markup_j': jewelryMarkup != null ? [jewelryMarkup!.toJson()] : [],
        'vendor_markup_m': meleeMarkup != null ? [meleeMarkup!.toJson()] : [],
      }
    };
  }

  /// Sample mock data fallback strictly adhering to official get_profile response
  static UserProfileResponse get mockProfile {
    return UserProfileResponse.fromJson({
      "status": 1,
      "message": "Profile fetched successfully",
      "data": {
        "details": [
          {
            "CD_USER_ID": "25",
            "CD_GROUP_ID": "4",
            "CD_PARENT_ID": "20",
            "SN_USERNAME": "praveen@braintreeproducts.com",
            "NM_USER_EMAIL": "praveen@braintreeproducts.com",
            "NM_USER_FULLNAME": "John Smith",
            "SN_USER_MOBILE": "9876543210",
            "FL_USER_ACTIVE": "1",
            "NM_COMPANY_NAME": "ABC Jewelry",
            "SN_COMPANY_LOGO": "old_logo.png",
            "NM_COMPANY_WEBSITE": "https://abcjewelry.com",
            "FAX": "123456",
            "ADDRESS": "New York, USA"
          }
        ],
        "vendor_markup_d": [
          {
            "PRICING_ID": "104",
            "CD_USER_ID": "25",
            "PARENT_MARKUP": "0",
            "USER_MARKUP": "10",
            "MARKUP_TYPE": "rapwise",
            "TYPE": "diamond",
            "IS_PRICE_HIDE": "0",
            "IS_MARKUP": "1"
          }
        ],
        "vendor_markup_j": [
          {
            "PRICING_ID": "105",
            "CD_USER_ID": "25",
            "PARENT_MARKUP": "0",
            "USER_MARKUP": "15",
            "MARKUP_TYPE": "rapwise",
            "TYPE": "jewelry",
            "IS_PRICE_HIDE": "0",
            "IS_MARKUP": "1"
          }
        ],
        "vendor_markup_m": [
          {
            "PRICING_ID": "113",
            "CD_USER_ID": "25",
            "PARENT_MARKUP": "0",
            "USER_MARKUP": "20",
            "MARKUP_TYPE": "rapwise",
            "TYPE": "melle",
            "IS_PRICE_HIDE": "0",
            "IS_MARKUP": "1"
          }
        ]
      }
    });
  }
}

class ProfileSubmitData {
  final String userId;
  final String name;
  final String company;
  final String website;
  final String email;
  final String phone;
  final String companyLogo;
  final String isDiamondWork;
  final String markupD;
  final String markupJ;
  final String markupM;
  final String price;
  final UserProfileDetails? details;

  const ProfileSubmitData({
    required this.userId,
    required this.name,
    required this.company,
    required this.website,
    required this.email,
    required this.phone,
    required this.companyLogo,
    required this.isDiamondWork,
    required this.markupD,
    required this.markupJ,
    required this.markupM,
    required this.price,
    this.details,
  });

  factory ProfileSubmitData.fromJson(Map<String, dynamic> json) {
    UserProfileDetails? detailsObj;
    final detailsList = json['details'];
    if (detailsList is List && detailsList.isNotEmpty) {
      detailsObj = UserProfileDetails.fromJson(detailsList.first as Map<String, dynamic>);
    }

    return ProfileSubmitData(
      userId: json['user_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      website: json['website']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      companyLogo: json['company_logo']?.toString() ?? '',
      isDiamondWork: json['is_diamond_work']?.toString() ?? '1',
      markupD: json['markup_d']?.toString() ?? '0',
      markupJ: json['markup_j']?.toString() ?? '0',
      markupM: json['markup_m']?.toString() ?? '0',
      price: json['price']?.toString() ?? '0',
      details: detailsObj,
    );
  }
}

class ProfileSubmitResponse {
  final int status;
  final String message;
  final ProfileSubmitData? data;

  const ProfileSubmitResponse({
    required this.status,
    required this.message,
    this.data,
  });

  bool get isSuccess => status == 1;

  factory ProfileSubmitResponse.fromJson(Map<String, dynamic> json) {
    ProfileSubmitData? dataObj;
    if (json['data'] is Map<String, dynamic>) {
      dataObj = ProfileSubmitData.fromJson(json['data'] as Map<String, dynamic>);
    }

    return ProfileSubmitResponse(
      status: json['status'] is int
          ? json['status'] as int
          : int.tryParse(json['status']?.toString() ?? '0') ?? 0,
      message: json['message']?.toString() ?? '',
      data: dataObj,
    );
  }
}
