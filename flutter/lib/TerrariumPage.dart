import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scmu_app/activity_graph_widget.dart';
import 'package:scmu_app/graph_widget.dart';

import 'Terrarium.dart';

class TerrariumPage extends StatefulWidget {
  final Terrarium terrarium;
  const TerrariumPage({Key? key, required this.terrarium}) : super(key: key);

  @override
  _TerrariumPageState createState() => _TerrariumPageState();
}

class _TerrariumPageState extends State<TerrariumPage> {
  final String espUrl = 'http://192.168.1.129'; // Replace with actual ESP32 IP address
  late DatabaseReference dbRef;

  @override
  void initState() {
    super.initState();
    dbRef = FirebaseDatabase.instance.ref("/Terrariums/${widget.terrarium.key}");
  }

  Future<void> toggleLed(String led, String command) async {
    var url = Uri.parse('$espUrl/$led/$command');
    const timeoutDuration = Duration(seconds: 2); // Set your desired timeout duration

    try {
      final response = await http.get(url).timeout(timeoutDuration);

      if (response.statusCode != 200 && response.statusCode != 201) {
        print('Failed to execute LED command. Status code: ${response.statusCode}');
        await dbRef.child("${led}Status").set(command);
      }
    } catch (e) {
      // Handle timeout and other exceptions
      if (e is TimeoutException) {
        print('Request to ESP32 timed out.');
      } else {
        print('Error executing LED command: $e');
      }
      await dbRef.child("${led}Status").set(command);
    }
  }

  Stream<Terrarium> getTerrarium() {
    final DatabaseReference ref = FirebaseDatabase.instance.ref().child('Terrariums').child(widget.terrarium.key);
    return ref.onValue.map((event) {
      return Terrarium.fromSnapshot(event.snapshot);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terrarium ' + widget.terrarium.name),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<Terrarium>(
          stream: getTerrarium(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData) {
              return Center(child: Text('No data available'));
            }

            final terrarium = snapshot.data!;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[300],
                          child: Icon(Icons.image, size: 50, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatusCard('TEMPERATURE', terrarium.temperature),
                            _buildStatusCard('HUMIDITY', terrarium.humidity),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSwitch('LIGHT', terrarium.ledStatus == 'ON', 'led'),
                  _buildSwitch('HEATER', terrarium.heaterStatus == 'ON', 'heater'),
                  const SizedBox(height: 32),
                  _buildIndicator('WATER LEVEL', 'OK', Colors.green),
                  _buildIndicator('FOOD LEVEL', 'LOW', Colors.red),
                  const SizedBox(height: 32),
                  ActivityGraph(graphData: terrarium.activity),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0),
                          side: BorderSide(color: Colors.grey.shade600),
                        ),
                      ),
                      minimumSize: MaterialStateProperty.all(Size(275, 60)),
                      backgroundColor: MaterialStateProperty.all(Colors.green.shade300),
                      overlayColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed)) {
                            return Colors.green.shade200;
                          }
                          return Colors.green.shade300;
                        },
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      'Edit Terrarium',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black, // Set text color to black
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, double value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitch(String title, bool value, String led) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(width: MediaQuery.sizeOf(context).width * 0.15),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 40),
          Switch(
            value: value,
            onChanged: (bool newValue) {
              toggleLed(led, newValue ? 'ON' : 'OFF');
            },
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(String title, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(width: MediaQuery.sizeOf(context).width * 0.15),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 40),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 16,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
