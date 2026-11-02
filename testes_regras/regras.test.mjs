// Regras de segurança do Firestore (LGPD): cada pessoa acessa só os próprios dados.
import { after, before, beforeEach, describe, test } from 'node:test';
import { readFileSync } from 'node:fs';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  deleteDoc,
  doc,
  getDoc,
  serverTimestamp,
  setDoc,
  Timestamp,
  updateDoc,
  writeBatch,
} from 'firebase/firestore';

let ambiente;

const carla = { uid: 'uid-carla', email: 'carla.lima@example.com' };
const bruno = { uid: 'uid-bruno', email: 'bruno.reis@example.com' };

function perfilDe(pessoa, extras = {}) {
  return {
    nome: 'Carla Lima',
    email: pessoa.email,
    cidade: 'Navegantes',
    dataNascimento: Timestamp.fromDate(new Date(2009, 2, 2)),
    autorizacaoResponsavel: true,
    aceitePoliticaEm: Timestamp.now(),
    criadoEm: serverTimestamp(),
    ...extras,
  };
}

function bancoDe(pessoa) {
  return ambiente
    .authenticatedContext(pessoa.uid, { email: pessoa.email })
    .firestore();
}

before(async () => {
  ambiente = await initializeTestEnvironment({
    projectId: 'demo-nexo-future',
    firestore: { rules: readFileSync('../firestore.rules', 'utf8') },
  });
});

beforeEach(async () => {
  await ambiente.clearFirestore();
  // Perfil da Carla já salvo, sem passar pelas regras.
  await ambiente.withSecurityRulesDisabled(async (contexto) => {
    await setDoc(doc(contexto.firestore(), 'jovens', carla.uid), perfilDe(carla));
  });
});

after(async () => {
  await ambiente.cleanup();
});

describe('Perfis de jovens', () => {
  test('quem não entrou no app não lê nenhum perfil', async () => {
    const anonimo = ambiente.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(anonimo, 'jovens', carla.uid)));
  });

  test('o jovem lê o próprio perfil', async () => {
    await assertSucceeds(getDoc(doc(bancoDe(carla), 'jovens', carla.uid)));
  });

  test('o jovem não lê o perfil de outra pessoa', async () => {
    await assertFails(getDoc(doc(bancoDe(bruno), 'jovens', carla.uid)));
  });

  test('o jovem cria o próprio perfil com os campos do cadastro', async () => {
    await assertSucceeds(
      setDoc(doc(bancoDe(bruno), 'jovens', bruno.uid), perfilDe(bruno)),
    );
  });

  test('ninguém cria perfil no lugar de outra pessoa', async () => {
    await assertFails(
      setDoc(doc(bancoDe(bruno), 'jovens', 'uid-outro'), perfilDe(bruno)),
    );
  });

  test('o perfil não aceita campos fora do cadastro, como CPF ou senha', async () => {
    const banco = bancoDe(bruno);
    await assertFails(
      setDoc(doc(banco, 'jovens', bruno.uid), perfilDe(bruno, { cpf: '12345678900' })),
    );
    await assertFails(
      setDoc(doc(banco, 'jovens', bruno.uid), perfilDe(bruno, { senha: 'segredo123' })),
    );
  });

  test('o e-mail do perfil precisa ser o e-mail da conta', async () => {
    await assertFails(
      setDoc(
        doc(bancoDe(bruno), 'jovens', bruno.uid),
        perfilDe(bruno, { email: 'outro@example.com' }),
      ),
    );
  });

  test('o perfil precisa ter nome, cidade, nascimento e aceite da política', async () => {
    const semAceite = perfilDe(bruno);
    delete semAceite.aceitePoliticaEm;
    await assertFails(setDoc(doc(bancoDe(bruno), 'jovens', bruno.uid), semAceite));
  });

  test('o jovem apaga o próprio perfil (direito de exclusão)', async () => {
    await assertSucceeds(deleteDoc(doc(bancoDe(carla), 'jovens', carla.uid)));
  });

  test('o jovem não apaga o perfil de outra pessoa', async () => {
    await assertFails(deleteDoc(doc(bancoDe(bruno), 'jovens', carla.uid)));
  });
});

