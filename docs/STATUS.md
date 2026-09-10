# STATUS — controle-stonni (ar-condicionado por Bluetooth)

> Índice vivo do projeto. Atualizar sempre que mexer.
> Última atualização: **10/09/2026**

## O que é

Controle remoto do ar-condicionado Stonni, rodando no navegador do celular e falando
direto com a placa do equipamento por **Bluetooth LE** — sem servidor, sem login,
sem internet. **É o app do cliente final**, publicado a partir do site da Stonni e
instalável na tela inicial do Android. O testador de bancada
(`bancada/testador-ble.html`) continua existindo só como ferramenta de protocolo, e
**não vai para o ar**.

## Onde está

| Coisa | Caminho |
|---|---|
| Código | `C:\Aplicações da bononi\controle-stonni\` |
| Repositório | `github.com/gustavopelissaribononi-ai/controle-stonni` (branch `main`) |
| Servidor local | `preview_start` → `app-stonni-ar` (porta **5286**) |
| Script do servidor | `.claude\run-app-stonni.cmd` na pasta de docs |
| **Teste (https real)** | `https://gustavopelissaribononi-ai.github.io/controle-stonni/` — GitHub Pages |
| Endereço planejado | `https://controle.stonni.com.br` |
| Deploy de produção | ainda **não publicado** — ver Publicação |

⚠️ **Este é o único app do grupo fora da conta `leobononi2906`.** Os outros 16 repositórios
ficam lá. Consequências práticas: a Vercel precisa ter esta conta conectada para importar, e
quem procurar o app junto com os outros não vai achar. Se incomodar, o GitHub transfere o
repositório em Settings → Transfer ownership, e aqui basta um `git remote set-url origin`.

Arquivo único `index.html` (~43 KB) + `manifest.json` + `sw.js` + `vercel.json` + `icons/`.
Sem build, sem dependência de pacote. Segue o padrão dos outros apps do grupo.

## Ambiente de teste — GitHub Pages

`.github/workflows/pages.yml` publica a cada push na `main`. Serve para **instalar no Android
e validar o Bluetooth num https de verdade**, sem depender da Vercel nem de DNS.

Por causa dele os caminhos do app são **relativos** (`./icons/…`, `scope: "./"`): no Pages o
app fica em `/controle-stonni/`, e caminho absoluto quebraria ícone, manifest e service
worker. Relativo funciona tanto na subpasta quanto na raiz do subdomínio depois. **Não voltar
para caminho absoluto** sem lembrar disso.

O `.vercelignore` não vale aqui — no Pages sai a pasta inteira, inclusive
`bancada/testador-ble.html`. Isso é intencional no ambiente de teste: é por ele que se
confirma o valor de desligar das `CHAVES`, direto do celular, em
`…github.io/controle-stonni/bancada/testador-ble.html`. Na Vercel (produção) o
`.vercelignore` mantém tudo isso fora.

## Publicação (decidido em 10/09/2026)

Subdomínio próprio na Vercel — seria o **primeiro domínio próprio do grupo**; os outros 16
apps rodam em `*.vercel.app`. Passos que dependem de acesso a conta:

1. ~~Criar o repositório e dar push da `main`~~ ✅ **feito em 10/09/2026** —
   `github.com/gustavopelissaribononi-ai/controle-stonni`
2. Vercel → importar o repo, framework "Other", sem build. **Já dá um endereço
   `*.vercel.app` funcional** — use ele para instalar num Android e testar o Bluetooth com o
   equipamento antes de mexer em DNS.
3. Cloudflare → `CNAME controle → cname.vercel-dns.com`, **proxy desligado (nuvem cinza)**,
   senão a Vercel não emite o certificado
4. Vercel → Domains → adicionar `controle.stonni.com.br`
5. WordPress → botão e QR Code apontando para o endereço, avisando que é **Android**

⚠️ **Ninguém documentou quem tem acesso ao Cloudflare / WordPress da Stonni.** A relação do
grupo com o site sempre foi só hotlink de imagem. Esse é o passo que pode segurar a
publicação — não o código.

O site em si: WordPress 6.9.7 + Elementor, na Hostinger, atrás de Cloudflare (DNS nos
nameservers `saanvi`/`renan.ns.cloudflare.com`), LiteSpeed com cache de 7 dias.

## Protocolo (copiado do testador, sem alteração)

