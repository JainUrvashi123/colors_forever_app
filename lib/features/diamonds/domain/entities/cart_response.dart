import 'diamond.dart';

class SolitaireCartItem {
  final String cartId;
  final String stockId;
  final String serialNo;
  final String lab;
  final String certNumber;
  final String shape;
  final double weight;
  final String color;
  final String grade;
  final String cut;
  final String polish;
  final String symmetry;
  final String fluorescence;
  final String imageUrl;
  final double pricePerCts;
  final int available;

  const SolitaireCartItem({
    required this.cartId,
    required this.stockId,
    required this.serialNo,
    required this.lab,
    required this.certNumber,
    required this.shape,
    required this.weight,
    required this.color,
    required this.grade,
    required this.cut,
    required this.polish,
    required this.symmetry,
    required this.fluorescence,
    required this.imageUrl,
    required this.pricePerCts,
    required this.available,
  });

  Diamond toDiamond() {
    return Diamond(
      serialNo: serialNo,
      shape: shape,
      weight: weight,
      color: color,
      labColor: color,
      grade: grade,
      cut: cut,
      polish: polish,
      symmetry: symmetry,
      fluorescence: fluorescence,
      depth: 0,
      table: 0,
      retailPricePerCts: pricePerCts,
      totalRetailPrice: pricePerCts * weight,
      wholesalePrice: pricePerCts,
      totalWholesalePrice: pricePerCts * weight,
      lab: lab,
      certNumber: certNumber,
      measurements: '',
      location: '',
      imageUrl: imageUrl,
      videoUrl: '',
      certUrl: '',
    );
  }
}

class SolitaireCartEmail {
  final String parentToEmail;
  final String toEmail;

  const SolitaireCartEmail({
    required this.parentToEmail,
    required this.toEmail,
  });
}

class CartResponse {
  final int status;
  final String message;
  final List<SolitaireCartItem> solitaireCartItems;
  final int totalItems;
  final SolitaireCartEmail? emailInfo;

  const CartResponse({
    required this.status,
    required this.message,
    required this.solitaireCartItems,
    required this.totalItems,
    this.emailInfo,
  });

  static const empty = CartResponse(
    status: 1,
    message: '',
    solitaireCartItems: [],
    totalItems: 0,
  );
}