function empresaDe(pessoa, extras = {}) {
  return {
    nome: 'Estaleiro Foz Azul',
    cnpj: '11222333000181',
    setor: 'Naval',
    recrutador: 'Marcos Pereira',
    email: pessoa.email,
    cidade: 'Itajaí',
    aceitePoliticaEm: Timestamp.now(),
    criadoEm: serverTimestamp(),
    ...extras,
  };
}

describe('Perfis de empresas', () => {
  const marcos = { uid: 'uid-marcos', email: 'rh@fozazul.example.com' };

  test('o recrutador cria o perfil da própria empresa', async () => {
    await assertSucceeds(
      setDoc(doc(bancoDe(marcos), 'empresas', marcos.uid), empresaDe(marcos)),
    );
  });

  test('o recrutador lê o perfil da própria empresa, e outra pessoa não', async () => {
    await assertSucceeds(
      setDoc(doc(bancoDe(marcos), 'empresas', marcos.uid), empresaDe(marcos)),
    );
    await assertSucceeds(getDoc(doc(bancoDe(marcos), 'empresas', marcos.uid)));
    await assertFails(getDoc(doc(bancoDe(bruno), 'empresas', marcos.uid)));
  });

  test('ninguém cria empresa no lugar de outra pessoa', async () => {
    await assertFails(
      setDoc(doc(bancoDe(bruno), 'empresas', marcos.uid), empresaDe(bruno)),
    );
  });

  test('o CNPJ tem exatamente 14 dígitos', async () => {
    const banco = bancoDe(marcos);
    await assertFails(
      setDoc(doc(banco, 'empresas', marcos.uid), empresaDe(marcos, { cnpj: '11.222.333/0001-81' })),
    );
    await assertFails(
      setDoc(doc(banco, 'empresas', marcos.uid), empresaDe(marcos, { cnpj: '123' })),
    );
  });

  test('o perfil da empresa não aceita campos fora do cadastro', async () => {
    await assertFails(
      setDoc(
        doc(bancoDe(marcos), 'empresas', marcos.uid),
        empresaDe(marcos, { senha: 'segredo123' }),
      ),
    );
  });

  test('o e-mail do perfil precisa ser o e-mail da conta', async () => {
    await assertFails(
      setDoc(
        doc(bancoDe(marcos), 'empresas', marcos.uid),
        empresaDe(marcos, { email: 'outro@example.com' }),
      ),
    );
  });

  test('o perfil da empresa precisa do setor', async () => {
    const semSetor = empresaDe(marcos);
    delete semSetor.setor;
    await assertFails(setDoc(doc(bancoDe(marcos), 'empresas', marcos.uid), semSetor));
  });

  test('o perfil precisa do aceite da política', async () => {
    const semAceite = empresaDe(marcos);
    delete semAceite.aceitePoliticaEm;
    await assertFails(setDoc(doc(bancoDe(marcos), 'empresas', marcos.uid), semAceite));
  });
});

function oficinaDe(pessoa, extras = {}) {
  return {
    nome: 'Oficina Escola Mãos do Porto',
    cnpj: '11222333000181',
    gestor: 'Rita Moraes',
    email: pessoa.email,
    cidade: 'Itajaí',
    alvaraNumero: 'AE-2026-0042',
    alvaraValidade: Timestamp.fromDate(new Date(2027, 2, 1)),
    aceitePoliticaEm: Timestamp.now(),
    criadoEm: serverTimestamp(),
    ...extras,
  };
}

