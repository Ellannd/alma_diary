# Journal Restructure TODO

## Phase 1: Data Layer (Repository) ✅
- [x] 1.1 Create JournalRepository with full CRUD
- [x] insertEntry(entry)
- [x] getEntries()
- [x] getEntryById(id)
- [x] updateEntry(entry)
- [x] deleteEntry(id)

## Phase 2: Service Layer (Utilities) ✅
- [x] 2.1 Create JournalService with encryption/decryption
- [x] encryptContent(content)
- [x] decryptContent(encrypted)
- [x] encryptAnalysis(analysis)
- [x] decryptAnalysis(encrypted)
- [x] generateEntryId()

## Phase 3: Controller (Orchestrator) ✅
- [x] 3.1 Create JournalController
- [x] saveEntry(content, sentiment, etc)
- [x] loadEntries()
- [x] loadEntryById(id)
- [x] updateEntry(id, data)
- [x] deleteEntry(id)

## Phase 4: UI Updates ✅
- [x] 4.1 Update alma_journal.dart
- [x] 4.2 Update EntryReflectionDetail
- [x] 4.3 Update AlmaReflectionsScreen
- [x] 4.4 Update references in other files

## Phase 5: Cleanup ✅
- [x] 5.1 Remove old JournalService duplication (journal_service.dart deleted)
- [x] 5.2 Remove old JournalRepository duplication (journal_repository.dart deleted)
- [ ] 5.3 Verify build compiles (flutter analyze)
