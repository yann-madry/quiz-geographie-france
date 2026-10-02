import processing.sound.*;
import java.util.*;

// =========================================================
// 1) musiques / sons + paramètres
// =========================================================
SoundFile intro, menu, apprendre, parametres, jeu1, jeu2, jeu3, jeu4;
SoundFile Lose, Win, capital_win, boutton, musiqueActuelle;

float volume = 0.5;          // volume global (0..1)
Slider sliderVolume;
boolean son = true;          // son on/off
boolean introDejaJouee = false;
boolean menuLance = false;   // évite de relancer la musique menu en boucle


// =========================================================
// 2) ETATS (pages)
// =========================================================
final int ACCUEIL         = 0;
final int JEU             = 1;
final int APPRENDRE       = 2;
final int PARAMETRES      = 3;
final int MENU_PUZZLE     = 4;
final int PUZZLE          = 5;
final int QUIZ_TEXTE      = 6;
final int QUIZ_CARTE      = 7;
final int QUIZ_PHOTO      = 8;
final int QUIZ_MULTIPLE   = 9;
final int QUIZ_CHAUDFROID = 10;

int actuel = ACCUEIL;

// =========================================================
// 3) (carte à gauche / panneau à droite)
// =========================================================
final int PANEL_W = 520;       // largeur de la zone droite
final int PANEL_MARGIN = 60;   // marge haute/basse des panneaux
final int BOTTOM_BAR_H = 90;   //bas pour boutons accueil/quitter

// =========================================================
// 4)clair/sombre
// =========================================================
boolean clair = false;

int couleurFond, couleurTextePrincipal, couleurTexteSecondaire, couleurTraits;
int couleurBoutonFond, couleurBoutonFondSurvol, couleurBoutonContour;
int couleurBoutonContourSurvol, couleurBoutonTexte, couleurVoile;

int alphaVoile = 50; // intensité du voile --> menu


// =========================================================
// 5) IMAGES menus
// =========================================================
PImage planete, arc;


// =========================================================
// 6) CARTE + PUZZLE : svg + départements + drag
// =========================================================
PShape france;
ArrayList<Departement> departements = new ArrayList<Departement>();

Departement attraper = null;   // pièce actuellement attrapée (puzzle)
float attraperDX, attraperDY;  // décalage souris -> pièce pour drag fluide

// Zone carte : tout ce qui est à gauche du panneau
float zoneX, zoneY, zoneW, zoneH;

int n = 5;        // nombre de pièces à replacer au puzzle (selon niveau)
int restant = 0;  // compteur pièces restantes (puzzle)


// =========================================================
// 7) BOUTONS
// =========================================================
Boutton bouttonJouer, bouttonAppr, bouttonPARA, bouttonQUIT;
Boutton bouttonLumi, bouttonSon;
Boutton boutonAccueilBR, boutonQuitterBR; // bas droite

Boutton j1, j2, j3, j4, j5, j6;      // boutons menu "JEU"

Boutton nv1, nv2, nv3, nv4, nv5, nv6; // niveaux puzzle
Boutton bouttonRejouer, bouttonRetourPuzzle, bouttonNvSuiv;


// =========================================================
// 8) SYSTEME QUIZ : données + panneaux + moteur
// =========================================================
Theme theme;
Donnees bdd;
InfoBulle bulle;

PanneauInfo panneauLateral;
PanneauQuiz panneauJeu;
PanneauMultiple panneauMultiple;

Quiz moteurQuiz;
Question questionEnCours;

int score = 0;
int tentatives = 0;

String messageReponse = "";     // message quiz texte/carte
PImage imgMystere;
String idMystere = "";
String messageJeuPhoto = "";

Boutton btnSkip;                // bouton "PASSER" (photo)


// =========================================================
// 9) QUIZ MULTIPLE : nb de cibles à trouver dans un round
// =========================================================
int multiK = 4;

HashMap<String, String> multiIdVersNom = new HashMap<String, String>();
HashSet<String> multiCibles = new HashSet<String>();
HashSet<String> multiTrouves = new HashSet<String>();

String messageMultiple = "";

// Transition visuelle fin de round (quiz multiple)
boolean transitionMultiple = false;
int transitionT = 0;


// =========================================================
// 10) CHAUD/FROID : deviner un département via proximité
// =========================================================
String cibleId = "";
String cibleNom = "";
int clicksChaudFroid = 0;   // nb de clics pour cette cible
float chaleur = 0;          // 0..1 (1 = très chaud)

String messageChaudFroid = ""; // message du mode chaud/froid (séparé des autres)

boolean transitionCF = false;
int tCF = 0;


// =========================================================
// SETUP : initialisation (une seule fois au lancement)
// =========================================================
void setup() {
  fullScreen();
  frameRate(60);

  // Zone carte = tout l'écran moins le panneau droit
  zoneX = 0;
  zoneY = 0;
  zoneW = width - PANEL_W;
  zoneH = height;

  // Objets logiques / data
  theme = new Theme();
  bdd = new Donnees();

  // Images des menus
  planete = loadImage("Images/photo.jpg");
  arc = loadImage("Images/arc.jpg");

  // Intro audio
  intro = new SoundFile(this, "Sons/intro.wav");
  intro.play();
  introDejaJouee = true;

  // Carte France SVG
  france = loadShape("france.svg");

  // On transforme le SVG en liste de "Departement" (un objet par PATH)
  extractDepartements(france);

  // On calcule la transform (scale + translate) pour que la carte tienne dans zoneW/height
  ratio(france, zoneX, zoneY, zoneW, zoneH);
  reinitialiserDepartements();

  // UI : infobulle + panneaux (mêmes positions partout grâce au layout)
  bulle = new InfoBulle();

  int panelX = width - PANEL_W + 20;
  int panelY = PANEL_MARGIN;
  int panelH = height - PANEL_MARGIN * 2 - BOTTOM_BAR_H;

  panneauLateral  = new PanneauInfo(panelX, panelY, PANEL_W - 40, panelH);
  panneauJeu      = new PanneauQuiz(panelX, panelY, PANEL_W - 40, panelH);
  panneauMultiple = new PanneauMultiple(panelX, panelY, PANEL_W - 40, panelH);

  // Moteur de quiz (utilise bdd)
  moteurQuiz = new Quiz(bdd);

  // Crée tous les boutons (menus + jeux + puzzle)
  initBoutons();
}

