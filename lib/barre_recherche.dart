import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BarreRecherche extends StatefulWidget {
  final Function(String) onSearch;

 

  const BarreRecherche({
    super.key,
    required this.onSearch,
  });

  @override
  State<BarreRecherche> createState() => _BarreRechercheState();
}

class _BarreRechercheState extends State<BarreRecherche> {

  final TextEditingController textController = TextEditingController();
  Set<String> favoris = {};
  bool chargement = true;


  void submitSearch() {
    final query = textController.text.trim();

    if (query.isNotEmpty) {
      widget.onSearch(query);
    }
  }

  Future<void> _chargerFavoris() async {
    // Charger et obtenir les préférences partagées pour cette application.
    final prefs = await SharedPreferences.getInstance();
    final liste = prefs.getStringList("favoris"); // pas de await ici

    // Le widget a pu être détruit pendant le chargement
    if (!mounted) return;

    setState(() {
      favoris = {...?liste};
      chargement = false;
    });
  }

  Future<void> _sauvegarderFavoris() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("favoris", favoris.toList());
  }

  // Ajoute le favori s'il est absent, le retire sinon
  Future<void> _basculerFavori(String texte) async {
    final valeur = texte.trim();
    if (valeur.isEmpty) return;

    setState(() {
      if (!favoris.remove(valeur)) {
        favoris.add(valeur);
      }
    });

    await _sauvegarderFavoris();
  }

  void _choisirFavori(String favori) {
    textController.text = favori;
    submitSearch();
  }

  @override
  void initState() {
    super.initState();
    _chargerFavoris();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: textController,
          onSubmitted: (_) => submitSearch(),
          decoration: InputDecoration(
            hintText: "Entrez une ville/région/pays",
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: submitSearch,
            ),
          ),
        ),


        // Se reconstruit à chaque changement du texte
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: textController,
          builder: (context, value, _) {
            final texte = value.text.trim();
            final estFavori = favoris.contains(texte);

            return ElevatedButton.icon(
              // null = bouton désactivé
              onPressed: chargement || texte.isEmpty
                  ? null
                  : () => _basculerFavori(texte),
              icon: Icon(estFavori ? Icons.star : Icons.star_border),
              label: Text(
                estFavori ? "Retirer des favoris" : "Ajouter aux favoris",
              ),
            );
          },
        ),

        // Liste des favoris
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final favori in favoris)
              InputChip(
                label: Text(favori),
                onPressed: () => _choisirFavori(favori),
                onDeleted: () => _basculerFavori(favori),
              ),
          ],
        ),
      ],
    );
  }
}