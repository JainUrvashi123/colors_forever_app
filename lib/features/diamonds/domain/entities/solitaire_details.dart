import 'diamond.dart';

class SolitaireDetails {
  final Diamond diamond;
  final List<Diamond> similarDiamonds;
  final List<String> imageArray;
  final List<String> videoArray;
  final List<String> certificateArray;
  final int isPriceHide;
  final int login;

  const SolitaireDetails({
    required this.diamond,
    required this.similarDiamonds,
    required this.imageArray,
    required this.videoArray,
    required this.certificateArray,
    required this.isPriceHide,
    required this.login,
  });
}
