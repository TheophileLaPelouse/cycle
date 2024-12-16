alter type ___.bloc_type add value 'source' ; 
commit ; 
insert into ___.input_output values ('source', array['to_transmit']::varchar[], array['qe_s', 'tbentrant_s', 'tbsortant_s', 'dbo5_s', 'mes_s', 'ngl_s']::varchar[], array[]::varchar[], false) ;

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
    i integer := 1;
    s real := 0; 
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
        -- raise notice 'b_typ = %, col = %', b_typ, col ;
        if b_typ = 'lien' then 
            ups := array_cat(ups, (select array_agg(up) from ___.link where down = ups[i]
             and 'lien' != (select b_type from api.bloc where id = ___.link.up)::varchar));
            n := n + (select count(*) from ___.link where down = ups[i] 
            and 'lien' != (select b_type from api.bloc where id = ___.link.up)::varchar); 
        end if ;
        if col = any((select outputs from api.input_output where b_type = b_typ)::varchar[]) then
            query := 'select '||col||' from ___.'||b_typ||'_bloc where id = $1';
            execute query using ups[i] into val;
            s := s + val;
        elseif col||'_s' = any((select outputs from api.input_output where b_type = b_typ)::varchar[]) then 
            query := 'select '||col||'_s from ___.'||b_typ||'_bloc where id = $1';
            execute query using ups[i] into val;
            s := s + val;
       -- raise notice 's = %, val = %', s, val ;
        end if ; 
        i := i + 1 ;
    end loop ;
    query := 'update api.source_bloc set '||col||'_s = $1 where id = $2';
    -- raise notice 'query = %', query ;
    -- raise notice 's = %', s ;
    execute query using s, id_source;
    return ;
end ;
$$ ;

create or replace function ___.source_link_trigger_function() returns trigger as $$
declare 
    b_typ ___.bloc_type ;
    flag boolean := false ;
    double_down integer ;
begin
    -- raise notice E'\n on est dans le trigger' ;
    select into b_typ b_type from api.bloc where id = new.down ;
    -- raise notice 'b_typ = %', b_typ ;
    if b_typ = 'source' then 
        flag := true ;
        double_down := new.down ;
    end if ;
    if b_typ = 'lien' then 
        for double_down in (select down from ___.link where up = new.down) loop 
            if (select b_type from api.bloc where id = double_down) = 'source' then 
                flag := true ;
                exit ;
            end if ;
        end loop ;
    end if ;
    if flag then 
        -- raise notice 'on y est' ; 
        perform ___.update_source_bloc(double_down);
    end if ;
    return new ;
end ;
$$ language plpgsql ;

create trigger source_link_trigger after insert or update on ___.link for each row execute function ___.source_link_trigger_function() ;


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


----------------------------------------------------------------------------------------------------------------
-- Canalisation
----------------------------------------------------------------------------------------------------------------

alter type ___.bloc_type add value 'canalisation' ; 
commit ; 
insert into ___.input_output values ('canalisation', array['qe_e', 'dbo5_e', 'mes_e', 'ngl_e', 'ml', 'diam']::varchar[], array['qe_s', 'dbo5_s', 'mes_s', 'ngl_s']::varchar[], array['CO2 construction canalisation 2']::varchar[]) ;

create sequence ___.canalisation_bloc_name_seq ;

create type ___.mat_cana_type as enum ('fonte', 'PEHD', 'PVC', 'acier', 'béton') ;
create type ___.urban_type as enum ('rural', 'urbain') ;
create type ___.diam_type as enum ('100', '300', '500', '250', '400', '125', '225', '600', '1300', '1000', '110', '200', '160') ;
create type ___.dvie_type as enum ('50', '60', '80') ;
create type ___.method_type as enum ('classic', 'sans_tranche') ;

-- create type ___.cana_type as (
--     mat_cana ___.mat_cana_type,
--     urban ___.urban_type,
--     diam ___.diam_type,
--     d_vie ___.dvie_type,
--     method ___.method_type
-- );

create table ___.diam_type_table(
    id serial primary key,
    val ___.diam_type, 
    FE real, 
    incert real default 0,
    materiau ___.mat_cana_type,
    sans_tranche ___.method_type,
    urbain ___.urban_type,
    d_vie ___.dvie_type,
    description text,
    unique(val, materiau, urbain, d_vie, sans_tranche)
) ; 

create table ___.diam_values(
    val ___.diam_type primary key
) ;
insert into ___.diam_values(val) values ('100'), ('300'), ('500'), ('250'), ('400'), ('125'), ('225'), ('600'), ('1300'), ('1000'), ('110'), ('200'), ('160') ;
create table ___.method_values(
    val ___.method_type primary key
) ;
insert into ___.method_values(val) values ('classic'), ('sans_tranche') ;

create table ___.dvie_values(
    val ___.dvie_type primary key
) ;
insert into ___.dvie_values(val) values ('50'), ('60'), ('80') ;
create table ___.urban_values(
    val ___.urban_type primary key
) ;
insert into ___.urban_values(val) values ('rural'), ('urbain') ;



