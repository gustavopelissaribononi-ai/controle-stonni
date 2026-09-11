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
| Repositório | `github.com/leobononi2906/controle-stonni` (branch `main`) |
| Servidor local | `preview_start` → `app-stonni-ar` (porta **5286**) |
| Script do servidor | `.claude\run-app-stonni.cmd` na pasta de docs |
| **Teste (https real)** | `https://leobononi2906.github.io/controle-stonni/` — GitHub Pages |
| Endereço planejado | `https://controle.stonni.com.br` |
| Deploy de produção | ainda **não publicado** — ver Publicação |

O repositório nasceu na conta pessoal `gustavopelissaribononi-ai` e foi **transferido para
`leobononi2906` em 11/09/2026**, onde ficam os outros 16 apps do grupo. O endereço antigo
responde com redirecionamento, mas **o endereço do GitHub Pages mudou de verdade** — quem
tinha o app instalado pelo endereço antigo precisa reinstalar pelo novo.

Arquivo único `index.html` (~43 KB) + `manifest.json` + `sw.js` + `vercel.json` + `icons/`.
Sem build, sem dependência de pacote. Segue o padrão dos outros apps do grupo.

## Ambiente de teste — GitHub Pages

`.github/workflows/pages.yml` publica a cada push na `main`. Serve para **instalar no Android
e validar o Bluetooth num https de verdade**, sem depender da Vercel nem de DNS.

Por causa dele os caminhos do app são **relativos** (`./icons/…`, `scope: "./"`): no Pages o
app fica em `/controle-stonni/`, e caminho absoluto quebraria ícone, manifest e service
worker. Relativo funciona tanto na subpasta quanto na raiz do subdomínio depois. **Não voltar
para caminho absoluto** sem lembrar disso.

O workflow publica **só o app** (`index.html`, `manifest.json`, `sw.js`, `icons/`). No começo
subia a pasta inteira, e com ela iam para a internet aberta o próprio `docs/STATUS.md` — que
descreve o protocolo comando a comando — o `bancada/testador-ble.html` e o README. Um
concorrente lia tudo sem precisar de equipamento. O `.vercelignore` cuida do mesmo do lado da
Vercel; no Pages a barreira é o passo `Monta o site` do workflow.

⚠️ Consequência prática: **o testador de bancada não está mais acessível pelo celular.** Para
usá-lo num teste, servir da máquina local (`preview_start` + encaminhamento de porta por USB)
ou republicá-lo temporariamente.

## Publicação (decidido em 10/09/2026)

Subdomínio próprio na Vercel — seria o **primeiro domínio próprio do grupo**; os outros 16
apps rodam em `*.vercel.app`. Passos que dependem de acesso a conta:

1. ~~Criar o repositório e dar push da `main`~~ ✅ **feito em 10/09/2026** —
   `github.com/leobononi2906/controle-stonni`
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
`4`=ventilador 1–5 · `10`=display (alterna) · `28`=luz · `69`=oscilação · `255`=status.

O comando `68` (ar externo 1 / interno 0) existe no protocolo mas **não é usado**: o
equipamento testado é sempre interno, e o controle saiu do app.

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

### Responsividade

Medido, não estimado — em 320, 390, 700, 768, 844×390, 1024 e 1440. Em todos: **nenhum
vazamento horizontal e nenhum alvo de toque abaixo de 40 px**.

| Tela | Antes | Agora |
|---|---|---|
| 768×1024 (tablet em pé) | 68% de uso, 1 coluna | **98%**, 2 colunas, 1,8 telas de rolagem |
| 844×390 (celular deitado) | 1 coluna, 6,2 telas de rolagem | **2 colunas, 4,3 telas**, número 116→58 px |
| 320 e 390 (celular em pé) | ok | mantido, 100% de uso |

O que estava errado: o corte de duas colunas ficava em **960 px**, e deixava de fora
justamente os dois casos comuns — tablet em pé e celular deitado. Agora são **700 px** para
as duas colunas e **1100 px** para a largura máxima.

Deitado, o recurso escasso é a **altura**, não a largura: existe um bloco
`@media(orientation:landscape) and (max-height:520px)` que aperta o vertical (número, paddings
dos cartões, botões redondos) sem mexer no resto.

⚠️ **Instalar e conectar não esticam** (`max-width:560px` a partir de 700 px). São formulários
curtos; a 1000 px o título fica ilegível e o botão principal vira faixa. Quem ganha com tela
larga é o controle, que vira duas colunas.

⚠️ Cuidado com `ch` para limitar largura de título: tentei `.hero{max-width:19ch}` e deu
174 px, porque `ch` usa a fonte do **contêiner** (15 px), não a do `h1` (54 px). O título
quebrou em três linhas.

Duas telas: conectar → controle.

## O que o app faz além do testador

