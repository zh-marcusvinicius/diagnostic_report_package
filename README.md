# Diagnostic Report Package

Um pacote de diagnósticos focado em rastreabilidade e monitoramento de erros. Ele funciona como um "reporter" que escuta as ações do usuário ao longo da navegação no aplicativo e armazena esse histórico em memória. Quando um erro acontece, o pacote captura o erro e envia automaticamente um relatório contendo a trilha de ações realizadas (logs), detalhes do dispositivo e contexto adicional, facilitando a identificação e correção da falha.

---

## Instalação

Adicione o pacote como dependência no `pubspec.yaml` do seu projeto Flutter:

**Via Git:**

```yaml
dependencies:
  diagnostic_report_package:
    git:
      url: https://github.com/zh-marcusvinicius/diagnostic_report_package.git
      ref: main
```

Depois rode:

```bash
flutter pub get
```

E importe onde precisar:

```dart
import 'package:diagnostic_report_package/diagnostic_report_package.dart';
```

---

## Visão Geral das Principais Classes

O pacote possui uma arquitetura baseada em interfaces para facilitar a injeção de dependências e a customização conforme as necessidades do seu app.

- **`DiagnosticReporter` / `DefaultDiagnosticReporter`**: A interface e a implementação principal. É a classe central que você irá instanciar no seu app para gravar eventos, capturar erros e enviar os relatórios.
- **`DiagnosticEvent`**: Representa uma ação do usuário ou um evento de sistema ocorrido no app. Cada evento possui uma categoria e um nível de severidade.
- **`DiagnosticCategory` & `DiagnosticLevel`**: Usados para classificar os eventos (`ui`, `network`, `business`, etc.) e definir a gravidade (`info`, `warning`, `error`, etc.).
- **`DiagnosticReport`**: O objeto final que consolida as informações do dispositivo, o erro ocorrido, o contexto dinâmico do app e a lista dos últimos eventos antes da falha.
- **`DiagnosticContextCollector`**: Interface para coletar o contexto do app no momento do erro (ex: usuário logado, equipamento, localização). Há um exemplo de implementação: `AppDiagnosticCollector`.
- **Interfaces de Dependência**:
  - `DiagnosticEventRepository`: Para armazenamento temporário dos eventos (já inclui a implementação `InMemoryDiagnosticEventRepository`).
  - `DiagnosticConnectivity`: Para checar o status de conexão (online/offline).
  - `DiagnosticTransport`: Para realizar o envio do relatório final a um servidor/backend.
  - `DiagnosticReportStore`: Para salvar relatórios localmente quando não houver conexão, permitindo reenvio futuro.

## Inicialização

Para utilizar o `DiagnosticReporter`, primeiro você precisa implementar algumas interfaces requeridas pelo pacote (transporte de dados, conectividade e armazenamento local).

### Passo 1: Implementar as Dependências

```dart
// 1. Implemente a verificação de conectividade
class MyConnectivity implements DiagnosticConnectivity {
  @override
  Future<bool> get isOnline async {
    // Retorne se o app possui conexão com a internet
    return true; 
  }
}

// 2. Implemente o meio de envio para o servidor
class MyTransport implements DiagnosticTransport {
  @override
  Future<DiagnosticTransportResponse> send(DiagnosticSubmissionEnvelope envelope) async {
    // Código para fazer o POST HTTP enviando o "envelope.base64Content"
    return DiagnosticTransportResponse(statusCode: 200, remoteId: '123');
  }
}

// 3. Implemente o armazenamento local para salvar em caso de offline
class MyReportStore implements DiagnosticReportStore {
  @override
  Future<List<DiagnosticReport>> load() async { /* ler relatórios offline */ return []; }
  
  @override
  Future<void> save(List<DiagnosticReport> reports) async { /* salvar offline */ }
  
  @override
  Future<void> clear() async { /* limpar offline */ }
}
```

### Passo 2: Instanciar o Reporter

Recomenda-se criar e disponibilizar essa instância globalmente no seu app (usando um Provider, GetIt, Riverpod, etc.).

```dart
final diagnosticReporter = DefaultDiagnosticReporter(
  deviceInfo: const DiagnosticDeviceInfo(
    model: 'Pixel 7',
    os: 'Android',
    osVersion: '14',
    manufacturer: 'Google',
    appVersion: '1.2.0',
  ),
  connectivity: MyConnectivity(),
  transport: MyTransport(),
  reportStore: MyReportStore(),
  // AppDiagnosticCollector recebe providers tipados — implemente as interfaces
  // DiagnosticSessionProvider, DiagnosticEquipmentProvider e DiagnosticLocationProvider
  // retornando Map<String, dynamic>? com os dados do seu domínio.
  collector: AppDiagnosticCollector(
    sessionProvider: MySessionProvider(),
    equipmentProvider: MyEquipmentProvider(),
    locationProvider: MyLocationProvider(),
  ),
  // Opcional: injete sua própria implementação de repositório de eventos,
  // ou o padrão InMemoryDiagnosticEventRepository() será usado automaticamente.
);
```

