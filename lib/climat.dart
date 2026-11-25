import 'package:climat_et_energie_solaire/map_search.dart';
import 'package:material_ui/material_ui.dart';

class Climat extends StatelessWidget {
  final String? localisation;

  const Climat({
    super.key,
    required this.localisation,
  });

  @override
  Widget build(BuildContext context) {
    if (localisation == null) {
      return const Center(
        child: Text('Recherchez une localisation'),
      );
    }

    return MapSearchScreen(
      key: ValueKey(localisation),
      localisation: localisation!,
    );
  }
}