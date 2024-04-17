import 'package:flutter/material.dart';
import 'package:scmu_app/AddTerrariumDialog.dart';
import 'terrarium.dart';

class TerrariumsPage extends StatefulWidget {
  const TerrariumsPage({Key? key}) : super(key: key);

  @override
  _TerrariumsPageState createState() => _TerrariumsPageState();
}

class _TerrariumsPageState extends State<TerrariumsPage> {
  final List<Terrarium> terrariums = [
    Terrarium(
      name: 'Terrarium 1',
      minTemperature: 25.0,
      maxTemperature: 28.0,
      minHumidity: 50.0,
      maxHumidity: 60.0,
      minLightHours: 10,
      maxLightHours: 12,
      minHeaterHours: 6,
      maxHeaterHours: 8,
      minFeedingHours: 2,
      maxFeedingHours: 3,
    ),
    Terrarium(
      name: 'Terrarium 2',
      minTemperature: 20.0,
      maxTemperature: 30.0,
      minHumidity: 40.0,
      maxHumidity: 70.0,
      minLightHours: 8,
      maxLightHours: 14,
      minHeaterHours: 5,
      maxHeaterHours: 10,
      minFeedingHours: 1,
      maxFeedingHours: 4,
    ),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terrariums'),
      ),
      body: ListView.builder(
        itemCount: terrariums.length,
        itemBuilder: (context, index) {
          final terrarium = terrariums[index];
          return ListTile(
            title: Text(terrarium.name),
            subtitle: Text('Temperature: ${terrarium.minTemperature}°C | Humidity: ${terrarium.minHumidity}%'),
            onTap: () {
              // Navigate to details page or perform any action on terrarium selection
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTerrariumDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddTerrariumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddTerrariumDialog(
          onTerrariumAdded: (newTerrarium) {
            setState(() {
              terrariums.add(newTerrarium);
            });
          },
        );
      },
    );
  }
}