describe('Perfis de oficinas', () => {
  const rita = { uid: 'uid-rita', email: 'contato@maosdoporto.example.com' };

  test('o gestor cria o perfil da própria oficina com o alvará', async () => {
    await assertSucceeds(
      setDoc(doc(bancoDe(rita), 'oficinas', rita.uid), oficinaDe(rita)),
    );
  });

  test('a oficina pode se cadastrar sem o alvará', async () => {
    const semAlvara = oficinaDe(rita);
    delete semAlvara.alvaraNumero;
    delete semAlvara.alvaraValidade;
    await assertSucceeds(setDoc(doc(bancoDe(rita), 'oficinas', rita.uid), semAlvara));
  });

  test('o alvará vem completo: número e validade juntos', async () => {
    const semValidade = oficinaDe(rita);
    delete semValidade.alvaraValidade;
    await assertFails(setDoc(doc(bancoDe(rita), 'oficinas', rita.uid), semValidade));
  });

  test('o gestor lê o perfil da própria oficina, e outra pessoa não', async () => {
    await assertSucceeds(
      setDoc(doc(bancoDe(rita), 'oficinas', rita.uid), oficinaDe(rita)),
    );
    await assertSucceeds(getDoc(doc(bancoDe(rita), 'oficinas', rita.uid)));
    await assertFails(getDoc(doc(bancoDe(bruno), 'oficinas', rita.uid)));
  });

  test('ninguém cria oficina no lugar de outra pessoa', async () => {
    await assertFails(
      setDoc(doc(bancoDe(bruno), 'oficinas', rita.uid), oficinaDe(bruno)),
    );
  });

  test('o CNPJ tem exatamente 14 dígitos e o e-mail é o da conta', async () => {
    const banco = bancoDe(rita);
    await assertFails(
      setDoc(doc(banco, 'oficinas', rita.uid), oficinaDe(rita, { cnpj: '123' })),
    );
    await assertFails(
      setDoc(doc(banco, 'oficinas', rita.uid), oficinaDe(rita, { email: 'outro@example.com' })),
    );
  });

  test('o perfil da oficina não aceita campos fora do cadastro', async () => {
    await assertFails(
      setDoc(doc(bancoDe(rita), 'oficinas', rita.uid), oficinaDe(rita, { senha: 'segredo123' })),
    );
  });
});

// Vagas e cursos: leitura pública (sem dados pessoais); só quem confirmou o
// e-mail (RN0001) publica, e cada um mexe só no que é seu.
const marcos = { uid: 'uid-marcos', email: 'rh@fozazul.example.com' };
const paula = { uid: 'uid-paula', email: 'rh@transvale.example.com' };
const rita = { uid: 'uid-rita', email: 'contato@maosdoporto.example.com' };
const davi = { uid: 'uid-davi', email: 'contato@centrotecnico.example.com' };

function contaConfirmada(pessoa, confirmada = true) {
  return ambiente
    .authenticatedContext(pessoa.uid, {
      email: pessoa.email,
      email_verified: confirmada,
    })
    .firestore();
}

function vagaDe(pessoa, extras = {}) {
  return {
    titulo: 'Pintor(a) naval',
    empresa: 'Estaleiro Foz Azul',
    empresaId: pessoa.uid,
    area: 'Naval',
    cidade: 'Itajaí',
    qualificacao: 'Preparo de superfície e pintura de cascos.',
    posicoes: 3,
    candidaturas: 0,
    situacao: 'aberta',
    cursos: [],
    criadoEm: serverTimestamp(),
    ...extras,
  };
}

const cursoVinculado = {
  id: 'curso-pintura',
  nome: 'Pintura naval',
  oficina: 'Oficina Escola Mãos do Porto',
  cargaHoraria: 32,
};

async function semRegras(acao) {
  await ambiente.withSecurityRulesDisabled(async (contexto) => {
    await acao(contexto.firestore());
  });
}

async function prepararEmpresas() {
  await semRegras(async (banco) => {
    await setDoc(doc(banco, 'empresas', marcos.uid), empresaDe(marcos));
    await setDoc(doc(banco, 'empresas', paula.uid), empresaDe(paula));
  });
}