| Item | Valor |
|---|---|
| Serviço | `0000ffe0-0000-1000-8000-00805f9b34fb` |
| Notificações (RX) | `…ffe1…` |
| Escrita (TX) | `…ffe2…` |
| Quadro | 9 bytes · `5A 5A len tipo cmd val chk 0D 0A` · chk = soma & 0xFF |
| Ativação | `cmd 0x42` logo após conectar, antes das notificações |
| Status | consulta `cmd 255 val 0` a cada 3 s; resposta com ≥21 bytes |
| Busca | filtro por nome exato (QR Code) ou `namePrefix: 'KT'` |

`montaQuadro`, `montaAtivacao`, `leStatus` e a remontagem do buffer são **idênticos**
ao testador validado na bancada. Não mexer sem o equipamento na mão.

Comandos: `1`=liga(1)/desliga(2) · `2`=modo e funções · `3`=temperatura alvo ·
`4`=ventilador 1–5 · `10`=display · `28`=luz · `68`=ar externo(1)/interno(0) ·
`69`=oscilação · `255`=status.

⚠️ Atenção ao mapa duplo do **modo**: o valor que se envia não é o código que volta
no status. Refrigerar envia 1 / volta 1 · Desumidificar envia 7 / volta 2 ·
Ventilar envia 2 / volta 3 · Aquecer envia 8 / volta 4. No HTML isso está em
`data-val` (envio) e `data-est` (status).

## Design

Identidade extraída do próprio site (stonni.com.br), não inventada:

- Ciano **#00AEE7** — cor de preenchimento e dos números grandes
- **Roboto 900** nos títulos e na temperatura · **Manrope** no corpo
- Botão cheio, raio 12–16 px, `padding 12px 24px`

Tema **escuro** (o site é claro): é um controle usado dentro da cabine, muitas vezes
à noite. Texto sobre o ciano é quase-preto `#04222D` — branco sobre ciano, como o site
faz, dá 2,5:1 e reprova AA; num controle isso atrapalha de verdade.

Duas telas: conectar → controle. No desktop vira duas colunas a partir de 960 px.

## O que o app faz além do testador

- **Estado ativo real** — modo, ventilador, funções e chaves acendem conforme o que a
  placa responde, não conforme o último botão tocado.
- **Estado otimista** (`marca`/`valor`) — o status chega de 3 em 3 s; sem isso o botão
  que você acabou de tocar voltaria sozinho. Cada marca cai assim que o aparelho
  confirma o mesmo valor, ou no prazo (4,5 s; 9 s na temperatura).
- **Temperatura com envio automático** — 600 ms depois do último toque, sem botão
  "Enviar". No testador, o poll de 3 s sobrescrevia o valor que você estava ajustando.
- **Reconexão automática** — 3 tentativas com espera crescente. Bluetooth em caminhão
  cai; sem isso o motorista precisaria refazer a busca.
- **Chaves liga/desliga** de oscilação, luz e display, em vez de botão de mão única.
- **PWA instalável de verdade** — ícones locais 192/512/maskable e botão próprio
  "Instalar na tela inicial" (`beforeinstallprompt`). Nenhum outro app do grupo tem esse
  botão; sem ele o motorista teria que achar "Instalar app" no menu do Chrome.
- **Recado em português** no lugar do log — ver abaixo.
- Poll pausa com a tela em segundo plano e dispara na volta.
- Guarda o último nome de aparelho usado.

## O site só instala; o controle só roda instalado (10/09/2026)

Decisão do produto: quem abre `controle.stonni.com.br` pelo navegador **não usa o controle** —
vê só a tela de instalação. São três estados agora, não dois:

| Estado | O que aparece |
|---|---|
| Navegador (`display-mode: browser`) | só `#telaInstalar` — hero, botão de instalar, passo a passo |
| Instalado, sem conexão | `#telaConectar` |
| Instalado, conectado | `#telaControle` |

`instalado()` casa contra `standalone`, `fullscreen`, `minimal-ui` e
`window-controls-overlay`, mais `navigator.standalone` do iOS. `roteia()` decide uma vez, na
carga.

O passo a passo numerado aparece quando o `beforeinstallprompt` não vem em 1,5 s — sem isso a
pessoa fica olhando para uma tela que manda instalar sem dizer como. O aviso de aparelho sem
Bluetooth migrou para essa tela: não adianta instalar num iPhone.

### Modo teste — digite `TESTE` (ou `DEMO`) no campo de código

Abre o controle com um ar-condicionado **simulado**, para conferir a interface sem
equipamento na frente. Não é um atalho: `aparelhoDeTeste()` devolve um objeto com a mesma
cara de um `BluetoothDevice` e passa pelo `abrirSessao()` de verdade, então o app percorre o
caminho inteiro — monta quadro, escreve, recebe notificação, `leStatus()`, `pinta()`. O
simulador monta quadros de 21 bytes com checksum válido e faz o ambiente caminhar na direção
do alvo, senão a tela ficaria estática.

