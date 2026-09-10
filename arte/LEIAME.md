# Arte e geração dos ícones

`simbolo-stonni.png` — símbolo oficial da Stonni, **2560×2560 PNG com transparência**,
baixado de `stonni.com.br/wp-content/uploads/2025/09/simbolo-stonni-azul-claro-scaled-1.png`
(há também as versões `azul-escuro` e `branco` no mesmo lugar).

## Regerar os ícones

```
node arte/gera-icones.js
```

Escreve em `icons/`: 192, 512, maskable-512, apple-touch (180) e favicon (32), todos com o
símbolo sobre `#0A0E13` (o fundo do app).

Depende de **`@napi-rs/canvas`**, que não é instalado aqui — o script aponta para o que já
existe em `bononi-exped\node_modules`. Não há Pillow nem ImageMagick nesta máquina.

## Por que os ícones são locais

Um app instalado que busca o ícone no WordPress fica refém do site estar no ar. Além disso o
Chrome no Android só oferece "Instalar" com ícones de 192 e 512 que ele consiga baixar.

## O erro a não repetir

O `manifest.json` do `com_stonni` declara um **JPEG 1999×538** como PNG 192×192 e 512×512 — as
três afirmações são falsas, e por isso aquele app provavelmente não passa nos critérios de
instalação. Depois de gerar, confira sempre assinatura e dimensão reais do arquivo.
