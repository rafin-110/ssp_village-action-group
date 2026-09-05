import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/bootstrap/app_bootstrap.dart';
import 'core/network/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── 1. Supabase (must be first — auth session restore depends on it) ──────
  await Supabase.initialize(
    url: SupabaseConfig.url,
    // ignore: deprecated_member_use
    anonKey: SupabaseConfig.anonKey,
  );

  // ── 2. Offline-first database & Data migrations ─────────────────────────────
  await initLocalDbAndSync();

  // ── 3. Initialize locale data for formatting ──────────────────────────────
  await initializeDateFormatting('en_IN', null);
  await initializeDateFormatting('hi_IN', null);

  runApp(
    const ProviderScope(
      child: VagDmpApp(),
    ),
  );
}