void initBoutons() {
  int playW = 300;
  int playH = 60;
  int playX = width/2 - playW/2;
  int playY = height/2 - playH*2;

  bouttonJouer = new Boutton(playX, playY, playW, playH, "JOUER");
  bouttonAppr  = new Boutton(playX, playY + playH*3/2, playW, playH, "APPRENDRE");
  bouttonPARA  = new Boutton(playX, playY + playH*6/2, playW, playH, "PARAMETRES");
  bouttonQUIT  = new Boutton(playX, playY + playH*9/2, playW, playH, "QUITTER");

  bouttonLumi = new Boutton(playX, playY, playW, playH, "FOND");
  bouttonSon  = new Boutton(playX, playY + playH*3/2, playW, playH, "SON");
  sliderVolume = new Slider(playX, playY + playH*3, playW, 30, 0, 1, volume);

  // Boutons de sélection de modes (page JEU)
  int jW = 200;
  int jH = 150;
  int jX = width/10;
  int jY = height*2/5;

  j1 = new Boutton(jX, jY, jW, jH, "Puzzle");
  j2 = new Boutton(jX*8/3, jY, jW, jH, "Quiz Texte");
  j3 = new Boutton(jX*13/3, jY, jW, jH, "Quiz Carte");
  j4 = new Boutton(jX*18/3, jY, jW, jH, "Quiz Photo");
  j5 = new Boutton(jX*23/3, jY, jW, jH, "Quiz Multiple");
  j6 = new Boutton(jX*13/3, jY*165/100, jW, jH, "Chaud/Froid");

  // Boutons bas droite stable grâce à BOTTOM_BAR_H
  int bw = 200;
  int bh = 50;
  int bmarge = 30;
  int bespace = 15;

  int xQuit = width - bw - bmarge;
  int y = height - BOTTOM_BAR_H + (BOTTOM_BAR_H - bh)/2; // centre verticalement dans la barre
  int xAccueil = xQuit - bw - bespace;

  boutonAccueilBR = new Boutton(xAccueil, y, bw, bh, "ACCUEIL");
  boutonQuitterBR = new Boutton(xQuit, y, bw, bh, "QUITTER");

  // Niveaux puzzle
  nv1 = new Boutton(jX, jY, jW, jH, "Niveau 1");
  nv2 = new Boutton(jX*8/3, jY, jW, jH, "Niveau 2");
  nv3 = new Boutton(jX*13/3, jY, jW, jH, "Niveau 3");
  nv4 = new Boutton(jX*18/3, jY, jW, jH, "Niveau 4");
  nv5 = new Boutton(jX*23/3, jY, jW, jH, "Niveau 5");
  nv6 = new Boutton(jX*13/3, jY*165/100, jW, jH, "Niveau 6");

  // Boutons fin puzzle
  bouttonRejouer = new Boutton(int(0.38*width), int(0.6*height), bw, bh, "Rejouer");
  bouttonNvSuiv  = new Boutton(int(0.52*width), int(0.6*height), bw, bh, "Niveau suivant");
  bouttonRetourPuzzle = new Boutton(int(0.85*width), int(0.9*height), bw, bh, "Retour");

  // Photo : bouton passer (si trop d'erreurs)
  btnSkip = new Boutton(width - 400, height - 150, 150, 50, "PASSER");
}


// =========================================================
// calcule (clair/sombre) à chaque frame
// =========================================================

void appliquerThemeCouleur() {
  if (clair) {
    couleurFond = 235;
    couleurTextePrincipal = 0;
    couleurTexteSecondaire = 40;
    couleurTraits = 0;

    couleurBoutonFond = 180;
    couleurBoutonFondSurvol = 210;
    couleurBoutonContour = 40;
    couleurBoutonContourSurvol = 0;
    couleurBoutonTexte = 0;

    couleurVoile = 255;
  } else {
    couleurFond = 0;
    couleurTextePrincipal = 255;
    couleurTexteSecondaire = 180;
    couleurTraits = 255;

    couleurBoutonFond = 40;
    couleurBoutonFondSurvol = 80;
    couleurBoutonContour = 180;
    couleurBoutonContourSurvol = 255;
    couleurBoutonTexte = 255;

    couleurVoile = 0;
  }
}


void draw() {
  appliquerThemeCouleur();

  // Une fois l'intro terminée, on lance la musique du menu
  if (intro != null && !intro.isPlaying() && !menuLance) {
    menuLance = true;
    JoueMusiquePage();
  }

  if (actuel == ACCUEIL)             dessinerEcranMenu();
  else if (actuel == JEU)            dessinerEcranJeu();
  else if (actuel == APPRENDRE)      dessinerEcranAppr();
  else if (actuel == PARAMETRES)     dessinerEcranPARA();
  else if (actuel == MENU_PUZZLE)    dessinerEcranNvPuzzle();
  else if (actuel == PUZZLE)         dessinerEcranPuzzle();
  else if (actuel == QUIZ_TEXTE)     dessinerEcranQuizTexte();
  else if (actuel == QUIZ_CARTE)     dessinerEcranQuizCarte();
  else if (actuel == QUIZ_PHOTO)     dessinerEcranQuizPhoto();
  else if (actuel == QUIZ_MULTIPLE)  dessinerEcranQuizMultiple();
  else if (actuel == QUIZ_CHAUDFROID) dessinerEcranChaudFroid();
}

