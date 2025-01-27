import 'package:cho_nun_btk/app/models/table/table.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TableProvider {
  final CollectionReference tablesCollection =
      FirebaseFirestore.instance.collection('tables');

  // Fetch all tables as a stream
  Stream<List<TableModel>> getTablesStream() {
    return tablesCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => TableModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Add or update a table
  Future<void> saveTable(TableModel table) async {
    await tablesCollection.doc(table.id).set(table.toJson());
  }

  // Delete a table
  Future<void> deleteTable(String tableId) async {
    await tablesCollection.doc(tableId).delete();
  }
}
