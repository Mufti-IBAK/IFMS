void main() {
  bool isUpdateAvailable(String currentVer, String currentBuildStr, String latestVerWithBuild) {
    final latestParts = latestVerWithBuild.split('+');
    final latestVer = latestParts.first;
    final latestBuildStr = latestParts.length > 1 ? latestParts.last : '0';

    final currentSem = currentVer.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final latestSem = latestVer.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    while (currentSem.length < 3) {
      currentSem.add(0);
    }
    while (latestSem.length < 3) {
      latestSem.add(0);
    }

    for (int i = 0; i < 3; i++) {
      if (latestSem[i] > currentSem[i]) return true;
      if (currentSem[i] > latestSem[i]) return false;
    }

    final latestBuild = int.tryParse(latestBuildStr) ?? 0;
    final currentBuild = int.tryParse(currentBuildStr) ?? 0;
    return latestBuild > currentBuild;
  }

  print('1.0.0+28 vs 2.5.0+20028: \${isUpdateAvailable('1.0.0', '28', '2.5.0+20028')}');
  print('2.5.0+20028 vs 2.5.0+20028: \${isUpdateAvailable('2.5.0', '20028', '2.5.0+20028')}');
  print('1.0.0+0028 vs 2.5.0+20028: \${isUpdateAvailable('1.0.0', '0028', '2.5.0+20028')}');
}
