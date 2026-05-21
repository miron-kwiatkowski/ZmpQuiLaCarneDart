import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    return Scaffold(
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
            stream: context.read<TablesCubit>().stream.map((_) => false), // TODO: podłączyć ApiClient.isConnected
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
                  if (state.tables.isEmpty) {
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
                    itemCount: state.tables.length,
                    itemBuilder: (context, index) {
                      final table = state.tables[index];
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
      // Nasłuchiwanie na zdarzenia z Cubit
      blocListener: BlocListener<TablesCubit, TablesState>(
        listener: (context, state) {
          if (state is TableStatusUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Zmieniono status stolika ${state.tableToken} na ${state.newStatus}'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: const SizedBox.shrink(),
      ),
    );
  }

  /// Pasek filtrów
  Widget _buildFilterBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const SizedBox(width: 16),
            _FilterChip(label: 'Wszystkie', value: null),
            const SizedBox(width: 8),
            _FilterChip(label: 'Wolne', value: 'available'),
            const SizedBox(width: 8),
            _FilterChip(label: 'Zajęte', value: 'occupied'),
            const SizedBox(width: 8),
            _FilterChip(label: 'Rezerwacje', value: 'reserved'),
            const SizedBox(width: 8),
            _FilterChip(label: 'Do sprzątania', value: 'cleaning'),
            const SizedBox(width: 8),
            _FilterChip(label: 'Uszkodzone', value: 'out_of_service'),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}

/// Widget filtra
class _FilterChip extends StatelessWidget {
  final String label;
  final String? value;

  const _FilterChip({required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TablesCubit>();
    
    return FilterChip(
      label: Text(label),
      onSelected: (_) => cubit.filterTables(value),
      selected: false, // TODO: porównać z aktualnym filtrem w stanie
    );
  }
}

/// Karta pojedynczego stolika
class _TableCard extends StatelessWidget {
  final dynamic table; // TableEntity

  const _TableCard({required this.table});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    
    switch (table.statusToken) {
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
      color: statusColor.withOpacity(0.1),
      child: InkWell(
        onTap: () => _showTableDetails(context),
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
    switch (statusToken) {
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

  void _showTableDetails(BuildContext context) {
    // TODO: Nawigacja do szczegółów stolika
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
            const SizedBox(height: 16),
            // TODO: Dodaj akcje dla stolika
          ],
        ),
      ),
    );
  }
}
