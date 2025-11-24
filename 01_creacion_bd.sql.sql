--CREACIÓN DE LA BASE DE DATOS
CREATE DATABASE HotelEstrellaDelValle;
GO

USE HotelEstrellaDelValle;
GO

-- CREACIÓN DE TABLAS NORMALIZADAS

-- Tabla 1: Clientes
-- Almacena la información de los clientes del hotel.
CREATE TABLE Clientes (
    IdCliente INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    Apellidos VARCHAR(100) NOT NULL,
    Telefono VARCHAR(15),
    Email VARCHAR(100) UNIQUE,
    Estado BIT DEFAULT 1 -- 1 = Activo, 0 = Inactivo (para lógica de conjuntos)
);

-- Tabla 2: TiposHabitacion (Nueva tabla para normalización 3FN)
-- Almacena los tipos de habitaciones disponibles (e.g., Sencilla, Doble, Suite).
CREATE TABLE TiposHabitacion (
    IdTipoHabitacion INT IDENTITY(1,1) PRIMARY KEY,
    NombreTipo VARCHAR(50) UNIQUE NOT NULL,
    Descripcion VARCHAR(200)
);


-- Tabla 3: Habitaciones
-- Almacena los detalles de cada habitación individual.
CREATE TABLE Habitaciones (
    IdHabitacion INT IDENTITY(1,1) PRIMARY KEY,
    Numero VARCHAR(10) UNIQUE NOT NULL, -- Número de habitación (ej: 101, 205)
    IdTipoHabitacion INT NOT NULL, -- FK a TiposHabitacion
    PrecioPorNoche DECIMAL(10, 2) NOT NULL,
    
    CONSTRAINT FK_Habitaciones_TiposHabitacion FOREIGN KEY (IdTipoHabitacion)
        REFERENCES TiposHabitacion(IdTipoHabitacion)
);


-- Tabla 4: Reservaciones
-- Almacena los detalles de cada reserva hecha por un cliente.
CREATE TABLE Reservaciones (
    IdReserva INT IDENTITY(1,1) PRIMARY KEY,
    IdCliente INT NOT NULL, -- FK a Clientes
    IdHabitacion INT NOT NULL, -- FK a Habitaciones
    FechaEntrada DATE NOT NULL,
    FechaSalida DATE NOT NULL,
    CantidadNoches INT, -- Se puede calcular, pero se mantiene para agilizar consultas.
    MontoTotal DECIMAL(10, 2), -- Monto total de la reserva (antes de pagos)
    FechaCreacion DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_Reservaciones_Clientes FOREIGN KEY (IdCliente)
        REFERENCES Clientes(IdCliente),
    CONSTRAINT FK_Reservaciones_Habitaciones FOREIGN KEY (IdHabitacion)
        REFERENCES Habitaciones(IdHabitacion),
    
    -- Restricción para asegurar que la fecha de salida sea posterior a la de entrada
    CONSTRAINT CHK_FechaSalida CHECK (FechaSalida > FechaEntrada)
);


-- Tabla 5: MetodosPago (Nueva tabla para normalización 3FN)
-- Almacena los métodos de pago aceptados (e.g., Efectivo, Tarjeta, Transferencia).
CREATE TABLE MetodosPago (
    IdMetodoPago INT IDENTITY(1,1) PRIMARY KEY,
    NombreMetodo VARCHAR(50) UNIQUE NOT NULL
);


-- Tabla 6: Pagos
-- Almacena los registros de los pagos realizados para una reserva.
CREATE TABLE Pagos (
    IdPago INT IDENTITY(1,1) PRIMARY KEY,
    IdReserva INT NOT NULL, -- FK a Reservaciones
    IdMetodoPago INT NOT NULL, -- FK a MetodosPago
    Monto DECIMAL(10, 2) NOT NULL,
    FechaPago DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_Pagos_Reservaciones FOREIGN KEY (IdReserva)
        REFERENCES Reservaciones(IdReserva),
    CONSTRAINT FK_Pagos_MetodosPago FOREIGN KEY (IdMetodoPago)
        REFERENCES MetodosPago(IdMetodoPago)
);


-- Tabla de Log para el Trigger
CREATE TABLE LogHabitaciones (
    IdLog INT IDENTITY(1,1) PRIMARY KEY,
    IdHabitacion INT NOT NULL,
    Usuario VARCHAR(100) DEFAULT SUSER_SNAME(),
    Fecha DATETIME DEFAULT GETDATE(),
    TipoCambio VARCHAR(50) NOT NULL, -- INSERT, UPDATE, DELETE
    DetallesCambio NVARCHAR(MAX)
);