void dessinerVoile() {
  noStroke();
  fill(couleurVoile, alphaVoile);
  rect(0, 0, width, height);
}

void dessinerTitre(String texte) {
  textAlign(CENTER, CENTER);

  textSize(150);
  fill(couleurTextePrincipal);
  text("GÉO", width/2, height*0.2);

  textSize(60);
  fill(couleurTexteSecondaire);
  text(texte, width/2, height*0.28);

  stroke(couleurTraits);
  strokeWeight(4);
  line(width*0.3, height*0.33, width*0.7, height*0.33);
}

//(accueil / quitter)
void afficherBoutonsBasDroite() {
  boutonAccueilBR.mettreAJour();
  boutonAccueilBR.afficher();

  boutonQuitterBR.mettreAJour();
  boutonQuitterBR.afficher();
}


// =========================================================
// dessins
// =========================================================
void dessinerEcranMenu() {
  if (planete != null) image(planete, 0, 0, width, height);
  dessinerVoile();
  dessinerTitre("FRANCE");

  bouttonJouer.mettreAJour();
  bouttonJouer.afficher();
  bouttonAppr.mettreAJour();
  bouttonAppr.afficher();
  bouttonPARA.mettreAJour();
  bouttonPARA.afficher();
  bouttonQUIT.mettreAJour();
  bouttonQUIT.afficher();
}

void dessinerEcranJeu() {
  if (arc != null) image(arc, 0, 0, width, height);
  dessinerVoile();
  dessinerTitre("JEU");

  j1.mettreAJour();
  j1.afficher();
  j2.mettreAJour();
  j2.afficher();
  j3.mettreAJour();
  j3.afficher();
  j4.mettreAJour();
  j4.afficher();
  j5.mettreAJour();
  j5.afficher();
  j6.mettreAJour();
  j6.afficher();

  afficherBoutonsBasDroite();
}

void dessinerEcranAppr() {
  background(couleurFond);

  dessinerCarteInteractive();
  panneauLateral.dessin();
  gererInfoBulle();               // infobulle au survol

  afficherBoutonsBasDroite();
}

void dessinerEcranPARA() {
  background(couleurFond);
  dessinerTitre("PARAMETRES");

  bouttonLumi.texte = clair ? "FOND : BLANC" : "FOND : NOIR";
  bouttonLumi.mettreAJour();
  bouttonLumi.afficher();

  bouttonSon.texte = son ? "SON : ON" : "SON : OFF";
  bouttonSon.mettreAJour();
  bouttonSon.afficher();

  sliderVolume.afficher();
  textSize(20);
  fill(couleurTexteSecondaire);
  text("Volume: " + int(volume * 100) + "%", width/2, sliderVolume.y + 50);

  afficherBoutonsBasDroite();
}

void dessinerEcranNvPuzzle() {
  background(couleurFond);
  dessinerTitre("PUZZLE");

  nv1.mettreAJour();
  nv1.afficher();
  nv2.mettreAJour();
  nv2.afficher();
  nv3.mettreAJour();
  nv3.afficher();
  nv4.mettreAJour();
  nv4.afficher();
  nv5.mettreAJour();
  nv5.afficher();
  nv6.mettreAJour();
  nv6.afficher();

  afficherBoutonsBasDroite();
}

void dessinerEcranPuzzle() {
  background(20);

  //(gauche carte / droite pièces)
  noStroke();
  fill(0);
  rect(zoneX, zoneY, zoneW, zoneH);

  fill(40);
  rect(zoneW, 0, width-zoneW, height);

  // Carte en fond (blanche) pour guider
  pushMatrix();
  france.disableStyle();
  fill(255);
  noStroke();
  shape(france, 0, 0);
  popMatrix();

  // On dessine d'abord les pièces verrouillées, puis les pièces déplacables.
  // But : éviter que la pièce attrapée soit dessinée "sous" les autres.
  restant = 0;
  ArrayList<Departement> depToDraw = new ArrayList<Departement>();

  for (Departement p : departements) {
    if (!p.verouiller) {
      restant++;

      // Coloration simple
      if (p == attraper || (attraper == null && p.hit(mouseX, mouseY))) {
        p.couleurActuelle = color(theme.TITRE);
      } else {
        p.couleurActuelle = color(200);
      }

      if (p != attraper) depToDraw.add(p);
    } else {
      if (p != attraper) p.affiche();
    }
  }

  for (Departement p : depToDraw) p.affiche();
  if (attraper != null) attraper.affiche();

  // Infos à droite
  fill(theme.TITRE);
  textAlign(CENTER, TOP);
  textSize(28);
  text("Départements\nrestants : " + restant, zoneW + (width-zoneW)/2, 0.1*height);

  // Retour puzzle
  bouttonRetourPuzzle.mettreAJour();
  bouttonRetourPuzzle.afficher();

  // Fin puzzle : overlay + boutons
  if (restant == 0) {
    dessinerVoile();
    fill(40);
    rect(width/3, height/3, width/3, height/3, 20);
    fill(0, 200, 0);
    textAlign(CENTER, CENTER);
    text("Bravo ! Terminé !", width/2, 0.4*height);

    bouttonRejouer.mettreAJour();
    bouttonRejouer.afficher();

    if (n != 30) {
      bouttonNvSuiv.mettreAJour();
      bouttonNvSuiv.afficher();
    }
  }
}

void dessinerEcranQuizTexte() {
  background(couleurFond);
  dessinerCarteFixe();
  panneauJeu.dessin(score, messageReponse);
  afficherBoutonsBasDroite();
}

void dessinerEcranQuizCarte() {
  background(couleurFond);
  dessinerCarteInteractiveQuiz();
  panneauJeu.dessin(score, messageReponse);
  afficherBoutonsBasDroite();
}

