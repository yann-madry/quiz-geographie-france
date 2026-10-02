// ==================== CLASSE INFO DEPT ====================
// Stocke les informations d'un département
class InfoDept {
  String id, nom, region, prefecture, description;
  
  InfoDept(String n, String r, String p, String d) {
    this.nom = n;
    this.region = r;
    this.prefecture = p;
    this.description = d;
  }
}

// ==================== CLASSE DONNEES ====================
// Charge et gère les informations sur les départements
class Donnees {
  String[] lignes;
  
  Donnees() {
    lignes = loadStrings("departements.csv");
  }
  
  // Récupère les infos d'un département par son ID
  InfoDept getInfos(String idCherche) {
    if (lignes == null) {
      return new InfoDept("Erreur", "Fichier", "Absent", "");
    }
    
    for (int i = 0; i < lignes.length; i++) {
      String[] p = split(lignes[i], ';');
      if (p.length >= 5 && p[0].equals(idCherche)) {
        InfoDept info = new InfoDept(p[1], p[2], p[3], p[4]);
        info.id = p[0];
        return info;
      }
    }
    
    return new InfoDept("", "", "", "");
  }
}
