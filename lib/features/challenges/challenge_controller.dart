import 'package:alma_diary/features/notifications/controller/notifications_controller_old.dart';
import 'package:flutter/foundation.dart';
import 'package:alma_diary/features/challenges/engine/challenges_engine_v2.dart';
import 'challenge_repository.dart';


class ChallengeController extends ChangeNotifier {
  final ChallengeRepository _repository;
  final ChallengesEngine _engine;
  final NotificationController _notificationController;

  String? _userId;

  // ============= STATE =============
  List<Challenge> _challenges = [];
  List<UserChallenge> _userChallenges = [];
  Map<String, int> _progressByChallenge = {};
  Map<String, String> _statusByChallenge = {};
  Map<String, Challenge> _challengeMap = {};

  bool _isLoading = false;
  String? _error;

  // ============= GETTERS =============
  List<Challenge> get challenges => _challenges;
  List<UserChallenge> get userChallenges => _userChallenges;
  Map<String, int> get progressByChallenge => _progressByChallenge;
  Map<String, String> get statusByChallenge => _statusByChallenge;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get userId => _userId;

  // ============= CONSTRUCTOR =============
  ChallengeController({
    ChallengeRepository? repository,
    ChallengesEngine? engine,
    NotificationController? notificationController,
  })  : _repository = repository ?? ChallengeRepository(),
        _engine = engine ?? ChallengesEngine(),
        _notificationController =
            notificationController ?? NotificationController.instance;

  // ============= INITIALIZATION =============
  void setUserId(String userId) {
    _userId = userId;
  }
  
