-- Views

CREATE  OR REPLACE VIEW `contas_por_gerente` AS
  SELECT
    co.funcionarios_matricula_gerente,
    co.num_conta,
    co.tipo,
    co.saldo,
    ci.cpf,
    ci.nome
  FROM contas co
    JOIN clientes_has_contas clhco
      ON co.num_conta = clhco.contas_num_conta
    JOIN clientes ci
      ON ci.cpf = clhco.clientes_cpf
    ORDER BY co.num_conta ASC, ci.nome ASC;

CREATE  OR REPLACE VIEW `transacoes_por_conta` AS
  SELECT
    c.num_conta,
    t.num_transacao,
    t.tipo,
    t.valor,
    t.data_hora,
    t.contas_num_conta_destino
  FROM contas c
    JOIN transacoes t
      ON c.num_conta = t.contas_num_conta_origem
  ORDER BY c.num_conta ASC, t.data_hora DESC;

-- Triggers

CREATE DEFINER = CURRENT_USER TRIGGER `Equipe521459`.`clientes_has_contas_BEFORE_INSERT` BEFORE INSERT ON `clientes_has_contas` FOR EACH ROW
BEGIN
	DECLARE qtd_clientes_conta INT;
    DECLARE cliente_has_conta_in_agencia INT;

	-- Conta quantos clientes já possuem a conta que está sendo associada
    SELECT COUNT(*) INTO qtd_clientes_conta
    FROM clientes_has_contas
    WHERE contas_num_conta = NEW.contas_num_conta;

	IF qtd_clientes_conta >= 2 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Uma conta não pode ter mais de dois clientes associados a ela.';
	END IF;

    -- Conta quantas contas o cliente tem na agência da conta que está sendo associada a ele
    SELECT COUNT(*) INTO cliente_has_conta_in_agencia
    FROM clientes_has_contas, contas
    WHERE
		contas_num_conta = num_conta AND
        clientes_cpf = NEW.clientes_cpf AND
        agencias_num_ag = (
			SELECT agencias_num_ag
			FROM contas
			WHERE num_conta = NEW.contas_num_conta
		);

	IF cliente_has_conta_in_agencia > 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Um cliente só pode ter uma conta por agência.';
	END IF;
END$$

CREATE DEFINER = CURRENT_USER TRIGGER `Equipe521459`.`contas_BEFORE_INSERT` BEFORE INSERT ON `contas` FOR EACH ROW
BEGIN
	DECLARE funcionario_cargo VARCHAR(10);
    DECLARE funcionario_agencia INT;

    SELECT cargo, agencias_num_ag INTO funcionario_cargo, funcionario_agencia
    FROM funcionarios
    WHERE matricula = NEW.funcionarios_matricula_gerente;

    IF funcionario_cargo <> 'gerente' THEN
    	SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Somente um funcionário com cargo de "gerente" pode ser associado a gerente de uma conta.';
	END IF;

    IF funcionario_agencia <> NEW.agencias_num_ag THEN
    	SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'O gerente da conta deve pertencer a mesma agência da conta.';
	END IF;
END$$

CREATE DEFINER = CURRENT_USER TRIGGER `Equipe521459`.`contas_BEFORE_UPDATE` BEFORE UPDATE ON `contas` FOR EACH ROW
BEGIN
	DECLARE funcionario_cargo VARCHAR(10);
    DECLARE funcionario_agencia INT;

	-- Só executa se o gerente da conta tiver sido alterado
	IF OLD.funcionarios_matricula_gerente <> NEW.funcionarios_matricula_gerente THEN
		SELECT cargo, agencias_num_ag INTO funcionario_cargo, funcionario_agencia
		FROM funcionarios
		WHERE matricula = NEW.funcionarios_matricula_gerente;

		IF funcionario_cargo <> 'gerente' THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Somente um funcionário com cargo de "gerente" pode ser associado a gerente de uma conta.';
		END IF;

		IF funcionario_agencia <> NEW.agencias_num_ag THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'O gerente da conta deve pertencer a mesma agência da conta.';
		END IF;
  END IF;
END$$