--Carga de Datos
-- Inserción en TiposHabitacion
INSERT INTO TiposHabitacion (NombreTipo, Descripcion) VALUES 
('Sencilla', 'Una cama matrimonial, para una o dos personas.'),
('Doble', 'Dos camas matrimoniales, para hasta cuatro personas.'),
('Suite', 'Habitación de lujo con sala de estar separada.');


-- Inserción en MetodosPago
INSERT INTO MetodosPago (NombreMetodo) VALUES 
('Efectivo'),
('Tarjeta de Crédito'),
('Transferencia Bancaria'),
('Cheque');


-- Inserción en Clientes (Mínimo 10)
INSERT INTO Clientes (Nombre, Apellidos, Telefono, Email, Estado) VALUES 
('Ana', 'García López', '555-1234', 'ana.garcia@mail.com', 1), -- ID 1
('Luis', 'Pérez Martínez', '555-5678', 'luis.perez@mail.com', 1), -- ID 2
('Elena', 'Rodríguez Sánchez', '555-9012', 'elena.rodriguez@mail.com', 1), -- ID 3
('Pedro', 'Gómez Hernández', '555-3456', 'pedro.gomez@mail.com', 1), -- ID 4
('Sofía', 'Fernández Díaz', '555-7890', 'sofia.fernandez@mail.com', 1), -- ID 5
('Javier', 'Ruiz Castro', '555-2345', 'javier.ruiz@mail.com', 0), -- ID 6 (Inactivo)
('Marta', 'López Vega', '555-6789', 'marta.lopez@mail.com', 1), -- ID 7
('Daniel', 'Muñoz Torres', '555-1098', 'daniel.munoz@mail.com', 1), -- ID 8
('Carla', 'Jiménez Mora', '555-4321', 'carla.jimenez@mail.com', 1), -- ID 9
('Pablo', 'Alonso Gil', '555-8765', 'pablo.alonso@mail.com', 1); -- ID 10


-- Inserción en Habitaciones (Mínimo 10)
-- ID TiposHabitacion: 1=Sencilla, 2=Doble, 3=Suite
INSERT INTO Habitaciones (Numero, IdTipoHabitacion, PrecioPorNoche) VALUES
('101', 1, 80.00), -- Sencilla ID 1
('102', 1, 80.00), -- Sencilla ID 2
('103', 2, 120.00), -- Doble ID 3
('104', 2, 120.00), -- Doble ID 4
('201', 2, 125.00), -- Doble ID 5
('202', 3, 200.00), -- Suite ID 6
('203', 3, 210.00), -- Suite ID 7
('301', 1, 85.00), -- Sencilla ID 8
('302', 2, 130.00), -- Doble ID 9
('303', 3, 220.00); -- Suite ID 10


-- Inserción en Reservaciones (Mínimo 15)
-- Se inserta sin CantidadNoches y MontoTotal para que el TRIGGER 1 lo calcule después.
INSERT INTO Reservaciones (IdCliente, IdHabitacion, FechaEntrada, FechaSalida) VALUES
(1, 1, '2025-11-20', '2025-11-22'), -- 2 noches @ 80.00 = 160.00 (ID 1)
(2, 3, '2025-11-25', '2025-11-30'), -- 5 noches @ 120.00 = 600.00 (ID 2)
(3, 6, '2025-12-01', '2025-12-04'), -- 3 noches @ 200.00 = 600.00 (ID 3)
(4, 2, '2025-12-10', '2025-12-11'), -- 1 noche @ 80.00 = 80.00 (ID 4)
(1, 4, '2025-12-15', '2025-12-18'), -- 3 noches @ 120.00 = 360.00 (ID 5) -- Cliente 1 repite
(5, 5, '2026-01-05', '2026-01-10'), -- 5 noches @ 125.00 = 625.00 (ID 6)
(7, 8, '2026-01-15', '2026-01-16'), -- 1 noche @ 85.00 = 85.00 (ID 7)
(8, 10, '2026-02-01', '2026-02-07'), -- 6 noches @ 220.00 = 1320.00 (ID 8)
(9, 9, '2026-02-14', '2026-02-16'), -- 2 noches @ 130.00 = 260.00 (ID 9)
(10, 7, '2026-03-01', '2026-03-05'), -- 4 noches @ 210.00 = 840.00 (ID 10)
(1, 1, '2026-03-10', '2026-03-12'), -- 2 noches @ 80.00 = 160.00 (ID 11) -- Cliente 1 repite
(2, 2, '2026-04-01', '2026-04-02'), -- 1 noche @ 80.00 = 80.00 (ID 12)
(3, 3, '2026-04-10', '2026-04-15'), -- 5 noches @ 120.00 = 600.00 (ID 13)
(4, 4, '2026-05-01', '2026-05-03'), -- 2 noches @ 120.00 = 240.00 (ID 14)
(5, 5, '2026-05-15', '2026-05-20'); -- 5 noches @ 125.00 = 625.00 (ID 15)


