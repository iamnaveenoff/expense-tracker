import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fintracker/dao/account_dao.dart';
import 'package:fintracker/dao/category_dao.dart';
import 'package:fintracker/dao/payment_dao.dart';
import 'package:fintracker/model/account.model.dart';
import 'package:fintracker/model/category.model.dart';
import 'package:fintracker/model/payment.model.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> migrateDataToFirestore() async {
  await Firebase.initializeApp();

  // Initialize the DAO classes
  final AccountDao accountDao = AccountDao();
  final CategoryDao categoryDao = CategoryDao();
  final PaymentDao paymentDao = PaymentDao();

  // Read data from SQLite
  List<Account> accounts = await accountDao.find(withSummery: true);
  List<Category> categories = await categoryDao.find(withSummery: true);
  List<Payment> payments = await paymentDao.find();

  // Save data to Firestore
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Save accounts to Firestore
  for (var account in accounts) {
    await firestore.collection('accounts').doc(account.id.toString()).set({
      'name': account.name,
      'icon': account.icon,
      'color': account.color,
      'isDefault': account.isDefault,
      'income': account.income,
      'expense': account.expense,
      'balance': account.balance,
    });
  }

  // Save categories to Firestore
  for (var category in categories) {
    await firestore.collection('categories').doc(category.id.toString()).set({
      'name': category.name,
      'icon': category.icon,
      'color': category.color,
      'budget': category.budget,
      'expense': category.expense,
    });
  }

  // Save payments to Firestore
  for (var payment in payments) {
    await firestore.collection('payments').doc(payment.id.toString()).set({
      'type': payment.type.toString(), // Convert PaymentType enum to String
      'amount': payment.amount,
      'datetime': Timestamp.fromDate(payment.datetime),
      'category': payment.category.id.toString(), // Convert to String
      'account': payment.account.id.toString(), // Convert to String
    });
  }

  print('Data migration from SQLite to Firestore completed successfully!');
}
