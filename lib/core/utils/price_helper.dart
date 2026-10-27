import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/diamonds/domain/entities/diamond.dart';
import 'formatters.dart';

class DisplayPrice {
  final bool isHidden;
  /// True when price is hidden specifically because user is not logged in.
  final bool loginRequired;
  final String formattedTotal;
  final String formattedPerCt;
  final double totalPrice;
  final double perCtPrice;
  final bool isWholesale;

  const DisplayPrice({
    required this.isHidden,
    this.loginRequired = false,
    required this.formattedTotal,
    required this.formattedPerCt,
    required this.totalPrice,
    required this.perCtPrice,
    required this.isWholesale,
  });
}

class PriceHelper {
  /// Checks if price hiding is active for the given category/item.
  /// Prices are always hidden for unauthenticated (guest) users.
  static bool isPriceHidden(
    AuthProvider? auth, {
    int? itemIsPriceHide,
    String? category = 'diamond',
  }) {
    // Hide price for guests who are not logged in
    if (auth == null || !auth.isAuthenticated) return true;

    if (itemIsPriceHide == 1) return true;

    if (auth.userProfile != null) {
      if (category == 'jewelry') {
        if (auth.userProfile?.jewelryMarkup?.isPriceHidden == true) return true;
      } else if (category == 'melee') {
        if (auth.userProfile?.meleeMarkup?.isPriceHidden == true) return true;
      } else {
        if (auth.userProfile?.diamondMarkup?.isPriceHidden == true) return true;
      }
    }

    return false;
  }

  /// Calculates display pricing (total & per-carat) for a diamond.
  static DisplayPrice getDiamondPrice(
    Diamond diamond,
    AuthProvider? auth, {
    int? itemIsPriceHide,
    bool compact = true,
  }) {
    final hidden = isPriceHidden(
      auth,
      itemIsPriceHide: itemIsPriceHide,
      category: 'diamond',
    );

    final isLoggedIn = auth?.isAuthenticated ?? false;

    if (hidden) {
      // Distinguish between "not logged in" and "price hidden by vendor setting"
      final hiddenLabel = isLoggedIn ? 'Price Upon Request' : 'Login to View Price';
      return DisplayPrice(
        isHidden: true,
        loginRequired: !isLoggedIn,
        formattedTotal: hiddenLabel,
        formattedPerCt: hiddenLabel,
        totalPrice: 0.0,
        perCtPrice: 0.0,
        isWholesale: false,
      );
    }

    final isAuthenticated = auth?.isAuthenticated ?? false;
    final isMarkupEnabled = auth?.isMarkupEnabled ?? false;

    final isWholesale = isAuthenticated &&
        !isMarkupEnabled &&
        diamond.totalWholesalePrice > 0;

    double total = isWholesale ? diamond.totalWholesalePrice : diamond.totalRetailPrice;
    double perCt = isWholesale ? diamond.wholesalePricePerCts : diamond.retailPricePerCts;

    // Apply custom dealer markup % if markup toggle is active and user markup is configured
    if (isAuthenticated && isMarkupEnabled) {
      final markupStr = auth?.userProfile?.diamondMarkup?.userMarkup;
      final markupVal = double.tryParse(markupStr ?? '0') ?? 0.0;
      if (markupVal > 0) {
        final baseTotal = diamond.totalWholesalePrice > 0
            ? diamond.totalWholesalePrice
            : diamond.totalRetailPrice;
        final basePerCt = diamond.wholesalePricePerCts > 0
            ? diamond.wholesalePricePerCts
            : diamond.retailPricePerCts;
        if (baseTotal > 0) {
          total = baseTotal * (1.0 + (markupVal / 100.0));
          perCt = basePerCt * (1.0 + (markupVal / 100.0));
        }
      }
    }

    return DisplayPrice(
      isHidden: false,
      formattedTotal: Formatters.formatCurrency(total, compact: compact),
      formattedPerCt: Formatters.formatCurrency(perCt, compact: compact),
      totalPrice: total,
      perCtPrice: perCt,
      isWholesale: isWholesale,
    );
  }
}