-- Inserción en Pagos (Mínimo 15)
-- Asumiendo que el trigger de Reservaciones ya se ejecutó y llenó MontoTotal
-- ID MetodosPago: 1=Efectivo, 2=Tarjeta de Crédito, 3=Transferencia Bancaria
INSERT INTO Pagos (IdReserva, IdMetodoPago, Monto) VALUES 
(1, 1, 160.00), -- Pago Completo R1
(2, 2, 300.00), -- Pago Parcial R2 (Monto Total = 600.00)
(3, 3, 600.00), -- Pago Completo R3
(4, 1, 80.00), -- Pago Completo R4
(5, 2, 360.00), -- Pago Completo R5
(6, 2, 625.00), -- Pago Completo R6
(7, 3, 85.00), -- Pago Completo R7
(8, 1, 1320.00), -- Pago Completo R8
(9, 2, 260.00), -- Pago Completo R9
(10, 3, 840.00), -- Pago Completo R10
(11, 1, 160.00), -- Pago Completo R11
(12, 2, 80.00), -- Pago Completo R12
(13, 3, 600.00), -- Pago Completo R13
(14, 1, 240.00), -- Pago Completo R14
(15, 2, 625.00), -- Pago Completo R15
(2, 2, 300.00); -- Segundo Pago Parcial R2 (Ahora completo: 300+300=600)


--Consultas y Lógica Avanzada

--Consultas Básicas **

-- Listar todos los clientes ordenados por apellido
SELECT IdCliente, Nombre, Apellidos, Telefono, Email
FROM Clientes
ORDER BY Apellidos ASC;



-- Listar habitaciones de mayor a menor precio
SELECT H.Numero, T.NombreTipo, H.PrecioPorNoche
FROM Habitaciones H
JOIN TiposHabitacion T ON H.IdTipoHabitacion = T.IdTipoHabitacion
ORDER BY H.PrecioPorNoche DESC;


-- Mostrar reservaciones realizadas en un rango de fechas (ej: Nov y Dic 2025)
SELECT 
    R.IdReserva,
    C.Nombre + ' ' + C.Apellidos AS Cliente,
    H.Numero AS Habitacion,
    R.FechaEntrada,
    R.FechaSalida
FROM Reservaciones R
JOIN Clientes C ON R.IdCliente = C.IdCliente
JOIN Habitaciones H ON R.IdHabitacion = H.IdHabitacion
WHERE R.FechaEntrada BETWEEN '2025-11-01' AND '2025-12-31'
ORDER BY R.FechaEntrada;


-- ** Consultas Avanzadas **

--JOIN entre Reservaciones, Habitaciones y Clientes (detalle de una reserva)
SELECT
    R.IdReserva,
    C.Nombre + ' ' + C.Apellidos AS NombreCliente,
    H.Numero AS Habitacion,
    T.NombreTipo AS Tipo,
    R.FechaEntrada,
    R.FechaSalida,
    R.MontoTotal
FROM Reservaciones R
JOIN Clientes C ON R.IdCliente = C.IdCliente
JOIN Habitaciones H ON R.IdHabitacion = H.IdHabitacion
JOIN TiposHabitacion T ON H.IdTipoHabitacion = T.IdTipoHabitacion
WHERE R.IdReserva = 1;


--JOIN para pagos por cliente
SELECT 
    C.Nombre + ' ' + C.Apellidos AS Cliente,
    P.Monto AS MontoPagado,
    P.FechaPago,
    M.NombreMetodo
