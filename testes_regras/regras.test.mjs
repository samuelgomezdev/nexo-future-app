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

  test('o perfil precisa do aceite da política', async () => {
    const semAceite = empresaDe(marcos);
    delete semAceite.aceitePoliticaEm;
    await assertFails(setDoc(doc(bancoDe(marcos), 'empresas', marcos.uid), semAceite));
  });
});

describe('Demais coleções', () => {
  test('coleções que o app não usa ficam fechadas', async () => {
    const banco = bancoDe(carla);
    await assertFails(getDoc(doc(banco, 'qualquer', 'documento')));
    await assertFails(setDoc(doc(banco, 'qualquer', 'documento'), { a: 1 }));
  });
});