void dessinerEcranQuizPhoto() {
  background(couleurFond);

  dessinerCarteInteractive();
  panneauLateral.dessinModeDevinette(imgMystere, messageJeuPhoto, score);
  gererInfoBulle();

  afficherBoutonsBasDroite();

  // "PASSER" après 3 tentatives
  if (tentatives >= 3) {
    btnSkip.mettreAJour();
    btnSkip.afficher();
  }
}

void dessinerEcranQuizMultiple() {
  background(couleurFond);

  dessinerCarteInteractiveQuizMultiple();
  panneauMultiple.dessin(score, messageMultiple, multiIdVersNom, multiCibles, multiTrouves);

  afficherBoutonsBasDroite();

  // Transition de fin de round : voile + halo (effet doux)
  if (transitionMultiple) {
    transitionT++;

    float p = constrain(transitionT / 45.0, 0, 1);
    p = 1 - pow(1 - p, 3); // belle transition qui accelere et ralentit

    noStroke();
    fill(0, 120 * p);
    rect(0, 0, width, height);

    float cx = zoneW / 2;
    float cy = height / 2;
    float r  = p * max(zoneW, height);

    noFill();
    stroke(120, 255, 180, 180 * (1 - p));
    strokeWeight(6);
    ellipse(cx, cy, r, r);

    // Fin transition -> nouvelle question
    if (transitionT >= 45) {
      transitionMultiple = false;
      nouvelleQuestionMultiple();
    }
  }
}

void dessinerEcranChaudFroid() {
  background(couleurFond);
  dessinerCarteInteractiveChaudFroid();

  // Séparation visuelle carte / panneau (simple et propre)
  stroke(60);
  line(zoneW, 0, zoneW, height);
  noStroke();
  dessinerPanneauChaudFroid();
  afficherBoutonsBasDroite();

  // Transition quand trouvé : voile + halo puis nouvelle cible
  if (transitionCF) {
    tCF++;

    float p = constrain(tCF / 45.0, 0, 1);
    p = 1 - pow(1 - p, 3); // easing

    fill(0, 120 * p);
    noStroke();
    rect(0, 0, width, height);

    float cx = zoneW / 2;
    float cy = height / 2;
    float r  = p * max(zoneW, height);

    noFill();
    stroke(120, 255, 180, 180 * (1 - p));
    strokeWeight(6);
    ellipse(cx, cy, r, r);

    if (tCF >= 45) {
      transitionCF = false;
      nouvelleCibleChaudFroid();
    }
  }
}

void dessinerCarteFixe() {
  pushMatrix();
  france.disableStyle();
  fill(theme.PANEL);
  noStroke();
  shape(france, 0, 0);
  popMatrix();

  for (Departement d : departements) {
    d.verouiller = true;
    d.couleurActuelle = theme.PANEL;
    d.affiche();
  }
}

void dessinerCarteInteractive() {
  pushMatrix();
  france.disableStyle();
  fill(theme.PANEL);
  noStroke();
  shape(france, 0, 0);
  popMatrix();

  for (Departement d : departements) {
    d.verouiller = true;

    // Apprendre : survol + sélection depuis panneau
    if (d.id.equals(panneauLateral.idActuel)) {
      d.couleurActuelle = theme.TITRE;
    } else if (d.hit(mouseX, mouseY)) {
      d.couleurActuelle = theme.TITRE;
    } else {
      d.couleurActuelle = theme.PANEL;
    }

    d.affiche();
  }
}

void dessinerCarteInteractiveQuiz() {
  pushMatrix();
  france.disableStyle();
  fill(theme.PANEL);
  noStroke();
  shape(france, 0, 0);
  popMatrix();

  // ID attendu pour le highlight (normalisé)
  String cible = "";
  if (questionEnCours != null) {
    // si idMap est vide/null chez toi, on tente un fallback
    cible = normId(questionEnCours.idMap);
    if (cible.equals("")) {
      // fallback fréquent selon les moteurs : parfois l'id est stocké ailleurs
      // (décommente la bonne ligne selon ta classe Question)
      // cible = normId(questionEnCours.id);
      // cible = normId(questionEnCours.idDepartement);
    }
  }

  for (Departement d : departements) {
    d.verouiller = true;

    if (!cible.equals("") && normId(d.id).equals(cible)) {
      d.couleurActuelle = theme.TITRE;   // highlight
    } else {
      d.couleurActuelle = theme.PANEL;
    }

    d.affiche();
  }
}


void dessinerCarteInteractiveQuizMultiple() {
  pushMatrix();
  france.disableStyle();
  fill(theme.PANEL);
  noStroke();
  shape(france, 0, 0);
  popMatrix();

  for (Departement d : departements) {
    d.verouiller = true;

    // Multiple : trouvé = vert, hover = titre, sinon neutre
    if (multiTrouves.contains(d.id)) {
      d.couleurActuelle = theme.VERT;
    } else if (d.hit(mouseX, mouseY)) {
      d.couleurActuelle = theme.TITRE;
    } else {
      d.couleurActuelle = theme.PANEL;
    }

    d.affiche();
  }
}

void dessinerCarteInteractiveChaudFroid() {
  pushMatrix();
  france.disableStyle();
  fill(theme.PANEL);
  noStroke();
  shape(france, 0, 0);
  popMatrix();

  for (Departement d : departements) {
    d.verouiller = true;

    // Quand la cible est trouvée : pulse vert (pendant la transition)
    if (transitionCF && d.id.equals(cibleId)) {
      float pulse = 0.5 + 0.5 * sin(frameCount * 0.12);
      d.couleurActuelle = lerpColor(theme.PANEL, theme.VERT, pulse);
    }
    // Sinon hover bleu/titre
    else if (d.hit(mouseX, mouseY)) {
      d.couleurActuelle = theme.TITRE;
    }
    // Sinon neutre
    else {
      d.couleurActuelle = theme.PANEL;
    }

    d.affiche();
  }
}