- **Estado ativo real** — modo, ventilador, funções e chaves acendem conforme o que a
  placa responde, não conforme o último botão tocado.
- **Estado otimista** (`marca`/`valor`) — o status chega de 3 em 3 s; sem isso o botão
  que você acabou de tocar voltaria sozinho. A marca cai quando **um quadro novo** traz o
  mesmo valor, ou quando estoura o prazo de 9 s.
- **Temperatura com envio automático** — 600 ms depois do último toque, sem botão
  "Enviar". No testador, o poll de 3 s sobrescrevia o valor que você estava ajustando.
- **Reconexão automática** — 3 tentativas com espera crescente. Bluetooth em caminhão
  cai; sem isso o motorista precisaria refazer a busca.
- **Chaves liga/desliga** de oscilação e luz, em vez de botão de mão única. O display ficou
  como botão de alternar, porque o equipamento não informa o estado dele.
- **PWA instalável de verdade** — ícones locais 192/512/maskable e botão próprio
  "Instalar na tela inicial" (`beforeinstallprompt`). Nenhum outro app do grupo tem esse
  botão; sem ele o motorista teria que achar "Instalar app" no menu do Chrome.
- **Recado em português** no lugar do log — ver abaixo.
- Poll pausa com a tela em segundo plano e dispara na volta.
- Guarda o último nome de aparelho usado.

## Conta do cliente e cadastro do equipamento (10/09/2026)

O app deixou de ser anônimo. Detalhes e o que falta fazer no Supabase estão em
[`docs/2026-09-10-login-e-cadastro.md`](2026-09-10-login-e-cadastro.md). Resumo do que mudou
no código:

**Cinco telas agora**, decididas por `roteia()` sem nenhuma chamada de rede:

```
não instalado         -> telaInstalar
sem sessão            -> telaLogin        (e-mail/senha ou Google)
sem equipamento       -> telaCadastro     (código de barras + QR, uma vez)
com tudo, sem conexão -> telaConectar
conectado             -> telaControle
```

⚠️ **A regra que não pode ser quebrada: o controle do ar NUNCA espera a rede.** Login
acontece uma vez, com internet; a sessão fica no `localStorage`; abrir o app e conectar no
Bluetooth não faz nenhuma chamada. Consequências disso no código, todas deliberadas:

- `renovaSessao()` falha **em silêncio** e não desloga. Sem rede, a sessão guardada segue
  valendo — offline não pode expulsar o motorista do próprio ar.
- `salvaEquipamento()` grava **local primeiro** e só depois tenta mandar. Se o Supabase
  estiver fora, ou a tabela não existir ainda, o cadastro vale assim mesmo e sincroniza depois.
- `renovaSessao()`, `buscaUsuario()` e `sincronizaEquipamento()` são chamados **depois** de a
  tela certa já estar no ar, nunca antes.

**Sem SDK.** Autenticação é `fetch()` direto em `/auth/v1/*`, como os outros apps do grupo.
O app continua sem dependência externa e sem nada para baixar antes de abrir.

**Um leitor só** (`leCodigo(formatos, titulo)`) serve aos dois usos — devolve o valor lido ou
`null` se cancelaram. Código de barras aceita `ean_13`, `ean_8`, `upc_a`, `upc_e`, `code_128`,
`code_39`, `itf` e `codabar`.

### Descoberta útil: o servidor local aponta para staging

`serve-staging.py` **reescreve a URL do Supabase** ao servir: o arquivo em disco tem
`vishxwdxqiygbxmtpfoy` (produção), mas o navegador recebe `gxzhuewczlixksqrmjuk` (staging) —
daí a faixa laranja. Teste local não alcança produção, de graça. Vale lembrar disso antes de
concluir que "o login não funciona": pode ser só o staging não ter a configuração.

⚠️ **Publicar este código faz o Supabase de produção passar a aceitar cadastro** de quem abrir
o endereço. É o esperado num app de cliente final, mas é uma porta que se abre no dia do
deploy — não no dia em que o primeiro cliente aparecer.

## Avisos ao cliente (10/09/2026)

Dois fatos que o cliente precisa saber **antes** de tentar, e que geravam chamado à toa:

- **O ar não precisa estar ligado** para o controle conectar. Aparece na tela de instalação e
  na de conectar.
- **É para celular Android; no computador não funciona.**

⚠️ Isso obrigou a corrigir duas mensagens de erro que diziam o contrário — *"Confira se o ar
está ligado na chave"* em `recadoDeErro()` e na falha de reconexão. Elas mandavam o cliente
fazer justamente o que não é necessário. Se algum texto novo mencionar ligar o ar antes de
conectar, está errado.

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

### Log de bancada com o equipamento (10/09/2026, KT2026050014629)

18 quadros de status reais, todos com **checksum OK**. O que ficou provado:

