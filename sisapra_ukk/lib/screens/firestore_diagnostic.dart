import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Diagnostic screen untuk test Firestore connection
class FirestoreDiagnosticScreen extends StatefulWidget {
  const FirestoreDiagnosticScreen({super.key});

  @override
  State<FirestoreDiagnosticScreen> createState() =>
      _FirestoreDiagnosticScreenState();
}

class _FirestoreDiagnosticScreenState extends State<FirestoreDiagnosticScreen> {
  String _status = 'Checking...';
  String _details = '';
  Color _statusColor = Colors.orange;

  @override
  void initState() {
    super.initState();
    _testFirestore();
  }

  Future<void> _testFirestore() async {
    try {
      // Test 1: Can we access Firestore instance?
      final db = FirebaseFirestore.instance;
      setState(() {
        _status = '✅ Firestore instance accessible';
        _details = '$_details\n✅ FirebaseFirestore.instance loaded';
      });

      // Test 2: Can we reach the collection?
      final coll = db.collection('aspirasi');
      setState(() {
        _details = '$_details\n✅ Collection reference created';
      });

      // Test 3: Try to read (non-destructive)
      final snapshot = await coll.limit(1).get();
      setState(() {
        _details =
            '$_details\n✅ Read test successful (${snapshot.docs.length} docs)';
      });

      // Test 4: Try to write test document
      final testDoc = db
          .collection('_test')
          .doc('test_${DateTime.now().millisecondsSinceEpoch}');
      await testDoc.set({'test': true, 'timestamp': Timestamp.now()});

      setState(() {
        _status = '✅ FIRESTORE WORKING!';
        _details =
            '$_details\n✅ Write test successful\n\n🎉 You can now submit aspirasi!';
        _statusColor = Colors.green;
      });

      // Clean up test doc
      await testDoc.delete();
    } catch (e) {
      setState(() {
        _status = '❌ FIRESTORE ERROR';
        _details = '$_details\n\n❌ Error: $e\n\n'
            '📌 SOLUTION:\n'
            '1. Open Firebase Console\n'
            '2. Go to sisapraukk project → Firestore → Rules\n'
            '3. Replace with permissive rules (allow read, write: if true)\n'
            '4. Click Publish\n'
            '5. Wait 30s and refresh this page';
        _statusColor = Colors.red;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔍 Firestore Diagnostic'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.1),
                border: Border.all(color: _statusColor, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _status,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _statusColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _details,
                    style: const TextStyle(fontSize: 14, height: 1.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'ℹ️ What to do next:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStep(
              '1',
              'Check Firestore Security Rules',
              'Must have "allow write: if true" for testing',
            ),
            const SizedBox(height: 12),
            _buildStep(
              '2',
              'Refresh this page',
              'After updating rules, wait 30s and refresh',
            ),
            const SizedBox(height: 12),
            _buildStep(
              '3',
              'If still error, check browser console',
              'Press F12 → Console tab → look for error messages',
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _status = 'Checking...';
                    _details = '';
                    _statusColor = Colors.orange;
                  });
                  await _testFirestore();
                },
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('🔄 Re-test Firestore',
                      style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String num, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
