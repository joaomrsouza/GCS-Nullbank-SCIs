USE `Equipe521459`;

INSERT INTO `agencias`
  (nome_ag, cidade_ag)
VALUES
  ('Agência Sobral', 'Sobral'),
  ('Agência Fortaleza', 'Fortaleza'),
  ('Agência Marco', 'Marco');

INSERT INTO `clientes`
  (cpf, nome, data_nasc, rg_num, rg_orgao_emissor, rg_uf, end_tipo, end_logradouro, end_numero, end_bairro, end_cep, end_cidade, end_estado)
VALUES
  ('12345678910', 'João Marcos', '2001-12-11', '123456789', 'SSP', 'CE', 'Rua', 'Cel. Diogo Gomes', 123, 'Centro', '12345678', 'Sobral', 'CE'),
  ('12345678920', 'João Henrique', '2001-03-02', '123456790', 'SSP', 'CE', 'Rua', 'Comércio', 450, 'Centro', '12345632', 'Sobral', 'CE'),
  ('12345678921', 'Ana Paula', '2001-07-08', '123456791', 'SSP', 'CE', 'Rua', 'Estação', 200, 'Centro', '12345633', 'Sobral', 'CE'),
  ('12345678998', 'Priscila Áquila', '2002-06-02', '98765575', 'SSP', 'CE', 'Residencial', 'Rua Paraíso', 468, 'Centro', '62570000', 'Fortaleza', 'CE'),
  ('12345678911', 'Carlos Douglas', '2000-11-23', '98765888', 'SSP', 'CE', 'Rua', 'Rua X', 477, 'Brasília', '23456777', 'Fortaleza', 'CE'),
  ('12345678913', 'Maria do Socorro', '1968-06-15', '98765541', 'SSP', 'CE', 'Residencial', 'Rua F', 478, 'Centro', '62570088', 'Fortaleza', 'CE'),
  ('12345678914', 'Expedita Raquel', '1994-04-06', '98765579', 'SSP', 'CE', 'Avenida', 'João Ambrosio', 496, 'Centro', '62570088', 'Marco', 'CE'),
  ('12345678912', 'Ruth Ágatha', '2002-01-19', '98765546', 'SSP', 'CE', 'Rua', 'Rua A', 467, 'Cabral', '64000510', 'Marco', 'CE'),
  ('12345678993', 'Gabriela Freitas', '1992-09-23', '98765547', 'SSP', 'CE', 'Avenida', 'das Flores', 589, 'Areias', '64000579', 'Marco', 'CE'),
  ('12345678931', 'Mariana Alves', '1992-07-16', '98765550', 'SSP', 'CE', 'Avenida', 'Beira-Mar', 1020, 'Meireles', '64000590', 'Fortaleza', 'CE'),
  ('12345678932', 'Lucas Moreira', '1992-08-12', '98765551', 'SSP', 'CE', 'Rua', 'Barão de Studart', 102, 'Aldeota', '64000000', 'Fortaleza', 'CE'),
  ('12345678933', 'Renata Pereira', '1980-08-12', '98765552', 'SSP', 'CE', 'Rua', 'Barão de Studart', 102, 'Centro', '64000000', 'Sobral', 'CE'),
  ('12345678934', 'Thiago Martins', '1984-10-22', '98765553', 'SSP', 'CE', 'Avenida', 'dos Ipês', 102, 'Centro', '64000587', 'Marco', 'BA'),
  ('12345678935', 'Camila Rocha', '1996-02-18', '98765554', 'SSP', 'PI', 'Avenida', 'Professor Dias', 879, 'Centro', '64000587', 'Teresina', 'PI'),
  ('12345678930', 'Carlos Eduardo', '1992-11-10', '98765548', 'SSP', 'CE', 'Rua', 'Domingos Olímpio', 1500, 'Benfica', '64000579', 'Sobral', 'CE');

INSERT INTO `funcionarios`
  (agencias_num_ag, nome, data_nasc, genero, endereco, cidade, cargo, salario, senha, salt)
