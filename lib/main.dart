import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MeusPagamentosApp());
}

class MeusPagamentosApp extends StatelessWidget {
  const MeusPagamentosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meus Pagamentos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blueAccent,
        brightness: Brightness.light,
      ),
      home: const HomeScreen(),
    );
  }
}

enum PaymentStatus { paid, pending, overdue }

class BillItem {
  final String id;
  final String title;
  final double amount;
  final DateTime dueDate;
  bool isPaid;

  BillItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    this.isPaid = false,
  });

  PaymentStatus get status {
    if (isPaid) return PaymentStatus.paid;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);

    if (due.isBefore(today)) {
      return PaymentStatus.overdue;
    }
    return PaymentStatus.pending;
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<BillItem> _bills = [
    BillItem(
      id: '1',
      title: 'Internet Fibra',
      amount: 119.90,
      dueDate: DateTime.now().subtract(const Duration(days: 2)),
      isPaid: false,
    ),
    BillItem(
      id: '2',
      title: 'Condomínio',
      amount: 450.00,
      dueDate: DateTime.now().add(const Duration(days: 3)),
      isPaid: false,
    ),
    BillItem(
      id: '3',
      title: 'Energia Elétrica',
      amount: 185.30,
      dueDate: DateTime.now().subtract(const Duration(days: 5)),
      isPaid: true,
    ),
    BillItem(
      id: '4',
      title: 'Fatura do Cartão',
      amount: 1240.50,
      dueDate: DateTime.now(),
      isPaid: false,
    ),
  ];

  final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final dateFormatter = DateFormat('dd/MM/yyyy');

  double get _totalOverdue => _bills
      .where((b) => b.status == PaymentStatus.overdue)
      .fold(0, (sum, item) => sum + item.amount);

  double get _totalPending => _bills
      .where((b) => b.status == PaymentStatus.pending)
      .fold(0, (sum, item) => sum + item.amount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Meus Pagamentos', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSummaryCards(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Suas Contas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_bills.length} itens',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: _bills.length,
              itemBuilder: (context, index) {
                final bill = _bills[index];
                return _buildBillCard(bill);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewBillDialog,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova Conta'),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: _summaryTile(
              title: 'Atrasados',
              amount: _totalOverdue,
              color: Colors.red.shade700,
              bgColor: Colors.red.shade50,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _summaryTile(
              title: 'A Vencer',
              amount: _totalPending,
              color: Colors.amber.shade800,
              bgColor: Colors.amber.shade50,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryTile({
    required String title,
    required double amount,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            currencyFormatter.format(amount),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildBillCard(BillItem bill) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (bill.status) {
      case PaymentStatus.paid:
        statusColor = const Color(0xFF2E7D32);
        statusText = 'Pago';
        statusIcon = Icons.check_circle_rounded;
        break;
      case PaymentStatus.overdue:
        statusColor = const Color(0xFFD32F2F);
        statusText = 'Atrasado';
        statusIcon = Icons.warning_amber_rounded;
        break;
      case PaymentStatus.pending:
        statusColor = const Color(0xFFF57C00);
        statusText = 'A Vencer';
        statusIcon = Icons.schedule_rounded;
        break;
    }

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: statusColor, width: 6)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            bill.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text('Vencimento: ${dateFormatter.format(bill.dueDate)}'),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(statusIcon, size: 14, color: statusColor),
                  const SizedBox(width: 4),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currencyFormatter.format(bill.amount),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: () {
                  setState(() {
                    bill.isPaid = !bill.isPaid;
                  });
                },
                child: Text(
                  bill.isPaid ? 'Desfazer' : 'Marcar Pago',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addNewBillDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: Column(
mainAxisSize: MainAxisSize.min,
            
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cadastrar Nova Conta',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Conta (ex: Aluguel)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Valor (R\$)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty && amountController.text.isNotEmpty) {
                    setState(() {
                      _bills.add(
                        BillItem(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: titleController.text,
                          amount: double.tryParse(amountController.text) ?? 0.0,
                          dueDate: DateTime.now().add(const Duration(days: 5)),
                        ),
                      );
                    });
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Salvar Conta'),
              ),
            ],
          ),
        );
      },
    );
  }
}