void mousePressed() {

  // ------------------- ACCUEIL -------------------
  if (actuel == ACCUEIL) {

    if (bouttonJouer.estClique()) {
      jouerSonBouton();

      actuPage(JEU);
    }
    if (bouttonAppr.estClique()) {
      jouerSonBouton();
      lancerModeApprendre();
    }
    if (bouttonPARA.estClique()) {
      jouerSonBouton();
      actuPage(PARAMETRES);
    }
    if (bouttonQUIT.estClique()) {
      jouerSonBouton();
      exit();
    }
    return;
  }

  // ------------------- PARAMETRES -------------------
  if (actuel == PARAMETRES) {
    if (bouttonLumi.estClique()) {
      jouerSonBouton();
      clair = !clair;
    }
    if (bouttonSon.estClique()) {
      jouerSonBouton();
      son = !son;
      // Si on désactive le son, mettre le slider à 0
      if (!son) {
        sliderVolume.setValeur(0);
        volume = 0;
      } else {
        // Si on réactive le son, remettre un volume par défaut si à 0
        if (volume == 0) {
          volume = 0.5;
          sliderVolume.setValeur(0.5);
        }
      }
      JoueMusiquePage();
    }
    sliderVolume.presser();
  }

  // ------------------- MENU JEU -------------------
  if (actuel == JEU) {
    if (j1.estClique()) {
      jouerSonBouton();
      actuPage(MENU_PUZZLE);
      return;
    }
    if (j2.estClique()) {
      jouerSonBouton();
      lancerModeQuiz(QUIZ_TEXTE);
      return;
    }
    if (j3.estClique()) {
      jouerSonBouton();
      lancerModeQuiz(QUIZ_CARTE);
      return;
    }
    if (j4.estClique()) {
      jouerSonBouton();
      lancerModePhoto();
      return;
    }
    if (j5.estClique()) {
      jouerSonBouton();
      lancerModeQuizMultiple();
      return;
    }
    if (j6.estClique()) {
      jouerSonBouton();
      lancerModeChaudFroid();
      return;
    }
  }

  // ------------------- MENU PUZZLE -------------------
  if (actuel == MENU_PUZZLE) {
    if (nv1.estClique()) {
      n = 5;
      piecesAPlacer(n);
      actuPage(PUZZLE);
      return;
    }
    if (nv2.estClique()) {
      n = 10;
      piecesAPlacer(n);
      actuPage(PUZZLE);
      return;
    }
    if (nv3.estClique()) {
      n = 15;
      piecesAPlacer(n);
      actuPage(PUZZLE);
      return;
    }
    if (nv4.estClique()) {
      n = 20;
      piecesAPlacer(n);
      actuPage(PUZZLE);
      return;
    }
    if (nv5.estClique()) {
      n = 25;
      piecesAPlacer(n);
      actuPage(PUZZLE);
      return;
    }
    if (nv6.estClique()) {
      n = 30;
      piecesAPlacer(n);
      actuPage(PUZZLE);
      return;
    }
  }

  // ------------------- PUZZLE -------------------
  if (actuel == PUZZLE) {
    if (bouttonRetourPuzzle.estClique()) {
      reinitialiserDepartements();
      actuPage(MENU_PUZZLE);
      return;
    }

    // Boutons de fin (si terminé)
    if (restant == 0 && bouttonRejouer.estClique()) {
      piecesAPlacer(n);
      return;
    }
    if (restant == 0 && bouttonNvSuiv.estClique() && n < 30) {
      n += 5;
      piecesAPlacer(n);
      return;
    }

    // Attraper une pièce (en partant de la fin pour prendre celle "au-dessus")
    for (int i = departements.size()-1; i >= 0; i--) {
      Departement p = departements.get(i);
      if (p.verouiller) continue;

      if (p.hit(mouseX, mouseY)) {
        attraper = p;

        // On met la pièce à la fin de la liste pour la dessiner au-dessus
        departements.remove(i);
        departements.add(attraper);

        // Deltas pour garder la même prise pendant le drag
        attraperDX = mouseX - attraper.x;
        attraperDY = mouseY - attraper.y;
        return;
      }
    }
  }

  // ------------------- APPRENDRE -------------------
  if (actuel == APPRENDRE) {
    for (Departement d : departements) {
      if (d.hit(mouseX, mouseY)) {
        panneauLateral.selectionner(d.id);
        jouerSonBouton();
        break;
      }
    }
  }

  // ------------------- QUIZ TEXTE/CARTE -------------------
  if (actuel == QUIZ_TEXTE || actuel == QUIZ_CARTE) {
    verifierReponseQuizBoutons();
  }

  // ------------------- QUIZ MULTIPLE -------------------
  if (actuel == QUIZ_MULTIPLE) {
    verifierReponseQuizMultiple();
  }

  // ------------------- CHAUD/FROID -------------------
  if (actuel == QUIZ_CHAUDFROID) {
    verifierChaudFroid();
  }

  // ------------------- QUIZ PHOTO -------------------
  if (actuel == QUIZ_PHOTO) {
    if (tentatives >= 3 && btnSkip.estClique()) {
      jouerSonBouton();
      changerImageMystere();
      messageJeuPhoto = "Passé ! La réponse était : " + bdd.getInfos(idMystere).nom;
    } else {
      verifierReponseQuizPhoto();
    }
  }

  // ------------------- Boutons persistants (sauf ACCUEIL) -------------------
  if (actuel != ACCUEIL) {
    if (boutonAccueilBR.estClique()) {
      jouerSonBouton();
      reinitialiserDepartements();

      actuPage(ACCUEIL);
    }
    if (boutonQuitterBR.estClique()) {
      jouerSonBouton();
      exit();
    }
  }
}


