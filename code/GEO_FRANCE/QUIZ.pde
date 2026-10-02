// ==================== CLASSE QUESTION ====================
// Représente une question de quiz
class Question {
  String enonce;
  String bonneReponse;
  String idMap;        // ID du département sur la carte (null si pas quiz carte)
  String[] choix;      // 4 choix mélangés
  
  Question(String e, String b, String[] c, String id) {
    this.enonce = e;
    this.bonneReponse = b;
    this.choix = c;
    this.idMap = id;
  }
}

// ==================== CLASSE QUIZ ====================
// Génère des questions aléatoires sur les départements
class Quiz {
  Donnees bdd;
  
  // IDs des départements ayant des photos disponibles
  String[] idsImages = { 
    "01", "06", "11", "12", "13", "14", "15", "17", "21", "24", 
    "25", "29", "2a", "30", "31", "33", "35", "37", "41", "44",
    "48", "50", "51", "54", "56", "57", "59", "63", "67", "69", 
    "75", "76", "78", "83", "84", "85", "86", "90" 
  };
  
  Quiz(Donnees bdd) {
    this.bdd = bdd;
  }
  
  // Retourne un ID aléatoire pour le quiz photo
  String getQuestionImage() {
    if (idsImages.length == 0) return "01";
    int idx = int(random(idsImages.length));
    return idsImages[idx];
  }
  
  // Génère une nouvelle question
  // mode 0 = préfecture/région aléatoire, mode 2 = carte
  Question nouvelleQuestion(int mode) {
    int idx = int(random(1, bdd.lignes.length));
    String[] d = split(bdd.lignes[idx], ';');
    
    if (d.length < 5) return nouvelleQuestion(mode);
    
    InfoDept sujet = new InfoDept(d[1], d[2], d[3], d[4]);
    sujet.id = d[0];
    
    int type = mode;
    if (mode == 0) type = int(random(2)); // Aléatoire entre préfecture et région
    else type = 2;
    
    String q = "", rep = "", idMap = null;
    String[] fausses = new String[3];
    
    if (type == 0) {
      // Question sur la préfecture
      q = "Quelle est la préfecture du département : " + sujet.nom + " ?";
      rep = sujet.prefecture;
      fausses = getFausses(0, rep);
    } else if (type == 1) {
      // Question sur la région
      q = "Quelle est la Région du département : " + sujet.nom + " ?";
      rep = sujet.region;
      fausses = getFausses(1, rep);
    } else {
      // Question sur la carte
      q = "Quel département est mis en évidence ?";
      rep = sujet.nom;
      idMap = sujet.id;
      fausses = getFausses(2, rep);
    }
    
    return new Question(q, rep, melanger(rep, fausses), idMap);
  }
  
  // Génère 3 fausses réponses
  String[] getFausses(int type, String bonne) {
    String[] res = new String[3];
    int n = 0;
    
    while (n < 3) {
      int idx = int(random(1, bdd.lignes.length));
      String[] d = split(bdd.lignes[idx], ';');
      if (d.length < 5) continue;
      
      String val = (type == 0) ? d[3] : (type == 1) ? d[2] : d[1];
      
      // Évite les doublons et les en-têtes CSV
      if (!val.equals(bonne) && !estDedans(val, res) && 
          !val.equals("nom") && !val.equals("region") && !val.equals("prefecture")) {
        res[n] = val;
        n++;
      }
    }
    
    return res;
  }
  
  // Mélange la bonne réponse avec les fausses
  String[] melanger(String b, String[] f) {
    String[] t = { b, f[0], f[1], f[2] };
    
    for (int i = 0; i < 10; i++) {
      int x = int(random(4)), y = int(random(4));
      String tmp = t[x];
      t[x] = t[y];
      t[y] = tmp;
    }
    
    return t;
  }
  
  // Vérifie si une valeur est déjà dans le tableau
  boolean estDedans(String v, String[] tab) {
    for (String s : tab) {
      if (s != null && s.equals(v)) return true;
    }
    return false;
  }
}
