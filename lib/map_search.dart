import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

class MapSearchScreen extends StatefulWidget {
  final String localisation;

  const MapSearchScreen({
    super.key,
    required this.localisation,
  });

  @override
  State<MapSearchScreen> createState() => _MapSearchScreenState();
}

class _MapSearchScreenState extends State<MapSearchScreen> {
  final MapController _mapController = MapController();

  LatLng _center = const LatLng(48.8566, 2.3522); // Coordonnées par défaut : Paris
  String _latitude = '48.8566';
  String _longitude = '2.3522';

  // Récupérer les coordonnées d'une ville (un couple [lat, long])
  // Récupérer les coordonnées d'une ville (un couple [lat, long])
  Future<List<double>> _getCoordinates(String city) async {
    // Cas "latitude, longitude" on utilise pas nominatum
    final morceaux = city.split(',');
    if (morceaux.length == 2) {
      final lat = double.tryParse(morceaux[0].trim());
      final lon = double.tryParse(morceaux[1].trim());
      if (lat != null && lon != null) {
        return [lat, lon];
      }
    }

    // Cas nom de ville 
    // Uri.https encode les espaces, les &, etc.
    final url = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': city,
      'format': 'json',
      'limit': '1',
    });
    final response = await http.get(url, headers: {'User-Agent': 'FlutterApp'});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        return [lat, lon];
      }
    }
    throw Exception("Aucune coordonnée trouvée pour $city");
  }

  // Rechercher une ville et centrer la carte
  // todo serach location non city ...
  Future<void> _searchCity() async {
    try {
      final query = widget.localisation.trim();

      if (query.isEmpty) {
        return;
      }
      
      List<double> location = await _getCoordinates(query);

      if (!mounted) return;

      setState(() {
        _center = LatLng(location[0], location[1]);
        _latitude = location[0].toString();
        _longitude = location[1].toString();
      });

      _mapController.move(_center, 12.0);

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du géocodage : $e'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Attendre que la carte soit affichée avant de la déplacer
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchCity();
    });
  }

  @override
  //sert si l'écran parent garde la carte affichée et change localisation. 
  // Sans cette méthode, la carte ne lancerait pas la nouvelle recherche.
  void didUpdateWidget(covariant MapSearchScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.localisation != widget.localisation) {
      _searchCity();
    }
  }


  @override
  Widget build(BuildContext context) {
    final cartoApiKey = dotenv.get('cartoApiKey');

    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenStreetMap Search'),
      ),
      body: Column(
        children: [
          Text('Latitude : $_latitude', style: const TextStyle(fontSize: 16)),
          Text('Longitude : $_longitude', style: const TextStyle(fontSize: 16)),
          Expanded(
            child: FlutterMap(
              mapController: _mapController, // Ajout du contrôleur
              options: MapOptions(
                initialCenter: _center,
                initialZoom: 12.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png?key=$cartoApiKey",
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'net.eddbali.cours_osm.map_adresse',
                  //attributionBuilder: (_) {
                  //  return Text("© OpenStreetMap contributors | © Carto");
                  //},
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _center,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _searchCity,
        child: const Icon(Icons.search),
      ),
    );
  }
}