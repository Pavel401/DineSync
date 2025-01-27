import 'package:cloud_firestore/cloud_firestore.dart';

class TableModel {
  final String id; // Unique identifier for the table
  final String tableName; // Display name or number for the table
  final TableStatus tableStatus; // Current status of the table
  final int capacity; // Number of people the table can accommodate
  final String? currentOrderId; // ID of the current active order (if occupied)
  final String?
      location; // Location of the table (e.g., "Outdoor", "Main Hall")
  final Timestamp? reservedUntil; // Time until the table is reserved

  TableModel({
    required this.id,
    required this.tableName,
    required this.tableStatus,
    required this.capacity,
    this.currentOrderId,
    this.location,
    this.reservedUntil,
  });

  // JSON serialization
  Map<String, dynamic> toJson() => {
        'id': id,
        'tableName': tableName,
        'tableStatus': tableStatus.name,
        'capacity': capacity,
        'currentOrderId': currentOrderId,
        'location': location,
        'reservedUntil': reservedUntil,
      };

  // JSON deserialization
  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'],
      tableName: json['tableName'],
      tableStatus:
          TableStatus.values.firstWhere((e) => e.name == json['tableStatus']),
      capacity: json['capacity'],
      currentOrderId: json['currentOrderId'],
      location: json['location'],
      reservedUntil: json['reservedUntil'] != null
          ? (json['reservedUntil'] as Timestamp)
          : null,
    );
  }

  // CopyWith method
  TableModel copyWith({
    String? id,
    String? tableName,
    TableStatus? tableStatus,
    int? capacity,
    String? currentOrderId,
    String? location,
    Timestamp? reservedUntil,
  }) {
    return TableModel(
      id: id ?? this.id,
      tableName: tableName ?? this.tableName,
      tableStatus: tableStatus ?? this.tableStatus,
      capacity: capacity ?? this.capacity,
      currentOrderId: currentOrderId ?? this.currentOrderId,
      location: location ?? this.location,
      reservedUntil: reservedUntil ?? this.reservedUntil,
    );
  }
}

// TableStatus Enum
enum TableStatus {
  AVAILABLE,
  RESERVED,
  OCCUPIED,
  UNAVAILABLE,
}