CREATE DEFINER = CURRENT_USER TRIGGER `Equipe521459`.`dependentes_BEFORE_INSERT` BEFORE INSERT ON `dependentes` FOR EACH ROW
BEGIN
	DECLARE num_dependentes INT;

    -- Conta a quantidade de dependentes do funcionário que está sendo associdado ao dependente inserido
    SELECT COUNT(nome_dependente) INTO num_dependentes
    FROM dependentes
    WHERE funcionarios_matricula = NEW.funcionarios_matricula;

    IF num_dependentes >= 5 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Um funcionário não pode ter mais que 5 dependentes.';
	END IF;

	SET NEW.idade = TIMESTAMPDIFF(YEAR, NEW.data_nasc, CURDATE());

END$$

CREATE DEFINER = CURRENT_USER TRIGGER `Equipe521459`.`dependentes_BEFORE_UPDATE` BEFORE UPDATE ON `dependentes` FOR EACH ROW
BEGIN
	SET NEW.idade = TIMESTAMPDIFF(YEAR, NEW.data_nasc, CURDATE());
END$$

CREATE DEFINER = CURRENT_USER TRIGGER `Equipe521459`.`funcionarios_BEFORE_INSERT` BEFORE INSERT ON `funcionarios` FOR EACH ROW
BEGIN
	IF NEW.salario < 2286.00 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Um funcionário não pode ter o salário menor que 2.286,00.';
	END IF;
END$$

CREATE DEFINER = CURRENT_USER TRIGGER `Equipe521459`.`funcionarios_AFTER_INSERT` AFTER INSERT ON `funcionarios` FOR EACH ROW
BEGIN
	UPDATE agencias
    SET sal_total = (
		SELECT SUM(salario)
        FROM funcionarios
        WHERE agencias_num_ag = NEW.agencias_num_ag
    )
    WHERE num_ag = NEW.agencias_num_ag;
END$$

CREATE DEFINER = CURRENT_USER TRIGGER `Equipe521459`.`funcionarios_BEFORE_UPDATE` BEFORE UPDATE ON `funcionarios` FOR EACH ROW
BEGIN
	IF NEW.salario < 2286.00 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Um funcionário não pode ter o salário menor que 2.286,00.';
	END IF;
END$$

CREATE DEFINER = CURRENT_USER TRIGGER `Equipe521459`.`funcionarios_AFTER_UPDATE` AFTER UPDATE ON `funcionarios` FOR EACH ROW
BEGIN
	-- TRIGGER Executa somente se o salário OU a agência do funcionário tiver sido alterado(a)
	IF OLD.salario <> NEW.salario OR OLD.agencias_num_ag <> NEW.agencias_num_ag THEN
		-- Atualiza o sal_total da antiga agência do funcionário
		UPDATE agencias
		SET sal_total = (
			SELECT SUM(salario)
			FROM funcionarios
			WHERE agencias_num_ag = OLD.agencias_num_ag
		)
		WHERE num_ag = OLD.agencias_num_ag;

		-- Se a agência tiver sido alterada, atualiza também o sal_total da nova agência
		IF OLD.agencias_num_ag <> NEW.agencias_num_ag THEN
			UPDATE agencias
			SET sal_total = (
				SELECT SUM(salario)
				FROM funcionarios
				WHERE agencias_num_ag = NEW.agencias_num_ag
			)
			WHERE num_ag = NEW.agencias_num_ag;
		END IF;
	END IF;
END$$

CREATE DEFINER = CURRENT_USER TRIGGER `Equipe521459`.`funcionarios_AFTER_DELETE` AFTER DELETE ON `funcionarios` FOR EACH ROW
BEGIN
	UPDATE agencias
    SET sal_total = (
		SELECT SUM(salario)
        FROM funcionarios
        WHERE agencias_num_ag = OLD.agencias_num_ag
    )
    WHERE num_ag = OLD.agencias_num_ag;
END$$

