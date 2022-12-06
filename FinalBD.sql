go
create database datosventas
go
use datosventas

go
create table cliente(
idcliente int identity primary key not null,
dni int,
apellidos nvarchar(50),
nombre nvarchar(50),
direccion nvarchar(50),
telefono int
)
create table clienteLog(
idcliente int,
dni int,
apellidos nvarchar(50),
nombre nvarchar(50),
direccion nvarchar(50),
telefono int,
fecha date,
tipo varchar(50)
)

CREATE TRIGGER tg_cliente_insert   
ON cliente  
for INSERT 
AS 
BEGIN 
   INSERT INTO clienteLog(idcliente,dni,apellidos,nombre, direccion,telefono, fecha, tipo)
   select idcliente, dni, apellidos, nombre, direccion,direccion,getdate(), 'Insert' from inserted;
END

CREATE TRIGGER tg_cliente_update   
ON cliente  
for update 
AS 
BEGIN 
   INSERT INTO clienteLog(idcliente,dni,apellidos,nombre, direccion,telefono, fecha, tipo)
   select idcliente, dni, apellidos, nombre, direccion,direccion,getdate(), 'Updated' from updated;
END

CREATE TRIGGER tg_cliente_delete   
ON cliente  
for delete 
AS 
BEGIN 
   INSERT INTO clienteLog(idcliente,dni,apellidos,nombre, direccion,telefono, fecha, tipo)
   select idcliente, dni, apellidos, nombre, direccion,direccion,getdate(), 'Delete' from deleted;
END


go
create table proovedores(
idproovedor int identity primary key not null,
dni int,
apellidos nvarchar(50),
nombre nvarchar(50),
direccion nvarchar(50),
telefono int
)

go

create table cargo(
idcargo int identity primary key not null,
descripcion nvarchar(50)
)
go
create table empleado(
idempleado int identity primary key not null,
idcargo int foreign key references cargo(idcargo),
dni int,
apellidos nvarchar(50),
nombres nvarchar(50),
sexo nvarchar(30),
fechanac date,
direccion nvarchar(50),
estadocivil nvarchar(30)
)

alter table empleado
add
estado nvarchar(30)

go
create table categoria(
idcategoria int identity primary key not null,
descripcion nvarchar(50)
)


go


create table producto(
idproducto int identity primary key,
idcategoria int foreign key references categoria(idcategoria),
nombre nvarchar(50),
descripcion nvarchar(60),
stock int,
preciocompra decimal(4,2),
precioventa decimal(4,2),
fechanacimiento date
)

go
create table venta(
idventa int identity primary key,
idempleado int foreign key references empleado(idempleado),
idcliente int foreign key references cliente(idcliente),
nrodocumento nvarchar(50),
tipodocumento nvarchar(40),
fechaventa date
)

go

create table detalleventa(
iddetalleventa int identity primary key,
idproducto int foreign key references producto(idproducto),
idventa int foreign key references venta(idventa),
cantidad int,
preciounitario decimal(4,2)
)

create table Orden_Solicitud(
id_orden int identity primary key,
responsable int foreign key references empleado(idempleado),
fecha date,
Items int,
preciounitario decimal(4,2)
)

go
create table usuario(
idusuario int identity primary key,
idempleado int foreign key references empleado(idempleado),
usuario nvarchar(50),
contrase�a nvarchar(50)
)

/*PROCEDIMIENTOS ALMACENADOS */
/* PROCEDIMIENTOS PARA LOS CLIENTES */

create proc AgregarCliente
@dni int,
@apellido nvarchar(50),
@nombre nvarchar(50),
@direccion nvarchar(50),
@telefono int
as
begin
insert into cliente(dni,apellidos,nombre,direccion,telefono) values(@dni,@apellido,@nombre,@direccion,@telefono)
end

create proc EditarCliente
@idcliente int,
@dni int,
@apellido nvarchar(50),
@nombre nvarchar(50),
@direccion nvarchar(50),
@telefono int
as
begin
update cliente set dni = @dni, apellidos = @apellido, nombre = @nombre, direccion = @direccion, telefono = @telefono
where idcliente = @idcliente
end

