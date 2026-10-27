import 'package:image_picker/image_picker.dart';
import '../../../../core/network/session_manager.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';
import '../models/user_profile_model.dart';

class AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  UserModel? _currentUser;
  String? _savedUsername;
  String? _savedPassword;

  AuthRepository({
    AuthRemoteDataSource? remoteDataSource,
    AuthLocalDataSource? localDataSource,
    UserModel? currentUser,
  })  : _remoteDataSource = remoteDataSource ?? AuthRemoteDataSource(),
        _localDataSource = localDataSource ?? AuthLocalDataSource(),
        _currentUser = currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  String? get savedUsername => _savedUsername;
  String? get savedPassword => _savedPassword;
  AuthLocalDataSource get localDataSource => _localDataSource;

  /// Restores active session and credentials from local storage on app start.
  Future<UserModel?> restoreSession() async {
    try {
      _currentUser = await _localDataSource.getUserSession();
      final creds = await _localDataSource.getSavedCredentials();
      _savedUsername = creds['username'];
      _savedPassword = creds['password'];

      // Auto-authenticate if credentials exist but session profile needs refresh
      if (_currentUser == null &&
          _savedUsername != null &&
          _savedUsername!.isNotEmpty &&
          _savedPassword != null &&
          _savedPassword!.isNotEmpty) {
        final resp = await login(
          username: _savedUsername!,
          password: _savedPassword!,
          remember: true,
        );
        if (resp.isSuccess) {
          _currentUser = resp.user;
        }
      }

      return _currentUser;
    } catch (_) {
      return null;
    }
  }

  void setSavedCredentials(String username, String password, {bool remember = true}) {
    _savedUsername = username;
    _savedPassword = password;
    _localDataSource.saveCredentials(username, password, remember: remember);
  }

  Future<LoginResponse> login({
    required String username,
    required String password,
    bool remember = true,
  }) async {
    final response = await _remoteDataSource.login(
      username: username,
      password: password,
      remember: remember,
    );

    if (response.isSuccess && response.user != null) {
      _currentUser = response.user;
      _savedUsername = username;
      _savedPassword = password;

      // Persist user session and credentials
      await _localDataSource.saveUserSession(response.user!);
      await _localDataSource.saveCredentials(username, password, remember: remember);
    }

    return response;
  }

  Future<ForgotPasswordResponse> forgotPassword({
    required String username,
  }) async {
    return await _remoteDataSource.forgotPassword(username: username);
  }

  Future<MarkupToggleResponse> toggleMarkup({
    int isDiamondWork2 = 1,
    required int toggleChecked,
    required String emailInput,
    required String passwordInput,
    String? vdUserId,
  }) async {
    final response = await _remoteDataSource.toggleMarkup(
      isDiamondWork2: isDiamondWork2,
      toggleChecked: toggleChecked,
      emailInput: emailInput,
      passwordInput: passwordInput,
      vdUserId: vdUserId ?? _currentUser?.userId,
    );

    if (response.isSuccess) {
      final isEnabled = response.details?.isMarkupActive ?? (toggleChecked == 1);
      final categories = response.details?.updated ?? const <String>[];
      await _localDataSource.saveMarkupState(
        isEnabled: isEnabled,
        categories: categories,
      );
    }

    return response;
  }

  Future<UserProfileResponse> fetchProfile({String? userId, bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cachedMap = await _localDataSource.getProfileData();
      if (cachedMap != null) {
        final cachedProfile = UserProfileResponse.fromJson(cachedMap);
        if (cachedProfile.isSuccess) return cachedProfile;
      }
    }

    try {
      final remoteRes = await _remoteDataSource.getProfile(userId: userId ?? _currentUser?.userId);
      if (remoteRes.isSuccess) {
        await _localDataSource.saveProfileData(remoteRes.toJson());
        return remoteRes;
      }
    } catch (_) {}

    final cachedMap = await _localDataSource.getProfileData();
    if (cachedMap != null) {
      return UserProfileResponse.fromJson(cachedMap);
    }

    return UserProfileResponse.mockProfile;
  }

  Future<void> saveUpdatedProfile(UserProfileResponse updatedProfile) async {
    await _localDataSource.saveProfileData(updatedProfile.toJson());
    if (_currentUser != null && updatedProfile.details != null) {
      _currentUser = _currentUser!.copyWith(
        fullName: updatedProfile.details!.fullName,
        company: updatedProfile.details!.companyName,
        logo: updatedProfile.details!.companyLogo,
      );
      await _localDataSource.saveUserSession(_currentUser!);
    }
  }

  Future<ProfileSubmitResponse> submitProfile({
    required String name,
    required String company,
    required String website,
    required String phone,
    required String isDiamondWork,
    required String companyLogoOld,
    required String fax,
    required String address,
    required String markupType,
    required String markupD,
    required String markupJ,
    required String markupM,
    required String price,
    String? email,
    String? userId,
    XFile? logoFile,
  }) async {
    final response = await _remoteDataSource.submitProfile(
      name: name,
      company: company,
      website: website,
      phone: phone,
      isDiamondWork: isDiamondWork,
      companyLogoOld: companyLogoOld,
      fax: fax,
      address: address,
      markupType: markupType,
      markupD: markupD,
      markupJ: markupJ,
      markupM: markupM,
      price: price,
      email: email,
      userId: userId ?? _currentUser?.userId,
      logoFile: logoFile,
    );

    if (response.isSuccess) {
      final submitData = response.data;
      final details = submitData?.details;
      final updatedName = submitData?.name.isNotEmpty == true ? submitData!.name : (details?.fullName ?? name);
      final updatedCompany = submitData?.company.isNotEmpty == true ? submitData!.company : (details?.companyName ?? company);
      final updatedLogo = submitData?.companyLogo.isNotEmpty == true ? submitData!.companyLogo : (logoFile?.name ?? companyLogoOld);

      // Create updated UserProfileResponse
      final updatedProfile = UserProfileResponse(
        status: 1,
        message: 'Profile updated successfully',
        details: UserProfileDetails(
          userId: submitData?.userId ?? _currentUser?.userId ?? '25',
          groupId: details?.groupId ?? '4',
          parentId: details?.parentId ?? '20',
          username: email ?? _currentUser?.fullName ?? 'praveen@braintreeproducts.com',
          email: email ?? _currentUser?.fullName ?? 'praveen@braintreeproducts.com',
          fullName: updatedName,
          mobile: phone,
          active: '1',
          companyName: updatedCompany,
          companyLogo: updatedLogo,
          companyWebsite: website,
          fax: fax,
          address: address,
        ),
        diamondMarkup: VendorMarkup(
          pricingId: '104',
          userId: submitData?.userId ?? _currentUser?.userId ?? '25',
          parentMarkup: '0',
          userMarkup: markupD,
          markupType: markupType,
          type: 'diamond',
          isPriceHide: price,
          isMarkup: isDiamondWork,
        ),
        jewelryMarkup: VendorMarkup(
          pricingId: '105',
          userId: submitData?.userId ?? _currentUser?.userId ?? '25',
          parentMarkup: '0',
          userMarkup: markupJ,
          markupType: markupType,
          type: 'jewelry',
          isPriceHide: price,
          isMarkup: isDiamondWork,
        ),
        meleeMarkup: VendorMarkup(
          pricingId: '113',
          userId: submitData?.userId ?? _currentUser?.userId ?? '25',
          parentMarkup: '0',
          userMarkup: markupM,
          markupType: markupType,
          type: 'melle',
          isPriceHide: price,
          isMarkup: isDiamondWork,
        ),
      );

      await _localDataSource.saveProfileData(updatedProfile.toJson());

      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(
          fullName: updatedName,
          company: updatedCompany,
          logo: updatedLogo,
        );
        await _localDataSource.saveUserSession(_currentUser!);
      }
    }

    return response;
  }

  Future<LogoutResponse> logout({bool? keepSavedUsername}) async {
    LogoutResponse remoteResult = const LogoutResponse(status: 1, message: 'Logout Successfully');
    try {
      remoteResult = await _remoteDataSource.logout();
    } catch (_) {}

    _currentUser = null;
    SessionManager.clearSession();
    final remember = await _localDataSource.getRememberMe();
    final shouldKeep = keepSavedUsername ?? remember;

    if (!shouldKeep) {
      _savedUsername = null;
      _savedPassword = null;
    }
    await _localDataSource.clearSession(keepSavedUsername: shouldKeep);
    return remoteResult;
  }
}
