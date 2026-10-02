// Classe Slider pour contrôler le volume
class Slider {
  float x, y, w, h;
  float valeurMin, valeurMax, valeur;
  boolean enGlissement = false;

  Slider(float x, float y, float w, float h, float min, float max, float valeurInitiale) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.valeurMin = min;
    this.valeurMax = max;
    this.valeur = valeurInitiale;
  }

  void afficher() {
    // Barre de fond
    stroke(couleurBoutonContour);
    strokeWeight(2);
    fill(couleurBoutonFond);
    rect(x, y, w, h, h/2);

    // Barre de progression
    float progression = map(valeur, valeurMin, valeurMax, 0, w);
    noStroke();
    fill(100, 150, 255);
    rect(x, y, progression, h, h/2);

    // Curseur
    float curseurX = map(valeur, valeurMin, valeurMax, x, x + w);
    stroke(couleurBoutonContourSurvol);
    strokeWeight(2);
    fill(enGlissement || estSurvole() ? couleurBoutonFondSurvol : 255);
    circle(curseurX, y + h/2, h * 1.5);
  }


  boolean estSurvole() {
    float curseurX = map(valeur, valeurMin, valeurMax, x, x + w);
    return dist(mouseX, mouseY, curseurX, y + h/2) < h;
  }

  void presser() {
    if (estSurvole() || (mouseX >= x && mouseX <= x + w && mouseY >= y - h && mouseY <= y + h*2)) {
      enGlissement = true;
      mettreAJourValeur();
    }
  }

  void glisser() {
    if (enGlissement) {
      mettreAJourValeur();
    }
  }

  void relacher() {
    enGlissement = false;
  }

  void mettreAJourValeur() {
    float nouvelleValeur = map(mouseX, x, x + w, valeurMin, valeurMax);
    valeur = constrain(nouvelleValeur, valeurMin, valeurMax);
  }

  float getValeur() {
    return valeur;
  }

  void setValeur(float nouvelleValeur) {
    valeur = constrain(nouvelleValeur, valeurMin, valeurMax);
  }
}