create proc MostrarCliente
as
begin
select idcliente,nombre,apellidos,direccion,telefono,dni from cliente 
end

/* PROCEDIMIENTOS PARA LAS CATEGORIAS */

create proc AgregarCategoria
@descripcion nvarchar(50)
as
begin
insert into categoria(descripcion) values (@descripcion)
end

create proc MostrarCategoria
as
begin
select idcategoria,descripcion from categoria
end

/* PROCEDIMIENTOS PARA LOS PRODUCTOS */

create proc MostrarProductos
as
begin
select PR.idproducto,PR.idcategoria,PR.nombre as producto,CA.descripcion as categoria, PR.descripcion, PR.stock, PR.preciocompra, PR.precioventa,PR.fechavencimiento from producto PR
inner join categoria CA on CA.idcategoria = PR.idcategoria
end

create proc AgregarProducto
@idcategoria  int,
@nombre nvarchar(50),
@descripcion nvarchar(50),
@stock int,
@preciocompra decimal(4,2),
@precioventa decimal(4,2),
@fechavencimiento date
as
begin
insert into producto(idcategoria,nombre,descripcion,stock,preciocompra,precioventa,fechavencimiento) values(@idcategoria,@nombre,@descripcion,@stock,@preciocompra,@precioventa,@fechavencimiento)
end

create proc EditarProducto
@idproducto int,
@idcategoria  int,
@nombre nvarchar(50),
@descripcion nvarchar(50),
@stock int,
@preciocompra decimal(4,2),
@precioventa decimal(4,2),
@fechavencimiento date
as
begin
update producto set idcategoria = @idcategoria, nombre = @nombre,descripcion = @descripcion,stock = @stock,preciocompra = @preciocompra,precioventa = @precioventa, fechavencimiento = @fechavencimiento
where idproducto = @idproducto
end

/* PROCEDIMIENTOS PARA LOS CARGOS(de los empleados) */

create proc MostrarCargo
as
begin
select idcargo, descripcion from cargo
end

create proc AgregarCargo
@descripcion nvarchar(50)
as
begin
insert into cargo(descripcion) values (@descripcion)
end

/* PROCEDIMIENTOS PARA LOS EMPLEADOS */

Create proc MostrarEmpleados
as
begin
select EM.idempleado, EM.idcargo,CA.descripcion as cargo,EM.nombres,EM.apellidos,EM.sexo,EM.dni,EM.fechanac,EM.direccion,EM.estadocivil as 'estado civil',EM.estado from empleado EM
inner Join cargo CA on CA.idcargo = EM.idcargo
end

create proc AgregarEmpleado@idcargo int,
@nombre nvarchar(50),
@apellidos nvarchar(50),
@sexo nvarchar(50),
@dni int,
@fechanac nvarchar(20),
@direccion nvarchar(50),
@estadocivil nvarchar(30),
@estado nvarchar(30)
as
begin
insert into empleado(idcargo,nombres,apellidos,sexo,dni,fechanac,direccion,estadocivil,estado) values(@idcargo,@nombre,@apellidos,@sexo,@dni,@fechanac,@direccion,@estadocivil,@estado)
end

create proc EditarEmpleado
@idempleado int,
@idcargo int,
@nombre nvarchar(50),
@apellidos nvarchar(50),
@sexo nvarchar(50),
@dni int,
@fechanac nvarchar(20),
@direccion nvarchar(50),
@estadocivil nvarchar(30),
@estado nvarchar(30)
as
begin
update empleado set idcargo = @idcargo, nombres = @nombre, apellidos = @apellidos, sexo = @sexo, dni = @dni, fechanac = @fechanac, direccion = @direccion, estadocivil = @estadocivil,estado= @estado where idempleado = @idempleado
end

/* PROCEDIMIENTOS PARA LOS USUARIOS */