VALUES
  (1, 'João Marcos', '2001-12-11', 'masculino', 'Rua Cel. Diogo Gomes', 'Sobral', 'gerente', 8000.00, 'KlVi4APLsJL+QiQOpL+Jde9FcF8msnU8WUMAbeWqajU=', 'D3q7C5D+WOVb1ES5fjEHmL/okMmzmhksvuSfXeLSKIQ='),
  (1, 'João Henrique', '2001-03-02', 'masculino', 'Rua Comércio', 'Sobral', 'caixa', 5000.00, 'KlVi4APLsJL+QiQOpL+Jde9FcF8msnU8WUMAbeWqajU=', 'D3q7C5D+WOVb1ES5fjEHmL/okMmzmhksvuSfXeLSKIQ='),
  (1, 'Ana Paula', '2001-07-08', 'feminino', 'Rua Estação', 'Sobral', 'atendente', 3000.00, 'KlVi4APLsJL+QiQOpL+Jde9FcF8msnU8WUMAbeWqajU=', 'D3q7C5D+WOVb1ES5fjEHmL/okMmzmhksvuSfXeLSKIQ='),
  (2, 'Priscila Áquila', '2002-06-02', 'feminino', 'Paraíso', 'Fortaleza', 'gerente', 8000.00, 'KlVi4APLsJL+QiQOpL+Jde9FcF8msnU8WUMAbeWqajU=', 'D3q7C5D+WOVb1ES5fjEHmL/okMmzmhksvuSfXeLSKIQ='),
  (2, 'Carlos Douglas', '2000-11-23', 'masculino', 'Rua X', 'Fortaleza', 'caixa', 5000.00, 'KlVi4APLsJL+QiQOpL+Jde9FcF8msnU8WUMAbeWqajU=', 'D3q7C5D+WOVb1ES5fjEHmL/okMmzmhksvuSfXeLSKIQ='),
  (2, 'Maria do Socorro', '1968-06-15', 'feminino', 'Rua F', 'Fortaleza', 'atendente', 3000.00, 'KlVi4APLsJL+QiQOpL+Jde9FcF8msnU8WUMAbeWqajU=', 'D3q7C5D+WOVb1ES5fjEHmL/okMmzmhksvuSfXeLSKIQ='),
  (3, 'Expedita Raquel', '1994-04-06', 'feminino', 'Avenida João Ambrosio', 'Marco', 'gerente', 8000.00, 'KlVi4APLsJL+QiQOpL+Jde9FcF8msnU8WUMAbeWqajU=', 'D3q7C5D+WOVb1ES5fjEHmL/okMmzmhksvuSfXeLSKIQ='),
  (3, 'Ruth Ágatha', '2002-01-19', 'não-binário', 'Rua A', 'Marco', 'caixa', 5000.00, 'KlVi4APLsJL+QiQOpL+Jde9FcF8msnU8WUMAbeWqajU=', 'D3q7C5D+WOVb1ES5fjEHmL/okMmzmhksvuSfXeLSKIQ='),
  (3, 'Gabriela Freitas', '1992-09-23', 'não-binário', 'Avenida das Flores', 'Marco', 'atendente', 3000.00, 'KlVi4APLsJL+QiQOpL+Jde9FcF8msnU8WUMAbeWqajU=', 'D3q7C5D+WOVb1ES5fjEHmL/okMmzmhksvuSfXeLSKIQ='),
  (1, 'Thales Rocha', '1999-10-06', 'masculino', 'Rua Castro Freitas', 'Sobral', 'gerente', 7500.00, 'KlVi4APLsJL+QiQOpL+Jde9FcF8msnU8WUMAbeWqajU=', 'D3q7C5D+WOVb1ES5fjEHmL/okMmzmhksvuSfXeLSKIQ=');

