# Weather Forecast 🌦️

> App Flutter com duas abas: “Clima” (WeatherAPI) e “Surf/Pesca” (Open‑Meteo). Arquitetura limpa, DI com AutoInjector, estado reativo com Signals + Commands. Cidade inicial: Matinhos, PR.

---

## ✨ Funcionalidades

| 💡 Recurso | 🚀 Descrição |
|---|---|
| 🔎 Busca por cidade | Campo de busca nas duas abas com feedback de carregamento |
| 🌡️ Clima atual e previsão | Temperatura, detalhes e previsão pela WeatherAPI |
| 🌊 Condições do mar | Onda, ondulação, período, vento e temperatura da água (Open‑Meteo) |
| 🌗 Marés | Extremos quando disponíveis; fallback por máximos/mínimos |
| 🔄 Atualização | Pull‑to‑refresh e auto‑refresh a cada 30 minutos |
| 🌍 i18n | Interface em pt‑BR com mensagens amigáveis |

---

## 🏗️ Arquitetura

| Camada | Responsabilidade | Principais arquivos |
|---|---|---|
| Core | Configurações, temas, DI | `lib/core/di/injector.dart`, `core/config/*` |
| Data (Weather) | Data sources HTTP e mock | `data/datasources/*`, `data/services/api_http_client_service.dart` |
| Data (Marine) | Serviço Open‑Meteo + repositório | `data/services/open_meteo_api_service.dart`, `data/repositories/marine_repository_impl.dart` |
| Domain | Models e use cases | `domain/models/*`, `domain/usecases/*` |
| UI | Controllers, views e widgets | `ui/controllers/*`, `ui/views/*`, `ui/widgets/*` |

---

## 📂 Estrutura

```
lib/
  core/di/injector.dart
  data/
    datasources/               # Weather API remote + mock
    repositories/marine_repository_impl.dart
    services/{api_http_client_service,marine_api_service,open_meteo_api_service}.dart
  domain/
    models/{current_weather,forecast,marine_models}.dart
    repositories/marine_repository.dart
    usecases/{get_current_weather_usecase,get_forecast_usecase,search_locations_usecase,
              get_marine_hours_usecase,get_tide_extremes_usecase}.dart
  ui/
    controllers/{weather_home_view_controller,surf_fish_controller}.dart
    views/weather_home_page.dart
    widgets/{current_weather_card,weather_detail_card,forecast_list,weather_search_bar,
             surf_fish_panel}.dart
```

---

## 🔧 Configuração e Execução

| Variável | Uso | Exemplo |
|---|---|---|
| `WEATHER_API_KEY` | Chave da WeatherAPI | `--dart-define=WEATHER_API_KEY=SEU_TOKEN` |
| `USE_MOCK` | Mock para clima (true/false) | `--dart-define=USE_MOCK=true` |

Comandos rápidos:

```bash
flutter pub get
# Web
flutter run -d chrome --dart-define=WEATHER_API_KEY=SEU_TOKEN
# Mock do clima
flutter run -d chrome --dart-define=WEATHER_API_KEY=SEU_TOKEN --dart-define=USE_MOCK=true
```

Notas:
- 🌊 A aba Surf/Pesca usa Open‑Meteo — sem chave e sem proxy.
- 📍 Cidade inicial: “Matinhos, PR” (altere em `lib/ui/controllers/weather_home_view_controller.dart`).

---

## 🌊 Aba Surf/Pesca

- Serviço: `OpenMeteoApiService` combina dois endpoints (Marine + Forecast) e adapta para `MarineHour`.
- Marés: `getTideExtremes` lê lista de extremos quando disponível; caso contrário, deriva por máximos/mínimos da série de altura.
- Janelas ideais (heurística):

| Atividade | Critério | Pontos |
|---|---|---|
| Surf | Período ≥ 8 s | +1 |
| Surf | Altura de swell 0.8–2.2 m | +1 |
| Surf | Vento ≤ 8 m/s | +1 |
| Pesca | Vento ≤ 6 m/s | +1 |
| Pesca | Ondas ≤ 1.5 m | +1 |
| Pesca | Próximo de extremo de maré (±90 min) | +2 |

- Limiar de exibição:
  - Surf: ≥ 3
  - Pesca: ≥ 3 (ou ≥ 2 quando não houver dados de maré)
- UI: cards com gradiente azul, chips de maré e carrossel horizontal de janelas.
- Mensagens i18n: ausência de maré/janelas é comunicada de forma amigável.

---

## 🔤 Internacionalização (l10n)

Chaves relevantes: `noMarineData`, `noTideData`, `noWindows`, além de `currentConditions`, `wave`, `swell`, `water` etc. Arquivos em `lib/l10n`.

---

## 🧩 Dependências

| Pacote | Finalidade |
|---|---|
| auto_injector | Injeção de dependências |
| http | Requisições REST |
| signals_flutter | Estado reativo com signals |
| flutter_localizations | i18n pt‑BR |

Consulte o `pubspec.yaml` para a lista completa.

---

## 🧭 Boas Práticas e Roadmap

- ✅ Camadas e contratos bem definidos (Service → Repository → Use Cases → Controller → UI)
- ✅ Controllers enxutos; lógica de cálculo isolada
- ✅ Tratamento resiliente de erros/4xx no marinho
- ✅ DI centralizada e testável

---

## 📝 Licença

Projeto para estudos. Use e adapte conforme sua necessidade.