async function prepararVaga() {
  await semRegras(async (banco) => {
    await setDoc(doc(banco, 'vagas', 'vaga-pintor'), {
      ...vagaDe(marcos),
      criadoEm: Timestamp.now(),
    });
  });
}

describe('Vagas', () => {
  beforeEach(prepararEmpresas);

  test('o visitante, sem conta, lê as vagas (RN0007)', async () => {
    await prepararVaga();
    const anonimo = ambiente.unauthenticatedContext().firestore();
    await assertSucceeds(getDoc(doc(anonimo, 'vagas', 'vaga-pintor')));
  });

  test('a empresa com e-mail confirmado publica vaga aberta e sem cursos', async () => {
    await assertSucceeds(
      setDoc(doc(contaConfirmada(marcos), 'vagas', 'nova'), vagaDe(marcos)),
    );
  });

  test('com e-mail não confirmado, a empresa não publica (RN0001)', async () => {
    await assertFails(
      setDoc(doc(contaConfirmada(marcos, false), 'vagas', 'nova'), vagaDe(marcos)),
    );
  });

  test('quem não tem perfil de empresa não publica vaga', async () => {
    await assertFails(
      setDoc(doc(contaConfirmada(rita), 'vagas', 'nova'), vagaDe(rita)),
    );
  });

  test('ninguém publica vaga em nome de outra empresa', async () => {
    await assertFails(
      setDoc(doc(contaConfirmada(paula), 'vagas', 'nova'), vagaDe(marcos)),
    );
  });

  test('a vaga nasce aberta, sem cursos e sem candidaturas', async () => {
    const banco = contaConfirmada(marcos);
    await assertFails(
      setDoc(doc(banco, 'vagas', 'nova'), vagaDe(marcos, { candidaturas: 1 })),
    );
    await assertFails(
      setDoc(doc(banco, 'vagas', 'nova'), vagaDe(marcos, { situacao: 'aguardandoIngresso' })),
    );
    await assertFails(
      setDoc(doc(banco, 'vagas', 'nova'), vagaDe(marcos, { cursos: [cursoVinculado] })),
    );
  });

  test('a vaga não aceita campos fora do cadastro', async () => {
    await assertFails(
      setDoc(
        doc(contaConfirmada(marcos), 'vagas', 'nova'),
        vagaDe(marcos, { emailRecrutador: 'rh@fozazul.example.com' }),
      ),
    );
  });

  test('a vaga precisa de cargo, área, cidade da AMFRI e posições de 1 a 100', async () => {
    const banco = contaConfirmada(marcos);
    const semCargo = vagaDe(marcos);
    delete semCargo.titulo;
    await assertFails(setDoc(doc(banco, 'vagas', 'nova'), semCargo));
    await assertFails(setDoc(doc(banco, 'vagas', 'nova'), vagaDe(marcos, { titulo: '' })));
    await assertFails(setDoc(doc(banco, 'vagas', 'nova'), vagaDe(marcos, { area: 'Astronomia' })));
    await assertFails(setDoc(doc(banco, 'vagas', 'nova'), vagaDe(marcos, { cidade: 'Curitiba' })));
    await assertFails(setDoc(doc(banco, 'vagas', 'nova'), vagaDe(marcos, { posicoes: 0 })));
    await assertFails(setDoc(doc(banco, 'vagas', 'nova'), vagaDe(marcos, { posicoes: 101 })));
  });

  test('a empresa dona vincula até 5 cursos, e a vaga passa a aceitar candidaturas', async () => {
    await prepararVaga();
    await assertSucceeds(
      updateDoc(doc(contaConfirmada(marcos), 'vagas', 'vaga-pintor'), {
        cursos: [cursoVinculado],
        situacao: 'aguardandoIngresso',
      }),
    );
  });

  test('o 6º curso não entra na vaga (RN0006)', async () => {
    await prepararVaga();
    const seis = [1, 2, 3, 4, 5, 6].map((i) => ({ ...cursoVinculado, id: `curso-${i}` }));
    await assertFails(
      updateDoc(doc(contaConfirmada(marcos), 'vagas', 'vaga-pintor'), {
        cursos: seis,
        situacao: 'aguardandoIngresso',
      }),
    );
  });

  test('sem curso vinculado, a vaga não passa a aceitar candidaturas (RF0007)', async () => {
    await prepararVaga();
    await assertFails(
      updateDoc(doc(contaConfirmada(marcos), 'vagas', 'vaga-pintor'), {
        situacao: 'aguardandoIngresso',
      }),
    );
  });

  test('outra empresa não altera nem apaga a vaga', async () => {
    await prepararVaga();
    const banco = contaConfirmada(paula);
    await assertFails(
      updateDoc(doc(banco, 'vagas', 'vaga-pintor'), { titulo: 'Outra coisa' }),
    );
    await assertFails(deleteDoc(doc(banco, 'vagas', 'vaga-pintor')));
  });

  test('a empresa dona não passa a vaga para outra empresa', async () => {
    await prepararVaga();
    await assertFails(
      updateDoc(doc(contaConfirmada(marcos), 'vagas', 'vaga-pintor'), {
        empresaId: paula.uid,
      }),
    );
  });

  test('a empresa dona apaga a própria vaga', async () => {
    await prepararVaga();
    await assertSucceeds(deleteDoc(doc(contaConfirmada(marcos), 'vagas', 'vaga-pintor')));
  });
});