INSERT INTO `contas` (agencias_num_ag, funcionarios_matricula_gerente, tipo, saldo, senha, salt) VALUES
  (1, 1, 'corrente', 1500.00, 'KlVi4APLsJL+QiQOpL+Jde9FcF8msnU8WUMAbeWqajU=', 'D3q7C5D+WOVb1ES5fjEHmL/okMmzmhksvuSfXeLSKIQ='),
  (1, 1, 'poupança', 2000.00, 'KlVi4APLsJL+QiQOpL+Jde9FcF8msnU8WUMAbeWqajU=', 'D3q7C5D+WOVb1ES5fjEHmL/okMmzmhksvuSfXeLSKIQ='),
  (1, 1, 'poupança', 2000.00, 'KlVi4APLsJL+QiQOpL+Jde9FcF8msnU8WUMAbeWqajU=', 'D3q7C5D+WOVb1ES5fjEHmL/okMmzmhksvuSfXeLSKIQ='),
  (1, 10, 'poupança', 2790.00, 'KlVi4APLsJL+QiQOpL+Jde9FcF8msnU8WUMAbeWqajU=', 'D3q7C5D+WOVb1ES5fjEHmL/okMmzmhksvuSfXeLSKIQ='),
  (1, 10, 'especial', 8000.00, 'KlVi4APLsJL+QiQOpL+Jde9FcF8msnU8WUMAbeWqajU=', 'D3q7C5D+WOVb1ES5fjEHmL/okMmzmhksvuSfXeLSKIQ='),
  (2, 4, 'corrente', 8500.00, 'KlVi4APLsJL+QiQOpL+Jde9FcF8msnU8WUMAbeWqajU=', 'D3q7C5D+WOVb1ES5fjEHmL/okMmzmhksvuSfXeLSKIQ='),
  (2, 4, 'corrente', 8970.70, 'KlVi4APLsJL+QiQOpL+Jde9FcF8msnU8WUMAbeWqajU=', 'D3q7C5D+WOVb1ES5fjEHmL/okMmzmhksvuSfXeLSKIQ='),
  (2, 4, 'poupança', 1000.00, 'KlVi4APLsJL+QiQOpL+Jde9FcF8msnU8WUMAbeWqajU=', 'D3q7C5D+WOVb1ES5fjEHmL/okMmzmhksvuSfXeLSKIQ='),
  (2, 4, 'especial', 9000.00, 'KlVi4APLsJL+QiQOpL+Jde9FcF8msnU8WUMAbeWqajU=', 'D3q7C5D+WOVb1ES5fjEHmL/okMmzmhksvuSfXeLSKIQ='),
  (3, 7, 'corrente', 7800.00, 'KlVi4APLsJL+QiQOpL+Jde9FcF8msnU8WUMAbeWqajU=', 'D3q7C5D+WOVb1ES5fjEHmL/okMmzmhksvuSfXeLSKIQ='),
  (3, 7, 'poupança', 2200.00, 'KlVi4APLsJL+QiQOpL+Jde9FcF8msnU8WUMAbeWqajU=', 'D3q7C5D+WOVb1ES5fjEHmL/okMmzmhksvuSfXeLSKIQ='),
  (3, 7, 'poupança', 2714.60, 'KlVi4APLsJL+QiQOpL+Jde9FcF8msnU8WUMAbeWqajU=', 'D3q7C5D+WOVb1ES5fjEHmL/okMmzmhksvuSfXeLSKIQ='),
  (3, 7, 'poupança', 2999.90, 'KlVi4APLsJL+QiQOpL+Jde9FcF8msnU8WUMAbeWqajU=', 'D3q7C5D+WOVb1ES5fjEHmL/okMmzmhksvuSfXeLSKIQ='),
  (3, 7, 'poupança', 1740.00, 'KlVi4APLsJL+QiQOpL+Jde9FcF8msnU8WUMAbeWqajU=', 'D3q7C5D+WOVb1ES5fjEHmL/okMmzmhksvuSfXeLSKIQ='),
  (3, 7, 'especial', 5000.00, 'KlVi4APLsJL+QiQOpL+Jde9FcF8msnU8WUMAbeWqajU=', 'D3q7C5D+WOVb1ES5fjEHmL/okMmzmhksvuSfXeLSKIQ=');

INSERT INTO `clientes_has_contas` (contas_num_conta, clientes_cpf) VALUES
  (1, '12345678910'),
  (1, '12345678920'),
  (2, '12345678913'),
  (3, '12345678921'),
  (4, '12345678998'),
  (5, '12345678911'),
  (6, '12345678913'),
  (7, '12345678914'),
  (8, '12345678912'),
  (9, '12345678993'),
  (10, '12345678931'),
  (11, '12345678932'),
  (12, '12345678933'),
  (13, '12345678934'),
  (14, '12345678935'),
  (15, '12345678930');

