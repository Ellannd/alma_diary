import 'package:supabase_flutter/supabase_flutter.dart';

class SearchRepository {
  final client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getJournal(String userId) async {
    return await client
        .from('journal')
        .select()
        .eq('user_id', userId);
  }

  Future<List<Map<String, dynamic>>> getReflections(String userId) async {
    return await client
        .from('reflections')
        .select()
        .eq('user_id', userId);
  }

  Future<List<Map<String, dynamic>>> getChallenges(String userId) async {
    return await client
        .from('user_challenges')
        .select('*, challenges(*)')
        .eq('user_id', userId);
  }

  Future<List<Map<String, dynamic>>> getQuotes() async {
    return await client.from('quotes').select();
  }

  

}