⚠️ **O modo teste valida a interface, não o protocolo.** O simulador obedece exatamente à
convenção que o app assume — inclusive no ponto ainda não confirmado (desligar com valor 2).
Ele nunca vai discordar do app, porque foi escrito a partir dele. Só o equipamento decide.

Funciona antes da checagem de Bluetooth, então abre até em aparelho que não tem Bluetooth
nenhum. Não fica salvo no `localStorage` — não faria sentido reconectar sozinho num
simulador. O código **não aparece na tela** de propósito: é ferramenta, não recurso do
cliente.

### Leitor de QR Code

`BarcodeDetector` — nativo no Chrome do Android, **sem biblioteca e sem rede**, então o leitor
funciona com o app offline. Botão ao lado do campo de código abre a câmera em tela cheia
(`facingMode: environment`); ao ler, preenche o campo e **já chama `conectar()`** — ler o
código e ainda pedir mais um toque seria bobagem.

`extraiCodigo()` tem uma regra que não é óbvia: **conteúdo curto e sem espaço vai verbatim**.
O filtro do Bluetooth casa o nome exato, então normalizar maiúscula ou separador quebraria a
conexão — `kt-a1b2c3` precisa continuar `kt-a1b2c3`. Só quando o QR vem embrulhado (uma URL,
ou texto em volta) é que se extrai o `KT-…` de dentro.

Onde não houver `BarcodeDetector` ou a câmera for negada, o campo manual continua valendo e o
app diz isso — por isso o campo **não sai da tela**.

### O aparelho fica salvo depois da primeira conexão

`abrirSessao()` grava `aparelho.name` no `localStorage` **depois** de conectar — o nome que o
aparelho respondeu, não o que a pessoa digitou. É o que `reconectaSozinho()` procura na
abertura seguinte.

### Reconexão silenciosa ao abrir

`reconectaSozinho()` usa `navigator.bluetooth.getDevices()` — que devolve os aparelhos já
autorizados e permite `gatt.connect()` **sem gesto do usuário**. É o que faz o app abrir já no
controle em vez de parar em "Procurar aparelho" toda vez. Prefere o último nome usado
(`localStorage`), senão o primeiro autorizado.

⚠️ **`gatt.connect()` num aparelho fora de alcance fica pendurado — sem erro e sem sucesso.**
Por isso existe o `ABERTURA_MS` (8 s): estourando o prazo, o app zera `aparelho` (o que corta
`caiu()` e a cadeia de retentativas), chama `disconnect()` para cancelar a conexão pendente e
mostra a tela de procurar com um recado. Sem esse limite o app abriria e ficaria travado em
"Procurando o ar…" para sempre.

Se o Chrome não expuser `getDevices`, a função devolve `false` de cara e tudo segue como antes.

## Feito para virar app de cliente final (10/09/2026)

O app nasceu como ferramenta interna. Ao decidir que vai no site e no celular do cliente,
mudou:

- **Ícones locais** em `icons/`, gerados do símbolo oficial 2560×2560 (ver `arte/LEIAME.md`).
  Antes o manifest tinha um único ícone de 300 px hospedado no WordPress — o Chrome no
  Android não instala assim.
- **Zero dependência do site.** Logo do cabeçalho e favicon eram remotos; agora são arquivos
  locais e o `sw.js` não tem mais regra para `stonni.com.br`. Um app instalado que busca
  imagem no WordPress não é offline.
- **Painel técnico removido.** Envio bruto de comando não fica exposto a quem abrir o site.
  A função `log()` continua existindo e alimenta o `console` — a assistência lê por
  `chrome://inspect`. Quem mexe em protocolo usa `bancada/testador-ble.html`.
- **`recado()` no lugar do log.** Sem o painel, o cliente veria o chip voltar para
  "Desconectado" e nada mais. `recadoDeErro()` traduz a falha do Web Bluetooth para algo
  acionável ("Confira se o ar está ligado na chave e se você está perto dele"). Cancelar a
  lista de aparelhos devolve `null` de propósito: é intenção do usuário, não erro.
- **Headers no `vercel.json`** — `Service-Worker-Allowed`, `no-cache` no `sw.js`/HTML/manifest
  e `immutable` nos ícones.
