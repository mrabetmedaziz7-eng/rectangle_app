# Rectangle Splitter (Pavage d'espace récursif BSP)

Une application Flutter interactive implémentant un algorithme de partitionnement binaire d'espace (Binary Space Partitioning - BSP) inspiré des gestionnaires de fenêtres en tuiles (*tiling window managers* tels que i3 ou bspwm).

## Fonctionnalités

- **Découpe récursive infinie :** Chaque rectangle est cliquable et se subdivise récursivement en deux rectangles égaux.
- **Alternance d'orientation :** Alternance stricte entre découpe verticale (`Row`) et horizontale (`Column`) selon la profondeur dans l'arbre.
- **Gestion des couleurs :**
  - Mode standard : attribution de couleurs aléatoires vibrantes issues d'une palette sélectionnée.
  - Mode dégradé : génération automatique de teintes et nuances par variation de luminosité et de saturation (`HSLColor`).
- **Panneau de configuration (`OptionsSheet`) :**
  - Réglage en direct de la largeur de bordure (`0.0` à `12.0` px).
  - Réglage de l'arrondi des coins (`0.0` à `32.0` px).
  - Activation/désactivation du mode dégradé.
  - Sélection de la couleur de base.
- **Indicateurs visuels et métriques :**
  - Compteur dynamique en temps réel du nombre total de rectangles dans l'`AppBar`.
  - Affichage centré de la profondeur (`depth`) avec contraste adaptatif (noir/blanc dynamique) et redimensionnement automatique (`FittedBox`).
- **Bouton de réinitialisation (`Reset`) :** Retour instantané à l'état initial en un clic.

## Structure du Projet

```
lib/
├── models/
│   └── node.dart            # Modèle d'arbre, logique BSP, couleurs HSL et calcul de profondeur
├── widgets/
│   └── options_sheet.dart   # Panneau modal de configuration (Sliders, Switch, Palette)
└── main.dart                # Interface principale, Scaffold, AppBar et rendu récursif
test/
└── widget_test.dart         # Suite de 7 tests unitaires et d'interface
```

## Lancer le Projet

```bash
# Vérifier l'analyse statique
flutter analyze

# Lancer la suite de tests
flutter test

# Lancer dans Google Chrome (Web)
flutter run -d chrome

# Lancer en application Windows Desktop
flutter run -d windows
```
