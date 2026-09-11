# Login do cliente final e cadastro de equipamento

> Decidido em 10/09/2026. **Nada foi aplicado no Supabase** — esta nota é o que
> precisa ser revisado e executado lá, por quem tem acesso.

## O que muda no produto

O app deixa de ser 100% anônimo. O cliente final cria conta (e-mail/senha ou Google),
escaneia **o código de barras do produto (SKU)** e depois **o QR Code do aparelho**, uma vez.
Dali em diante abre e vai direto ao controle.

O motivo de manter a sessão viva não é só conveniência: a intenção é **enviar notificações**
para quem tem o app. Isso não está construído ainda (ver Pendências), mas o cadastro já nasce
no formato que aquilo vai precisar.

## A regra que não pode ser quebrada

⚠️ **O controle do ar nunca espera a rede.** O motorista usa isso na estrada, sem sinal. O
login acontece uma vez, com internet; a sessão fica guardada no aparelho; e a partir daí abrir
o app e conectar no Bluetooth **não faz nenhuma chamada de rede**. Se alguma mudança futura
colocar uma chamada ao Supabase no caminho entre abrir o app e controlar o ar, ela está errada.

## O que fazer no Supabase

### 1. Tabela

`supabase/001_equipamentos.sql`, no repositório. Cria `stonni_ar_equipamentos` **com RLS
ligado e quatro políticas** (o dono só enxerga as próprias linhas).

⚠️ **Aqui o RLS não é opcional.** Este é o primeiro app do grupo aberto ao público, e ele leva
a anon key embutida como todo app estático. Sem RLS, qualquer cliente leria a tabela inteira —
quem comprou o quê, com qual número de série. Ligar RLS numa tabela **nova** não tem relação
com o rollout pendente nas tabelas antigas: é por tabela.

### 2. Provedor Google

Não existe OAuth em nenhum app do grupo — este seria o primeiro. Precisa de:

1. **Google Cloud** → criar credencial OAuth 2.0 (tipo *Aplicativo da Web*)
2. Em *Authorized redirect URIs*, apontar para o callback do Supabase:
   `https://vishxwdxqiygbxmtpfoy.supabase.co/auth/v1/callback`
3. **Supabase** → Authentication → Providers → Google → colar Client ID e Client Secret

### 3. URLs de redirecionamento

Supabase → Authentication → URL Configuration → **Redirect URLs**, incluindo os dois endereços:

```
https://leobononi2906.github.io/controle-stonni/
https://controle.stonni.com.br/
```

⚠️ Sem o endereço na lista, o login com Google volta com erro em vez de entrar. E quando o
app mudar de endereço, **isto tem que ser atualizado junto** — é o esquecimento clássico.

### 4. Confirmação de e-mail

Authentication → Providers → Email. Decidir se o cadastro por e-mail/senha exige confirmação.

- **Com confirmação**: mais seguro, mas o cliente precisa sair do app, abrir o e-mail e voltar
  — no meio da instalação do ar, com o caminhão parado.
- **Sem confirmação**: entra direto. Aceitável aqui, porque a conta não dá acesso a dinheiro
  nem a dado de terceiro; ela vincula um equipamento a uma pessoa.

Recomendação: **sem confirmação** para não travar a instalação, e revisar se aparecer abuso.

## Decisões que tomei sozinho, e dá para mudar

- **O SKU é guardado como veio**, sem validar contra catálogo — não existe catálogo de produto
  acessível ao app hoje. Se quiser validação, precisa de uma tabela de produtos.
- **A conta é criada dentro do app** (e-mail/senha), porque o cliente não existe em lugar
  nenhum antes de comprar.
- **Sem SDK do Supabase.** A autenticação é `fetch()` direto nos endpoints `/auth/v1/*`, como
  os outros apps do grupo já fazem. Mantém o app sem dependência externa e sem quebrar o
  funcionamento offline.

## Pendências

- [ ] Revisar e aplicar `supabase/001_equipamentos.sql`
- [ ] Configurar o provedor Google (Google Cloud + Supabase)
- [ ] Cadastrar as Redirect URLs
- [ ] Decidir a confirmação de e-mail
- [ ] **Notificações**: precisa de chaves VAPID, guardar a inscrição de push por usuário e uma
      Edge Function para disparar. É uma frente à parte, não incluída aqui.