CREATE DEFINER = CURRENT_USER TRIGGER `Equipe521459`.`transacoes_BEFORE_INSERT` BEFORE INSERT ON `transacoes` FOR EACH ROW
BEGIN
	DECLARE saldo_atual REAL;
    DECLARE limite_credito_especial REAL;

	-- Somente movimentações de saída precisam de saldo em conta
	IF NEW.tipo IN('saque', 'pagamento', 'transferência', 'PIX') THEN
		SELECT saldo INTO saldo_atual
        FROM contas
        WHERE num_conta = NEW.contas_num_conta_origem;

        -- Obtem o limite de crédito se a conta for especial
        SELECT limite_credito INTO limite_credito_especial
        FROM contas_especial
        WHERE contas_num_conta = NEW.contas_num_conta_origem;

        -- Caso a conta não seja especial, o limite de crédito é 0
        IF limite_credito_especial IS NULL THEN
			SET limite_credito_especial = 0;
		END IF;

        -- Saldo em conta + limite de crédito especial (se houver) devem ser maior ou igual ao valor da transação
        IF (saldo_atual + limite_credito_especial) < NEW.valor THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'A conta não possui saldo e/ou crédito para realizar esta transação.';
        END IF;
    END IF;

	-- Verifica se transferência e PIX possuem conta de destino
    IF NEW.tipo IN('transferência', 'PIX') AND NEW.contas_num_conta_destino IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Transferência e PIX devem possuir uma conta de destino.';
    END IF;
END$$

CREATE DEFINER = CURRENT_USER TRIGGER `Equipe521459`.`transacoes_AFTER_INSERT` AFTER INSERT ON `transacoes` FOR EACH ROW
BEGIN
    DECLARE current_saldo REAL;
    DECLARE value_to_sub_on_saldo REAL;
    DECLARE value_to_sub_on_limite_credito REAL;

	-- Transações que debitam saldo da conta ou do limite crédito
    IF NEW.tipo IN('saque', 'pagamento', 'transferência', 'PIX') THEN
		-- Obtem o saldo atual
		SELECT saldo INTO current_saldo
		FROM contas
		WHERE num_conta = NEW.contas_num_conta_origem;

        -- Verifica qual o valor a ser debitado do saldo e do limite de crédito se for necessário
		IF current_saldo - NEW.valor < 0 THEN
			SET value_to_sub_on_saldo = current_saldo;
			SET value_to_sub_on_limite_credito = NEW.valor - value_to_sub_on_saldo;
		ELSE
			SET value_to_sub_on_saldo = NEW.valor;
		END IF;

        -- Se houver débito de saldo, atualiza o saldo da conta
		IF value_to_sub_on_saldo > 0 THEN
			UPDATE contas
			SET saldo = saldo - value_to_sub_on_saldo
			WHERE num_conta = NEW.contas_num_conta_origem;
		END IF;

		-- Se houver dábito de crédito, atualiza o limite de crédito
		IF value_to_sub_on_limite_credito > 0 THEN
			UPDATE contas_especial
			SET limite_credito = limite_credito - value_to_sub_on_limite_credito
			WHERE contas_num_conta = NEW.contas_num_conta_origem;
		END IF;

		-- Transferência e PIX subtraem da conta origem e somam ao saldo da conta destino
		IF NEW.tipo IN ('transferência','PIX') THEN
			UPDATE contas
			SET saldo = saldo + NEW.valor
			WHERE num_conta = NEW.contas_num_conta_destino;
		END IF;
	END IF;

	-- Deposito e estorno somam ao saldo da conta
    IF NEW.tipo IN ('deposito','estorno') THEN
		UPDATE contas
        SET saldo = saldo + NEW.valor
        WHERE num_conta = NEW.contas_num_conta_origem;
    END IF;
END$$

-- Consultas

SELECT * FROM agencias
WHERE
  (nome_ag LIKE CONCAT('%', ?, '%') OR ? = 1)
  AND
  (cidade_ag LIKE CONCAT('%', ?, '%') OR ? = 1)
LIMIT ?, ?;

SELECT COUNT(*) AS count FROM agencias
WHERE
  (nome_ag LIKE CONCAT('%', ?, '%') OR ? = 1)
  AND
  (cidade_ag LIKE CONCAT('%', ?, '%') OR ? = 1);

