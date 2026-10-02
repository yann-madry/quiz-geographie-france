# Quiz de géographie – départements de France

Application interactive en **Processing (Java)** pour apprendre et réviser les départements, les régions et les préfectures de France. La carte est un fichier SVG chargé directement par le programme : chaque département est une forme que l'on peut survoler, cliquer ou déplacer.

Projet réalisé en équipe de trois en une semaine, en 1ʳᵉ année de BUT Informatique (IUT Lyon 1, site de Bourg-en-Bresse), SAÉ 1.01.

## Fonctionnalités

- **Mode Apprendre** : on survole ou on clique un département pour afficher sa fiche (nom, région, préfecture, description, photo).
- **Six modes de jeu**

  | Mode | Principe |
  |---|---|
  | Puzzle | Replacer à la souris les départements retirés de la carte, sur 6 niveaux |
  | Quiz Texte | Trouver la préfecture ou la région d'un département parmi quatre réponses |
  | Quiz Carte | Cliquer sur le département demandé |
  | Quiz Photo | Retrouver sur la carte le département d'une photo mystère |
  | Quiz Multiple | Cliquer sur tous les départements d'une liste |
  | Chaud / Froid | Trouver un département grâce à un indice de proximité à chaque clic |

- Score, thème clair ou sombre, musique et réglage du volume.

## Organisation du code

| Fichier | Rôle |
|---|---|
| `GEO_FRANCE.pde` | Programme principal : écrans, boucle d'affichage, gestion de la souris, modes de jeu |
| `DEPARTEMENT.pde` | Un département : sa forme SVG, sa couleur, sa position |
| `DONNEES.pde` | Lecture de `departements.csv` (nom, région, préfecture, description) |
| `QUIZ.pde` | Tirage des questions et des mauvaises réponses |
| `PANNEAUX.pde` | Panneaux latéraux : fiche d'information, quiz, liste à trouver |
| `BOUTTON.pde`, `SLIDER.pde`, `THEME.pde` | Composants d'interface réutilisables |

## Lancer le projet

1. Installer [Processing 4](https://processing.org/download) et la bibliothèque **Sound** (menu Sketch → Importer une bibliothèque).
2. Ouvrir `GEO_FRANCE/GEO_FRANCE.pde`.

**Les sons et les photos ne sont pas dans ce dépôt** : ils pèsent plus de 600 Mo et ne nous appartiennent pas. Sans eux, le programme ne démarre pas tel quel. Il faut placer ses propres fichiers dans `GEO_FRANCE/data/Sons` et `GEO_FRANCE/data/Images` (une photo `01.jpg`, `02.jpg`… par département).

## Ce que j'ai appris

- Structurer un programme de plus de 2 000 lignes en classes plutôt qu'en un seul fichier.
- Exploiter un fichier SVG comme donnée du programme et non comme simple image.
- Gérer un programme à plusieurs écrans avec une machine à états.
- Coder à trois sur le même projet et fusionner les parties de chacun.