**O parser está certo.** Ventilador 3/2/1 → `fan` 3/2/1; alvo 25/23/21 → `target` 25/23/21;
turbo e luz nos bits previstos. Os offsets de `leStatus` **saem da lista de pendências**.

**A convenção de desligar (valor 2) está certa, ao menos para a luz.** `1C 01` acendeu (bit
`light` = 1) e `1C 02` apagou (bit = 0), confirmado em 0,2 s. Swing continua sem teste — o
equipamento da bancada não tem.

**Sobre o display, a conclusão anterior estava errada.** Eu havia escrito que o equipamento
não reporta esse estado. Reporta: no log de 17:48 o bit foi de 1 para 0 quando o **controle
físico** foi usado, e voltou. O bit não ter mudado nos testes anteriores tinha outra causa —
a polaridade, logo abaixo.

### ⚠️ A POLARIDADE NÃO É A MESMA EM TODOS OS COMANDOS (resolvido em 10/09/2026)

Defeito de raiz, e explica quase tudo que parecia lentidão ou comando perdido.

No log de 17:48, três transições seguidas e coerentes:

| Comando enviado | f[2] depois | O app mostrava |
|---|---|---|
| `01 02` rotulado *Desligar* | `9B` (bit7 = 1) | Ligado |
| `01 01` rotulado *Ligar* | `1B` (bit7 = 0) | Desligado |
| `01 02` rotulado *Desligar* | `9B` (bit7 = 1) | Ligado |

Mandar "Ligar" levava o bit a 0. **Confirmado no equipamento**: tocar em Ligar no app
*desligava* o ar. Ou seja, o bit de status está certo (1 = ligado) e **os valores é que
estavam trocados**.

A convenção real, medida:

| Comando | valor 1 | valor 2 |
|---|---|---|
| **energia** (`1`) | desliga | liga |
| **display** (`10`) | apaga | acende |
| **luz** (`28`) | acende | apaga |

**Não é uniforme** — a luz é o contrário das outras duas. Não uniformizar: o firmware é assim.
Está tudo na constante `ENERGIA` e no mapa `CHAVES`, no topo do script.

Com isso, o que parecia inexplicável se encaixa sem nenhum chute novo:

- os `0A 02` do log mandavam **acender** um display que já estava aceso → nada acontecia, e
  daí *"nenhuma vez o display apagou"*;
- na versão anterior um toque rápido chegava a mandar `0A 01` = apagar → foi **a vez que
  apagou**;
- os toques seguintes voltavam a mandar apagar → *"só não ligava novamente"*;
- e o "Desligar seguido de Ligar" que terminava em `1B`: o ar ficava **ligado**, e o app é
  que mostrava desligado.

Por isso o Display **voltou a ser chave liga/desliga**: o estado é reportado, e agora com a
polaridade certa.

⚠️ Sobra uma dedução não confirmada: o display seguir a mesma convenção da energia veio por
inferência, não por teste. A energia foi confirmada no equipamento.

### Retorno da bancada (10/09/2026) — o que o equipamento mostrou

Primeiro teste com o ar de verdade:

- **Entrada de ar não existe neste equipamento** — é sempre interno. O controle saiu do app
  (e o comando 68 saiu do simulador). O campo `windSide` continua sendo lido do quadro, só não
  é mais mostrado nem comandado.
- **Display funciona, mas demora** — precisa esperar. Não é comando errado; é resposta lenta.
  A hipótese de que o valor 2 estava errado **caiu**: o comando chega, a placa é que leva
  tempo.
- **Oscilação e luz não puderam ser testadas** — o equipamento da bancada não tem essas
  funções. A convenção de desligar (valor 2) continua **não confirmada** para elas.

Isso gerou duas mudanças:

**Estado de espera nos controles.** Antes o botão mentia: pintava de ciano na hora, com cara
de pronto, enquanto a placa ainda nem tinha processado. Agora **âmbar = enviado, aguardando o
aparelho; ciano = confirmado pelo status**. O estado sai de graça do `otim`: enquanto a marca
não foi resolvida, o controle está aguardando — daí o helper `aguardando()`, que precisa ser
chamado **depois** de `valor()`, que é quem resolve a marca. O prazo da marca subiu de 4,5 s
para 9 s, senão um comando lento expira antes de confirmar.

**Painel de requisições.** `#painelTec` mostra TX/RX e, o que interessa para este problema,
**quanto tempo cada comando levou até o equipamento confirmar**:

```
TX  5A 5A 06 01 0A 02 C7 0D 0A   Display off
RX  5A 5A 96 0A 1B 0D 08 02 19 15 ...
confirmado chv:display em 1.0 s
```

