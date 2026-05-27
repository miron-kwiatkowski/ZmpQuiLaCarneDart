import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/dish_entity.dart';
import '../../domain/entities/reservation_entity.dart';
import '../../domain/repositories/waiter_repository.dart';
import '../cubits/orders/orders_cubit_export.dart';

/// Strona szczegółów rezerwacji z możliwością edycji zamówienia
/// QlC10: Kelner może aktywować rezerwację, domówić produkty, dodawać notatki
/// QlC13: Kelner może edytować aktywne zamówienie
class ReservationDetailPage extends StatefulWidget {
  final String reservationToken;
  final OrderEntity? order;

  const ReservationDetailPage({
    super.key,
    required this.reservationToken,
    this.order,
  });

  @override
  State<ReservationDetailPage> createState() => _ReservationDetailPageState();
}

class _ReservationDetailPageState extends State<ReservationDetailPage> {
  @override
  void initState() {
    super.initState();
    if (widget.order == null) {
      context.read<OrdersCubit>().loadReservationDetails(widget.reservationToken);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Szczegóły Rezerwacji'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_shopping_cart),
            onPressed: () => _showAddItemsDialog(),
            tooltip: 'Dodaj dania',
          ),
        ],
      ),
      body: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          if (state is OrdersLoading || state is OrdersSubmitting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is OrdersError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Błąd: ${state.failure.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<OrdersCubit>().loadReservationDetails(widget.reservationToken),
                    child: const Text('Spróbuj ponownie'),
                  ),
                ],
              ),
            );
          }
          if (state is OrdersLoaded) {
            return _buildOrderContentFromReservation(state.reservation);
          }
          
          // Fallback if widget.order was provided but state is Initial
          if (widget.order != null) {
             return _buildOrderContent(widget.order!);
          }

          return const Center(child: Text('Brak danych'));
        },
      ),
    );
  }

  Widget _buildOrderContentFromReservation(ReservationEntity reservation) {
    return Column(
      children: [
        // Nagłówek z informacjami o rezerwacji
        Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rezerwacja: ${reservation.token}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    _buildStatusChip(reservation.statusToken),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Stolik: ${reservation.tableToken}'),
                Text('Goście: ${reservation.guestCount}'),
                Text('Suma: ${reservation.totalPrice.toStringAsFixed(2)} PLN'),
                if (reservation.notes != null) ...[
                  const SizedBox(height: 8),
                  Text('Notatki: ${reservation.notes}', style: const TextStyle(fontStyle: FontStyle.italic)),
                ],
              ],
            ),
          ),
        ),

        // Lista pozycji zamówienia
        Expanded(
          child: reservation.orderItems.isEmpty
              ? const Center(child: Text('Brak pozycji w zamówieniu'))
              : ListView.builder(
                  itemCount: reservation.orderItems.length,
                  itemBuilder: (context, index) {
                    final item = reservation.orderItems[index];
                    return OrderItemTile(
                      item: item,
                      onRemove: () => _confirmRemoveItem(item),
                      onEditNote: () => _editItemNote(item),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildOrderContent(OrderEntity order) {
    return Column(
      children: [
        // Nagłówek z informacjami o rezerwacji
        Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rezerwacja: ${widget.reservationToken}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatusChip(order.statusToken),
                    const SizedBox(width: 8),
                    Text('Suma: ${order.totalAmount.toStringAsFixed(2)} PLN'),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Lista pozycji zamówienia
        Expanded(
          child: ListView.builder(
            itemCount: order.items.length,
            itemBuilder: (context, index) {
              final item = order.items[index];
              return OrderItemTile(
                item: item,
                onRemove: () => _confirmRemoveItem(item),
                onEditNote: () => _editItemNote(item),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String statusToken) {
    Color color;
    switch (statusToken.toUpperCase()) {
      case 'PENDING':
      case 'ACTIVE':
        color = Colors.orange;
        break;
      case 'IN_PROGRESS':
        color = Colors.blue;
        break;
      case 'COMPLETED':
        color = Colors.green;
        break;
      case 'CANCELLED':
      case 'NO_SHOW':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        statusToken,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
    );
  }

  void _showAddItemsDialog() {
    Navigator.pushNamed(context, '/dishes').then((result) {
      if (result is List<DishEntity>) {
        // Dodaj wybrane dania do zamówienia
        context.read<OrdersCubit>().addItems(
          reservationToken: widget.reservationToken,
          items: result.map((dish) => OrderItemToAdd(
            dishToken: dish.token,
            quantity: 1,
            note: null,
          )).toList(),
        );
      }
    });
  }

  void _confirmRemoveItem(OrderItemEntity item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usuń pozycję'),
        content: Text('Czy na pewno usunąć "${item.dishName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<OrdersCubit>().removeItem(
                reservationToken: widget.reservationToken,
                dishToken: item.dishToken,
                quantity: item.quantity,
                note: item.note,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Usuń'),
          ),
        ],
      ),
    );
  }

  void _editItemNote(OrderItemEntity item) {
    final noteController = TextEditingController(text: item.note ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edytuj notatkę'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            hintText: 'Np. bez cebuli, extra sos...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Zaktualizuj notatkę w zamówieniu
              Navigator.pop(context);
            },
            child: const Text('Zapisz'),
          ),
        ],
      ),
    );
  }
}

/// Widget pojedynczej pozycji zamówienia
class OrderItemTile extends StatelessWidget {
  final OrderItemEntity item;
  final VoidCallback? onRemove;
  final VoidCallback? onEditNote;

  const OrderItemTile({
    super.key,
    required this.item,
    this.onRemove,
    this.onEditNote,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text('${item.quantity}'),
      ),
      title: Text(item.dishName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${item.unitPrice.toStringAsFixed(2)} PLN x ${item.quantity}'),
          if (item.note != null && item.note!.isNotEmpty)
            Text(
              '📝 ${item.note}',
              style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${item.totalPrice.toStringAsFixed(2)} PLN',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.edit_note, size: 20),
            onPressed: onEditNote,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