create proc AccederUsuario
@usuario nvarchar(50),
@contrase�a nvarchar(50)
as
begin
select * from usuario where usuario = @usuario and contrase�a = @contrase�a
end

create proc AgregarUsuario
@idempleado int,
@usuario nvarchar(50),
@contrase�a nvarchar(50)
as
begin
insert into usuario(idempleado,usuario,contrase�a) values (@idempleado,@usuario,@contrase�a)
end

Create Proc VerificarUsuario
@idempleado int
as
begin
select * from usuario where idempleado = @idempleado
end

/* PROCEDIMIENTOS ALMACENADOS DE VENTAS */

create proc ObtenerNroDocumento
as
begin
SELECT TOP 1 nrodocumento FROM venta ORDER BY idventa DESC 
end

Create proc MostrarVenta
as
begin
select VE.idventa,VE.nrodocumento as 'Nro.Documento',(EM.nombres + ' ' + EM.apellidos) as Empleado,(CL.nombre + ' ' + Cl.apellidos) as Cliente, VE.tipodocumento as 'Tipo de Documeto', VE.fechaventa as 'Fecha Venta' from venta VE
inner join empleado EM on EM.idempleado = VE.idempleado
inner join cliente CL on CL.idcliente = VE.idcliente
end

go

create proc AgregarVenta
@idempleado int,
@idcliente int,
@nrodocumento nvarchar(50),
@tipodocumento nvarchar(50),
@fechaventa nvarchar(30)
as
begin
insert into venta(idempleado,idcliente,nrodocumento,tipodocumento,fechaventa) values(@idempleado,@idcliente,@nrodocumento,@tipodocumento,@fechaventa)
end

go

create proc DeshacerVenta
@idventa int
as
begin
delete from venta where idventa = @idventa
end

/* PROCEDIMIENTOS ALMACENADOS DE DETALLES DE VENTAS */

create proc ObtenerIdVenta
as
begin
SELECT TOP 1 idventa FROM venta ORDER BY idventa DESC
end

create proc VerRegistroDetalleVenta
@idventa int
as
begin
select DV.iddetalleventa,DV.idproducto,DV.cantidad,(PR.nombre + ' ' + PR.descripcion)as descripcion,DV.preciounitario,(DV.cantidad * DV.preciounitario) as importe from detalleventa DV
inner join producto PR on PR.idproducto = DV.idproducto where DV.idventa =@idventa
end

create proc GenerarComprobante
@idventa int
as
begin
SELECT        dbo.venta.idventa, dbo.cliente.nombre, dbo.cliente.apellidos, dbo.cliente.dni, dbo.venta.fechaventa, dbo.venta.tipodocumento, dbo.venta.nrodocumento, 
                         dbo.producto.nombre AS Descripcion, dbo.detalleventa.cantidad, dbo.detalleventa.preciounitario, 
                         dbo.detalleventa.cantidad * dbo.detalleventa.preciounitario AS Importe
FROM            dbo.detalleventa INNER JOIN
                         dbo.venta ON dbo.detalleventa.idventa = dbo.venta.idventa INNER JOIN
                         dbo.producto ON dbo.detalleventa.idproducto = dbo.producto.idproducto INNER JOIN
                         dbo.cliente ON dbo.venta.idcliente = dbo.cliente.idcliente
						 where dbo.venta.idventa = @idventa
end


create proc AgregarDetalleVenta
@idproducto int,
@idventa int,
@cantidad int,
@preciounitario decimal(4,2)
as
begin
insert into detalleventa(idproducto,idventa,cantidad,preciounitario) values (@idproducto,@idventa,@cantidad,@preciounitario)
end

create proc DeshacerDetalleVenta
@idventa int
as
begin
delete from detalleventa where idventa = @idventa
end

select * from producto
drop proc AgregarDetalleVenta

create proc Aumentarstock
@idproducto int,
@cantidad int
as
begin
update producto set stock = stock + @cantidad where idproducto = @idproducto
end

create proc EliminarDetalleVenta
@iddetalleventa int
as
begin
delete from detalleventa where iddetalleventa = @iddetalleventa
end