// Drag puzzle : déplace la pièce actuellement attrapée
void mouseDragged() {
  if (actuel == PARAMETRES) {
    sliderVolume.glisser();
    volume = sliderVolume.getValeur();

    // Si le slider est à 0, désactiver le son
    if (volume == 0) {
      son = false;
    } else {
      // Si le slider n'est pas à 0, activer le son
      if (!son) {
        son = true;
      }
    }

    // Mettre à jour le volume de la musique en cours
    if (musiqueActuelle != null && son) {
      musiqueActuelle.amp(volume);
    }
  }
  if (actuel == PUZZLE && attraper != null) {
    attraper.x = mouseX - attraperDX;
    attraper.y = mouseY - attraperDY;
  }
}

// Release puzzle : si assez proche de home -> verrouille la pièce
void mouseReleased() {
  if (actuel == PARAMETRES) {
    sliderVolume.relacher();
  }
  if (actuel == PUZZLE && attraper != null) {
    if (dist(attraper.x, attraper.y, attraper.homeX, attraper.homeY) < 25) {
      attraper.x = attraper.homeX;
      attraper.y = attraper.homeY;
      attraper.verouiller = true;
      attraper.couleurActuelle = theme.PANEL;
    }

    attraper = null;
  }
}


// =========================================================
// NAVIGATION : change de page + musique
// =========================================================
void actuPage(int nouvellePage) {
  if (actuel == nouvellePage) return;
  actuel = nouvellePage;
  JoueMusiquePage();
}

void JoueMusiquePage() {
  if (!son) {
    stopAllMusic();
    musiqueActuelle = null;
    return;
  }

  // Lazy loading : on charge un son seulement si besoin
  if (actuel == PARAMETRES && parametres == null) parametres = new SoundFile(this, "Sons/attaque.wav");
  if (actuel == PUZZLE && jeu1 == null)          jeu1 = new SoundFile(this, "Sons/Capital.wav");
  if (actuel == JEU && jeu2 == null)            jeu2 = new SoundFile(this, "Sons/Capital_Combat.wav");
  if (actuel == MENU_PUZZLE && menu == null)    menu = new SoundFile(this, "Sons/clashof.wav");

  SoundFile cible = null;

  if (actuel == ACCUEIL)     cible = menu;
  if (actuel == PARAMETRES)  cible = parametres;
  if (actuel == PUZZLE)      cible = jeu1;
  if (actuel == JEU)         cible = jeu2;
  if (actuel == MENU_PUZZLE) cible = menu;

  if (cible == null) return;

  stopAllMusic();
  musiqueActuelle = cible;
  musiqueActuelle.amp(volume);
  musiqueActuelle.loop();
}

// Son de clic : simple, on relance toujours depuis le début
void jouerSonBouton() {
  if (!son) return;
  if (boutton == null) boutton = new SoundFile(this, "Sons/boutton.wav");

  boutton.stop();
  boutton.amp(volume);
  boutton.play();
}

// Stop all : évite les superpositions en changeant de page
void stopAllMusic() {
  if (menu != null) menu.stop();
  if (parametres != null) parametres.stop();
  if (jeu1 != null) jeu1.stop();
  if (jeu2 != null) jeu2.stop();
  if (jeu3 != null) jeu3.stop();
  if (jeu4 != null) jeu4.stop();
  if (Win != null) Win.stop();
  if (Lose != null) Lose.stop();
  if (capital_win != null) capital_win.stop();
}


// =========================================================
// CARTE : extraction des départements depuis le SVG
// =========================================================
void extractDepartements(PShape dep) {
  departements.clear();
  traverse(dep);
}

// Parcours récursif : chaque PATH devient un Departement (id = name du PATH)
void traverse(PShape s) {
  if (s == null) return;

  if (s.getFamily() == PShape.PATH) {
    departements.add(new Departement(s, s.getName()));
  }

  for (int i = 0; i < s.getChildCount(); i++) {
    traverse(s.getChild(i));
  }
}


// =========================================================
// RATIO : mise à l’échelle de la carte pour rentrer dans la zone gauche
// =========================================================
void ratio(PShape s, float x, float y, float w, float h) {
  float sw = max(1, s.width);
  float sh = max(1, s.height);

  // On garde le ratio : on prend l’échelle la plus petite pour que tout rentre
  float echelle = min(w/sw, h/sh);

  // Centrage dans la zone
  float dX = x + (w - sw*echelle) / 2.0;
  float dY = y + (h - sh*echelle) / 2.0;

  // On stocke la transform pour chaque département (utile pour hit/draw/centres)
  for (Departement p : departements) {
    p.homeX = dX;
    p.homeY = dY;
    p.echelle = echelle;
  }

  // Transform appliquée au PShape global
  france.resetMatrix();
  france.translate(dX, dY);
  france.scale(echelle);
}


// Remet les départements à l’état de base (verrouillés, position home, couleur base)
void reinitialiserDepartements() {
  for (Departement p : departements) {
    p.verouiller = true;
    p.x = p.homeX;
    p.y = p.homeY;
    p.couleurActuelle = theme.PANEL;
  }
}


// =========================================================
// PUZZLE : choisir les pièces aléatoires à déplacer à droite
// =========================================================
void piecesAPlacer(int num) {
  reinitialiserDepartements();

  num = constrain(num, 0, departements.size());

  // On crée une liste d’indices puis on la mélange
  IntList indices = new IntList();
  for (int i = 0; i < departements.size(); i++) indices.append(i);
  indices.shuffle();

  float rightX = zoneW;
  float rightW = width - zoneW;
  int marge = 30;

  for (int k = 0; k < num; k++) {
    Departement p = departements.get(indices.get(k));
    p.verouiller = false;

    // Bornes de placement : on tient compte de la hitbox pour éviter que la pièce sorte de l’écran
    float xMin = rightX + marge - p.minX * p.echelle;
    float xMax = (rightX + rightW - marge) - p.maxX * p.echelle;
    float yMin = marge - p.minY * p.echelle;
    float yMax = (height - marge) - p.maxY * p.echelle;

    p.x = (xMin > xMax) ? rightX + rightW/2 : random(xMin, xMax);
    p.y = (yMin > yMax) ? height/2 : random(yMin, yMax);
  }
}


