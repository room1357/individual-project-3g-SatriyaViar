import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:pemrograman_mobile/models/category_manager.dart';
import 'package:pemrograman_mobile/models/expense.dart';
import 'package:pemrograman_mobile/models/expense_manager.dart';
import 'package:pemrograman_mobile/models/income_manager.dart';
import 'package:pemrograman_mobile/screens/advanced_expense_list_screen.dart';
import 'package:pemrograman_mobile/screens/category_screen.dart';
import 'package:pemrograman_mobile/screens/statistik_screen.dart';
import 'login_screen.dart';
import 'expense_list_screen.dart';
import 'profile_screen.dart';
import 'message_screen.dart';
import 'setting_screen.dart';
import 'shared_expenses_screen.dart';
import '../Services/auth_services.dart';
import '../utils/formater.dart';
import '../models/user.dart';

class HomeScreen extends StatefulWidget {
  final UserAccount? user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedPeriod = 'Month';
  int _currentIndex = 2; // Start at home (center)
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: _currentIndex == 2 ? _buildHomeAppBar() : null,
      body: _getBody(),
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: _currentIndex,
        height: 60.0,
        items: const <Widget>[
          Icon(Icons.message_outlined, size: 28, color: Colors.white),
          Icon(Icons.category_outlined, size: 28, color: Colors.white),
          Icon(Icons.home, size: 32, color: Colors.white),
          Icon(Icons.bar_chart_outlined, size: 28, color: Colors.white),
          Icon(Icons.person_outline, size: 28, color: Colors.white),
        ],
        color: const Color(0xFF5B8DEE),
        buttonBackgroundColor: const Color(0xFF4A7DE8),
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOutCubic,
        animationDuration: const Duration(milliseconds: 400),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  PreferredSizeWidget _buildHomeAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          const Icon(Icons.menu, color: Colors.black87),
          const SizedBox(width: 12),
          const Text(
            'Main Account',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.black54,
            size: 20,
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.black87),
          onPressed: () async {
            final auth = AuthService();
            await auth.signOut(); // Logout, hapus session

            if (!context.mounted) return; // Pastikan context masih aktif

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          },
        ),
      ],
    );
  }

  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return const MessageScreen();
      case 1:
        return CategoryScreen();
      case 2:
        return _buildHomeDashboard();
      case 3:
        return StatisticsScreen(
          expenses: [
            ...ExpenseManager.getAllExpenses(),
            ...AuthService().sharedExpenses.map(
              (s) => Expense(
                id: s.date.millisecondsSinceEpoch.toString(),
                title: s.title,
                amount: s.amount,
                category: 'Pengeluaran Bersama',
                description: 'Dibuat oleh ${s.createdBy}',
                date: s.date,
              ),
            ),
          ],
          categories: CategoryManager.getAllCategories(),
        );
      case 4:
        return const ProfileScreen();
      default:
        return _buildHomeDashboard();
    }
  }

  Widget _buildHomeDashboard() {
    return FutureBuilder(
      future: _loadDashboardData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;
        final totalIncome = data['income']!;
        final totalExpense = data['expense']!;
        final totalBalance = totalIncome - totalExpense;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAccountBalanceCard(totalBalance, totalIncome, totalExpense),
              const SizedBox(height: 20),
              _buildChartSection(),
              const SizedBox(height: 20),
              _buildCashFlowSection(totalIncome, totalExpense),
              const SizedBox(height: 20),
              _buildQuickAccessSection(context),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, double>> _loadDashboardData() async {
    final auth = AuthService();
    await auth.loadData(); // pastikan data user & shared expenses terload

    final totalIncome = IncomeManager.calculateTotal(IncomeManager.incomes);
    final personalExpense = ExpenseManager.calculateTotal(
      ExpenseManager.expenses,
    );

    // 🔹 Tambahkan shared expense dari AuthService
    final sharedExpenseTotal = auth.sharedExpenses.fold<double>(
      0,
      (sum, e) => sum + e.amount,
    );

    final totalExpense = personalExpense + sharedExpenseTotal;

    return {'income': totalIncome, 'expense': totalExpense};
  }

  Widget _buildAccountBalanceCard(
    double balance,
    double income,
    double expense,
  ) {
    final thisMonthChange = income - expense;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF5B8DEE), Color(0xFF4A7DE8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B8DEE).withAlpha(200),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Account balance',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(90),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'This Month',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            formatRupiah(balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                formatRupiah(balance),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                thisMonthChange >= 0
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                color: Colors.white,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white24, thickness: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSubAccountItem(
                  'Income',
                  formatRupiah(balance),
                  '+${formatRupiah(balance)}',
                ),
              ),
              Container(width: 1, height: 40, color: Colors.white24),
              Expanded(
                child: _buildSubAccountItem(
                  'Expense',
                  formatRupiah(expense),
                  '- ${formatRupiah(expense)}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubAccountItem(String title, String amount, String change) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Flexible(
                child: Text(
                  amount,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return FutureBuilder<List<Expense>>(
      future: _loadCombinedExpenses(), // Fungsi gabungan data
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Gagal memuat data'));
        }

        final allExpenses = snapshot.data ?? [];
        final total = allExpenses.fold<double>(0, (sum, e) => sum + e.amount);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header tanggal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Icon(Icons.arrow_back_ios, size: 16, color: Colors.black54),
                  Text(
                    'Feb 01 - 28, 2023',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.black54,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Total semua expense
              Text(
                formatRupiah(total),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B6B),
                ),
              ),

              const SizedBox(height: 20),

              // Chart pengeluaran
              SizedBox(
                height: 150,
                child: CustomPaint(
                  painter: ChartPainter(expenses: allExpenses),
                  child: Container(),
                ),
              ),

              const SizedBox(height: 16),

              // Tombol periode
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPeriodButton('Week'),
                  _buildPeriodButton('Month'),
                  _buildPeriodButton('Year'),
                  _buildPeriodButton('All'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<List<Expense>> _loadCombinedExpenses() async {
    // Ambil semua data pribadi dari ExpenseManager
    final personal = ExpenseManager.expenses;

    // Ambil shared expense dari AuthService (user aktif)
    final auth = AuthService();
    await auth.loadData();

    final shared =
        auth.sharedExpenses.map((s) {
          return Expense(
            id: s.date.millisecondsSinceEpoch.toString(),
            title: s.title,
            amount: s.amount,
            category: 'Pengeluaran Bersama',
            description:
                'Dibuat oleh ${s.createdBy} • Anggota: ${s.members.join(', ')}',
            date: s.date,
          );
        }).toList();

    // Gabungkan keduanya (pribadi + bersama)
    return [...personal, ...shared];
  }

  Widget _buildPeriodButton(String period) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = period),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5B8DEE) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          period,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCashFlowSection(double income, double expense) {
    final total = income - expense;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cash Flow',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Icon(Icons.more_vert, color: Colors.black54),
            ],
          ),
          const Text(
            'This Month',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 20),
          _buildCashFlowItem(
            'Income',
            (income),
            const Color(0xFF4CAF50),
            Icons.arrow_downward,
          ),
          const SizedBox(height: 12),
          _buildCashFlowItem(
            'Expenses',
            expense,
            const Color(0xFFFF6B6B),
            Icons.arrow_upward,
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${total >= 0 ? '+' : '-'}${formatRupiah(total.abs())}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color:
                      total >= 0
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFFF6B6B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCashFlowItem(
    String label,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
        Text(
          formatRupiah(amount),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Access',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [
            _buildQuickAccessCard(
              context,
              'Pengeluaran',
              Icons.money_off,
              const Color(0xFFFF6B6B),
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExpenseListScreen()),
              ),
            ),
            _buildQuickAccessCard(
              context,
              'Kategori',
              Icons.category,
              const Color(0xFFFF9800),
              () {
                setState(() => _currentIndex = 1);
                _bottomNavigationKey.currentState?.setPage(1);
              },
            ),
            _buildQuickAccessCard(
              context,
              'Statistik',
              Icons.bar_chart,
              const Color(0xFF9C27B0),
              () {
                setState(() => _currentIndex = 3);
                _bottomNavigationKey.currentState?.setPage(3);
              },
            ),
            _buildQuickAccessCard(
              context,
              'Advanced',
              Icons.attach_money,
              const Color(0xFF4CAF50),
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdvancedExpenseListScreen(),
                ),
              ),
            ),
            _buildQuickAccessCard(
              context,
              'Shared Expense',
              Icons.group,
              const Color(0xFF5B8DEE),
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            SharedExpensesScreen(currentUser: widget.user!),
                  ),
                );
              },
            ),

            _buildQuickAccessCard(
              context,
              'Profil',
              Icons.person,
              const Color(0xFF5B8DEE),
              () {
                setState(() => _currentIndex = 4);
                _bottomNavigationKey.currentState?.setPage(4);
              },
            ),
            _buildQuickAccessCard(
              context,
              'Pesan',
              Icons.message,
              const Color(0xFFFF9800),
              () {
                setState(() => _currentIndex = 0);
                _bottomNavigationKey.currentState?.setPage(0);
              },
            ),
            _buildQuickAccessCard(
              context,
              'Pengaturan',
              Icons.settings,
              const Color(0xFF607D8B),
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(100),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(100),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  final List<Expense> expenses;

  ChartPainter({required this.expenses});

  @override
  void paint(Canvas canvas, Size size) {
    if (expenses.isEmpty) return;

    // Urutkan berdasarkan tanggal
    expenses.sort((a, b) => a.date.compareTo(b.date));

    final maxAmount = expenses
        .map((e) => e.amount)
        .reduce((a, b) => a > b ? a : b);
    final path = Path();

    // Skala sumbu X & Y
    for (int i = 0; i < expenses.length; i++) {
      final x = (i / (expenses.length - 1)) * size.width;
      final y = size.height - (expenses[i].amount / maxAmount) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Warna garis
    final linePaint =
        Paint()
          ..color = const Color(0xFF5B8DEE)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    // Warna area bawah
    final fillPaint =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF5B8DEE).withAlpha(100),
              const Color(0xFF5B8DEE).withAlpha(400),
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
          ..style = PaintingStyle.fill;

    // Isi area bawah
    final fillPath =
        Path.from(path)
          ..lineTo(size.width, size.height)
          ..lineTo(0, size.height)
          ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // Titik-titik kecil di tiap data
    final dotPaint =
        Paint()
          ..color = const Color(0xFF5B8DEE)
          ..style = PaintingStyle.fill;

    for (int i = 0; i < expenses.length; i++) {
      final x = (i / (expenses.length - 1)) * size.width;
      final y = size.height - (expenses[i].amount / maxAmount) * size.height;
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ChartPainter oldDelegate) {
    return oldDelegate.expenses != expenses;
  }
}
