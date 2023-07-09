import 'dart:math';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'database_helper.dart';
import 'api_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: InstallScreen(),
    );
  }
}

class InstallScreen extends StatefulWidget {
  @override
  _InstallScreenState createState() => _InstallScreenState();
}

class _InstallScreenState extends State<InstallScreen> {
  final String successMessage = 'done';
  final String failedMessage = 'failed';

  String appId = '';
  String status = '';

  @override
  void initState() {
    super.initState();
    _checkInstallationStatus();
  }

  Future<void> _checkInstallationStatus() async {
    final List<Map<String, dynamic>> results = await DatabaseHelper.instance.getInstallationData();

    if (results.isEmpty) {
      // Generate a random app ID and set status as 'new'
      final Random random = Random();
      final int randomId = random.nextInt(10000);
      appId = randomId.toString();
      status = 'new';

      // Insert app data into SQLite database
     // await DatabaseHelper.instance.insertAppData(appId, status);

      // Send app data to API
      final String response = successMessage;//await ApiService.sendDataToApi(appId);

      if (response == successMessage) {
        // Update status as 'done'
        //await DatabaseHelper.instance.updateStatus(appId, 'done');

        // Redirect to QR scan screen on success
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QRScanScreen()),
        );
      } else {
        // Show retry button on failure
        setState(() {
          status = 'failed';
        });
      }
    } else {
      if(results.first['status'] == 'done'){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QRScanScreen()),
        );
      }else{
        setState(() {
          status = 'failed';
        });
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Install Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'App ID: $appId',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            if (status == 'new')
              CircularProgressIndicator()
            else if (status == 'done')
              ElevatedButton(
                child: const Text('Continue'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QRScanScreen()),
                  );
                },
              )
            else if (status == 'failed')
                ElevatedButton(
                  child: const Text('Try Again'),
                  onPressed: () async {
                    // Reset status and check installation again
                    setState(() {
                      status = '';
                    });
                    await _checkInstallationStatus();
                  },
                ),
          ],
        ),
      ),
    );
  }
}


class QRScanScreen extends StatefulWidget {
  @override
  _QRScanScreenState createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  QRViewController? controller;
  String qrCodeData = '';
  bool sendingData = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Scan')),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: ElevatedButton(
                child: const Text('Send'),
                onPressed: sendingData ? null : _sendQRCodeData,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrCodeData = scanData.code!;
      });
    });
  }

  void _sendQRCodeData() async {
    setState(() {
      sendingData = true;
    });

    final String response = await ApiService.sendDataToApi(qrCodeData);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Result'),
        content: Text(response == 'success' ? 'Data sent successfully.' : 'Failed to send data.'),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              if (response == 'success') {
                // Clear QR code data and continue scanning
                setState(() {
                  qrCodeData = '';
                  sendingData = false;
                });
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