function cursoDe(pessoa, extras = {}) {
  return {
    nome: 'Pintura naval',
    area: 'Naval',
    cargaHoraria: 32,
    vagasTurma: 15,
    descricao: 'Preparo de superfície e acabamento.',
    vagaId: 'vaga-pintor',
    vagaTitulo: 'Pintor(a) naval',
    empresaId: marcos.uid,
    empresa: 'Estaleiro Foz Azul',
    oficinaId: pessoa.uid,
    oficina: 'Oficina Escola Mãos do Porto',
    situacao: 'emAnalise',
    criadoEm: serverTimestamp(),
    ...extras,
  };
}

const anteontem = () => Timestamp.fromMillis(Date.now() - 2 * 24 * 60 * 60 * 1000);

async function prepararOficinas() {
  await semRegras(async (banco) => {
    // Rita tem alvará em dia; Davi se cadastrou sem alvará.
    await setDoc(doc(banco, 'oficinas', rita.uid), oficinaDe(rita));
    const semAlvara = oficinaDe(davi);
    delete semAlvara.alvaraNumero;
    delete semAlvara.alvaraValidade;
    await setDoc(doc(banco, 'oficinas', davi.uid), semAlvara);
  });
}

async function prepararCurso(extras = {}) {
  await semRegras(async (banco) => {
    await setDoc(doc(banco, 'cursos', 'curso-pintura'), {
      ...cursoDe(rita),
      criadoEm: Timestamp.now(),
      ...extras,
    });
  });
}

