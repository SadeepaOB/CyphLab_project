import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../services/firebase_service.dart';
import '../widgets/category_breakdown.dart';
import '../widgets/expense_summary_card.dart';
import '../widgets/expense_tile.dart';
import 'add_edit_expense_screen.dart';

/// Main screen of the Expense Tracker app.
///
/// Implements:
/// - Real-time stream of expenses from Firestore
/// - Three UI states: Loading, Empty, and Error (with retry)
/// - Monthly total card with month navigation
/// - Category filter & date range filter
/// - Search by title
/// - Category-wise spending breakdown
/// - Delete expense with confirmation dialog
class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  // Stream reference that can be recreated for a retry
  late Stream<List<Expense>> _expensesStream;

  // Filters & State
  String _selectedCategory = 'All';
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTimeRange? _customDateRange;
  String _searchQuery = '';
  bool _showBreakdown = false;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Initialize or refresh the real-time stream
  void _initStream() {
    setState(() {
      _expensesStream = _firebaseService.getExpensesStream();
    });
  }

  /// Navigate to previous month for the summary card
  void _goToPreviousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  /// Navigate to next month for the summary card
  void _goToNextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  /// Reset all filters to default
  void _resetFilters() {
    setState(() {
      _selectedCategory = 'All';
      _customDateRange = null;
      _searchQuery = '';
      _searchController.clear();
      _isSearching = false;
    });
  }

  /// Open date range picker
  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _customDateRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 30)),
            end: DateTime.now(),
          ),
    );

    if (picked != null) {
      setState(() {
        _customDateRange = picked;
      });
    }
  }

  /// Confirm and delete an expense
  Future<void> _confirmDelete(Expense expense) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense'),
        content: Text('Are you sure you want to delete "${expense.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      try {
        await _firebaseService.deleteExpense(expense.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Expense deleted successfully'),
              backgroundColor: Colors.black87,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete expense: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Filter the list of expenses according to active category, date range, and search
  List<Expense> _applyFilters(List<Expense> expenses) {
    return expenses.where((expense) {
      // 1. Category filter
      if (_selectedCategory != 'All' && expense.category != _selectedCategory) {
        return false;
      }

      // 2. Custom Date Range filter
      if (_customDateRange != null) {
        final expenseDate = DateTime(expense.date.year, expense.date.month, expense.date.day);
        final startDate = DateTime(_customDateRange!.start.year, _customDateRange!.start.month, _customDateRange!.start.day);
        final endDate = DateTime(_customDateRange!.end.year, _customDateRange!.end.month, _customDateRange!.end.day);

        if (expenseDate.isBefore(startDate) || expenseDate.isAfter(endDate)) {
          return false;
        }
      }

      // 3. Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final titleMatches = expense.title.toLowerCase().contains(query);
        final noteMatches = expense.note?.toLowerCase().contains(query) ?? false;
        if (!titleMatches && !noteMatches) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search expenses...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim();
                  });
                },
              )
            : const Text(
                'Expense Tracker',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
        actions: [
          // Search toggle button
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            tooltip: _isSearching ? 'Close Search' : 'Search',
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),

          // Breakdown chart toggle button
          IconButton(
            icon: Icon(_showBreakdown ? Icons.pie_chart : Icons.pie_chart_outline),
            tooltip: 'Toggle Category Breakdown',
            onPressed: () {
              setState(() {
                _showBreakdown = !_showBreakdown;
              });
            },
          ),

          // Dark mode toggle button
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: widget.isDarkMode ? 'Light Mode' : 'Dark Mode',
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: StreamBuilder<List<Expense>>(
        stream: _expensesStream,
        builder: (context, snapshot) {
          // ===================================================================
          // UI STATE 1: LOADING (Spinner)
          // ===================================================================
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading your expenses...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          // ===================================================================
          // UI STATE 2: ERROR (Message with Retry Option)
          // ===================================================================
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                    const SizedBox(height: 16),
                    const Text(
                      'Oops! Unable to load expenses.',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _initStream,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final allExpenses = snapshot.data ?? [];

          // Calculate current selected month's total
          final monthExpenses = allExpenses.where((e) {
            return e.date.year == _selectedMonth.year && e.date.month == _selectedMonth.month;
          }).toList();

          final monthTotal = monthExpenses.fold<double>(
            0.0,
            (sum, item) => sum + item.amount,
          );

          // Apply filters (Category, Date Range, Search)
          final filteredExpenses = _applyFilters(allExpenses);

          return RefreshIndicator(
            onRefresh: () async {
              _initStream();
            },
            child: CustomScrollView(
              slivers: [
                // Monthly Summary Card Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: ExpenseSummaryCard(
                      totalAmount: monthTotal,
                      count: monthExpenses.length,
                      selectedMonth: _selectedMonth,
                      onPreviousMonth: _goToPreviousMonth,
                      onNextMonth: _goToNextMonth,
                    ),
                  ),
                ),

                // Optional Category Breakdown Chart
                if (_showBreakdown)
                  SliverToBoxAdapter(
                    child: CategoryBreakdownWidget(expenses: filteredExpenses),
                  ),

                // Filters section (Category chips & Date filter)
                SliverToBoxAdapter(
                  child: _buildFilterSection(),
                ),

                // Filter status summary & Reset button
                if (_selectedCategory != 'All' || _customDateRange != null || _searchQuery.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Showing ${filteredExpenses.length} filtered results',
                              style: const TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                          ),
                          TextButton(
                            onPressed: _resetFilters,
                            child: const Text('Reset Filters'),
                          ),
                        ],
                      ),
                    ),
                  ),

                // =============================================================
                // UI STATE 3: EMPTY (Friendly "No expenses yet" message)
                // =============================================================
                if (filteredExpenses.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              allExpenses.isEmpty ? Icons.receipt_long_outlined : Icons.filter_alt_off,
                              size: 72,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              allExpenses.isEmpty
                                  ? 'No expenses recorded yet!'
                                  : 'No expenses match your filters.',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              allExpenses.isEmpty
                                  ? 'Tap the "+" button below to log your first expense.'
                                  : 'Try resetting the filters or searching with another keyword.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            if (allExpenses.isEmpty)
                              ElevatedButton.icon(
                                onPressed: () => _navigateToAddEdit(null),
                                icon: const Icon(Icons.add),
                                label: const Text('Add Expense'),
                              )
                            else
                              OutlinedButton.icon(
                                onPressed: _resetFilters,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Clear Filters'),
                              ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  // Expense History List (Most recent first)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final expense = filteredExpenses[index];
                        return ExpenseTile(
                          expense: expense,
                          onEdit: () => _navigateToAddEdit(expense),
                          onDelete: () => _confirmDelete(expense),
                        );
                      },
                      childCount: filteredExpenses.length,
                    ),
                  ),

                // Bottom padding for Floating Action Button
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddEdit(null),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }

  /// Builds category chips and date filter
  Widget _buildFilterSection() {
    final categories = ['All', ...ExpenseCategory.categories];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Chips Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              // Date Range Button
              ActionChip(
                avatar: Icon(
                  Icons.date_range,
                  size: 18,
                  color: _customDateRange != null ? Colors.white : null,
                ),
                backgroundColor: _customDateRange != null ? Theme.of(context).colorScheme.primary : null,
                label: Text(
                  _customDateRange == null
                      ? 'Date Range'
                      : '${_customDateRange!.start.month}/${_customDateRange!.start.day} - ${_customDateRange!.end.month}/${_customDateRange!.end.day}',
                  style: TextStyle(
                    color: _customDateRange != null ? Colors.white : null,
                    fontSize: 12,
                  ),
                ),
                onPressed: _pickDateRange,
              ),
              const SizedBox(width: 8),

              // Category filter chips
              ...categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: FilterChip(
                    label: Text(cat, style: const TextStyle(fontSize: 12)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  /// Open Add/Edit screen
  void _navigateToAddEdit(Expense? expense) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => AddEditExpenseScreen(expense: expense),
      ),
    );
  }
}
