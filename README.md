# Quiz de géographie – départements de France

Application interactive en **Java / Processing** pour apprendre et réviser les départements, les régions et les préfectures de France, à partir d'une carte SVG que le programme exploite directement.

## Contexte du projet

| | |
|---|---|
| Cadre | SAÉ 1.01, BUT Informatique 1ʳᵉ année, IUT Lyon 1 – site de Bourg-en-Bresse |
| Date et durée | Janvier 2026, une semaine |
| Équipe | 3 personnes |
| Technologies | Java, Processing 4, SVG, CSV |

Le sujet : concevoir un quiz interactif sur la géographie de la France, construit autour d'une carte SVG.

## Présentation du projet

L'application propose un mode pour apprendre, où chaque département se survole et se clique pour afficher sa fiche, puis six modes de jeu pour s'entraîner, du puzzle au quiz photo. Elle est jouable de bout en bout, avec score, thème clair ou sombre et réglage du volume.

## Objectifs pédagogiques

Cette SAÉ mobilise principalement trois compétences du BUT Informatique :

- **Réaliser un développement d'application** : concevoir un programme complet en programmation orientée objet, avec son interface.
- **Optimiser des applications** : structurer les données et alléger le programme pour qu'il reste fluide.
- **Travailler dans une équipe informatique** : coder à plusieurs sur le même programme et présenter le résultat à l'oral.

## Travail réalisé

- Une application complète : 1 mode d'apprentissage et 6 modes de jeu.
- Un programme de plus de 2 000 lignes organisé en classes.
- Une présentation orale du projet, en équipe.

## Fonctionnalités

| Mode | Principe |
|---|---|
| Apprendre | Survoler ou cliquer un département pour afficher sa fiche : nom, région, préfecture, description, photo |
| Puzzle | Replacer à la souris les départements retirés de la carte, sur 6 niveaux |
| Quiz Texte | Trouver la préfecture ou la région d'un département parmi quatre réponses |
| Quiz Carte | Cliquer sur le département demandé |
| Quiz Photo | Retrouver sur la carte le département d'une photo mystère |
| Quiz Multiple | Cliquer sur tous les départements d'une liste |
| Chaud / Froid | Trouver un département grâce à un indice de proximité à chaque clic |

## Architecture du projet

```
.
├── README.md
├── LICENSE
└── code/
    └── GEO_FRANCE/          Sketch Processing
        ├── GEO_FRANCE.pde   Programme principal : écrans, affichage, souris, modes de jeu
        ├── DEPARTEMENT.pde  Un département : forme SVG, couleur, position
        ├── DONNEES.pde      Lecture du fichier de données des départements
        ├── QUIZ.pde         Tirage des questions et des mauvaises réponses
        ├── PANNEAUX.pde     Panneaux latéraux : fiche, quiz, liste à trouver
        ├── BOUTTON.pde, SLIDER.pde, THEME.pde   Composants d'interface réutilisables
        └── data/
            ├── france.svg        Carte des départements
            └── departements.csv  Nom, région, préfecture et description de chaque département
```

Le programme principal gère les écrans avec une machine à états (accueil, apprendre, paramètres, chaque mode de jeu) ; tout le reste est découpé en classes réutilisables.

## Organisation du travail

Projet mené à trois en une semaine : répartition des tâches, points réguliers, fusion des parties de chacun dans un seul programme, puis présentation orale en équipe.

## Documents

Les données du projet sont dans `code/GEO_FRANCE/data/` : la carte `france.svg` et le fichier `departements.csv`.

Les sons et les photos ne sont pas publiés : ils pèsent plus de 600 Mo et ne nous appartiennent pas.

## Implémentation

### Points techniques

- **La carte comme donnée** : le fichier SVG est chargé avec `loadShape`, puis parcouru récursivement pour en extraire chaque département sous forme de `PShape`. Chaque forme est associée à ses informations grâce à son identifiant.
- **Détection de la souris** : le clic est testé directement sur la forme du département (`contains`), après conversion des coordonnées dans le repère de la carte. Les boîtes englobantes sont calculées à partir des sommets du SVG.
- **Puzzle** : une pièce déposée assez près de sa place d'origine se verrouille automatiquement.
- **Optimisation** : la carte et les données sont chargées une seule fois au lancement, les sons et les photos seulement quand l'écran concerné en a besoin ; le code répété est regroupé dans des classes (boutons, panneaux).

### Lancer le projet

1. Installer [Processing 4](https://processing.org/download) et la bibliothèque **Sound** (menu Sketch → Importer une bibliothèque).
2. Ajouter vos propres fichiers dans `code/GEO_FRANCE/data/Sons` et `code/GEO_FRANCE/data/Images` (une photo `01.jpg`, `02.jpg`… par département) : sans eux, le programme ne démarre pas tel quel.
3. Ouvrir `code/GEO_FRANCE/GEO_FRANCE.pde` et lancer le sketch.

## Suite du projet

- Rendre les sons et les photos facultatifs, pour que le programme démarre même sans eux.
- Ajouter les départements d'outre-mer.
- Enregistrer les meilleurs scores de chaque mode.

## Licence

Ce projet est sous licence [Creative Commons BY-NC 4.0](LICENSE) : vous pouvez le réutiliser et l'adapter en citant les auteurs, mais pas à des fins commerciales.
