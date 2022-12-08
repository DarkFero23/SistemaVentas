create schema COMPRAS;

create schema ALMACEN;

create schema INVENTARIO;

SET search_path TO public, public;

drop  table areas_de_trabajo;
--Creamos la tabla area de trabajo con sus campos 
create table areas_de_trabajo(
	id_area serial not null constraint pk_id_area primary key,
	nom_area varchar(40) not null,
	dni_jefe_area varchar(8) not null,
	director_financiero varchar(8) not null,
	centro_costo numeric not null constraint centro_costo_min check(centro_costo >= 1000)
	
);
create or replace procedure create_areas_de_trabajo(
	entrada_nom_area varchar(40),
	entrada_dni_jefe_area varchar(8),
	entrada_director_financiero varchar(8),
	entrada_centro_costo numeric
)
LANGUAGE plpgsql as 
$$
begin
	insert into areas_de_trabajo(nom_area,dni_jefe_area,director_financiero,centro_costo) values (entrada_nom_area, entrada_dni_jefe_area, entrada_director_financiero,entrada_centro_costo);
	exception
		when others then
			raise exception 'Error al crear Ã¡rea de trabajo.';
end;
$$

call create_areas_de_trabajo('Contabilidad', '75888698','87654355',100000);

select * from areas_de_trabajo;


create or replace procedure delete_areas_de_trabajo(
	entrada_id int
)
LANGUAGE plpgsql as 
$$
begin
	delete from areas_de_trabajo where id_area = entrada_id;
	exception
		when others then
			raise notice 'Error al eliminar Ã¡rea de trabajo.';
end;
$$

call delete_areas_de_trabajo(4);
select * from areas_de_trabajo
copy areas_de_trabajo from 'D:\Ferito23\Area_trabajo.csv' Delimiter ',' csv header;

--Poner el constraint para jefe area
ALTER TABLE areas_de_trabajo ADD CONSTRAINT fk_dni_jefe_area FOREIGN KEY (dni_jefe_area) REFERENCES empleado (dni_empleado);

--Poner el constraint para Dir_Fin
ALTER TABLE areas_de_trabajo ADD CONSTRAINT fk_director_financiero FOREIGN KEY (director_financiero) REFERENCES empleado (dni_empleado);
--Probando datos de la tabla
insert into areas_de_trabajo (nom_area,dni_jefe_area,director_financiero,centro_costo) values ('Juegos', '73888258','87654321',100000);
insert into areas_de_trabajo (nom_area,dni_jefe_area,director_financiero,centro_costo) values ('Limpieza', '72797080','12345678',100000);
insert into areas_de_trabajo (nom_area,dni_jefe_area,director_financiero,centro_costo) values ('Electro', '74214321','45678321',100000);
select * from areas_de_trabajo;
delete from areas_de_trabajo

--Tabla Empleado

--Insertamos 1 valor para el empleado
drop table empleado;

create table empleado(
	dni_empleado varchar(8) not null constraint pk_dni_empleado primary key,
	id_area int not null,
	nombre_empleado varchar(40) not null,
	cargo varchar(40) not null,
	salario numeric constraint salario_min check(salario >=1000)
	
);
--Contraint para dni
ALTER TABLE empleado ADD constraint fk_id_area foreign key (id_area) references areas_de_trabajo(id_area) match simple on update cascade on delete cascade
copy public.empleado from 'D:\Ferito23\Dirc_Finaciero.csv' Delimiter ',' csv header;
copy public.empleado from 'D:\Ferito23\Jefe_Area.csv' dELIMITER ',' csv header;
--Probando consultas
insert into empleado (dni_empleado,id_area,nombre_empleado,cargo,salario) values ('72797080', 1,'Luis','Jefe Area',100000);
insert into empleado (dni_empleado,id_area,nombre_empleado,cargo,salario) values ('72797080', 1,'Luis Luque','Jefe Area',100000);
select * from empleado ;

