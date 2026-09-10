/* Gera os ícones PWA do app Stonni a partir do símbolo oficial 2560x2560.
   Usa @napi-rs/canvas que já existe no node_modules do bononi-exped. */
const { createCanvas, loadImage } = require('C:/Aplicações da bononi/bononi-exped/node_modules/@napi-rs/canvas');
const fs = require('fs');
const path = require('path');

const BASE  = 'C:/Aplicações da bononi/controle-stonni';
const FONTE = path.join(BASE, 'arte/simbolo-stonni.png');
const SAIDA = path.join(BASE, 'icons');
const FUNDO = '#0A0E13';           // mesmo --fundo do app

(async () => {
  const img = await loadImage(FONTE);
  console.log('fonte:', img.width + 'x' + img.height);

  /* --- acha o retângulo real do símbolo dentro do PNG ---
     O arquivo é 2560x2560, mas a arte pode não ocupar tudo. Mede num
     rascunho de 256px (rápido) e escala o resultado de volta. */
  const A = 256, k = img.width / A;
  const rasc = createCanvas(A, A);
  const rc = rasc.getContext('2d');
  rc.drawImage(img, 0, 0, A, A);
  const px = rc.getImageData(0, 0, A, A).data;
  let x0 = A, y0 = A, x1 = -1, y1 = -1;
  for (let y = 0; y < A; y++) {
    for (let x = 0; x < A; x++) {
      if (px[(y * A + x) * 4 + 3] > 12) {
        if (x < x0) x0 = x; if (x > x1) x1 = x;
        if (y < y0) y0 = y; if (y > y1) y1 = y;
      }
    }
  }
  const cx = Math.max(0, Math.floor(x0 * k));
  const cy = Math.max(0, Math.floor(y0 * k));
  const cw = Math.min(img.width  - cx, Math.ceil((x1 - x0 + 1) * k));
  const ch = Math.min(img.height - cy, Math.ceil((y1 - y0 + 1) * k));
  console.log('símbolo real:', cw + 'x' + ch, 'em (' + cx + ',' + cy + ')');

  /* fracao = quanto da largura do ícone o símbolo ocupa */
  function gerar(nome, tam, fracao, comFundo) {
    const cv = createCanvas(tam, tam);
    const g = cv.getContext('2d');
    if (comFundo) { g.fillStyle = FUNDO; g.fillRect(0, 0, tam, tam); }
    const alvo = tam * fracao;
    const esc = Math.min(alvo / cw, alvo / ch);
    const w = cw * esc, h = ch * esc;
    g.drawImage(img, cx, cy, cw, ch, (tam - w) / 2, (tam - h) / 2, w, h);
    const buf = cv.toBuffer('image/png');
    fs.writeFileSync(path.join(SAIDA, nome), buf);
    console.log(nome.padEnd(26), tam + 'x' + tam, String(buf.length).padStart(7) + ' bytes',
                '· símbolo ' + Math.round(fracao * 100) + '%');
  }

  fs.mkdirSync(SAIDA, { recursive: true });

  // "any": o Android desenha o PNG como veio, então já vai com o fundo do app
  gerar('icon-192.png',          192, 0.78, true);
  gerar('icon-512.png',          512, 0.78, true);
  // maskable: o launcher recorta em círculo/squircle. Conteúdo dentro dos 60% centrais.
  gerar('icon-maskable-512.png', 512, 0.58, true);
  gerar('apple-touch-icon.png',  180, 0.78, true);
  gerar('favicon.png',            32, 0.88, true);
})().catch(e => { console.error('FALHOU:', e.message); process.exit(1); });
