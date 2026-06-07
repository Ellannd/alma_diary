// lib/ai/chat/controllers/chat_controller.dart

import 'dart:async';

import 'package:alma_diary/features/embeddings/data/embeddings_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alma_diary/ai/chat/domain/chat_conversation.dart';
import 'package:alma_diary/ai/chat/domain/chat_message.dart';
import 'package:alma_diary/ai/chat/services/chat_service.dart';
import 'package:alma_diary/ai/chat/data/chat_repository.dart';
import 'package:alma_diary/core/constants.dart';
import 'package:alma_diary/core/logging/log_service.dart';
import 'package:alma_diary/state/profile/profile_controller.dart';

// ── Estado ───────────────────────────────────────────────────────

class ChatState {
  final List<ChatMessage> messages;
  final List<ChatConversation> conversations;
  final ChatConversation? activeConversation;
  final bool isLoading;
  final bool isLoadingConversations;
  final String? error;
  final List<SimilarEntry> similarEntries;

  const ChatState({
    this.messages = const [],
    this.conversations = const [],
    this.activeConversation,
    this.isLoading = false,
    this.isLoadingConversations = false,
    this.error,
    this.similarEntries = const [],
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    List<ChatConversation>? conversations,
    ChatConversation? activeConversation,
    bool? isLoading,
    bool? isLoadingConversations,
    String? error,
    bool clearConversation = false,
    bool clearError = false,
    List<SimilarEntry>? similarEntries,
  }) => ChatState(
    messages: messages ?? this.messages,
    conversations: conversations ?? this.conversations,
    activeConversation: clearConversation
        ? null
        : activeConversation ?? this.activeConversation,
    isLoading: isLoading ?? this.isLoading,
    isLoadingConversations:
        isLoadingConversations ?? this.isLoadingConversations,
    error: clearError ? null : error ?? this.error,
    similarEntries: similarEntries ?? this.similarEntries,
  );

  bool get hasMessages => messages.isNotEmpty;
  bool get hasError => error != null;
  bool get hasConversations => conversations.isNotEmpty;
}

// ── Notifier ─────────────────────────────────────────────────────

class ChatNotifier extends Notifier<ChatState> {
  late ChatService _service;
  late ChatRepository _repo;

  @override
  ChatState build() {
    final user = ref.watch(currentUserProvider);
    final userId = user?.id ?? '';

    _repo = ChatRepository(Supabase.instance.client);

    _service = ChatService(
      supabaseUrl: EnvConfig.supabaseUrl,
      supabaseAnonKey: EnvConfig.supabaseAnonKey,
      userId: userId,
    );

    // Cargar conversaciones al iniciar
    if (userId.isNotEmpty) {
      Future.microtask(() => _loadConversations(userId));
    }

    ref.onDispose(() => _service.clearHistory());

    return const ChatState();
  }

  // ── Conversaciones ─────────────────────────────────────────

  Future<void> _loadConversations(String userId) async {
    state = state.copyWith(isLoadingConversations: true);
    try {
      final conversations = await _repo.getConversations(userId);
      state = state.copyWith(
        conversations: conversations,
        isLoadingConversations: false,
      );
    } catch (e) {
      LogService.instance.error('chat.load_conversations', error: e);
      state = state.copyWith(isLoadingConversations: false);
    }
  }

  /// Crea una conversación nueva y la activa
  Future<void> newConversation() async {
    final userId = ref.read(currentUserProvider)?.id ?? '';
    if (userId.isEmpty) return;

    try {
      final conversation = await _repo.createConversation(userId);
      _service.clearHistory();

      state = state.copyWith(
        activeConversation: conversation,
        messages: [],
        conversations: [conversation, ...state.conversations],
        clearError: true,
      );
    } catch (e) {
      LogService.instance.error('chat.new_conversation', error: e);
      state = state.copyWith(error: e.toString());
    }
  }

  /// Carga una conversación existente del historial
  Future<void> loadConversation(ChatConversation conversation) async {
    state = state.copyWith(
      activeConversation: conversation,
      isLoading: true,
      clearError: true,
    );

    try {
      final messages = await _repo.getMessages(conversation.id);

      // Reconstruir historial en el service para que el contexto sea correcto
      _service.clearHistory();
      _service.restoreHistory(messages);

      state = state.copyWith(messages: messages, isLoading: false);
    } catch (e) {
      LogService.instance.error('chat.load_conversation', error: e);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    try {
      await _repo.deleteConversation(conversationId);

      final updated = state.conversations
          .where((c) => c.id != conversationId)
          .toList();

      // Si era la activa, limpiar
      final wasActive = state.activeConversation?.id == conversationId;

      state = state.copyWith(
        conversations: updated,
        clearConversation: wasActive,
        messages: wasActive ? [] : null,
      );

      if (wasActive) _service.clearHistory();
    } catch (e) {
      LogService.instance.error('chat.delete_conversation', error: e);
    }
  }

  // ── Mensajes ───────────────────────────────────────────────

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || state.isLoading) return;

    // Si no hay conversación activa, crear una
    if (state.activeConversation == null) await newConversation();
    final conversation = state.activeConversation;
    if (conversation == null) return;

    final isFirstMessage = state.messages.isEmpty;

    final userMsg = ChatMessage(
      content: text.trim(),
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      clearError: true,
      similarEntries: [],
    );

    try {
      final reply = await _service.sendMessage(
        text,
        conversationId: conversation.id,
      );

      state = state.copyWith(
        messages: [...state.messages, reply],
        isLoading: false,
      );

      final userId = ref.read(currentUserProvider)?.id;
      if (userId != null) {
        unawaited(
          EmbeddingRepository().searchSimilar(userId: userId, query: text).then(
            (entries) {
              state = state.copyWith(similarEntries: entries);
            },
          ),
        );
      }

      // Generar título tras el primer mensaje (fire & forget)
      if (isFirstMessage) {
        _generateAndUpdateTitle(conversation, text);
      }
    } catch (e) {
      LogService.instance.error('chat.send_message', error: e);
      state = state.copyWith(
        messages: state.messages.where((m) => m != userMsg).toList(),
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> _generateAndUpdateTitle(
    ChatConversation conversation,
    String firstMessage,
  ) async {
    final title = await _repo.generateTitle(firstMessage);
    if (title == null || title.isEmpty) return;

    try {
      await _repo.updateTitle(conversation.id, title);

      // Actualizar en estado local
      final updatedConversation = conversation.copyWith(title: title);
      final updatedList = state.conversations.map((c) {
        return c.id == conversation.id ? updatedConversation : c;
      }).toList();

      state = state.copyWith(
        activeConversation: updatedConversation,
        conversations: updatedList,
      );
    } catch (e) {
      LogService.instance.error('chat.update_title', error: e);
    }
  }

  void clearError() => state = state.copyWith(clearError: true);
}

// ── Providers ────────────────────────────────────────────────────

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(
  ChatNotifier.new,
);