SELECT * FROM agencias WHERE num_ag = ?;

SELECT nome_ag FROM agencias WHERE num_ag = ?;

INSERT INTO agencias
  (nome_ag, cidade_ag)
VALUES
  (?, ?);

SELECT * FROM agencias WHERE num_ag = ?;

UPDATE agencias SET
  nome_ag = ?, cidade_ag = ?
WHERE num_ag = ?;

SELECT * FROM agencias WHERE num_ag = ?;

DELETE FROM agencias
WHERE num_ag = ?;

SELECT num_ag, nome_ag FROM agencias
WHERE
  num_ag = ?
  OR
  nome_ag LIKE CONCAT('%', ?, '%')
  OR
  ? = 1;

SELECT * FROM clientes_has_contas WHERE contas_num_conta = ?;

SELECT * FROM clientes
WHERE
  (nome LIKE CONCAT('%', ?, '%') OR ? = 1)
  AND
  (cpf LIKE CONCAT('%', ?, '%') OR ? = 1)
ORDER BY nome ASC
LIMIT ?, ?;

SELECT COUNT(*) AS count FROM clientes
WHERE
  (nome LIKE CONCAT('%', ?, '%') OR ? = 1)
  AND
  (cpf LIKE CONCAT('%', ?, '%') OR ? = 1);

SELECT * FROM clientes WHERE cpf = ?;

SELECT *
FROM clientes_has_contas chc
  JOIN clientes c
    ON chc.clientes_cpf = c.cpf
WHERE chc.contas_num_conta = ?;

SELECT nome FROM clientes WHERE cpf = ?;

INSERT INTO clientes
  (cpf, nome, data_nasc, rg_num, rg_orgao_emissor, rg_uf, end_tipo, end_logradouro, end_numero, end_bairro, end_cep, end_cidade, end_estado)
VALUES
  (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);

INSERT INTO emails
  (clientes_cpf, email, tipo)
VALUES
  (?, ?, ?);

INSERT INTO telefones
  (clientes_cpf, telefone, tipo)
VALUES
  (?, ?, ?);

SELECT * FROM clientes WHERE cpf = ?;

UPDATE clientes SET
  nome = ?,
  data_nasc = ?,
  rg_num = ?,
  rg_orgao_emissor = ?,
  rg_uf = ?,
  end_tipo = ?,
  end_logradouro = ?,
  end_numero = ?,
  end_bairro = ?,
  end_cep = ?,
  end_cidade = ?,
  end_estado = ?
WHERE cpf = ?;

DELETE FROM emails WHERE clientes_cpf = ?;

DELETE FROM telefones WHERE clientes_cpf = ?;

INSERT INTO emails
  (clientes_cpf, email, tipo)
VALUES
  (?, ?, ?);

INSERT INTO telefones
  (clientes_cpf, telefone, tipo)
VALUES
  (?, ?, ?);

SELECT * FROM clientes WHERE cpf = ?;

DELETE FROM emails WHERE clientes_cpf = ?;

DELETE FROM telefones WHERE clientes_cpf = ?;

DELETE FROM clientes
WHERE cpf = ?;

SELECT email, tipo FROM emails WHERE clientes_cpf = ?;

SELECT telefone, tipo FROM telefones WHERE clientes_cpf = ?;

SELECT cpf, nome
FROM clientes
WHERE
  cpf = ?
  OR
  nome LIKE CONCAT('%', ?, '%')
  OR
  ? = 1;

SELECT * FROM contas
WHERE
  (num_conta = ? OR ? = 1)
  AND
  (tipo = ? OR ? = 1)
LIMIT ?, ?;

SELECT COUNT(*) AS count FROM contas
WHERE
  (num_conta = ? OR ? = 1)
  AND
  (tipo = ? OR ? = 1);

SELECT agencias_num_ag, num_conta FROM clientes_has_contas JOIN contas ON contas_num_conta = num_conta WHERE clientes_cpf = ?;

SELECT * FROM clientes_has_contas JOIN contas ON contas_num_conta = num_conta WHERE clientes_cpf = ?;

