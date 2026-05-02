# TODO - Readings Architecture Migration

## 📋 Migration Plan: Readings Feature

### Phase 1: Create Repository (Data Layer)
- [x] 1.1 Create `lib/features/readings/data/reading_repository.dart`
- [x] 1.2 Implement `getReadings()` - fetch all readings
- [x] 1.3 Implement `saveReading()` - insert to saved_readings
- [x] 1.4 Implement `getSavedReadingIds()` - get user's saved IDs
- [x] 1.5 Implement `removeSavedReading()` - delete from saved_readings

### Phase 2: Create Controller (State + Logic)
- [x] 2.1 Create `lib/features/readings/controller/reading_controller.dart`
- [x] 2.2 Implement properties: readings, savedIds, isLoading
- [x] 2.3 Implement `setUser()` - set current user
- [x] 2.4 Implement `load()` - load all readings and saved IDs
- [x] 2.5 Implement `toggleSave()` - save/unsave reading
- [x] 2.6 Implement `isSaved()` - check if reading is saved

### Phase 3: Update UI (alma_readings.dart)
- [x] 3.1 Remove `_saved` Set from UI
- [x] 3.2 Replace `_savePersonalizedReading()` fake method with real implementation
- [x] 3.3 Remove direct ReadingsEngine usage for basic loading
- [x] 3.4 Add controller initialization in initState
- [x] 3.5 Replace data source with controller.readings
- [x] 3.6 Use controller.isSaved() for saved state
- [x] 3.7 Use controller.toggleSave() for save action
- [ ] 3.8 Use controller.isLoading for loading state (optional - local loading kept)

### Phase 4: Cleanup Old Files (Optional)
- [ ] 4.1 Keep `reading_service.dart` for other features (or deprecate)
- [ ] 4.2 Keep `readings_engine.dart` for personalized reading generation
