# Publicar na Hostinger (enquanto o domínio não estiver na Vercel)

> Escrito em 11/09/2026, depois de descobrir que `controle.stonni.com.br` servia a **v14** —
> treze versões atrás — e expunha `docs/STATUS.md`, `bancada/testador-ble.html` e `README.md`
> em HTTP 200. O protocolo do equipamento estava legível no endereço oficial da Stonni.

## Por que isto existe

O `controle.stonni.com.br` **não está na Vercel**. Está na Hostinger, no mesmo servidor do
WordPress (`platform: hostinger`, `panel: hpanel`, `x-turbo-charged-by: LiteSpeed`).

Consequência: **dar push no GitHub não atualiza esse endereço.** Cada versão precisa de um envio
manual — e foi exatamente por isso que ficou treze versões para trás sem ninguém notar.

⚠️ **A solução definitiva é mover o domínio para a Vercel**, onde o deploy é automático a cada
push. Enquanto isso não acontece, use este procedimento — ele existe para o erro não se repetir,
não para ser permanente.

## Como gerar o pacote

```
publicar\gerar.cmd
```

Gera `publicar\controle-stonni.zip` com **exatamente** o que pode ficar público:

```
index.html
manifest.json
sw.js
.htaccess
icons/icon-192.png
icons/icon-512.png
icons/icon-maskable-512.png
icons/apple-touch-icon.png
icons/favicon.png
```

É a mesma lista que o `.github/workflows/pages.yml` publica no GitHub Pages — de propósito, para
os dois endereços servirem a mesma coisa.

## Como enviar

1. **Antes de tudo, apagar no servidor** as pastas `docs/`, `bancada/`, `arte/`, `supabase/` e o
   `README.md`, se ainda existirem. **Enviar o pacote não apaga nada** — só sobrescreve.
2. hPanel → Gerenciador de Arquivos → pasta do subdomínio `controle.stonni.com.br`
3. Enviar o `controle-stonni.zip` e extrair ali, sobrescrevendo
4. Conferir que o `.htaccess` foi junto (o Gerenciador esconde arquivos que começam com ponto —
   ligar "mostrar arquivos ocultos")

## Como conferir que deu certo

Abrir cada um destes. Os três primeiros **têm que dar 404**:

```
https://controle.stonni.com.br/docs/STATUS.md
https://controle.stonni.com.br/bancada/testador-ble.html
https://controle.stonni.com.br/README.md
```

E o app tem que mostrar o carimbo de versão novo no rodapé. Se mostrar o antigo, o Cloudflare está
com cache — limpar em Caching → Purge Everything.

## O que o `.htaccess` faz

Devolve 404 para `docs/`, `bancada/`, `arte/`, `supabase/`, `.git*` e para qualquer `.md`, `.sql`,
`.yml`, `.py` ou `.log`. É a **segunda** barreira: se um dia alguém enviar a pasta inteira de novo,
o vazamento não volta. Não substitui apagar os arquivos — um servidor mal configurado pode ignorar
o `.htaccess`.
