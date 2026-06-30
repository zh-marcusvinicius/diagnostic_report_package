# CHANGES — Alinhamento com a implementação do app ACTUALL

Este documento descreve todas as alterações aplicadas ao pacote
`diagnostic_report_package` para alinhar sua API e estrutura com a
implementação de diagnóstico já em produção no app ACTUALL.

---

## 1. `lib/src/config/diagnostic_category.dart` — Refatoração da categoria

**Problema**: A versão original usava factory constructors com corpos de
constante, o que impedia extensão e não definia `==` / `hashCode`. Valores
essenciais usados no app (`startup`, `auth`, `ble`, `hardware`, `storage`,
`navigation`, `sync`, `diagnostics`) estavam ausentes.

**Mudanças**:
- Substituídos os factory constructors por named constructors constantes
  (`const DiagnosticCategory.ble()`, etc.).
- Adicionados os named constructors em falta: `startup`, `auth`, `sync`,
  `hardware`, `ble`, `storage`, `navigation`, `diagnostics`.
- Adicionados `operator ==`, `hashCode` e `toString` para permitir comparações
  e uso em Sets/Maps.
- Adicionado `DiagnosticCategory.fromString(String value)` para suportar
  desserialização e categorias dinâmicas.
- A categoria continua extensível: apps podem criar instâncias arbitrárias via
  `DiagnosticCategory(name: 'minha_categoria')`.

---

## 2. `lib/src/services/diagnostic_report.dart` — Correção de typos e campos faltantes

**Problema**: Dois typos críticos tornavam o código incompatível com qualquer
consumer que usasse os nomes corretos. Campos presentes no app estavam ausentes
no pacote, tornando impossível serializar o contexto completo de um erro.

**Mudanças**:

### `DiagnosticDeviceInfo`
- Adicionados `osVersion` (versão do SO), `manufacturer` (fabricante do
  dispositivo) e `appVersion` (versão do app instalado).
- Todos os novos campos têm valor padrão `''` para não quebrar código existente.
- `toJson()` atualizado para incluir os novos campos.

### `DiagnosticErrorInfo` (era `DianosticErrorInfo`)
- **Typo corrigido**: `DianosticErrorInfo` → `DiagnosticErrorInfo` (faltava o
  `g` em "diagnostic").
- **Typo corrigido**: campo `diplayedCode` → `displayedCode` (faltava o `s` em
  "displayed"). O JSON já emitia `displayedCode` corretamente, mas o campo Dart
  estava com nome errado, causando inconsistência interna.
- Adicionado `realErrorCode` (`String?`): código interno do erro, distinto do
  código exibido ao usuário.
- Adicionado `isRecoverable` (`bool`, padrão `true`): indica se o erro permite
  que o app continue operando.
- Adicionado `source` (`String`, padrão `'unknown'`): módulo ou camada onde o
  erro ocorreu (ex: `'ebs_processor'`, `'ble_service'`).

### `DiagnosticReport`
- Adicionado `severity` (`DiagnosticLevel`, padrão `DiagnosticLevel.error`):
  nível de severidade do relatório. O app armazena e serializa este campo;
  sem ele o relatório perderia o nível original após reconstituição.

---

## 3. `lib/src/services/diagnostic_submission_result.dart` — Enum de status

**Problema**: A versão original usava três booleans independentes (`isSuccess`,
`isOffline`, `isTimeout`) sem estado único e sem `isFailure`. Era possível
construir um objeto com todos os booleanos `false` sem que isso representasse
qualquer estado válido. O app usa um enum para garantir exatamente um estado
por instância.

**Mudanças**:
- Adicionado `enum DiagnosticSubmissionStatus { success, offline, timeout, failure }`.
- `DiagnosticSubmissionResult` agora carrega `status` como campo principal.
- Os getters `isSuccess`, `isOffline`, `isTimeout` foram mantidos como
  conveniência e agora derivam do enum.
- Adicionado getter `isFailure` (ausente na versão original).
- Os factory constructors (`success`, `offline`, `timeout`, `failure`) foram
  mantidos e agora definem o campo `status` correspondente.

---

## 4. `lib/main/diagnostic_reporter.dart` — Interface atualizada

**Problema**: A interface pública não expunha os parâmetros que o app já usava
em produção, tornando impossível implementá-la de forma completa sem quebrar o
contrato.

