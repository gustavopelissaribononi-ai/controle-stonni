-- ============================================================================
--  controle-stonni · cadastro de equipamento do cliente final
--  Escrito em 10/09/2026. NÃO APLICADO — aguarda revisão.
--
--  Contexto: o app do ar-condicionado passa a ter login do cliente final
--  (e-mail/senha e Google). Depois de entrar, ele escaneia o código de barras
--  (SKU) e o QR Code do equipamento uma vez; o vínculo fica guardado aqui.
--
--  ⚠️ LEIA A SEÇÃO DE RLS ANTES DE APLICAR. Este é o primeiro app do grupo
--     aberto ao PÚBLICO, e isso muda o risco de deixar RLS desligado.
-- ============================================================================

create table if not exists public.stonni_ar_equipamentos (
  id         uuid        primary key default gen_random_uuid(),
  user_id    uuid        not null references auth.users(id) on delete cascade,
  sku        text        not null,
  aparelho   text        not null,          -- nome BLE do módulo, ex.: KT2026050014629
  apelido    text,                          -- "ar da cabine", dado pelo dono
  criado_em  timestamptz not null default now(),

  -- o mesmo dono não cadastra o mesmo aparelho duas vezes
  constraint stonni_ar_equip_unico unique (user_id, aparelho)
);

comment on table  public.stonni_ar_equipamentos is
  'Equipamentos que cada cliente final cadastrou no app de controle do ar Stonni.';
comment on column public.stonni_ar_equipamentos.aparelho is
  'Nome do módulo Bluetooth lido do QR Code colado no equipamento.';
comment on column public.stonni_ar_equipamentos.sku  is
  'Código de barras do produto, lido no cadastro. Guardado como veio, sem validação.';

create index if not exists stonni_ar_equip_user on public.stonni_ar_equipamentos (user_id);

-- ---------------------------------------------------------------------------
--  RLS — aqui não é opcional
--
--  O app é público e leva a anon key embutida, como todo app estático. Sem RLS,
--  qualquer cliente conseguiria ler a tabela inteira: quem comprou o quê, com
--  qual número de série. Com RLS, cada um enxerga só as próprias linhas.
--
--  Isto NÃO mexe nas tabelas existentes: RLS é por tabela, e esta nasce agora.
--  (O grupo tem RLS desligado no resto — ver references/seguranca.md. Ligar em
--  tabela nova não tem relação com aquele rollout.)
-- ---------------------------------------------------------------------------
alter table public.stonni_ar_equipamentos enable row level security;

create policy "dono lê o próprio equipamento"
  on public.stonni_ar_equipamentos for select
  using (auth.uid() = user_id);

create policy "dono cadastra no próprio nome"
  on public.stonni_ar_equipamentos for insert
  with check (auth.uid() = user_id);

create policy "dono edita o próprio equipamento"
  on public.stonni_ar_equipamentos for update
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "dono remove o próprio equipamento"
  on public.stonni_ar_equipamentos for delete
  using (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
--  Conferência depois de aplicar
-- ---------------------------------------------------------------------------
-- select relrowsecurity from pg_class where relname = 'stonni_ar_equipamentos';
--   -> tem que voltar true
-- select policyname, cmd from pg_policies where tablename = 'stonni_ar_equipamentos';
--   -> tem que listar as quatro políticas acima
