class Tables {
  Tables._();

  static const String categories = '''
    CREATE TABLE categories (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      icon INTEGER NOT NULL,
      color INTEGER NOT NULL,
      type TEXT NOT NULL CHECK(type IN ('income', 'expense'))
    )
  ''';

  static const String transactions = '''
    CREATE TABLE transactions (
      id TEXT PRIMARY KEY,
      amount REAL NOT NULL,
      type TEXT NOT NULL CHECK(type IN ('income', 'expense')),
      category_id TEXT NOT NULL,
      description TEXT,
      date TEXT NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (category_id) REFERENCES categories(id)
    )
  ''';

  static const String credits = '''
    CREATE TABLE credits (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      total_amount REAL NOT NULL,
      term_months INTEGER NOT NULL,
      monthly_payment REAL NOT NULL,
      interest_rate REAL NOT NULL DEFAULT 0,
      start_date TEXT NOT NULL,
      remaining_amount REAL NOT NULL
    )
  ''';

  static const String creditPayments = '''
    CREATE TABLE credit_payments (
      id TEXT PRIMARY KEY,
      credit_id TEXT NOT NULL,
      amount REAL NOT NULL,
      due_date TEXT NOT NULL,
      is_paid INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (credit_id) REFERENCES credits(id) ON DELETE CASCADE
    )
  ''';
}
