alter type ___.bloc_type add value 'source' ; 
commit ; 
insert into ___.input_output values ('source', array['to_transmit']::varchar[], array['qe_s', 'tbentrant_s', 'tbsortant_s', 'dbo5_s', 'mes_s', 'ngl_s']::varchar[], array[]::varchar[], true) ;

create sequence ___.source_bloc_name_seq ;

create type ___.to_transmit_type as enum ('qe', 'tbentrant', 'tbsortant', 'dbo5', 'mes', 'ngl');

create table ___.source_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('source_bloc', abbreviation=>'source_bloc'),
formula varchar[] default array[]::varchar[],
formula_name varchar[] default array[]::varchar[],
to_transmit ___.to_transmit_type not null default 'qe',
qe_s real,
tbentrant_s real,
tbsortant_s real,
dbo5_s real,
mes_s real,
ngl_s real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade,
unique (name, id)
);

create table ___.source_bloc_config(
    like ___.source_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.source_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('source', 'bloc', 'Point');

create or replace function ___.update_source_bloc(id_source integer)
returns void
language plpgsql
as $$
declare
    ups integer[] ;
    n integer ; 
    i integer ;
    s real ; 
    val real ;
    b_typ ___.bloc_type ;
    col varchar ;
    query text ;
begin 
    select into col to_transmit from api.source_bloc where id = id_source;
    select into ups array_agg(up) from ___.link where down = id_source;
    n := array_length(ups, 1) ;
    while i < n + 1 loop 
        select into b_typ b_type from ___.bloc where id = ups[i];
        if b_typ = 'lien' then 
            ups := array_append(ups, (select up from ___.link where down = ups[i]));
            n := n + 1 ;
        end if ;
        if exists(select 1 from information_schema.columns where table_name = b_typ||'_bloc' and column_name = col) then 
            query := 'select '||col||' from ___.'||b_typ||'_bloc where id = $1';
            execute query using ups[i] into val;
            s := s + val;
        elseif exists(select 1 from information_schema.columns where table_name = b_typ||'_bloc' and column_name = col||'_s') then 
            query := 'select '||col||'_s from ___.'||b_typ||'_bloc where id = $1';
            execute query using ups[i] into val;
            s := s + val;
        i := i + 1 ;
        end if ; 
    end loop ;
    query := 'update api.source_bloc set '||col||'_s = $1 where id = $2';
    execute query using s, id_source;
    return ;
end ;
$$ ;

create or replace function ___.source_link_trigger_function() returns trigger as $$
begin
    if new.down in (select id from api.source_bloc) then 
        perform ___.update_source_bloc(new.down);
    end if ;
    return new ;
end ;
$$ language plpgsql ;

create trigger source_link_trigger after insert or update on ___.link for each row execute function ___.source_link_trigger_function() ;



alter type ___.bloc_type add value 'traitement' ;
commit ; 
insert into ___.input_output values ('traitement', array['eh', 'v', 'w', 'reac']::varchar[], array[]::varchar[], array['construction eh traitement', 'exploitation traitement eh ', 'consommation électrique']::varchar[]) ;

create sequence ___.traitement_bloc_name_seq ;     




create table ___.traitement_bloc(
id integer primary key,
shape ___.geo_type not null default 'Polygon',
geom geometry('POLYGON', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('traitement_bloc', abbreviation=>'traitement_bloc'),
formula varchar[] default array['co2_c = eh*30*0.15', 'co2_e = 390*0.15*eh', 'co2_e = w*0.052']::varchar[],
formula_name varchar[] default array['construction eh traitement', 'exploitation traitement eh ', 'consommation électrique']::varchar[],
eh real,
v real,
w real,
reac real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.traitement_bloc_config(
    like ___.traitement_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.traitement_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('traitement', 'bloc', 'Polygon' 
    
    ) ;

select api.add_new_formula('construction eh traitement'::varchar, 'co2_c = eh*30*0.15'::varchar, 1, ''::text) ;
select api.add_new_formula('exploitation traitement eh '::varchar, 'co2_e = 390*0.15*eh'::varchar, 1, ''::text) ;
select api.add_new_formula('consommation électrique'::varchar, 'co2_e = w*0.052'::varchar, 5, ''::text) ;




alter type ___.bloc_type add value 'file_boue' ;
commit ; 
insert into ___.input_output values ('file_boue', array['eh']::varchar[], array['tbhaut']::varchar[], array[]::varchar[]) ;

create sequence ___.file_boue_bloc_name_seq ;     




create table ___.file_boue_bloc(
id integer primary key,
shape ___.geo_type not null default 'Polygon',
geom geometry('POLYGON', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('file_boue_bloc', abbreviation=>'file_boue_bloc'),
formula varchar[] default array[]::varchar[],
formula_name varchar[] default array[]::varchar[],
eh real,
tbhaut real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.file_boue_bloc_config(
    like ___.file_boue_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.file_boue_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('file_boue', 'bloc', 'Polygon' 
    
    ) ;






alter type ___.bloc_type add value 'flottateur' ;
commit ; 
insert into ___.input_output values ('flottateur', array['dbo5_e', 'mes_e', 'tbhaut', 'eh']::varchar[], array['dbo5_s', 'mes_s', 'tbhaut_s']::varchar[], array['flottateur construction boue amont']::varchar[]) ;

create sequence ___.flottateur_bloc_name_seq ;     

create table ___.flottateur_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('flottateur_bloc', abbreviation=>'flottateur_bloc'),
formula varchar[] default array['co2_c = eh*tbhaut']::varchar[],
formula_name varchar[] default array['flottateur construction boue amont']::varchar[],
dbo5_e real,
mes_e real,
tbhaut real,
eh real,
dbo5_s real,
mes_s real,
tbhaut_s real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.flottateur_bloc_config(
    like ___.flottateur_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.flottateur_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('flottateur', 'bloc', 'Point' 

) ;

select api.add_new_formula('flottateur construction boue amont'::varchar, 'co2_c = eh*tbhaut'::varchar, 3, ''::text) ;




alter type ___.bloc_type add value 'usine_de_compostage' ;
commit ; 
insert into ___.input_output values ('usine_de_compostage', array['tbhaut', 'w']::varchar[], array['tbhaut']::varchar[], array['construction usine de compostage boue', 'Consommation électrique']::varchar[]) ;

create sequence ___.usine_de_compostage_bloc_name_seq ;     




create table ___.usine_de_compostage_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('usine_de_compostage_bloc', abbreviation=>'usine_de_compostage_bloc'),
formula varchar[] default array['co2_c = tbhaut*2.892', 'co2_e = 0.052*w']::varchar[],
formula_name varchar[] default array['construction usine de compostage boue', 'Consommation électrique']::varchar[],
tbhaut real,
w real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.usine_de_compostage_bloc_config(
    like ___.usine_de_compostage_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.usine_de_compostage_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('usine_de_compostage', 'bloc', 'Point' 
    
    ) ;

select api.add_new_formula('construction usine de compostage boue'::varchar, 'co2_c = tbhaut*2.892'::varchar, 1, ''::text) ;
select api.add_new_formula('Consommation électrique'::varchar, 'co2_e = 0.052*w'::varchar, 1, ''::text) ;





alter type ___.bloc_type add value 'compostage' ;
commit ; 
insert into ___.input_output values ('compostage', array['d', 'tbhaut', 'eh', 'dbo5', 'mes']::varchar[], array[]::varchar[], array['compostage exploitation boue']::varchar[]) ;

create sequence ___.compostage_bloc_name_seq ;     




create table ___.compostage_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('compostage_bloc', abbreviation=>'compostage_bloc'),
formula varchar[] default array['co2_e = 444.5*tbhaut']::varchar[],
formula_name varchar[] default array['compostage exploitation boue']::varchar[],
d real,
tbhaut real,
eh real,
dbo5 real,
mes real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.compostage_bloc_config(
    like ___.compostage_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.compostage_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('compostage', 'bloc', 'Point' 
    
    ) ;

select api.add_new_formula('compostage exploitation boue'::varchar, 'co2_e = 444.5*tbhaut'::varchar, 3, ''::text) ;





alter type ___.bloc_type add value 'file_eau' ;
commit ; 
insert into ___.input_output values ('file_eau', array['eh', 'dco_elim']::varchar[], array[]::varchar[], array['Exploitation file eau']::varchar[]) ;

create sequence ___.file_eau_bloc_name_seq ;     




create table ___.file_eau_bloc(
id integer primary key,
shape ___.geo_type not null default 'Polygon',
geom geometry('POLYGON', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('file_eau_bloc', abbreviation=>'file_eau_bloc'),
formula varchar[] default array['ch4_e = dco_elim*0.0002']::varchar[],
formula_name varchar[] default array['Exploitation file eau']::varchar[],
eh real,
dco_elim real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.file_eau_bloc_config(
    like ___.file_eau_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.file_eau_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('file_eau', 'bloc', 'Polygon' 
    
    ) ;

select api.add_new_formula('Exploitation file eau'::varchar, 'ch4_e = dco_elim*0.0002'::varchar, 5, ''::text) ;





alter type ___.bloc_type add value 'clarificateur' ;
commit ; 
insert into ___.input_output values ('clarificateur', array['eh', 'q', 'vit', 'vu', 'e_voile']::varchar[], array['q_s', 'v_s']::varchar[], array['emission construction débit']::varchar[]) ;

create sequence ___.clarificateur_bloc_name_seq ;     




create table ___.clarificateur_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('clarificateur_bloc', abbreviation=>'clarificateur_bloc'),
formula varchar[] default array[]::varchar[],
formula_name varchar[] default array[]::varchar[],
eh real,
q real,
vit real default 60,
vu real,
e_voile real,
q_s real,
v_s real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.clarificateur_bloc_config(
    like ___.clarificateur_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.clarificateur_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('clarificateur', 'bloc', 'Point' 
    
    ) ;

-- select api.add_new_formula('emission construction débit'::varchar, 'co2_c = 52.7*q + 1273*q^(1/2)'::varchar, 2, ''::text) ;





alter type ___.bloc_type add value 'rejets_eau' ;
commit ; 
insert into ___.input_output values ('rejets_eau', array['eh', 'ngl', 'dco', 'oxi', 'milieu']::varchar[], array[]::varchar[], array['emission exploitation rejets eau azote', 'emission exploitation rejets eau méthane']::varchar[]) ;

create sequence ___.rejets_eau_bloc_name_seq ;     

create type ___.oxi_type as enum ('peu oxygéné', 'bien oxygéné');
create type ___.milieu_type as enum ('réserve,lac, estuaire', 'autres');

create table ___.oxi_type_table(val ___.oxi_type primary key, FE real, description text);
insert into ___.oxi_type_table(val) values ('peu oxygéné') ;
insert into ___.oxi_type_table(val) values ('bien oxygéné') ;
create table ___.milieu_type_table(val ___.milieu_type primary key, FE real, description text);
insert into ___.milieu_type_table(val) values ('réserve,lac, estuaire') ;
insert into ___.milieu_type_table(val) values ('autres') ;

select template.basic_view('oxi_type_table') ;
select template.basic_view('milieu_type_table') ;

create table ___.rejets_eau_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('rejets_eau_bloc', abbreviation=>'rejets_eau_bloc'),
formula varchar[] default array['n2o_e = ngl*oxi', 'ch4_e = dco*milieu']::varchar[],
formula_name varchar[] default array['emission exploitation rejets eau azote', 'emission exploitation rejets eau méthane']::varchar[],
eh real,
ngl real,
dco real,
oxi ___.oxi_type not null default 'peu oxygéné' references ___.oxi_type_table(val),
milieu ___.milieu_type not null default 'réserve,lac, estuaire' references ___.milieu_type_table(val),

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.rejets_eau_bloc_config(
    like ___.rejets_eau_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.rejets_eau_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('rejets_eau', 'bloc', 'Point' 
    ,additional_columns => '{oxi_type_table.FE as oxi_FE, oxi_type_table.description as oxi_description, milieu_type_table.FE as milieu_FE, milieu_type_table.description as milieu_description}'
    ,additional_join => 'left join ___.oxi_type_table on oxi_type_table.val = c.oxi  join ___.milieu_type_table on milieu_type_table.val = c.milieu ') ;

select api.add_new_formula('emission exploitation rejets eau azote'::varchar, 'n2o_e = ngl*oxi'::varchar, 3, ''::text) ;
select api.add_new_formula('emission exploitation rejets eau méthane'::varchar, 'ch4_e = dco*milieu'::varchar, 3, ''::text) ;





alter type ___.bloc_type add value 'lien' ;
commit ; 
insert into ___.input_output values ('lien', array[]::varchar[], array[]::varchar[], array[]::varchar[], false) ;

create sequence ___.lien_bloc_name_seq ;     




create table ___.lien_bloc(
id integer primary key,
shape ___.geo_type not null default 'LineString',
geom geometry('LINESTRING', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('lien_bloc', abbreviation=>'lien_bloc'),
formula varchar[] default array[]::varchar[],
formula_name varchar[] default array[]::varchar[],

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.lien_bloc_config(
    like ___.lien_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.lien_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('lien', 'bloc', 'LineString' 
    
    ) ;



alter type ___.bloc_type add value 'sur_bloc' ;
commit ; 
insert into ___.input_output values ('sur_bloc', array[]::varchar[], array[]::varchar[], array[]::varchar[], false) ;

create sequence ___.sur_bloc_bloc_name_seq ;     




create table ___.sur_bloc_bloc(
id integer primary key,
shape ___.geo_type not null default 'Polygon',
geom geometry('POLYGON', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('sur_bloc_bloc', abbreviation=>'sur_bloc_bloc'),
formula varchar[] default array[]::varchar[],
formula_name varchar[] default array[]::varchar[],

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.sur_bloc_bloc_config(
    like ___.sur_bloc_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.sur_bloc_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('sur_bloc', 'bloc', 'Polygon' 
    
    ) ;


update api.oxi_type_table set description = 'kgNO2/kgNGL pour un milieu bien oxygéné (concentration en O2 supérieu à 3 mg/L)', fe = 3.03 where val = 'bien oxygéné';
update api.oxi_type_table set description = 'kgNO2/kgNGL pour un milieu peu oxygéné (concentration en O2 entre 0.1 et 3 mg/L)', fe = 1.46 where val = 'peu oxygéné';
update api.milieu_type_table set description = '', fe = 0.2682 where val = 'réserve,lac, estuaire';
update api.milieu_type_table set description = '', fe = 1.4304 where val = 'autres';



