USE master
--DROP  DATABASE CursorEndereco
CREATE DATABASE CursorEndereco
GO
USE CursorEndereco


CREATE TABLE envio (
    CPF VARCHAR(20),
    NR_LINHA_ARQUIV INT,
    CD_FILIAL INT,
    DT_ENVIO DATETIME,
    NR_DDD INT,
    NR_TELEFONE VARCHAR(10),
    NR_RAMAL VARCHAR(10),
    DT_PROCESSAMENT DATETIME,
    NM_ENDERECO VARCHAR(200),
    NR_ENDERECO INT,
    NM_COMPLEMENTO VARCHAR(50),
    NM_BAIRRO VARCHAR(100),
    NR_CEP VARCHAR(10),
    NM_CIDADE VARCHAR(100),
    NM_UF VARCHAR(2)
)
GO
CREATE TABLE endereço (
    CPF VARCHAR(20),
    CEP VARCHAR(10),
    PORTA INT,
    ENDEREÇO VARCHAR(200),
    COMPLEMENTO VARCHAR(100),
    BAIRRO VARCHAR(100),
    CIDADE VARCHAR(100),
    UF VARCHAR(2)
)

CREATE PROCEDURE sp_insereenvio
AS
BEGIN
    DECLARE @cpf AS INT
    DECLARE @cont1 AS INT
    DECLARE @cont2 AS INT
    DECLARE @conttotal AS INT
    SET @cpf = 11111
    SET @cont1 = 1
    SET @cont2 = 1
    SET @conttotal = 1
    WHILE @cont1 <= @cont2 AND @cont2 <= 100
    BEGIN
        INSERT INTO envio (CPF, NR_LINHA_ARQUIV, DT_ENVIO)
        VALUES (CAST(@cpf AS VARCHAR(20)), @cont1, GETDATE())

        INSERT INTO endereço (CPF, PORTA, ENDEREÇO)
        VALUES (@cpf, @conttotal, CAST(@cont2 AS VARCHAR(3)) + 'Rua ' + CAST(@conttotal AS VARCHAR(5)))

        SET @cont1 = @cont1 + 1
        SET @conttotal = @conttotal + 1
        IF @cont1 >= @cont2
        BEGIN
            SET @cont1 = 1
            SET @cont2 = @cont2 + 1
            SET @cpf = @cpf + 1
        END
    END
END;


EXEC sp_insereenvio;

CREATE PROCEDURE MoverEnderecoParaEnvio
AS
BEGIN
    DECLARE @CPF VARCHAR(20)
    DECLARE @NR_LINHA_ARQUIV INT
    DECLARE @NM_ENDERECO VARCHAR(200)
    DECLARE @NR_ENDERECO INT
    DECLARE @NM_COMPLEMENTO VARCHAR(50)
    DECLARE @NM_BAIRRO VARCHAR(100)
    DECLARE @NR_CEP VARCHAR(10)
    DECLARE @NM_CIDADE VARCHAR(100)
    DECLARE @NM_UF VARCHAR(2)

    DECLARE endereco_cursor CURSOR FOR
    SELECT
        E.CPF,
        E.PORTA,
        E.ENDEREÇO,
        E.COMPLEMENTO,
        E.BAIRRO,
        E.CEP,
        E.CIDADE,
        E.UF,
        ENV.NR_LINHA_ARQUIV
    FROM
        endereço E
    INNER JOIN
        envio ENV ON E.CPF = ENV.CPF

    OPEN endereco_cursor

    FETCH NEXT FROM endereco_cursor INTO @CPF, @NR_LINHA_ARQUIV, @NM_ENDERECO, @NR_ENDERECO, @NM_COMPLEMENTO, @NM_BAIRRO, @NR_CEP, @NM_CIDADE, @NM_UF

    WHILE @@FETCH_STATUS = 0
    BEGIN
        UPDATE envio
        SET
            NM_ENDERECO = @NM_ENDERECO,
            NR_ENDERECO = @NR_ENDERECO,
            NM_COMPLEMENTO = @NM_COMPLEMENTO,
            NM_BAIRRO = @NM_BAIRRO,
            NR_CEP = @NR_CEP,
            NM_CIDADE = @NM_CIDADE,
            NM_UF = @NM_UF
        WHERE
            CPF = @CPF
            AND NR_LINHA_ARQUIV = @NR_LINHA_ARQUIV

        FETCH NEXT FROM endereco_cursor INTO @CPF, @NR_LINHA_ARQUIV, @NM_ENDERECO, @NR_ENDERECO, @NM_COMPLEMENTO, @NM_BAIRRO, @NR_CEP, @NM_CIDADE, @NM_UF
    END

    CLOSE endereco_cursor
    DEALLOCATE endereco_cursor
END;



EXEC MoverEnderecoParaEnvio;


SELECT * FROM envio ORDER BY CPF, NR_LINHA_ARQUIV ASC;