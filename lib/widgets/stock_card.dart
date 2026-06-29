import 'package:flutter/material.dart';
import '../models/stock_item.dart';

/// Reusable stock item card widget
class StockCard extends StatefulWidget {
  final StockItem item;
  final VoidCallback onDelete;
  final Function(void Function()) onSetState;
  final String currentTheme;

  const StockCard({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onSetState,
    this.currentTheme = 'default',
  });

  @override
  State<StockCard> createState() => _StockCardState();
}

class _StockCardState extends State<StockCard> {
  late TextEditingController _openingController;
  late TextEditingController _priceController;
  late List<TextEditingController> _returnedControllers;
  late List<TextEditingController> _addedControllers;
  late List<TextEditingController> _closingControllers;
  bool _initialized = false;

  void _initializeControllers() {
    if (_initialized) return;

    _priceController = TextEditingController(
      text: widget.item.price.toString(),
    );
    _openingController = TextEditingController(
      text: widget.item.openingStock.toString(),
    );
    _returnedControllers = List.generate(
      widget.item.returnedStockEntries.length,
      (idx) => TextEditingController(
        text: widget.item.returnedStockEntries[idx].toString(),
      ),
    );
    _addedControllers = List.generate(
      widget.item.addedStockEntries.length,
      (idx) => TextEditingController(
        text: widget.item.addedStockEntries[idx].toString(),
      ),
    );
    _closingControllers = List.generate(
      widget.item.closingStockEntries.length,
      (idx) => TextEditingController(
        text: widget.item.closingStockEntries[idx].toString(),
      ),
    );
    _initialized = true;
  }

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void didUpdateWidget(StockCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only reinitialize if the item reference changed
    if (oldWidget.item != widget.item) {
      _initialized = false;
      _initializeControllers();
      return;
    }
  }