create or replace procedure create_empleado(
	entrada_dni_empleado varchar(8),
	entrada_id_area int,
	entrada_nombre_empleado varchar(40),
	entrada_cargo varchar(40),
	entrada_salario numeric
)
LANGUAGE plpgsql as 
$$
begin
	insert into empleado(dni_empleado, id_area, nombre_empleado, cargo, salario) values (entrada_dni_empleado, entrada_id_area, entrada_nombre_empleado, entrada_cargo, entrada_salario);
	exception
		when others then
			raise exception 'Error al crear empleado.';
end;
$$

call create_empleado('72797550', 2,'JuancÃ­n','Jefe Area',100000);

select * from empleado e;

create or replace procedure delete_empleado(
	entrada_dni_empleado varchar(8)
)
LANGUAGE plpgsql as 
$$
begin
	delete from empleado where dni_empleado = entrada_dni_empleado;
	exception
		when others then
			raise exception 'Error al eliminar empleado.';
end;
$$

call delete_empleado('72797550');
select * from empleado

SET search_path TO COMPRAS, public;

create table categoria(
nombre_categoria varchar(20) not null primary key
);
CREATE OR replace procedure create_categoria(nombre_categoria_c varchar(50))
LANGUAGE plpgsql AS 
$$
BEGIN
    INSERT INTO compras.categoria(nombre_categoria) VALUES (nombre_categoria_c);
END;
$$


CREATE OR replace procedure delete_categoria(nombre_categoria_c varchar(50))
language plpgsql
AS $$
BEGIN
    DELETE FROM compras.categoria WHERE nombre_categoria = nombre_categoria_c ;
END;
$$
insert into categoria (nombre_categoria) values ('Cosas para jugar');
insert into categoria (nombre_categoria) values ('Accesorios Limpieza');
insert into categoria (nombre_categoria) values ('Para hogar');

select * from categoria ;
delete from categoria 
--------------------------------------------
drop table bien 

--Bien, que al momento de la compra se vuelve un Item con un precio ya definido
--0= Suministro y 1= Bien y Mueble
create table bien(
	id_bien serial not null constraint pk_id_bien primary key,
	nom_bien varchar(40),
	nom_categoria varchar(20) not null,
	unidad_medida_bien varchar(40),
	tipo int not null,
	stock int not null,
	constraint fk_nom_categoria foreign key (nom_categoria) references categoria(nombre_categoria) 
	match simple on update cascade on delete cascade
);

copy compras.bien from 'D:\Ferito23\Bien.csv' Delimiter ',' csv header;
select* from bien
create or replace procedure create_bien(nom_bien_a varchar ,nom_categoria_a varchar,unidad_medida_bien_a varchar,tipo_a int,stock_a int)
language plpgsql
as $$
begin 
	insert into compras.bien (nom_bien,nom_categoria,unidad_medida_bien,tipo,stock) values (nom_bien_a,nom_categoria_a,unidad_medida_bien_a,tipo_a,stock_a);
end;
$$;
call create_bien('Play 99','Cosas para jugar','Caja de carton',0,433)

create or replace procedure delete_bien(id_a int)
language plpgsql
as $$
begin 
	delete from compras.bien
	where id_bien=id_a;
end;
$$;
call eliminar_bien (37)
----------------------------------------------------------------
drop table proveedor
create table proveedor(
	ruc varchar(11) not null constraint pk_id_provedor primary key,
	nom_proveedor varchar(40),
	telefono varchar(40),
	direccion varchar(80),
	email varchar(30)
);
--Eliminar proovedor
drop procedure delete_provedor

create or replace procedure delete_proveedor(ruc_el varchar)
language plpgsql
as $$
begin 
	delete from compras.proveedor
	where ruc=ruc_el;
end;
$$;
call delete_proveedor ('72063920139')

drop procedure create_proveedor

create or replace procedure create_proveedor(ruc_in varchar ,nom_proveedor_in varchar,telefono_in varchar,direccion_in varchar,email_in varchar)
language plpgsql
as $$
begin 
	insert into compras.proveedor (ruc,nom_proveedor,telefono,direccion,email) values (ruc_in,nom_proveedor_in,telefono_in,direccion_in,email_in);
