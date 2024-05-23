import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'Terrarium.dart';

class AddTerrariumDialog extends StatefulWidget {
  const AddTerrariumDialog({Key? key}) : super(key: key);

  @override
  _AddTerrariumDialogState createState() => _AddTerrariumDialogState();
}

class _AddTerrariumDialogState extends State<AddTerrariumDialog> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController minTemperatureController = TextEditingController();
  final TextEditingController maxTemperatureController = TextEditingController();
  final TextEditingController minHumidityController = TextEditingController();
  final TextEditingController maxHumidityController = TextEditingController();
  final TextEditingController minLightHoursController = TextEditingController();
  final TextEditingController maxLightHoursController = TextEditingController();
  final TextEditingController minHeaterHoursController = TextEditingController();
  final TextEditingController maxHeaterHoursController = TextEditingController();
  final TextEditingController minFeedingHoursController = TextEditingController();
  final TextEditingController maxFeedingHoursController = TextEditingController();

  final dbRef = FirebaseDatabase.instance.ref('Terrariums');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New Terrarium', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nameController, 'Name'),
              SizedBox(height: 10),
              _buildSectionLabel('Temperature'),
              _buildRow([
                _buildTextField(minTemperatureController, 'Min', keyboardType: TextInputType.number),
                _buildTextField(maxTemperatureController, 'Max', keyboardType: TextInputType.number),
              ]),
              SizedBox(height: 10),
              _buildSectionLabel('Humidity'),
              _buildRow([
                _buildTextField(minHumidityController, 'Min', keyboardType: TextInputType.number),
                _buildTextField(maxHumidityController, 'Max', keyboardType: TextInputType.number),
              ]),
              SizedBox(height: 10),
              _buildSectionLabel('Light Hours'),
              _buildRow([
                _buildTextField(minLightHoursController, 'Min', keyboardType: TextInputType.number),
                _buildTextField(maxLightHoursController, 'Max', keyboardType: TextInputType.number),
              ]),
              SizedBox(height: 10),
              _buildSectionLabel('Heater Hours'),
              _buildRow([
                _buildTextField(minHeaterHoursController, 'Min', keyboardType: TextInputType.number),
                _buildTextField(maxHeaterHoursController, 'Max', keyboardType: TextInputType.number),
              ]),
              SizedBox(height: 10),
              _buildSectionLabel('Feeding Hours'),
              _buildRow([
                _buildTextField(minFeedingHoursController, 'Min', keyboardType: TextInputType.number),
                _buildTextField(maxFeedingHoursController, 'Max', keyboardType: TextInputType.number),
              ]),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Validate and save form data
            final newTerrarium = Terrarium(
              key: nameController.text,
              name: nameController.text,
              foodLevel: 0,
              waterLevel: 0,
              temperature: 0.0,
              humidity: 0.0,
              ledStatus: "OFF",
              heaterStatus: "OFF",
              minTemperature: double.parse(minTemperatureController.text),
              maxTemperature: double.parse(maxTemperatureController.text),
              minHumidity: double.parse(minHumidityController.text),
              maxHumidity: double.parse(maxHumidityController.text),
              minLightHours: int.parse(minLightHoursController.text),
              maxLightHours: int.parse(maxLightHoursController.text),
              minHeaterHours: int.parse(minHeaterHoursController.text),
              maxHeaterHours: int.parse(maxHeaterHoursController.text),
              minFeedingHours: int.parse(minFeedingHoursController.text),
              maxFeedingHours: int.parse(maxFeedingHoursController.text),
              activity: {},
            );

            dbRef.push().set({
              'name': newTerrarium.name,
              'minTemp': newTerrarium.minTemperature,
              'maxTemp': newTerrarium.maxTemperature,
              'minHumidity': newTerrarium.minHumidity,
              'maxHumidity': newTerrarium.maxHumidity,
              'minLight': newTerrarium.minLightHours,
              'maxLight': newTerrarium.maxLightHours,
            });

            Navigator.of(context).pop();
          },
          child: Text('Add'),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
    );
  }

  Widget _buildSectionLabel(String labelText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(
        labelText,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildRow(List<Widget> children) {
    return Row(
      children: children.map((child) => Expanded(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: child,
      ))).toList(),
    );
  }
}
