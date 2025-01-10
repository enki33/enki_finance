import 'package:powersync/powersync.dart';

final schema = Schema([
  Table(
    'users',
    [
      Column.text('email'),
      Column.text('name'),
      Column.text('avatar_url'),
      Column.text('created_at'),
      Column.text('updated_at'),
    ],
  ),
  Table(
    'jars',
    [
      Column.text('user_id'),
      Column.text('name'),
      Column.text('type'),
      Column.real('percentage'),
      Column.real('balance'),
      Column.text('currency'),
      Column.text('created_at'),
      Column.text('updated_at'),
    ],
    indexes: [
      Index('user_id_idx', [IndexedColumn('user_id')]),
      Index('type_idx', [IndexedColumn('type')]),
      Index('created_at_idx', [IndexedColumn('created_at')]),
    ],
  ),
  Table(
    'transactions',
    [
      Column.text('user_id'),
      Column.text('jar_id'),
      Column.text('type'),
      Column.text('category'),
      Column.text('description'),
      Column.real('amount'),
      Column.text('currency'),
      Column.text('status'),
      Column.integer('is_recurring'),
      Column.text('recurrence_rule'),
      Column.text('created_at'),
      Column.text('updated_at'),
    ],
    indexes: [
      Index('user_id_idx', [IndexedColumn('user_id')]),
      Index('jar_id_idx', [IndexedColumn('jar_id')]),
      Index('type_idx', [IndexedColumn('type')]),
      Index('created_at_idx', [IndexedColumn('created_at')]),
    ],
  ),
  Table(
    'categories',
    [
      Column.text('name'),
      Column.text('type'),
      Column.text('icon'),
      Column.text('color'),
      Column.text('created_at'),
      Column.text('updated_at'),
    ],
    indexes: [
      Index('type_idx', [IndexedColumn('type')]),
    ],
  ),
  Table(
    'settings',
    [
      Column.text('user_id'),
      Column.text('key'),
      Column.text('value'),
      Column.text('created_at'),
      Column.text('updated_at'),
    ],
    indexes: [
      Index('user_id_idx', [IndexedColumn('user_id')]),
      Index('key_idx', [IndexedColumn('key')]),
    ],
  ),
]);