describe('Cursos', () => {
  beforeEach(async () => {
    await prepararEmpresas();
    await prepararOficinas();
    await prepararVaga();
  });

  test('o visitante lê o curso publicado (RN0007)', async () => {
    await prepararCurso();
    const anonimo = ambiente.unauthenticatedContext().firestore();
    await assertSucceeds(getDoc(doc(anonimo, 'cursos', 'curso-pintura')));
  });

  test('o rascunho só a oficina dona lê', async () => {
    await prepararCurso({ situacao: 'rascunho' });
    const anonimo = ambiente.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(anonimo, 'cursos', 'curso-pintura')));
    await assertSucceeds(getDoc(doc(contaConfirmada(rita), 'cursos', 'curso-pintura')));
  });

  test('a oficina com alvará em dia publica curso para a vaga (RF0005)', async () => {
    await assertSucceeds(
      setDoc(doc(contaConfirmada(rita), 'cursos', 'novo'), cursoDe(rita)),
    );
  });

  test('a oficina sem alvará não publica curso (RN0003)', async () => {
    await assertFails(
      setDoc(doc(contaConfirmada(davi), 'cursos', 'novo'), cursoDe(davi)),
    );
  });

  test('a oficina com alvará vencido não publica curso (RN0003)', async () => {
    await semRegras(async (banco) => {
      await setDoc(
        doc(banco, 'oficinas', rita.uid),
        oficinaDe(rita, { alvaraValidade: anteontem() }),
      );
    });
    await assertFails(
      setDoc(doc(contaConfirmada(rita), 'cursos', 'novo'), cursoDe(rita)),
    );
  });

  test('sem alvará, a oficina salva o curso como rascunho', async () => {
    await assertSucceeds(
      setDoc(
        doc(contaConfirmada(davi), 'cursos', 'novo'),
        cursoDe(davi, { situacao: 'rascunho' }),
      ),
    );
  });

  test('com e-mail não confirmado, a oficina não publica (RN0001)', async () => {
    await assertFails(
      setDoc(doc(contaConfirmada(rita, false), 'cursos', 'novo'), cursoDe(rita)),
    );
  });

  test('ninguém publica curso em nome de outra oficina', async () => {
    await assertFails(
      setDoc(doc(contaConfirmada(davi), 'cursos', 'novo'), cursoDe(rita)),
    );
  });

  test('o curso não nasce aprovado', async () => {
    await assertFails(
      setDoc(
        doc(contaConfirmada(rita), 'cursos', 'novo'),
        cursoDe(rita, { situacao: 'aprovado' }),
      ),
    );
  });

  test('o curso aponta para uma vaga que existe, com a empresa certa', async () => {
    const banco = contaConfirmada(rita);
    await assertFails(
      setDoc(doc(banco, 'cursos', 'novo'), cursoDe(rita, { vagaId: 'nao-existe' })),
    );
    await assertFails(
      setDoc(doc(banco, 'cursos', 'novo'), cursoDe(rita, { empresaId: paula.uid })),
    );
  });

  test('o curso não aceita campos fora do cadastro', async () => {
    await assertFails(
      setDoc(
        doc(contaConfirmada(rita), 'cursos', 'novo'),
        cursoDe(rita, { telefoneProfessor: '47999999999' }),
      ),
    );
  });

  test('carga horária e vagas na turma têm limites', async () => {
    const banco = contaConfirmada(rita);
    await assertFails(setDoc(doc(banco, 'cursos', 'novo'), cursoDe(rita, { cargaHoraria: 0 })));
    await assertFails(setDoc(doc(banco, 'cursos', 'novo'), cursoDe(rita, { vagasTurma: 101 })));
  });

  test('a oficina publica o próprio rascunho quando tem alvará', async () => {
    await prepararCurso({ situacao: 'rascunho' });
    await assertSucceeds(
      setDoc(doc(contaConfirmada(rita), 'cursos', 'curso-pintura'), cursoDe(rita)),
    );
  });

  test('a oficina não aprova o próprio curso', async () => {
    await prepararCurso();
    await assertFails(
      updateDoc(doc(contaConfirmada(rita), 'cursos', 'curso-pintura'), {
        situacao: 'aprovado',
      }),
    );
  });

  test('a empresa dona da vaga aprova ou recusa o curso (RF0007)', async () => {
    await prepararCurso();
    await assertSucceeds(
      updateDoc(doc(contaConfirmada(marcos), 'cursos', 'curso-pintura'), {
        situacao: 'aprovado',
      }),
    );
    await prepararCurso();
    await assertSucceeds(
      updateDoc(doc(contaConfirmada(marcos), 'cursos', 'curso-pintura'), {
        situacao: 'recusado',
      }),
    );
  });

  test('outra empresa não aprova curso de vaga que não é dela', async () => {
    await prepararCurso();
    await assertFails(
      updateDoc(doc(contaConfirmada(paula), 'cursos', 'curso-pintura'), {
        situacao: 'aprovado',
      }),
    );
  });

  test('ao aprovar, a empresa muda só a situação do curso', async () => {
    await prepararCurso();
    await assertFails(
      updateDoc(doc(contaConfirmada(marcos), 'cursos', 'curso-pintura'), {
        situacao: 'aprovado',
        cargaHoraria: 8,
      }),
    );
  });

  test('a empresa não aprova rascunho nem curso já decidido', async () => {
    await prepararCurso({ situacao: 'rascunho' });
    await assertFails(
      updateDoc(doc(contaConfirmada(marcos), 'cursos', 'curso-pintura'), {
        situacao: 'aprovado',
      }),
    );
    await prepararCurso({ situacao: 'recusado' });
    await assertFails(
      updateDoc(doc(contaConfirmada(marcos), 'cursos', 'curso-pintura'), {
        situacao: 'aprovado',
      }),
    );
  });

  test('com e-mail não confirmado, a empresa não decide (RN0001)', async () => {
    await prepararCurso();
    await assertFails(
      updateDoc(doc(contaConfirmada(marcos, false), 'cursos', 'curso-pintura'), {
        situacao: 'aprovado',
      }),
    );
  });
});