## Como Aplicar no Código

Uma vez instanciado, o reporter deve ser chamado ao longo do fluxo do usuário.

### 1. Registrando Ações e Navegações

Em locais importantes (ex: toques em botões, aberturas de tela, chamadas de rede), registre eventos. Isso montará a "trilha" que será enviada se der erro.

```dart
// Ao clicar em um botão de login:
diagnosticReporter.recordEvent(
  category: const DiagnosticCategory.ui(),
  level: DiagnosticLevel.info,
  message: 'Usuário clicou no botão de Login',
  metadata: {'metodo': 'biometria'}, // Opcional
);

// Ao finalizar uma chamada de rede:
diagnosticReporter.recordEvent(
  category: const DiagnosticCategory.network(),
  level: DiagnosticLevel.info,
  message: 'Download de configuração concluído',
);
```

### 2. Capturando Erros (O Estouro)

Quando um erro ocorre (num bloco `try-catch`, ou no Global Error Handler do Flutter), você captura a falha. O Reporter vai buscar os dados de contexto, informações do erro e os últimos eventos salvos no repositório em memória para criar o `DiagnosticReport`.

```dart
try {
  // Código que pode falhar
  throw Exception('Falha de conexão com banco de dados');
} catch (error, stackTrace) {
  // 1. Gera o relatório consolidado
  final report = await diagnosticReporter.captureError(
    error,
    stackTrace,
    displayedCode: 'DB_ERR_001',
    severity: DiagnosticLevel.error,
    isFatal: true,
  );
  
  // 2. Envia automaticamente para o servidor (ou salva offline)
  final result = await diagnosticReporter.submit(report);
  
  if (result.isSuccess) {
    print('Erro submetido com sucesso: ${result.incidentId}');
  } else {
    print('Erro ao enviar relatório. Salvo localmente para reenvio.');
  }
}
```

### 3. Rastreamento Automático via Gerenciamento de Estado (BLoC / Provider)

Para evitar colocar chamadas de `recordEvent()` manualmente em cada tela ou botão do seu aplicativo, você pode integrar o reporter com os mecanismos globais de observação do seu gerenciador de estado. 

**Nenhuma alteração é necessária no código interno do package**, pois ele foi desenhado para ser desacoplado e receber os eventos de forma reativa a partir de qualquer contexto.

#### Exemplo com flutter_bloc (BlocObserver)
Crie um observador customizado no seu aplicativo que recebe a instância do `DiagnosticReporter`:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:diagnostic_report_package/diagnostic_report_package.dart';

class DiagnosticBlocObserver extends BlocObserver {
  final DiagnosticReporter reporter;

  DiagnosticBlocObserver(this.reporter);

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    
    // Registra automaticamente cada evento disparado no app
    reporter.recordEvent(
      category: const DiagnosticCategory.business(),
      level: DiagnosticLevel.info,
      message: 'Bloc Event: ${bloc.runtimeType} -> $event',
    );
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    
    // Opcional: Se quiser capturar e reportar erros de bloc automaticamente
    reporter.recordEvent(
      category: const DiagnosticCategory.business(),
      level: DiagnosticLevel.error,
      message: 'Erro no Bloc ${bloc.runtimeType}: $error',
    );
  }
}
```

E inicialize no seu `main.dart`:
```dart
void main() {
  final reporter = DefaultDiagnosticReporter(...);
  
  Bloc.observer = DiagnosticBlocObserver(reporter);
  
  runApp(const MyApp());
}
```

#### Exemplo com Riverpod (ProviderObserver)
Se você utiliza Riverpod, o processo é semelhante usando o `ProviderObserver`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:diagnostic_report_package/diagnostic_report_package.dart';

class DiagnosticProviderObserver extends ProviderObserver {
  final DiagnosticReporter reporter;

  DiagnosticProviderObserver(this.reporter);

  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    // Registra a mudança de estado como um evento de sistema
    reporter.recordEvent(
      category: const DiagnosticCategory.business(),
      level: DiagnosticLevel.info,
      message: 'State Update: ${provider.name ?? provider.runtimeType} alterado',
    );
  }
}
```

E inicialize envolvendo o seu app com `ProviderScope`:
```dart
void main() {
  final reporter = DefaultDiagnosticReporter(...);

  runApp(
    ProviderScope(
      observers: [DiagnosticProviderObserver(reporter)],
      child: const MyApp(),
    ),
  );
}
```

### Resumo do Fluxo

1. **Setup:** Inicialize o `DefaultDiagnosticReporter` com as suas implementações.
2. **Track (Ouvindo):** Registre os eventos usando chamadas manuais (`recordEvent()`) ou configure observers globais (como `BlocObserver` ou `ProviderObserver`) para registrar automaticamente.
3. **Capture (Estouro):** Chame `captureError()` quando um `Exception` for disparado.
4. **Submit:** Envie o report criado usando `submit()`, que tentará mandar para a rede e, caso o aparelho esteja offline, o armazenará localmente para envio posterior.
