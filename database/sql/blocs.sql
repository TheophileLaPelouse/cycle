

alter type ___.bloc_type add value 'tables_degouttage' ;
commit ; 
insert into ___.input_output values ('tables_degouttage', array['q_poly', 'transp_poly', 'tbsortant', 'eh', 'mes', 'dbo5', 'tbentrant', 'welec']::varchar[], array['tbsortant_s']::varchar[], array['CO2 construction tables_degouttage 1', 'CO2 exploitation tables_degouttage 3', 'CO2 construction tables_degouttage 3', 'tbentrant dessableurdegraisseur 1', 'CO2 exploitation q_poly tables_degouttage 6', 'tbentrant bassin_dorage 2', 'CO2 construction tables_degouttage 2', 'CO2 elec 6']::varchar[]) ;

create sequence ___.tables_degouttage_bloc_name_seq ;     




create table ___.tables_degouttage_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('tables_degouttage_bloc', abbreviation=>'tables_degouttage'),
formula varchar[] default array['co2_c=((feobj10_te)*(eh<10000)+(feobj50_te)*(eh>10000)*(eh<100000)+(feobj100_te)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)', 'co2_e=feelec*tbsortant*welec_te', 'co2_c=((feobj10_te)*(eh<10000)+(feobj50_te)*(eh>10000)*(eh<100000)+(feobj100_te)*(eh>100000))*tbentrant', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'co2_e=0.001*q_poly*(1000*fepolymere + transp_poly)', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_c=((feobj10_te)*(eh<10000)+(feobj50_te)*(eh>10000)*(eh<100000)+(feobj100_te)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)', 'co2_e=feelec*welec']::varchar[],
formula_name varchar[] default array['CO2 construction tables_degouttage 1', 'CO2 exploitation tables_degouttage 3', 'CO2 construction tables_degouttage 3', 'tbentrant dessableurdegraisseur 1', 'CO2 exploitation q_poly tables_degouttage 6', 'tbentrant bassin_dorage 2', 'CO2 construction tables_degouttage 2', 'CO2 elec 6']::varchar[],
q_poly real default 5,
transp_poly real default 50,
tbsortant real,
eh real,
mes real,
dbo5 real,
tbentrant real,
welec real,
tbsortant_s real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.tables_degouttage_bloc_config(
    like ___.tables_degouttage_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.tables_degouttage_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('tables_degouttage', 'bloc', 'Point' 
    
    ) ;

select api.add_new_formula('CO2 construction tables_degouttage 1'::varchar, 'co2_c=((feobj10_te)*(eh<10000)+(feobj50_te)*(eh>10000)*(eh<100000)+(feobj100_te)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 exploitation tables_degouttage 3'::varchar, 'co2_e=feelec*tbsortant*welec_te'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 construction tables_degouttage 3'::varchar, 'co2_c=((feobj10_te)*(eh<10000)+(feobj50_te)*(eh>10000)*(eh<100000)+(feobj100_te)*(eh>100000))*tbentrant'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant dessableurdegraisseur 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 exploitation q_poly tables_degouttage 6'::varchar, 'co2_e=0.001*q_poly*(1000*fepolymere + transp_poly)'::varchar, 6, ''::text) ;
select api.add_new_formula('tbentrant bassin_dorage 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 construction tables_degouttage 2'::varchar, 'co2_c=((feobj10_te)*(eh<10000)+(feobj50_te)*(eh>10000)*(eh<100000)+(feobj100_te)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;





alter type ___.bloc_type add value 'flottateur' ;
commit ; 
insert into ___.input_output values ('flottateur', array['q_poly', 'transp_poly', 'tbsortant', 'eh', 'mes', 'dbo5', 'tbentrant', 'welec']::varchar[], array['tbsortant_s']::varchar[], array['tbentrant dessableurdegraisseur 1', 'CO2 construction flottateur 1', 'CO2 construction flottateur 2', 'CO2 exploitation q_poly tables_degouttage 6', 'tbentrant bassin_dorage 2', 'CO2 elec 6', 'CO2 construction flottateur 3', 'CO2 exploitation flottateur 3']::varchar[]) ;

create sequence ___.flottateur_bloc_name_seq ;     




create table ___.flottateur_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('flottateur_bloc', abbreviation=>'flottateur'),
formula varchar[] default array['tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'co2_c=((feobj10_flot)*(eh<10000)+(feobj50_flot)*(eh>10000)*(eh<100000)+(feobj100_flot)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)', 'co2_c=((feobj10_flot)*(eh<10000)+(feobj50_flot)*(eh>10000)*(eh<100000)+(feobj100_flot)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)', 'co2_e=0.001*q_poly*(1000*fepolymere + transp_poly)', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec', 'co2_c=((feobj10_flot)*(eh<10000)+(feobj50_flot)*(eh>10000)*(eh<100000)+(feobj100_flot)*(eh>100000))*tbentrant', 'co2_e=feelec*tbsortant*welec_flot']::varchar[],
formula_name varchar[] default array['tbentrant dessableurdegraisseur 1', 'CO2 construction flottateur 1', 'CO2 construction flottateur 2', 'CO2 exploitation q_poly tables_degouttage 6', 'tbentrant bassin_dorage 2', 'CO2 elec 6', 'CO2 construction flottateur 3', 'CO2 exploitation flottateur 3']::varchar[],
q_poly real default 0,
transp_poly real default 50,
tbsortant real,
eh real,
mes real,
dbo5 real,
tbentrant real,
welec real,
tbsortant_s real,

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

select api.add_new_formula('tbentrant dessableurdegraisseur 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 construction flottateur 1'::varchar, 'co2_c=((feobj10_flot)*(eh<10000)+(feobj50_flot)*(eh>10000)*(eh<100000)+(feobj100_flot)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 construction flottateur 2'::varchar, 'co2_c=((feobj10_flot)*(eh<10000)+(feobj50_flot)*(eh>10000)*(eh<100000)+(feobj100_flot)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 exploitation q_poly tables_degouttage 6'::varchar, 'co2_e=0.001*q_poly*(1000*fepolymere + transp_poly)'::varchar, 6, ''::text) ;
select api.add_new_formula('tbentrant bassin_dorage 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 construction flottateur 3'::varchar, 'co2_c=((feobj10_flot)*(eh<10000)+(feobj50_flot)*(eh>10000)*(eh<100000)+(feobj100_flot)*(eh>100000))*tbentrant'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 exploitation flottateur 3'::varchar, 'co2_e=feelec*tbsortant*welec_flot'::varchar, 3, ''::text) ;





alter type ___.bloc_type add value 'decanteur_lamellaire' ;
commit ; 
insert into ___.input_output values ('decanteur_lamellaire', array['long', 'e', 'larg', 'h', 'tauenterre', 'abatdco', 'eh', 'abatngl', 'w_dbo5_eau', 'dbo5elim', 'dco', 'ntk', 'mes', 'dbo5', 'welec']::varchar[], array['ngl_s', 'dco_s', 'qe_s']::varchar[], array['dco_s fpr 3', 'CO2 construction decanteur_lamellaire 3', 'ngl_s bassin_dorage 3', 'tbentrant dessableurdegraisseur 1', 'ngl_s bassin_dorage 3', 'dco_s fpr 3', 'CO2 exploitation fpr 3', 'tbentrant bassin_dorage 2', 'CO2 elec 6']::varchar[]) ;

create sequence ___.decanteur_lamellaire_bloc_name_seq ;     




create table ___.decanteur_lamellaire_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('decanteur_lamellaire_bloc', abbreviation=>'decanteur_lamellaire'),
formula varchar[] default array['dco_s=dco*(1 - abatdco)', 'co2_c=febet*e*rhobet*(larg*long + 2*larg*(h + e) + 2*long*(h + e)) + feevac*rhoterre*tauenterre*(h + e)*(e + larg)*(e + long) + fefonda*(e + larg)*(e + long) + fepelle*cad*tauenterre*(h + e)*(e + larg)*(e + long)', 'ngl_s=eh*ntk_eh*(1 - abatngl)', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'ngl_s=ntk*(1 - abatngl)', 'dco_s=eh*dco_eh*(1 - abatdco)', 'co2_e=feelec*dbo5elim*w_dbo5_eau', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec']::varchar[],
formula_name varchar[] default array['dco_s fpr 3', 'CO2 construction decanteur_lamellaire 3', 'ngl_s bassin_dorage 3', 'tbentrant dessableurdegraisseur 1', 'ngl_s bassin_dorage 3', 'dco_s fpr 3', 'CO2 exploitation fpr 3', 'tbentrant bassin_dorage 2', 'CO2 elec 6']::varchar[],
long real,
e real default 0.25,
larg real,
h real default 5,
tauenterre real default 0.75,
abatdco real,
eh real,
abatngl real,
w_dbo5_eau real,
dbo5elim real,
dco real,
ntk real,
mes real,
dbo5 real,
welec real,
ngl_s real,
dco_s real,
qe_s real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.decanteur_lamellaire_bloc_config(
    like ___.decanteur_lamellaire_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.decanteur_lamellaire_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('decanteur_lamellaire', 'bloc', 'Point' 
    
    ) ;

select api.add_new_formula('dco_s fpr 3'::varchar, 'dco_s=dco*(1 - abatdco)'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 construction decanteur_lamellaire 3'::varchar, 'co2_c=febet*e*rhobet*(larg*long + 2*larg*(h + e) + 2*long*(h + e)) + feevac*rhoterre*tauenterre*(h + e)*(e + larg)*(e + long) + fefonda*(e + larg)*(e + long) + fepelle*cad*tauenterre*(h + e)*(e + larg)*(e + long)'::varchar, 3, ''::text) ;
select api.add_new_formula('ngl_s bassin_dorage 3'::varchar, 'ngl_s=eh*ntk_eh*(1 - abatngl)'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant dessableurdegraisseur 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('ngl_s bassin_dorage 3'::varchar, 'ngl_s=ntk*(1 - abatngl)'::varchar, 3, ''::text) ;
select api.add_new_formula('dco_s fpr 3'::varchar, 'dco_s=eh*dco_eh*(1 - abatdco)'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 exploitation fpr 3'::varchar, 'co2_e=feelec*dbo5elim*w_dbo5_eau'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant bassin_dorage 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;





alter type ___.bloc_type add value 'excavation' ;
commit ; 
insert into ___.input_output values ('excavation', array['vterre']::varchar[], array[]::varchar[], array['CO2 construction excavation 5']::varchar[]) ;

create sequence ___.excavation_bloc_name_seq ;     




create table ___.excavation_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('excavation_bloc', abbreviation=>'excavation'),
formula varchar[] default array['co2_c=vterre*(feevac*rhoterre + fepelle*cad)']::varchar[],
formula_name varchar[] default array['CO2 construction excavation 5']::varchar[],
vterre real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.excavation_bloc_config(
    like ___.excavation_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.excavation_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('excavation', 'bloc', 'Point' 
    
    ) ;

select api.add_new_formula('CO2 construction excavation 5'::varchar, 'co2_c=vterre*(feevac*rhoterre + fepelle*cad)'::varchar, 5, ''::text) ;





alter type ___.bloc_type add value 'dessableurdegraisseur' ;
commit ; 
insert into ___.input_output values ('dessableurdegraisseur', array['w_dbo5_eau', 'dbo5elim', 'e', 'eh', 'vit', 'h', 'tauenterre', 'abatdco', 'abatngl', 'qe', 'dco', 'ntk', 'mes', 'dbo5', 'tgraisses', 'tsables', 'vu', 'welec']::varchar[], array['qe_s', 'ngl_s', 'dco_s']::varchar[], array['dco_s fpr 3', 'ngl_s bassin_dorage 3', 'tbentrant dessableurdegraisseur 1', 'CO2 construction degazage 2', 'ngl_s bassin_dorage 3', 'dco_s fpr 3', 'CO2 exploitation fpr 3', 'tbentrant bassin_dorage 2', 'CO2 construction bassin_cylindrique 3', 'CO2 elec 6', 'CO2 construction dessableurdegraisseur 1', 'CO2 exploitation dessableurdegraisseur 3']::varchar[]) ;

create sequence ___.dessableurdegraisseur_bloc_name_seq ;     




create table ___.dessableurdegraisseur_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('dessableurdegraisseur_bloc', abbreviation=>'dessableurdegraisseur'),
formula varchar[] default array['dco_s=dco*(1 - abatdco)', 'ngl_s=eh*ntk_eh*(1 - abatngl)', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'co2_c=(febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe/vit)**0.5) + 24*qe) + 24.0*vit*(0.3618*e + (qe/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda + fepelle*cad*tauenterre*(h + e)))/vit', 'ngl_s=ntk*(1 - abatngl)', 'dco_s=eh*dco_eh*(1 - abatdco)', 'co2_e=feelec*dbo5elim*w_dbo5_eau', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_c=(febet*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*h*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda + fepelle*cad*tauenterre*(h + e)))/h', 'co2_e=feelec*welec', 'co2_c=(febet*e*rhobet*(24*eh*qe_eh + 3.14159*h*vit*(e + 5.52791*(eh*qe_eh/vit)**0.5)) + 24.0*vit*(0.3618*e + (eh*qe_eh/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda + fepelle*cad*tauenterre*(h + e)))/vit', 'co2_e=fedechet*tgraisses + fesables*tsables']::varchar[],
formula_name varchar[] default array['dco_s fpr 3', 'ngl_s bassin_dorage 3', 'tbentrant dessableurdegraisseur 1', 'CO2 construction degazage 2', 'ngl_s bassin_dorage 3', 'dco_s fpr 3', 'CO2 exploitation fpr 3', 'tbentrant bassin_dorage 2', 'CO2 construction bassin_cylindrique 3', 'CO2 elec 6', 'CO2 construction dessableurdegraisseur 1', 'CO2 exploitation dessableurdegraisseur 3']::varchar[],
w_dbo5_eau real,
dbo5elim real,
e real default 0.25,
eh real,
vit real default 20,
h real default 4,
tauenterre real default 0.75,
abatdco real,
abatngl real,
qe real,
dco real,
ntk real,
mes real,
dbo5 real,
tgraisses real,
tsables real,
vu real,
welec real,
qe_s real,
ngl_s real,
dco_s real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.dessableurdegraisseur_bloc_config(
    like ___.dessableurdegraisseur_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.dessableurdegraisseur_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('dessableurdegraisseur', 'bloc', 'Point' 
    
    ) ;

select api.add_new_formula('dco_s fpr 3'::varchar, 'dco_s=dco*(1 - abatdco)'::varchar, 3, ''::text) ;
select api.add_new_formula('ngl_s bassin_dorage 3'::varchar, 'ngl_s=eh*ntk_eh*(1 - abatngl)'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant dessableurdegraisseur 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 construction degazage 2'::varchar, 'co2_c=(febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe/vit)**0.5) + 24*qe) + 24.0*vit*(0.3618*e + (qe/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda + fepelle*cad*tauenterre*(h + e)))/vit'::varchar, 2, ''::text) ;
select api.add_new_formula('ngl_s bassin_dorage 3'::varchar, 'ngl_s=ntk*(1 - abatngl)'::varchar, 3, ''::text) ;
select api.add_new_formula('dco_s fpr 3'::varchar, 'dco_s=eh*dco_eh*(1 - abatdco)'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 exploitation fpr 3'::varchar, 'co2_e=feelec*dbo5elim*w_dbo5_eau'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant bassin_dorage 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 construction bassin_cylindrique 3'::varchar, 'co2_c=(febet*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*h*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda + fepelle*cad*tauenterre*(h + e)))/h'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 construction dessableurdegraisseur 1'::varchar, 'co2_c=(febet*e*rhobet*(24*eh*qe_eh + 3.14159*h*vit*(e + 5.52791*(eh*qe_eh/vit)**0.5)) + 24.0*vit*(0.3618*e + (eh*qe_eh/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda + fepelle*cad*tauenterre*(h + e)))/vit'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 exploitation dessableurdegraisseur 3'::varchar, 'co2_e=fedechet*tgraisses + fesables*tsables'::varchar, 3, ''::text) ;





alter type ___.bloc_type add value 'rejets' ;
commit ; 
insert into ___.input_output values ('rejets', array['fech4_mil', 'abatdco', 'eh', 'abatngl', 'fen2o_oxi', 'dco', 'ngl']::varchar[], array[]::varchar[], array['CH4 exploitation rejets 2', 'N2O exploitation rejets 1', 'N2O exploitation rejets 2', 'CH4 exploitation rejets 1']::varchar[]) ;

create sequence ___.rejets_bloc_name_seq ;     

create type ___.fech4_mil_type as enum ('Autres', 'Réservoirs, lac, estuaires');
create type ___.fen2o_oxi_type as enum ('Bien oxigéné', 'Peu oxigéné');

create table ___.fech4_mil_type_table(val ___.fech4_mil_type primary key, FE real, incert real default 0, description text);
insert into ___.fech4_mil_type_table(val) values ('Autres') ;
insert into ___.fech4_mil_type_table(val) values ('Réservoirs, lac, estuaires') ;
create table ___.fen2o_oxi_type_table(val ___.fen2o_oxi_type primary key, FE real, incert real default 0, description text);
insert into ___.fen2o_oxi_type_table(val) values ('Bien oxigéné') ;
insert into ___.fen2o_oxi_type_table(val) values ('Peu oxigéné') ;

select template.basic_view('fech4_mil_type_table') ;
select template.basic_view('fen2o_oxi_type_table') ;

create table ___.rejets_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('rejets_bloc', abbreviation=>'rejets'),
formula varchar[] default array['ch4_e=dco*fech4_mil', 'n2o_e=eh*fen2o_oxi*ntk_eh*(1 - abatngl)', 'n2o_e=fen2o_oxi*ngl', 'ch4_e=eh*fech4_mil*dco_eh*(1 - abatdco)']::varchar[],
formula_name varchar[] default array['CH4 exploitation rejets 2', 'N2O exploitation rejets 1', 'N2O exploitation rejets 2', 'CH4 exploitation rejets 1']::varchar[],
fech4_mil ___.fech4_mil_type not null default 'Autres' references ___.fech4_mil_type_table(val),
abatdco real default 0.75,
eh real,
abatngl real default 0.8,
fen2o_oxi ___.fen2o_oxi_type not null default 'Bien oxigéné' references ___.fen2o_oxi_type_table(val),
dco real,
ngl real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.rejets_bloc_config(
    like ___.rejets_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.rejets_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('rejets', 'bloc', 'Point' 
    ,additional_columns => '{fech4_mil_type_table.FE as fech4_mil_FE, fech4_mil_type_table.description as fech4_mil_description, fen2o_oxi_type_table.FE as fen2o_oxi_FE, fen2o_oxi_type_table.description as fen2o_oxi_description}'
    ,additional_join => 'left join ___.fech4_mil_type_table on fech4_mil_type_table.val = c.fech4_mil  join ___.fen2o_oxi_type_table on fen2o_oxi_type_table.val = c.fen2o_oxi ') ;

select api.add_new_formula('CH4 exploitation rejets 2'::varchar, 'ch4_e=dco*fech4_mil'::varchar, 2, ''::text) ;
select api.add_new_formula('N2O exploitation rejets 1'::varchar, 'n2o_e=eh*fen2o_oxi*ntk_eh*(1 - abatngl)'::varchar, 1, ''::text) ;
select api.add_new_formula('N2O exploitation rejets 2'::varchar, 'n2o_e=fen2o_oxi*ngl'::varchar, 2, ''::text) ;
select api.add_new_formula('CH4 exploitation rejets 1'::varchar, 'ch4_e=eh*fech4_mil*dco_eh*(1 - abatdco)'::varchar, 1, ''::text) ;





alter type ___.bloc_type add value 'centrifugeuse_pour_deshy' ;
commit ; 
insert into ___.input_output values ('centrifugeuse_pour_deshy', array['q_poly', 'transp_poly', 'tbsortant', 'direct', 'eh', 'mes', 'dbo5', 'tbentrant', 'welec']::varchar[], array['tbsortant_s']::varchar[], array['tbentrant dessableurdegraisseur 1', 'CO2 construction centrifugeuse_pour_deshy 1', 'CO2 construction centrifugeuse_pour_deshy 3', 'CO2 exploitation q_poly tables_degouttage 6', 'CO2 construction centrifugeuse_pour_deshy 2', 'tbentrant bassin_dorage 2', 'CO2 elec 6', 'CO2 exploitation centrifugeuse_pour_deshy 3']::varchar[]) ;

create sequence ___.centrifugeuse_pour_deshy_bloc_name_seq ;     




create table ___.centrifugeuse_pour_deshy_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('centrifugeuse_pour_deshy_bloc', abbreviation=>'centrifugeuse_pour_deshy'),
formula varchar[] default array['tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'co2_c=((feobj10_cd)*(eh<10000)+(feobj50_cd)*(eh>10000)*(eh<100000)+(feobj100_cd)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)', 'co2_c=((feobj10_cd)*(eh<10000)+(feobj50_cd)*(eh>10000)*(eh<100000)+(feobj100_cd)*(eh>100000))*tbentrant', 'co2_e=0.001*q_poly*(1000*fepolymere + transp_poly)', 'co2_c=((feobj10_cd)*(eh<10000)+(feobj50_cd)*(eh>10000)*(eh<100000)+(feobj100_cd)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec', 'co2_e=feelec*tbsortant*(-welec_cd*direct + welec_cd + welec_direct*direct)']::varchar[],
formula_name varchar[] default array['tbentrant dessableurdegraisseur 1', 'CO2 construction centrifugeuse_pour_deshy 1', 'CO2 construction centrifugeuse_pour_deshy 3', 'CO2 exploitation q_poly tables_degouttage 6', 'CO2 construction centrifugeuse_pour_deshy 2', 'tbentrant bassin_dorage 2', 'CO2 elec 6', 'CO2 exploitation centrifugeuse_pour_deshy 3']::varchar[],
q_poly real default 10,
transp_poly real default 50,
tbsortant real,
direct integer default 0,
eh real,
mes real,
dbo5 real,
tbentrant real,
welec real,
tbsortant_s real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.centrifugeuse_pour_deshy_bloc_config(
    like ___.centrifugeuse_pour_deshy_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.centrifugeuse_pour_deshy_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('centrifugeuse_pour_deshy', 'bloc', 'Point' 
    
    ) ;

select api.add_new_formula('tbentrant dessableurdegraisseur 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 construction centrifugeuse_pour_deshy 1'::varchar, 'co2_c=((feobj10_cd)*(eh<10000)+(feobj50_cd)*(eh>10000)*(eh<100000)+(feobj100_cd)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 construction centrifugeuse_pour_deshy 3'::varchar, 'co2_c=((feobj10_cd)*(eh<10000)+(feobj50_cd)*(eh>10000)*(eh<100000)+(feobj100_cd)*(eh>100000))*tbentrant'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 exploitation q_poly tables_degouttage 6'::varchar, 'co2_e=0.001*q_poly*(1000*fepolymere + transp_poly)'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 construction centrifugeuse_pour_deshy 2'::varchar, 'co2_c=((feobj10_cd)*(eh<10000)+(feobj50_cd)*(eh>10000)*(eh<100000)+(feobj100_cd)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)'::varchar, 2, ''::text) ;
select api.add_new_formula('tbentrant bassin_dorage 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 exploitation centrifugeuse_pour_deshy 3'::varchar, 'co2_e=feelec*tbsortant*(-welec_cd*direct + welec_cd + welec_direct*direct)'::varchar, 3, ''::text) ;





alter type ___.bloc_type add value 'lagunage' ;
commit ; 
insert into ___.input_output values ('lagunage', array['abatdco', 'eh', 'abatngl', 'w_dbo5_eau', 'dbo5elim', 'dco', 'ntk', 'mes', 'dbo5', 'welec']::varchar[], array['ngl_s', 'dco_s', 'qe_s']::varchar[], array['dco_s fpr 3', 'ngl_s bassin_dorage 3', 'tbentrant dessableurdegraisseur 1', 'ngl_s bassin_dorage 3', 'dco_s fpr 3', 'CO2 exploitation fpr 3', 'tbentrant bassin_dorage 2', 'CO2 elec 6']::varchar[]) ;

create sequence ___.lagunage_bloc_name_seq ;     




create table ___.lagunage_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('lagunage_bloc', abbreviation=>'lagunage'),
formula varchar[] default array['dco_s=dco*(1 - abatdco)', 'ngl_s=eh*ntk_eh*(1 - abatngl)', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'ngl_s=ntk*(1 - abatngl)', 'dco_s=eh*dco_eh*(1 - abatdco)', 'co2_e=feelec*dbo5elim*w_dbo5_eau', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec']::varchar[],
formula_name varchar[] default array['dco_s fpr 3', 'ngl_s bassin_dorage 3', 'tbentrant dessableurdegraisseur 1', 'ngl_s bassin_dorage 3', 'dco_s fpr 3', 'CO2 exploitation fpr 3', 'tbentrant bassin_dorage 2', 'CO2 elec 6']::varchar[],
abatdco real,
eh real,
abatngl real,
w_dbo5_eau real,
dbo5elim real,
dco real,
ntk real,
mes real,
dbo5 real,
welec real,
ngl_s real,
dco_s real,
qe_s real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.lagunage_bloc_config(
    like ___.lagunage_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.lagunage_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('lagunage', 'bloc', 'Point' 
    
    ) ;

select api.add_new_formula('dco_s fpr 3'::varchar, 'dco_s=dco*(1 - abatdco)'::varchar, 3, ''::text) ;
select api.add_new_formula('ngl_s bassin_dorage 3'::varchar, 'ngl_s=eh*ntk_eh*(1 - abatngl)'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant dessableurdegraisseur 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('ngl_s bassin_dorage 3'::varchar, 'ngl_s=ntk*(1 - abatngl)'::varchar, 3, ''::text) ;
select api.add_new_formula('dco_s fpr 3'::varchar, 'dco_s=eh*dco_eh*(1 - abatdco)'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 exploitation fpr 3'::varchar, 'co2_e=feelec*dbo5elim*w_dbo5_eau'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant bassin_dorage 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;





alter type ___.bloc_type add value 'conditionnement_thermiqu' ;
commit ; 
insert into ___.input_output values ('conditionnement_thermiqu', array['eh', 'vboue', 'mes', 'dbo5', 'tbentrant', 'welec']::varchar[], array['tbsortant_s']::varchar[], array['CO2 construction conditionnement_thermiqu 3', 'CO2 construction conditionnement_thermiqu 2', 'tbentrant dessableurdegraisseur 1', 'tbentrant bassin_dorage 2', 'CO2 elec 6', 'CO2 construction conditionnement_thermiqu 1', 'CO2 exploitation conditionnement_thermiqu 3']::varchar[]) ;

create sequence ___.conditionnement_thermiqu_bloc_name_seq ;     




create table ___.conditionnement_thermiqu_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('conditionnement_thermiqu_bloc', abbreviation=>'conditionnement_thermiqu'),
formula varchar[] default array['co2_c=((feobj50_ct)*(eh>10000)*(eh<100000)+(feobj100_ct)*(eh>100000))*tbentrant', 'co2_c=((feobj50_ct)*(eh>10000)*(eh<100000)+(feobj100_ct)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec', 'co2_c=((feobj50_ct)*(eh>10000)*(eh<100000)+(feobj100_ct)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)', 'co2_e=feelec*vboue*welec_ct']::varchar[],
formula_name varchar[] default array['CO2 construction conditionnement_thermiqu 3', 'CO2 construction conditionnement_thermiqu 2', 'tbentrant dessableurdegraisseur 1', 'tbentrant bassin_dorage 2', 'CO2 elec 6', 'CO2 construction conditionnement_thermiqu 1', 'CO2 exploitation conditionnement_thermiqu 3']::varchar[],
eh real,
vboue real,
mes real,
dbo5 real,
tbentrant real,
welec real,
tbsortant_s real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.conditionnement_thermiqu_bloc_config(
    like ___.conditionnement_thermiqu_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.conditionnement_thermiqu_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('conditionnement_thermiqu', 'bloc', 'Point' 
    
    ) ;

select api.add_new_formula('CO2 construction conditionnement_thermiqu 3'::varchar, 'co2_c=((feobj50_ct)*(eh>10000)*(eh<100000)+(feobj100_ct)*(eh>100000))*tbentrant'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 construction conditionnement_thermiqu 2'::varchar, 'co2_c=((feobj50_ct)*(eh>10000)*(eh<100000)+(feobj100_ct)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)'::varchar, 2, ''::text) ;
select api.add_new_formula('tbentrant dessableurdegraisseur 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('tbentrant bassin_dorage 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 construction conditionnement_thermiqu 1'::varchar, 'co2_c=((feobj50_ct)*(eh>10000)*(eh<100000)+(feobj100_ct)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 exploitation conditionnement_thermiqu 3'::varchar, 'co2_e=feelec*vboue*welec_ct'::varchar, 3, ''::text) ;





alter type ___.bloc_type add value 'batiment_dexploitation' ;
commit ; 
insert into ___.input_output values ('batiment_dexploitation', array['welec']::varchar[], array[]::varchar[], array['CO2 elec 6']::varchar[]) ;

create sequence ___.batiment_dexploitation_bloc_name_seq ;     




create table ___.batiment_dexploitation_bloc(
id integer primary key,
shape ___.geo_type not null default 'Polygon',
geom geometry('POLYGON', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('batiment_dexploitation_bloc', abbreviation=>'batiment_dexploitation'),
formula varchar[] default array['co2_e=feelec*welec']::varchar[],
formula_name varchar[] default array['CO2 elec 6']::varchar[],
welec real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.batiment_dexploitation_bloc_config(
    like ___.batiment_dexploitation_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.batiment_dexploitation_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('batiment_dexploitation', 'bloc', 'Polygon' 
    
    ) ;

select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;





alter type ___.bloc_type add value 'filtre_a_presse' ;
commit ; 
insert into ___.input_output values ('filtre_a_presse', array['q_chaux', 'q_poly', 'transp_chaux', 'transp_poly', 'transp_fecl3', 'q_fecl3', 'eh', 'mes', 'dbo5', 'tbentrant', 'welec']::varchar[], array['tbsortant_s']::varchar[], array['CO2 construction filtre_a_presse 2', 'tbentrant dessableurdegraisseur 1', 'tbentrant bassin_dorage 2', 'CO2 exploitation intrant filtre_a_presse 6', 'CO2 elec 6', 'CO2 construction filtre_a_presse 3', 'CO2 construction filtre_a_presse 1']::varchar[]) ;

create sequence ___.filtre_a_presse_bloc_name_seq ;     




create table ___.filtre_a_presse_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('filtre_a_presse_bloc', abbreviation=>'filtre_a_presse'),
formula varchar[] default array['co2_c=((feobj10_fp)*(eh<10000)+(feobj50_fp)*(eh>10000)*(eh<100000)+(feobj100_fp)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=fepolymere*q_poly + 0.001*q_chaux*(1000*fechaux + transp_chaux) + 0.001*q_fecl3*(1000*fefecl3 + transp_fecl3) + 0.001*q_poly*transp_poly', 'co2_e=feelec*welec', 'co2_c=((feobj10_fp)*(eh<10000)+(feobj50_fp)*(eh>10000)*(eh<100000)+(feobj100_fp)*(eh>100000))*tbentrant', 'co2_c=((feobj10_fp)*(eh<10000)+(feobj50_fp)*(eh>10000)*(eh<100000)+(feobj100_fp)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)']::varchar[],
formula_name varchar[] default array['CO2 construction filtre_a_presse 2', 'tbentrant dessableurdegraisseur 1', 'tbentrant bassin_dorage 2', 'CO2 exploitation intrant filtre_a_presse 6', 'CO2 elec 6', 'CO2 construction filtre_a_presse 3', 'CO2 construction filtre_a_presse 1']::varchar[],
q_chaux real,
q_poly real,
transp_chaux real,
transp_poly real default 50,
transp_fecl3 real,
q_fecl3 real,
eh real,
mes real,
dbo5 real,
tbentrant real,
welec real,
tbsortant_s real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.filtre_a_presse_bloc_config(
    like ___.filtre_a_presse_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.filtre_a_presse_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('filtre_a_presse', 'bloc', 'Point' 
    
    ) ;

select api.add_new_formula('CO2 construction filtre_a_presse 2'::varchar, 'co2_c=((feobj10_fp)*(eh<10000)+(feobj50_fp)*(eh>10000)*(eh<100000)+(feobj100_fp)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)'::varchar, 2, ''::text) ;
select api.add_new_formula('tbentrant dessableurdegraisseur 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('tbentrant bassin_dorage 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 exploitation intrant filtre_a_presse 6'::varchar, 'co2_e=fepolymere*q_poly + 0.001*q_chaux*(1000*fechaux + transp_chaux) + 0.001*q_fecl3*(1000*fefecl3 + transp_fecl3) + 0.001*q_poly*transp_poly'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 construction filtre_a_presse 3'::varchar, 'co2_c=((feobj10_fp)*(eh<10000)+(feobj50_fp)*(eh>10000)*(eh<100000)+(feobj100_fp)*(eh>100000))*tbentrant'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 construction filtre_a_presse 1'::varchar, 'co2_c=((feobj10_fp)*(eh<10000)+(feobj50_fp)*(eh>10000)*(eh<100000)+(feobj100_fp)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)'::varchar, 1, ''::text) ;





alter type ___.bloc_type add value 'epaississement_statique' ;
commit ; 
insert into ___.input_output values ('epaississement_statique', array['eh', 'tbsortant', 'mes', 'dbo5', 'tbentrant', 'welec']::varchar[], array['tbsortant_s']::varchar[], array['tbentrant dessableurdegraisseur 1', 'CO2 construction epaississement_statique 2', 'tbentrant bassin_dorage 2', 'CO2 elec 6', 'CO2 construction epaississement_statique 3', 'CO2 exploitation epaississement_statique 3', 'CO2 construction epaississement_statique 1']::varchar[]) ;

create sequence ___.epaississement_statique_bloc_name_seq ;     




create table ___.epaississement_statique_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('epaississement_statique_bloc', abbreviation=>'epaississement_statique'),
formula varchar[] default array['tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'co2_c=((feobj10_es)*(eh<10000)+(feobj50_es)*(eh>10000)*(eh<100000)+(feobj100_es)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec', 'co2_c=((feobj10_es)*(eh<10000)+(feobj50_es)*(eh>10000)*(eh<100000)+(feobj100_es)*(eh>100000))*tbentrant', 'co2_e=feelec*tbsortant*welec_es', 'co2_c=((feobj10_es)*(eh<10000)+(feobj50_es)*(eh>10000)*(eh<100000)+(feobj100_es)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)']::varchar[],
formula_name varchar[] default array['tbentrant dessableurdegraisseur 1', 'CO2 construction epaississement_statique 2', 'tbentrant bassin_dorage 2', 'CO2 elec 6', 'CO2 construction epaississement_statique 3', 'CO2 exploitation epaississement_statique 3', 'CO2 construction epaississement_statique 1']::varchar[],
eh real,
tbsortant real,
mes real,
dbo5 real,
tbentrant real,
welec real,
tbsortant_s real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.epaississement_statique_bloc_config(
    like ___.epaississement_statique_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.epaississement_statique_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('epaississement_statique', 'bloc', 'Point' 
    
    ) ;

select api.add_new_formula('tbentrant dessableurdegraisseur 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 construction epaississement_statique 2'::varchar, 'co2_c=((feobj10_es)*(eh<10000)+(feobj50_es)*(eh>10000)*(eh<100000)+(feobj100_es)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)'::varchar, 2, ''::text) ;
select api.add_new_formula('tbentrant bassin_dorage 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 construction epaississement_statique 3'::varchar, 'co2_c=((feobj10_es)*(eh<10000)+(feobj50_es)*(eh>10000)*(eh<100000)+(feobj100_es)*(eh>100000))*tbentrant'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 exploitation epaississement_statique 3'::varchar, 'co2_e=feelec*tbsortant*welec_es'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 construction epaississement_statique 1'::varchar, 'co2_c=((feobj10_es)*(eh<10000)+(feobj50_es)*(eh>10000)*(eh<100000)+(feobj100_es)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)'::varchar, 1, ''::text) ;





alter type ___.bloc_type add value 'chateau_deau' ;
commit ; 
insert into ___.input_output values ('chateau_deau', array['mpompe', 'vbet']::varchar[], array[]::varchar[], array['CO2 construction chateau_deau 5']::varchar[]) ;

create sequence ___.chateau_deau_bloc_name_seq ;     




create table ___.chateau_deau_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('chateau_deau_bloc', abbreviation=>'chateau_deau'),
formula varchar[] default array['co2_c=febet*vbet*rhobet + fepoids*mpompe']::varchar[],
formula_name varchar[] default array['CO2 construction chateau_deau 5']::varchar[],
mpompe real,
vbet real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.chateau_deau_bloc_config(
    like ___.chateau_deau_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.chateau_deau_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('chateau_deau', 'bloc', 'Point' 
    
    ) ;

select api.add_new_formula('CO2 construction chateau_deau 5'::varchar, 'co2_c=febet*vbet*rhobet + fepoids*mpompe'::varchar, 5, ''::text) ;





alter type ___.bloc_type add value 'clarificateur' ;
commit ; 
insert into ___.input_output values ('clarificateur', array['e', 'eh', 'vit', 'taur', 'h', 'tauenterre', 'abatdco', 'abatngl', 'w_dbo5_eau', 'dbo5elim', 'qe', 'dco', 'ntk', 'mes', 'dbo5', 'vu', 'welec']::varchar[], array['tbentrant_s', 'ngl_s', 'dco_s', 'qe_s']::varchar[], array['dco_s fpr 3', 'ngl_s bassin_dorage 3', 'tbentrant dessableurdegraisseur 1', 'ngl_s bassin_dorage 3', 'dco_s fpr 3', 'CO2 exploitation fpr 3', 'CO2 construction clarificateur 1', 'tbentrant bassin_dorage 2', 'CO2 construction bassin_cylindrique 3', 'CO2 elec 6', 'CO2 construction clarificateur 2']::varchar[]) ;

create sequence ___.clarificateur_bloc_name_seq ;     




create table ___.clarificateur_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('clarificateur_bloc', abbreviation=>'clarificateur'),
formula varchar[] default array['dco_s=dco*(1 - abatdco)', 'ngl_s=eh*ntk_eh*(1 - abatngl)', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'ngl_s=ntk*(1 - abatngl)', 'dco_s=eh*dco_eh*(1 - abatdco)', 'co2_e=feelec*dbo5elim*w_dbo5_eau', 'co2_c=(febet*e*rhobet*(24*eh*qe_eh*(taur + 1) + 3.14159*h*vit*(e + 5.52791*(eh*qe_eh*(taur + 1)/vit)**0.5)) + 24.0*vit*(0.3618*e + (eh*qe_eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda + fepelle*cad*tauenterre*(h + e)))/vit', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_c=(febet*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*h*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda + fepelle*cad*tauenterre*(h + e)))/h', 'co2_e=feelec*welec', 'co2_c=(febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*vit*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda + fepelle*cad*tauenterre*(h + e)))/vit']::varchar[],
formula_name varchar[] default array['dco_s fpr 3', 'ngl_s bassin_dorage 3', 'tbentrant dessableurdegraisseur 1', 'ngl_s bassin_dorage 3', 'dco_s fpr 3', 'CO2 exploitation fpr 3', 'CO2 construction clarificateur 1', 'tbentrant bassin_dorage 2', 'CO2 construction bassin_cylindrique 3', 'CO2 elec 6', 'CO2 construction clarificateur 2']::varchar[],
e real default 0.25,
eh real,
vit real default 60,
taur real default 1,
h real default 3,
tauenterre real default 0.75,
abatdco real,
abatngl real,
w_dbo5_eau real,
dbo5elim real,
qe real,
dco real,
ntk real,
mes real,
dbo5 real,
vu real,
welec real,
tbentrant_s real,
ngl_s real,
dco_s real,
qe_s real,

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

select api.add_new_formula('dco_s fpr 3'::varchar, 'dco_s=dco*(1 - abatdco)'::varchar, 3, ''::text) ;
select api.add_new_formula('ngl_s bassin_dorage 3'::varchar, 'ngl_s=eh*ntk_eh*(1 - abatngl)'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant dessableurdegraisseur 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('ngl_s bassin_dorage 3'::varchar, 'ngl_s=ntk*(1 - abatngl)'::varchar, 3, ''::text) ;
select api.add_new_formula('dco_s fpr 3'::varchar, 'dco_s=eh*dco_eh*(1 - abatdco)'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 exploitation fpr 3'::varchar, 'co2_e=feelec*dbo5elim*w_dbo5_eau'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 construction clarificateur 1'::varchar, 'co2_c=(febet*e*rhobet*(24*eh*qe_eh*(taur + 1) + 3.14159*h*vit*(e + 5.52791*(eh*qe_eh*(taur + 1)/vit)**0.5)) + 24.0*vit*(0.3618*e + (eh*qe_eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda + fepelle*cad*tauenterre*(h + e)))/vit'::varchar, 1, ''::text) ;
select api.add_new_formula('tbentrant bassin_dorage 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 construction bassin_cylindrique 3'::varchar, 'co2_c=(febet*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*h*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda + fepelle*cad*tauenterre*(h + e)))/h'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 construction clarificateur 2'::varchar, 'co2_c=(febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*vit*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda + fepelle*cad*tauenterre*(h + e)))/vit'::varchar, 2, ''::text) ;





alter type ___.bloc_type add value 'sechage_thermique' ;
commit ; 
insert into ___.input_output values ('sechage_thermique', array['siccite_e', 'eh', 'pelletisation', 'tbsortant', 'mes', 'dbo5', 'tbentrant', 'tee', 'welec']::varchar[], array['siccite_s', 'tbsortant_s']::varchar[], array['CO2 exploitation sechage_thermique 4', 'CO2 exploitation sechage_thermique 3', 'tbentrant dessableurdegraisseur 1', 'CO2 construction sechage_thermique 1', 'CO2 construction sechage_thermique 2', 'CO2 construction sechage_thermique 3', 'tbentrant bassin_dorage 2', 'CO2 elec 6']::varchar[]) ;

create sequence ___.sechage_thermique_bloc_name_seq ;     




create table ___.sechage_thermique_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('sechage_thermique_bloc', abbreviation=>'sechage_thermique'),
formula varchar[] default array['co2_e=feelec*(24*nbjour*pth*tee - tbsortant*(welec_st_nopell*(pelletisation - 1) - welec_st_pell*pelletisation))', 'co2_e=feelec*tbsortant*(24*nbjour*pth*(siccite_e - siccite_s) - welec_st_nopell*(pelletisation - 1) + welec_st_pell*pelletisation)', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'co2_c=((feobj50_st)*(eh>10000)*(eh<100000)+(feobj100_st)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)', 'co2_c=((feobj50_st)*(eh>10000)*(eh<100000)+(feobj100_st)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)', 'co2_c=((feobj50_st)*(eh>10000)*(eh<100000)+(feobj100_st)*(eh>100000))*tbentrant', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec']::varchar[],
formula_name varchar[] default array['CO2 exploitation sechage_thermique 4', 'CO2 exploitation sechage_thermique 3', 'tbentrant dessableurdegraisseur 1', 'CO2 construction sechage_thermique 1', 'CO2 construction sechage_thermique 2', 'CO2 construction sechage_thermique 3', 'tbentrant bassin_dorage 2', 'CO2 elec 6']::varchar[],
siccite_e real,
eh real,
pelletisation integer default 0,
tbsortant real,
mes real,
dbo5 real,
tbentrant real,
tee real,
welec real,
siccite_s real,
tbsortant_s real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.sechage_thermique_bloc_config(
    like ___.sechage_thermique_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.sechage_thermique_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('sechage_thermique', 'bloc', 'Point' 
    
    ) ;

select api.add_new_formula('CO2 exploitation sechage_thermique 4'::varchar, 'co2_e=feelec*(24*nbjour*pth*tee - tbsortant*(welec_st_nopell*(pelletisation - 1) - welec_st_pell*pelletisation))'::varchar, 4, ''::text) ;
select api.add_new_formula('CO2 exploitation sechage_thermique 3'::varchar, 'co2_e=feelec*tbsortant*(24*nbjour*pth*(siccite_e - siccite_s) - welec_st_nopell*(pelletisation - 1) + welec_st_pell*pelletisation)'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant dessableurdegraisseur 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 construction sechage_thermique 1'::varchar, 'co2_c=((feobj50_st)*(eh>10000)*(eh<100000)+(feobj100_st)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 construction sechage_thermique 2'::varchar, 'co2_c=((feobj50_st)*(eh>10000)*(eh<100000)+(feobj100_st)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 construction sechage_thermique 3'::varchar, 'co2_c=((feobj50_st)*(eh>10000)*(eh<100000)+(feobj100_st)*(eh>100000))*tbentrant'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant bassin_dorage 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;





alter type ___.bloc_type add value 'bassin_cylindrique' ;
commit ; 
insert into ___.input_output values ('bassin_cylindrique', array['e', 'vu', 'h', 'tauenterre']::varchar[], array[]::varchar[], array['CO2 construction bassin_cylindrique 3']::varchar[]) ;

create sequence ___.bassin_cylindrique_bloc_name_seq ;     




create table ___.bassin_cylindrique_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('bassin_cylindrique_bloc', abbreviation=>'bassin_cylindrique'),
formula varchar[] default array['co2_c=(febet*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*h*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda + fepelle*cad*tauenterre*(h + e)))/h']::varchar[],
formula_name varchar[] default array['CO2 construction bassin_cylindrique 3']::varchar[],
e real default 0.25,
vu real,
h real,
tauenterre real default 0.75,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.bassin_cylindrique_bloc_config(
    like ___.bassin_cylindrique_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.bassin_cylindrique_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('bassin_cylindrique', 'bloc', 'Point' 
    
    ) ;

select api.add_new_formula('CO2 construction bassin_cylindrique 3'::varchar, 'co2_c=(febet*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*h*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda + fepelle*cad*tauenterre*(h + e)))/h'::varchar, 3, ''::text) ;





alter type ___.bloc_type add value 'degazage' ;
commit ; 
insert into ___.input_output values ('degazage', array['e', 'eh', 'vit', 'h', 'tauenterre', 'abatdco', 'abatngl', 'w_dbo5_eau', 'dbo5elim', 'qe', 'dco', 'ntk', 'mes', 'dbo5', 'vu', 'welec']::varchar[], array['ngl_s', 'dco_s', 'qe_s']::varchar[], array['dco_s fpr 3', 'ngl_s bassin_dorage 3', 'tbentrant dessableurdegraisseur 1', 'CO2 construction degazage 2', 'ngl_s bassin_dorage 3', 'dco_s fpr 3', 'CO2 exploitation fpr 3', 'tbentrant bassin_dorage 2', 'CO2 construction bassin_cylindrique 3', 'CO2 elec 6', 'CO2 construction dessableurdegraisseur 1']::varchar[]) ;

create sequence ___.degazage_bloc_name_seq ;     




create table ___.degazage_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('degazage_bloc', abbreviation=>'degazage'),
formula varchar[] default array['dco_s=dco*(1 - abatdco)', 'ngl_s=eh*ntk_eh*(1 - abatngl)', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'co2_c=(febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe/vit)**0.5) + 24*qe) + 24.0*vit*(0.3618*e + (qe/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda + fepelle*cad*tauenterre*(h + e)))/vit', 'ngl_s=ntk*(1 - abatngl)', 'dco_s=eh*dco_eh*(1 - abatdco)', 'co2_e=feelec*dbo5elim*w_dbo5_eau', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_c=(febet*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*h*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda + fepelle*cad*tauenterre*(h + e)))/h', 'co2_e=feelec*welec', 'co2_c=(febet*e*rhobet*(24*eh*qe_eh + 3.14159*h*vit*(e + 5.52791*(eh*qe_eh/vit)**0.5)) + 24.0*vit*(0.3618*e + (eh*qe_eh/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda + fepelle*cad*tauenterre*(h + e)))/vit']::varchar[],
formula_name varchar[] default array['dco_s fpr 3', 'ngl_s bassin_dorage 3', 'tbentrant dessableurdegraisseur 1', 'CO2 construction degazage 2', 'ngl_s bassin_dorage 3', 'dco_s fpr 3', 'CO2 exploitation fpr 3', 'tbentrant bassin_dorage 2', 'CO2 construction bassin_cylindrique 3', 'CO2 elec 6', 'CO2 construction dessableurdegraisseur 1']::varchar[],
e real default 0.25,
eh real,
vit real default 60,
h real default 5,
tauenterre real default 0.75,
abatdco real,
abatngl real,
w_dbo5_eau real,
dbo5elim real,
qe real,
dco real,
ntk real,
mes real,
dbo5 real,
vu real,
welec real,
ngl_s real,
dco_s real,
qe_s real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.degazage_bloc_config(
    like ___.degazage_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.degazage_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('degazage', 'bloc', 'Point' 
    
    ) ;

select api.add_new_formula('dco_s fpr 3'::varchar, 'dco_s=dco*(1 - abatdco)'::varchar, 3, ''::text) ;
select api.add_new_formula('ngl_s bassin_dorage 3'::varchar, 'ngl_s=eh*ntk_eh*(1 - abatngl)'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant dessableurdegraisseur 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 construction degazage 2'::varchar, 'co2_c=(febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe/vit)**0.5) + 24*qe) + 24.0*vit*(0.3618*e + (qe/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda + fepelle*cad*tauenterre*(h + e)))/vit'::varchar, 2, ''::text) ;
select api.add_new_formula('ngl_s bassin_dorage 3'::varchar, 'ngl_s=ntk*(1 - abatngl)'::varchar, 3, ''::text) ;
select api.add_new_formula('dco_s fpr 3'::varchar, 'dco_s=eh*dco_eh*(1 - abatdco)'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 exploitation fpr 3'::varchar, 'co2_e=feelec*dbo5elim*w_dbo5_eau'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant bassin_dorage 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 construction bassin_cylindrique 3'::varchar, 'co2_c=(febet*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*h*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda + fepelle*cad*tauenterre*(h + e)))/h'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 construction dessableurdegraisseur 1'::varchar, 'co2_c=(febet*e*rhobet*(24*eh*qe_eh + 3.14159*h*vit*(e + 5.52791*(eh*qe_eh/vit)**0.5)) + 24.0*vit*(0.3618*e + (eh*qe_eh/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda + fepelle*cad*tauenterre*(h + e)))/vit'::varchar, 1, ''::text) ;





alter type ___.bloc_type add value 'compostage' ;
commit ; 
insert into ___.input_output values ('compostage', array['eh', 'tbsortant', 'mes', 'dbo5', 'tbentrant', 'welec']::varchar[], array['tbsortant_s']::varchar[], array['CO2 construction compostage 2', 'CO2 construction compostage 1', 'CH4 exploitation compostage 3', 'CO2 exploitation compostage 3', 'tbentrant dessableurdegraisseur 1', 'CO2 construction compostage 3', 'tbentrant bassin_dorage 2', 'N2O exploitation compostage 3', 'CO2 exploitation compostage 3', 'CO2 elec 6']::varchar[]) ;

create sequence ___.compostage_bloc_name_seq ;     




create table ___.compostage_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('compostage_bloc', abbreviation=>'compostage'),
formula varchar[] default array['co2_c=0.0005*fecompost*nbjour*(dbo5 + mes)', 'co2_c=0.0005*eh*fecompost*nbjour*(dbo5_eh + mes_eh)', 'ch4_e=tbsortant*ch4_compost', 'co2_e=fegazole*tbsortant*gazole_compost', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'co2_c=fecompost*tbentrant', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'n2o_e=tbsortant*n2o_compost', 'co2_e=feelec*tbsortant*welec_compost', 'co2_e=feelec*welec']::varchar[],
formula_name varchar[] default array['CO2 construction compostage 2', 'CO2 construction compostage 1', 'CH4 exploitation compostage 3', 'CO2 exploitation compostage 3', 'tbentrant dessableurdegraisseur 1', 'CO2 construction compostage 3', 'tbentrant bassin_dorage 2', 'N2O exploitation compostage 3', 'CO2 exploitation compostage 3', 'CO2 elec 6']::varchar[],
eh real,
tbsortant real,
mes real,
dbo5 real,
tbentrant real,
welec real,
tbsortant_s real,

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

select api.add_new_formula('CO2 construction compostage 2'::varchar, 'co2_c=0.0005*fecompost*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 construction compostage 1'::varchar, 'co2_c=0.0005*eh*fecompost*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CH4 exploitation compostage 3'::varchar, 'ch4_e=tbsortant*ch4_compost'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 exploitation compostage 3'::varchar, 'co2_e=fegazole*tbsortant*gazole_compost'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant dessableurdegraisseur 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 construction compostage 3'::varchar, 'co2_c=fecompost*tbentrant'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant bassin_dorage 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('N2O exploitation compostage 3'::varchar, 'n2o_e=tbsortant*n2o_compost'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 exploitation compostage 3'::varchar, 'co2_e=feelec*tbsortant*welec_compost'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;





alter type ___.bloc_type add value 'conditionnement_chimique' ;
commit ; 
insert into ___.input_output values ('conditionnement_chimique', array['vboue', 'transp_chaux', 'transp_fecl3', 'transp_catio', 'q_fecl3', 'q_chaux', 'transp_anio', 'q_catio', 'q_anio', 'fecc', 'eh', 'mes', 'dbo5', 'tbentrant', 'welec']::varchar[], array['tbsortant_s']::varchar[], array['CO2 construction conditionnement_chimique 3', 'CO2 exploitation intrant conditionnement_chimique 6', 'CO2 exploitation conditionnement_chimique 3', 'tbentrant dessableurdegraisseur 1', 'CO2 construction conditionnement_chimique 1', 'CO2 construction conditionnement_chimique 2', 'tbentrant bassin_dorage 2', 'CO2 elec 6']::varchar[]) ;

create sequence ___.conditionnement_chimique_bloc_name_seq ;     

create type ___.fecc_type as enum ('Cuve moyenne', 'Grand cuve', 'Petite cuve');

create table ___.fecc_type_table(val ___.fecc_type primary key, FE real, incert real default 0, description text);
insert into ___.fecc_type_table(val) values ('Cuve moyenne') ;
insert into ___.fecc_type_table(val) values ('Grand cuve') ;
insert into ___.fecc_type_table(val) values ('Petite cuve') ;

select template.basic_view('fecc_type_table') ;

create table ___.conditionnement_chimique_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('conditionnement_chimique_bloc', abbreviation=>'conditionnement_chimique'),
formula varchar[] default array['co2_c=fecc*tbentrant', 'co2_e=0.001*q_anio*(1000*feanionique + transp_anio) + 0.001*q_catio*(1000*fecationique + transp_catio) + 0.001*q_chaux*(1000*fechaux + transp_chaux) + 0.001*q_fecl3*(1000*fefecl3 + transp_fecl3)', 'co2_e=feelec*vboue*welec_cc', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'co2_c=0.0005*eh*fecc*nbjour*(dbo5_eh + mes_eh)', 'co2_c=0.0005*fecc*nbjour*(dbo5 + mes)', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec']::varchar[],
formula_name varchar[] default array['CO2 construction conditionnement_chimique 3', 'CO2 exploitation intrant conditionnement_chimique 6', 'CO2 exploitation conditionnement_chimique 3', 'tbentrant dessableurdegraisseur 1', 'CO2 construction conditionnement_chimique 1', 'CO2 construction conditionnement_chimique 2', 'tbentrant bassin_dorage 2', 'CO2 elec 6']::varchar[],
vboue real,
transp_chaux real,
transp_fecl3 real,
transp_catio real,
q_fecl3 real,
q_chaux real,
transp_anio real,
q_catio real,
q_anio real,
fecc ___.fecc_type not null default 'Cuve moyenne' references ___.fecc_type_table(val),
eh real,
mes real,
dbo5 real,
tbentrant real,
welec real,
tbsortant_s real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.conditionnement_chimique_bloc_config(
    like ___.conditionnement_chimique_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.conditionnement_chimique_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('conditionnement_chimique', 'bloc', 'Point' 
    ,additional_columns => '{fecc_type_table.FE as fecc_FE, fecc_type_table.description as fecc_description}'
    ,additional_join => 'left join ___.fecc_type_table on fecc_type_table.val = c.fecc ') ;

select api.add_new_formula('CO2 construction conditionnement_chimique 3'::varchar, 'co2_c=fecc*tbentrant'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 exploitation intrant conditionnement_chimique 6'::varchar, 'co2_e=0.001*q_anio*(1000*feanionique + transp_anio) + 0.001*q_catio*(1000*fecationique + transp_catio) + 0.001*q_chaux*(1000*fechaux + transp_chaux) + 0.001*q_fecl3*(1000*fefecl3 + transp_fecl3)'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 exploitation conditionnement_chimique 3'::varchar, 'co2_e=feelec*vboue*welec_cc'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant dessableurdegraisseur 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 construction conditionnement_chimique 1'::varchar, 'co2_c=0.0005*eh*fecc*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 construction conditionnement_chimique 2'::varchar, 'co2_c=0.0005*fecc*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('tbentrant bassin_dorage 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;





alter type ___.bloc_type add value 'poste_de_refoulement' ;
commit ; 
insert into ___.input_output values ('poste_de_refoulement', array['mpompe', 'welec']::varchar[], array[]::varchar[], array['CO2 construction poste_de_refoulement 5', 'CO2 elec 6']::varchar[]) ;

create sequence ___.poste_de_refoulement_bloc_name_seq ;     




create table ___.poste_de_refoulement_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('poste_de_refoulement_bloc', abbreviation=>'poste_de_refoulement'),
formula varchar[] default array['co2_c=fepoids*mpompe', 'co2_e=feelec*welec']::varchar[],
formula_name varchar[] default array['CO2 construction poste_de_refoulement 5', 'CO2 elec 6']::varchar[],
mpompe real,
welec real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.poste_de_refoulement_bloc_config(
    like ___.poste_de_refoulement_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.poste_de_refoulement_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('poste_de_refoulement', 'bloc', 'Point' 
    
    ) ;

select api.add_new_formula('CO2 construction poste_de_refoulement 5'::varchar, 'co2_c=fepoids*mpompe'::varchar, 5, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;





alter type ___.bloc_type add value 'chaulage' ;
commit ; 
insert into ___.input_output values ('chaulage', array['eh', 'mes', 'dbo5', 'tbentrant', 'q_chaux', 'transp_chaux', 'welec']::varchar[], array['tbsortant_s']::varchar[], array['tbentrant dessableurdegraisseur 1', 'CO2 exploitation q_chaux chaulage 6', 'CO2 construction chaulage 2', 'tbentrant bassin_dorage 2', 'CO2 elec 6', 'CO2 construction chaulage 3', 'CO2 construction chaulage 1']::varchar[]) ;

create sequence ___.chaulage_bloc_name_seq ;     




create table ___.chaulage_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('chaulage_bloc', abbreviation=>'chaulage'),
formula varchar[] default array['tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'co2_e=0.001*q_chaux*(1000*fechaux + transp_chaux)', 'co2_c=((feobj10_ch)*(eh<10000)+(feobj50_ch)*(eh>10000)*(eh<100000)+(feobj100_ch)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec', 'co2_c=((feobj10_ch)*(eh<10000)+(feobj50_ch)*(eh>10000)*(eh<100000)+(feobj100_ch)*(eh>100000))*tbentrant', 'co2_c=((feobj10_ch)*(eh<10000)+(feobj50_ch)*(eh>10000)*(eh<100000)+(feobj100_ch)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)']::varchar[],
formula_name varchar[] default array['tbentrant dessableurdegraisseur 1', 'CO2 exploitation q_chaux chaulage 6', 'CO2 construction chaulage 2', 'tbentrant bassin_dorage 2', 'CO2 elec 6', 'CO2 construction chaulage 3', 'CO2 construction chaulage 1']::varchar[],
eh real,
mes real,
dbo5 real,
tbentrant real,
q_chaux real,
transp_chaux real default 50,
welec real,
tbsortant_s real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.chaulage_bloc_config(
    like ___.chaulage_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.chaulage_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('chaulage', 'bloc', 'Point' 
    
    ) ;

select api.add_new_formula('tbentrant dessableurdegraisseur 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 exploitation q_chaux chaulage 6'::varchar, 'co2_e=0.001*q_chaux*(1000*fechaux + transp_chaux)'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 construction chaulage 2'::varchar, 'co2_c=((feobj10_ch)*(eh<10000)+(feobj50_ch)*(eh>10000)*(eh<100000)+(feobj100_ch)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)'::varchar, 2, ''::text) ;
select api.add_new_formula('tbentrant bassin_dorage 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 construction chaulage 3'::varchar, 'co2_c=((feobj10_ch)*(eh<10000)+(feobj50_ch)*(eh>10000)*(eh<100000)+(feobj100_ch)*(eh>100000))*tbentrant'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 construction chaulage 1'::varchar, 'co2_c=((feobj10_ch)*(eh<10000)+(feobj50_ch)*(eh>10000)*(eh<100000)+(feobj100_ch)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)'::varchar, 1, ''::text) ;





alter type ___.bloc_type add value 'sechage_solaire' ;
commit ; 
insert into ___.input_output values ('sechage_solaire', array['ml']::varchar[], array[]::varchar[], array['CO2 construction sechage_solaire 1']::varchar[]) ;

create sequence ___.sechage_solaire_bloc_name_seq ;     




create table ___.sechage_solaire_bloc(
id integer primary key,
shape ___.geo_type not null default 'LineString',
geom geometry('LINESTRING', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('sechage_solaire_bloc', abbreviation=>'sechage_solaire'),
formula varchar[] default array['co2_c=febranche*ml']::varchar[],
formula_name varchar[] default array['CO2 construction sechage_solaire 1']::varchar[],
ml real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.sechage_solaire_bloc_config(
    like ___.sechage_solaire_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.sechage_solaire_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('sechage_solaire', 'bloc', 'LineString' 
    
    ) ;

select api.add_new_formula('CO2 construction sechage_solaire 1'::varchar, 'co2_c=febranche*ml'::varchar, 1, ''::text) ;





alter type ___.bloc_type add value 'tamis' ;
commit ; 
insert into ___.input_output values ('tamis', array['eh', 'munite_tamis', 'qmax', 'welec', 'compt', 'qe', 'mes', 'dbo5']::varchar[], array['qe_s']::varchar[], array['tbentrant dessableurdegraisseur 1', 'tbentrant bassin_dorage 2', 'CO2 elec 6', 'CO2 exploitation tamis 1', 'CO2 construction tamis 1', 'CO2 construction tamis 2']::varchar[]) ;

create sequence ___.tamis_bloc_name_seq ;     




create table ___.tamis_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('tamis_bloc', abbreviation=>'tamis'),
formula varchar[] default array['tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec', 'co2_e=eh*fedechet*rhodechet*(compt*qdechet_tamis_comp - qdechet_tamis_ncomp*(compt - 1))', 'co2_c=eh*fepoids*munite_tamis*qe_eh/qmax', 'co2_c=fepoids*munite_tamis*qe/qmax']::varchar[],
formula_name varchar[] default array['tbentrant dessableurdegraisseur 1', 'tbentrant bassin_dorage 2', 'CO2 elec 6', 'CO2 exploitation tamis 1', 'CO2 construction tamis 1', 'CO2 construction tamis 2']::varchar[],
eh real,
munite_tamis real default 210,
qmax real default 270,
welec real,
compt integer default 0,
qe real,
mes real,
dbo5 real,
qe_s real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.tamis_bloc_config(
    like ___.tamis_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.tamis_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('tamis', 'bloc', 'Point' 
    
    ) ;

select api.add_new_formula('tbentrant dessableurdegraisseur 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('tbentrant bassin_dorage 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 exploitation tamis 1'::varchar, 'co2_e=eh*fedechet*rhodechet*(compt*qdechet_tamis_comp - qdechet_tamis_ncomp*(compt - 1))'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 construction tamis 1'::varchar, 'co2_c=eh*fepoids*munite_tamis*qe_eh/qmax'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 construction tamis 2'::varchar, 'co2_c=fepoids*munite_tamis*qe/qmax'::varchar, 2, ''::text) ;





alter type ___.bloc_type add value 'degrilleur' ;
commit ; 
insert into ___.input_output values ('degrilleur', array['welec', 'qdechet', 'eh', 'munite_degrilleur', 'qmax', 'qe', 'mes', 'dbo5']::varchar[], array['qe_s']::varchar[], array['CO2 construction degrilleur 1', 'tbentrant dessableurdegraisseur 1', 'CO2 exploitation degrilleur 1', 'tbentrant bassin_dorage 2', 'CO2 elec 6', 'CO2 construction degrilleur 2']::varchar[]) ;

create sequence ___.degrilleur_bloc_name_seq ;     

create type ___.qdechet_type as enum ('Sans compactage', 'Compactage avec piston', 'Compactage avec vis');

create table ___.qdechet_type_table(val ___.qdechet_type primary key, FE real, incert real default 0, description text);
insert into ___.qdechet_type_table(val) values ('Sans compactage') ;
insert into ___.qdechet_type_table(val) values ('Compactage avec piston') ;
insert into ___.qdechet_type_table(val) values ('Compactage avec vis') ;

select template.basic_view('qdechet_type_table') ;

create table ___.degrilleur_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('degrilleur_bloc', abbreviation=>'degrilleur'),
formula varchar[] default array['co2_c=eh*fepoids*munite_degrilleur*qe_eh/qmax', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'co2_e=eh*fedechet*qdechet*rhodechet', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec', 'co2_c=fepoids*munite_degrilleur*qe/qmax']::varchar[],
formula_name varchar[] default array['CO2 construction degrilleur 1', 'tbentrant dessableurdegraisseur 1', 'CO2 exploitation degrilleur 1', 'tbentrant bassin_dorage 2', 'CO2 elec 6', 'CO2 construction degrilleur 2']::varchar[],
welec real,
qdechet ___.qdechet_type not null default 'Sans compactage' references ___.qdechet_type_table(val),
eh real,
munite_degrilleur real default 1500,
qmax real default 6000,
qe real,
mes real,
dbo5 real,
qe_s real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.degrilleur_bloc_config(
    like ___.degrilleur_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.degrilleur_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('degrilleur', 'bloc', 'Point' 
    ,additional_columns => '{qdechet_type_table.FE as qdechet_FE, qdechet_type_table.description as qdechet_description}'
    ,additional_join => 'left join ___.qdechet_type_table on qdechet_type_table.val = c.qdechet ') ;

select api.add_new_formula('CO2 construction degrilleur 1'::varchar, 'co2_c=eh*fepoids*munite_degrilleur*qe_eh/qmax'::varchar, 1, ''::text) ;
select api.add_new_formula('tbentrant dessableurdegraisseur 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 exploitation degrilleur 1'::varchar, 'co2_e=eh*fedechet*qdechet*rhodechet'::varchar, 1, ''::text) ;
select api.add_new_formula('tbentrant bassin_dorage 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 construction degrilleur 2'::varchar, 'co2_c=fepoids*munite_degrilleur*qe/qmax'::varchar, 2, ''::text) ;





alter type ___.bloc_type add value 'digesteur_anaerobie' ;
commit ; 
insert into ___.input_output values ('digesteur_anaerobie', array['tbsortant', 'tau_abattement', 'eh', 'mes', 'dbo5', 'vbiogaz', 'welec']::varchar[], array['tbsortant_s']::varchar[], array['tbsortant_s digesteur_anaerobie 3', 'tbentrant dessableurdegraisseur 1', 'tbentrant bassin_dorage 2', 'CO2 elec 6', 'CO2 construction digesteur_anaerobie 4', 'CO2 construction digesteur_anaerobie 3', 'CH4 exploitation digesteur_anaerobie 3', 'CO2 exploitation digesteur_anaerobie 3']::varchar[]) ;

create sequence ___.digesteur_anaerobie_bloc_name_seq ;     




create table ___.digesteur_anaerobie_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('digesteur_anaerobie_bloc', abbreviation=>'digesteur_anaerobie'),
formula varchar[] default array['tbsortant_s=tbsortant*tau_abattement', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec', 'co2_c=feobj_dan*vbiogaz', 'co2_c=225*feobj_dan*tbsortant', 'ch4_e=tbsortant*tau_fuite*vol_ms', 'co2_e=feelec*tbsortant*welec_dan']::varchar[],
formula_name varchar[] default array['tbsortant_s digesteur_anaerobie 3', 'tbentrant dessableurdegraisseur 1', 'tbentrant bassin_dorage 2', 'CO2 elec 6', 'CO2 construction digesteur_anaerobie 4', 'CO2 construction digesteur_anaerobie 3', 'CH4 exploitation digesteur_anaerobie 3', 'CO2 exploitation digesteur_anaerobie 3']::varchar[],
tbsortant real,
tau_abattement real default 0.4,
eh real,
mes real,
dbo5 real,
vbiogaz real,
welec real,
tbsortant_s real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.digesteur_anaerobie_bloc_config(
    like ___.digesteur_anaerobie_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.digesteur_anaerobie_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('digesteur_anaerobie', 'bloc', 'Point' 
    
    ) ;

select api.add_new_formula('tbsortant_s digesteur_anaerobie 3'::varchar, 'tbsortant_s=tbsortant*tau_abattement'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant dessableurdegraisseur 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('tbentrant bassin_dorage 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 construction digesteur_anaerobie 4'::varchar, 'co2_c=feobj_dan*vbiogaz'::varchar, 4, ''::text) ;
select api.add_new_formula('CO2 construction digesteur_anaerobie 3'::varchar, 'co2_c=225*feobj_dan*tbsortant'::varchar, 3, ''::text) ;
select api.add_new_formula('CH4 exploitation digesteur_anaerobie 3'::varchar, 'ch4_e=tbsortant*tau_fuite*vol_ms'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 exploitation digesteur_anaerobie 3'::varchar, 'co2_e=feelec*tbsortant*welec_dan'::varchar, 3, ''::text) ;





alter type ___.bloc_type add value 'grilles_degouttage' ;
commit ; 
insert into ___.input_output values ('grilles_degouttage', array['q_poly', 'transp_poly', 'tbsortant', 'eh', 'mes', 'dbo5', 'tbentrant', 'welec']::varchar[], array['tbsortant_s']::varchar[], array['CO2 exploitation grilles_degouttage 3', 'tbentrant dessableurdegraisseur 1', 'CO2 exploitation q_poly tables_degouttage 6', 'CO2 construction grilles_degouttage 1', 'tbentrant bassin_dorage 2', 'CO2 elec 6', 'CO2 construction grilles_degouttage 2', 'CO2 construction grilles_degouttage 3']::varchar[]) ;

create sequence ___.grilles_degouttage_bloc_name_seq ;     




create table ___.grilles_degouttage_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('grilles_degouttage_bloc', abbreviation=>'grilles_degouttage'),
formula varchar[] default array['co2_e=feelec*tbsortant*welec_ge', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'co2_e=0.001*q_poly*(1000*fepolymere + transp_poly)', 'co2_c=((feobj10_ge)*(eh<10000)+(feobj50_ge)*(eh>10000)*(eh<100000)+(feobj100_ge)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec', 'co2_c=((feobj10_ge)*(eh<10000)+(feobj50_ge)*(eh>10000)*(eh<100000)+(feobj100_ge)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)', 'co2_c=((feobj10_ge)*(eh<10000)+(feobj50_ge)*(eh>10000)*(eh<100000)+(feobj100_ge)*(eh>100000))*tbentrant']::varchar[],
formula_name varchar[] default array['CO2 exploitation grilles_degouttage 3', 'tbentrant dessableurdegraisseur 1', 'CO2 exploitation q_poly tables_degouttage 6', 'CO2 construction grilles_degouttage 1', 'tbentrant bassin_dorage 2', 'CO2 elec 6', 'CO2 construction grilles_degouttage 2', 'CO2 construction grilles_degouttage 3']::varchar[],
q_poly real default 5,
transp_poly real default 50,
tbsortant real,
eh real,
mes real,
dbo5 real,
tbentrant real,
welec real,
tbsortant_s real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.grilles_degouttage_bloc_config(
    like ___.grilles_degouttage_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.grilles_degouttage_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('grilles_degouttage', 'bloc', 'Point' 
    
    ) ;

select api.add_new_formula('CO2 exploitation grilles_degouttage 3'::varchar, 'co2_e=feelec*tbsortant*welec_ge'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant dessableurdegraisseur 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 exploitation q_poly tables_degouttage 6'::varchar, 'co2_e=0.001*q_poly*(1000*fepolymere + transp_poly)'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 construction grilles_degouttage 1'::varchar, 'co2_c=((feobj10_ge)*(eh<10000)+(feobj50_ge)*(eh>10000)*(eh<100000)+(feobj100_ge)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)'::varchar, 1, ''::text) ;
select api.add_new_formula('tbentrant bassin_dorage 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 construction grilles_degouttage 2'::varchar, 'co2_c=((feobj10_ge)*(eh<10000)+(feobj50_ge)*(eh>10000)*(eh<100000)+(feobj100_ge)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 construction grilles_degouttage 3'::varchar, 'co2_c=((feobj10_ge)*(eh<10000)+(feobj50_ge)*(eh>10000)*(eh<100000)+(feobj100_ge)*(eh>100000))*tbentrant'::varchar, 3, ''::text) ;





alter type ___.bloc_type add value 'lspr' ;
commit ; 
insert into ___.input_output values ('lspr', array['eh']::varchar[], array[]::varchar[], array['CH4 exploitation lspr 1', 'N2O exploitation lspr 1']::varchar[]) ;

create sequence ___.lspr_bloc_name_seq ;     




create table ___.lspr_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('lspr_bloc', abbreviation=>'lspr'),
formula varchar[] default array['ch4_e=eh*fe_lspr_ch4', 'n2o_e=eh*fe_lspr_n2o']::varchar[],
formula_name varchar[] default array['CH4 exploitation lspr 1', 'N2O exploitation lspr 1']::varchar[],
eh real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.lspr_bloc_config(
    like ___.lspr_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.lspr_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('lspr', 'bloc', 'Point' 
    
    ) ;

select api.add_new_formula('CH4 exploitation lspr 1'::varchar, 'ch4_e=eh*fe_lspr_ch4'::varchar, 1, ''::text) ;
select api.add_new_formula('N2O exploitation lspr 1'::varchar, 'n2o_e=eh*fe_lspr_n2o'::varchar, 1, ''::text) ;





alter type ___.bloc_type add value 'digesteur_aerobie' ;
commit ; 
insert into ___.input_output values ('digesteur_aerobie', array['eh', 'tbsortant', 'tau_abattement', 'mes', 'dbo5', 'tbentrant', 'welec']::varchar[], array['tbsortant_s']::varchar[], array['tbsortant_s digesteur_anaerobie 3', 'CO2 construction digesteur_aerobie 2', 'CO2 exploitation digesteur_aerobie 3', 'tbentrant dessableurdegraisseur 1', 'CO2 construction digesteur_aerobie 3', 'tbentrant bassin_dorage 2', 'CO2 elec 6', 'CO2 construction digesteur_aerobie 1']::varchar[]) ;

create sequence ___.digesteur_aerobie_bloc_name_seq ;     




create table ___.digesteur_aerobie_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('digesteur_aerobie_bloc', abbreviation=>'digesteur_aerobie'),
formula varchar[] default array['tbsortant_s=tbsortant*tau_abattement', 'co2_c=((feobj10_da)*(eh<10000)+(feobj50_da)*(eh>10000)*(eh<100000)+(feobj100_da)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)', 'co2_e=feelec*tbsortant*welec_da', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'co2_c=((feobj10_da)*(eh<10000)+(feobj50_da)*(eh>10000)*(eh<100000)+(feobj100_da)*(eh>100000))*tbentrant', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec', 'co2_c=((feobj10_da)*(eh<10000)+(feobj50_da)*(eh>10000)*(eh<100000)+(feobj100_da)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)']::varchar[],
formula_name varchar[] default array['tbsortant_s digesteur_anaerobie 3', 'CO2 construction digesteur_aerobie 2', 'CO2 exploitation digesteur_aerobie 3', 'tbentrant dessableurdegraisseur 1', 'CO2 construction digesteur_aerobie 3', 'tbentrant bassin_dorage 2', 'CO2 elec 6', 'CO2 construction digesteur_aerobie 1']::varchar[],
eh real,
tbsortant real,
tau_abattement real default 35,
mes real,
dbo5 real,
tbentrant real,
welec real,
tbsortant_s real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.digesteur_aerobie_bloc_config(
    like ___.digesteur_aerobie_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.digesteur_aerobie_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('digesteur_aerobie', 'bloc', 'Point' 
    
    ) ;

select api.add_new_formula('tbsortant_s digesteur_anaerobie 3'::varchar, 'tbsortant_s=tbsortant*tau_abattement'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 construction digesteur_aerobie 2'::varchar, 'co2_c=((feobj10_da)*(eh<10000)+(feobj50_da)*(eh>10000)*(eh<100000)+(feobj100_da)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 exploitation digesteur_aerobie 3'::varchar, 'co2_e=feelec*tbsortant*welec_da'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant dessableurdegraisseur 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 construction digesteur_aerobie 3'::varchar, 'co2_c=((feobj10_da)*(eh<10000)+(feobj50_da)*(eh>10000)*(eh<100000)+(feobj100_da)*(eh>100000))*tbentrant'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant bassin_dorage 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 construction digesteur_aerobie 1'::varchar, 'co2_c=((feobj10_da)*(eh<10000)+(feobj50_da)*(eh>10000)*(eh<100000)+(feobj100_da)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)'::varchar, 1, ''::text) ;





alter type ___.bloc_type add value 'pompe' ;
commit ; 
insert into ___.input_output values ('pompe', array['mpompe', 'welec']::varchar[], array[]::varchar[], array['CO2 construction poste_de_refoulement 5', 'CO2 elec 6']::varchar[]) ;

create sequence ___.pompe_bloc_name_seq ;     




create table ___.pompe_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('pompe_bloc', abbreviation=>'pompe'),
formula varchar[] default array['co2_c=fepoids*mpompe', 'co2_e=feelec*welec']::varchar[],
formula_name varchar[] default array['CO2 construction poste_de_refoulement 5', 'CO2 elec 6']::varchar[],
mpompe real,
welec real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.pompe_bloc_config(
    like ___.pompe_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.pompe_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('pompe', 'bloc', 'Point' 
    
    ) ;

select api.add_new_formula('CO2 construction poste_de_refoulement 5'::varchar, 'co2_c=fepoids*mpompe'::varchar, 5, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;





alter type ___.bloc_type add value 'stockage_boue' ;
commit ; 
insert into ___.input_output values ('stockage_boue', array['aere', 'grand', 'dbo', 'welec', 'eh', 'festock', 'mes', 'dbo5', 'tbentrant']::varchar[], array['tbsortant_s']::varchar[], array['CO2 construction stockage_boue 3', 'CO2 exploitation stockage_boue 3', 'CO2 construction stockage_boue 2', 'tbentrant dessableurdegraisseur 1', 'CO2 exploitation stockage_boue 1', 'CH4 exploitation stockage_boue 2', 'tbentrant bassin_dorage 2', 'CO2 elec 6', 'CO2 construction stockage_boue 1', 'CO2 exploitation stockage_boue 2']::varchar[]) ;

create sequence ___.stockage_boue_bloc_name_seq ;     

create type ___.festock_type as enum ('Silo de 5m3', 'Silo de 250m3', 'Silo de 500m3');

create table ___.festock_type_table(val ___.festock_type primary key, FE real, incert real default 0, description text);
insert into ___.festock_type_table(val) values ('Silo de 5m3') ;
insert into ___.festock_type_table(val) values ('Silo de 250m3') ;
insert into ___.festock_type_table(val) values ('Silo de 500m3') ;

select template.basic_view('festock_type_table') ;

create table ___.stockage_boue_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('stockage_boue_bloc', abbreviation=>'stockage_boue'),
formula varchar[] default array['co2_c=festock*tbentrant', 'co2_e=fesilo_aere*tbentrant*aere', 'co2_c=0.0005*festock*nbjour*(dbo5 + mes)', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'co2_e=0.0005*eh*fesilo_aere*nbjour*aere*(dbo5_eh + mes_eh)', 'ch4_e=-dbo*(aere - 1)*(fesilo_grand*grand - fesilo_petit*(grand - 1))', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec', 'co2_c=0.0005*eh*festock*nbjour*(dbo5_eh + mes_eh)', 'co2_e=0.0005*fesilo_aere*nbjour*aere*(dbo5 + mes)']::varchar[],
formula_name varchar[] default array['CO2 construction stockage_boue 3', 'CO2 exploitation stockage_boue 3', 'CO2 construction stockage_boue 2', 'tbentrant dessableurdegraisseur 1', 'CO2 exploitation stockage_boue 1', 'CH4 exploitation stockage_boue 2', 'tbentrant bassin_dorage 2', 'CO2 elec 6', 'CO2 construction stockage_boue 1', 'CO2 exploitation stockage_boue 2']::varchar[],
aere integer default 0,
grand integer default 0,
dbo real,
welec real,
eh real,
festock ___.festock_type not null default 'Silo de 5m3' references ___.festock_type_table(val),
mes real,
dbo5 real,
tbentrant real,
tbsortant_s real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.stockage_boue_bloc_config(
    like ___.stockage_boue_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.stockage_boue_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('stockage_boue', 'bloc', 'Point' 
    ,additional_columns => '{festock_type_table.FE as festock_FE, festock_type_table.description as festock_description}'
    ,additional_join => 'left join ___.festock_type_table on festock_type_table.val = c.festock ') ;

select api.add_new_formula('CO2 construction stockage_boue 3'::varchar, 'co2_c=festock*tbentrant'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 exploitation stockage_boue 3'::varchar, 'co2_e=fesilo_aere*tbentrant*aere'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 construction stockage_boue 2'::varchar, 'co2_c=0.0005*festock*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('tbentrant dessableurdegraisseur 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 exploitation stockage_boue 1'::varchar, 'co2_e=0.0005*eh*fesilo_aere*nbjour*aere*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CH4 exploitation stockage_boue 2'::varchar, 'ch4_e=-dbo*(aere - 1)*(fesilo_grand*grand - fesilo_petit*(grand - 1))'::varchar, 2, ''::text) ;
select api.add_new_formula('tbentrant bassin_dorage 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 construction stockage_boue 1'::varchar, 'co2_c=0.0005*eh*festock*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 exploitation stockage_boue 2'::varchar, 'co2_e=0.0005*fesilo_aere*nbjour*aere*(dbo5 + mes)'::varchar, 2, ''::text) ;





alter type ___.bloc_type add value 'centrifugeuse_pour_epais' ;
commit ; 
insert into ___.input_output values ('centrifugeuse_pour_epais', array['q_poly', 'transp_poly', 'eh', 'mes', 'dbo5', 'tbentrant', 'welec']::varchar[], array['tbsortant_s']::varchar[], array['tbentrant dessableurdegraisseur 1', 'CO2 construction centrifugeuse_pour_epais 2', 'CO2 exploitation q_poly tables_degouttage 6', 'tbentrant bassin_dorage 2', 'CO2 construction centrifugeuse_pour_epais 3', 'CO2 elec 6', 'CO2 construction centrifugeuse_pour_epais 1']::varchar[]) ;

create sequence ___.centrifugeuse_pour_epais_bloc_name_seq ;     




create table ___.centrifugeuse_pour_epais_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('centrifugeuse_pour_epais_bloc', abbreviation=>'centrifugeuse_pour_epais'),
formula varchar[] default array['tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'co2_c=((feobj10_ce)*(eh<10000)+(feobj50_ce)*(eh>10000)*(eh<100000)+(feobj100_ce)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)', 'co2_e=0.001*q_poly*(1000*fepolymere + transp_poly)', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_c=((feobj10_ce)*(eh<10000)+(feobj50_ce)*(eh>10000)*(eh<100000)+(feobj100_ce)*(eh>100000))*tbentrant', 'co2_e=feelec*welec', 'co2_c=((feobj10_ce)*(eh<10000)+(feobj50_ce)*(eh>10000)*(eh<100000)+(feobj100_ce)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)']::varchar[],
formula_name varchar[] default array['tbentrant dessableurdegraisseur 1', 'CO2 construction centrifugeuse_pour_epais 2', 'CO2 exploitation q_poly tables_degouttage 6', 'tbentrant bassin_dorage 2', 'CO2 construction centrifugeuse_pour_epais 3', 'CO2 elec 6', 'CO2 construction centrifugeuse_pour_epais 1']::varchar[],
q_poly real default 0,
transp_poly real default 50,
eh real,
mes real,
dbo5 real,
tbentrant real,
welec real,
tbsortant_s real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.centrifugeuse_pour_epais_bloc_config(
    like ___.centrifugeuse_pour_epais_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.centrifugeuse_pour_epais_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('centrifugeuse_pour_epais', 'bloc', 'Point' 
    
    ) ;

select api.add_new_formula('tbentrant dessableurdegraisseur 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 construction centrifugeuse_pour_epais 2'::varchar, 'co2_c=((feobj10_ce)*(eh<10000)+(feobj50_ce)*(eh>10000)*(eh<100000)+(feobj100_ce)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 exploitation q_poly tables_degouttage 6'::varchar, 'co2_e=0.001*q_poly*(1000*fepolymere + transp_poly)'::varchar, 6, ''::text) ;
select api.add_new_formula('tbentrant bassin_dorage 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 construction centrifugeuse_pour_epais 3'::varchar, 'co2_c=((feobj10_ce)*(eh<10000)+(feobj50_ce)*(eh>10000)*(eh<100000)+(feobj100_ce)*(eh>100000))*tbentrant'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 construction centrifugeuse_pour_epais 1'::varchar, 'co2_c=((feobj10_ce)*(eh<10000)+(feobj50_ce)*(eh>10000)*(eh<100000)+(feobj100_ce)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)'::varchar, 1, ''::text) ;





alter type ___.bloc_type add value 'bassin_biologique' ;
commit ; 
insert into ___.input_output values ('bassin_biologique', array['charge_bio', 'e', 'eh', 'h', 'tauenterre', 'abatdco', 'abatngl', 'w_dbo5_eau', 'dbo5elim', 'dbo5', 'dco', 'ntk', 'mes', 'vu', 'welec']::varchar[], array['ngl_s', 'dco_s', 'qe_s']::varchar[], array['dco_s fpr 3', 'ngl_s bassin_dorage 3', 'tbentrant dessableurdegraisseur 1', 'CO2 construction bassin_biologique 2', 'ngl_s bassin_dorage 3', 'dco_s fpr 3', 'CO2 exploitation fpr 3', 'tbentrant bassin_dorage 2', 'CO2 construction bassin_cylindrique 3', 'CO2 elec 6', 'CO2 construction bassin_biologique 2']::varchar[]) ;

create sequence ___.bassin_biologique_bloc_name_seq ;     

create type ___.charge_bio_type as enum ('Charge faible', 'Charge élevée', 'Charge moyenne');

create table ___.charge_bio_type_table(val ___.charge_bio_type primary key, FE real, incert real default 0, description text);
insert into ___.charge_bio_type_table(val) values ('Charge faible') ;
insert into ___.charge_bio_type_table(val) values ('Charge élevée') ;
insert into ___.charge_bio_type_table(val) values ('Charge moyenne') ;

select template.basic_view('charge_bio_type_table') ;

create table ___.bassin_biologique_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('bassin_biologique_bloc', abbreviation=>'bassin_biologique'),
formula varchar[] default array['dco_s=dco*(1 - abatdco)', 'ngl_s=eh*ntk_eh*(1 - abatngl)', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'co2_c=(febet*e*rhobet*(24*dbo5 + 3.14159*h**2*charge_bio*(e + 5.52791*(dbo5/(h*charge_bio))**0.5)) + 24.0*h*charge_bio*(0.3618*e + (dbo5/(h*charge_bio))**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda + fepelle*cad*tauenterre*(h + e)))/(h*charge_bio)', 'ngl_s=ntk*(1 - abatngl)', 'dco_s=eh*dco_eh*(1 - abatdco)', 'co2_e=feelec*dbo5elim*w_dbo5_eau', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_c=(febet*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*h*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda + fepelle*cad*tauenterre*(h + e)))/h', 'co2_e=feelec*welec', 'co2_c=(febet*e*rhobet*(24*eh*dbo5_eh + 3.14159*h**2*charge_bio*(e + 5.52791*(eh*dbo5_eh/(h*charge_bio))**0.5)) + 24.0*h*charge_bio*(0.3618*e + (eh*dbo5_eh/(h*charge_bio))**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda + fepelle*cad*tauenterre*(h + e)))/(h*charge_bio)']::varchar[],
formula_name varchar[] default array['dco_s fpr 3', 'ngl_s bassin_dorage 3', 'tbentrant dessableurdegraisseur 1', 'CO2 construction bassin_biologique 2', 'ngl_s bassin_dorage 3', 'dco_s fpr 3', 'CO2 exploitation fpr 3', 'tbentrant bassin_dorage 2', 'CO2 construction bassin_cylindrique 3', 'CO2 elec 6', 'CO2 construction bassin_biologique 2']::varchar[],
charge_bio ___.charge_bio_type not null default 'Charge faible' references ___.charge_bio_type_table(val),
e real default 0.25,
eh real,
h real default 4,
tauenterre real default 0.75,
abatdco real,
abatngl real,
w_dbo5_eau real,
dbo5elim real,
dbo5 real,
dco real,
ntk real,
mes real,
vu real,
welec real,
ngl_s real,
dco_s real,
qe_s real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.bassin_biologique_bloc_config(
    like ___.bassin_biologique_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.bassin_biologique_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('bassin_biologique', 'bloc', 'Point' 
    ,additional_columns => '{charge_bio_type_table.FE as charge_bio_FE, charge_bio_type_table.description as charge_bio_description}'
    ,additional_join => 'left join ___.charge_bio_type_table on charge_bio_type_table.val = c.charge_bio ') ;

select api.add_new_formula('dco_s fpr 3'::varchar, 'dco_s=dco*(1 - abatdco)'::varchar, 3, ''::text) ;
select api.add_new_formula('ngl_s bassin_dorage 3'::varchar, 'ngl_s=eh*ntk_eh*(1 - abatngl)'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant dessableurdegraisseur 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 construction bassin_biologique 2'::varchar, 'co2_c=(febet*e*rhobet*(24*dbo5 + 3.14159*h**2*charge_bio*(e + 5.52791*(dbo5/(h*charge_bio))**0.5)) + 24.0*h*charge_bio*(0.3618*e + (dbo5/(h*charge_bio))**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda + fepelle*cad*tauenterre*(h + e)))/(h*charge_bio)'::varchar, 2, ''::text) ;
select api.add_new_formula('ngl_s bassin_dorage 3'::varchar, 'ngl_s=ntk*(1 - abatngl)'::varchar, 3, ''::text) ;
select api.add_new_formula('dco_s fpr 3'::varchar, 'dco_s=eh*dco_eh*(1 - abatdco)'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 exploitation fpr 3'::varchar, 'co2_e=feelec*dbo5elim*w_dbo5_eau'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant bassin_dorage 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 construction bassin_cylindrique 3'::varchar, 'co2_c=(febet*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*h*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda + fepelle*cad*tauenterre*(h + e)))/h'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 construction bassin_biologique 2'::varchar, 'co2_c=(febet*e*rhobet*(24*eh*dbo5_eh + 3.14159*h**2*charge_bio*(e + 5.52791*(eh*dbo5_eh/(h*charge_bio))**0.5)) + 24.0*h*charge_bio*(0.3618*e + (eh*dbo5_eh/(h*charge_bio))**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda + fepelle*cad*tauenterre*(h + e)))/(h*charge_bio)'::varchar, 2, ''::text) ;





alter type ___.bloc_type add value 'station_de_pompage' ;
commit ; 
insert into ___.input_output values ('station_de_pompage', array[]::varchar[], array[]::varchar[], array[]::varchar[]) ;

create sequence ___.station_de_pompage_bloc_name_seq ;     




create table ___.station_de_pompage_bloc(
id integer primary key,
shape ___.geo_type not null default 'Polygon',
geom geometry('POLYGON', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('station_de_pompage_bloc', abbreviation=>'station_de_pompage'),
formula varchar[] default array[]::varchar[],
formula_name varchar[] default array[]::varchar[],

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.station_de_pompage_bloc_config(
    like ___.station_de_pompage_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.station_de_pompage_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('station_de_pompage', 'bloc', 'Polygon' 
    
    ) ;






alter type ___.bloc_type add value 'voirie' ;
commit ; 
insert into ___.input_output values ('voirie', array['s', 'ebit']::varchar[], array[]::varchar[], array['CO2 construction voirie 2']::varchar[]) ;

create sequence ___.voirie_bloc_name_seq ;     




create table ___.voirie_bloc(
id integer primary key,
shape ___.geo_type not null default 'LineString',
geom geometry('LINESTRING', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('voirie_bloc', abbreviation=>'voirie'),
formula varchar[] default array['co2_c=fevoirie*s*ebit*rhobit']::varchar[],
formula_name varchar[] default array['CO2 construction voirie 2']::varchar[],
s real,
ebit real default 0.08,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.voirie_bloc_config(
    like ___.voirie_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.voirie_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('voirie', 'bloc', 'LineString' 
    
    ) ;

select api.add_new_formula('CO2 construction voirie 2'::varchar, 'co2_c=fevoirie*s*ebit*rhobit'::varchar, 2, ''::text) ;





alter type ___.bloc_type add value 'cloture' ;
commit ; 
insert into ___.input_output values ('cloture', array['ml']::varchar[], array[]::varchar[], array['CO2 construction cloture 2']::varchar[]) ;

create sequence ___.cloture_bloc_name_seq ;     




create table ___.cloture_bloc(
id integer primary key,
shape ___.geo_type not null default 'LineString',
geom geometry('LINESTRING', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('cloture_bloc', abbreviation=>'cloture'),
formula varchar[] default array['co2_c=feclot*ml']::varchar[],
formula_name varchar[] default array['CO2 construction cloture 2']::varchar[],
ml real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.cloture_bloc_config(
    like ___.cloture_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.cloture_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('cloture', 'bloc', 'LineString' 
    
    ) ;

select api.add_new_formula('CO2 construction cloture 2'::varchar, 'co2_c=feclot*ml'::varchar, 2, ''::text) ;





alter type ___.bloc_type add value 'bassin_dorage' ;
commit ; 
insert into ___.input_output values ('bassin_dorage', array['e', 'tsejour', 'eh', 'h', 'tauenterre', 'abatdco', 'abatngl', 'w_dbo5_eau', 'dbo5elim', 'qe', 'dco', 'ntk', 'mes', 'dbo5', 'vu', 'welec']::varchar[], array['ngl_s', 'dco_s', 'qe_s']::varchar[], array['dco_s fpr 3', 'CO2 construction bassin_dorage 2', 'ngl_s bassin_dorage 3', 'tbentrant dessableurdegraisseur 1', 'ngl_s bassin_dorage 3', 'dco_s fpr 3', 'CO2 exploitation fpr 3', 'tbentrant bassin_dorage 2', 'CO2 construction bassin_cylindrique 3', 'CO2 elec 6', 'CO2 construction bassin_dorage 1']::varchar[]) ;

create sequence ___.bassin_dorage_bloc_name_seq ;     




create table ___.bassin_dorage_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('bassin_dorage_bloc', abbreviation=>'bassin_dorage'),
formula varchar[] default array['dco_s=dco*(1 - abatdco)', 'co2_c=(febet*e*rhobet*(3.14159*h**2*(e + 5.52791*(qe*tsejour/h)**0.5) + 24*qe*tsejour) + 24.0*h*(0.3618*e + (qe*tsejour/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda + fepelle*cad*tauenterre*(h + e)))/h', 'ngl_s=eh*ntk_eh*(1 - abatngl)', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'ngl_s=ntk*(1 - abatngl)', 'dco_s=eh*dco_eh*(1 - abatdco)', 'co2_e=feelec*dbo5elim*w_dbo5_eau', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_c=(febet*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*h*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda + fepelle*cad*tauenterre*(h + e)))/h', 'co2_e=feelec*welec', 'co2_c=(febet*e*rhobet*(24*eh*qe_eh*tsejour + 3.14159*h**2*(e + 5.52791*(eh*qe_eh*tsejour/h)**0.5)) + 24.0*h*(0.3618*e + (eh*qe_eh*tsejour/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda + fepelle*cad*tauenterre*(h + e)))/h']::varchar[],
formula_name varchar[] default array['dco_s fpr 3', 'CO2 construction bassin_dorage 2', 'ngl_s bassin_dorage 3', 'tbentrant dessableurdegraisseur 1', 'ngl_s bassin_dorage 3', 'dco_s fpr 3', 'CO2 exploitation fpr 3', 'tbentrant bassin_dorage 2', 'CO2 construction bassin_cylindrique 3', 'CO2 elec 6', 'CO2 construction bassin_dorage 1']::varchar[],
e real default 0.25,
tsejour real default 1,
eh real,
h real default 4,
tauenterre real default 0.75,
abatdco real,
abatngl real,
w_dbo5_eau real,
dbo5elim real,
qe real,
dco real,
ntk real,
mes real,
dbo5 real,
vu real,
welec real,
ngl_s real,
dco_s real,
qe_s real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.bassin_dorage_bloc_config(
    like ___.bassin_dorage_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.bassin_dorage_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('bassin_dorage', 'bloc', 'Point' 
    
    ) ;

select api.add_new_formula('dco_s fpr 3'::varchar, 'dco_s=dco*(1 - abatdco)'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 construction bassin_dorage 2'::varchar, 'co2_c=(febet*e*rhobet*(3.14159*h**2*(e + 5.52791*(qe*tsejour/h)**0.5) + 24*qe*tsejour) + 24.0*h*(0.3618*e + (qe*tsejour/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda + fepelle*cad*tauenterre*(h + e)))/h'::varchar, 2, ''::text) ;
select api.add_new_formula('ngl_s bassin_dorage 3'::varchar, 'ngl_s=eh*ntk_eh*(1 - abatngl)'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant dessableurdegraisseur 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('ngl_s bassin_dorage 3'::varchar, 'ngl_s=ntk*(1 - abatngl)'::varchar, 3, ''::text) ;
select api.add_new_formula('dco_s fpr 3'::varchar, 'dco_s=eh*dco_eh*(1 - abatdco)'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 exploitation fpr 3'::varchar, 'co2_e=feelec*dbo5elim*w_dbo5_eau'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant bassin_dorage 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 construction bassin_cylindrique 3'::varchar, 'co2_c=(febet*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*h*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda + fepelle*cad*tauenterre*(h + e)))/h'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 construction bassin_dorage 1'::varchar, 'co2_c=(febet*e*rhobet*(24*eh*qe_eh*tsejour + 3.14159*h**2*(e + 5.52791*(eh*qe_eh*tsejour/h)**0.5)) + 24.0*h*(0.3618*e + (eh*qe_eh*tsejour/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda + fepelle*cad*tauenterre*(h + e)))/h'::varchar, 1, ''::text) ;





alter type ___.bloc_type add value 'filtre_a_bande' ;
commit ; 
insert into ___.input_output values ('filtre_a_bande', array['q_poly', 'transp_poly', 'eh', 'mes', 'dbo5', 'tbentrant', 'welec']::varchar[], array['tbsortant_s']::varchar[], array['CO2 construction filtre_a_bande 2', 'CO2 construction filtre_a_bande 1', 'tbentrant dessableurdegraisseur 1', 'CO2 exploitation q_poly tables_degouttage 6', 'tbentrant bassin_dorage 2', 'CO2 elec 6', 'CO2 construction filtre_a_bande 3']::varchar[]) ;

create sequence ___.filtre_a_bande_bloc_name_seq ;     




create table ___.filtre_a_bande_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('filtre_a_bande_bloc', abbreviation=>'filtre_a_bande'),
formula varchar[] default array['co2_c=((feobj10_fb)*(eh<10000)+(feobj50_fb)*(eh>10000)*(eh<100000)+(feobj100_fb)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)', 'co2_c=((feobj10_fb)*(eh<10000)+(feobj50_fb)*(eh>10000)*(eh<100000)+(feobj100_fb)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'co2_e=0.001*q_poly*(1000*fepolymere + transp_poly)', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec', 'co2_c=((feobj10_fb)*(eh<10000)+(feobj50_fb)*(eh>10000)*(eh<100000)+(feobj100_fb)*(eh>100000))*tbentrant']::varchar[],
formula_name varchar[] default array['CO2 construction filtre_a_bande 2', 'CO2 construction filtre_a_bande 1', 'tbentrant dessableurdegraisseur 1', 'CO2 exploitation q_poly tables_degouttage 6', 'tbentrant bassin_dorage 2', 'CO2 elec 6', 'CO2 construction filtre_a_bande 3']::varchar[],
q_poly real default 5,
transp_poly real default 50,
eh real,
mes real,
dbo5 real,
tbentrant real,
welec real,
tbsortant_s real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.filtre_a_bande_bloc_config(
    like ___.filtre_a_bande_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.filtre_a_bande_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('filtre_a_bande', 'bloc', 'Point' 
    
    ) ;

select api.add_new_formula('CO2 construction filtre_a_bande 2'::varchar, 'co2_c=((feobj10_fb)*(eh<10000)+(feobj50_fb)*(eh>10000)*(eh<100000)+(feobj100_fb)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 construction filtre_a_bande 1'::varchar, 'co2_c=((feobj10_fb)*(eh<10000)+(feobj50_fb)*(eh>10000)*(eh<100000)+(feobj100_fb)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)'::varchar, 1, ''::text) ;
select api.add_new_formula('tbentrant dessableurdegraisseur 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 exploitation q_poly tables_degouttage 6'::varchar, 'co2_e=0.001*q_poly*(1000*fepolymere + transp_poly)'::varchar, 6, ''::text) ;
select api.add_new_formula('tbentrant bassin_dorage 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 construction filtre_a_bande 3'::varchar, 'co2_c=((feobj10_fb)*(eh<10000)+(feobj50_fb)*(eh>10000)*(eh<100000)+(feobj100_fb)*(eh>100000))*tbentrant'::varchar, 3, ''::text) ;





alter type ___.bloc_type add value 'fpr' ;
commit ; 
insert into ___.input_output values ('fpr', array['s_geom_eh', 'h', 'eh', 'abatdco', 'abatngl', 'w_dbo5_eau', 'dbo5elim', 'dco', 'ntk', 'mes', 'dbo5', 'welec']::varchar[], array['ngl_s', 'dco_s', 'qe_s']::varchar[], array['dco_s fpr 3', 'ngl_s bassin_dorage 3', 'tbentrant dessableurdegraisseur 1', 'ngl_s bassin_dorage 3', 'CO2 construction fpr 1', 'dco_s fpr 3', 'CO2 exploitation fpr 3', 'tbentrant bassin_dorage 2', 'CO2 elec 6']::varchar[]) ;

create sequence ___.fpr_bloc_name_seq ;     




create table ___.fpr_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('fpr_bloc', abbreviation=>'fpr'),
formula varchar[] default array['dco_s=dco*(1 - abatdco)', 'ngl_s=eh*ntk_eh*(1 - abatngl)', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'ngl_s=ntk*(1 - abatngl)', 'co2_c=eh*s_geom_eh*(feevac*h*rhoterre + fegeom + fepelle*h*cad)', 'dco_s=eh*dco_eh*(1 - abatdco)', 'co2_e=feelec*dbo5elim*w_dbo5_eau', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec']::varchar[],
formula_name varchar[] default array['dco_s fpr 3', 'ngl_s bassin_dorage 3', 'tbentrant dessableurdegraisseur 1', 'ngl_s bassin_dorage 3', 'CO2 construction fpr 1', 'dco_s fpr 3', 'CO2 exploitation fpr 3', 'tbentrant bassin_dorage 2', 'CO2 elec 6']::varchar[],
s_geom_eh real default 1.5,
h real default 2,
eh real,
abatdco real,
abatngl real,
w_dbo5_eau real,
dbo5elim real,
dco real,
ntk real,
mes real,
dbo5 real,
welec real,
ngl_s real,
dco_s real,
qe_s real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.fpr_bloc_config(
    like ___.fpr_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.fpr_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('fpr', 'bloc', 'Point' 
    
    ) ;

select api.add_new_formula('dco_s fpr 3'::varchar, 'dco_s=dco*(1 - abatdco)'::varchar, 3, ''::text) ;
select api.add_new_formula('ngl_s bassin_dorage 3'::varchar, 'ngl_s=eh*ntk_eh*(1 - abatngl)'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant dessableurdegraisseur 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('ngl_s bassin_dorage 3'::varchar, 'ngl_s=ntk*(1 - abatngl)'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 construction fpr 1'::varchar, 'co2_c=eh*s_geom_eh*(feevac*h*rhoterre + fegeom + fepelle*h*cad)'::varchar, 1, ''::text) ;
select api.add_new_formula('dco_s fpr 3'::varchar, 'dco_s=eh*dco_eh*(1 - abatdco)'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 exploitation fpr 3'::varchar, 'co2_e=feelec*dbo5elim*w_dbo5_eau'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant bassin_dorage 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;



update ___.fen2o_oxi_type_table set fe = 0.0034, incert = 0.45, description = 'kgN2O/kgNGL rejeté [2] peu oxygéné (par défault)' where val = 'Peu oxigéné' ;
update ___.fecc_type_table set fe = 0.0009, incert = 0.0, description = '' where val = 'Cuve moyenne' ;
update ___.charge_bio_type_table set fe = 2.25, incert = 0.35, description = 'kgDBO5/m3/j charge élevé [11]' where val = 'Charge élevée' ;
update ___.festock_type_table set fe = 0.0052, incert = 0.0, description = 'silo de 500m3 [10]' where val = 'Silo de 500m3' ;
update ___.fech4_mil_type_table set fe = 0.009, incert = 0.3, description = 'kgCH4/kgDCO rejeté [2] autres' where val = 'Autres' ;
update ___.qdechet_type_table set fe = 0.99, incert = 0.4, description = 'compactage piston [1]' where val = 'Compactage avec piston' ;
update ___.charge_bio_type_table set fe = 1.1, incert = 0.35, description = 'kgDBO5/m3/j charge moyenne [11]' where val = 'Charge moyenne' ;
update ___.charge_bio_type_table set fe = 0.5, incert = 0.35, description = 'kgDBO5/m3/j charge faible [11]' where val = 'Charge faible' ;
update ___.fecc_type_table set fe = 0.0007, incert = 0.0, description = '' where val = 'Grand cuve' ;
update ___.qdechet_type_table set fe = 2.33, incert = 0.7, description = 'L/EH/an sans compactage [1]' where val = 'Sans compactage' ;
update ___.festock_type_table set fe = 0.0067, incert = 0.0, description = 'silo de 250m3 [10]' where val = 'Silo de 250m3' ;
update ___.qdechet_type_table set fe = 1.12, incert = 0.5, description = 'compactage avec vis [1]' where val = 'Compactage avec vis' ;
update ___.fecc_type_table set fe = 0.0023, incert = 0.0, description = 'kgCO2eq/tMS cuve pour conditionnement chimique [10]' where val = 'Petite cuve' ;
update ___.festock_type_table set fe = 0.0352, incert = 0.0, description = 'kgCO2eq/tMS silo de 5m3 [10]' where val = 'Silo de 5m3' ;
update ___.fen2o_oxi_type_table set fe = 0.0007, incert = 0.45, description = 'kgN2O/kgNGL rejeté [2] Bien oxygéné' where val = 'Bien oxigéné' ;
update ___.fech4_mil_type_table set fe = 0.048, incert = 0.3, description = 'kgCH4/kgDCO rejeté [2] réservoirs, lac, estuaires' where val = 'Réservoirs, lac, estuaires' ;


insert into ___.global_values(name, val, incert, comment) values ('rhometha', 0.657, 0.0, 'kg/m3') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj50_fb', 0.0257, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('fedechet_stock', 0.692, 0.5, 'kgco2eq/kg, [2] quand est ce qu''on stock ?') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj10_ge', 0.0021, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('fecurage_prev', 42.0, 0.5, 'kgCO2eq/km[2]') ;
insert into ___.global_values(name, val, incert, comment) values ('q_poly_te', 5.0, 0.0, 'kg [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj10_da', 0.0228, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('fe_lspr_n2o', 0.033, 0.0, 'kgN2O/EH/an [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('ch4_eau', 0.0002, 0.3, 'kgCH4/kgDCO [2] Emission de méthane dans la file eau') ;
insert into ___.global_values(name, val, incert, comment) values ('fecompost', 2.892, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('n2o_compost', 0.65, 0.8, 'kgN2O/t déchets [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj100_st', 13.6647, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('welec_compost', 160.0, 0.8, 'kWh/tMS [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('rhoco2', 1.87, 0.0, 'kg/m3') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj100_te', 0.0018, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('qmax_degrilleur', 6000.0, 0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('cad', 125.0, 0.0, 'm3/h') ;
insert into ___.global_values(name, val, incert, comment) values ('fefecl3', 0.33, 0.3, 'kgCO2eq/kg[2]') ;
insert into ___.global_values(name, val, incert, comment) values ('feclot', 168.0, 0.0, 'kgCO2eq/ml [6]') ;
insert into ___.global_values(name, val, incert, comment) values ('rhobit', 2.35, 0.0, 't/m3 [plusieurs sources qui se recoupent]') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj100_fp', 0.4943, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('welec_te', 174.0, 0.0, '[10] kWh/tMS') ;
insert into ___.global_values(name, val, incert, comment) values ('lgraisses_nc', 0.00955, 3.0, 'kL/EH/an milliers de litres de graisses non concentrées par eh par an [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('rhoterre', 1.5, 0.0, 't/m3 ') ;
insert into ___.global_values(name, val, incert, comment) values ('welec_fb', 5.0, 0.0, 'kWh/m3 [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('ferep_branche_t', 400.0, 0.95, 'kgCO2eq/ml [2]') ;
insert into ___.global_values(name, val, incert, comment) values ('fesables', 0.013, 0.26, 'kgco2eq/kg [2]') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj100_ss', 3.3911, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('fevoirie', 53.0, 0.2, 'kgCO2eq/t bitume [2]') ;
insert into ___.global_values(name, val, incert, comment) values ('qdechet_tamis_comp', 4.0, 0.5, 'L/EH/an sans compactage') ;
insert into ___.global_values(name, val, incert, comment) values ('fepelle', 61.0, 0.0, 'kgco2eq/h [7]') ;
insert into ___.global_values(name, val, incert, comment) values ('vol_ms', 225.0, 0.45, '[12] m3CH4/tMS') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj50_ch', 0.1611, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj50_da', 0.0126, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj50_fp', 0.2103, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj10_cd', 0.1296, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('n2o_biofiltre', 0.0165, 0.15, 'kgN2O/kgNTK [2] Emission d''azote dans les biofiltres nitrifiants ') ;
insert into ___.global_values(name, val, incert, comment) values ('dgraisses', 0.9, 0.1, 'densité des graisses [1]') ;
insert into ___.global_values(name, val, incert, comment) values ('fesilo_petit', 0.12, 0.0, 'kgCH4/kgDBO silo de moins de 2 mètre [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('dco_eh', 0.135, 0.0, 'kg/j') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj100_da', 0.0102, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj10_te', 0.0044, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('welec_da', 500.0, 0.0, '[10] kWh/tMS') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj50_st', 26.4856, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('mes_eh', 0.09, 0.0, 'kg/j') ;
insert into ___.global_values(name, val, incert, comment) values ('sables_nlavé', 0.00163, 0.0, 't/EH/an tonnage de sables récupérer sans lavage [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('welec_fp', 30.0, 0.3, 'kWh/m3 [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('tau_fuite', 0.1245, 0.3, '[2]') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj50_ct', 0.1572, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('welec_direct', 160.0, 0.2, 'kWh/m3 [10] pour une direct') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj10_flot', 0.0117, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('welec_st_nopell', 105.0, 0.05, 'kWh/tee [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj50_te', 0.0022, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('fepoids', 5.5, 0.5, 'kgCO2eq/kg [2] facteur d''émission machines') ;
insert into ___.global_values(name, val, incert, comment) values ('fecurage_cur', 53.0, 0.5, 'kgCO2eq/km[2]') ;
insert into ___.global_values(name, val, incert, comment) values ('sables_lavé', 0.00131, 0.0, 't/EH/an tonnage de sables récupérer si lavage [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj50_ge', 0.0011, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('dbo5_eh', 0.06, 0.0, 'kg/j') ;
insert into ___.global_values(name, val, incert, comment) values ('ch4_compost', 2.9, 1.5, 'kgCH4/t déchets [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj100_fb', 0.0553, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('qdechet_tamis_ncomp', 8.0, 0.5, 'L/EH/an avec compactage (moyenne arbitraire incertitudes dégrillages)') ;
insert into ___.global_values(name, val, incert, comment) values ('gazole_compost', 10.0, 0.0, 'L/tMS [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('fe_lspr_co2', 0.0056, 0.0, 'kgCO2/EH/an [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj100_es', 0.0096, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('welec_ge', 115.0, 0.0, '[10] kWh/tMS') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj50_es', 0.0109, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('welec_ct', 65.0, 0.5, 'kWh/m3 [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj100_cd', 0.1347, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('fedechet', 0.045, 0.5, 'kgco2eq/kg facteur d''émissions des déchets émis par les dégrilleurs et tamis [2]') ;
insert into ___.global_values(name, val, incert, comment) values ('feevac', 5.4, 0.0, 'kgco2eq/t de terre évacuée [6][7]') ;
insert into ___.global_values(name, val, incert, comment) values ('felam', 3.6, 0.0, 'kgCO2eq/kg [8]') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj50_ss', 3.9359, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj10_ce', 0.1296, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj100_ch', 0.1219, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj10_fp', 0.2674, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('ferep_branche', 7.0, 0.3, 'kgCO2eq/ml [2]') ;
insert into ___.global_values(name, val, incert, comment) values ('fe_lspr_ch4', 0.034, 0.0, 'kgCH4/EH/an  [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('fefonda', 80.0, 0.0, 'kgCO2eq/m2 [7]') ;
insert into ___.global_values(name, val, incert, comment) values ('febet', 155.0, 0.2, 'kgco2eq/t [2]') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj10_es', 0.0245, 0.0, '[10] kgCO2eq/tMS même chose pour tout ce qui suit si non précisé') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj50_cd', 0.0735, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('welec_st_pell', 62.5, 0.05, 'kWh/tee [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('fegazole', 3.1, 0.0, 'kgCO2eq/L [8]') ;
insert into ___.global_values(name, val, incert, comment) values ('rhodechet', 0.96, 0.65, '[1]') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj100_ce', 0.1363, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('fecurage_desob', 12.0, 0.5, 'kgCO2eq/km[2]') ;
insert into ___.global_values(name, val, incert, comment) values ('fesilo_aere', 5.0, 0.0, 'kWh/tMS silo aéré [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('fecationique', 1.395, 0.3, '[2] résine cathionique') ;
insert into ___.global_values(name, val, incert, comment) values ('lgraisses_c', 0.00159, 3.0, 'kL/EH/an milliers de litres de graisses concentrées par eh par an [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('fesilo_grand', 0.4, 0.0, 'kgCH4/kgDBO silo de plus de 2 mètre [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj100_ct', 0.0817, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj50_flot', 0.0062, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('nbjour', 365.0, 0.0, 'Nombre de jour d''activité d''une step par an') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj10_ch', 0.5875, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('w_dbo5_eau', 5.0, 0.3, 'kWh/kDBO5 élim affiné les valeurs en allant chercher dans les données de base [3]') ;
insert into ___.global_values(name, val, incert, comment) values ('rholam', 1040.0, 0.0, 'kg/m3 [3]') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj10_ss', 7.6227, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('welec_dan', 125.0, 0.6, '[10] kWh/tMS') ;
insert into ___.global_values(name, val, incert, comment) values ('welec_es', 10.0, 0.0, '[10] kWh/tMS') ;
insert into ___.global_values(name, val, incert, comment) values ('febranche', 420.0, 0.95, 'kgCO2eq/ml [2]') ;
insert into ___.global_values(name, val, incert, comment) values ('n2o_boue_act', 0.0006, 0.5, '') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj100_flot', 0.0048, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('p_eh', 0.004, 0.0, 'kg/j') ;
insert into ___.global_values(name, val, incert, comment) values ('feelec', 0.052, 0.2, 'kgCO2eq/kWh électrique [9]') ;
insert into ___.global_values(name, val, incert, comment) values ('fegeom', 0.45, 0.0, 'kgCO2/m2 [7]') ;
insert into ___.global_values(name, val, incert, comment) values ('ntk_eh', 0.015, 0.0, 'kg/j') ;
insert into ___.global_values(name, val, incert, comment) values ('fechaux', 1.032, 0.3, 'kgCO2eq/kg [2] chaux vive') ;
insert into ___.global_values(name, val, incert, comment) values ('csables', 0.00104, 0.5, 't/EH/an tonnage de déchets sableux [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj100_ge', 0.0012, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj10_fb', 0.0679, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('feanionique', 3.927, 0.3, '[2] résine anionique') ;
insert into ___.global_values(name, val, incert, comment) values ('qmax_tamis', 270.0, 0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('welec_cd', 60.0, 0.5, 'kWh/m3 [10] pour une non direct ') ;
insert into ___.global_values(name, val, incert, comment) values ('munite_degrilleur', 925.0, 0.6, 'kg fixé par rapport au NG de FB procédés') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj50_ce', 0.0759, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('qe_eh', 0.12, 0.0, 'm3/j') ;
insert into ___.global_values(name, val, incert, comment) values ('welec_cc', 225.0, 0.33, 'kgCO2eq/m3 boue [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('munite_tamis', 610.0, 0.25, 'tamis à tambour') ;
insert into ___.global_values(name, val, incert, comment) values ('rhobet', 2.4, 0.0, 't/m3 ') ;
insert into ___.global_values(name, val, incert, comment) values ('fepolymere', 0.805, 0.3, 'kgCO2eq/kg  [2]') ;
insert into ___.global_values(name, val, incert, comment) values ('welec_flot', 33.0, 0.0, '[10] kWh/tMS') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj_dan', 0.0062, 0.0, 'digestion anaérobie kgCO2eq/m3 biogaz produit [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('pth', 1000.0, 0.1, 'kW/tee [10]') ;
