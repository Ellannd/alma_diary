# TODO - Reflections Architecture Alignment

## 📋 Plan: Align Reflections with Journal Architecture

### Phase 1: Create ReflectionController
- [x] 1.1 Create `lib/features/reflections/controller/reflection_controller.dart`
- [x] 1.2 Implement state: entries, isLoading, selectedEntry
- [x] 1.3 Wrap JournalService calls (single source)
- [x] 1.4 Handle decryption in controller (not UI/Engine)

### Phase 2: Update Reflections UI
- [x] 2.1 Remove local `_entries` state
- [x] 2.2 Use controller for loading entries
- [x] 2.3 Use controller for entry detail

### Phase 3: Update Entry Reflection Detail
- [x] 3.1 Remove local state
- [x] 3.2 Use controller

### Phase 4: Clean up ReflectionsEngine
- [ ] 4.1 Remove direct Supabase access
- [ ] 4.2 Keep only visualization/analysis logic
