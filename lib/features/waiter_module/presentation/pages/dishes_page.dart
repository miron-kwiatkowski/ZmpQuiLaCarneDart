import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/dishes/dishes_cubit.dart';
import '../../domain/entities/dish_entity.dart';

/// Strona z listą dań
/// QlC12: Kelner widzi listę dań z detalami (skład, alergeny, powody niedostępności)
class DishesPage extends StatefulWidget {
  const DishesPage({super.key});

  @override
  State<DishesPage> createState() => _DishesPageState();
}

class _DishesPageState extends State<DishesPage> {
  String? _selectedCategory;
  bool _showOnlyAvailable = false;
  List<String> _excludedAllergens = [];

  @override
  void initState() {
    super.initState();
    context.read<DishesCubit>().loadDishes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista Dań'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: BlocBuilder<DishesCubit, DishesState>(
        builder: (context, state) {
          if (state is DishesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DishesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Błąd: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<DishesCubit>().loadDishes();
                    },
                    child: const Text('Spróbuj ponownie'),
                  ),
                ],
              ),
            );
          }

          if (state is DishesLoaded) {
            var dishes = state.dishes;

            // Filtruj po kategorii
            if (_selectedCategory != null) {
              dishes = dishes.where((d) => d.categoryToken == _selectedCategory).toList();
            }

            // Filtruj dostępność
            if (_showOnlyAvailable) {
              dishes = dishes.where((d) => d.isAvailable).toList();
            }

            // Filtruj alergeny
            if (_excludedAllergens.isNotEmpty) {
              dishes = dishes.where((d) {
                return !d.allergenTokens.any((a) => _excludedAllergens.contains(a));
              }).toList();
            }

            if (dishes.isEmpty) {
              return const Center(
                child: Text('Brak dań spełniających kryteria'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: dishes.length,
              itemBuilder: (context, index) {
                final dish = dishes[index];
                return DishCard(dish: dish);
              },
            );
          }

          return const Center(child: Text('Nieoczekiwany stan'));
        },
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filtry', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Tylko dostępne'),
              subtitle: const Text('Ukryj dania niedostępne'),
              value: _showOnlyAvailable,
              onChanged: (value) {
                setState(() => _showOnlyAvailable = value);
                Navigator.pop(context);
                context.read<DishesCubit>().loadDishes(
                  excludedAllergens: _excludedAllergens.isEmpty ? null : _excludedAllergens,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Karta pojedynczego dania
class DishCard extends StatelessWidget {
  final DishEntity dish;

  const DishCard({super.key, required this.dish});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: dish.isAvailable ? Colors.green : Colors.red,
          child: const Icon(Icons.restaurant, color: Colors.white),
        ),
        title: Text(
          dish.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: dish.isAvailable ? null : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Text('${dish.price.toStringAsFixed(2)} PLN'),
        trailing: dish.isAvailable
            ? null
            : Tooltip(
                message: dish.unavailabilityReason ?? 'Niedostępne',
                child: const Icon(Icons.info_outline, color: Colors.orange),
              ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...[
                Text(
                  dish.description,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 8),
              ],
                const Text('Składniki:', style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: dish.ingredientTokens
                      .map((ing) => Chip(
                            label: Text(ing, style: const TextStyle(fontSize: 12)),
                            backgroundColor: Colors.blue[50],
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),
                const Text('Alergeny:', style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: dish.allergenTokens
                      .map((allergen) => Chip(
                            label: Text(allergen, style: const TextStyle(fontSize: 12, color: Colors.white)),
                            backgroundColor: Colors.red[400],
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