SELECT *
FROM contas c
  LEFT JOIN contas_corrente cc
    ON c.num_conta = cc.contas_num_conta
  LEFT JOIN contas_especial ce
    ON c.num_conta = ce.contas_num_conta
  LEFT JOIN contas_poupanca cp
    ON c.num_conta = cp.contas_num_conta
WHERE num_conta = ?;

INSERT INTO contas
  (agencias_num_ag, funcionarios_matricula_gerente, salt, senha, tipo)
VALUES
  (?, ?, ?, ?, ?);

INSERT INTO clientes_has_contas
  (contas_num_conta, clientes_cpf)
VALUES
  (?, ?);

INSERT INTO contas_corrente
  (contas_num_conta, data_aniversario)
VALUES
  (?, ?);

INSERT INTO contas_especial
  (contas_num_conta, limite_credito)
VALUES
  (?, ?);

INSERT INTO contas_poupanca
  (contas_num_conta, taxa_juros)
VALUES
  (?, ?);

SELECT * FROM contas WHERE num_conta = ?;

UPDATE contas SET
  agencias_num_ag = ?,
  funcionarios_matricula_gerente = ?,
  senha = ?,
  salt = ?,
  tipo = ?
WHERE num_conta = ?;

UPDATE contas SET
  agencias_num_ag = ?,
  funcionarios_matricula_gerente = ?,
  tipo = ?
WHERE num_conta = ?;

DELETE FROM clientes_has_contas WHERE contas_num_conta = ?;

INSERT INTO clientes_has_contas
  (contas_num_conta, clientes_cpf)
VALUES
  (?, ?);

DELETE FROM contas_corrente WHERE contas_num_conta = ?;

DELETE FROM contas_especial WHERE contas_num_conta = ?;

DELETE FROM contas_poupanca WHERE contas_num_conta = ?;

INSERT INTO contas_corrente
  (contas_num_conta, data_aniversario)
VALUES
  (?, ?);

INSERT INTO contas_especial
  (contas_num_conta, limite_credito)
VALUES
  (?, ?);

INSERT INTO contas_poupanca
  (contas_num_conta, taxa_juros)
VALUES
  (?, ?);

SELECT * FROM contas WHERE num_conta = ?;

DELETE FROM contas
WHERE num_conta = ?;

SELECT num_conta FROM contas
WHERE
  num_conta = ?
  OR
  ? = 1;

SELECT * FROM dependentes
WHERE
  funcionarios_matricula = ?
  AND
  (nome_dependente LIKE CONCAT('%', ?, '%') OR ? = 1)
ORDER BY nome_dependente ASC
LIMIT ?, ?;

SELECT COUNT(*) AS count FROM dependentes
WHERE
  funcionarios_matricula = ?
  AND
  (nome_dependente LIKE CONCAT('%', ?, '%') OR ? = 1);

SELECT * FROM dependentes
WHERE
  funcionarios_matricula = ?
  AND
  nome_dependente = ?;

INSERT INTO dependentes
  (funcionarios_matricula, data_nasc, nome_dependente, parentesco)
VALUES
  (?, ?, ?, ?);

SELECT * FROM dependentes
WHERE
  funcionarios_matricula = ?
  AND
  nome_dependente = ?;

UPDATE dependentes SET
  data_nasc = ?,
  parentesco = ?
WHERE
  funcionarios_matricula = ?
  AND
  nome_dependente = ?;

SELECT * FROM dependentes
WHERE
  funcionarios_matricula = ?
  AND
  nome_dependente = ?;

DELETE FROM dependentes
WHERE
  funcionarios_matricula = ?
  AND
  nome_dependente = ?;

SELECT * FROM funcionarios
WHERE
  (matricula = ? OR ? = 1)
  AND
  (nome LIKE CONCAT('%', ?, '%') OR ? = 1)
LIMIT ?, ?;

SELECT COUNT(*) AS count FROM funcionarios
WHERE
  (matricula = ? OR ? = 1)
  AND
  (nome LIKE CONCAT('%', ?, '%') OR ? = 1);

SELECT * FROM funcionarios WHERE matricula = ?;

