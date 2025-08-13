<!-- @format -->

# Guideline do Projeto

Este documento serve como um guia para o desenvolvimento do projeto, definindo a arquitetura, a estrutura de pastas e as convenções de código.

## Arquitetura

O projeto segue uma arquitetura baseada em features, inspirada nas [diretrizes de arquitetura do Flutter](https://docs.flutter.dev/app-architecture/guide).

A estrutura de pastas principal é dividida em:

- `lib/core`: Contém o código que é compartilhado por todo o aplicativo.
- `lib/features`: Contém as diferentes funcionalidades do aplicativo.

### Camada de Dados

A camada de dados é responsável por obter e manipular os dados do aplicativo. Ela é dividida em:

- **Services:** Responsáveis pela comunicação com fontes de dados externas, como a API do Supabase. Eles lidam diretamente com as chamadas de rede.
- **Repositories:** Atuam como uma ponte entre os `services` e a camada de UI (ViewModels). Eles podem conter lógica de negócios, como tratar erros (try-catch), combinar dados de múltiplas fontes e fazer cache.
- **Models:** Representam as estruturas de dados do aplicativo. Eles são mantidos dentro das pastas de cada feature.

### Gerenciamento de Estado

Para o gerenciamento de estado, utilizamos a abordagem de **ViewModel** (também conhecida como `ChangeNotifier`), conforme recomendado pela equipe do Flutter. Cada tela ou widget complexo terá seu próprio `ViewModel` para gerenciar seu estado e a lógica de UI. O `login_viewmodel.dart` é um exemplo dessa abordagem.

## Estrutura de Pastas

### `lib/core`

A pasta `core` contém os seguintes subdiretórios:

- `routes`: Define as rotas de navegação do aplicativo. O arquivo `app_routes.dart` centraliza todas as rotas.
- `theme`: Contém a definição visual do aplicativo.
  - `app_colors.dart`: Define a paleta de cores.
  - `app_styles.dart`: Define os estilos de texto.
  - `app_icons.dart`: Centraliza os caminhos para os ícones.
  - `app_theme.dart`: Define o tema geral do aplicativo.
- `widgets`: Contém widgets reutilizáveis em todo o aplicativo.
  - `app_buttons.dart`: Fornece uma abstração para os botões, permitindo consistência visual. Possui três variantes: `filled`, `outline` e `text`, que podem ser usadas com os construtores `AppButton()`, `AppButton.outline()` e `AppButton.text()`.
  - `app_form_field.dart`: Fornece uma abstração para os campos de formulário, incluindo validação, campos de senha e customização de teclado.

### `lib/features`

Cada feature do aplicativo terá sua própria pasta dentro de `lib/features`. A estrutura interna de cada feature pode variar, mas geralmente conterá:

- `data/`:
  - `models/`: Modelos de dados específicos da feature.
  - `repositories/`: Repositórios da feature.
  - `services/`: Serviços da feature.
- `widgets/`: Widgets específicos da feature.
- `[feature_name]_page.dart`: A página principal da feature.
- `[feature_name]_viewmodel.dart`: O ViewModel (ChangeNotifier) da feature.

## Convenções de Código

### Nomes de Rotas

Toda página deve ter uma constante estática `routename` para facilitar o gerenciamento de rotas com o `goRouter`.

```dart
class LoginPage extends StatelessWidget {
  static const String routename = 'login';
  // ...
}
```

### Tratamento de Erros

O tratamento de erros é uma parte crucial do aplicativo. A abordagem é a seguinte:

- **Repositories:** Todo método de um repositório que faz uma chamada para um `service` deve estar dentro de um bloco `try-catch`. Em caso de erro, o repositório deve lançar uma exceção customizada (ex: `LoginException`) que a camada de `ViewModel` possa entender.
- **ViewModels:** O `ViewModel` deve capturar as exceções lançadas pelo `repository` e atualizar seu estado para refletir o erro. Isso pode incluir uma mensagem de erro para o usuário e o estado de carregamento.
- **UI:** A UI deve observar o estado do `ViewModel` e exibir uma mensagem de erro apropriada para o usuário (ex: usando um `SnackBar` ou um `AlertDialog`). O erro detalhado deve ser registrado no console para fins de depuração.