// Candidaturas: cada jovem guarda a própria lista (RN0005: no máximo 5) e a
// vaga publicada conta as candidaturas; ao completar as posições, lota.
async function prepararVagaAceitando(extras = {}) {
  await semRegras(async (banco) => {
    await setDoc(doc(banco, 'vagas', 'vaga-pintor'), {
      ...vagaDe(marcos),
      situacao: 'aguardandoIngresso',
      cursos: [cursoVinculado],
      posicoes: 2,
      criadoEm: Timestamp.now(),
      ...extras,
    });
  });
}

async function prepararLista(pessoa, vagas) {
  await semRegras(async (banco) => {
    await setDoc(doc(banco, 'candidaturas', pessoa.uid), {
      vagas,
      atualizadoEm: Timestamp.now(),
    });
  });
}

function listaDe(vagas) {
  return { vagas, atualizadoEm: serverTimestamp() };
}

// Grava a lista e a contagem da vaga juntas, como o app faz.
function candidatarEm(banco, pessoa, vagas, mudancaNaVaga) {
  const lote = writeBatch(banco);
  lote.set(doc(banco, 'candidaturas', pessoa.uid), listaDe(vagas));
  lote.update(doc(banco, 'vagas', 'vaga-pintor'), mudancaNaVaga);
  return lote.commit();
}

