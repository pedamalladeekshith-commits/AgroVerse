import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CommunityForumScreen extends StatefulWidget {
  const CommunityForumScreen({super.key});

  @override
  _CommunityForumScreenState createState() => _CommunityForumScreenState();
}

class _CommunityForumScreenState extends State<CommunityForumScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _replyController = TextEditingController();

  List<dynamic> _posts = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    setState(() => _loading = true);
    try {
      final posts = await ApiService.getPosts();
      setState(() => _posts = posts.reversed.toList());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _addPost() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) return;
    try {
      await ApiService.addPost(_titleController.text, _contentController.text, "Farmer Ravi");
      _titleController.clear();
      _contentController.clear();
      Navigator.pop(context);
      _fetchPosts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _addReply(int postId) async {
    if (_replyController.text.isEmpty) return;
    try {
      await ApiService.addReply(postId, _replyController.text, "Farmer Ravi");
      _replyController.clear();
      Navigator.pop(context);
      _fetchPosts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _showAddPostDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("New Community Post", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Subject", border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _contentController, maxLines: 4, decoration: const InputDecoration(labelText: "Describe your problem or advice", border: OutlineInputBorder())),
            const SizedBox(height: 15),
            ElevatedButton(onPressed: _addPost, style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800], padding: const EdgeInsets.symmetric(vertical: 15)), child: const Text("Post to Community", style: TextStyle(color: Colors.white))),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showReplyDialog(int postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Reply to Post", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(controller: _replyController, maxLines: 3, decoration: const InputDecoration(labelText: "Your reply", border: OutlineInputBorder())),
            const SizedBox(height: 15),
            ElevatedButton(onPressed: () => _addReply(postId), style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800], padding: const EdgeInsets.symmetric(vertical: 12)), child: const Text("Submit Reply", style: TextStyle(color: Colors.white))),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Community Forum"), backgroundColor: Colors.green[800]),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchPosts,
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  final post = _posts[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    margin: const EdgeInsets.only(bottom: 15),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(backgroundColor: Colors.green[100], child: Text(post['author'][0], style: const TextStyle(fontWeight: FontWeight.bold))),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(post['author'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const Text("Posted recently", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 15),
                          Text(post['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                          const SizedBox(height: 8),
                          Text(post['content']),
                          const Divider(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("${post['replies'].length} Replies", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                              TextButton.icon(onPressed: () => _showReplyDialog(post['id']), icon: const Icon(Icons.reply), label: const Text("Reply")),
                            ],
                          ),
                          if (post['replies'].isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (var reply in post['replies'])
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: RichText(
                                        text: TextSpan(
                                          style: const TextStyle(color: Colors.black87),
                                          children: [
                                            TextSpan(text: "${reply['author']}: ", style: const TextStyle(fontWeight: FontWeight.bold)),
                                            TextSpan(text: reply['content']),
                                          ],
                                        ),
                                      ),
                                    )
                                ],
                              ),
                            )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPostDialog,
        backgroundColor: Colors.green[800],
        child: const Icon(Icons.add_comment, color: Colors.white),
      ),
    );
  }
}