end;
$$;
call create_proveedor('72063920139','Luis Luque','9444444','Calle Cuba 105','luizl760@gmail.com')

select * from proveedor p 
copy proveedor from 'D:\Ferito23\Proovedores.csv' Delimiter ',' csv header;
select * from proveedor
-------------------------------------------------------

drop table solicitud
create table solicitud(
	num_solicitud serial not null unique constraint pk_num_solicitud primary key,
	fecha_pedido date not null default now(),
	responsable varchar(8) not null, 
	aprobacion_jefe_area bool not null default false,
	constraint fk_responsable  foreign key (responsable) references public.empleado(dni_empleado) match simple on update cascade on delete cascade
);
copy solicitud from 'D:\Ferito23\solicitud.csv' Delimiter ',' csv header;
drop procedure create_solicitud
create or replace procedure create_solicitud(fecha_pedido_s date ,responsable_s varchar,aprobacion_jefe_area_s bool)
language plpgsql
as $$
begin 
	insert into compras.solicitud (fecha_pedido,responsable,aprobacion_jefe_area) values (fecha_pedido_s,responsable_s,aprobacion_jefe_area_s);
end;
$$;
call create_solicitud('2022-02-07','93149974',false)

create or replace procedure delete_solicitud(num_solicitud_s int)
language plpgsql
as $$
begin 
	delete from compras.solicitud
	where num_solicitud=num_solicitud_s;
end;
$$;
call delete_solicitud(34)

select *from solicitud
delete from solicitud

--------------------------------------------------------------
create table detalle_solicitud(
	id_soli int not null,
	id_bien int not null,
	cantidad int not null,
	valor_unitario float not null,
	valor_total float not null,
	constraint fk_id_bien foreign key (id_bien) references bien(id_bien) match simple on update cascade on delete cascade,
	constraint fk_id_soli foreign key (id_soli) references solicitud(num_solicitud) match simple on update cascade on delete cascade
);
copy detalle_solicitud from 'D:\Ferito23\Detalle_soli.csv' Delimiter ',' csv header;
select *from detalle_solicitud
delete from detalle_solicitud

create table orden_de_compra(
	num_orden serial not null constraint pk_num_orden primary key,
	fecha_creacion date not null,
	num_solicitud int not null,
	ruc_proveedor varchar(11) not null,
	tipo_envio varchar(20) not null,
	condicion_envio varchar(20) not null default 'Gratis',
	fecha_entrega date,
	descuento numeric default 0,
	constraint fk_num_solicitud foreign key (num_solicitud) references solicitud(num_solicitud) match simple on update cascade on delete cascade,
	constraint fk_ruc_proveedor foreign key (ruc_proveedor) references proveedor(ruc) match simple on update cascade on delete cascade
);
copy orden_de_compra from 'D:\Ferito23\orden_compra.csv' Delimiter ',' csv header;
select *from orden_de_compra




create table detalle_orden(
	num_orden int not null,
	id_bien int not null,
	primary key(num_orden, id_bien),
	constraint fk_num_orden foreign key (num_orden) references orden_de_compra(num_orden) match simple on update cascade on delete cascade,
	constraint fk_id_bien foreign key (id_bien) references bien(id_bien) match simple on update cascade on delete cascade
);
copy detalle_orden from 'D:\Ferito23\detalle_orden.csv' Delimiter ',' csv header;
select *from detalle_orden

SET search_path TO ALMACEN, public;

create table registro_de_entrada(
	id_registro serial not null constraint pk_id_registro primary key,
	num_orden int not null,
	fecha_entrada date default now(),
	constraint fk_num_orden foreign key (num_orden) references COMPRAS.orden_de_compra(num_orden) match simple on update cascade on delete cascade
);
copy registro_de_entrada from 'D:\Ferito23\registro_de_entrada.csv' Delimiter ',' csv header;
select *from registro_de_entrada
delete from registro_de_entrada
drop table registro_de_entrada

