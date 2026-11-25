import 'package:material_ui/material_ui.dart';

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

  void submitSearch() {
    final query = textController.text.trim();

    if (query.isNotEmpty) {
      widget.onSearch(query);
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textController,
      onSubmitted: (_) => submitSearch(),
      decoration: InputDecoration(
        hintText: "Entrez une ville/région/pays",
        suffixIcon: IconButton(
          icon: const Icon(Icons.search),
          onPressed: submitSearch,
        ),
      ),
    );
  }
}