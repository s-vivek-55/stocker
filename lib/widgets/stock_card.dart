import 'package:flutter/material.dart';
import '../models/stock_item.dart';

/// Reusable stock item card widget
class StockCard extends StatefulWidget {
  final StockItem item;
  final VoidCallback onDelete;
  final Function(void Function()) onSetState;

  const StockCard({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onSetState,
  });

  @override
  State<StockCard> createState() => _StockCardState();
}

class _StockCardState extends State<StockCard> {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Rate: ₹${widget.item.price}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
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

            // Responsive Stock Fields Layout
            if (isMobile)
              Column(
                children: [
                  // Opening Stock (Mobile)
                  _buildOpeningField(),
                  const SizedBox(height: 10),
                  // Returned Stock Entries (Mobile)
                  _buildReturnedSection(),
                  const SizedBox(height: 10),
                  // Added Stock Entries (Mobile)
                  _buildAddedSection(),
                  const SizedBox(height: 10),
                  // Closing Stock Entries (Mobile)
                  _buildClosingSection(),
                ],
              )
            else
              // Desktop/Tablet Layout
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: _buildOpeningField(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: _buildReturnedSection(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: _buildAddedSection(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: _buildClosingSection(),
                      ),
                    ],
                  ),
                ],
              ),

            const SizedBox(height: 12),

            // Summary Section
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryStat('Sold', widget.item.sold),
                  _buildSummaryStat(
                    'Earnings',
                    '₹${widget.item.totalEarnings.toStringAsFixed(2)}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build opening stock field
  Widget _buildOpeningField() {
    return TextFormField(
      initialValue: widget.item.openingStock.toString(),
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Opening',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 12,
        ),
      ),
      onChanged: (val) => widget.onSetState(
        () => widget.item.openingStock = int.tryParse(val) ?? 0,
      ),
    );
  }

  /// Build returned stock section (scrollable)
  Widget _buildReturnedSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...List.generate(
            widget.item.returnedStockEntries.length,
            (returnedIndex) => Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: SizedBox(
                width: 90,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: widget
                            .item
                            .returnedStockEntries[returnedIndex]
                            .toString(),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'R${returnedIndex + 1}',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 10,
                          ),
                        ),
                        onChanged: (val) => widget.onSetState(() {
                          widget.item.returnedStockEntries[returnedIndex] =
                              int.tryParse(val) ?? 0;
                        }),
                      ),
                    ),
                    if (widget.item.returnedStockEntries.length > 1)
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.remove_circle,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () {
                          widget.onSetState(() {
                            widget.item.returnedStockEntries
                                .removeAt(returnedIndex);
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Center(
              child: IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  color: Colors.green,
                ),
                tooltip: 'Add Returned',
                onPressed: () {
                  widget.onSetState(
                    () => widget.item.returnedStockEntries.add(0),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build added stock section (scrollable)
  Widget _buildAddedSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...List.generate(
            widget.item.addedStockEntries.length,
            (addedIndex) => Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: SizedBox(
                width: 90,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: widget.item.addedStockEntries[addedIndex]
                            .toString(),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'A${addedIndex + 1}',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 10,
                          ),
                        ),
                        onChanged: (val) => widget.onSetState(() {
                          widget.item.addedStockEntries[addedIndex] =
                              int.tryParse(val) ?? 0;
                        }),
                      ),
                    ),
                    if (widget.item.addedStockEntries.length > 1)
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.remove_circle,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () {
                          widget.onSetState(() {
                            widget.item.addedStockEntries.removeAt(addedIndex);
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Center(
              child: IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  color: Colors.green,
                ),
                tooltip: 'Add Entry',
                onPressed: () {
                  widget.onSetState(
                    () => widget.item.addedStockEntries.add(0),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build closing stock section (scrollable)
  Widget _buildClosingSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...List.generate(
            widget.item.closingStockEntries.length,
            (closingIndex) => Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: SizedBox(
                width: 90,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: widget
                            .item
                            .closingStockEntries[closingIndex]
                            .toString(),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'C${closingIndex + 1}',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 10,
                          ),
                        ),
                        onChanged: (val) => widget.onSetState(() {
                          widget.item.closingStockEntries[closingIndex] =
                              int.tryParse(val) ?? 0;
                        }),
                      ),
                    ),
                    if (widget.item.closingStockEntries.length > 1)
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.remove_circle,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () {
                          widget.onSetState(() {
                            widget.item.closingStockEntries
                                .removeAt(closingIndex);
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Center(
              child: IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  color: Colors.green,
                ),
                tooltip: 'Add Closing',
                onPressed: () {
                  widget.onSetState(
                    () => widget.item.closingStockEntries.add(0),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build summary stat widget
  Widget _buildSummaryStat(String label, dynamic value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
                                            ),
                                      ),
                                      onChanged: (val) => widget.onSetState(() {
                                        widget
                                                .item
                                                .addedStockEntries[addedIndex] =
                                            int.tryParse(val) ?? 0;
                                      }),
                                    ),
                                  ),
                                  if (widget.item.addedStockEntries.length > 1)
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(
                                        Icons.remove_circle,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        widget.onSetState(() {
                                          widget.item.addedStockEntries
                                              .removeAt(addedIndex);
                                        });
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Add button for Added
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Center(
                            child: IconButton(
                              icon: const Icon(
                                Icons.add_circle,
                                color: Colors.green,
                              ),
                              tooltip: 'Add More',
                              onPressed: () {
                                widget.onSetState(
                                  () => widget.item.addedStockEntries.add(0),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Closing Stock Entries (Scrollable)
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...List.generate(
                          widget.item.closingStockEntries.length,
                          (closingIndex) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: SizedBox(
                              width: 100,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: widget
                                          .item
                                          .closingStockEntries[closingIndex]
                                          .toString(),
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'C${closingIndex + 1}',
                                        border: const OutlineInputBorder(),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 10,
                                            ),
                                      ),
                                      onChanged: (val) => widget.onSetState(() {
                                        widget
                                                .item
                                                .closingStockEntries[closingIndex] =
                                            int.tryParse(val) ?? 0;
                                      }),
                                    ),
                                  ),
                                  if (widget.item.closingStockEntries.length >
                                      1)
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(
                                        Icons.remove_circle,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        widget.onSetState(() {
                                          widget.item.closingStockEntries
                                              .removeAt(closingIndex);
                                        });
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Add button for Closing
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Center(
                            child: IconButton(
                              icon: const Icon(
                                Icons.add_circle,
                                color: Colors.green,
                              ),
                              tooltip: 'Add Closing',
                              onPressed: () {
                                widget.onSetState(
                                  () => widget.item.closingStockEntries.add(0),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Formula Label
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Opening - Returned + Added - Closing = Sold',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Summary Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sold: ${widget.item.sold < 0 ? 0 : widget.item.sold}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Earnings: ₹${widget.item.totalEarnings.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
