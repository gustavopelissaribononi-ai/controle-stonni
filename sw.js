// ============================================================
//  SERVICE WORKER — Ar-condicionado Stonni (PWA)
//  O app precisa abrir sem internet: o controle é Bluetooth, e
//  quem usa está na estrada. Estratégia: network-first para a
//  casca (deploy novo sempre vence quando online), cache como
//  fallback offline. Fontes do Google vão de cache-first.
//
//  Nada aqui depende de stonni.com.br — os ícones são locais de
//  propósito, senão um app "instalado" ficaria refém do site.
//
//  ⚠️ Ao subir um deploy, BUMPAR VERSAO para invalidar o cache.
// ============================================================
const VERSAO = 'stonni-ar-v11-20260910';
const CASCA = [
  './',
  './index.html',
  './manifest.json',
  './icons/icon-192.png',
  './icons/icon-512.png',
  './icons/icon-maskable-512.png',
  './icons/apple-touch-icon.png',
  './icons/favicon.png',
];

self.addEventListener('install', (ev) => {
  self.skipWaiting();
  ev.waitUntil(
    caches.open(VERSAO).then((c) => Promise.allSettled(CASCA.map((u) => c.add(u))))
  );
});

self.addEventListener('activate', (ev) => {
  ev.waitUntil(
    caches.keys()
      .then((ks) => Promise.all(ks.filter((k) => k !== VERSAO).map((k) => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', (ev) => {
  const req = ev.request;
  if (req.method !== 'GET') return;

  const url = new URL(req.url);
  const ehFonte = url.hostname === 'fonts.googleapis.com' || url.hostname === 'fonts.gstatic.com';

  // fontes do Google: cache-first (não mudam, e economizam dado no celular)
  if (ehFonte) {
    ev.respondWith(
      caches.match(req).then((hit) => hit || fetch(req).then((res) => {
        const copia = res.clone();
        caches.open(VERSAO).then((c) => c.put(req, copia)).catch(() => {});
        return res;
      }).catch(() => hit))
    );
    return;
  }

  // casca do app: network-first, cai para o cache quando offline
  if (url.origin === location.origin) {
    ev.respondWith(
      fetch(req).then((res) => {
        const copia = res.clone();
        caches.open(VERSAO).then((c) => c.put(req, copia)).catch(() => {});
        return res;
      }).catch(() => caches.match(req).then((hit) => hit || caches.match('./index.html')))
    );
  }
});
