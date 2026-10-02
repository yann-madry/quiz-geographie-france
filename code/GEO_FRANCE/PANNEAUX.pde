// ==================== CLASSE INFO BULLE ====================
class InfoBulle {
  void dessin(String titre, String soustitre) {
    textFont(theme.fontNormal);
    float w = max(textWidth(titre), textWidth(soustitre)) + 35;

    fill(theme.BULLE);
    stroke(0);
    rect(mouseX + 15, mouseY + 15, w, 50, 8);

    textAlign(LEFT, TOP);
    fill(0);
    textSize(14);
    text(titre, mouseX + 25, mouseY + 20);

    fill(100);
    textSize(12);
    text(soustitre, mouseX + 25, mouseY + 40);
  }
}

// ==================== CLASSE PANNEAU INFO ====================
class PanneauInfo {
  float x, y, w, h;
  InfoDept infoActuelle;
  String idActuel = "";
  PImage photoDept;
  HashMap<String, PImage> memoirePhotos = new HashMap<String, PImage>();

  PanneauInfo(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    defaut();
  }

  void defaut() {
    idActuel = "";
    infoActuelle = new InfoDept("Sélectionnez un département", "...", "...", "");
    photoDept = null;
  }

  void selectionner(String id) {
    this.idActuel = id;
    this.infoActuelle = bdd.getInfos(id);

    if (memoirePhotos.containsKey(id)) {
      photoDept = memoirePhotos.get(id);
    } else {
      photoDept = loadImage("Images/" + id + ".jpg");
      if (photoDept != null && photoDept.width > 0) {
        photoDept.resize((int)w - 40, 280);
        memoirePhotos.put(id, photoDept);
      }
    }
  }

  void dessin() {
    fill(33, 37, 43, 230);
    stroke(255);
    strokeWeight(3);
    rect(x, y, w, h, 20);

    noStroke();
    if (idActuel.length() > 0) fill(theme.TITRE, 30);
    else fill(100, 30);
    rect(x, y, w, 90, 20, 20, 0, 0);

    fill(255);
    textAlign(LEFT, CENTER);
    textFont(theme.fontTitre);

    if (idActuel.length() > 0) {
      textSize(50);
      fill(theme.TITRE);
      text(idActuel, x + 30, y + 45);

      textSize(32);
      fill(255);
      text(infoActuelle.nom, x + 110, y + 45);
    } else {
      textSize(28);
      fill(150);
      text(infoActuelle.nom, x + 30, y + 45);
    }

    ligne("RÉGION", infoActuelle.region, y + 130);
    ligne("PRÉFECTURE", infoActuelle.prefecture, y + 220);

    if (photoDept != null && photoDept.width > 0) {
      image(photoDept, x + 20, y + 300);
      noFill();
      stroke(255, 100);
      strokeWeight(2);
      rect(x + 20, y + 300, w - 40, 280, 15);
    }

    fill(0, 50);
    stroke(255, 10);
    rect(x + 20, y + 600, w - 40, h - 620, 10);

    fill(200);
    textAlign(LEFT, TOP);
    textFont(theme.fontNormal);
    textSize(18);
    text(infoActuelle.description, x + 40, y + 620, w - 80, h - 640);

    noFill();
    stroke(128);
    strokeWeight(3);
    rect(x, y, w, h, 20);
  }

  void dessinModeDevinette(PImage img, String msg, int pts) {
    fill(theme.PANEL);
    stroke(theme.TITRE);
    strokeWeight(2);
    rect(x, y, w, h, 20);

    fill(theme.TITRE);
    textAlign(CENTER, TOP);
    textFont(theme.fontTitre);
    textSize(40);
    text("C'EST OÙ ?", x + w / 2, y + 30);

    fill(255);
    textSize(22);
    text("Score : " + pts, x + w / 2, y + 80);

    float imgY = y + 130;

    if (img != null) {
      float r = (float)img.width / (float)img.height;
      float drawW = w - 60;
      float drawH = drawW / r;

      if (drawH > 280) {
        drawH = 280;
        drawW = drawH * r;
      }

      float imgX = x + (w - drawW) / 2;

      image(img, imgX, imgY, drawW, drawH);
      stroke(255);
      strokeWeight(3);
      noFill();
      rect(imgX, imgY, drawW, drawH, 10);

      float textY = imgY + drawH + 30;

      if (msg.length() == 0) {
        fill(255);
        textSize(24);
        text("Regarde bien cette photo...", x + w / 2, textY);
        fill(180);
        textSize(18);
        text("Clique sur le département correspondant\ndirectement sur la carte !", x + w / 2, textY + 40);
      } else {
        if (msg.startsWith("BRAVO")) fill(theme.VERT);
        else if (msg.startsWith("Passé")) fill(theme.TITRE);
        else fill(theme.ROUGE);

        textSize(22);
        textAlign(CENTER, TOP);
        text(msg, x + 20, textY, w - 40, 200);
      }
    }
  }

