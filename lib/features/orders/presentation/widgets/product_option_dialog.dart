import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hompimpa_pos/features/products/domain/product.dart';
import 'package:hompimpa_pos/features/products/data/topping_repository.dart';
import 'package:hompimpa_pos/features/products/domain/topping.dart';
import 'package:hompimpa_pos/features/settings/data/settings_repository.dart';
import 'package:hompimpa_pos/features/settings/domain/sambal_settings.dart';
import '../cart_controller.dart';

class ProductOptionDialog extends ConsumerStatefulWidget {
  final Product product;
  const ProductOptionDialog({Key? key, required this.product}) : super(key: key);

  @override
  ConsumerState<ProductOptionDialog> createState() => _ProductOptionDialogState();
}

class _ProductOptionDialogState extends ConsumerState<ProductOptionDialog> {
  int _qty = 1;
  String _sambal = 'Campur';
  double _level = 1;
  final _noteController = TextEditingController();
  
  // Topping State
  final Map<String, int> _selectedToppings = {}; // id -> qty
  
  @override
  void initState() {
    super.initState();
  }

  Color _getSliderColor() {
    if (_level <= 2) return Colors.green;
    if (_level <= 4) return Colors.amber;
    if (_level <= 6) return Colors.orange;
    return Colors.red;
  }

  double _calculateTotal(List<Topping> availableToppings) {
    // Watch settings inside build if possible, but here we are in a helper.
    // We'll pass the settings to this function or read them from ref.
    final sambalSettings = ref.read(sambalSettingsProvider).value ?? const SambalSettings();
    
    double unitPrice = widget.product.price;
    final isMie = widget.product.category.toLowerCase().contains('mie') || widget.product.name.toLowerCase().contains('mie');
    
    if (isMie) {
      unitPrice += 1500; // Default pangsit
    }
    
    _selectedToppings.forEach((id, qty) {
       final topping = availableToppings.firstWhere((t) => t.id == id, orElse: () => const Topping(id: '', name: '', price: 0, stock: 0));
       unitPrice += topping.price * qty;
    });

    // Spicy Level Charge
    if (isMie || widget.product.category.toLowerCase().contains('pangsit') || widget.product.name.toLowerCase().contains('pangsit')) {
       if (_level >= 6) {
         unitPrice += sambalSettings.level6to7Price;
       } else if (_level >= 4) {
         unitPrice += sambalSettings.level4to5Price;
       } else {
         unitPrice += sambalSettings.level0to3Price;
       }
    }

    return unitPrice * _qty;
  }