// =========================================================
// MODES : fonctions de lancement (reset + première question)
// =========================================================
void lancerModeApprendre() {
  actuPage(APPRENDRE);

  ratio(france, 0, 0, zoneW, height);
  reinitialiserDepartements();

  panneauLateral.defaut();
}

void lancerModeQuiz(int mode) {
  actuPage(mode);

  ratio(france, 0, 0, zoneW, height);
  reinitialiserDepartements();

  score = 0;
  tentatives = 0;

  // m=0 : quiz texte ; m=2 : quiz carte (selon ton moteur)
  nouvelleQuestion(mode == QUIZ_TEXTE ? 0 : 2);
}

void lancerModePhoto() {
  actuPage(QUIZ_PHOTO);

  ratio(france, 0, 0, zoneW, height);
  reinitialiserDepartements();

  score = 0;
  tentatives = 0;

  changerImageMystere();
}

void lancerModeQuizMultiple() {
  actuPage(QUIZ_MULTIPLE);

  ratio(france, 0, 0, zoneW, height);
  reinitialiserDepartements();

  score = 0;
  tentatives = 0;

  nouvelleQuestionMultiple();
}

void lancerModeChaudFroid() {
  actuPage(QUIZ_CHAUDFROID);

  ratio(france, 0, 0, zoneW, height);
  reinitialiserDepartements();

  score = 0;
  clicksChaudFroid = 0;

  nouvelleCibleChaudFroid();
}

float[] hitbox(PShape s) {
  float minX = 1e9, minY = 1e9, maxX = -1e9, maxY = -1e9;

  if (s.getChildCount() > 0) {
    for (int i = 0; i < s.getChildCount(); i++) {
      float[] b = hitbox(s.getChild(i));
      minX = min(minX, b[0]);
      minY = min(minY, b[1]);
      maxX = max(maxX, b[2]);
      maxY = max(maxY, b[3]);
    }
  } else {
    for (int i = 0; i < s.getVertexCount(); i++) {
      PVector v = s.getVertex(i);
      if (v != null) {
        minX = min(minX, v.x);
        minY = min(minY, v.y);
        maxX = max(maxX, v.x);
        maxY = max(maxY, v.y);
      }
    }
  }

  return new float[]{minX, minY, maxX, maxY};
}

// =========================================================
// QUIZ TEXTE/CARTE : questions + validation via panneau
// =========================================================
void nouvelleQuestion(int m) {
  questionEnCours = moteurQuiz.nouvelleQuestion(m);

  if (panneauJeu != null) {
    panneauJeu.chargerQuestion(questionEnCours);
  }

  messageReponse = "";
  tentatives = 0;
}

void verifierReponseQuizBoutons() {
  // rep = texte du bouton cliqué dans le panneau
  String rep = panneauJeu.verifierClic();

  if (rep == null) return;

  if (rep.equals(questionEnCours.bonneReponse)) {
    int points = (tentatives == 0) ? 10 : (tentatives == 1 ? 5 : 1);
    score += points;

    // question suivante
    nouvelleQuestion(actuel == QUIZ_TEXTE ? 0 : 2);

    messageReponse = "BRAVO ! + " + points + " pts";
    if (Win != null) Win.play();
  } else {
    tentatives++;
    messageReponse = "Faux !";
    if (Lose != null) Lose.play();
  }
}


// =========================================================
// QUIZ MULTIPLE : génération cibles + validation par clic sur carte
// =========================================================
void nouvelleQuestionMultiple() {
  multiCibles.clear();
  multiTrouves.clear();
  multiIdVersNom.clear();
  messageMultiple = "";
  tentatives = 0;

  if (bdd == null || bdd.lignes == null || bdd.lignes.length < 2) {
    messageMultiple = "Erreur : base de données absente";
    return;
  }

  // Tire k départements différents (évite l'en-tête CSV)
  int k = constrain(multiK, 1, min(8, bdd.lignes.length - 1));

  while (multiCibles.size() < k) {
    int idx = int(random(1, bdd.lignes.length));
    String[] d = split(bdd.lignes[idx], ';');
    if (d == null || d.length < 2) continue;

    String id = d[0];
    String nom = d[1];

    if (id == null || id.length() == 0) continue;
    if (nom == null || nom.equals("nom")) continue;

    multiCibles.add(id);
    multiIdVersNom.put(id, nom);
  }
}

void verifierReponseQuizMultiple() {
  // Cherche quel département a été cliqué
  for (Departement d : departements) {
    if (!d.hit(mouseX, mouseY)) continue;

    // Déjà trouvé -> pas d'action
    if (multiTrouves.contains(d.id)) {
      messageMultiple = "Déjà trouvé : " + multiIdVersNom.get(d.id);
      return;
    }

    // Bonne réponse -> ajoute et score
    if (multiCibles.contains(d.id)) {
      multiTrouves.add(d.id);

      int points = (tentatives == 0) ? 3 : (tentatives == 1 ? 2 : 1);
      score += points;

      messageMultiple = "OK ! " + multiIdVersNom.get(d.id) + " (+" + points + ")";

      // Si toutes les cibles trouvées -> transition puis nouvelle question
      if (multiTrouves.size() == multiCibles.size()) {
        int bonus = (tentatives == 0) ? 8 : 4;
        score += bonus;

        messageMultiple = "";
        transitionMultiple = true;
        transitionT = 0;
      }
    }
    // Mauvaise réponse
    else {
      tentatives++;
      messageMultiple = "Non : " + bdd.getInfos(d.id).nom;
    }
    return;
  }
}