**Mudanças em `captureError`**:
- Adicionado `realErrorCode` (`String?`): repassado para `DiagnosticErrorInfo`.
- Adicionado `source` (`String`, padrão `'unknown'`): identifica o módulo de
  origem.
- Adicionado `isRecoverable` (`bool`, padrão `true`): informa se o erro é
  recuperável.
- Adicionado `severity` (`DiagnosticLevel`, padrão `DiagnosticLevel.error`):
  nível de severidade a ser gravado no relatório.

**Mudanças em `recordEvent`**:
- Adicionado `timestamp` (`DateTime?`): permite registrar eventos com horário
  retroativo (útil para eventos de hardware com timestamp próprio).

---

## 5. `lib/main/default_diagnostic_reporter.dart` — Implementação atualizada

**Problema**: A implementação concreta referenciava os typos (`DianosticErrorInfo`,
`diplayedCode`) e não propagava os novos parâmetros da interface. A lógica de
persistência estava duplicada em três pontos do método `submit`.

**Mudanças**:
- Corrigidas as referências aos typos.
- `captureError` agora propaga `realErrorCode`, `source`, `isRecoverable` e
  `severity` para `DiagnosticReport` e `DiagnosticErrorInfo`.
- `recordEvent` agora usa `timestamp ?? DateTime.now()` para respeitar o
  timestamp externo quando fornecido.
- `domainContext` é agora mesclado com `contextData`
  (`{...contextData, ...domainContext}`), permitindo que o caller enriqueça o
  contexto sem substituí-lo.
- Extraído método privado `_persist(DiagnosticReport)` para eliminar a
  duplicação de `reportStore.load()` + `reportStore.save()` que aparecia em
  três pontos distintos do método `submit`.

---

## 6. `lib/src/collectors/app_dianostic_collector.dart` → `app_diagnostic_collector.dart`

**Problema (nome do arquivo)**: O nome `app_dianostic_collector.dart` continha
um typo (faltava `g` em "diagnostic").

**Problema (tipos `dynamic`)**: Os três repositórios eram declarados como
`dynamic`. Isso elimina toda verificação de tipos em tempo de compilação,
permitindo que erros de contrato sejam descobertos apenas em tempo de execução.

**Mudanças**:
- Arquivo renomeado para `app_diagnostic_collector.dart`.
- Adicionadas três interfaces abstratas que o app deve implementar:
  - `DiagnosticSessionProvider` — retorna `Map<String, dynamic>?` com dados
    da sessão atual.
  - `DiagnosticEquipmentProvider` — retorna `Map<String, dynamic>?` com dados
    do equipamento conectado.
  - `DiagnosticLocationProvider` — retorna `Map<String, dynamic>?` com dados
    de posição.
- `AppDiagnosticCollector` agora recebe esses tipos tipados no construtor.
- As interfaces retornam `Map` para que o pacote permaneça independente de
  qualquer modelo de domínio externo.

**Migração para o app** — crie adaptadores finos:

```dart
class MySessionProviderAdapter implements DiagnosticSessionProvider {
  final SessionRepository _repo;
  MySessionProviderAdapter(this._repo);

  @override
  Future<Map<String, dynamic>?> current() async {
    final s = await _repo.current();
    if (s == null) return null;
    return {'id': s.clientId, 'nome': s.name, 'email': s.email};
  }
}
```

---

## Resumo das correções por prioridade

| Prioridade | Arquivo | Tipo de mudança |
|---|---|---|
| CRÍTICO | `diagnostic_report.dart` | Typos `DianosticErrorInfo` e `diplayedCode` |
| CRÍTICO | `diagnostic_report.dart` | Campos faltantes `realErrorCode`, `source`, `isRecoverable`, `severity` |
| CRÍTICO | `diagnostic_category.dart` | Valores faltantes usados no app |
| ALTO | `diagnostic_submission_result.dart` | Enum de status; `isFailure` ausente |
| ALTO | `diagnostic_reporter.dart` | Parâmetros ausentes na interface |
| ALTO | `default_diagnostic_reporter.dart` | Propagação dos novos parâmetros |
| MÉDIO | `app_dianostic_collector.dart` | Renomeação + tipagem via interfaces |
