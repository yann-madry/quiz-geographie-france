// ==================== CLASSE DEPARTEMENT ====================
// Cette classe représente un département français (forme SVG)
class Departement {
  PShape forme;           // Forme SVG du département
  String id;              // Identifiant (ex: "75" pour Paris)
  float x, y;             // Position actuelle
  float homeX, homeY;     // Position d'origine (pour le puzzle)
  float echelle;          // Facteur d'échelle
  float minX, minY, maxX, maxY;  // Limites de la forme (hitbox)
  boolean verouiller = false;    // true = placé correctement
  color couleurActuelle;         // Couleur affichée
  color couleurBase = color(200); // Couleur par défaut

  Departement(PShape s, String nomComplet) {
    this.forme = s;
    this.forme.disableStyle();

    String nomBrut = (nomComplet != null) ? nomComplet : s.getName();
    this.id = (nomBrut != null) ? nomBrut.replace("dep_", "") : "";

    // Calcul de la hitbox
    float[] b = hitbox(forme);
    minX = b[0];
    minY = b[1];
    maxX = b[2];
    maxY = b[3];
  }

  // Affiche le département à l'écran
  void affiche() {
    pushMatrix();
    translate(x, y);
    scale(echelle);
    if (couleurActuelle != theme.PANEL) {
      fill(couleurActuelle);
      stroke(0);
      strokeWeight(1.2 / echelle);
    } else if (verouiller) {
      fill(theme.PANEL);
      stroke(255, 40);
      strokeWeight(0.5 / echelle);
    } else {
      fill(couleurActuelle);
      stroke(0);
      strokeWeight(1.5 / echelle);
    }

    shape(forme, 0, 0);
    popMatrix();
  }

  boolean hit(float mx, float my) {
    // 1. Conversion dans le repère local de la pièce
    float lx = (mx - x) / echelle;
    float ly = (my - y) / echelle;

    // 2. Test rapide : rectangle englobant
    if (lx < minX || lx > maxX || ly < minY || ly > maxY) {
      return false;
    }

    // 3. Test précis : forme exacte
    return forme.contains(lx, ly);
  }
}