FROM Pagos P
JOIN Reservaciones R ON P.IdReserva = R.IdReserva
JOIN Clientes C ON R.IdCliente = C.IdCliente
JOIN MetodosPago M ON P.IdMetodoPago = M.IdMetodoPago
ORDER BY C.Apellidos, P.FechaPago DESC;


--Subconsulta que liste clientes que han hecho más de una reserva
SELECT Nombre, Apellidos, Email
FROM Clientes
WHERE IdCliente IN (
    SELECT IdCliente
    FROM Reservaciones
    GROUP BY IdCliente
    HAVING COUNT(IdReserva) > 1 -- La subconsulta identifica los IDs de clientes con más de una reserva.
);


--Consultas con lógica condicional WHERE
-- a) Reservaciones con MontoTotal mayor a 500.00
SELECT R.IdReserva, R.MontoTotal FROM Reservaciones R WHERE R.MontoTotal > 500.00;

-- b) Clientes cuyo apellido empieza con 'P' (LIKE)
SELECT Nombre, Apellidos FROM Clientes WHERE Apellidos LIKE 'P%';

-- c) Habitaciones con precio por noche entre 100.00 y 150.00 (BETWEEN)
SELECT Numero, PrecioPorNoche FROM Habitaciones WHERE PrecioPorNoche BETWEEN 100.00 AND 150.00;


--Lógica de Conjuntos 

-- 1. UNION entre clientes activos e inactivos (todos los clientes)
SELECT Nombre, Apellidos, 'Activo' AS EstadoCliente FROM Clientes WHERE Estado = 1
UNION
SELECT Nombre, Apellidos, 'Inactivo' AS EstadoCliente FROM Clientes WHERE Estado = 0
ORDER BY Apellidos;


-- 2. INTERSECT para identificar clientes con reservaciones Y pagos
SELECT C.Nombre, C.Apellidos FROM Clientes C
INTERSECT
SELECT C2.Nombre, C2.Apellidos FROM Reservaciones R
JOIN Clientes C2 ON R.IdCliente = C2.IdCliente
INTERSECT
SELECT C3.Nombre, C3.Apellidos FROM Pagos P
JOIN Reservaciones R2 ON P.IdReserva = R2.IdReserva
JOIN Clientes C3 ON R2.IdCliente = C3.IdCliente;


-- 3. EXCEPT para identificar habitaciones que no tienen reservación
SELECT Numero FROM Habitaciones
EXCEPT
SELECT H.Numero FROM Habitaciones H
JOIN Reservaciones R ON H.IdHabitacion = R.IdHabitacion;


            --Transacciones
-- Transacción para registrar una Reserva y su Pago inicial.
-- Esto asegura la atomicidad: o se insertan ambos, o no se inserta ninguno.
BEGIN TRANSACTION;
BEGIN TRY
-- Variables para la nueva reserva
    DECLARE @NuevoIdCliente INT = 1; -- Ejemplo: Ana García
    DECLARE @NuevoIdHabitacion INT = 5; -- Ejemplo: Habitación 201 (Doble)
    DECLARE @FechaEntrada DATE = '2026-06-01';
    DECLARE @FechaSalida DATE = '2026-06-05';
    DECLARE @PrecioNoche DECIMAL(10, 2) = (SELECT PrecioPorNoche FROM Habitaciones WHERE IdHabitacion = @NuevoIdHabitacion);
    DECLARE @CantidadNoches INT = DATEDIFF(DAY, @FechaEntrada, @FechaSalida);
    DECLARE @MontoReserva DECIMAL(10, 2) = @PrecioNoche * @CantidadNoches;
    DECLARE @MontoPagoInicial DECIMAL(10, 2) = 150.00; -- Primer pago
    DECLARE @IdMetodoPago INT = 2; -- Tarjeta de Crédito
    DECLARE @NuevaReservaId INT;
-- 1. Registrar una nueva reservación
    INSERT INTO Reservaciones (IdCliente, IdHabitacion, FechaEntrada, FechaSalida, CantidadNoches, MontoTotal)
    VALUES (@NuevoIdCliente, @NuevoIdHabitacion, @FechaEntrada, @FechaSalida, @CantidadNoches, @MontoReserva);
-- Obtener el Id de la reservación recién insertada
    SET @NuevaReservaId = SCOPE_IDENTITY();
