import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'firebase_config.dart';
import 'models/landmine_detection.dart';
import 'pages/history_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: firebaseConfig['apiKey'] as String,
      appId: firebaseConfig['appId'] as String,
      messagingSenderId: firebaseConfig['messagingSenderId'] as String,
      projectId: firebaseConfig['projectId'] as String,
      authDomain: firebaseConfig['authDomain'] as String,
      databaseURL: firebaseConfig['databaseURL'] as String,
      storageBucket: firebaseConfig['storageBucket'] as String,
      measurementId: firebaseConfig['measurementId'] as String,
    ),
  );
  
  final cameras = await availableCameras();
  
  // Force landscape orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(RobotControlApp(cameras: cameras));
}

class RobotControlApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const RobotControlApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Field Surveillance Robot',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: ControlScreen(cameras: cameras),
    );
  }
}

class ControlScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const ControlScreen({super.key, required this.cameras});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  final DatabaseReference _robotRef = FirebaseDatabase.instance.ref().child('robot');
  final DatabaseReference _sensorDataRef = FirebaseDatabase.instance.ref().child('sensor_data');
  bool isSearchModeOn = false;
  bool _isCraneOn = false;
  String _currentDirection = 'stop';
  double _temperature = 0.0;
  double _gasLevel = 0.0;
  double _craneAngle = 0.0;
  Position? _currentPosition;
  bool _isCameraInitialized = false;
  late CameraController _cameraController;
  List<LandmineDetection> _detections = [];
  late Stream<DatabaseEvent> _temperatureStream;
  late Stream<DatabaseEvent> _gasLevelStream;
  late Stream<DatabaseEvent> _positionStream;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _setupStreams();
  }

  void _setupStreams() {
    _temperatureStream = _sensorDataRef.child('temperature').onValue;
    _gasLevelStream = _sensorDataRef.child('gas').onValue;
    _positionStream = _sensorDataRef.child('position').onValue;

    _temperatureStream.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          _temperature = (event.snapshot.value as num).toDouble();
        });
      }
    });

    _gasLevelStream.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          _gasLevel = (event.snapshot.value as num).toDouble();
        });
      }
    });

    _positionStream.listen((event) {
      if (event.snapshot.value != null) {
        final Map<String, dynamic> posData = Map<String, dynamic>.from(event.snapshot.value as Map);
        setState(() {
          _currentPosition = Position(
            latitude: posData['latitude'],
            longitude: posData['longitude'],
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            altitudeAccuracy: 0,
            heading: 0,
            headingAccuracy: 0,
            speed: 0,
            speedAccuracy: 0,
          );
        });
      }
    });
  }

  void _sendMovementCommand(String direction) {
    setState(() {
      _currentDirection = direction;
    });
    _robotRef.child('commands').push().set({
      'type': 'movement',
      'direction': direction,
      'timestamp': ServerValue.timestamp,
    });
  }

  void _toggleCrane() {
    setState(() {
      _isCraneOn = !_isCraneOn;
    });
    _robotRef.child('commands').push().set({
      'type': 'crane',
      'status': _isCraneOn ? 'on' : 'off',
      'timestamp': ServerValue.timestamp,
    });
  }

  Future<void> _initializeCamera() async {
    _cameraController = CameraController(
      widget.cameras[0],
      ResolutionPreset.medium,
    );

    try {
      await _cameraController.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Camera preview takes 2/3 of the screen
          Expanded(
            flex: 2,
            child: _isCameraInitialized
                ? CameraPreview(_cameraController)
                : const Center(child: CircularProgressIndicator()),
          ),
          // Controls take 1/3 of the screen
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Movement controls
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () => _sendMovementCommand('forward'),
                        child: const Icon(Icons.arrow_upward, size: 32),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () => _sendMovementCommand('left'),
                            child: const Icon(Icons.arrow_back, size: 32),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _sendMovementCommand('stop'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Icon(Icons.stop, size: 32),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _sendMovementCommand('right'),
                            child: const Icon(Icons.arrow_forward, size: 32),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _sendMovementCommand('backward'),
                        child: const Icon(Icons.arrow_downward, size: 32),
                      ),
                    ],
                  ),
                  
                  // Crane control button
                  ElevatedButton.icon(
                    onPressed: _toggleCrane,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isCraneOn ? Colors.green : Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    icon: Icon(_isCraneOn ? Icons.construction : Icons.build),
                    label: Text(_isCraneOn ? 'Crane ON' : 'Crane OFF'),
                  ),

                  // Sensor readings
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Temperature: ${_temperature.toStringAsFixed(1)}°C',
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Gas Level: ${_gasLevel.toStringAsFixed(1)}',
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
