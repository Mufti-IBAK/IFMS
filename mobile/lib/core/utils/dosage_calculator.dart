class DosageResult {
  final double activeMgNeeded;
  final double? concentrationMgPerUnit;
  final double? calculatedAmount;
  final String displayUnit;
  final String formulaExplanation;

  DosageResult({
    required this.activeMgNeeded,
    this.concentrationMgPerUnit,
    this.calculatedAmount,
    required this.displayUnit,
    required this.formulaExplanation,
  });

  double? get volumeToAdminister => calculatedAmount;
  String get unit => displayUnit;
}

class DosageCalculator {
  /// Calculates the exact required dosage based on animal weight, dosage rate (mg/kg),
  /// and medication concentration (% w/v or w/w, mg/mL, mg/tab, or mg/g).
  static DosageResult calculate({
    required double weightKg,
    required double dosageRatePerKg,
    double? concentrationValue,
    String? concentrationUnit,
    double? concentrationMgPerMl,
    String? medicationUnit,
    String? concentrationText,
  }) {
    final activeMgNeeded = weightKg * dosageRatePerKg;
    double? concMgPerUnit = concentrationMgPerMl;
    String resolvedUnit = (medicationUnit ?? 'mL');

    // 1. Determine concentration in mg/unit if not explicitly passed as concentrationMgPerMl
    if (concMgPerUnit == null || concMgPerUnit <= 0) {
      if (concentrationValue != null && concentrationValue > 0) {
        final cUnit = (concentrationUnit ?? '').toLowerCase();
        if (cUnit == '%' || cUnit.contains('percent')) {
          // 1% = 10 mg/mL (w/v for liquids) or 10 mg/g (w/w for powders)
          concMgPerUnit = concentrationValue * 10.0;
        } else if (cUnit == 'mg_ml' || cUnit == 'mg/ml') {
          concMgPerUnit = concentrationValue;
        } else if (cUnit == 'mg_tab' || cUnit == 'mg/tab' || cUnit == 'mg/tablet') {
          concMgPerUnit = concentrationValue;
        } else if (cUnit == 'mg_g' || cUnit == 'mg/g') {
          concMgPerUnit = concentrationValue;
        } else {
          concMgPerUnit = concentrationValue;
        }
      } else if (concentrationText != null && concentrationText.isNotEmpty) {
        final match = RegExp(r'([0-9]+(?:\.[0-9]+)?)').firstMatch(concentrationText);
        if (match != null) {
          final parsed = double.tryParse(match.group(1)!);
          if (parsed != null && parsed > 0) {
            concMgPerUnit = concentrationText.contains('%') ? (parsed * 10.0) : parsed;
          }
        }
      }
    }

    // 2. Resolve display unit based on concentration unit or medication unit
    final cUnit = (concentrationUnit ?? '').toLowerCase();
    if (cUnit == '%' || cUnit == 'mg_ml' || cUnit == 'mg/ml') {
      resolvedUnit = 'mL';
    } else if (cUnit == 'mg_tab' || cUnit == 'mg/tab' || cUnit == 'mg/tablet') {
      resolvedUnit = 'tabs';
    } else if (cUnit == 'mg_g' || cUnit == 'mg/g') {
      resolvedUnit = 'g';
    } else if (medicationUnit != null && medicationUnit.isNotEmpty) {
      resolvedUnit = medicationUnit;
    }

    // 3. Calculate dose amount (volume in mL, number of tablets, or weight in grams)
    double? calculatedAmount;
    if (concMgPerUnit != null && concMgPerUnit > 0) {
      calculatedAmount = activeMgNeeded / concMgPerUnit;
    }

    // 4. Build detailed step-by-step formula explanation
    final StringBuffer explanation = StringBuffer();
    explanation.write('${weightKg.toStringAsFixed(1)} kg × ${dosageRatePerKg.toStringAsFixed(1)} mg/kg = ${activeMgNeeded.toStringAsFixed(1)} mg active drug');

    if (concMgPerUnit != null && concMgPerUnit > 0 && calculatedAmount != null) {
      String concDesc = '${concMgPerUnit.toStringAsFixed(1)} mg/$resolvedUnit';
      if (cUnit == '%' && concentrationValue != null) {
        concDesc = '${concentrationValue.toStringAsFixed(1)}% ($concDesc)';
      }
      explanation.write(' ÷ $concDesc = ${calculatedAmount.toStringAsFixed(1)} $resolvedUnit');
    }

    return DosageResult(
      activeMgNeeded: activeMgNeeded,
      concentrationMgPerUnit: concMgPerUnit,
      calculatedAmount: calculatedAmount,
      displayUnit: resolvedUnit,
      formulaExplanation: explanation.toString(),
    );
  }
}
