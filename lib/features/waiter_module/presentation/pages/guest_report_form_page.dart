import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/reports/reports_cubit_export.dart';

/// Strona formularza zgłoszenia gościa
/// QlC14: Kelner może zgłaszać gości (działa offline/online)
class GuestReportFormPage extends StatefulWidget {
  final String? clientToken; // Opcjonalny token klienta

  const GuestReportFormPage({super.key, this.clientToken});

  @override
  State<GuestReportFormPage> createState() => _GuestReportFormPageState();
}

class _GuestReportFormPageState extends State<GuestReportFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zgłoś Gościa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Powód zgłoszenia',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  hintText: 'Opisz sytuację (min. 10 znaków)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.warning_amber_rounded),
                ),
                minLines: 3,
                maxLines: 5,
                maxLength: 500,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Wymagany powód zgłoszenia';
                  }
                  if (value.trim().length < 10) {
                    return 'Powód musi mieć minimum 10 znaków';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              if (_isSubmitting)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text('Wyślij Zgłoszenie'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _submitReport,
                ),
              
              const SizedBox(height: 16),
              
              BlocListener<ReportsCubit, ReportsState>(
                listener: (context, state) {
                  if (state is ReportCreated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Zgłoszenie wysłane pomyślnie!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context, true);
                  } else if (state is ReportsError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Błąd: ${state.failure.message}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.clientToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Brak wybranego klienta do zgłoszenia'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await context.read<ReportsCubit>().createReport(
        clientToken: widget.clientToken!,
        reason: _reasonController.text.trim(),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
