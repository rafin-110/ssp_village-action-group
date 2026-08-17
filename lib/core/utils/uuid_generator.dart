import 'package:uuid/uuid.dart';

// ---------------------------------------------------------------------------
// PHASE 07 — UUID Generator Utility
// ---------------------------------------------------------------------------
// All client-side entities (Issues, ProgressUpdates, Attachments) must have
// their UUID generated HERE before saving. The same UUID is used as the
// primary key in both Isar and Supabase — this makes sync retries idempotent.
//
// Rule from §40.1 of project_documentation.md:
// "Generate issue UUID locally before saving. Use the same UUID in Supabase.
//  This makes retries idempotent."
// ---------------------------------------------------------------------------

const _uuid = Uuid();

/// Generates a new v4 UUID string.
/// Use for: new Issue, new ProgressUpdate, new Attachment.
String generateUuid() => _uuid.v4();