create table registro_de_salida(
	id_registro serial not null constraint pk2_id_registro primary key,
	cantidad_salida int not null,
	fecha_salida date not null,
	id_registro_entrada int not null,
	constraint fk_id_registro_entrada foreign key (id_registro_entrada) references registro_de_entrada(id_registro) match simple on update cascade on delete cascade
);
copy registro_de_salida from 'D:\Ferito23\registro_de_salida.csv' Delimiter ',' csv header;
select *from registro_de_salida

SET search_path TO INVENTARIO, public;

create table ubicacion_de_bienes(
    id_ubi serial constraint pk_id_ubi primary key,
    responsable_bien varchar(8) not null,
    fecha_entrega date,
    registro_entrada int not null,
    constraint fk_registro_entrada foreign key (registro_entrada) references ALMACEN.registro_de_entrada(id_registro),
    constraint fk_responsable_bien foreign key (responsable_bien) references public.empleado(dni_empleado)
);

select num_orden from orden_de_compra odc where num_orden = num_orden




SET search_path TO COMPRAS, public;

create or replace function añadir_valor_total() returns void
LANGUAGE plpgsql as 
$$
declare
    cur_clientes CURSOR FOR SELECT * FROM detalle_solicitud;
    valor_aux float;
begin
    FOR registro IN cur_clientes loop
       valor_aux = registro.valor_unitario * registro.cantidad;
       update detalle_solicitud set valor_total = valor_aux where id_soli = registro.id_soli and id_bien = registro.id_bien;
    END LOOP;
    exception
        when others then
            raise exception 'Error.';
end;
$$

select añadir_valor_total();


--Cursor Anidado de Registro de Entrada
select rde.id_registro from almacen.registro_de_entrada rde 

select b.nom_bien, ds.cantidad from almacen.registro_de_entrada rde 
inner join compras.orden_de_compra odc on rde.num_orden = odc.num_orden 
inner join compras.solicitud s on odc.num_solicitud = s.num_solicitud 
inner join compras.detalle_solicitud ds on ds.id_soli = s.num_solicitud 
inner join compras.bien b on ds.id_bien = b.id_bien 
where rde.id_registro = 1;

CREATE OR REPLACE FUNCTION rep_reg_ent() RETURNS VOID AS
$BODY$
DECLARE
    reg1          RECORD;
    cur_re CURSOR FOR select rde.id_registro from almacen.registro_de_entrada rde ;
BEGIN
   OPEN cur_re;
   FETCH cur_re INTO reg1;
   WHILE( FOUND ) LOOP
       RAISE NOTICE 'ID REGISTRO ENTRADA:  %', reg1.id_registro;
       FETCH cur_re INTO reg1;
   END LOOP ;
   RETURN;
END
$BODY$
LANGUAGE 'plpgsql';

select rep_reg_ent();

CREATE OR REPLACE FUNCTION rep_reg_det() RETURNS VOID AS
$BODY$
DECLARE
    reg2         RECORD;
    cur_det CURSOR FOR select b.nom_bien, ds.cantidad from almacen.registro_de_entrada rde 
						inner join compras.orden_de_compra odc on rde.num_orden = odc.num_orden 
						inner join compras.solicitud s on odc.num_solicitud = s.num_solicitud 
						inner join compras.detalle_solicitud ds on ds.id_soli = s.num_solicitud 
						inner join compras.bien b on ds.id_bien = b.id_bien 
						where rde.id_registro = 1;
BEGIN
   OPEN cur_det;
   FETCH cur_det INTO reg2;
  RAISE NOTICE 'ITEM - CANTIDAD';
   WHILE( FOUND ) LOOP
       RAISE NOTICE '-----> % - %', reg2.nom_bien, reg2.cantidad;
       FETCH cur_det INTO reg2;
   END LOOP ;
   RETURN;
END
$BODY$
LANGUAGE 'plpgsql';

select rep_reg_det();

--Reporte de Registro de Entrada
CREATE OR REPLACE FUNCTION rep_registro_entrada() RETURNS VOID AS
$BODY$
DECLARE
    reg1          RECORD;
    cur_re CURSOR FOR select rde.id_registro from almacen.registro_de_entrada rde ;
