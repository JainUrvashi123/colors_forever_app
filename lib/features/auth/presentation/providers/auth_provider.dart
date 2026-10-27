import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/user_model.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/repositories/auth_repository.dart';

import '../../../../core/network/session_manager.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  bool _isInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  bool _isMarkupEnabled = false;
  List<String> _markupCategories = const [];
  UserProfileResponse? _userProfile;

  AuthProvider({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  bool get isInitialized => _isInitialized;
  UserModel? get currentUser => _repository.currentUser;
  bool get isAuthenticated => _repository.isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isMarkupEnabled => _isMarkupEnabled;
  List<String> get markupCategories => _markupCategories;
  UserProfileResponse? get userProfile => _userProfile;
  String? get savedUsername => _repository.savedUsername;
  String? get savedPassword => _repository.savedPassword;
  bool get hasSavedCredentials =>
      (_repository.savedUsername?.isNotEmpty == true) &&
      (_repository.savedPassword?.isNotEmpty == true);

  /// Initializes active user session and saved preferences from local storage.
  Future<void> initSession() async {
    try {
      await _repository.restoreSession();
      await SessionManager.loadSessionCookie();
      final savedMarkup = await _repository.localDataSource.getMarkupState();
      final savedCategories = await _repository.localDataSource.getMarkupCategories();

      if (currentUser != null) {
        SessionManager.userId = currentUser!.userId;
        if (currentUser!.vdGroupId.isNotEmpty) {
          SessionManager.vdGroupId = currentUser!.vdGroupId;
        }
      }
      SessionManager.username = savedUsername;
      SessionManager.password = savedPassword;

      SessionManager.reauthenticate = () async {
        if (savedUsername != null &&
            savedUsername!.isNotEmpty &&
            savedPassword != null &&
            savedPassword!.isNotEmpty) {
          return await login(savedUsername!, savedPassword!, remember: true);
        }
        return false;
      };

      if (savedMarkup != null) {
        _isMarkupEnabled = savedMarkup;
      }
      if (savedCategories.isNotEmpty) {
        _markupCategories = savedCategories;
      }

      // Re-establish authenticated backend session on startup if saved credentials exist
      if (savedUsername != null &&
          savedUsername!.isNotEmpty &&
          savedPassword != null &&
          savedPassword!.isNotEmpty) {
        await login(savedUsername!, savedPassword!, remember: true);
      } else {
        await fetchProfile();
      }
    } catch (_) {
      // Gracefully handle any startup storage errors
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  void setSavedCredentials(String username, String password, {bool remember = true}) {
    _repository.setSavedCredentials(username, password, remember: remember);
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> login(
    String username,
    String password, {
    bool remember = true,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _repository.login(
        username: username,
        password: password,
        remember: remember,
      );

      _isLoading = false;
      if (response.isSuccess) {
        SessionManager.userId = response.user?.userId;
        if (response.user?.vdGroupId != null && response.user!.vdGroupId.isNotEmpty) {
          SessionManager.vdGroupId = response.user!.vdGroupId;
        }
        SessionManager.username = username;
        SessionManager.password = password;
        _successMessage = response.message.isNotEmpty
            ? response.message
            : 'Login Successfully';
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message.isNotEmpty
            ? response.message
            : 'Username or Password is Incorrect!';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<ForgotPasswordResponse> forgotPassword(String username) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _repository.forgotPassword(username: username);
      _isLoading = false;
      if (response.isSuccess) {
        _successMessage = response.message;
        _errorMessage = null;
      } else {
        _errorMessage = response.message;
      }
      notifyListeners();
      return response;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Password reset request failed: ${e.toString()}';
      notifyListeners();
      return ForgotPasswordResponse(status: 0, message: _errorMessage!);
    }
  }

  Future<bool> quickToggleMarkup(bool enable) async {
    final email = _repository.savedUsername;
    final password = _repository.savedPassword;
    if (email == null || email.isEmpty || password == null || password.isEmpty) {
      return false;
    }

    final response = await toggleMarkup(
      toggleChecked: enable ? 1 : 0,
      isDiamondWork2: enable ? 1 : 0,
      emailInput: email,
      passwordInput: password,
      vdUserId: currentUser?.userId,
    );

    return response.isSuccess;
  }

  Future<MarkupToggleResponse> toggleMarkup({
    required int toggleChecked,
    required String emailInput,
    required String passwordInput,
    int isDiamondWork2 = 1,
    String? vdUserId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _repository.toggleMarkup(
        isDiamondWork2: isDiamondWork2,
        toggleChecked: toggleChecked,
        emailInput: emailInput,
        passwordInput: passwordInput,
        vdUserId: vdUserId,
      );

      _isLoading = false;
      if (response.isSuccess) {
        _successMessage = response.message;
        _errorMessage = null;
        if (response.details != null) {
          _isMarkupEnabled = response.details!.isMarkupActive;
          if (response.details!.updated.isNotEmpty) {
            _markupCategories = response.details!.updated;
          }
        } else {
          _isMarkupEnabled = (toggleChecked == 1);
        }
      } else {
        _errorMessage = response.message;
      }
      notifyListeners();
      return response;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Toggle markup failed: ${e.toString()}';
      notifyListeners();
      return MarkupToggleResponse(status: 0, message: _errorMessage!);
    }
  }

  Future<UserProfileResponse> fetchProfile({String? userId, bool forceRefresh = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _repository.fetchProfile(userId: userId, forceRefresh: forceRefresh);
      _userProfile = response;
      if (response.details?.groupId != null && response.details!.groupId.isNotEmpty) {
        SessionManager.vdGroupId = response.details!.groupId;
      }
      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _isLoading = false;
      _userProfile = UserProfileResponse.mockProfile;
      if (UserProfileResponse.mockProfile.details?.groupId != null &&
          UserProfileResponse.mockProfile.details!.groupId.isNotEmpty) {
        SessionManager.vdGroupId = UserProfileResponse.mockProfile.details!.groupId;
      }
      notifyListeners();
      return UserProfileResponse.mockProfile;
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
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _repository.submitProfile(
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
        userId: userId ?? currentUser?.userId,
        logoFile: logoFile,
      );

      _isLoading = false;
      if (response.isSuccess) {
        _successMessage = response.message.isNotEmpty ? response.message : 'Profile has been updated successfully!';
        if (response.data != null) {
          _userProfile = UserProfileResponse.fromSubmitData(response.data!, _userProfile);
        } else {
          _userProfile = UserProfileResponse(
            status: 1,
            message: _successMessage!,
            details: UserProfileDetails(
              userId: userId ?? currentUser?.userId ?? '25',
              groupId: _userProfile?.details?.groupId ?? '4',
              parentId: _userProfile?.details?.parentId ?? '20',
              username: email ?? currentUser?.fullName ?? '',
              email: email ?? currentUser?.fullName ?? '',
              fullName: name,
              mobile: phone,
              active: '1',
              companyName: company,
              companyLogo: logoFile?.name ?? companyLogoOld,
              companyWebsite: website,
              fax: fax,
              address: address,
            ),
            diamondMarkup: VendorMarkup(
              pricingId: _userProfile?.diamondMarkup?.pricingId ?? '104',
              userId: userId ?? currentUser?.userId ?? '25',
              parentMarkup: '0',
              userMarkup: markupD,
              markupType: markupType,
              type: 'diamond',
              isPriceHide: price,
              isMarkup: isDiamondWork,
            ),
            jewelryMarkup: VendorMarkup(
              pricingId: _userProfile?.jewelryMarkup?.pricingId ?? '105',
              userId: userId ?? currentUser?.userId ?? '25',
              parentMarkup: '0',
              userMarkup: markupJ,
              markupType: markupType,
              type: 'jewelry',
              isPriceHide: price,
              isMarkup: isDiamondWork,
            ),
            meleeMarkup: VendorMarkup(
              pricingId: _userProfile?.meleeMarkup?.pricingId ?? '113',
              userId: userId ?? currentUser?.userId ?? '25',
              parentMarkup: '0',
              userMarkup: markupM,
              markupType: markupType,
              type: 'melle',
              isPriceHide: price,
              isMarkup: isDiamondWork,
            ),
          );
        }

        if (_userProfile?.details?.groupId != null && _userProfile!.details!.groupId.isNotEmpty) {
          SessionManager.vdGroupId = _userProfile!.details!.groupId;
        }

        await _repository.saveUpdatedProfile(_userProfile!);
      } else {
        _errorMessage = response.message;
      }
      notifyListeners();
      return response;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Profile update failed: ${e.toString()}';
      notifyListeners();
      return ProfileSubmitResponse(status: 0, message: _errorMessage!);
    }
  }

  Future<Map<String, String?>> getSavedCredentials() async {
    return await _repository.localDataSource.getSavedCredentials();
  }

  static final List<Future<void> Function()> _onLogoutCallbacks = [];
  static void registerLogoutCallback(Future<void> Function() cb) {
    if (!_onLogoutCallbacks.contains(cb)) {
      _onLogoutCallbacks.add(cb);
    }
  }
  static void unregisterLogoutCallback(Future<void> Function() cb) {
    _onLogoutCallbacks.remove(cb);
  }

  Future<LogoutResponse> logout({bool? keepSavedUsername}) async {
    _isLoading = true;
    notifyListeners();

    final result = await _repository.logout(keepSavedUsername: keepSavedUsername);

    _isMarkupEnabled = false;
    _markupCategories = const [];
    _userProfile = null;
    _errorMessage = null;
    _successMessage = null;
    _isLoading = false;
    SessionManager.clearSession();

    for (final cb in List.of(_onLogoutCallbacks)) {
      try {
        await cb();
      } catch (_) {}
    }

    notifyListeners();

    return result;
  }
}