✅ **A validação de bancada terminou em 10/09/2026 e o painel voltou a nascer escondido.**
Ele é ferramenta de assistência: **5 toques no logo** do cabeçalho mostram, mais 5 escondem, e
a escolha fica no `localStorage`. Quem nunca fez o gesto nunca vê — testado com o
`localStorage` limpo.

O `log()` escreve no painel mesmo com ele escondido, então dá para ligar no meio de um teste e
o histórico já está lá.

### Bateria do caminhão (proteção de subtensão)

O ar corta sozinho quando a tensão cai, para o caminhão não ficar sem partida. O dado já
vinha no quadro de status e não estava sendo usado direito:

| Campo | O que é |
|---|---|
| `voltage` (f[8]) | tensão atual da bateria, em volts inteiros |
| `underV` (f[9]) | proteção de subtensão — tratado como **limite de corte** |
| `fault` 19 (`SPv`) e 37 (`SP`) | falhas de proteção de tensão |

Mostrar só o número não ajuda o motorista: o que importa é **a distância até o corte**. Daí
o cartão com a tensão grande, uma barra e a marca do limite, mais uma frase que muda de
estado: em ordem → *bateria baixa, falta pouco para o corte em X V* → *abaixo do limite* →
*desligado pela proteção*.

⚠️ **`underV` é interpretado, não documentado.** Só vira "limite em volts" quando o valor é
plausível (entre 9 e 32, e abaixo da tensão atual + 6). Se vier fora disso — pode ser
sinalizador em vez de limiar, dependendo da placa — o app mostra só a tensão e o sistema,
**sem inventar um número de corte**. Confirmar com o equipamento.

O sistema (12 V ou 24 V) é deduzido da própria leitura em `sistemaDe()`: abaixo de 18 V é 12.

O rótulo `Núcleo` virou **Temperatura interna** no diagnóstico, e `Tensão` saiu de lá — subiu
para o cartão de bateria.

⚠️ **Cuidado com nome de classe curto neste arquivo.** A marca do limite começou como
`.marca` e colidiu com a `.marca` do logo do cabeçalho (`height:34px`, circular). Como
`height` só estava declarado na regra do logo, ela vazava: o traço saía com 34 px em vez de
20 e invadia o texto — e a seletividade maior de `.bat-barra .marca` não protegia, porque não
declarava `height`. Por isso as peças do cartão são `.bat-marca` e `.bat-preenche`. Sendo um
arquivo único com todo o CSS junto, prefixo por componente não é preciosismo.

### iPhone — instala, mas não controla

Os passos de instalação no iPhone são outros (o menu é do Chrome, mas a instalação passa pelo
Compartilhar do iOS), e estão na tela em `#passosIphone`, escolhidos por `ehIOS`.

⚠️ **Instalar no iPhone não faz o Bluetooth funcionar.** Todo navegador do iOS usa o motor do
Safari — o Chrome do iPhone inclusive — e o WebKit não implementa Web Bluetooth. O app instala
e abre; simplesmente não acha o ar. Por isso a tela diz isso antes de a pessoa tentar:

| Situação | O que aparece |
|---|---|
| iPhone, no navegador | tela de instalação com os passos + *"Dá para instalar, mas o controle não vai conectar"* |
| iPhone, já instalado | **entra no app** (tela de conectar) com o aviso do aparelho fixo |
| Android | passos do Chrome, sem aviso |

⚠️ **Não barrar o app quando falta Bluetooth.** Uma versão do `roteia()` fazia isso, achando
que protegia o cliente. O efeito real foi prender o iPhone na tela de instalação *depois* de
ele já ter instalado — sem saída, e sem nem conseguir chegar ao modo teste. Quem explica a
limitação é o `#avisoSuporte`, que por isso vive **fora** das telas, ao lado do `#recado`, e
aparece nas duas. O botão "Procurar aparelho" também continua ativo: é por ele que se entra
no modo teste, e com um código de verdade o `conectar()` explica por que não vai.

Resolver de verdade exige app nativo — é a pendência de iPhone lá embaixo.

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

- [ ] **Confirmar o display com a polaridade nova** (`10 / 1` apaga, `10 / 2` acende). A
      energia foi confirmada no equipamento; o display segue a mesma convenção por dedução,
      e ainda não foi visto funcionando.
- [ ] **Validar o desligar da oscilação (swing).** Luz já foi confirmada na bancada
      (`1C 01`/`1C 02`); o display saiu das chaves por não ser reportado. Falta só o
      swing, e o equipamento onde se testou não tem essa função.
- [x] ~~Confirmar os offsets de `leStatus`~~ — **confirmados** no log de bancada de
      10/09/2026: ventilador, alvo, turbo e luz bateram exatos, checksum OK em 18 quadros.
- [ ] **Confirmar que 20,5 V é mesmo o corte** (`underV` = 205 em décimos). O número é
      plausível e constante, mas ninguém viu o ar cortar nessa tensão ainda.
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