SELECT nome FROM funcionarios WHERE matricula = ?;

INSERT INTO funcionarios
  (agencias_num_ag, cargo, cidade, data_nasc, endereco, genero, nome, salario, salt, senha)
VALUES
  (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);

SELECT * FROM funcionarios WHERE matricula = ?;

UPDATE funcionarios SET
  agencias_num_ag = ?,
  cargo = ?,
  cidade = ?,
  data_nasc = ?,
  endereco = ?,
  genero = ?,
  nome = ?,
  salario = ?,
  salt = ?,
  senha = ?
WHERE matricula = ?;

UPDATE funcionarios SET
  agencias_num_ag = ?,
  cargo = ?,
  cidade = ?,
  data_nasc = ?,
  endereco = ?,
  genero = ?,
  nome = ?,
  salario = ?
WHERE matricula = ?;

SELECT * FROM funcionarios WHERE matricula = ?;

DELETE FROM funcionarios
WHERE matricula = ?;

SELECT nome, matricula FROM funcionarios
WHERE
  (
    matricula = ?
    OR
    nome LIKE CONCAT('%', ?, '%')
    OR
    ? = 1
  ) AND cargo = 'gerente';

SELECT * FROM transacoes
WHERE
  (num_transacao = ? OR ? = 1)
  AND
  (tipo = ? OR ? = 1)
ORDER BY data_hora DESC
LIMIT ?, ?;

SELECT COUNT(*) AS count FROM transacoes
WHERE
  (num_transacao = ? OR ? = 1)
  AND
  (tipo = ? OR ? = 1);

SELECT * FROM transacoes WHERE num_transacao = ?;

INSERT INTO transacoes
  (contas_num_conta_destino, contas_num_conta_origem, tipo, valor)
VALUES
  (?, ?, ?, ?);

SELECT * FROM transacoes WHERE num_transacao = ?;

UPDATE transacoes SET
  contas_num_conta_origem = ?,
  contas_num_conta_destino = ?,
  tipo = ?,
  valor = ?
WHERE num_transacao = ?;

SELECT * FROM transacoes WHERE num_transacao = ?;

DELETE FROM transacoes
WHERE num_transacao = ?;

SELECT
  f.agencias_num_ag,
  f.nome,
  f.cargo,
  f.endereco,
  f.cidade,
  f.salario,
  (
    SELECT COUNT(*)
    FROM dependentes
    WHERE funcionarios_matricula = f.matricula
  ) AS dependentes
FROM funcionarios f
WHERE agencias_num_ag = ?
ORDER BY f.nome ASC
LIMIT ?, ?;

SELECT
  f.agencias_num_ag,
  f.nome,
  f.cargo,
  f.endereco,
  f.cidade,
  f.salario,
  (
    SELECT COUNT(*)
    FROM dependentes
    WHERE funcionarios_matricula = f.matricula
  ) AS dependentes
FROM funcionarios f
WHERE agencias_num_ag = ?
ORDER BY f.nome DESC
LIMIT ?, ?;

SELECT
  f.agencias_num_ag,
  f.nome,
  f.cargo,
  f.endereco,
  f.cidade,
  f.salario,
  (
    SELECT COUNT(*)
    FROM dependentes
    WHERE funcionarios_matricula = f.matricula
  ) AS dependentes
FROM funcionarios f
WHERE agencias_num_ag = ?
ORDER BY f.salario ASC
LIMIT ?, ?;

SELECT
  f.agencias_num_ag,
  f.nome,
  f.cargo,
  f.endereco,
  f.cidade,
  f.salario,
  (
    SELECT COUNT(*)
    FROM dependentes
    WHERE funcionarios_matricula = f.matricula
  ) AS dependentes
FROM funcionarios f
WHERE agencias_num_ag = ?
ORDER BY f.salario DESC
LIMIT ?, ?;

SELECT COUNT(*) as count
FROM funcionarios
WHERE agencias_num_ag = ?;

SELECT co.agencias_num_ag, cl.nome, co.num_conta, co.tipo
FROM contas co
  JOIN clientes_has_contas cohcl
    ON co.num_conta = cohcl.contas_num_conta
  JOIN clientes cl
    ON cohcl.clientes_cpf = cl.cpf