-- Simular un error si el monto del pago es 0 o negativo (comentar esta línea para éxito)
-- IF @MontoPagoInicial <= 0 RAISERROR('Monto de pago inválido', 16, 1);
-- 2. Insertar un pago correspondiente a la reserva
    INSERT INTO Pagos (IdReserva, IdMetodoPago, Monto)
    VALUES (@NuevaReservaId, @IdMetodoPago, @MontoPagoInicial);
-- 4. Si todo es correcto → COMMIT
    COMMIT TRANSACTION;
    PRINT 'Transacción exitosa. Nueva Reserva ID: ' + CAST(@NuevaReservaId AS VARCHAR) + ' y Pago registrado.';
END TRY
BEGIN CATCH
-- 3. Si alguna inserción falla → ROLLBACK
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
-- Mostrar detalles del error
    PRINT 'Transacción fallida. Se realizó ROLLBACK.';
    PRINT 'Error: ' + ERROR_MESSAGE();
END CATCH
GO


--Manipulación de Datos
-- 1. Actualizar precio de una habitación según el tipo (ejemplo: Sencilla)
UPDATE H
SET H.PrecioPorNoche = H.PrecioPorNoche * 1.05 -- Aumento del 5%
FROM Habitaciones H
JOIN TiposHabitacion T ON H.IdTipoHabitacion = T.IdTipoHabitacion
WHERE T.NombreTipo = 'Sencilla';


-- 2. Eliminar pagos de una reserva cancelada (ejemplo: Reserva 4)
-- Primero, eliminamos los pagos
DELETE FROM Pagos WHERE IdReserva = 4;
-- Luego, eliminamos la reserva
DELETE FROM Reservaciones WHERE IdReserva = 4;


-- 3. Insertar una reserva nueva con un cálculo dinámico del monto total (usando función DATEDIFF)
-- El trigger 1 se encargará de esto en la BD final, pero aquí se muestra cómo se haría manualmente
DECLARE @InNoches INT;
DECLARE @InPrecio DECIMAL(10, 2);
DECLARE @InFechaEntrada DATE = '2026-07-01';
DECLARE @InFechaSalida DATE = '2026-07-03';
DECLARE @InIdHabitacion INT = 1;

SET @InNoches = DATEDIFF(DAY, @InFechaEntrada, @InFechaSalida);
SET @InPrecio = (SELECT PrecioPorNoche FROM Habitaciones WHERE IdHabitacion = @InIdHabitacion);

INSERT INTO Reservaciones (IdCliente, IdHabitacion, FechaEntrada, FechaSalida, CantidadNoches, MontoTotal)
VALUES (10, @InIdHabitacion, @InFechaEntrada, @InFechaSalida, @InNoches, @InPrecio * @InNoches);


--Bases de Datos Avanzado
-- **  Funciones **

-- Función 1: fn_CalcularNoches
-- Calcula el número de noches entre dos fechas.
CREATE FUNCTION fn_CalcularNoches (@FechaEntrada DATE, @FechaSalida DATE)
RETURNS INT
AS
BEGIN
    RETURN DATEDIFF(DAY, @FechaEntrada, @FechaSalida);
END;
GO
-- Uso de la función: SELECT dbo.fn_CalcularNoches('2025-11-20', '2025-11-22');