- Pasta renomeada de `Aplicativo Stonni` para `controle-stonni` (kebab-case do grupo, igual
  ao subdomínio). O `.claude\run-app-stonni.cmd` foi ajustado junto — o nome curto 8.3 mudou
  de `APLICA~1` para `CONTRO~1`.

## Pendências

- [ ] **Validar na bancada o desligar de oscilação / luz / display.** É o único ponto
      do protocolo não confirmado: o testador só tinha o valor de *ligar*. Adotei
      `des: 2`, seguindo a convenção do liga/desliga (1 liga, 2 desliga). Se não
      responder, muda numa linha só — constante `CHAVES` no topo do script. Como o app
      não tem mais envio bruto, esse teste é feito pelo `bancada/testador-ble.html`.
- [ ] Confirmar os offsets de `leStatus` com o equipamento ligado. O parser lê o byte
      2 como estado (onde o cabeçalho sugeriria comprimento). Veio assim do testador;
      a função `confere()` avisa no console se tensão/ambiente/modo vierem implausíveis.
- [ ] **Publicar** — Web Bluetooth exige https. Ver seção Publicação; o gargalo é acesso
      ao Cloudflare, não código.
- [ ] Confirmar a instalação num Android real: botão "Instalar" aparecendo, ícone sem
      círculo branco em volta na tela inicial, e abertura em `standalone` no modo avião.
- [ ] Decidir sobre iPhone. Safari não expõe Bluetooth para página web e a Apple não
      sinaliza mudança — o app mostra o aviso, mas metade dos clientes fica de fora.
      Resolver exige app nativo (ou wrapper tipo Capacitor).
- [ ] Fora deste app: o ícone PWA do `com_stonni` é um JPEG declarado como PNG quadrado.
      Provavelmente impede a instalação daquele app.

## Decisões que não são óbvias no código

- **Sem Supabase, sem Hub, sem login.** É um app de cliente final, offline, que só
  conversa com a placa por Bluetooth. Não há o que autenticar nem o que registrar em
  `{prefixo}_logs`. Por isso o checklist de app novo do padrão do grupo se aplica só
  em parte aqui.
- **Sem aba de Configurações.** Não há regra de negócio: o que existe é protocolo, e
  protocolo mora em constante nomeada no topo do script (`CHAVES`, `MODOS`, `FALHAS`).
- **O service worker não registra em localhost**, de propósito (`location.protocol ===
  'https:'`). Cache de service worker já escondeu semanas de trabalho neste grupo; em
  desenvolvimento o que se vê é sempre o arquivo, nunca o cache. Testar o offline
  exige subir num https.

## Dev-log

**10/09/2026** — App criado a partir do `testador-ble.html` validado na bancada.
Protocolo portado sem alteração; UI refeita com a identidade do site. Três bugs
encontrados e corrigidos no caminho:

1. Faltava a regra base do `.ic` — todos os ícones saíam preenchidos em vez de
   traçados (apareciam como bolinhas).
2. A névoa decorativa do cartão de clima vazava 90 px pela direita e, com
   `overflow:hidden`, transformava o cartão num container rolável: qualquer controle
   recebendo foco arrastava o conteúdo para a esquerda e cortava a temperatura.
   Corrigido com `right:0` + `overflow:clip`.
3. A reconexão automática não se sustentava: falhando a 1ª tentativa, a cadeia parava
   e o chip ficava preso em "Reconectando (1/3)…" para sempre. Cada falha agora
   agenda a próxima (`tentaVoltar`).

Verificado no Chromium em 375×812 e 1100×820, sem erro de console: quadro de status
sintético renderizando, temperatura com trava otimista, modo/ventilador/chaves
acendendo, cadeia de reconexão 1→2→3→desconectado, e `desconectar()` limpando estado.
**O caminho BLE em si ainda não foi testado com o equipamento** — só o protocolo
portado e a tela.

**10/09/2026 (2ª rodada)** — Definido que o app vai no site da Stonni e no celular do
cliente. Virou produto público: ícones locais gerados do símbolo oficial 2560×2560,
dependência do WordPress cortada, painel técnico removido, `recado()` traduzindo falha de
Bluetooth para português, botão de instalar, headers de cache no `vercel.json`, pasta
renomeada para `controle-stonni`.

Verificado: manifest servindo os três ícones em `200 image/png` com `purpose` correto e
assinatura PNG real conferida byte a byte; `recadoDeErro()` cobrindo os cinco casos
(inclusive cancelamento devolvendo `null`); painel técnico ausente do DOM; tela de controle
íntegra sem ele. **Instalação real no Android continua por testar** — só é possível depois
de publicar num https.