create proc Disminuirstock
@idproducto int,
@cantidad int
as
begin
update producto set stock = stock - @cantidad where idproducto = @idproducto
end

ALTER TRIGGER [dbo].[tg_cliente_delete]   
ON [dbo].[cliente]  
for delete 
AS 
BEGIN 
   INSERT INTO clienteLog(idcliente,dni,apellidos,nombre, direccion,telefono, fecha, tipo)
   select idcliente, dni, apellidos, nombre, direccion,direccion,getdate(), 'Delete' from deleted;
END

ALTER TRIGGER [dbo].[tg_cliente_insert]   
ON [dbo].[cliente]  
for INSERT 
AS 
BEGIN 
   INSERT INTO clienteLog(idcliente,dni,apellidos,nombre, direccion,telefono, fecha, tipo)
   select idcliente, dni, apellidos, nombre, direccion,direccion,getdate(), 'Insert' from inserted;
END

ALTER TRIGGER [dbo].[tg_cliente_update]   
ON [dbo].[cliente]  
for update 
AS 
BEGIN 
   INSERT INTO clienteLog(idcliente,dni,apellidos,nombre, direccion,telefono, fecha, tipo)
   select idcliente, dni, apellidos, nombre, direccion,direccion,getdate(), 'Updated' from updated;
END

ALTER TRIGGER [dbo].[tg_detalleV_delete]
ON [dbo].[detalleventa]  
for delete 
AS 
BEGIN 
   INSERT INTO detalleventaLog(
	iddetalleventa,
	idproducto,
	idventa,
	cantidad,
	preciounitario,
	fecha,
	tipo
)
select    
	iddetalleventa,
	idproducto,
	idventa,
	cantidad,
	preciounitario,
	getdate(),
	'Delete' 
	from deleted;
END

ALTER TRIGGER [dbo].[tg_detalleV_insert]
ON [dbo].[detalleventa]  
for insert 
AS 
BEGIN 
   INSERT INTO detalleventaLog(
	iddetalleventa,
	idproducto,
	idventa,
	cantidad,
	preciounitario,
	fecha,
	tipo
)
select    
	iddetalleventa,
	idproducto,
	idventa,
	cantidad,
	preciounitario,
	getdate(),
	'Delete' 
	from inserted;
END

ALTER TRIGGER [dbo].[tg_detalleV_update]
ON [dbo].[detalleventa]  
for update 
AS 
BEGIN 
   INSERT INTO detalleventaLog(
	iddetalleventa,
	idproducto,
	idventa,
	cantidad,
	preciounitario,
	fecha,
	tipo
)
select    
	iddetalleventa,
	idproducto,
	idventa,
	cantidad,
	preciounitario,
	getdate(),
	'Delete' 
	from updated;
END


ALTER TRIGGER [dbo].[tg_empleado_delete]  
ON [dbo].[empleado]  
for delete 
AS 
BEGIN 
   INSERT INTO empleadoLog(
   idempleado ,
	idcargo,
	dni ,
	apellidos,
	nombres,
	sexo,
	fechanac ,
	direccion ,
	estadocivil,
	fecha ,
	tipo)
select    idempleado ,
idcargo,
dni ,
apellidos,
nombres,
sexo,
fechanac ,
direccion ,
estadocivil,
getdate() ,
'Delete' from deleted;
END

ALTER TRIGGER [dbo].[tg_empleado_insert]   
ON [dbo].[empleado]  
for INSERT 
AS 
BEGIN 
   INSERT INTO empleadoLog(
   idempleado ,
idcargo,
dni ,
apellidos,
nombres,
sexo,
fechanac ,
direccion ,
estadocivil,
fecha ,
tipo)
select    idempleado ,
idcargo,
dni ,
apellidos,
nombres,
sexo,
fechanac ,
direccion ,
estadocivil,
getdate() ,
'Insert' from inserted;
END

