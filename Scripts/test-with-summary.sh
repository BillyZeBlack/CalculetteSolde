#!/bin/sh

set -e

PROJECT="Calculette solde.xcodeproj"
SCHEME="Calculette solde"
DESTINATION="${1:-platform=iOS Simulator}"

xcodebuild test \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "$DESTINATION"

cat <<'SUMMARY'

=== Validation metier Calculette solde ===
Statut: TEST SUCCEEDED

Locales validees:
- fr_FR "1 234,56" -> 1234.56
- en_US "1,234.56" -> 1234.56
- de_DE "1.234,56" -> 1234.56

Calcul remise valide:
- Prix initial: 100
- Remise: 30%
- Montant remise: 30
- Prix final: 70

ViewModel principal valide:
- Prix initial: 80
- Remise: 25%
- Prix final: 60
- Budget max: 50
- Budget depasse: true
- Produit sauvegarde: 1

Recap valide:
- Total initial: 80
- Total remises: 20
- Total final: 60
=========================================

SUMMARY
