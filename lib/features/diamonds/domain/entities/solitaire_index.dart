class SolitaireColor {
  final String id;
  final String name;
  final String value;
  final String img;

  const SolitaireColor({
    required this.id,
    required this.name,
    required this.value,
    required this.img,
  });
}

class SolitaireShade {
  final String id;
  final String name;
  final String value;
  final String dcl;
  final String parentId;

  const SolitaireShade({
    required this.id,
    required this.name,
    required this.value,
    required this.dcl,
    required this.parentId,
  });
}

class SolitaireShape {
  final String id;
  final String name;
  final String value;
  final String img;

  const SolitaireShape({
    required this.id,
    required this.name,
    required this.value,
    required this.img,
  });
}

class SolitaireClarity {
  final String id;
  final String name;
  final String value;

  const SolitaireClarity({
    required this.id,
    required this.name,
    required this.value,
  });
}

class SolitaireTicker {
  final String id;
  final String page;
  final String message;

  const SolitaireTicker({
    required this.id,
    required this.page,
    required this.message,
  });
}

class SolitaireIndex {
  final int status;
  final int login;
  final int isPriceHide;
  final List<SolitaireTicker> ticker;
  final List<SolitaireColor> colors;
  final List<SolitaireShade> shades;
  final List<SolitaireShape> shapes;
  final List<SolitaireClarity> clarities;
  final int totalWishlist;

  const SolitaireIndex({
    required this.status,
    required this.login,
    required this.isPriceHide,
    required this.ticker,
    required this.colors,
    required this.shades,
    required this.shapes,
    required this.clarities,
    required this.totalWishlist,
  });

  static const empty = SolitaireIndex(
    status: 1,
    login: 0,
    isPriceHide: 0,
    ticker: [],
    colors: [],
    shades: [],
    shapes: [],
    clarities: [],
    totalWishlist: 0,
  );
}