ALTER TRIGGER [dbo].[tg_empleado_update]   
ON [dbo].[empleado]  
for update 
AS 
BEGIN 
   INSERT INTO empleadoLog(
   idempleado ,
	idcargo,
	dni ,
	apellidos,
	nombres,
	sexo,
	fechanac ,
	direccion ,
	estadocivil,
	fecha ,
	tipo)
select    idempleado ,
idcargo,
dni ,
apellidos,
nombres,
sexo,
fechanac ,
direccion ,
estadocivil,
getdate() ,
'Update' from updated;
END

ALTER TRIGGER [dbo].[tg_producto_delete] 
ON [dbo].[producto]  
for delete 
AS 
BEGIN 
   INSERT INTO productoLog(
	idproducto,
	idcategoria,
	nombre ,
	descripcion,
	stock ,
	preciocompra ,
	precioventa ,
	fecha,
	tipo
)
select    
	idproducto,
	idcategoria,
	nombre ,
	descripcion,
	stock ,
	preciocompra ,
	precioventa ,
	getdate(),
	'Delete' 
	from deleted;
END

ALTER TRIGGER [dbo].[tg_producto_insert]   
ON [dbo].[producto]  
for INSERT 
AS 
BEGIN 
   INSERT INTO productoLog(
	idproducto,
	idcategoria,
	nombre ,
	descripcion,
	stock ,
	preciocompra ,
	precioventa ,	
	fecha,
	tipo
)
select    
	idproducto,
	idcategoria,
	nombre ,
	descripcion,
	stock ,
	preciocompra ,
	precioventa ,
	getdate(),
	'Insert' 
	from inserted;
END

ALTER TRIGGER [dbo].[tg_producto_update]  
ON [dbo].[producto]  
for update 
AS 
BEGIN 
   INSERT INTO productoLog(
	idproducto,
	idcategoria,
	nombre ,
	descripcion,
	stock ,
	preciocompra ,
	precioventa ,
	fecha,
	tipo
)
select    
	idproducto,
	idcategoria,
	nombre ,
	descripcion,
	stock ,
	preciocompra ,
	precioventa ,
	getdate(),
	'Update' 
	from updated;
END

ALTER TRIGGER [dbo].[tg_venta_delete]
ON [dbo].[venta]  
for delete 
AS 
BEGIN 
   INSERT INTO ventaLog(
	idventa,
	idempleado,
	idcliente,
	nrodocumento ,
	tipodocumento,
	fechaventa,
	fecha,
	tipo
)
select    
	idventa,
	idempleado,
	idcliente,
	nrodocumento ,
	tipodocumento,
	fechaventa,
	getdate(),
	'Delete' 
	from deleted;
END

ALTER TRIGGER [dbo].[tg_venta_insert]
ON [dbo].[venta]  
for insert 
AS 
BEGIN 
   INSERT INTO ventaLog(
	idventa,
	idempleado,
	idcliente,
	nrodocumento ,
	tipodocumento,
	fechaventa,
	fecha,
	tipo
)
select    
	idventa,
	idempleado,
	idcliente,
	nrodocumento ,
	tipodocumento,
	fechaventa,
	getdate(),
	'Delete' 
	from inserted;
END

ALTER TRIGGER [dbo].[tg_venta_update]
ON [dbo].[venta]  
for update 
AS 
BEGIN 
   INSERT INTO ventaLog(
	idventa,
	idempleado,
	idcliente,
	nrodocumento ,
	tipodocumento,
	fechaventa,
	fecha,
	tipo
)
select    
	idventa,
	idempleado,
	idcliente,
	nrodocumento ,
	tipodocumento,
	fechaventa,
	getdate(),
	'Delete' 
	from updated;
END

go
create table prueba(
id_prueba int identity primary key not null,
first_name nvarchar(50),
last_name nvarchar(50)
)

BULK INSERT
	prueba
From 'D:\Ferito23\nombre.csv'
with(
	FIELDTERMINATOR = ',',
	ROWTERMINATOR ='\n',
	FIRSTROW = 2

select *from Prueba