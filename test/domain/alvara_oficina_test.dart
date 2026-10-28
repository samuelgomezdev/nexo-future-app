import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_future_app/domain/erros.dart';
import 'package:nexo_future_app/domain/models/oficina.dart';
import 'package:nexo_future_app/domain/regras/alvara_oficina.dart';

void main() {
  final hoje = DateTime(2026, 10, 28);

  Oficina oficina({Alvara? alvara}) => Oficina(
    id: 'oficina-1',
    nome: 'Oficina Escola Mãos do Porto',
    cidade: 'Itajaí',
    alvara: alvara,
  );

  Alvara alvaraValidoAte(DateTime validade) =>
      Alvara(numero: 'AE-2026-0042', validade: validade);

  group('RN0003: a oficina só publica cursos se apresentar o alvará', () {
    test('oficina com alvará em dia publica curso', () {
      final comAlvara = oficina(alvara: alvaraValidoAte(DateTime(2027, 3, 1)));

      expect(podePublicarCurso(comAlvara, hoje: hoje), isTrue);
      expect(() => conferirAlvara(comAlvara, hoje: hoje), returnsNormally);
    });

    test('oficina sem alvará não publica curso', () {
      final semAlvara = oficina();

      expect(podePublicarCurso(semAlvara, hoje: hoje), isFalse);
      expect(
        () => conferirAlvara(semAlvara, hoje: hoje),
        throwsA(isA<OficinaSemAlvara>()),
      );
    });

    test('alvará com número em branco conta como não apresentado', () {
      final emBranco = oficina(
        alvara: Alvara(numero: '  ', validade: DateTime(2027, 3, 1)),
      );

      expect(
        () => conferirAlvara(emBranco, hoje: hoje),
        throwsA(isA<OficinaSemAlvara>()),
      );
    });

    test('alvará vencido não publica curso', () {
      final vencido = oficina(alvara: alvaraValidoAte(DateTime(2026, 10, 27)));

      expect(podePublicarCurso(vencido, hoje: hoje), isFalse);
      expect(
        () => conferirAlvara(vencido, hoje: hoje),
        throwsA(isA<AlvaraVencido>()),
      );
    });

    test('alvará que vence hoje ainda vale', () {
      final venceHoje = oficina(
        alvara: alvaraValidoAte(DateTime(2026, 10, 28)),
      );

      expect(podePublicarCurso(venceHoje, hoje: hoje), isTrue);
    });

    test('as mensagens explicam o que a oficina precisa fazer', () {
      expect(
        const OficinaSemAlvara().toString(),
        'Envie o alvará de ensino da oficina para publicar cursos.',
      );
      expect(
        const AlvaraVencido().toString(),
        'O alvará de ensino da oficina venceu. Envie o alvará renovado para publicar cursos.',
      );
    });
  });
}
