import 'package:supabase_flutter/supabase_flutter.dart';
import '../atletica_model.dart';

class TorcidometroRepository {
  final SupabaseClient _supabaseClient;

  TorcidometroRepository(this._supabaseClient);

  Future<List<Atletica>> getRankingBySeries(String series) async {
    try {
      final response = await _supabaseClient.rpc(
        'execute_raw_sql',
        params: {
          'query':
              '''
            SELECT 
              COUNT(nickname) as pontos, 
              a.nickname as nome,
              a.logo_url as logo
            FROM 
              athletic_vote av
            INNER JOIN 
              athletics a ON av.athletic_id = a.id
            WHERE 
              series = '$series'
            GROUP BY 
              a.nickname, a.logo_url
            ORDER BY 
              pontos DESC
          ''',
        },
      );

      if (response != null && response is List) {
        final rankings = response.map((item) {
          final data = item as Map<String, dynamic>;
          return Atletica(
            posicao: 0, // Position will be set after sorting
            nome: data['nome'] as String? ?? '',
            logo: data['logo'] as String? ?? '',
            ouro: 0,
            prata: 0,
            bronze: 0,
            pontos: data['pontos'] as int? ?? 0,
          );
        }).toList();

        // Set positions based on the sorted order
        for (int i = 0; i < rankings.length; i++) {
          rankings[i] = Atletica(
            posicao: i + 1,
            nome: rankings[i].nome,
            logo: rankings[i].logo,
            ouro: rankings[i].ouro,
            prata: rankings[i].prata,
            bronze: rankings[i].bronze,
            pontos: rankings[i].pontos,
          );
        }

        return rankings;
      }

      return [];
    } catch (error) {
      throw Exception('Erro ao buscar ranking: $error');
    }
  }
}
