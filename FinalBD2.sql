create schema COMPRAS;

create schema ALMACEN;

create schema INVENTARIO;

SET search_path TO public, public;

drop table areas_de_trabajo;

create table areas_de_trabajo(
	id_area serial not null constraint pk_id_area primary key,
	nom_area varchar(40) not null,
	centro_costo numeric not null constraint centro_costo_min check(centro_costo >= 1000)
);

drop table empleado;

create table empleado(
	dni_empleado varchar(8) not null constraint pk_dni_empleado primary key,
	id_area int not null,
	nombre_empleado varchar(40) not null,
	cargo varchar(40) not null,
	salario float constraint salario_min check(salario >=1000),
	constraint fk_id_area foreign key (id_area) references areas_de_trabajo(id_area) match simple on update cascade on delete cascade
);

--Creamos el Jefe de Área
alter table areas_de_trabajo add column dni_jefe_area varchar(8) not null;

ALTER TABLE areas_de_trabajo ADD CONSTRAINT fk_dni_jefe_area FOREIGN KEY (dni_jefe_area) REFERENCES empleado (dni_empleado);

--Creamos el Director Financiero
alter table areas_de_trabajo add column director_financiero varchar(8) not null;

ALTER TABLE areas_de_trabajo ADD CONSTRAINT fk_director_financiero FOREIGN KEY (director_financiero) REFERENCES empleado (dni_empleado);


select * from public.areas_de_trabajos;

SET search_path TO COMPRAS, public;

create table categoria(
nombre_categoria varchar(20) not null primary key
);

drop table bien 

--Bien, que al momento de la compra se vuelve un Item con un precio ya definido
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

create table proveedor(
	ruc varchar(11) not null constraint pk_id_provedor primary key,
	nom_proveedor varchar(40),
	telefono varchar(9),
	direccion varchar(80),
	email varchar(30)
);

create table solicitud(
	num_solicitud serial not null unique constraint pk_num_solicitud primary key,
	fecha_pedido date not null default now(),
	responsable varchar(8) not null, 
	aprobacion_jefe_area bool not null default false,
	constraint fk_responsable  foreign key (responsable) references public.empleado(dni_empleado) match simple on update cascade on delete cascade
);

create table detalle_solicitud(
	id_soli int not null,
	id_bien int not null,
	cantidad int not null,
	valor_unitario float not null,
	valor_total float not null,
	constraint fk_id_bien foreign key (id_bien) references bien(id_bien) match simple on update cascade on delete cascade,
	constraint fk_id_soli foreign key (id_soli) references solicitud(num_solicitud) match simple on update cascade on delete cascade
);

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

create table detalle_orden(
	num_orden int not null,
	id_bien int not null,
	primary key(num_orden, id_bien),
	constraint fk_num_orden foreign key (num_orden) references orden_de_compra(num_orden) match simple on update cascade on delete cascade,
	constraint fk_id_bien foreign key (id_bien) references bien(id_bien) match simple on update cascade on delete cascade
);

SET search_path TO ALMACEN, public;

create table registro_de_entrada(
	id_registro serial not null constraint pk_id_registro primary key,
	num_orden int not null,
	fecha_entrada date default now(),
	constraint fk_num_orden foreign key (num_orden) references COMPRAS.orden_de_compra(num_orden) match simple on update cascade on delete cascade
);

create table registro_de_salida(
	id_registro serial not null constraint pk2_id_registro primary key,
	cantidad_salida int not null,
	fecha_salida date not null,
	id_registro_entrada int not null,
	constraint fk_id_registro_entrada foreign key (id_registro_entrada) references registro_de_entrada(id_registro) match simple on update cascade on delete cascade
);

SET search_path TO INVENTARIO, public;

create table ubicacion_de_bienes(
    id_ubi serial constraint pk_id_ubi primary key,
    responsable_bien varchar(8) not null,
    fecha_entrega date,
    registro_entrada int not null,
    constraint fk_registro_entrada foreign key (registro_entrada) references ALMACEN.registro_de_entrada(id_registro),
    constraint fk_responsable_bien foreign key (responsable_bien) references public.empleado(dni_empleado)
);
