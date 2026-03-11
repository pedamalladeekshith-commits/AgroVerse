import 'package:flutter/material.dart';
import '../services/api_service.dart';

class FarmLogScreen extends StatefulWidget {
  const FarmLogScreen({super.key});

  @override
  _FarmLogScreenState createState() => _FarmLogScreenState();
}

class _FarmLogScreenState extends State<FarmLogScreen> {
  final _activityController = TextEditingController();
  final _expenseController = TextEditingController();
  final _stageController = TextEditingController();
  final _notesController = TextEditingController();

  List<dynamic> _logs = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    setState(() => _loading = true);
    try {
      final logs = await ApiService.getFarmLogs();
      setState(() => _logs = logs.reversed.toList());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _addLog() async {
    if (_activityController.text.isEmpty) return;

    final log = {
      "date": DateTime.now().toString().split(' ')[0],
      "activity": _activityController.text,
      "expense": double.tryParse(_expenseController.text) ?? 0.0,
      "crop_stage": _stageController.text,
      "notes": _notesController.text
    };

    try {
      await ApiService.addFarmLog(log);
      _activityController.clear();
      _expenseController.clear();
      _stageController.clear();
      _notesController.clear();
      Navigator.pop(context);
      _fetchLogs();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _showAddLogDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Add Farm Activity", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(controller: _activityController, decoration: const InputDecoration(labelText: "Activity (e.g., Sowing, Squirting)", border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _expenseController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Expense (₹)", border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _stageController, decoration: const InputDecoration(labelText: "Crop Stage", border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _notesController, maxLines: 3, decoration: const InputDecoration(labelText: "Notes", border: OutlineInputBorder())),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addLog,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800], padding: const EdgeInsets.symmetric(vertical: 15)),
              child: const Text("Save Log", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Farm Activity Log"), backgroundColor: Colors.green[800]),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
              ? const Center(child: Text("No logs yet. Tap + to add one."))
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    final log = _logs[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(log['date'], style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                Text("₹${log['expense']}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const Divider(),
                            Text(log['activity'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                            if (log['crop_stage'].isNotEmpty) Text("Stage: ${log['crop_stage']}"),
                            if (log['notes'].isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(log['notes'], style: const TextStyle(fontStyle: FontStyle.italic)),
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLogDialog,
        backgroundColor: Colors.green[800],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
