import 'package:cho_nun_btk/app/models/table/table.dart';
import 'package:cho_nun_btk/app/provider/table_provider.dart';
import 'package:flutter/material.dart';

class TableSelectionView extends StatelessWidget {
  const TableSelectionView({Key? key}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    final TableProvider _tableProvider = TableProvider();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Table'),
        centerTitle: true,
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
                    'No tables available',
                    style: Theme.of(context).textTheme.titleLarge,
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
                final isAvailable = table.tableStatus == TableStatus.AVAILABLE;

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: InkWell(
                    onTap: isAvailable
                        ? () {
                            TableModel temptable = table.copyWith(
                                tableStatus: TableStatus.OCCUPIED);

                            Navigator.pop(context, temptable);
                          }
                        : null,
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                table.tableName,
                                style: Theme.of(context).textTheme.titleMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  Icon(Icons.people,
                                      size: 20, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${table.capacity} seats',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
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
                        if (!isAvailable)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.lock_outline,
                                  color: Colors.grey[600],
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
