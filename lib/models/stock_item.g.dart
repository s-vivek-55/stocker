// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StockItemAdapter extends TypeAdapter<StockItem> {
  @override
  final int typeId = 0;

  @override
  StockItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StockItem(
      name: fields[0] as String,
      price: fields[1] as double,
      openingStock: fields[2] as int,
      returnedStockEntries: (fields[3] as List?)?.cast<int>(),
      addedStockEntries: (fields[4] as List?)?.cast<int>(),
      closingStockEntries: (fields[5] as List?)?.cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, StockItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.price)
      ..writeByte(2)
      ..write(obj.openingStock)
      ..writeByte(3)
      ..write(obj.returnedStockEntries)
      ..writeByte(4)
      ..write(obj.addedStockEntries)
      ..writeByte(5)
      ..write(obj.closingStockEntries);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
