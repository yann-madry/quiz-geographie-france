// ==================== CLASSE THEME ====================
// Gère les couleurs et polices de l'application
class Theme {
  int FOND, PANEL, TEXTE, TITRE, VERT, ROUGE, OR, BULLE;
  PFont fontTitre, fontNormal;
  
  Theme() {
    fontTitre = createFont("Arial Bold", 24);
    fontNormal = createFont("Arial", 14);
    setMode(true); // Mode sombre par défaut
  }
  
  void setMode(boolean sombre) {
    if (sombre) {
      // Palette sombre
      FOND = 0xFF282C34;
      PANEL = 0xFF21252B;
      TEXTE = 0xFFABB2BF;
      TITRE = 0xFF61AFEF;
      VERT = 0xFF98C379;
      ROUGE = 0xFFE06C75;
      OR = 0xFFFFD700;
      BULLE = 0xDDFFFFFF;
    } else {
      // Palette claire
      FOND = 0xFFF0F0F0;
      PANEL = 0xFFFFFFFF;
      TEXTE = 0xFF333333;
      TITRE = 0xFF007ACC;
      VERT = 0xFF33AA33;
      ROUGE = 0xFFAA3333;
      OR = 0xFFFFA500;
      BULLE = 0xDDFFFFFF;
    }
  }
}