  /// Load all challenges and user progress
  /// This is the main entry point for initializing the controller
  Future<void> loadChallenges() async {
    if (_userId == null) {
      _setError(' Usuario no autenticado');
      return;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      // Load from repository
      final challenges = await _repository.getChallenges();
      final userChallenges = await _repository.getUserChallenges(_userId!);
      
      // Update state
      _updateState(challenges, userChallenges);
      
    } catch (e) {
      debugPrint('Error loading challenges: $e');
      _setError('Error al cargar desafíos: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // ============= STATE UPDATES =============
  void _updateState(
    List<Challenge> challenges,
    List<UserChallenge> userChallenges,
  ) {
    _challenges = challenges;
    _userChallenges = userChallenges;
    
    // Build challenge map for quick lookup
    _challengeMap = {
      for (var c in challenges) c.id: c,
    };
    
    // Build progress map
    _progressByChallenge = {
      for (var uc in userChallenges) uc.challengeId: uc.progress,
    };
    
    // Build status map
    _statusByChallenge = {
      for (var uc in userChallenges) uc.challengeId: uc.status,
    };
    
    notifyListeners();
  }
  
  void _updateUserChallengeState(UserChallenge updated) {
    // Update in list
    final index = _userChallenges.indexWhere(
      (uc) => uc.challengeId == updated.challengeId,
    );
    
    if (index >= 0) {
      _userChallenges[index] = updated;
    } else {
      _userChallenges.add(updated);
    }
    
    // Update maps
    _progressByChallenge[updated.challengeId] = updated.progress;
    _statusByChallenge[updated.challengeId] = updated.status;
    
    notifyListeners();
  }
  
  // ============= ACTIONS =============
  
  /// Start a new challenge
  /// Flow: UI → Controller → Engine.validateStart() → Repository.insert() → State → notifyListeners()
  Future<bool> startChallenge(String challengeId) async {
    if (_userId == null) {
      _setError('Usuario no autenticado');
      return false;
    }
    
    // Get challenge
    final challenge = _challengeMap[challengeId];
    if (challenge == null) {
      _setError('Desafío no encontrado');
      return false;
    }
    
    // Validate with engine (NO complex logic here)
    final (isValid, errorMessage) = _engine.validateStart(
      challenge: challenge,
      existingUserChallenges: _userChallenges,
    );
    
    if (!isValid) {
      _setError(errorMessage ?? 'No se puede iniciar el desafío');
      return false;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      // Insert via repository
      await _repository.insertUserChallenge(
        userId: _userId!,
        challenge: challenge,
      );
      
      // Create new user challenge state locally
      final newUserChallenge = UserChallenge(
        id: '',
        challengeId: challengeId,
        status: 'active',
        progress: 0,
        startedAt: DateTime.now(),
      );
      
      // Update state
      _updateUserChallengeState(newUserChallenge);
      
      // Notify via engine (side effect)
      await _notificationController.handleChallengeEvent(
        _userId!,
        challenge.title,
        eventType: 'started',
      
      );
      
      return true;
      
    } catch (e) {
      debugPrint('Error starting challenge: $e');
      _setError('Error al iniciar desafío: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Update challenge progress
  /// Flow: UI → Controller → Engine.calculateProgress() → Repository.update() → State → notifyListeners()
  Future<bool> updateProgress(String challengeId, int newProgress) async {
    if (_userId == null) {
      _setError('Usuario no autenticado');
      return false;
    }
    
    // Get current challenge and progress
    final challenge = _challengeMap[challengeId];
    if (challenge == null) {
      _setError('Desafío no encontrado');
      return false;
    }
    
    final currentProgress = _progressByChallenge[challengeId] ?? 0;
    
    // Calculate new progress via engine
    final calculatedProgress = _engine.calculateProgress(
      currentProgress: currentProgress,
      increment: newProgress - currentProgress,
    );
    
    // Check if completed
    final isCompleted = _engine.isProgressCompleted(calculatedProgress);
    
    // Determine status via engine
    final newStatus = _engine.determineStatus(calculatedProgress);
    
    _setLoading(true);
    _clearError();
    
    try {
      // Update via repository
      await _repository.updateUserChallenge(
        userId: _userId!,
        challenge: challenge,
        progress: calculatedProgress,
        isCompleted: isCompleted,
      );
      
      // Update local state
      final existingIndex = _userChallenges.indexWhere(
        (uc) => uc.challengeId == challengeId,
      );
      
      final updatedUserChallenge = existingIndex >= 0
          ? UserChallenge(
              id: _userChallenges[existingIndex].id,
              challengeId: challengeId,
              status: newStatus,
              progress: calculatedProgress,
              startedAt: _userChallenges[existingIndex].startedAt,
              completedAt: isCompleted ? DateTime.now() : null,
            )
          : UserChallenge(
              id: '',
              challengeId: challengeId,
              status: newStatus,
              progress: calculatedProgress,
              startedAt: DateTime.now(),
              completedAt: isCompleted ? DateTime.now() : null,
            );
      
      _updateUserChallengeState(updatedUserChallenge);
      
      // If completed, notify and calculate reward
      if (isCompleted) {
        final reward = _engine.calculateReward(
          challenge: challenge,
          finalProgress: calculatedProgress,
          durationDays: DateTime.now().difference(
            updatedUserChallenge.startedAt ?? DateTime.now(),
          ).inDays,
        );
        
        await _notificationController.handleChallengeEvent(
            _userId!,
            challenge.title,
            eventType: 'completed',
            points: reward,
          );
      }
      
      return true;
      
    } catch (e) {
      debugPrint('Error updating progress: $e');
      _setError('Error al actualizar progreso: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Increment progress by a specific amount
  Future<bool> incrementProgress(String challengeId, int increment) async {
    final currentProgress = _progressByChallenge[challengeId] ?? 0;
    final newProgress = (currentProgress + increment).clamp(0, 100);
    return updateProgress(challengeId, newProgress);
  }
  
  /// Mark challenge as completed (100%)
  Future<bool> completeChallenge(String challengeId) async {
    return updateProgress(challengeId, 100);
  }
  
  // ============= QUERY HELPERS =============
  
  /// Get challenge by ID
  Challenge? getChallenge(String challengeId) {
    return _challengeMap[challengeId];
  }
  
  /// Get progress for a specific challenge
  int getProgress(String challengeId) {
    return _progressByChallenge[challengeId] ?? 0;
  }
  
  /// Get status for a specific challenge
  String getStatus(String challengeId) {
    return _statusByChallenge[challengeId] ?? 'not_started';
  }
  
  /// Check if a challenge is active
  bool isActive(String challengeId) {
    return _statusByChallenge[challengeId] == 'active';
  }
  
  /// Check if a challenge is completed
  bool isCompleted(String challengeId) {
    return _statusByChallenge[challengeId] == 'completed';
  }
  
  /// Check if a challenge has been started (any state)
  bool isStarted(String challengeId) {
    return _statusByChallenge.containsKey(challengeId);
  }
  
  /// Get user challenge object
  UserChallenge? getUserChallenge(String challengeId) {
    try {
      return _userChallenges.firstWhere(
        (uc) => uc.challengeId == challengeId,
      );
    } catch (_) {
      return null;
    }
  }
  
  /// Get progress summary
  Map<String, dynamic> getProgressSummary() {
    return _engine.buildProgressSummary(_userChallenges);
  }
  
  /// Get challenges filtered by category
  List<Challenge> getChallengesByCategory(String category) {
    return _engine.filterByCategory(
      challenges: _challenges,
      category: category,
    );
  }
  
  /// Get unique categories
  List<String> getCategories() {
    return _challenges.map((c) => c.category).toSet().toList();
  }
  
  // ============= ERROR HANDLING =============
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  void _setError(String message) {
    _error = message;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
  }
  
  void clearError() {
    _clearError();
    notifyListeners();
  }
  
  // ============= RESET =============
  void reset() {
    _challenges = [];
    _userChallenges = [];
    _progressByChallenge = {};
    _statusByChallenge = {};
    _challengeMap = {};
    _isLoading = false;
    _error = null;
    _userId = null;
    notifyListeners();
  }
}
