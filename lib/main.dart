import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'dart:async';

void main() {
  runApp(const FitnessTrackerApp());
}

class FitnessTrackerApp extends StatelessWidget {
  const FitnessTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fitness Tracker',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const FitnessTrackerScreen(),
    );
  }
}

class FitnessTrackerScreen extends StatelessWidget {
  const FitnessTrackerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness Tracker'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to the tracking screen when the button is pressed
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TrackingPage()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text(
            'Start Tracking',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class TrackingPage extends StatefulWidget {
  const TrackingPage({Key? key}) : super(key: key);

  @override
  _TrackingPageState createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _steps = '0';
  String _status = 'Starting to track...';
  bool _isTracking = false;
  bool _isTrackingStarted = false;
  bool _isTrackingStopped = false;

  @override
  void initState() {
    super.initState();
    _initializePedometer();
  }

  void _initializePedometer() {
    _stepCountStream = Pedometer.stepCountStream;
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;

    _stepCountStream.listen(
      _onStepCount,
      onError: (error) => setState(() => _steps = 'Step Count not available'),
    );

    _pedestrianStatusStream.listen(
      _onPedestrianStatusChanged,
      onError: (error) => setState(() => _status = 'Status not available'),
    );
  }

  void _onStepCount(StepCount event) {
    setState(() {
      _steps = event.steps.toString();
    });
  }

  void _onPedestrianStatusChanged(PedestrianStatus event) {
    setState(() {
      _status = event.status;
    });
  }

  void _toggleTracking() async {
    setState(() {
      _isTracking = !_isTracking;
      if (_isTracking) {
        _status = 'Sensing your activity...'; // Simulate sensing
        _steps = '0';
        _isTrackingStarted = true;
        _isTrackingStopped = false;
      } else {
        _status = 'Tracking Stopped. Total steps: $_steps';
        _isTrackingStarted = false;
        _isTrackingStopped = true;
        _stepCountStream.drain();
        _pedestrianStatusStream.drain();
      }
    });

    if (_isTracking) {
      // Simulate a delay before showing "Tracking started" message.
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _status = 'Tracking Started! Keep Moving...';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracking in Progress'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: () {
              _toggleTracking(); // Stop tracking
              Navigator.pop(context, _steps); // Pass the steps count back
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(seconds: 1),
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(blurRadius: 8, color: Colors.green.shade200)],
              ),
              child: Column(
                children: [
                  Text(
                    'Steps Taken:',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _steps,
                    style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            AnimatedContainer(
              duration: const Duration(seconds: 1),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade50,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(blurRadius: 5, color: Colors.blueGrey.shade300, spreadRadius: 2)],
              ),
              child: Column(
                children: [
                  Text(
                    'Activity Status:',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _status,
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500, color: Colors.blueGrey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            AnimatedOpacity(
              opacity: _isTracking ? 1.0 : 0.0,
              duration: const Duration(seconds: 1),
              child: Center(
                child: Icon(
                  Icons.fitness_center,
                  color: Colors.green,
                  size: 80,
                ),
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: _toggleTracking,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isTracking ? Colors.red : Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _isTracking ? 'Stop Tracking' : 'Start Tracking',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