  void ligne(String l, String v, float py) {
    textAlign(LEFT, TOP);
    textFont(theme.fontNormal);

    fill(theme.TITRE);
    textSize(15);
    text(l, x + 30, py);

    fill(255);
    textSize(26);
    text(v, x + 30, py + 20);

    stroke(255, 20);
    line(x + 30, py + 65, x + w - 30, py + 65);
    noStroke();
  }
}

// ==================== CLASSE PANNEAU QUIZ ====================
class PanneauQuiz {
  float x, y, w, h;
  Boutton[] btnReponses;
  Question questionEnCours;

  PanneauQuiz(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;

    btnReponses = new Boutton[4];
    for (int i = 0; i < 4; i++) {
      btnReponses[i] = new Boutton(
        (int)x + 20,
        (int)y + 200 + (i * 70),
        (int)w - 40,
        50,
        ""
        );
    }
  }

  void chargerQuestion(Question q) {
    this.questionEnCours = q;
    for (int i = 0; i < 4; i++) {
      btnReponses[i].texte = q.choix[i];
    }
  }

  void dessin(int score, String message) {
    fill(theme.PANEL);
    stroke(theme.TITRE);
    strokeWeight(2);
    rect(x, y, w, h, 20);

    fill(theme.TITRE);
    textAlign(LEFT, TOP);
    textSize(22);
    text("SCORE : " + score, x + 30, y + 30);

    fill(theme.TITRE);
    textAlign(CENTER, TOP);
    textSize(30);
    text("QUIZ", x + w / 2, y + 30);

    if (questionEnCours != null) {
      fill(theme.TEXTE);
      textSize(20);
      textAlign(CENTER, CENTER);
      text(questionEnCours.enonce, x + 20, y + 80, w - 40, 100);

      for (Boutton b : btnReponses) {
        b.mettreAJour();
        b.afficher();
      }
    }

    if (message.startsWith("BRAVO")) fill(theme.VERT);
    else fill(theme.ROUGE);

    textAlign(CENTER, CENTER);
    textSize(24);
    text(message, x + w / 2, y + h - 60);
  }

  String verifierClic() {
    for (Boutton b : btnReponses) {
      if (b.estClique()) return b.texte;
    }
    return null;
  }
}

// ==================== CLASSE PANNEAU QUESTIONS MULTIPLES ====================
// Affiche la liste des départements à trouver et l'avancement.
class PanneauMultiple {
  float x, y, w, h;

  PanneauMultiple(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  void dessin(int score, String message,
    HashMap<String, String> idVersNom,
    HashSet<String> cibles,
    HashSet<String> trouves) {

    noStroke();
    fill(25, 30, 35);
    rect(x, y, w, h, 20);

    float pad = 28;
    float ty = y + pad;

    // instruction
    fill(170);
    textAlign(LEFT, TOP);
    textSize(16);
    text("Clique sur tous les départements demandés", x + pad, ty);
    ty += 34;

    // progression
    fill(255);
    textSize(22);
    text(trouves.size() + " / " + cibles.size() + " trouvés", x + pad, ty);
    ty += 30;

    // séparation
    stroke(70);
    line(x + pad, ty, x + w - pad, ty);
    noStroke();
    ty += 26;

    // liste
    textSize(20);
    for (String id : cibles) {
      String nom = idVersNom.get(id);
      if (trouves.contains(id)) {
        fill(90, 220, 130);
        text("✔ " + nom, x + pad, ty);
      } else {
        fill(230);
        text("• " + nom, x + pad, ty);
      }
      ty += 34;
    }

    // message feedback (en bas)
    if (message != null && message.length() > 0) {
      fill(180);
      textSize(16);
      text(message, x + pad, y + h - 40);
    }
  }
}
