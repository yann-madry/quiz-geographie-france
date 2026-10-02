// ==================== CLASSE BOUTTON ====================
// Cette classe gère l'affichage et les interactions des boutons
class Boutton {
  int x, y, w, h;
  String texte;
  boolean surbrillance;
  
  // Constructeur : crée un bouton avec position et texte
  Boutton(int x, int y, int w, int h, String t) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.texte = t;
  }
  
  // Met à jour l'état de surbrillance (survol souris)
  void mettreAJour() {
    surbrillance = mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h;
  }
  
  // Vérifie si le bouton est cliqué
  boolean estClique() {
    return mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h;
  }
  
  // Affiche le bouton avec les couleurs du thème actuel
  void afficher() {
    // Couleurs différentes selon survol ou non
    if (surbrillance) {
      fill(couleurBoutonFondSurvol);
      stroke(couleurBoutonContourSurvol);
      strokeWeight(3);
    } else {
      fill(couleurBoutonFond);
      stroke(couleurBoutonContour);
      strokeWeight(2);
    }
    
    // Dessin du rectangle avec coins arrondis
    rect(x, y, w, h, 12);
    
    // Texte centré
    fill(couleurBoutonTexte);
    textAlign(CENTER, CENTER);
    noStroke();
    textSize(28);
    text(texte, x + w/2, y + h/2);
  }
}