describe('Candidaturas', () => {
  beforeEach(async () => {
    await prepararEmpresas();
    await prepararVagaAceitando();
  });

  test('o jovem grava e lê a própria lista de candidaturas', async () => {
    const banco = contaConfirmada(carla);
    await assertSucceeds(
      setDoc(doc(banco, 'candidaturas', carla.uid), listaDe(['vaga-01'])),
    );
    await assertSucceeds(getDoc(doc(banco, 'candidaturas', carla.uid)));
  });

  test('a lista tem no máximo 5 vagas, sem repetir (RN0005)', async () => {
    const banco = contaConfirmada(carla);
    await assertSucceeds(
      setDoc(doc(banco, 'candidaturas', carla.uid), listaDe(['a', 'b', 'c', 'd', 'e'])),
    );
    await assertFails(
      setDoc(doc(banco, 'candidaturas', carla.uid), listaDe(['a', 'b', 'c', 'd', 'e', 'f'])),
    );
    await assertFails(
      setDoc(doc(banco, 'candidaturas', carla.uid), listaDe(['a', 'a'])),
    );
  });

  test('ninguém lê nem grava a lista de outra pessoa', async () => {
    await prepararLista(carla, ['vaga-01']);
    const banco = contaConfirmada(bruno);
    await assertFails(getDoc(doc(banco, 'candidaturas', carla.uid)));
    await assertFails(
      setDoc(doc(banco, 'candidaturas', carla.uid), listaDe([])),
    );
  });

  test('só quem tem perfil de jovem e confirmou o e-mail se candidata (RN0001)', async () => {
    await assertFails(
      setDoc(
        doc(contaConfirmada(carla, false), 'candidaturas', carla.uid),
        listaDe(['vaga-01']),
      ),
    );
    await assertFails(
      setDoc(doc(contaConfirmada(marcos), 'candidaturas', marcos.uid), listaDe(['vaga-01'])),
    );
  });

  test('a lista não aceita campos fora do combinado', async () => {
    await assertFails(
      setDoc(doc(contaConfirmada(carla), 'candidaturas', carla.uid), {
        ...listaDe(['vaga-01']),
        telefone: '47999999999',
      }),
    );
  });

  test('a candidatura conta na vaga junto com a lista do jovem', async () => {
    await assertSucceeds(
      candidatarEm(contaConfirmada(carla), carla, ['vaga-pintor'], { candidaturas: 1 }),
    );
  });

  test('a candidatura que completa as posições deixa a vaga lotada', async () => {
    await prepararVagaAceitando({ posicoes: 1 });
    const banco = contaConfirmada(carla);
    await assertFails(
      candidatarEm(banco, carla, ['vaga-pintor'], { candidaturas: 1 }),
    );
    await assertSucceeds(
      candidatarEm(banco, carla, ['vaga-pintor'], {
        candidaturas: 1,
        situacao: 'lotada',
      }),
    );
  });

  test('o jovem não aumenta a contagem sem pôr a vaga na própria lista', async () => {
    await assertFails(
      updateDoc(doc(contaConfirmada(carla), 'vagas', 'vaga-pintor'), { candidaturas: 1 }),
    );
  });

  test('a contagem sobe de uma em uma', async () => {
    await assertFails(
      candidatarEm(contaConfirmada(carla), carla, ['vaga-pintor'], { candidaturas: 2 }),
    );
  });

  test('o jovem não muda outros campos da vaga', async () => {
    await assertFails(
      candidatarEm(contaConfirmada(carla), carla, ['vaga-pintor'], {
        candidaturas: 1,
        titulo: 'Outra coisa',
      }),
    );
  });

  test('vaga sem curso aprovado ou lotada não recebe candidatura (RF0007)', async () => {
    await prepararVagaAceitando({ situacao: 'aberta', cursos: [] });
    await assertFails(
      candidatarEm(contaConfirmada(carla), carla, ['vaga-pintor'], { candidaturas: 1 }),
    );
    await prepararVagaAceitando({ situacao: 'lotada', candidaturas: 2 });
    await assertFails(
      candidatarEm(contaConfirmada(carla), carla, ['vaga-pintor'], {
        candidaturas: 3,
        situacao: 'lotada',
      }),
    );
  });

  test('ao desistir, a contagem desce e a vaga lotada volta a aceitar', async () => {
    await prepararVagaAceitando({ situacao: 'lotada', candidaturas: 2 });
    await prepararLista(carla, ['vaga-pintor']);
    await assertSucceeds(
      candidatarEm(contaConfirmada(carla), carla, [], {
        candidaturas: 1,
        situacao: 'aguardandoIngresso',
      }),
    );
  });

  test('quem não se candidatou não desconta a vaga', async () => {
    await prepararVagaAceitando({ candidaturas: 1 });
    await assertFails(
      candidatarEm(contaConfirmada(carla), carla, [], { candidaturas: 0 }),
    );
  });

  test('a empresa não mexe na contagem de candidaturas', async () => {
    await assertFails(
      updateDoc(doc(contaConfirmada(marcos), 'vagas', 'vaga-pintor'), { candidaturas: 1 }),
    );
  });
});

describe('Demais coleções', () => {
  test('coleções que o app não usa ficam fechadas', async () => {
    const banco = bancoDe(carla);
    await assertFails(getDoc(doc(banco, 'qualquer', 'documento')));
    await assertFails(setDoc(doc(banco, 'qualquer', 'documento'), { a: 1 }));
  });
});
