// CodeWithFlexz on Instagram

// AmirBayat0 on Github
// Programming with Flexz on Youtube

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FinalView(),
    );
  }
}

class FinalView extends StatefulWidget {
  const FinalView({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _FinalViewState createState() => _FinalViewState();
}

class _FinalViewState extends State<FinalView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<Map<String, dynamic>> allData = [];
  bool isLoading = true;

  void refreshData() async {
    final data = await SQLHelper.getItems();
    setState(() {
      allData = data;
      isLoading = false;
    });
  }

  void showForm(int? id) async {
    if (id != null) {
      // id != null -> update an existing item
      final existingJournal =
          allData.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['title'];
      _descriptionController.text = existingJournal['description'];
    }
    // id == null -> create new item
    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 200,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(hintText: 'Description'),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Colors.indigo),
              ),
              onPressed: () async {
                if (id == null) {
                  await addItem();
                }

                if (id != null) {
                  await updateItem(id);
                }

                _titleController.text = '';
                _descriptionController.text = '';

                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              },
              child: Text(id == null ? 'Create New' : 'Update'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> addItem() async {
    await SQLHelper.createItem(
        _titleController.text, _descriptionController.text);
    refreshData();
  }

  Future<void> updateItem(int id) async {
    await SQLHelper.updateItem(
        id, _titleController.text, _descriptionController.text);
    refreshData();
  }

  void deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.indigo,
        content: Text('正常に削除されました!'),
      ),
    );
    refreshData();
  }

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 223, 223, 223),
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text('To do List'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.indigo,
              ),
            )
          : allData.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FadeInUp(
                        from: 30,
                        child: const Text(
                          "すべてのタスクが終了した👍",
                          style: TextStyle(fontSize: 17),
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      FadeInUp(
                        from: 30,
                        delay: const Duration(milliseconds: 400),
                        child: Text(
                          "タスクの追加は＋ボタンで👇",
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 15, top: 15, bottom: 8),
                      child: Text(
                        "Latest Tasks",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 500,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: allData.length,
                        itemBuilder: (context, index) => Slidable(
                          key: const ValueKey(0),
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
                                flex: 2,
                                onPressed: (_) =>
                                    showForm(allData[index]['id']),
                                backgroundColor:
                                    const Color.fromARGB(255, 223, 223, 223),
                                foregroundColor: Colors.indigo,
                                icon: Icons.edit,
                                label: 'Edit',
                              ),
                              SlidableAction(
                                flex: 2,
                                onPressed: (_) =>
                                    deleteItem(allData[index]['id']),
                                backgroundColor:
                                    const Color.fromARGB(255, 223, 223, 223),
                                foregroundColor: Colors.indigo,
                                icon: Icons.delete,
                                label: 'Delete',
                              ),
                            ],
                          ),
                          child: Card(
                            color: Colors.indigo,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5),
                            child: ListTile(
                              title: Text(
                                allData[index]['title'],
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                allData[index]['description'],
                                style: const TextStyle(
                                    color: Color.fromARGB(199, 255, 255, 255)),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add),
        onPressed: () => showForm(null),
      ),
    );
  }
}
