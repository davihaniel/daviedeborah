-- Habilitar extensão UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tabela de anfitriões
CREATE TABLE anfitriao (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nome            TEXT NOT NULL,
  numero          TEXT NOT NULL,
  confirmacao     BOOLEAN NOT NULL DEFAULT FALSE,
  dat_criacao     TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  dat_atualizacao TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  dat_exclusao    TIMESTAMP WITH TIME ZONE
);

COMMENT ON TABLE anfitriao IS 'Tabela do anfitrião';
COMMENT ON COLUMN anfitriao.id IS 'ID auto gerado';
COMMENT ON COLUMN anfitriao.nome IS 'Nome do anfitrião';
COMMENT ON COLUMN anfitriao.numero IS 'Número do anfitrião (telefone)';
COMMENT ON COLUMN anfitriao.confirmacao IS 'Confirmação de presença';
COMMENT ON COLUMN anfitriao.dat_criacao IS 'Data de criação';
COMMENT ON COLUMN anfitriao.dat_atualizacao IS 'Data de atualização';
COMMENT ON COLUMN anfitriao.dat_exclusao IS 'Data de exclusão (soft delete)';

-- Tabela de convidados
CREATE TABLE convidado (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nome            TEXT NOT NULL,
  idade           INTEGER,
  id_anfitriao    UUID NOT NULL REFERENCES anfitriao(id) ON DELETE CASCADE,
  dat_criacao     TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  dat_atualizacao TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  dat_exclusao    TIMESTAMP WITH TIME ZONE
);

COMMENT ON TABLE convidado IS 'Tabela de convidados';
COMMENT ON COLUMN convidado.id IS 'ID auto gerado';
COMMENT ON COLUMN convidado.nome IS 'Nome do convidado';
COMMENT ON COLUMN convidado.idade IS 'Idade se for uma criança';
COMMENT ON COLUMN convidado.id_anfitriao IS 'ID do anfitrião';
COMMENT ON COLUMN convidado.dat_criacao IS 'Data de criação';
COMMENT ON COLUMN convidado.dat_atualizacao IS 'Data de atualização';
COMMENT ON COLUMN convidado.dat_exclusao IS 'Data de exclusão (soft delete)';

-- Tabela de recados
CREATE TABLE recado (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nome         TEXT NOT NULL,
  mensagem     TEXT NOT NULL,
  aprovado     BOOLEAN NOT NULL DEFAULT FALSE,
  dat_criacao  TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  dat_exclusao TIMESTAMP WITH TIME ZONE
);

COMMENT ON TABLE recado IS 'Tabela de recados';
COMMENT ON COLUMN recado.id IS 'ID auto gerado';
COMMENT ON COLUMN recado.nome IS 'Nome do autor';
COMMENT ON COLUMN recado.mensagem IS 'Mensagem do recado';
COMMENT ON COLUMN recado.aprovado IS 'Se é um recado aprovado';
COMMENT ON COLUMN recado.dat_criacao IS 'Data de criação';
COMMENT ON COLUMN recado.dat_exclusao IS 'Data de exclusão (soft delete)';

-- Criar índices para melhor performance
CREATE INDEX idx_convidado_id_anfitriao ON convidado(id_anfitriao);
CREATE INDEX idx_recado_aprovado ON recado(aprovado);
CREATE INDEX idx_anfitriao_confirmacao ON anfitriao(confirmacao);

-- Criar função para atualizar dat_atualizacao automaticamente
CREATE OR REPLACE FUNCTION update_dat_atualizacao()
RETURNS TRIGGER AS $$
BEGIN
  NEW.dat_atualizacao = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criar triggers para atualizar dat_atualizacao
CREATE TRIGGER trigger_anfitriao_update
BEFORE UPDATE ON anfitriao
FOR EACH ROW
EXECUTE FUNCTION update_dat_atualizacao();

CREATE TRIGGER trigger_convidado_update
BEFORE UPDATE ON convidado
FOR EACH ROW
EXECUTE FUNCTION update_dat_atualizacao();

-- ============================================
-- POLÍTICAS DE SEGURANÇA (RLS)
-- ============================================

-- Habilitar RLS nas tabelas
ALTER TABLE anfitriao ENABLE ROW LEVEL SECURITY;
ALTER TABLE convidado ENABLE ROW LEVEL SECURITY;
ALTER TABLE recado ENABLE ROW LEVEL SECURITY;

-- ============================================
-- POLÍTICAS PARA TABELA: anfitriao
-- ============================================

-- Qualquer usuário pode selecionar (SELECT)
CREATE POLICY "Qualquer um pode selecionar anfitriao"
ON anfitriao
FOR SELECT
USING (true);

-- Qualquer usuário pode inserir (INSERT)
CREATE POLICY "Qualquer um pode inserir anfitriao"
ON anfitriao
FOR INSERT
WITH CHECK (true);

-- Apenas usuários autenticados podem atualizar (UPDATE)
CREATE POLICY "Apenas autenticados podem atualizar anfitriao"
ON anfitriao
FOR UPDATE
USING (auth.role() = 'authenticated')
WITH CHECK (auth.role() = 'authenticated');

-- Apenas usuários autenticados podem deletar (DELETE)
CREATE POLICY "Apenas autenticados podem deletar anfitriao"
ON anfitriao
FOR DELETE
USING (auth.role() = 'authenticated');

-- ============================================
-- POLÍTICAS PARA TABELA: convidado
-- ============================================

-- Qualquer usuário pode selecionar (SELECT)
CREATE POLICY "Qualquer um pode selecionar convidado"
ON convidado
FOR SELECT
USING (true);

-- Qualquer usuário pode inserir (INSERT)
CREATE POLICY "Qualquer um pode inserir convidado"
ON convidado
FOR INSERT
WITH CHECK (true);

-- Apenas usuários autenticados podem atualizar (UPDATE)
CREATE POLICY "Apenas autenticados podem atualizar convidado"
ON convidado
FOR UPDATE
USING (auth.role() = 'authenticated')
WITH CHECK (auth.role() = 'authenticated');

-- Apenas usuários autenticados podem deletar (DELETE)
CREATE POLICY "Apenas autenticados podem deletar convidado"
ON convidado
FOR DELETE
USING (auth.role() = 'authenticated');

-- ============================================
-- POLÍTICAS PARA TABELA: recado
-- ============================================

-- Qualquer usuário pode selecionar (SELECT)
CREATE POLICY "Qualquer um pode selecionar recado"
ON recado
FOR SELECT
USING (true);

-- Qualquer usuário pode inserir (INSERT)
CREATE POLICY "Qualquer um pode inserir recado"
ON recado
FOR INSERT
WITH CHECK (true);

-- Apenas usuários autenticados podem atualizar (UPDATE)
CREATE POLICY "Apenas autenticados podem atualizar recado"
ON recado
FOR UPDATE
USING (auth.role() = 'authenticated')
WITH CHECK (auth.role() = 'authenticated');

-- Apenas usuários autenticados podem deletar (DELETE)
CREATE POLICY "Apenas autenticados podem deletar recado"
ON recado
FOR DELETE
USING (auth.role() = 'authenticated');