  @override
  void dispose() {
    if (_initialized) {
      _priceController.dispose();
      _openingController.dispose();
      for (var controller in _returnedControllers) {
        controller.dispose();
      }
      for (var controller in _addedControllers) {
        controller.dispose();
      }
      for (var controller in _closingControllers) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  /// Get card background color based on theme
  Color _getCardColor() {
    if (widget.currentTheme == 'dark') {
      return const Color(0xFF2d2d2d).withOpacity(0.75);
    }
    return const Color.fromARGB(255, 216, 234, 245).withOpacity(0.75);
  }

  /// Get text color based on theme
  Color _getTextColor() {
    if (widget.currentTheme == 'dark') {
      return Colors.white;
    }
    return Colors.black;
  }

  /// Round price: if decimal >= 0.50, round to next integer
  double _roundPrice(double value) {
    final decimal = value - value.toInt();
    if (decimal >= 0.50) {
      return (value.toInt() + 1).toDouble();
    }
    return value.floorToDouble();
  }

  /// Get label text color based on theme
  Color _getLabelColor() {
    if (widget.currentTheme == 'dark') {
      return Colors.grey[400]!;
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: _getCardColor(),
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with delete button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Item',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.item.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getItemNameColor(),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rate',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _getThemeBorderColor(),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _getThemeBorderColor(),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _getThemeBorderColor(),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 6,
                          ),
                          isDense: true,
                        ),
                        onChanged: (val) => widget.onSetState(
                          () => widget.item.price = double.tryParse(val) ?? 0.0,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Stock Values Display - EDITABLE FIELDS
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Opening Field
                  SizedBox(width: 45, child: _buildOpeningField()),
                  const SizedBox(width: 2),
                  // Remaining Field (Returned)
                  _buildRemainingRow(),
                  const SizedBox(width: 8),
                  // Added Field
                  _buildAddedRow(),
                  const SizedBox(width: 8),
                  // Closing Field
                  _buildClosingRow(),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Summary Section
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getSummaryBackgroundColor(),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryStat('Sold', widget.item.sold, _getSoldColor()),
                  _buildSummaryStat(
                    'Earnings',
                    '${_roundPrice(widget.item.totalEarnings).toStringAsFixed(0)}',
                    _getEarningsColor(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpeningField() {
    return TextFormField(
      controller: _openingController,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic,
        color: _getOpeningTextColor(),
      ),
      decoration: const InputDecoration(
        labelText: 'O',
        border: OutlineInputBorder(),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      ),
      onTap: () {
        _openingController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _openingController.value.text.length,
        );
      },
      onChanged: (val) => widget.onSetState(
        () => widget.item.openingStock = int.tryParse(val) ?? 0,
      ),
    );
  }

  Widget _buildRemainingField() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: _buildRemainingRow(),
    );
  }

  Widget _buildRemainingRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(
          widget.item.returnedStockEntries.length,
          (idx) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                child: SizedBox(
                  width: 45,
                  child: TextFormField(
                    controller: _returnedControllers[idx],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _getRemovedValueColor(),
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      labelText: widget.item.returnedStockEntries.length == 1
                          ? 'R'
                          : 'R${idx + 1}',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 4,
                      ),
                    ),
                    onTap: () {
                      _returnedControllers[idx].selection = TextSelection(
                        baseOffset: 0,
                        extentOffset:
                            _returnedControllers[idx].value.text.length,
                      );
                    },
                    onChanged: (val) => widget.onSetState(() {
                      widget.item.returnedStockEntries[idx] =
                          int.tryParse(val) ?? 0;
                    }),
                  ),
                ),
              ),
              if (widget.item.returnedStockEntries.length > 1)
                SizedBox(
                  width: 30,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.remove_circle,
                      color: Colors.red,
                      size: 20,
                    ),
                    onPressed: () {
                      widget.onSetState(() {
                        _returnedControllers[idx].dispose();
                        _returnedControllers.removeAt(idx);
                        widget.item.returnedStockEntries.removeAt(idx);
                      });
                    },
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: InkWell(
            onTap: () {
              widget.onSetState(() {
                widget.item.returnedStockEntries.add(0);
                _returnedControllers.add(TextEditingController(text: '0'));
              });
            },
            borderRadius: BorderRadius.circular(10),
            child: const Icon(Icons.add_circle, color: Colors.green, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildAddedSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: _buildAddedRow(),
    );
  }

  Widget _buildAddedRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(
          widget.item.addedStockEntries.length,
          (idx) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                child: SizedBox(
                  width: 45,
                  child: TextFormField(
                    controller: _addedControllers[idx],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _getAddedValueColor(),
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      labelText: 'A${idx + 1}',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 4,
                      ),
                    ),
                    onTap: () {
                      _addedControllers[idx].selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: _addedControllers[idx].value.text.length,
                      );
                    },
                    onChanged: (val) => widget.onSetState(() {
                      widget.item.addedStockEntries[idx] =
                          int.tryParse(val) ?? 0;
                    }),
                  ),
                ),
              ),
              if (widget.item.addedStockEntries.length > 2 &&
                  idx == widget.item.addedStockEntries.length - 1)
                SizedBox(
                  width: 30,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.remove_circle,
                      color: Colors.red,
                      size: 20,
                    ),
                    onPressed: () {
                      widget.onSetState(() {
                        _addedControllers[idx].dispose();
                        _addedControllers.removeAt(idx);
                        widget.item.addedStockEntries.removeAt(idx);
                      });
                    },
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: InkWell(
            onTap: () {
              widget.onSetState(() {
                widget.item.addedStockEntries.add(0);
                _addedControllers.add(TextEditingController(text: '0'));
              });
            },
            borderRadius: BorderRadius.circular(10),
            child: const Icon(Icons.add_circle, color: Colors.green, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildClosingSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: _buildClosingRow(),
    );
  }

  Widget _buildClosingRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(
          widget.item.closingStockEntries.length,
          (idx) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                child: SizedBox(
                  width: 45,
                  child: TextFormField(
                    controller: _closingControllers[idx],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _getClosingValueColor(),
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      labelText: widget.item.closingStockEntries.length == 1
                          ? 'C'
                          : 'C${idx + 1}',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 4,
                      ),
                    ),
                    onTap: () {
                      _closingControllers[idx].selection = TextSelection(
                        baseOffset: 0,
                        extentOffset:
                            _closingControllers[idx].value.text.length,
                      );
                    },
                    onChanged: (val) => widget.onSetState(() {
                      widget.item.closingStockEntries[idx] =
                          int.tryParse(val) ?? 0;
                    }),
                  ),
                ),
              ),
              if (widget.item.closingStockEntries.length > 1 &&
                  idx == widget.item.closingStockEntries.length - 1)
                SizedBox(
                  width: 30,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.remove_circle,
                      color: Colors.red,
                      size: 20,
                    ),
                    onPressed: () {
                      widget.onSetState(() {
                        _closingControllers[idx].dispose();
                        _closingControllers.removeAt(idx);
                        widget.item.closingStockEntries.removeAt(idx);
                      });
                    },
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: InkWell(
            onTap: () {
              widget.onSetState(() {
                widget.item.closingStockEntries.add(0);
                _closingControllers.add(TextEditingController(text: '0'));
              });
            },
            borderRadius: BorderRadius.circular(10),
            child: const Icon(Icons.add_circle, color: Colors.green, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryStat(String label, dynamic value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /// Get theme-aware border color
  Color _getThemeBorderColor() {
    switch (widget.currentTheme) {
      case 'green':
        return const Color(0xFF2E7D32);
      case 'orange':
        return const Color(0xFFF57C00);
      case 'dark':
        return const Color(0xFF616161);
      default: // default (blue)
        return const Color(0xFF283593);
    }
  }

  /// Get sold color based on theme
  Color _getSoldColor() {
    if (widget.currentTheme == 'dark') {
      return const Color(0xFFCE93D8); // Light purple for dark mode
    }
    return Colors.purple;
  }

  /// Get earnings color based on theme
  Color _getEarningsColor() {
    if (widget.currentTheme == 'dark') {
      return const Color(0xFF81C784); // Light green for dark mode
    }
    return const Color(0xFF1B5E20); // Dark green for light modes
  }

  /// Get summary section background color based on theme
  Color _getSummaryBackgroundColor() {
    switch (widget.currentTheme) {
      case 'green':
        return const Color(0xFF388E3C).withOpacity(0.15);
      case 'orange':
        return const Color(0xFFFF9800).withOpacity(0.15);
      case 'dark':
        return const Color(0xFF424242).withOpacity(0.6);
      default: // default (blue)
        return const Color(0xFF3f51b5).withOpacity(0.15);
    }
  }

  /// Get opening label color based on theme
  Color _getOpeningLabelColor() {
    if (widget.currentTheme == 'dark') {
      return Colors.white;
    }
    return _getLabelColor();
  }

  /// Get opening stock text color based on theme
  Color _getOpeningTextColor() {
    if (widget.currentTheme == 'dark') {
      return Colors.white.withOpacity(0.75);
    }
    return Colors.black;
  }

  /// Get item name color based on theme
  Color _getItemNameColor() {
    if (widget.currentTheme == 'dark') {
      return Colors.white.withOpacity(0.75);
    }
    return Colors.black;
  }

  /// Get removed/returned value color based on theme
  Color _getRemovedValueColor() {
    switch (widget.currentTheme) {
      case 'dark':
        return const Color(0xFFFFB74D); // Light orange for dark mode
      case 'green':
        return const Color(0xFFFFA726); // Lighter orange for green theme
      case 'orange':
        return const Color(0xFFE65100); // Darker orange for orange theme
      default: // default (blue)
        return const Color(0xFFF57C00); // Standard orange
    }
  }

  /// Get added value color based on theme
  Color _getAddedValueColor() {
    switch (widget.currentTheme) {
      case 'dark':
        return const Color(0xFF81C784); // Light green for dark mode
      case 'green':
        return const Color(0xFF1B5E20); // Dark green for green theme
      case 'orange':
        return const Color(0xFF66BB6A); // Medium green for orange theme
      default: // default (blue)
        return const Color(0xFF2E7D32); // Dark green for blue theme
    }
  }

  /// Get closing value color based on theme
  Color _getClosingValueColor() {
    switch (widget.currentTheme) {
      case 'dark':
        return const Color(0xFFEF5350); // Light red for dark mode
      case 'green':
        return const Color(0xFFEF5350); // Red for green theme
      case 'orange':
        return const Color(0xFFEF5350); // Red for orange theme
      default: // default (blue)
        return const Color(0xFFD32F2F); // Dark red for blue theme
    }
  }
}