// Normalise un ID département pour que "dep_01", "01", "1" donnent la même chose
String normId(String id) {
  if (id == null) return "";
  id = trim(id);

  // enlève un éventuel prefixe "dep_"
  if (id.startsWith("dep_")) id = id.substring(4);

  id = id.toUpperCase();

  // Cas 2A / 2B : on garde tel quel
  if (id.equals("2A") || id.equals("2B")) return id;

  // Si c'est uniquement des chiffres :
  boolean digits = true;
  for (int i = 0; i < id.length(); i++) {
    if (id.charAt(i) < '0' || id.charAt(i) > '9') {
      digits = false;
      break;
    }
  }

  if (digits) {
    // DOM (971..976 etc) : on garde tel quel (3 chiffres ou plus)
    if (id.length() >= 3) return id;

    // Métropole : on force en 2 chiffres ("1" -> "01")
    if (id.length() == 1) id = "0" + id;
    return id;
  }

  return id;
}


// =========================================================
// QUIZ PHOTO : image mystère + clic sur carte
// =========================================================
void changerImageMystere() {
  idMystere = moteurQuiz.getQuestionImage();
  imgMystere = loadImage("Images/" + idMystere + ".jpg");
  messageJeuPhoto = "";
  tentatives = 0;
}

void verifierReponseQuizPhoto() {
  for (Departement d : departements) {
    if (!d.hit(mouseX, mouseY)) continue;

    if (d.id.equals(idMystere)) {
      int points = (tentatives == 0) ? 10 : (tentatives == 1 ? 5 : 1);
      score += points;

      changerImageMystere();
      messageJeuPhoto = "BRAVO ! + " + points + " pts";
      if (Win != null) Win.play();
    } else {
      tentatives++;
      messageJeuPhoto = "Non, c'est : " + bdd.getInfos(d.id).nom;
      if (Lose != null) Lose.play();
    }
    return;
  }
}

// =========================================================
// CHAUD/FROID : cible aléatoire + clic + chaleur (proximité)
// =========================================================
void nouvelleCibleChaudFroid() {

  int idx = int(random(1, bdd.lignes.length));
  String[] d = split(bdd.lignes[idx], ';');
  if (d == null || d.length < 2) return;

  cibleId = d[0];
  cibleNom = d[1];

  clicksChaudFroid = 0;
  chaleur = 0;

  messageChaudFroid = "Trouve : " + cibleNom;
}

void dessinerPanneauChaudFroid() {
  // Utilise le layout global
  int x = width - PANEL_W + 20;
  int y = PANEL_MARGIN;
  int w = PANEL_W - 40;
  int h = height - PANEL_MARGIN*2 - BOTTOM_BAR_H;

  noStroke();
  fill(25, 30, 35);
  rect(x, y, w, h, 20);

  float pad = 28;
  float ty = y + pad;

  fill(170);
  textAlign(LEFT, TOP);
  textSize(16);
  text("Indice : plus tu es proche, plus tu es chaud", x + pad, ty);
  ty += 34;

  fill(255);
  textSize(22);
  text(messageChaudFroid, x + pad, ty);
  ty += 42;

  fill(180);
  textSize(18);
  text("Score : " + score, x + pad, ty);
  ty += 30;

  fill(180);
  text("Clics : " + clicksChaudFroid, x + pad, ty);
  ty += 40;

  // Barre de chaleur (0..1)
  fill(70);
  rect(x + pad, ty, w - 2*pad, 18, 10);

  color froid = color(90, 160, 255);
  color chaud = color(255, 120, 80);
  fill(lerpColor(froid, chaud, chaleur));
  rect(x + pad, ty, (w - 2*pad) * chaleur, 18, 10);
}

void verifierChaudFroid() {
  for (Departement d : departements) {
    if (!d.hit(mouseX, mouseY)) continue;

    clicksChaudFroid++;

    // Gagné : on score selon le nombre de clics (moins = mieux)
    if (d.id.equals(cibleId)) {
      int pts = max(2, 12 - 2*(clicksChaudFroid - 1));
      score += pts;

      messageChaudFroid = "Trouvé ! +" + pts + " pts";

      transitionCF = true;
      tCF = 0;
      return;
    }

    // Sinon : calcule une "chaleur" = 1 - distance normalisée
    float distNorm = distanceDepartementsNorm(d.id, cibleId); // ~0..1
    chaleur = constrain(1.0 - distNorm, 0, 1);

    if (chaleur > 0.90) messageChaudFroid = "Brûlant !!!!!!!!!!";
    if (chaleur > 0.75) messageChaudFroid = "Très chaud !";
    else if (chaleur > 0.65) messageChaudFroid = "Chaud";
    else if (chaleur > 0.5)messageChaudFroid = "Froid ";
    else messageChaudFroid = "Glacial !!!! ";

    return;
  }
}

// Distance approximative entre deux départements : centre de leur hitbox (bbox)
// Puis normalisation par une grande distance de référence (diagonale zone carte)
float distanceDepartementsNorm(String a, String b) {
  Departement da = null, db = null;

  for (Departement d : departements) {
    if (d.id.equals(a)) da = d;
    if (d.id.equals(b)) db = d;
  }

  if (da == null || db == null) return 1;

  // Centre de hitbox en coordonnées écran (min/max * echelle + home)
  float ax = (da.minX + da.maxX) * 0.5 * da.echelle + da.homeX;
  float ay = (da.minY + da.maxY) * 0.5 * da.echelle + da.homeY;

  float bx = (db.minX + db.maxX) * 0.5 * db.echelle + db.homeX;
  float by = (db.minY + db.maxY) * 0.5 * db.echelle + db.homeY;

  float dpx = dist(ax, ay, bx, by);

  // Distance max de référence (diagonale de la zone carte)
  float maxD = dist(0, 0, zoneW, height);

  return dpx / maxD;
}


// =========================================================
// INFOBULLE : affiche nom/région au survol
// =========================================================
void gererInfoBulle() {
  for (Departement d : departements) {
    if (d.hit(mouseX, mouseY)) {
      InfoDept i = bdd.getInfos(d.id);
      bulle.dessin(i.nom, i.region);
      return;
    }
  }
}
