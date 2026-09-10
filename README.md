# controle-stonni — ar-condicionado Stonni

Controle remoto do ar-condicionado Stonni por **Bluetooth LE**, direto do navegador do celular.
App do cliente final: sem servidor, sem login, sem internet. Instala na tela inicial do Android.

Destino: **https://controle.stonni.com.br** (subdomínio na Vercel, link a partir do site).

## Rodar localmente

Web Bluetooth só funciona em **https** ou **localhost**.

```
preview_start  ->  app-stonni-ar     (porta 5286)
```

O service worker **não registra em localhost** de propósito — cache de SW já escondeu semanas
de trabalho neste grupo. Testar instalação e offline exige um https de verdade.

## Testar de verdade

**Chrome no Android.** Safari do iPhone não expõe Bluetooth para página web; o app avisa e
explica. O nome do aparelho está no QR Code colado no equipamento — em branco, a busca lista
tudo que começa com `KT`.

## Arquivos

| Arquivo | O que é |
|---|---|
| `index.html` | o app inteiro — protocolo, tela e estilo |
| `manifest.json` | PWA: nome, ícones, `standalone` |
| `sw.js` | cache offline; **bumpar `VERSAO` a cada deploy** |
| `vercel.json` | rewrites, headers de segurança e de cache |
| `.vercelignore` | mantém `bancada/`, `arte/` e `docs/` fora do ar |
| `icons/` | ícones gerados (192, 512, maskable, apple-touch, favicon) |
| `arte/` | símbolo 2560px + script que gera os ícones — ver `arte/LEIAME.md` |
| `bancada/testador-ble.html` | testador de protocolo, com log e envio bruto. **Não vai para o ar** |
| `docs/STATUS.md` | estado do projeto, protocolo e pendências |

Comece pelo `docs/STATUS.md`.

## O que este app não tem, de propósito

- **Painel técnico.** Envio bruto de comando não fica exposto a quem abrir o site. O log de
  quadros vai para o console do navegador (`chrome://inspect` resolve para a assistência), e
  quem precisa mexer no protocolo usa `bancada/testador-ble.html`.
- **Supabase, Hub, login.** Não há o que autenticar: o app conversa só com a placa.
