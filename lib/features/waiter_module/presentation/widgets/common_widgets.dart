import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Widget wskaźnika statusu połączenia
/// Wyświetla baner Online/Offline w aplikacji
class ConnectivityStatusWidget extends StatelessWidget {
  final Stream<List<ConnectivityResult>> connectivityStream;

  const ConnectivityStatusWidget({
    super.key,
    required this.connectivityStream,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: connectivityStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final connectivity = snapshot.data!;
        final isOnline = connectivity.any(
          (result) => result != ConnectivityResult.none,
        );

        if (isOnline) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: Colors.orange,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Tryb Offline - dane będą zsynchronizowane po odzyskaniu połączenia',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Widget kafelka stolika
class TableCard extends StatelessWidget {
  final String name;
  final String status;
  final int? tableNumber;
  final bool isAvailable;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TableCard({
    super.key,
    required this.name,
    required this.status,
    this.tableNumber,
    required this.isAvailable,
    this.onTap,
    this.onLongPress,
  });

  Color _getStatusColor() {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
        return Colors.green;
      case 'OCCUPIED':
        return Colors.red;
      case 'RESERVED':
        return Colors.orange;
      case 'CLEANING':
        return Colors.blue;
      case 'OUT_OF_SERVICE':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
        return Icons.check_circle;
      case 'OCCUPIED':
        return Icons.people;
      case 'RESERVED':
        return Icons.event;
      case 'CLEANING':
        return Icons.cleaning_services;
      case 'OUT_OF_SERVICE':
        return Icons.build;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getStatusColor(),
              width: 3,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: _getStatusColor().withValues(alpha: 0.2),
                child: Icon(
                  _getStatusIcon(),
                  size: 36,
                  color: _getStatusColor(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                tableNumber != null ? 'Stolik #$tableNumber' : name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _translateStatus(status),
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

  String _translateStatus(String status) {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
        return 'Wolny';
      case 'OCCUPIED':
        return 'Zajęty';
      case 'RESERVED':
        return 'Zarezerwowany';
      case 'CLEANING':
        return 'Do sprzątania';
      case 'OUT_OF_SERVICE':
        return 'Awaria';
      default:
        return status;
    }
  }
}

/// Widget odznaki statusu
class StatusBadge extends StatelessWidget {
  final String status;
  final bool small;

  const StatusBadge({
    super.key,
    required this.status,
    this.small = false,
  });

  Color _getColor() {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'IN_PROGRESS':
        return Colors.blue;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 12,
        vertical: small ? 4 : 8,
      ),
      decoration: BoxDecoration(
        color: _getColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _translateStatus(status),
        style: TextStyle(
          color: Colors.white,
          fontSize: small ? 10 : 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _translateStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Oczekujące';
      case 'IN_PROGRESS':
        return 'W trakcie';
      case 'COMPLETED':
        return 'Zakończone';
      case 'CANCELLED':
        return 'Anulowane';
      default:
        return status;
    }
  }
}
