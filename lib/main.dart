import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'models/transaction_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TransactionAdapter());
  await Hive.openBox<Transaction>('transactions');
  runApp(const ButceTakipApp());
}

class ButceTakipApp extends StatelessWidget {
  const ButceTakipApp({super.key});

  @override
  Widget build(BuildContext context) {
    // --- RENK PALETİ ---
    const seedColor = Color(0xFF6C63FF);
    const lightBg = Color(0xFFF5F7FA);
    const darkBg = Color(0xFF121212);
    const darkCardBg = Color(0xFF1E1E2C);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cüzdanım',
      
      // Dil Ayarları
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('tr', 'TR')],

      // --- AYDINLIK TEMA ---
      theme: ThemeData(
        brightness: Brightness.light,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor, brightness: Brightness.light),
        useMaterial3: true,
        scaffoldBackgroundColor: lightBg,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
        cardColor: Colors.white,
      ),

      // --- KARANLIK TEMA ---
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).apply(
          bodyColor: Colors.white70, 
          displayColor: Colors.white
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor, 
          brightness: Brightness.dark,
          surface: darkCardBg,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: darkBg,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
        cardColor: darkCardBg,
        bottomSheetTheme: BottomSheetThemeData(backgroundColor: darkCardBg),
      ),

      themeMode: ThemeMode.system, // Sisteme göre otomatik değişir
      home: const AnaSayfa(),
    );
  }
}

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({super.key});

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  final Box<Transaction> transactionBox = Hive.box<Transaction>('transactions');

  final Map<String, dynamic> categoryDetails = {
    'Market': {'icon': Icons.shopping_cart_outlined, 'color': Colors.orange},
    'Yemek': {'icon': Icons.restaurant, 'color': Colors.redAccent},
    'Ulaşım': {'icon': Icons.directions_bus, 'color': Colors.blue},
    'Fatura': {'icon': Icons.receipt_long, 'color': Colors.purple},
    'Eğlence': {'icon': Icons.movie_creation_outlined, 'color': Colors.pink},
    'Sağlık': {'icon': Icons.local_hospital_outlined, 'color': Colors.teal},
    'Maaş': {'icon': Icons.work_outline, 'color': Colors.green},
    'Ek İş': {'icon': Icons.attach_money, 'color': Colors.lightGreen},
    'Hediye': {'icon': Icons.card_giftcard, 'color': Colors.amber},
    'Yatırım': {'icon': Icons.trending_up, 'color': Colors.cyan},
    'Diğer': {'icon': Icons.more_horiz, 'color': Colors.grey},
  };

  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  bool isExpenseSelection = true;
  String? selectedCategory;
  DateTime selectedDate = DateTime.now();

  void _openTransactionForm(BuildContext context, {Transaction? existingTransaction}) {
    if (existingTransaction != null) {
      titleController.text = existingTransaction.title;
      amountController.text = existingTransaction.amount.toString();
      isExpenseSelection = existingTransaction.isExpense;
      selectedCategory = existingTransaction.category;
      selectedDate = existingTransaction.date;
    } else {
      titleController.clear();
      amountController.clear();
      isExpenseSelection = true;
      selectedCategory = null;
      selectedDate = DateTime.now();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final textColor = Theme.of(context).textTheme.bodyLarge!.color;
        
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final categoriesToShow = categoryDetails.keys.where((key) {
               final incomeKeys = ['Maaş', 'Ek İş', 'Hediye', 'Yatırım'];
               if (isExpenseSelection) {
                 return !incomeKeys.contains(key) || key == 'Diğer';
               } else {
                 return incomeKeys.contains(key) || key == 'Diğer';
               }
            }).toList();

            void presentDatePicker() {
              showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                locale: const Locale("tr", "TR"),
              ).then((pickedDate) {
                if (pickedDate == null) return;
                setModalState(() {
                  final now = DateTime.now();
                  selectedDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, now.hour, now.minute);
                });
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 25, left: 20, right: 20,
              ),
              // --- DÜZELTME BURADA: SingleChildScrollView eklendi ---
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      existingTransaction != null ? 'İşlemi Düzenle' : 'Yeni İşlem Ekle', 
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() { isExpenseSelection = true; selectedCategory = null; }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isExpenseSelection ? const Color(0xFFFF5252) : Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.withOpacity(0.2))
                              ),
                              child: Center(child: Text('Gider 📉', style: TextStyle(color: isExpenseSelection ? Colors.white : textColor, fontWeight: FontWeight.bold))),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() { isExpenseSelection = false; selectedCategory = null; }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !isExpenseSelection ? const Color(0xFF4CAF50) : Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.withOpacity(0.2))
                              ),
                              child: Center(child: Text('Gelir 📈', style: TextStyle(color: !isExpenseSelection ? Colors.white : textColor, fontWeight: FontWeight.bold))),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 70,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: categoriesToShow.map((catName) {
                          final isSelected = selectedCategory == catName;
                          final color = categoryDetails[catName]['color'] as Color;
                          final icon = categoryDetails[catName]['icon'] as IconData;
                          
                          return GestureDetector(
                            onTap: () => setModalState(() => selectedCategory = catName),
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? color.withOpacity(0.2) : Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: isSelected ? color : Colors.grey.withOpacity(0.2), width: 2),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(icon, color: color, size: 24),
                                  Text(catName, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Tarih: ${DateFormat('dd MMM yyyy', 'tr_TR').format(selectedDate)}',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: textColor),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: presentDatePicker,
                          icon: Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                          label: Text('Değiştir', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: titleController,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Not (İsteğe bağlı)',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        filled: true, fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.withOpacity(0.2))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.withOpacity(0.2))),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: amountController,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Tutar',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        filled: true, fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.withOpacity(0.2))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.withOpacity(0.2))),
                        suffixText: '₺',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
                        onPressed: () {
                          final double? amount = double.tryParse(amountController.text);
                          if (amount != null && selectedCategory != null) {
                            if (existingTransaction != null) {
                              existingTransaction.title = titleController.text.isEmpty ? selectedCategory! : titleController.text;
                              existingTransaction.amount = amount;
                              existingTransaction.isExpense = isExpenseSelection;
                              existingTransaction.category = selectedCategory!;
                              existingTransaction.date = selectedDate;
                              existingTransaction.save();
                            } else {
                              final newTx = Transaction(
                                title: titleController.text.isEmpty ? selectedCategory! : titleController.text,
                                amount: amount,
                                date: selectedDate,
                                isExpense: isExpenseSelection,
                                category: selectedCategory!,
                              );
                              transactionBox.add(newTx);
                            }
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          existingTransaction != null ? 'Güncelle' : 'Kaydet', 
                          style: const TextStyle(color: Colors.white, fontSize: 16)
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<PieChartSectionData> _getSections(List<Transaction> transactions) {
    Map<String, double> categoryTotals = {};
    double totalExpense = 0;
    for (var tx in transactions) {
      if (tx.isExpense) {
        totalExpense += tx.amount;
        if (categoryTotals.containsKey(tx.category)) {
          categoryTotals[tx.category] = categoryTotals[tx.category]! + tx.amount;
        } else {
          categoryTotals[tx.category] = tx.amount;
        }
      }
    }
    return categoryTotals.entries.map((entry) {
      final percentage = (entry.value / totalExpense) * 100;
      final color = categoryDetails[entry.key]?['color'] ?? Colors.grey;
      return PieChartSectionData(
        color: color, value: entry.value, title: '${percentage.toStringAsFixed(0)}%', radius: 50,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge!.color;
    // final cardColor = Theme.of(context).cardColor; // Kullanılmayan değişken uyarısı vermesin diye kapattım

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Cüzdanım', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: textColor)),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: transactionBox.listenable(),
        builder: (context, Box<Transaction> box, _) {
          double totalIncome = 0;
          double totalExpense = 0;
          for (var tx in box.values) {
            tx.isExpense ? totalExpense += tx.amount : totalIncome += tx.amount;
          }
          double balance = totalIncome - totalExpense;
          var transactions = box.values.toList();
          transactions.sort((a, b) => b.date.compareTo(a.date));

          var chartSections = _getSections(transactions);

          return ListView(
            children: [
              // 1. BAKİYE KARTI
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2D3142), Color(0xFF4F5D75)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [BoxShadow(color: const Color(0xFF2D3142).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 10))],
                ),
                child: Column(
                  children: [
                    Text('Toplam Bakiye', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
                    Text('${balance.toStringAsFixed(2)} ₺', style: GoogleFonts.poppins(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         _buildSummaryItem(Icons.arrow_downward, Colors.greenAccent, 'Gelir', totalIncome),
                         Container(height: 30, width: 1, color: Colors.white24),
                         _buildSummaryItem(Icons.arrow_upward, Colors.redAccent, 'Gider', totalExpense),
                      ],
                    ),
                  ],
                ),
              ),

              // 2. PASTA GRAFİĞİ
              if (totalExpense > 0) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Harcama Dağılımı', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: chartSections,
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                      pieTouchData: PieTouchData(enabled: true),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Wrap(
                    spacing: 10, runSpacing: 10,
                    children: categoryDetails.keys.where((k) => transactions.any((t) => t.category == k && t.isExpense)).map((key) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 12, height: 12, decoration: BoxDecoration(color: categoryDetails[key]['color'], shape: BoxShape.circle)),
                          const SizedBox(width: 5),
                          Text(key, style: TextStyle(fontSize: 12, color: textColor)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],

              // 3. SON İŞLEMLER BAŞLIĞI
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text('Son İşlemler', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
              ),
              
              // 4. LİSTE
              transactions.isEmpty
                  ? Center(child: Padding(padding: const EdgeInsets.all(20), child: Text("Henüz işlem yok", style: GoogleFonts.poppins(color: Colors.grey))))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final tx = transactions[index];
                        final details = categoryDetails[tx.category] ?? {'icon': Icons.error, 'color': Colors.grey};

                        return GestureDetector(
                          onTap: () => _openTransactionForm(context, existingTransaction: tx),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1))
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: (details['color'] as Color).withOpacity(isDarkMode ? 0.2 : 0.1),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Icon(details['icon'], color: details['color'], size: 26),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(tx.title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat('dd MMM, HH:mm', 'tr_TR').format(tx.date),
                                        style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[500]),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${tx.isExpense ? "-" : "+"}${tx.amount.toStringAsFixed(0)} ₺',
                                      style: GoogleFonts.poppins(
                                        fontSize: 17, fontWeight: FontWeight.bold,
                                        color: tx.isExpense ? const Color(0xFFFF5252) : const Color(0xFF4CAF50),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => tx.delete(),
                                      child: Padding(padding: const EdgeInsets.only(top: 8, left: 10, bottom: 5), child: Icon(Icons.delete_outline, size: 20, color: Colors.grey[400])),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                const SizedBox(height: 80),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openTransactionForm(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSummaryItem(IconData icon, Color color, String title, double amount) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
            Text('${amount.toStringAsFixed(0)} ₺', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}