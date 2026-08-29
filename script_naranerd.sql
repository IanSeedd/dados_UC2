CREATE DATABASE naranerd;
USE naranerd;

-- CRIAÇÃO DAS TABELAS:
CREATE TABLE clientes (
	id INT PRIMARY KEY,
    nome VARCHAR(200),
    email VARCHAR(200),
    cidade VARCHAR(200)
);

CREATE TABLE vendedores (
	id INT PRIMARY KEY,
    nome VARCHAR(200),
    loja VARCHAR(200)
);

CREATE TABLE produtos (
	id INT PRIMARY KEY,
    nome VARCHAR(200),
    categoria VARCHAR(200),
    preco DECIMAL(10, 2)
);

CREATE TABLE vendas (
	id INT PRIMARY KEY,
    id_cliente INT,
    id_vendedor INT,
    id_produto INT,
    quantidade INT,
    valor DECIMAL(10, 2),
    data_venda DATE,
    FOREIGN KEY (id_cliente)
		REFERENCES clientes(id),
	FOREIGN KEY (id_vendedor)
		REFERENCES vendedores(id),
	FOREIGN KEY (id_produto)
		REFERENCES produtos(id)
);

SET GLOBAL local_infile = 1;

-- IMPORTAÇÕES:

LOAD DATA INFILE "C:/Users/ian.iannacconi/Downloads/naranerd/naranerd_clientes.csv"
INTO TABLE clientes
FIELDS TERMINATED BY ","
LINES TERMINATED BY "\n"
IGNORE 1 ROWS
(id, nome, email, cidade);

LOAD DATA INFILE "C:/Users/ian.iannacconi/Downloads/naranerd/naranerd_vendedores.csv"
INTO TABLE vendedores
FIELDS TERMINATED BY ","
LINES TERMINATED BY "\n"
IGNORE 1 ROWS
(id, nome, loja);

LOAD DATA INFILE "C:/Users/ian.iannacconi/Downloads/naranerd/naranerd_produtos.csv"
INTO TABLE produtos
FIELDS TERMINATED BY ","
LINES TERMINATED BY "\n"
IGNORE 1 ROWS
(id, nome, categoria, preco);

LOAD DATA INFILE "C:/Users/ian.iannacconi/Downloads/naranerd/naranerd_vendas.csv"
INTO TABLE vendas
FIELDS TERMINATED BY ","
LINES TERMINATED BY "\n"
IGNORE 1 ROWS
(id, id_cliente, id_vendedor, id_produto, quantidade, valor, data_venda);

SELECT data_venda FROM VENDAS;

-- Filtros / perguntas de negocio: 
SELECT c.id, c.nome, SUM(v.valor) AS valor_total
FROM vendas v
JOIN clientes c ON v.id_cliente = c.id
GROUP BY c.nome, c.id
ORDER BY valor_total DESC;

SELECT ven.id, ven.nome, COUNT(v.id) AS total_vendas
FROM vendas v
JOIN vendedores ven ON v.id_vendedor = ven.id
GROUP BY ven.nome, ven.id
ORDER BY total_vendas DESC;

SELECT p.categoria, SUM(v.valor) AS valor_total
FROM vendas v
JOIN produtos p ON v.id_produto = p.id
GROUP BY p.categoria
ORDER BY valor_total DESC;

SELECT ven.id, ven.nome, c.cidade, COUNT(v.id) AS total_vendas
FROM vendas v
JOIN vendedores ven ON v.id_vendedor = ven.id
JOIN clientes c ON v.id_cliente = c.id
GROUP BY ven.nome, c.cidade, ven.id
ORDER BY total_vendas DESC;

SELECT ven.id, ven.nome, p.categoria, ROUND(AVG(v.valor), 2) AS media
FROM vendas v
JOIN vendedores ven ON v.id_vendedor = ven.id
JOIN produtos p ON v.id_produto = p.id
GROUP BY ven.nome, p.categoria, ven.id
ORDER BY p.categoria ASC, media DESC;
