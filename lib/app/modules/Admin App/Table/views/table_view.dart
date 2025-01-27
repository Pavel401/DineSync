import 'package:cho_nun_btk/app/models/table/table.dart';
import 'package:cho_nun_btk/app/provider/table_provider.dart';
import 'package:flutter/material.dart';

class TableBuilderView extends StatefulWidget {
  const TableBuilderView({Key? key}) : super(key: key);

  @override
  State<TableBuilderView> createState() => _TableBuilderViewState();
}

class _TableBuilderViewState extends State<TableBuilderView> {
  final TableProvider _tableProvider = TableProvider();
  final _formKey = GlobalKey<FormState>();

  Future<void> _showTableBottomSheet({TableModel? table}) async {
    final isEditing = table != null;
    final TextEditingController tableNameController =
        TextEditingController(text: table?.tableName ?? '');
    final TextEditingController capacityController =
        TextEditingController(text: table?.capacity.toString() ?? '4');
    TableStatus selectedStatus = table?.tableStatus ?? TableStatus.AVAILABLE;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        Text(
                          isEditing ? 'Edit Table' : 'Create New Table',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: tableNameController,
                          decoration: InputDecoration(
                            labelText: 'Table Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.table_restaurant),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a table name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: capacityController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Capacity',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.people),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter capacity';
                            }
                            if (int.tryParse(value) == null ||
                                int.parse(value) <= 0) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<TableStatus>(
                          value: selectedStatus,
                          decoration: InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.check_circle_outline),
                          ),
                          onChanged: (TableStatus? newStatus) {
                            setModalState(() {
                              selectedStatus = newStatus!;
                            });
                          },
                          items: TableStatus.values.map((status) {
                            return DropdownMenuItem<TableStatus>(
                              value: status,
                              child: Text(status.name),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    final newTable = TableModel(
                                      id: table?.id ??
                                          _tableProvider.tablesCollection
                                              .doc()
                                              .id,
                                      tableName:
                                          tableNameController.text.trim(),
                                      tableStatus: selectedStatus,
                                      capacity:
                                          int.parse(capacityController.text),
                                    );
                                    await _tableProvider.saveTable(newTable);
                                    Navigator.pop(context);
                                  }
                                },
                                child:
                                    Text(isEditing ? 'Save Changes' : 'Create'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tables'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _showTableBottomSheet(),
            icon: const Icon(Icons.add),
            tooltip: 'Add New Table',
          ),
        ],
      ),
      body: StreamBuilder<List<TableModel>>(
        stream: _tableProvider.getTablesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.table_restaurant,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No tables found',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add a new table',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            );
          }

          final tables = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: tables.length,
              itemBuilder: (context, index) {
                final table = tables[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: InkWell(
                    onTap: () => _showTableBottomSheet(table: table),
                    borderRadius: BorderRadius.circular(15),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  table.tableName,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              PopupMenuButton(
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    child: const Text('Edit'),
                                    onTap: () =>
                                        _showTableBottomSheet(table: table),
                                  ),
                                  PopupMenuItem(
                                    child: const Text('Delete'),
                                    onTap: () async {
                                      await _tableProvider
                                          .deleteTable(table.id);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Icon(Icons.people,
                                  size: 20, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                '${table.capacity} seats',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(table.tableStatus)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              table.tableStatus.name,
                              style: TextStyle(
                                color: _getStatusColor(table.tableStatus),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTableBottomSheet(),
        icon: const Icon(Icons.add),
        label: const Text('Add Table'),
      ),
    );
  }

  Color _getStatusColor(TableStatus status) {
    switch (status) {
      case TableStatus.AVAILABLE:
        return Colors.green;
      case TableStatus.OCCUPIED:
        return Colors.red;
      case TableStatus.RESERVED:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
