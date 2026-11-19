import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
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

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _searchCity();
  }

  // Obtenir la position actuelle de l'utilisateur
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activer le service de localisation')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permission de localisation refusée')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission de localisation bloquée')),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _center = LatLng(position.latitude, position.longitude);
        _latitude = position.latitude.toString();
        _longitude = position.longitude.toString();
      });
      _mapController.move(_center, 12.0); // Centrer la carte
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erreur lors de l\'obtention de la localisation')),
      );
    }
  }

  // Récupérer les coordonnées d'une ville (un couple [lat, long])
  Future<List<double>> _getCoordinates(String city) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$city&format=json&limit=1');
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
  Future<void> _searchCity() async {
    try {
      final query = widget.localisation.trim();

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