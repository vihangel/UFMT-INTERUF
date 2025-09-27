<!-- @format -->

## Variáveis de Ambiente

Crie um arquivo `.env` na raiz do projeto com o seguinte conteúdo:

```env
SUPABASE_URL=https://cipsznaudjkrpzzruhvp.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNpcHN6bmF1ZGprcnB6enJ1aHZwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU5NjE4ODEsImV4cCI6MjA3MTUzNzg4MX0.4JyOWdbuI4Bf8Fk3DGt71bbWep0OqWhbrlblcIAhC7k
```

## Tarefas a Realizar

- **Configurar pacotes para abrir links externos**

  - Adicionar e configurar o pacote `openUrl` para suportar abertura de links externos em Android e iOS.

- **Gerenciar chaves do projeto Supabase**

  - Adicionar as chaves do projeto Supabase, incluindo configurações para autenticação via Google e Apple.

- **Implementar Notifier de Autenticação**

  - Criar um notifier para autenticação, responsável por redirecionar o usuário para a rota de login ou home conforme o status de autenticação.

- **Personalizar nome do projeto, ícone e splash screen**

  - Adicionar e configurar pacotes para alterar o nome do projeto, definir o ícone do app e personalizar a splash screen.
    https://pub.dev/packages/flutter_launcher_icons
    https://pub.dev/packages/flutter_native_splash

- **Gerenciar fontes personalizadas**

  - Verificar o uso do pacote Google Fonts. Caso a fonte desejada não esteja disponível, adicionar os arquivos de fonte diretamente nos assets do projeto e configurar no `pubspec.yaml`.

- **Melhorar handles de repositorios**

  - Adicionar tratativas de erros.