INSERT INTO `emails` (email, clientes_cpf, tipo) VALUES
  ('joao.silva@email.com', '12345678910', 'pessoal'),
  ('joao.henrique@email.com','12345678920','comercial'),
  ('ana.paula@email.com','12345678921','comercial'),
  ('priscila.aquila@email.com','12345678998','comercial'),
  ('carlos.douglas@email.com','12345678911','comercial'),
  ('maria.socorro@email.com','12345678913','pessoal'),
  ('expedita.raquel@email.com','12345678914','comercial'),
  ('ruth.agatha@email.com','12345678912','comercial'),
  ('gabriela.freitas@email.com','12345678993','comercial'),
  ('mariana.alves@email.com','12345678931','pessoal'),
  ('lucas.moreira@email.com','12345678932','pessoal'),
  ('renata.pereira@email.com','12345678933','comercial'),
  ('thiago.martins@email.com','12345678934','comercial'),
  ('camila.rocha@email.com','12345678935','comercial'),
  ('carlos.eduardo@email.com','12345678930','pessoal');

-- ! ALTERAÇÃO: Ajustado formatação do telefone

INSERT INTO `telefones` (telefone, clientes_cpf, tipo) VALUES
  ('(88) 98765-4309', '12345678910', 'celular'),
  ('(88) 98765-4310', '12345678920', 'celular'),
  ('(88) 98765-4311', '12345678921', 'celular'),
  ('(88) 98765-4312', '12345678998', 'celular'),
  ('(88) 98765-4313', '12345678911', 'celular'),
  ('(88) 98765-4314', '12345678913', 'celular'),
  ('(85) 98765-4315', '12345678914', 'celular'),
  ('(88) 98765-4316', '12345678912', 'celular'),
  ('(85) 98765-4317', '12345678993', 'celular'),
  ('(85) 98765-4318', '12345678931', 'celular'),
  ('(85) 98765-4319', '12345678932', 'celular'),
  ('(85) 98765-4320', '12345678933', 'celular'),
  ('(88) 98765-4321', '12345678934', 'celular'),
  ('(88) 98765-4322', '12345678935', 'celular'),
  ('(88) 98765-4323', '12345678930', 'celular');

INSERT INTO `transacoes` (contas_num_conta_origem, contas_num_conta_destino, tipo, valor) VALUES
  (1, NULL, 'saque', 200.00),
  (2, 11, 'transferência', 500.00),
  (3, NULL, 'deposito', 1020.00),
  (15, NULL, 'estorno', 8880.15),
  (3, NULL, 'pagamento', 20.00),
  (1, 3, 'PIX', 800.00);

-- ! ALTERAÇÃO: Removido idade, a idade deve ser calculada pelo banco de dados
INSERT INTO `dependentes` (nome_dependente, funcionarios_matricula, data_nasc, parentesco) VALUES
  ('Mariana Alves', 1, '1992-07-16', 'cônjuge'),
  ('Lucas Moreira', 1, '1992-08-12', 'filho(a)'),
  ('Renata Pereira', 1, '1980-08-12', 'genitor(a)'),
  ('Thiago Martins', 1, '1984-10-22', 'filho(a)'),
  ('Camila Rocha', 1, '1996-02-18', 'filho(a)'),
  ('Carlos Eduardo', 3, '1992-11-10', 'cônjuge');

INSERT INTO `contas_corrente` (contas_num_conta, data_aniversario) VALUES
  (1, '2001-12-11'),
  (6, '2025-06-20'),
  (7, '2025-07-30'),
  (10, '2025-06-20');

INSERT INTO `contas_especial` (contas_num_conta, limite_credito) VALUES
  (5, 5000.00),
  (9, 91000.00),
  (15, 1510800.00);

INSERT INTO `contas_poupanca` (contas_num_conta, taxa_juros) VALUES
  (2, 0.05),
  (3, 30.55),
  (4, 0.05),
  (8, 0.05),
  (11, 110.05),
  (12, 120.05),
  (13, 30.05),
  (14, 40.05);