WHERE co.agencias_num_ag = ?
ORDER BY co.tipo ASC
LIMIT ?, ?;

SELECT co.agencias_num_ag, cl.nome, co.num_conta, co.tipo
FROM contas co
  JOIN clientes_has_contas cohcl
    ON co.num_conta = cohcl.contas_num_conta
  JOIN clientes cl
    ON cohcl.clientes_cpf = cl.cpf
WHERE co.agencias_num_ag = ?
ORDER BY co.tipo DESC
LIMIT ?, ?;

SELECT COUNT(*) as count
FROM funcionarios
WHERE agencias_num_ag = ?;

SELECT c.agencias_num_ag, c.num_conta, c.saldo, ce.limite_credito
FROM contas c
  JOIN contas_especial ce
    ON c.num_conta = ce.contas_num_conta
WHERE
  c.agencias_num_ag = ?
  AND
  c.tipo = 'especial'
ORDER BY limite_credito DESC
LIMIT ?, ?;

SELECT COUNT(*) as count
FROM contas
WHERE
  agencias_num_ag = ?
  AND
  tipo = 'especial';

SELECT agencias_num_ag, num_conta, saldo
FROM contas
WHERE
  agencias_num_ag = ?
  AND
  tipo = 'poupança'
ORDER BY saldo DESC
LIMIT ?, ?;

SELECT COUNT(*) as count
FROM contas
WHERE
  agencias_num_ag = ?
  AND
  tipo = 'poupança';

SELECT
  c.agencias_num_ag,
  c.num_conta,
  (
    SELECT COUNT(*)
    FROM transacoes t
    WHERE
      t.contas_num_conta_origem = c.num_conta
      AND
      t.data_hora >= DATE(NOW() - INTERVAL ? DAY)
  ) AS qtd_transacoes
FROM contas c
WHERE
  c.agencias_num_ag = ?
  AND
  tipo = 'corrente'
ORDER BY qtd_transacoes DESC
LIMIT ?, ?;

SELECT COUNT(*) as count
FROM contas c
WHERE
  c.agencias_num_ag = ?
  AND
  tipo = 'corrente';

SELECT
  c.agencias_num_ag,
  c.num_conta,
  (
    SELECT SUM(valor)
    FROM transacoes t
    WHERE
      t.contas_num_conta_origem = c.num_conta
      AND
      t.data_hora >= DATE(NOW() - INTERVAL ? DAY)
  ) AS valor_transacoes
FROM contas c
WHERE
  c.agencias_num_ag = ?
  AND
  tipo = 'corrente'
ORDER BY valor_transacoes DESC
LIMIT ?, ?;

SELECT COUNT(*) as count
FROM contas c
WHERE
  c.agencias_num_ag = ?
  AND
  tipo = 'corrente';

SELECT
  data_nasc,
  end_bairro,
  end_cep,
  end_estado,
  end_logradouro,
  end_numero,
  end_tipo,
  end_cidade AS cidade,
  nome,
  (
    TIMESTAMPDIFF(YEAR, data_nasc, CURDATE())
  ) AS idade
FROM clientes
WHERE end_cidade LIKE CONCAT('%', ?, '%')
ORDER BY idade DESC
LIMIT ?, ?;

SELECT COUNT(*) as count
FROM clientes
WHERE end_cidade LIKE CONCAT('%', ?, '%');

SELECT
  f.nome,
  f.endereco,
  f.cargo,
  f.salario,
  f.agencias_num_ag,
  f.cidade,
  a.nome_ag AS agencias_nome
FROM funcionarios f
  JOIN agencias a
    ON f.agencias_num_ag = a.num_ag
WHERE f.cidade LIKE CONCAT('%', ?, '%')
ORDER BY
  f.agencias_num_ag ASC,
  f.cargo ASC,
  f.salario DESC
LIMIT ?, ?;

SELECT COUNT(*) as count
FROM funcionarios f
  JOIN agencias a
    ON f.agencias_num_ag = a.num_ag