BEGIN
   OPEN cur_re;
   FETCH cur_re INTO reg1;
   WHILE( FOUND ) LOOP
       RAISE NOTICE 'ID REGISTRO ENTRADA:  %', reg1.id_registro;
      
      DECLARE
		    reg2         RECORD;
		    cur_det CURSOR FOR select b.nom_bien, ds.cantidad from almacen.registro_de_entrada rde 
								inner join compras.orden_de_compra odc on rde.num_orden = odc.num_orden 
								inner join compras.solicitud s on odc.num_solicitud = s.num_solicitud 
								inner join compras.detalle_solicitud ds on ds.id_soli = s.num_solicitud 
								inner join compras.bien b on ds.id_bien = b.id_bien 
								where rde.id_registro = reg1.id_registro;
		BEGIN
		   OPEN cur_det;
		   FETCH cur_det INTO reg2;
		  RAISE NOTICE 'ITEM - CANTIDAD';
		   WHILE( FOUND ) LOOP
		       RAISE NOTICE '-----> % - %', reg2.nom_bien, reg2.cantidad;
		       FETCH cur_det INTO reg2;
		   END LOOP ;
		   RETURN;
		END	;	
      
       FETCH cur_re INTO reg1;
   END LOOP ;
   RETURN;
END
$BODY$
LANGUAGE 'plpgsql';

select rep_registro_entrada();

-- Cusor Simple registro de salida con el responsable y el ?rea
select rds.id_registro, e.nombre_empleado, adt.nom_area from almacen.registro_de_salida rds 
inner join almacen.registro_de_entrada rde on rds.id_registro_entrada = rde.id_registro 
inner join compras.orden_de_compra odc on rde.num_orden = odc.num_orden 
inner join compras.solicitud s on odc.num_solicitud = s.num_solicitud 
inner join public.empleado e on s.responsable = e.dni_empleado 
inner join public.areas_de_trabajo adt on e.id_area = adt.id_area 
order by 1;

CREATE OR REPLACE FUNCTION rep_registro_salida() RETURNS VOID AS
$BODY$
DECLARE
    reg1          RECORD;
    cur_re CURSOR FOR select rds.id_registro, e.nombre_empleado, adt.nom_area from almacen.registro_de_salida rds 
						inner join almacen.registro_de_entrada rde on rds.id_registro_entrada = rde.id_registro 
						inner join compras.orden_de_compra odc on rde.num_orden = odc.num_orden 
						inner join compras.solicitud s on odc.num_solicitud = s.num_solicitud 
						inner join public.empleado e on s.responsable = e.dni_empleado 
						inner join public.areas_de_trabajo adt on e.id_area = adt.id_area 
						order by 1;
BEGIN
   OPEN cur_re;
   FETCH cur_re INTO reg1;
   RAISE NOTICE 'ID REGISTRO ENTRADA - EMPLEADO - ?REA';
   WHILE( FOUND ) LOOP
       RAISE NOTICE '% - % - %', reg1.id_registro, reg1.nombre_empleado, reg1.nom_area;
       FETCH cur_re INTO reg1;
   END LOOP ;
   RETURN;
END
$BODY$
LANGUAGE 'plpgsql';

select rep_registro_salida();
-- Consulta

-- Ver el responsable y el jefe de ?rea de una determinada orden de entrada
select * from almacen.registro_de_entrada rde ;

select e.dni_empleado, e.nombre_empleado, adt.dni_jefe_area, adt.nom_area from almacen.registro_de_entrada rde 
inner join compras.orden_de_compra odc on rde.num_orden = odc.num_orden 
inner join compras.solicitud s on odc.num_solicitud = s.num_solicitud 
inner join public.empleado e on s.responsable = e.dni_empleado 
inner join public.areas_de_trabajo adt on e.id_area = adt.id_area 
where rde.id_registro = 4;

-- Procedimiento Almacenado 
-- Calcular que el retiro de un item del almacen no supere el stock
select * from compras.bien b ;

create or replace procedure verificar_retiro(val_ret int, item int)
language plpgsql	
as $$
declare 
	stock int;
