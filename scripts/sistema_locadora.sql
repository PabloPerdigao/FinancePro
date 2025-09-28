-- Sistema de Locadora - Finance Pro
-- Script de criação do banco de dados para sistema de locadora

-- Criação da base de dados
CREATE DATABASE IF NOT EXISTS sistema_locadora;
USE sistema_locadora;

-- Tabela de Clientes
CREATE TABLE clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome_completo VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefone VARCHAR(15),
    endereco TEXT,
    data_nascimento DATE,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ativo BOOLEAN DEFAULT TRUE
);

-- Tabela de Categorias de Produtos
CREATE TABLE categorias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    descricao TEXT,
    ativo BOOLEAN DEFAULT TRUE
);

-- Tabela de Produtos/Equipamentos
CREATE TABLE produtos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    categoria_id INT,
    valor_diaria DECIMAL(10,2) NOT NULL,
    quantidade_disponivel INT DEFAULT 0,
    codigo_barras VARCHAR(50),
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ativo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id)
);

-- Tabela de Locações
CREATE TABLE locacoes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    data_locacao DATE NOT NULL,
    data_prevista_devolucao DATE NOT NULL,
    data_devolucao DATE,
    valor_total DECIMAL(10,2),
    status ENUM('ativo', 'devolvido', 'atrasado', 'cancelado') DEFAULT 'ativo',
    observacoes TEXT,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

-- Tabela de Itens da Locação
CREATE TABLE itens_locacao (
    id INT AUTO_INCREMENT PRIMARY KEY,
    locacao_id INT NOT NULL,
    produto_id INT NOT NULL,
    quantidade INT NOT NULL,
    valor_unitario DECIMAL(10,2) NOT NULL,
    dias_locacao INT NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (locacao_id) REFERENCES locacoes(id),
    FOREIGN KEY (produto_id) REFERENCES produtos(id)
);

-- Tabela de Pagamentos
CREATE TABLE pagamentos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    locacao_id INT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    data_pagamento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    forma_pagamento ENUM('dinheiro', 'cartao_credito', 'cartao_debito', 'pix', 'transferencia') NOT NULL,
    status ENUM('pendente', 'aprovado', 'recusado') DEFAULT 'pendente',
    observacoes TEXT,
    FOREIGN KEY (locacao_id) REFERENCES locacoes(id)
);

-- Inserção de dados iniciais

-- Categorias padrão
INSERT INTO categorias (nome, descricao) VALUES 
('Eletrônicos', 'Equipamentos eletrônicos diversos'),
('Ferramentas', 'Ferramentas manuais e elétricas'),
('Eventos', 'Equipamentos para festas e eventos'),
('Esportes', 'Equipamentos esportivos'),
('Automóveis', 'Veículos e acessórios automotivos');

-- Produtos exemplo
INSERT INTO produtos (nome, descricao, categoria_id, valor_diaria, quantidade_disponivel, codigo_barras) VALUES 
('Furadeira Elétrica', 'Furadeira elétrica profissional 1000W', 2, 15.00, 5, '1234567890123'),
('Sistema de Som', 'Sistema de som completo para eventos', 3, 80.00, 2, '1234567890124'),
('Bicicleta Mountain Bike', 'Bicicleta para trilhas e passeios', 4, 25.00, 8, '1234567890125'),
('Notebook Gaming', 'Notebook para jogos e trabalho', 1, 45.00, 3, '1234567890126');

-- Cliente exemplo
INSERT INTO clientes (nome_completo, cpf, email, telefone, endereco, data_nascimento) VALUES 
('João Silva Santos', '123.456.789-00', 'joao.silva@email.com', '(11) 98765-4321', 'Rua das Flores, 123 - São Paulo, SP', '1985-06-15');

-- Índices para melhor performance
CREATE INDEX idx_clientes_cpf ON clientes(cpf);
CREATE INDEX idx_clientes_email ON clientes(email);
CREATE INDEX idx_locacoes_cliente ON locacoes(cliente_id);
CREATE INDEX idx_locacoes_data ON locacoes(data_locacao);
CREATE INDEX idx_locacoes_status ON locacoes(status);
CREATE INDEX idx_produtos_categoria ON produtos(categoria_id);
CREATE INDEX idx_itens_locacao_locacao ON itens_locacao(locacao_id);
CREATE INDEX idx_itens_locacao_produto ON itens_locacao(produto_id);
CREATE INDEX idx_pagamentos_locacao ON pagamentos(locacao_id);

-- Views úteis

-- View de locações em andamento
CREATE VIEW locacoes_ativas AS
SELECT 
    l.id,
    c.nome_completo as cliente,
    l.data_locacao,
    l.data_prevista_devolucao,
    l.valor_total,
    l.status,
    DATEDIFF(CURDATE(), l.data_prevista_devolucao) as dias_atraso
FROM locacoes l
JOIN clientes c ON l.cliente_id = c.id
WHERE l.status IN ('ativo', 'atrasado');

-- View de produtos disponíveis
CREATE VIEW produtos_disponiveis AS
SELECT 
    p.id,
    p.nome,
    p.descricao,
    c.nome as categoria,
    p.valor_diaria,
    p.quantidade_disponivel
FROM produtos p
JOIN categorias c ON p.categoria_id = c.id
WHERE p.ativo = TRUE AND p.quantidade_disponivel > 0;

-- View de faturamento por período
CREATE VIEW faturamento_mensal AS
SELECT 
    YEAR(l.data_locacao) as ano,
    MONTH(l.data_locacao) as mes,
    COUNT(*) as total_locacoes,
    SUM(l.valor_total) as faturamento_total,
    AVG(l.valor_total) as ticket_medio
FROM locacoes l
WHERE l.status != 'cancelado'
GROUP BY YEAR(l.data_locacao), MONTH(l.data_locacao)
ORDER BY ano DESC, mes DESC;