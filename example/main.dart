import 'package:flutter/material.dart';
import 'package:snack_pack/snack_pack.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snack Pack Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;
  Duration _selectedDuration = const Duration(seconds: 3);

  void _showSuccessSnackBar() {
    showCustomSnackBar(
      context,
      'Success! Operation completed successfully.',
      SnackBarType.success,
      duration: _selectedDuration,
    );
  }

  void _showFailureSnackBar() {
    showCustomSnackBar(
      context,
      'Error! Something went wrong. Please try again.',
      SnackBarType.failure,
      duration: _selectedDuration,
    );
  }

  void _showWarningSnackBar() {
    showCustomSnackBar(
      context,
      'Warning! Please check your input before proceeding.',
      SnackBarType.warning,
      duration: _selectedDuration,
    );
  }

  void _showInfoSnackBar() {
    showCustomSnackBar(
      context,
      'Info: Did you know you can swipe up to dismiss?',
      SnackBarType.info,
      duration: _selectedDuration,
    );
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
    showCustomSnackBar(
      context,
      'Counter incremented to counter!',
      SnackBarType.success,
      duration: _selectedDuration,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Snack Pack Demo'),
        elevation: 2,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.notifications_active,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              const Text(
                'Snack Pack Examples',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Tap any button to show a snack bar',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Duration',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SegmentedButton<Duration>(
                        segments: const [
                          ButtonSegment(
                            value: Duration(seconds: 2),
                            label: Text('2s'),
                          ),
                          ButtonSegment(
                            value: Duration(seconds: 3),
                            label: Text('3s'),
                          ),
                          ButtonSegment(
                            value: Duration(seconds: 5),
                            label: Text('5s'),
                          ),
                        ],
                        selected: {_selectedDuration},
                        onSelectionChanged: (Set<Duration> selected) {
                          setState(() {
                            _selectedDuration = selected.first;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildSnackBarButton(
                context,
                'Show Success',
                Colors.green,
                Icons.check_circle,
                _showSuccessSnackBar,
              ),
              const SizedBox(height: 16),
              _buildSnackBarButton(
                context,
                'Show Failure',
                Colors.red,
                Icons.error,
                _showFailureSnackBar,
              ),
              const SizedBox(height: 16),
              _buildSnackBarButton(
                context,
                'Show Warning',
                Colors.orange,
                Icons.warning,
                _showWarningSnackBar,
              ),
              const SizedBox(height: 16),
              _buildSnackBarButton(
                context,
                'Show Info',
                Colors.blue,
                Icons.info,
                _showInfoSnackBar,
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Counter: counter',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Each tap will show a success snack bar',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        icon: const Icon(Icons.add),
        label: const Text('Increment'),
      ),
    );
  }

  Widget _buildSnackBarButton(
    BuildContext context,
    String label,
    Color color,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
      ),
    );
  }
}