begin
	select b.stock into strict stock from compras.bien b where b.id_bien = item;
	if stock > val_ret then
		raise notice 'Se puede sacar la cantidad ingresada';
	else	
		raise notice 'No se puede sacar esta cantidad: %', val_ret;
	end if;

	exception 
		   when no_data_found then 
		      raise exception 'Item % not found', item;
end;
$$;

call verificar_retiro(3, 500);

-- Funci?n de C?lculo
-- Calcular cu?ntos registros de entrada se dieron en un mes del a?o 2022
-- Mes 03
select * from almacen.registro_de_entrada rde ;
select count(*) from almacen.registro_de_entrada rde 
where DATE_PART('month', rde.fecha_entrada) = 3
and DATE_PART('year', rde.fecha_entrada) = 2022;

create or replace function contar_registros_mes(mes int)
returns int
language plpgsql
as
$$
declare
   cantidad integer;
begin
   select count(*) into cantidad from almacen.registro_de_entrada rde 
	where DATE_PART('month', rde.fecha_entrada) = mes
	and DATE_PART('year', rde.fecha_entrada) = 2022;
   
   return cantidad;
  
  exception 
	   when others then 
	      raise notice 'Un error sucedi? en la b?squeda';
end;
$$;

select contar_registros_mes(3);

-- Detonadores para control de modificaciones
-- Cuando hay un ingreso de entrada aumentar el stock
select b.stock from compras.bien b 

select ds.id_bien, ds.cantidad, b.stock from almacen.registro_de_entrada rde 
inner join compras.orden_de_compra odc on rde.num_orden = odc.num_orden 
inner join compras.solicitud s on odc.num_solicitud = s.num_solicitud 
inner join compras.detalle_solicitud ds on s.num_solicitud = ds.id_soli
inner join compras.bien b on ds.id_bien = b.id_bien
where odc.num_orden = 14;

CREATE or replace FUNCTION tg_aumentar_stock() RETURNS TRIGGER AS
$body$
declare 
	idb int;
	cant int;
	stc int;
	val int;
BEGIN
    select ds.id_bien, ds.cantidad, b.stock into idb, cant, stc from almacen.registro_de_entrada rde 
	inner join compras.orden_de_compra odc on rde.num_orden = odc.num_orden 
	inner join compras.solicitud s on odc.num_solicitud = s.num_solicitud 
	inner join compras.detalle_solicitud ds on s.num_solicitud = ds.id_soli 
	inner join compras.bien b on ds.id_bien = b.id_bien
	where odc.num_orden = new.num_orden;

	val := cant + stc;

	update compras.bien set stock = val where id_bien = idb;

    RETURN NEW;
END
$body$
LANGUAGE 'plpgsql';

CREATE TRIGGER tg_am_stock AFTER INSERT ON almacen.registro_de_entrada 
FOR EACH ROW EXECUTE PROCEDURE tg_aumentar_stock();

select * from compras.solicitud s  
select * from compras.orden_de_compra odc 
select * from almacen.registro_de_entrada rde 
insert into compras.solicitud (responsable) values ('54911967');
insert into compras.detalle_solicitud (id_soli, id_bien, cantidad, valor_unitario, valor_total) values (31, 3, 3, 2, 0);
insert into compras.orden_de_compra (num_orden, fecha_creacion, num_solicitud, 
ruc_proveedor , tipo_envio, condicion_envio, fecha_entrega) values (14, now(), 31, '49659527420',
'Terrestre', 'Gratis', '01-01-2023')
update compras.solicitud set aprobacion_jefe_area = true where num_solicitud = 31;

select b.stock  from compras.bien b where b.id_bien = 3;
--Valor anterior 169
insert into almacen.registro_de_entrada (id_registro, num_orden) values (14, 14);
delete from almacen.registro_de_entrada where id_registro = 14 and num_orden = 14;
select b.stock from compras.bien b where b.id_bien = 3;

-- Cuando hay un retiro de bienes quitar el stock
CREATE or replace FUNCTION tg_quitar_stock() RETURNS TRIGGER AS
$body$
declare 
	idb int;
	stc int;
	val int;
