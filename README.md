# Weather Forecast

Aplicativo **Flutter** para consultar a previsão do tempo atual e dos próximos dias utilizando a **WeatherAPI**.
Segue **arquitetura limpa** (camadas `core`, `data`, `domain` e `ui`) com **signals** e **commands** para gerenciamento reativo de estado.
As dependências são registradas via **auto_injector** e o serviço de dados pode consumir a API real ou dados *mock*.

---

## 📌 Visão Geral

| Recurso                  | Descrição                                                                 |
|--------------------------|---------------------------------------------------------------------------|
| **Busca por cidade**     | Permite digitar o nome da cidade e obter clima atual + previsão.          |
| **Busca por coordenadas**| Interface de fachada para pesquisas por latitude/longitude.               |
| **Dados de exemplo**     | Quando a API não responde, retorna dados *mock* para manter a interface.  |
| **Temas claro/escuro**   | Definidos em `lightTheme` e `darkTheme` com **Material 3**.               |

---

## 🏗 Arquitetura

- **Entrada**  
  Arquivo `lib/main.dart` inicializa as dependências, configura o `MaterialApp`, aplica os temas claro/escuro e define a página inicial.

- **Injeção de Dependências**  
  `AutoInjector` registra serviços, repositórios, *use cases* e o controlador da tela inicial.

- **Serviços e Repositórios**  
  - `WeatherRemoteDataSource` consome a WeatherAPI via `ApiHttpClientService` e `WeatherMockDataSource` fornece dados estáticos.
  - `WeatherRepositoryImpl` decide entre remoto e mock, expondo modelos de domínio.

- **Use Cases / Facade**  
  A camada de domínio expõe *use cases* (ex.: `GetCurrentWeatherUseCase`, `GetForecastUseCase`) e uma *facade* para orquestrar chamadas.

- **UI (MVVM)**  
  `WeatherHomeViewController` utiliza **signals_flutter** e comandos parametrizados para acionar os *use cases* e atualizar a interface de forma reativa.

- **Padrão Command**  
  Implementação de comandos com estado reativo, permitindo composição e cancelamento de execuções.

---

## 📂 Estrutura de Pastas

```
lib/
  core/            # Configurações, temas, padrões e erros
  data/            # Serviços HTTP e repositórios
  domain/          # Models e use cases
  ui/              # Views, controllers, widgets e commands
  main.dart        # Ponto de entrada
```

---

## 📦 Dependências Principais

- `auto_injector` – Injeção de dependências  
- `http` – Requisições REST  
- `signals_flutter` – Estado reativo baseado em signals  
- `google_fonts`, `cupertino_icons` – UI e tipografia  

*(consulte o `pubspec.yaml` para a lista completa)*

---

## 🔑 Chave e documentação da WeatherAPI

1. Crie uma conta gratuita em [WeatherAPI](https://www.weatherapi.com/signup.aspx) e gere sua chave.
2. Explore os endpoints no [API Explorer](https://www.weatherapi.com/api-explorer.aspx) ou consulte a [documentação/Swagger](https://www.weatherapi.com/docs/).

A chave é lida em tempo de execução via `--dart-define=WEATHER_API_KEY` no arquivo [`ApiConfig`](lib/core/config/api_config.dart).

---

## ▶️ Como Executar

1. Instale o **Flutter SDK** (versão compatível com `sdk: ^3.7.2`).
2. Na raiz do projeto, rode:

```bash
flutter pub get
flutter run --dart-define=WEATHER_API_KEY=SEU_TOKEN --dart-define=USE_MOCK=false
```

> Use `--dart-define=USE_MOCK=true` para testar com os dados estáticos.

---

## 🎨 Funcionalidades de UI

- **WeatherSearchBar** → Campo de busca com indicador de carregamento.  
- **CurrentWeatherCard** → Exibe temperatura, condição e descrição.  
- **WeatherDetailsCard** → Mostra pressão, umidade, vento etc.  
- **ForecastList** → Lista previsões diárias para cinco dias.  

---

## 🚧 Pendências

- Adicionar testes unitários e de widget.
- Configurar `flutter analyze` e `flutter test` em pipeline de CI.
- Documentar geração de arquivos de internacionalização (l10n).
- Completar documentação da aba de surf/pesca.

---

## 📜 Licença

Este projeto é de uso livre para **estudos**.  
Substitua os dados da API e ajuste conforme sua necessidade.