WHERE f.cidade LIKE CONCAT('%', ?, '%');

SELECT
  num_ag,
  nome_ag,
  sal_total,
  cidade_ag AS cidade
FROM agencias
WHERE cidade_ag LIKE CONCAT('%', ?, '%')
ORDER BY sal_total DESC
LIMIT ?, ?;

SELECT COUNT(*) as count
FROM agencias
WHERE cidade_ag LIKE CONCAT('%', ?, '%');

SELECT
  chc.clientes_cpf,
  c.num_conta,
  c.tipo,
  c.agencias_num_ag,
  c.funcionarios_matricula_gerente,
  f.nome AS funcionarios_nome_gerente,
  c.saldo
FROM clientes_has_contas chc
  JOIN contas c
    ON chc.contas_num_conta = c.num_conta
  JOIN funcionarios f
    ON c.funcionarios_matricula_gerente = f.matricula
WHERE chc.clientes_cpf = ?
ORDER BY c.num_conta ASC
LIMIT ?, ?;

SELECT COUNT(*) as count
FROM clientes_has_contas
WHERE clientes_cpf = ?;

SELECT ? AS clientes_cpf, cpf, nome
FROM clientes
WHERE cpf IN (
  SELECT clientes_cpf
  FROM clientes_has_contas
  WHERE
    contas_num_conta IN (
      SELECT contas_num_conta
      FROM clientes_has_contas
      WHERE clientes_cpf = ?
    )
    AND
    clientes_cpf <> ?
)
ORDER BY cpf ASC
LIMIT ?, ?;

SELECT COUNT(*) AS count
FROM clientes
WHERE cpf IN (
  SELECT clientes_cpf
  FROM clientes_has_contas
  WHERE
    contas_num_conta IN (
      SELECT contas_num_conta
      FROM clientes_has_contas
      WHERE clientes_cpf = ?
    )
    AND
    clientes_cpf <> ?
);

SELECT
  chc.clientes_cpf,
  c.agencias_num_ag,
  c.num_conta,
  (
    SELECT COUNT(*)
    FROM transacoes t
    WHERE
      t.contas_num_conta_origem = c.num_conta
      AND
      t.data_hora >= DATE(NOW() - INTERVAL ? DAY)
  ) AS qtd_transacoes
FROM contas c
  JOIN clientes_has_contas chc
    ON c.num_conta = chc.contas_num_conta
WHERE chc.clientes_cpf = ?
ORDER BY qtd_transacoes DESC
LIMIT ?, ?;

SELECT COUNT(*) as count
FROM contas c
  JOIN clientes_has_contas chc
    ON c.num_conta = chc.contas_num_conta
WHERE chc.clientes_cpf = ?;

SELECT
  chc.clientes_cpf,
  c.agencias_num_ag,
  c.num_conta,
  (
    SELECT SUM(t.valor)
    FROM transacoes t
    WHERE
      t.contas_num_conta_origem = c.num_conta
      AND
      t.data_hora >= DATE(NOW() - INTERVAL ? DAY)
  ) AS valor_transacoes
FROM contas c
  JOIN clientes_has_contas chc
    ON c.num_conta = chc.contas_num_conta
WHERE chc.clientes_cpf = ?
ORDER BY valor_transacoes DESC
LIMIT ?, ?;

SELECT COUNT(*) as count
FROM contas c
  JOIN clientes_has_contas chc
    ON c.num_conta = chc.contas_num_conta
WHERE chc.clientes_cpf = ?;

SELECT *
FROM contas_por_gerente
WHERE funcionarios_matricula_gerente = ?
LIMIT ?, ?;

SELECT COUNT(*) as count
FROM contas_por_gerente
WHERE funcionarios_matricula_gerente = ?;

SELECT *
FROM transacoes_por_conta
WHERE
  num_conta = ?
  AND
  data_hora >= DATE(NOW() - INTERVAL ? DAY)
LIMIT ?, ?;

SELECT COUNT(*) as count
FROM transacoes_por_conta
WHERE
  num_conta = ?
  AND
  data_hora >= DATE(NOW() - INTERVAL ? DAY);