BEGIN
    select ds.id_bien, b.stock into idb, stc from almacen.registro_de_entrada rde 
	inner join compras.orden_de_compra odc on rde.num_orden = odc.num_orden 
	inner join compras.solicitud s on odc.num_solicitud = s.num_solicitud 
	inner join compras.detalle_solicitud ds on s.num_solicitud = ds.id_soli 
	inner join compras.bien b on ds.id_bien = b.id_bien
	where odc.num_orden = new.num_orden;

	val := stc - new.cantidad_salida;

	update compras.bien set stock = val where id_bien = idb;

    RETURN NEW;
END
$body$
LANGUAGE 'plpgsql';

CREATE TRIGGER tg_qu_stock AFTER INSERT ON almacen.registro_de_salida  
FOR EACH ROW EXECUTE PROCEDURE tg_quitar_stock();

-- Auditor?a de Registro de Entrada
CREATE TABLE log_reg_entrada
(
   ID_RE     INT,
   ID_NUMOR   INT,

   log_movimiento  VARCHAR(10),
   log_fecha_mov   timestamp
);

CREATE OR REPLACE FUNCTION tg_log_re() RETURNS TRIGGER AS
$BODY$
BEGIN
    IF (TG_OP='INSERT' OR TG_OP='UPDATE') THEN
        INSERT INTO log_reg_entrada
        ( ID_RE, NUMOR, log_movimiento, log_fecha_mov )
        VALUES /* Registramos en Log los valores nuevos */
        ( NEW.id_registro, NEW.num_orden, TG_OP, CURRENT_TIMESTAMP );
        RETURN NEW;
    END IF;
    IF (TG_OP='DELETE') THEN
        INSERT INTO log_reg_entrada
        ( ID_RE, NUMOR, log_movimiento, log_fecha_mov )
    VALUES /* Registramos en Log los valores eliminados */
        ( OLD.id_registro, OLD.num_orden, TG_OP, CURRENT_TIMESTAMP );
    RETURN OLD;
    END IF;
END;
$BODY$ LANGUAGE 'plpgsql';

CREATE TRIGGER tg_log_reg_ent AFTER INSERT OR UPDATE OR DELETE
ON log_reg_entrada FOR EACH ROW EXECUTE PROCEDURE tg_log_re();

-- Auditor?a de Registro de Salida
select * from almacen.registro_de_salida rds 
CREATE TABLE log_reg_salida
(
   ID_RE     INT,
   cant   INT,

   log_movimiento  VARCHAR(10),
   log_fecha_mov   timestamp
);

CREATE OR REPLACE FUNCTION tg_log_rs() RETURNS TRIGGER AS
$BODY$
BEGIN
    IF (TG_OP='INSERT' OR TG_OP='UPDATE') THEN
        INSERT INTO log_reg_salida
        ( ID_RE, cant, log_movimiento, log_fecha_mov )
        VALUES /* Registramos en Log los valores nuevos */
        ( NEW.id_registro, NEW.cantidad_salida, TG_OP, CURRENT_TIMESTAMP );
        RETURN NEW;
    END IF;
    IF (TG_OP='DELETE') THEN
        INSERT INTO log_reg_salida
        ( ID_RE, cant, log_movimiento, log_fecha_mov )
    VALUES /* Registramos en Log los valores eliminados */
        ( NEW.id_registro, NEW.cantidad_salida, TG_OP, CURRENT_TIMESTAMP );
    RETURN OLD;
    END IF;
END;
$BODY$ LANGUAGE 'plpgsql';

CREATE TRIGGER tg_log_reg_sal AFTER INSERT OR UPDATE OR DELETE
ON log_reg_salida FOR EACH ROW EXECUTE PROCEDURE tg_log_rs();

-- ?ndices
select * from almacen.registro_de_entrada rde ;
select * from almacen.registro_de_salida rds ;

CREATE INDEX idx_numor
ON almacen.registro_de_entrada(num_orden);

CREATE INDEX idx_regent
ON almacen.registro_de_salida(id_registro_entrada);