  @override
  Widget build(BuildContext context) {
    final toppingsAsync = ref.watch(toppingListProvider);
    final isMie = widget.product.category.toLowerCase().contains('mie') || widget.product.name.toLowerCase().contains('mie');

    print('DEBUG: Product Category: ${widget.product.category}');
    print('DEBUG: Product Name: ${widget.product.name}');
    print('DEBUG: isMie: $isMie');
    
    return toppingsAsync.when(
      loading: () => const AlertDialog(content: Center(child: CircularProgressIndicator())),
      error: (e, s) => AlertDialog(title: const Text('Error'), content: Text('$e')),
      data: (allToppings) {
        // Watch sambal settings to ensure rebuild when they change
        ref.watch(sambalSettingsProvider);
        final isMie = widget.product.category.toLowerCase().contains('mie') || widget.product.name.toLowerCase().contains('mie');
        final isLevelable = isMie || widget.product.category.toLowerCase().contains('pangsit') || widget.product.name.toLowerCase().contains('pangsit');
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 600;

        final activeToppings = allToppings.where((t) => t.isActive && t.stock > 0).toList();
        print('DEBUG: Active Toppings: ${activeToppings.length}');
        
        // Customization UI
        Widget buildCustomizationFields() {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Qty
              const Text('Jumlah (Qty)', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
                  ),
                  Text('$_qty', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      if (_qty + 1 > widget.product.stock) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Stok tidak cukup! Maks: ${widget.product.stock}')),
                        );
                        return;
                      }
                      setState(() => _qty++);
                    },
                  ),
                ],
              ),
              const Divider(),
              
              if (isLevelable) ...[
                // Sambal
                const Text('Opsi Sambal', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Radio<String>(
                      value: 'Campur',
                      groupValue: _sambal,
                      onChanged: (v) => setState(() => _sambal = v!),
                    ),
                    const Text('Campur'),
                    Radio<String>(
                      value: 'Pisah',
                      groupValue: _sambal,
                      onChanged: (v) => setState(() => _sambal = v!),
                    ),
                    const Text('Pisah'),
                  ],
                ),
                const Divider(),
                
                // Level
                Text('Level Pedas: ${_level.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: _getSliderColor(),
                    thumbColor: _getSliderColor(),
                    overlayColor: _getSliderColor().withOpacity(0.2),
                  ),
                  child: Slider(
                    value: _level,
                    min: 0,
                    max: 7,
                    divisions: 7,
                    label: _level.toInt().toString(),
                    onChanged: (v) => setState(() => _level = v),
                  ),
                ),
                const Divider(),
              ],
              
              // Note
              const Text('Catatan (Note)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Tanpa daun bawang',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              if (!isLevelable || isSmallScreen) _buildTotalSection(allToppings),
            ],
          );
        }

        Widget buildToppingsList() {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Topping', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if(isMie)
              // Default Pangsit (Locked)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.lock, size: 16, color: Colors.grey),
                  title: const Text('Pangsit (Default)', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('+ Rp 1.500 (Wajib)'),
                  trailing: const Icon(Icons.check_circle, color: Colors.green),
                ),
              ),
              // Extra Toppings
              ...activeToppings.map((topping) {
                final currentQty = _selectedToppings[topping.id] ?? 0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: currentQty > 0 ? Colors.orange[50] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: currentQty > 0 ? Colors.orange[200]! : Colors.grey[200]!),
                  ),
                  child: ListTile(
                    dense: true,
                    title: Text(topping.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Rp ${topping.price.toStringAsFixed(0)} | Sisa: ${topping.stock}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (currentQty > 0)
                          IconButton(
                            icon: const Icon(Icons.remove_circle, size: 24, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                 if (currentQty > 1) {
                                   _selectedToppings[topping.id] = currentQty - 1;
                                 } else {
                                   _selectedToppings.remove(topping.id);
                                 }
                              });
                            },
                          ),
                        if (currentQty > 0)
                           Padding(
                             padding: const EdgeInsets.symmetric(horizontal: 4),
                             child: Text('$currentQty', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                           ),
                        IconButton(
                          icon: const Icon(Icons.add_circle, size: 24, color: Colors.green),
                          onPressed: () {
                            if (currentQty + 1 > topping.stock) {
                               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Stok ${topping.name} tidak cukup')));
                               return;
                            }
                            setState(() {
                              _selectedToppings[topping.id] = currentQty + 1;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        }

        return AlertDialog(
          title: Text('Customization: ${widget.product.name}'),
          content: SizedBox(
            width: (isLevelable && !isSmallScreen) ? 800 : (isSmallScreen ? screenWidth : 450),
            child: SingleChildScrollView(
              child: isLevelable 
                ? (isSmallScreen 
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          buildCustomizationFields(),
                          const Divider(height: 32),
                          buildToppingsList(),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Column: Customization
                          Expanded(
                            flex: 5,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                buildCustomizationFields(),
                                const SizedBox(height: 16),
                                _buildTotalSection(allToppings),
                              ],
                            ),
                          ),
                          const VerticalDivider(width: 32),
                          // Right Column: Toppings
                          Expanded(
                            flex: 5,
                            child: buildToppingsList(),
                          ),
                        ],
                      )
                  )
                : buildCustomizationFields(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                // Build Toppings List
                List<Topping> finalToppings = [];
                
                // Add Default Pangsit
                if (isMie) {
                   // Mock ID for default pangsit or use real one? 
                   // Prompt says: Product Logic: "One order mie: AUTO add default topping: PANGSIT"
                   // We should add it to the OrderItem so it tracks stock later?
                   // "On order submit: Reduce topping stock... Default pangsit ALWAYS reduces stock"
                   // "Default pangsit: stock: 10000" (from Master Data)
                   
                   // So we DO need to map valid Topping object for Default Pangsit.
                   // From InMemoryRepo: id='pangsit', price=1500.
                   // But here we charge 3000.
                   // Strategy: Add a special Topping with price=3000? 
                   // OR keep ID='pangsit' (so stock reduces correctly) but override price to 3000?
                   // OrderItem has `price`. Toppings list is just for reference/stock? 
                   // OrderItem.toppings is List<Topping>. Topping has `.price`.
                   
                   // Let's find 'pangsit' in `allToppings`.
                   final pangsitParams = allToppings.firstWhere((t) => t.id == 'pangsit', orElse: () => const Topping(id: 'pangsit', name: 'Pangsit', price: 1500, stock: 10000));
                                      // Override price for the Order Record
                    finalToppings.add(pangsitParams.copyWith(price: 1500, name: 'Pangsit (Default)'));
                 }
                
                // Add Extra Toppings
                _selectedToppings.forEach((id, qty) {
                    final t = allToppings.firstWhere((element) => element.id == id);
                    // Add X copies or 1 copy with qty? 
                    // Topping struct doesn't have Qty. OrderItem has Qty.
                    // But here we can have multiple DIFFERENT toppings.
                    // If I have 2 Bakso, 1 Sosis.
                    // Topping structure needs to handle Qty? 
                    // The `Topping` model in `topping.dart` only has `stock` and `price`. It doesn't have `qty` (user selected qty).
                    // Wait, `OrderItem.toppings` is `List<Topping>`.
                    // If I select 2 Bakso, should I add [Bakso, Bakso]? Yes, that's one way.
                    
                    for(int i=0; i<qty; i++) {
                      finalToppings.add(t);
                    }
                });

                try {
                  ref.read(cartProvider.notifier).addItem(
                    widget.product,
                    _qty,
                    level: _level.toInt().toString(),
                    sambal: _sambal,
                    note: _noteController.text.isNotEmpty ? _noteController.text : null,
                    toppings: finalToppings.isNotEmpty ? finalToppings : null,
                  );
                  Navigator.pop(context);
                } catch (e) {
                   ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                   );
                }
              },
              child: const Text('SUBMIT'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTotalSection(List<Topping> allToppings) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(
            'Rp ${_calculateTotal(allToppings).toStringAsFixed(0)}', 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)
          ),
        ],
      ),
    );
  }
}
