CREATE DATABASE naramarket;

USE naramarket;

CREATE TABLE lojas (
	-- O auto significa que o ID atualiza de forma dinamica conforme você adiciona dados e declara como primary key 
    -- No caso em especifico ele foi apagado porque o csv já temm esse dado 
	id_loja INT PRIMARY KEY, 
	nome VARCHAR(100) NOT NULL,
	bairro VARCHAR(50)
);

CREATE TABLE produtos (
	id_produto INT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    categoria VARCHAR(100) NOT NULL,
    preco DECIMAL(10, 2)
);

CREATE TABLE vendas (
	id_venda INT KEY,
	id_produto INT NOT NULL,
	id_loja INT NOT NULL,
	quantidade INT,
	valor DECIMAL(8,2),
	data_venda DATE,
	FOREIGN KEY (id_produto) -- não necessariamente o id_ da tabela atual vai ter o mesmo nome do id da tabela da chave estrangeira (a tabela onde ela é primária)
		REFERENCES produtos(id_produto),
	FOREIGN KEY (id_loja)
		REFERENCES lojas(id_loja)
);

-- Apenas o DBA tem essa permissão normalmente nas empresas, por questões de segurança
SET GLOBAL local_infile = 1;

-- Sempre fique atento na ordem, faça primeiro as tables que não são fato
LOAD DATA INFILE 'C:/Users/ian.iannacconi/Downloads/naramarket/naramarket_lojas.csv'
INTO TABLE lojas
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n' -- cada linha é um novo registro
-- Ignora a primeira linha
IGNORE 1 ROWS
(id_loja, nome, bairro); -- Tem que ser na ordem do CREATE TABLE

LOAD DATA INFILE 'C:/Users/ian.iannacconi/Downloads/naramarket/naramarket_produtos.csv'
INTO TABLE produtos
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS
(id_produto, nome, categoria, preco); 

LOAD DATA INFILE 'C:/Users/ian.iannacconi/Downloads/naramarket/naramarket_vendas.csv'
INTO TABLE vendas
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS
(id_venda, id_produto, id_loja, quantidade, valor, data_venda); 

-- WHERE é um contexto de filtro de simples
SELECT * FROM vendas
WHERE valor > 100;

-- Ordenar do maior para o menor e limit já se explica automáticamente 
SELECT id_produto, valor FROM vendas
ORDER BY valor DESC
LIMIT 5;

SELECT id_produto, valor FROM vendas
WHERE id_loja = 3;

-- Isso funciona porque é o dado data e precisa das aspas
SELECT id_produto, valor, data_venda FROM vendas
WHERE data_venda >= '2024-03-01'
AND data_venda <= '2024-03-31';

-- Poupa tempo e usos do AND
SELECT id_produto, valor FROM vendas
WHERE id_produto IN (5, 12, 47);

-- Where serve para tabelas e não para colunas que são criadas por consultas já uque elas usam o having
SELECT id_produto, SUM(valor) AS total_vendas -- O AS define o resultado da soma criando uma coluna, ela só existe na consulta
FROM vendas
WHERE data_venda >= '2024-06-01'
-- Agrupa produtos e ordena por total de vendas
GROUP BY id_produto
HAVING total_vendas >= 10000
ORDER BY total_vendas DESC;

-- Quantidade de vendas por loja, só contar pelo id já que isso te leva para quantidade
SELECT id_loja, COUNT(id_venda) AS quantidade
FROM vendas
GROUP BY id_loja;

-- JOIN, só funciona quando as tabelas estão relacionadas. Lembrando que ele só pega as interseções das tabelas (literal igual conjutos de matématica)
-- FROM é usado para a tabela fato (normalmente)
-- INNER JOIN é a tabela que vai ser cruzada já o ON diz a coluna que liga as tabelas, o INNER é mais técnico já que o JOIN sozinho funciona
SELECT v.id_venda, p.nome, p.categoria, v.valor -- O v é um jeito de chamar a tabela vendas, o mesmo com produtos
FROM vendas v -- Declaração da chamada da tabela vendas
-- O que ta no FROM é sempre o da esquerda e também vem primeiro no ON
INNER JOIN produtos p ON v.id_produto = p.id_produto; -- ELe iguala o id(chave estrangeira x primaria) produto das duas tabelas e adiciona o nome do produto + categoria

CREATE TABLE cliente_farma (
	id INT PRIMARY KEY,
	nome VARCHAR(100)
);
CREATE TABLE vendas_farma (
	id INT PRIMARY KEY,
    id_cliente INT,
    FOREIGN KEY (id_cliente)
    REFERENCES cliente_farma(id)
);
INSERT INTO cliente_farma (id, nome)
VALUES (1, 'Haru Urara'),
(2, 'Izuku midoriya'),
(3, 'Special Week'),
(4, 'MaoMao');
INSERT INTO vendas_farma (id, id_cliente)
VALUES (1, 4),
(2, 2),
(3, 2),
(4, 4);
INSERT INTO vendas_farma (id) -- Venda sem cliente identificado
VALUES (5);
SELECT * FROM cliente_farma;
SELECT * FROM vendas_farma;
-- TESTE DE LEFT E RIGHT JOIN
SELECT v.id, c.nome  -- INNER JOIN
FROM vendas_farma v 
INNER JOIN cliente_farma c ON v.id_cliente = c.id; 
SELECT v.id, c.nome -- RIGHT JOIN, quem não comprou aparece com o id da venda null (não confunda com nulo porque o null seria a ausência de dados)
FROM vendas_farma v 
RIGHT JOIN cliente_farma c ON v.id_cliente = c.id; 
SELECT v.id, c.nome -- LEFT JOIN
FROM vendas_farma v 
LEFT JOIN cliente_farma c ON v.id_cliente = c.id; 

-- Continuação do Naramarket
SELECT l.bairro, SUM(v.valor) AS faturamento
FROM vendas v
JOIN lojas l ON v.id_loja = l.id_loja
-- GROU BY vem depois do JOIN, já que primeiro tem que cruzar os dados para depois agrupar
GROUP BY l.bairro
HAVING faturamento > 60000
ORDER BY faturamento DESC;

SELECT p.categoria, SUM(v.valor) AS faturamento
FROM vendas v
JOIN produtos p ON v.id_loja = p.id_produto
GROUP BY p.categoria
HAVING faturamento > 10000
ORDER BY faturamento DESC;


DROP TABLE lojas;