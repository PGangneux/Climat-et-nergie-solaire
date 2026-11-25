import 'package:climat_et_energie_solaire/barre_recherche.dart';
import 'package:climat_et_energie_solaire/climat.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:material_ui/material_ui.dart';


Future<void> main() async {
  await dotenv.load();
  runApp(const ClimatApp());
}

class ClimatApp extends StatelessWidget {
  const ClimatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: const AppShell(),
    );
  }
}





// 	Squelette permanent de l'application
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}


class _AppShellState extends State<AppShell> {
  String? localisationRecherchee;

  void rechercher(String localisation) {
    setState(() {
      localisationRecherchee = localisation;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Climat et énergie solaire'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              rechercher("");
            },
            child: const Text("Ma position")
          ),
          BarreRecherche(
            onSearch: rechercher
          ),
          Expanded(
            child: Climat(
              localisation: localisationRecherchee
            ),
          ),
          // Ici, on pourrait ajouter d'autres widgets pour afficher les résultats de la recherche
        ],
      ),
    );
  }
}
