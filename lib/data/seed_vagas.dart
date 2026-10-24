import '../domain/models/vaga.dart';

// Dados fictícios: empresas, oficinas e vagas inventadas para a demonstração.

const _maosDoPorto = 'Oficina Escola Mãos do Porto';
const _centroTecnico = 'Centro Técnico Itajaí';
const _navegar = 'Instituto Navegar Profissões';

const _laminacao = Curso(
  id: 'c-laminacao',
  nome: 'Laminação em fibra de vidro',
  oficina: _maosDoPorto,
);
const _pinturaNaval = Curso(
  id: 'c-pintura-naval',
  nome: 'Pintura naval',
  oficina: _maosDoPorto,
);
const _marcenariaNautica = Curso(
  id: 'c-marcenaria',
  nome: 'Marcenaria náutica',
  oficina: _maosDoPorto,
);
const _desenhoTecnico = Curso(
  id: 'c-desenho',
  nome: 'Leitura de desenho técnico',
  oficina: _navegar,
);
const _direcaoDefensiva = Curso(
  id: 'c-direcao',
  nome: 'Direção defensiva para CNH D',
  oficina: _centroTecnico,
);
const _mecanicaDiesel = Curso(
  id: 'c-diesel',
  nome: 'Mecânica de motores diesel',
  oficina: _centroTecnico,
);
const _empilhadeira = Curso(
  id: 'c-empilhadeira',
  nome: 'Operação de empilhadeira',
  oficina: _centroTecnico,
);
const _almoxarifado = Curso(
  id: 'c-almoxarifado',
  nome: 'Rotinas de almoxarifado',
  oficina: _navegar,
);
const _soldagem = Curso(
  id: 'c-soldagem',
  nome: 'Soldagem MIG/MAG',
  oficina: _centroTecnico,
);
const _metrologia = Curso(
  id: 'c-metrologia',
  nome: 'Metrologia e controle de qualidade',
  oficina: _navegar,
);
const _usinagem = Curso(
  id: 'c-usinagem',
  nome: 'Tornearia e fresagem',
  oficina: _centroTecnico,
);
const _alturaNr35 = Curso(
  id: 'c-nr35',
  nome: 'Trabalho em altura (NR-35)',
  oficina: _centroTecnico,
);
const _alvenaria = Curso(
  id: 'c-alvenaria',
  nome: 'Alvenaria e acabamento',
  oficina: _maosDoPorto,
);
const _eletrica = Curso(
  id: 'c-eletrica',
  nome: 'Instalações elétricas prediais',
  oficina: _centroTecnico,
);
const _recepcao = Curso(
  id: 'c-recepcao',
  nome: 'Recepção e atendimento em hotelaria',
  oficina: _navegar,
);
const _cozinha = Curso(
  id: 'c-cozinha',
  nome: 'Auxiliar de cozinha',
  oficina: _navegar,
);
const _boasPraticas = Curso(
  id: 'c-boas-praticas',
  nome: 'Boas práticas na manipulação de alimentos',
  oficina: _navegar,
);

const _naval = 'Naval';
const _logistica = 'Logística';
const _metalurgia = 'Metalurgia';
const _construcao = 'Construção Civil';
const _hotelaria = 'Turismo e Hotelaria';
const _alimentos = 'Alimentos';

const _fozAzul = 'Estaleiro Foz Azul';
const _pontaBrava = 'Náutica Ponta Brava';
const _transVale = 'TransVale Logística';
const _caisNorte = 'Armazéns Cais Norte';
const _metalSul = 'MetalSul Usinagem';
const _forjaAtlantica = 'Forja Atlântica';
const _horizonte = 'Construtora Horizonte Litoral';
const _enseadaClara = 'Hotel Enseada Clara';
const _mareAlta = 'Pescados Maré Alta';

const _fundamental = 'Ensino fundamental completo';
const _medio = 'Ensino médio completo';
const _medioCursando = 'Ensino médio em andamento';