insert into ___.diam_type_table (val, FE, incert, materiau, d_vie, sans_tranche, urbain)
values
('100', 120, 0.40, 'fonte', '80', 'classic', 'rural'),
('300', 270, 0.60, 'fonte', '80', 'classic', 'rural'),
('500', 440, 0.30, 'fonte', '80', 'classic', 'rural'),
('100', 50, 0.30, 'fonte', '80', 'classic', 'urbain'),
('250', 120, 0.40, 'fonte', '80', 'classic', 'urbain'),
('500', 290, 0.50, 'fonte', '80', 'classic', 'urbain'),
('100', 30, 0.80, 'fonte', '80', 'sans_tranche', 'rural'),
('200', 70, 0.80, 'fonte', '80', 'sans_tranche', 'rural'),
('300', 120, 0.80, 'fonte', '80', 'sans_tranche', 'rural'),
('400', 180, 0.80, 'fonte', '80', 'sans_tranche', 'rural'),
('125', 90, 0.25, 'PEHD', '60', 'classic', 'rural'),
('500', 240, 0.70, 'PEHD', '60', 'classic', 'rural'),
('160', 50, 0.30, 'PEHD', '60', 'classic', 'urbain'),
('250', 100, 0.40, 'PEHD', '60', 'classic', 'urbain'),
('125', 20, 0.80, 'PEHD', '60', 'sans_tranche', 'rural'),
('225', 50, 0.80, 'PEHD', '60', 'sans_tranche', 'rural'),
('500', 250, 0.50, 'acier', '80', 'classic', 'urbain'),
('600', 320, 0.50, 'acier', '80', 'classic', 'urbain'),
('1300', 1460, 0.50, 'acier', '80', 'classic', 'urbain'),
('600', 380, 0.80, 'béton', '50', 'classic', 'rural'),
('1000', 800, 0.80, 'béton', '50', 'classic', 'rural'),
('110', 30, 0.25, 'PVC', '60', 'classic', 'urbain'),
('225', 80, 0.35, 'PVC', '60', 'classic', 'urbain');


select template.basic_view('diam_type_table') ;

create table ___.canalisation_bloc(
id integer primary key,
shape ___.geo_type not null default 'LineString',
geom geometry('LINESTRING', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('canalisation_bloc', abbreviation=>'canalisation'),
formula varchar[] default array[]::varchar[],
formula_name varchar[] default array[]::varchar[],
qe_e real,
dbo5_e real,
mes_e real,
ngl_e real,
qe_s real,
dbo5_s real,
mes_s real,
ngl_s real,
ml real,

-- cana ___.cana_type not null default row('fonte', 'rural', '100', '80', 'classic'),

diam ___.diam_type not null default '100',
materiau ___.mat_cana_type not null default 'fonte',
urbain ___.urban_type not null default 'urbain',
d_vie ___.dvie_type not null default '80',
sans_tranche ___.method_type not null default 'classic',


foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade,
unique (name, id)
);

create table ___.canalisation_bloc_config(
    like ___.canalisation_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.canalisation_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

-- select api.add_new_bloc('canalisation', 'bloc', 'LineString' 
--     );
select api.add_new_bloc('canalisation', 'bloc', 'LineString' 
    ,additional_columns => '{diam_type_table.FE as diam_FE, diam_type_table.description as diam_description}'
    ,additional_join => 'left join ___.diam_type_table on diam_type_table.val = c.diam::varchar::___.diam_type and diam_type_table.materiau = c.materiau and diam_type_table.urbain = c.urbain::varchar::___.urban_type and diam_type_table.d_vie = c.d_vie::varchar::___.dvie_type and diam_type_table.sans_tranche = c.sans_tranche::varchar::___.method_type' 
    ) ;
select api.add_new_formula('CO2 construction canalisation 2'::varchar, 'co2_c=ml*diam'::varchar, 2, ''::text) ;

-- select api.add_new_bloc('canalisation', 'bloc', 'LineString' 
--     ,additional_columns => '{diam_type_table.FE as cana_FE, diam_type_table.description as cana_description}'
--     ,additional_join => 'left join ___.diam_type_table on diam_type_table.val = c.cana' 
--     ) ;

-- Tentative abandonnée de faire un truc bien pour QGIS avec des types enum, mais ça marche pas top parce que ça demande d'altérer des tables dans un trigger
-- Ce qui n'est pas légal

-- create or replace function ___.trigger_update_canalisation_bloc()
-- returns trigger
-- language plpgsql
-- as $$
-- declare 
--     items record ; 
--     possible_meth ___.method_type[] ;
--     query text ;
--     elem varchar ;
-- begin 
--     -- On doit pouvoir changer dans le formulaire : matériau, urbain ou rural et après on ajuste les autres en fonction de ce qui est possible
--     select into items array_agg(urbain) as urbain from ___.diam_type_table where materiau = new.materiau;
--     if not new.urbain::varchar::___.urban_type = any(items.urbain) then
--         new.urbain := items.val[1] ;
--     end if ;

--     select into items array_agg(val) as val, array_agg(d_vie) as d_vie from ___.diam_type_table where materiau = new.materiau and urbain = new.urbain;
--     raise notice 'items = %', items ;
--     if not new.diam::varchar::___.diam_type = any(items.val) then
--         new.diam := items.val[1] ;
--     end if ;
--     if not new.d_vie::varchar::___.dvie_type = any(items.d_vie) then
--         new.d_vie := items.d_vie[1] ;
--     end if ;
    
--     select into possible_meth array_agg(sans_tranche) from ___.diam_type_table where materiau = new.materiau and urbain = new.urbain 
--     and val = new.diam::varchar::___.diam_type and d_vie = new.d_vie::varchar::___.dvie_type ;
--     if not new.sans_tranche::varchar::___.method_type = any(possible_meth) then
--         new.sans_tranche := items.meth[1] ;
--     end if ;

--     delete from ___.diam_values ;
--     insert into ___.diam_values(val) select distinct unnest(items.val) ;
--     delete from ___.method_values ;
--     insert into ___.method_values(val) select distinct unnest(possible_meth) ;
--     delete from ___.dvie_values ;
--     insert into ___.dvie_values(val) select distinct unnest(items.d_vie) ;
    
--     return new ;
-- end ;
-- $$ ;

-- create trigger canalisation_bloc_trigger after insert or update on ___.canalisation_bloc for each row execute function ___.trigger_update_canalisation_bloc() ;



    