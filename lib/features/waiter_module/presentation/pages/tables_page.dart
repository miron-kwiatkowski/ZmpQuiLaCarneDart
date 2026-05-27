import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quilacarne_waiter/core/di/injection_container.dart';
import 'package:quilacarne_waiter/core/network/api_client.dart';
import 'package:quilacarne_waiter/features/waiter_module/domain/entities/table_entity.dart';
import '../cubits/tables/tables_cubit_export.dart';

/// Strona główna kelnera - lista stolików
/// 
/// Wzorzec: Page Pattern + BlocBuilder/BlocListener
/// Dlaczego: Separacja logiki UI od logiki biznesowej,
/// reaktywne aktualizacje stanu na podstawie Cubit
class TablesPage extends StatelessWidget {
  const TablesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<TablesCubit, TablesState>(
      listener: (context, state) {
        if (state is TableStatusUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Zmieniono status stolika ${state.tableToken} na ${state.newStatus}'),
              backgroundColor: Colors.green,
            ),
          );
        }
        if (state is TablesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Błąd: ${state.failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Stoliki'),
          actions: [
            // Przycisk odświeżania
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<TablesCubit>().refresh();
              },
            ),
            
            // Przełącznik trybu offline/online
            StreamBuilder<bool>(
              stream: sl<ApiClient>().onConnectivityChanged,
              initialData: true,
              builder: (context, snapshot) {
                final isConnected = snapshot.data ?? true;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isConnected ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isConnected ? Icons.wifi : Icons.wifi_off,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isConnected ? 'Online' : 'Offline',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            // Filtry statusów stolików
            _buildFilterBar(context),
            
            // Lista stolików
            Expanded(
              child: BlocBuilder<TablesCubit, TablesState>(
                builder: (context, state) {
                  if (state is TablesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (state is TablesError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                          const SizedBox(height: 16),
                          Text(
                            'Błąd: ${state.failure.message}',
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<TablesCubit>().refresh();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Odśwież'),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  if (state is TablesLoaded) {
                    var tables = state.tables;
                    
                    // Aplikuj filtrowanie w UI jeśli Cubit sam tego nie robi w streamie
                    if (state.filter != null) {
                      final filter = state.filter!.toUpperCase();
                      tables = tables.where((t) => t.statusToken.toUpperCase() == filter).toList();
                    }

                    if (tables.isEmpty) {
                      return const Center(
                        child: Text('Brak stolików do wyświetlenia'),
                      );
                    }
                    
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: tables.length,
                      itemBuilder: (context, index) {
                        final table = tables[index];
                        return _TableCard(table: table);
                      },
                    );
                  }
                  
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Pasek filtrów
  Widget _buildFilterBar(BuildContext context) {
    return BlocBuilder<TablesCubit, TablesState>(
      builder: (context, state) {
        final currentFilter = state is TablesLoaded ? state.filter : null;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const SizedBox(width: 16),
                _FilterChip(label: 'Wszystkie', value: null, isSelected: currentFilter == null),
                const SizedBox(width: 8),
                _FilterChip(label: 'Wolne', value: 'available', isSelected: currentFilter?.toLowerCase() == 'available'),
                const SizedBox(width: 8),
                _FilterChip(label: 'Zajęte', value: 'occupied', isSelected: currentFilter?.toLowerCase() == 'occupied'),
                const SizedBox(width: 8),
                _FilterChip(label: 'Rezerwacje', value: 'reserved', isSelected: currentFilter?.toLowerCase() == 'reserved'),
                const SizedBox(width: 8),
                _FilterChip(label: 'Do sprzątania', value: 'cleaning', isSelected: currentFilter?.toLowerCase() == 'cleaning'),
                const SizedBox(width: 8),
                _FilterChip(label: 'Uszkodzone', value: 'out_of_service', isSelected: currentFilter?.toLowerCase() == 'out_of_service'),
                const SizedBox(width: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Widget filtra
class _FilterChip extends StatelessWidget {
  final String label;
  final String? value;
  final bool isSelected;

  const _FilterChip({required this.label, this.value, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TablesCubit>();
    
    return FilterChip(
      label: Text(label),
      onSelected: (_) => cubit.filterTables(value),
      selected: isSelected,
    );
  }
}

/// Karta pojedynczego stolika
class _TableCard extends StatelessWidget {
  final TableEntity table;

  const _TableCard({required this.table});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    
    switch (table.statusToken.toUpperCase()) {
      case 'AVAILABLE':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'OCCUPIED':
        statusColor = Colors.red;
        statusIcon = Icons.people;
        break;
      case 'RESERVED':
        statusColor = Colors.orange;
        statusIcon = Icons.event;
        break;
      case 'CLEANING':
        statusColor = Colors.blue;
        statusIcon = Icons.cleaning_services;
        break;
      case 'OUT_OF_SERVICE':
        statusColor = Colors.grey;
        statusIcon = Icons.build;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Card(
      color: statusColor.withValues(alpha: 0.1),
      child: InkWell(
        onTap: () => _handleTableTap(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(statusIcon, size: 48, color: statusColor),
              const SizedBox(height: 8),
              Text(
                'Stolik ${table.tableNumber}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              if (table.seats != null)
                Text(
                  '${table.seats} miejsc',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusName(table.statusToken),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusName(String statusToken) {
    switch (statusToken.toUpperCase()) {
      case 'AVAILABLE':
        return 'Wolny';
      case 'OCCUPIED':
        return 'Zajęty';
      case 'RESERVED':
        return 'Zarezerwowany';
      case 'CLEANING':
        return 'Do sprzątania';
      case 'OUT_OF_SERVICE':
        return 'Uszkodzony';
      default:
        return statusToken;
    }
  }

  void _handleTableTap(BuildContext context) {
     _showTableDetails(context);
  }

  void _showTableDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stolik ${table.tableNumber}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('Status: ${_getStatusName(table.statusToken)}'),
            if (table.seats != null) Text('Miejsca: ${table.seats}'),
            const SizedBox(height: 24),
            
            if (table.isReserved || table.isOccupied)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: W prawdziwej aplikacji potrzebujemy tokenu rezerwacji
                    // Na potrzeby demo/naprawy nawigacji:
                    Navigator.pushNamed(
                      context, 
                      '/reservation_detail',
                      arguments: {'token': 'DEMO-TOKEN-123'} 
                    );
                  },
                  child: const Text('Szczegóły rezerwacji'),
                ),
              ),
              
            if (table.isAvailable)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Otwórz listę dań aby zacząć nowe zamówienie
                    Navigator.pushNamed(context, '/dishes');
                  },
                  child: const Text('Otwórz zamówienie'),
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                   // Logic to change status (e.g., to CLEANING or OUT_OF_SERVICE)
                  Navigator.pop(context);
                  context.read<TablesCubit>().changeTableStatus(
                    tableToken: table.token, 
                    newStatus: table.requiresCleaning ? 'AVAILABLE' : 'CLEANING'
                  );
                },
                child: Text(table.requiresCleaning ? 'Oznacz jako posprzątany' : 'Zmień status'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