-- Función 2: fn_CalcularMonto
-- Calcula el monto total de una reserva.
CREATE FUNCTION fn_CalcularMonto (@PrecioNoche DECIMAL(10, 2), @Noches INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    RETURN @PrecioNoche * @Noches;
END;
GO

-- Uso de la función: SELECT dbo.fn_CalcularMonto(120.00, 5);


-- **  Procedimientos Almacenados **

-- SP 1: sp_RegistrarReserva
-- Registra una reserva y usa la función para calcular noches y monto.
CREATE PROCEDURE sp_RegistrarReserva
    @IdCliente INT,
    @IdHabitacion INT,
    @FechaEntrada DATE,
    @FechaSalida DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Noches INT = dbo.fn_CalcularNoches(@FechaEntrada, @FechaSalida);
    DECLARE @Precio DECIMAL(10, 2) = (SELECT PrecioPorNoche FROM Habitaciones WHERE IdHabitacion = @IdHabitacion);
    DECLARE @MontoTotal DECIMAL(10, 2) = dbo.fn_CalcularMonto(@Precio, @Noches);

    INSERT INTO Reservaciones (IdCliente, IdHabitacion, FechaEntrada, FechaSalida, CantidadNoches, MontoTotal)
    VALUES (@IdCliente, @IdHabitacion, @FechaEntrada, @FechaSalida, @Noches, @MontoTotal);

    SELECT SCOPE_IDENTITY() AS IdReserva; -- Devuelve el ID de la nueva reserva
END;
GO
-- Uso: EXEC sp_RegistrarReserva 1, 6, '2026-08-01', '2026-08-03';


-- SP 2: sp_ActualizarDatosCliente
-- Actualiza teléfono y/o email de un cliente por su ID.
CREATE PROCEDURE sp_ActualizarDatosCliente
    @IdCliente INT,
    @TelefonoNuevo VARCHAR(15) = NULL,
    @EmailNuevo VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Clientes
    SET 
        Telefono = ISNULL(@TelefonoNuevo, Telefono),
        Email = ISNULL(@EmailNuevo, Email)
    WHERE IdCliente = @IdCliente;

    IF @@ROWCOUNT = 0
        RAISERROR('Cliente no encontrado.', 16, 1);
END;
GO
-- Uso: EXEC sp_ActualizarDatosCliente 1, '999-0000', 'ana.nueva@mail.com';


-- SP 3: sp_ReporteIngresosPorMes
-- Genera un reporte de ingresos totales agrupados por mes y año.
CREATE PROCEDURE sp_ReporteIngresosPorMes
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        YEAR(FechaPago) AS Anio,
        MONTH(FechaPago) AS Mes,
        SUM(Monto) AS IngresoTotal
    FROM Pagos
    GROUP BY YEAR(FechaPago), MONTH(FechaPago)
    ORDER BY Anio, Mes;
END;
GO
-- Uso: EXEC sp_ReporteIngresosPorMes;


               -- ** Vistas **

-- Vista 1: vw_ReservasDetalle
-- Muestra el detalle completo de las reservas (quién, qué habitación, cuánto).
CREATE VIEW vw_ReservasDetalle AS
SELECT
    R.IdReserva,
    C.Nombre + ' ' + C.Apellidos AS Cliente,
    H.Numero AS Habitacion,
    T.NombreTipo AS TipoHabitacion,
    R.FechaEntrada,
    R.FechaSalida,
    R.CantidadNoches,
    R.MontoTotal
FROM Reservaciones R
JOIN Clientes C ON R.IdCliente = C.IdCliente
JOIN Habitaciones H ON R.IdHabitacion = H.IdHabitacion
JOIN TiposHabitacion T ON H.IdTipoHabitacion = T.IdTipoHabitacion;
GO

-- Vista 2: vw_PagosPorCliente
-- Agrupa los pagos para mostrar el total pagado por cada cliente.
CREATE VIEW vw_PagosPorCliente AS
SELECT
    C.IdCliente,
    C.Nombre + ' ' + C.Apellidos AS Cliente,
    COUNT(P.IdPago) AS CantidadPagos,
    SUM(P.Monto) AS TotalPagado
FROM Pagos P
JOIN Reservaciones R ON P.IdReserva = R.IdReserva
JOIN Clientes C ON R.IdCliente = C.IdCliente
GROUP BY C.IdCliente, C.Nombre, C.Apellidos;
GO


-- Vista 3: vw_IngresosHabitaciones
-- Muestra la ocupación e ingresos generados por cada tipo de habitación.
CREATE VIEW vw_IngresosHabitaciones AS
SELECT
    T.NombreTipo AS TipoHabitacion,
    COUNT(R.IdReserva) AS TotalReservas,
    SUM(R.MontoTotal) AS IngresoGenerado
FROM Reservaciones R
JOIN Habitaciones H ON R.IdHabitacion = H.IdHabitacion
JOIN TiposHabitacion T ON H.IdTipoHabitacion = T.IdTipoHabitacion
GROUP BY T.NombreTipo;
GO


-- **  Triggers **
-- Trigger 1: Actualiza CantidadNoches y MontoTotal en Reservaciones (después de INSERT)
CREATE TRIGGER tr_Reservaciones_AfterInsert
ON Reservaciones
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    -- Actualiza las columnas calculadas en la tabla Reservaciones
    UPDATE R
    SET
        R.CantidadNoches = DATEDIFF(DAY, I.FechaEntrada, I.FechaSalida),
        R.MontoTotal = DATEDIFF(DAY, I.FechaEntrada, I.FechaSalida) * H.PrecioPorNoche
    FROM Reservaciones R
    INNER JOIN inserted I ON R.IdReserva = I.IdReserva -- 'inserted' contiene las filas recién insertadas
    INNER JOIN Habitaciones H ON I.IdHabitacion = H.IdHabitacion;
END;
GO



-- Trigger 2: Registro de Log cada vez que se modifique una habitación (INSERT, UPDATE, DELETE)
CREATE TRIGGER tr_Habitaciones_Log
ON Habitaciones
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    -- Para DELETE
    IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO LogHabitaciones (IdHabitacion, TipoCambio, DetallesCambio)
        SELECT 
            d.IdHabitacion, 
            'DELETE', 
            'Habitación eliminada: ' + d.Numero + ', Precio: ' + CAST(d.PrecioPorNoche AS VARCHAR)
        FROM deleted d;
    END
    -- Para INSERT
    ELSE IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO LogHabitaciones (IdHabitacion, TipoCambio, DetallesCambio)
        SELECT 
            i.IdHabitacion, 
            'INSERT', 
            'Habitación insertada: ' + i.Numero + ', Precio: ' + CAST(i.PrecioPorNoche AS VARCHAR)
        FROM inserted i;
    END
    -- Para UPDATE (solo si hay un cambio significativo en el precio o tipo)
    ELSE IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO LogHabitaciones (IdHabitacion, TipoCambio, DetallesCambio)
        SELECT 
            i.IdHabitacion, 
            'UPDATE', 
            'Cambio. Precio anterior: ' + CAST(d.PrecioPorNoche AS VARCHAR) + ', Nuevo precio: ' + CAST(i.PrecioPorNoche AS VARCHAR)
        FROM inserted i
        JOIN deleted d ON i.IdHabitacion = d.IdHabitacion
        WHERE i.PrecioPorNoche <> d.PrecioPorNoche OR i.IdTipoHabitacion <> d.IdTipoHabitacion;
    END
END;
GO


-- **CTEs (Common Table Expressions) **

-- CTE 1: Calcular ingresos totales por cliente (usando CTE)
WITH IngresosClienteCTE AS (
    SELECT
        R.IdCliente,
        P.Monto
    FROM Pagos P
    JOIN Reservaciones R ON P.IdReserva = R.IdReserva
)
SELECT 
    C.Nombre + ' ' + C.Apellidos AS Cliente,
    SUM(CTE.Monto) AS IngresoTotalGenerado
FROM IngresosClienteCTE CTE
JOIN Clientes C ON CTE.IdCliente = C.IdCliente
GROUP BY C.Nombre, C.Apellidos
ORDER BY IngresoTotalGenerado DESC;


-- CTE 2: Calcular ocupación de habitaciones por mes
WITH OcupacionMensualCTE AS (
    SELECT
        IdHabitacion,
        YEAR(FechaEntrada) AS Anio,
        MONTH(FechaEntrada) AS Mes,
        CantidadNoches
    FROM Reservaciones
)
SELECT
    CTE.Anio,
    CTE.Mes,
    H.Numero AS Habitacion,
    SUM(CTE.CantidadNoches) AS NochesOcupadas
FROM OcupacionMensualCTE CTE
JOIN Habitaciones H ON CTE.IdHabitacion = H.IdHabitacion
GROUP BY CTE.Anio, CTE.Mes, H.Numero
ORDER BY CTE.Anio, CTE.Mes, H.Numero;



-- **  Backups y restauración **

-- Comando para realizar el Backup (Se debe modificar la RUTA)
SELECT 'Script terminado' 
GO -- Separa el lote anterior
BACKUP DATABASE HotelEstrellaDelValle 
TO DISK = 'C:\TempBD\HotelEstrellaDelValle_Full_20251123.bak' 
WITH FORMAT, 
NAME = 'Full Backup of HotelEstrellaDelValle';
GO -- Separa el comando BACKUP del resto del script, si lo hay




-- Comando para Restaurar (Se debe modificar la RUTA)
-- Nota: Para ejecutar el RESTORE, la BD no puede estar en uso.
USE master; -- ¡Esto es clave! Cambia el contexto de tu sesión a la BD maestra
GO 

-- Ahora, SQL Server puede restaurar la BD objetivo sin conflicto
RESTORE DATABASE HotelEstrellaDelValle
FROM DISK = 'C:\TempBD\HotelEstrellaDelValle_Full_20251123.bak'
WITH 
    REPLACE, 
    FILE = 1;
GO