/// Sem cursos a vaga fica "aberta"; com cursos, "aguardando ingresso".
Vaga _vaga(
  int numero,
  String titulo,
  String empresa,
  String area,
  String cidade,
  String qualificacao,
  List<Curso> cursos, {
  bool lotada = false,
}) {
  final situacao = lotada
      ? SituacaoVaga.lotada
      : cursos.isEmpty
      ? SituacaoVaga.aberta
      : SituacaoVaga.aguardandoIngresso;
  return Vaga(
    id: 'vaga-${numero.toString().padLeft(2, '0')}',
    titulo: titulo,
    empresa: empresa,
    area: area,
    cidade: cidade,
    qualificacao: qualificacao,
    situacao: situacao,
    cursos: cursos,
  );
}

final List<Vaga> seedVagas = [
  _vaga(1, 'Laminador', _fozAzul, _naval, 'Itajaí', _fundamental, [
    _laminacao,
    _desenhoTecnico,
  ]),
  _vaga(2, 'Pintor Naval', _fozAzul, _naval, 'Itajaí', _fundamental, [
    _pinturaNaval,
    _alturaNr35,
  ]),
  _vaga(3, 'Marceneiro Náutico', _fozAzul, _naval, 'Navegantes', _fundamental, [
    _marcenariaNautica,
    _desenhoTecnico,
  ]),
  _vaga(4, 'Motorista CNH D', _transVale, _logistica, 'Itajaí', _medio, [
    _direcaoDefensiva,
  ]),
  _vaga(5, 'Mecânico Diesel', _transVale, _logistica, 'Navegantes', _medio, [
    _mecanicaDiesel,
    _desenhoTecnico,
  ]),
  _vaga(6, 'Soldador', _metalSul, _metalurgia, 'Itajaí', _fundamental, [
    _soldagem,
    _desenhoTecnico,
    _alturaNr35,
  ]),
  _vaga(7, 'Inspetor de Qualidade', _metalSul, _metalurgia, 'Itajaí', _medio, [
    _metrologia,
    _desenhoTecnico,
  ]),
  _vaga(
    8,
    'Auxiliar de Laminação',
    _pontaBrava,
    _naval,
    'Itapema',
    _medioCursando,
    [_laminacao],
  ),
  _vaga(
    9,
    'Operador de Empilhadeira',
    _caisNorte,
    _logistica,
    'Navegantes',
    _fundamental,
    [_empilhadeira],
  ),
  _vaga(
    10,
    'Auxiliar de Almoxarifado',
    _caisNorte,
    _logistica,
    'Itajaí',
    _medioCursando,
    [_almoxarifado, _empilhadeira],
  ),
  _vaga(
    11,
    'Torneiro Mecânico',
    _forjaAtlantica,
    _metalurgia,
    'Camboriú',
    _fundamental,
    [_usinagem, _metrologia, _desenhoTecnico],
  ),
  _vaga(
    12,
    'Pedreiro',
    _horizonte,
    _construcao,
    'Balneário Camboriú',
    _fundamental,
    [_alvenaria, _alturaNr35],
  ),
  _vaga(
    13,
    'Eletricista Predial',
    _horizonte,
    _construcao,
    'Balneário Camboriú',
    _medio,
    [_eletrica, _alturaNr35],
  ),
  _vaga(
    14,
    'Recepcionista de Hotel',
    _enseadaClara,
    _hotelaria,
    'Balneário Camboriú',
    _medio,
    [_recepcao],
  ),
  _vaga(
    15,
    'Auxiliar de Cozinha',
    _enseadaClara,
    _hotelaria,
    'Itapema',
    _medioCursando,
    [_cozinha, _boasPraticas],
  ),
  _vaga(
    16,
    'Auxiliar de Produção',
    _mareAlta,
    _alimentos,
    'Itajaí',
    _fundamental,
    [_boasPraticas],
  ),
  _vaga(17, 'Pintor Naval', _pontaBrava, _naval, 'Itapema', _fundamental, [
    _pinturaNaval,
  ], lotada: true),
  _vaga(
    18,
    'Ajudante de Motorista',
    _transVale,
    _logistica,
    'Itajaí',
    _medioCursando,
    [],
  ),
  _vaga(
    19,
    'Soldador',
    _forjaAtlantica,
    _metalurgia,
    'Camboriú',
    _fundamental,
    [_soldagem],
  ),
  _vaga(
    20,
    'Montador de Estruturas',
    _metalSul,
    _metalurgia,
    'Navegantes',
    _fundamental,
    [_desenhoTecnico, _alturaNr35, _soldagem],
  ),
  _vaga(
    21,
    'Marceneiro Náutico',
    _pontaBrava,
    _naval,
    'Itapema',
    _fundamental,
    [],
  ),
  _vaga(22, 'Conferente de Carga', _caisNorte, _logistica, 'Itajaí', _medio, [
    _almoxarifado,
  ], lotada: true),
  _vaga(
    23,
    'Servente de Obras',
    _horizonte,
    _construcao,
    'Camboriú',
    _medioCursando,
    [_alvenaria],
  ),
  _vaga(
    24,
    'Camareira',
    _enseadaClara,
    _hotelaria,
    'Balneário Camboriú',
    _medioCursando,
    [],
  ),
  _vaga(
    25,
    'Filetador de Pescados',
    _mareAlta,
    _alimentos,
    'Navegantes',
    _fundamental,
    [_boasPraticas],
  ),
  _vaga(
    26,
    'Mecânico de Manutenção',
    _forjaAtlantica,
    _metalurgia,
    'Camboriú',
    _medio,
    [_mecanicaDiesel, _usinagem, _metrologia],
  ),
  _vaga(
    27,
    'Auxiliar de Pintura',
    _fozAzul,
    _naval,
    'Navegantes',
    _medioCursando,
    [_pinturaNaval, _alturaNr35, _laminacao],
  ),
  _vaga(28, 'Motorista CNH D', _caisNorte, _logistica, 'Navegantes', _medio, [
    _direcaoDefensiva,
    _empilhadeira,
  ]),
  _vaga(
    29,
    'Ajudante de Eletricista',
    _horizonte,
    _construcao,
    'Itapema',
    _medioCursando,
    [_eletrica],
  ),
  _vaga(
    30,
    'Garçom',
    _enseadaClara,
    _hotelaria,
    'Balneário Camboriú',
    _medioCursando,
    [_recepcao, _boasPraticas],
  ),
  _vaga(
    31,
    'Operador de Câmara Fria',
    _mareAlta,
    _alimentos,
    'Itajaí',
    _fundamental,
    [],
  ),
  _vaga(32, 'Inspetor de Solda', _metalSul, _metalurgia, 'Itajaí', _medio, [
    _soldagem,
    _metrologia,
    _desenhoTecnico,
    _alturaNr35,
    _usinagem,
  ]),
  _vaga(33, 'Laminador', _pontaBrava, _naval, 'Itapema', _fundamental, [
    _laminacao,
  ], lotada: true),
  _vaga(
    34,
    'Auxiliar de Logística',
    _transVale,
    _logistica,
    'Itajaí',
    _medioCursando,
    [_almoxarifado],
  ),
  _vaga(
    35,
    'Carpinteiro de Obras',
    _horizonte,
    _construcao,
    'Balneário Camboriú',
    _fundamental,
    [_alvenaria, _marcenariaNautica],
  ),
  _vaga(36, 'Cozinheiro', _enseadaClara, _hotelaria, 'Itapema', _medio, [
    _cozinha,
    _boasPraticas,
  ]),
  _vaga(37, 'Embalador', _mareAlta, _alimentos, 'Navegantes', _fundamental, [
    _boasPraticas,
  ], lotada: true),
  _vaga(
    38,
    'Caldeireiro',
    _forjaAtlantica,
    _metalurgia,
    'Camboriú',
    _fundamental,
    [_soldagem, _desenhoTecnico],
  ),
  _vaga(39, 'Mecânico Naval', _fozAzul, _naval, 'Itajaí', _medio, [
    _mecanicaDiesel,
    _desenhoTecnico,
  ]),
  _vaga(
    40,
    'Repositor de Estoque',
    _caisNorte,
    _logistica,
    'Itajaí',
    _medioCursando,
    [],
  ),
];
