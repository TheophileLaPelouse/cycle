

alter type ___.bloc_type add value 'degrilleur' ;
commit ; 
insert into ___.input_output values ('degrilleur', array['d_vie', 'qdechet', 'eh', 'welec', 'qmax', 'munite_degrilleur', 'qe', 'mes', 'dbo5']::varchar[], array['qe_s']::varchar[], array['CO2 construction degrilleur 2', 'CO2 construction degrilleur 1', 'tbentrant sechage_thermique 1', 'CO2 exploitation degrilleur 1', 'tbentrant flottateur 2', 'CO2 elec 6']::varchar[]) ;

create sequence ___.degrilleur_bloc_name_seq ;     

create type ___.qdechet_type as enum ('Compactage avec piston', 'Compactage avec vis', 'Sans compactage');

create table ___.qdechet_type_table(val ___.qdechet_type primary key, FE real, incert real default 0, description text);
insert into ___.qdechet_type_table(val) values ('Compactage avec piston') ;
insert into ___.qdechet_type_table(val) values ('Compactage avec vis') ;
insert into ___.qdechet_type_table(val) values ('Sans compactage') ;

select template.basic_view('qdechet_type_table') ;

create table ___.degrilleur_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('degrilleur_bloc', abbreviation=>'degrilleur'),
formula varchar[] default array['co2_c=fepoids*munite_degrilleur*qe/qmax', 'co2_c=eh*fepoids*munite_degrilleur*qe_eh/qmax', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'co2_e=eh*fedechet*qdechet*rhodechet', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec']::varchar[],
formula_name varchar[] default array['CO2 construction degrilleur 2', 'CO2 construction degrilleur 1', 'tbentrant sechage_thermique 1', 'CO2 exploitation degrilleur 1', 'tbentrant flottateur 2', 'CO2 elec 6']::varchar[],
d_vie real default 15::real,
qdechet ___.qdechet_type not null default 'Compactage avec piston' references ___.qdechet_type_table(val),
eh real,
welec real,
qmax real default 6000::real,
munite_degrilleur real default 1500::real,
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

select api.add_new_formula('CO2 construction degrilleur 2'::varchar, 'co2_c=fepoids*munite_degrilleur*qe/qmax'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 construction degrilleur 1'::varchar, 'co2_c=eh*fepoids*munite_degrilleur*qe_eh/qmax'::varchar, 1, ''::text) ;
select api.add_new_formula('tbentrant sechage_thermique 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 exploitation degrilleur 1'::varchar, 'co2_e=eh*fedechet*qdechet*rhodechet'::varchar, 1, ''::text) ;
select api.add_new_formula('tbentrant flottateur 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;





alter type ___.bloc_type add value 'centrifugeuse_pour_deshy' ;
commit ; 
insert into ___.input_output values ('centrifugeuse_pour_deshy', array['d_vie', 'direct', 'tbsortant', 'transp_poly', 'q_poly', 'eh', 'mes', 'dbo5', 'tbentrant', 'welec']::varchar[], array['tbsortant_s']::varchar[], array['CO2 exploitation centrifugeuse_pour_deshy 3', 'CO2 construction centrifugeuse_pour_deshy 2', 'tbentrant sechage_thermique 1', 'CO2 construction centrifugeuse_pour_deshy 3', 'tbentrant flottateur 2', 'CO2 elec 6', 'CO2 exploitation q_poly tables_degouttage 6', 'CO2 construction centrifugeuse_pour_deshy 1']::varchar[]) ;

create sequence ___.centrifugeuse_pour_deshy_bloc_name_seq ;     




create table ___.centrifugeuse_pour_deshy_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('centrifugeuse_pour_deshy_bloc', abbreviation=>'centrifugeuse_pour_deshy'),
formula varchar[] default array['co2_e=feelec*tbsortant*(-welec_cd*direct + welec_cd + welec_direct*direct)', 'co2_c=((feobj10_cd)*(eh<10000)+(feobj50_cd)*(eh>10000)*(eh<100000)+(feobj100_cd)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)*d_vie', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'co2_c=((feobj10_cd)*(eh<10000)+(feobj50_cd)*(eh>10000)*(eh<100000)+(feobj100_cd)*(eh>100000))*tbentrant*d_vie', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec', 'co2_e=0.001*q_poly*(1000*fepolymere + fetransp*transp_poly)', 'co2_c=((feobj10_cd)*(eh<10000)+(feobj50_cd)*(eh>10000)*(eh<100000)+(feobj100_cd)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)*d_vie']::varchar[],
formula_name varchar[] default array['CO2 exploitation centrifugeuse_pour_deshy 3', 'CO2 construction centrifugeuse_pour_deshy 2', 'tbentrant sechage_thermique 1', 'CO2 construction centrifugeuse_pour_deshy 3', 'tbentrant flottateur 2', 'CO2 elec 6', 'CO2 exploitation q_poly tables_degouttage 6', 'CO2 construction centrifugeuse_pour_deshy 1']::varchar[],
d_vie real default 15::real,
direct boolean default 0::boolean,
tbsortant real,
transp_poly real default 50::real,
q_poly real,
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

select api.add_new_formula('CO2 exploitation centrifugeuse_pour_deshy 3'::varchar, 'co2_e=feelec*tbsortant*(-welec_cd*direct + welec_cd + welec_direct*direct)'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 construction centrifugeuse_pour_deshy 2'::varchar, 'co2_c=((feobj10_cd)*(eh<10000)+(feobj50_cd)*(eh>10000)*(eh<100000)+(feobj100_cd)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)*d_vie'::varchar, 2, ''::text) ;
select api.add_new_formula('tbentrant sechage_thermique 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 construction centrifugeuse_pour_deshy 3'::varchar, 'co2_c=((feobj10_cd)*(eh<10000)+(feobj50_cd)*(eh>10000)*(eh<100000)+(feobj100_cd)*(eh>100000))*tbentrant*d_vie'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant flottateur 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 exploitation q_poly tables_degouttage 6'::varchar, 'co2_e=0.001*q_poly*(1000*fepolymere + fetransp*transp_poly)'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 construction centrifugeuse_pour_deshy 1'::varchar, 'co2_c=((feobj10_cd)*(eh<10000)+(feobj50_cd)*(eh>10000)*(eh<100000)+(feobj100_cd)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)*d_vie'::varchar, 1, ''::text) ;





alter type ___.bloc_type add value 'lagunage' ;
commit ; 
insert into ___.input_output values ('lagunage', array['prod_e', 'd_vie', 's_geom_eh3', 'h3', 'eh', 'h1', 'h2', 's_geom_eh1', 's_geom_eh2', 'abatdco', 'abatngl', 'transp_rei', 'transp_naclo3', 'transp_phosphorique', 'q_h2o2', 'transp_citrique', 'q_oxyl', 'transp_javel', 'q_sulf_sod', 'q_sulf', 'q_anti_mousse', 'q_cl2', 'q_uree', 'q_chaux', 'q_catio', 'q_nahso3', 'transp_soude', 'q_hcl', 'q_kmno4', 'transp_anti_mousse', 'q_lait', 'transp_oxyl', 'transp_ca_regen', 'transp_uree', 'transp_sulf_alu', 'transp_nitrique', 'transp_ca_neuf', 'q_sable_t', 'q_soude_c', 'q_anio', 'q_soude', 'transp_nahso3', 'q_nitrique', 'q_naclo3', 'transp_kmno4', 'transp_h2o2', 'q_antiscalant', 'transp_chaux', 'q_phosphorique', 'transp_sulf_sod', 'q_javel', 'transp_mhetanol', 'transp_caco3', 'transp_antiscalant', 'transp_hcl', 'transp_ca_poudre', 'transp_ethanol', 'q_citrique', 'transp_soude_c', 'transp_coagl', 'q_ca_regen', 'q_poly', 'q_mhetanol', 'q_caco3', 'transp_lait', 'q_ca_poudre', 'q_rei', 'transp_catio', 'q_ca_neuf', 'transp_fecl3', 'transp_poly', 'transp_anio', 'q_co2l', 'transp_sable_t', 'q_coagl', 'transp_cl2', 'transp_co2l', 'transp_sulf', 'q_sulf_alu', 'q_ethanol', 'q_fecl3', 'dbo5elim', 'w_dbo5_eau', 'dco', 'ntk', 'mes', 'dbo5', 's_geom1', 's_geom3', 's_geom2', 'welec']::varchar[], array['ngl_s', 'dco_s', 'qe_s']::varchar[], array['ngl_s decanteur_lamellaire 3', 'CO2 construction lagunage 1', 'CO2 exploitation fpr 3', 'dco_s filiere_eau 3', 'dco_s filiere_eau 3', 'CO2 construction lagunage 3', 'ngl_s decanteur_lamellaire 3', 'tbentrant sechage_thermique 1', 'tbentrant flottateur 2', 'CO2 elec 6', 'CO2 exploitation intrant clarificateur 6']::varchar[]) ;

create sequence ___.lagunage_bloc_name_seq ;     

create type ___.prod_e_type as enum ('Acide sulfurique', 'Oxygène liquide', 'Antiscalants', 'CO2 liquide', 'Lait de chaux', 'Éthanol', 'Peroxyde d’hydrogène', 'Méthanol', 'Eau de javel', 'Poudre de calcium', 'Résine échangeuse d’ions', 'Permanganate de potassium', 'Calcium neuf', 'Sable de filtration', 'Carbonate de calcium', 'Coagulants liquide', 'Acide nitrique', 'Résine cationique', 'Chaux', 'Sulfate d’aluminium', 'Antimousse', 'Sulfate de sodium', 'Chlorate de sodium', 'Floculant', 'Régénérant de calcium', 'Soude', 'Acide chlorhydrique', 'Chlore', 'Bisulfite de sodium', 'Urée', 'Acide phosphorique', 'Cristaux de soude', 'Chlorure ferrique', 'Acide citrique', 'Résine anionique');

create table ___.prod_e_type_table(val ___.prod_e_type primary key, FE real, incert real default 0, description text);
insert into ___.prod_e_type_table(val) values ('Acide sulfurique') ;
insert into ___.prod_e_type_table(val) values ('Oxygène liquide') ;
insert into ___.prod_e_type_table(val) values ('Antiscalants') ;
insert into ___.prod_e_type_table(val) values ('CO2 liquide') ;
insert into ___.prod_e_type_table(val) values ('Lait de chaux') ;
insert into ___.prod_e_type_table(val) values ('Éthanol') ;
insert into ___.prod_e_type_table(val) values ('Peroxyde d’hydrogène') ;
insert into ___.prod_e_type_table(val) values ('Méthanol') ;
insert into ___.prod_e_type_table(val) values ('Eau de javel') ;
insert into ___.prod_e_type_table(val) values ('Poudre de calcium') ;
insert into ___.prod_e_type_table(val) values ('Résine échangeuse d’ions') ;
insert into ___.prod_e_type_table(val) values ('Permanganate de potassium') ;
insert into ___.prod_e_type_table(val) values ('Calcium neuf') ;
insert into ___.prod_e_type_table(val) values ('Sable de filtration') ;
insert into ___.prod_e_type_table(val) values ('Carbonate de calcium') ;
insert into ___.prod_e_type_table(val) values ('Coagulants liquide') ;
insert into ___.prod_e_type_table(val) values ('Acide nitrique') ;
insert into ___.prod_e_type_table(val) values ('Résine cationique') ;
insert into ___.prod_e_type_table(val) values ('Chaux') ;
insert into ___.prod_e_type_table(val) values ('Sulfate d’aluminium') ;
insert into ___.prod_e_type_table(val) values ('Antimousse') ;
insert into ___.prod_e_type_table(val) values ('Sulfate de sodium') ;
insert into ___.prod_e_type_table(val) values ('Chlorate de sodium') ;
insert into ___.prod_e_type_table(val) values ('Floculant') ;
insert into ___.prod_e_type_table(val) values ('Régénérant de calcium') ;
insert into ___.prod_e_type_table(val) values ('Soude') ;
insert into ___.prod_e_type_table(val) values ('Acide chlorhydrique') ;
insert into ___.prod_e_type_table(val) values ('Chlore') ;
insert into ___.prod_e_type_table(val) values ('Bisulfite de sodium') ;
insert into ___.prod_e_type_table(val) values ('Urée') ;
insert into ___.prod_e_type_table(val) values ('Acide phosphorique') ;
insert into ___.prod_e_type_table(val) values ('Cristaux de soude') ;
insert into ___.prod_e_type_table(val) values ('Chlorure ferrique') ;
insert into ___.prod_e_type_table(val) values ('Acide citrique') ;
insert into ___.prod_e_type_table(val) values ('Résine anionique') ;

select template.basic_view('prod_e_type_table') ;

create table ___.lagunage_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('lagunage_bloc', abbreviation=>'lagunage'),
formula varchar[] default array['ngl_s=eh*ntk_eh*(1 - abatngl)', 'co2_c=eh*(feevac*h1*s_geom_eh1*rhoterre + feevac*h2*s_geom_eh2*rhoterre + feevac*h3*s_geom_eh3*rhoterre + fepelle*h1*s_geom_eh1*cad + fepelle*h2*s_geom_eh2*cad + fepelle*h3*s_geom_eh3*cad + fegeom*s_geom_eh1 + fegeom*s_geom_eh2 + fegeom*s_geom_eh3)', 'co2_e=feelec*dbo5elim*w_dbo5_eau', 'dco_s=dco*(1 - abatdco)', 'dco_s=eh*dco_eh*(1 - abatdco)', 'co2_c=feevac*h1*s_geom1*rhoterre + feevac*h2*s_geom2*rhoterre + feevac*h3*s_geom3*rhoterre + fepelle*h1*s_geom1*cad + fepelle*h2*s_geom2*cad + fepelle*h3*s_geom3*cad + fegeom*s_geom1 + fegeom*s_geom2 + fegeom*s_geom3', 'ngl_s=ntk*(1 - abatngl)', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec', 'co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_co2l*(fetransp*transp_co2l + 1000*fe_co2l) + 0.001*q_coagl*(fetransp*transp_coagl + 1000*fe_coagl) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_fecl3*(fetransp*transp_fecl3 + 1000*fe_fecl3) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_javel*(fetransp*transp_javel + 1000*fe_javel) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_lait*(fetransp*transp_lait + 1000*fe_lait) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)']::varchar[],
formula_name varchar[] default array['ngl_s decanteur_lamellaire 3', 'CO2 construction lagunage 1', 'CO2 exploitation fpr 3', 'dco_s filiere_eau 3', 'dco_s filiere_eau 3', 'CO2 construction lagunage 3', 'ngl_s decanteur_lamellaire 3', 'tbentrant sechage_thermique 1', 'tbentrant flottateur 2', 'CO2 elec 6', 'CO2 exploitation intrant clarificateur 6']::varchar[],
prod_e ___.prod_e_type not null default 'Acide sulfurique' references ___.prod_e_type_table(val),
d_vie real default 50::real,
s_geom_eh3 real default 4.5::real,
h3 real default 1.2::real,
eh real,
h1 real default 1.8::real,
h2 real default 1.4::real,
s_geom_eh1 real default 9::real,
s_geom_eh2 real default 4.5::real,
abatdco real,
abatngl real,
transp_rei real default 50::real,
transp_naclo3 real default 50::real,
transp_phosphorique real default 50::real,
q_h2o2 real,
transp_citrique real default 50::real,
q_oxyl real,
transp_javel real default 50::real,
q_sulf_sod real,
q_sulf real,
q_anti_mousse real,
q_cl2 real,
q_uree real,
q_chaux real,
q_catio real,
q_nahso3 real,
transp_soude real default 50::real,
q_hcl real,
q_kmno4 real,
transp_anti_mousse real default 50::real,
q_lait real,
transp_oxyl real default 50::real,
transp_ca_regen real default 50::real,
transp_uree real default 50::real,
transp_sulf_alu real default 50::real,
transp_nitrique real default 50::real,
transp_ca_neuf real default 50::real,
q_sable_t real,
q_soude_c real,
q_anio real,
q_soude real,
transp_nahso3 real default 50::real,
q_nitrique real,
q_naclo3 real,
transp_kmno4 real default 50::real,
transp_h2o2 real default 50::real,
q_antiscalant real,
transp_chaux real default 50::real,
q_phosphorique real,
transp_sulf_sod real default 50::real,
q_javel real,
transp_mhetanol real default 50::real,
transp_caco3 real default 50::real,
transp_antiscalant real default 50::real,
transp_hcl real default 50::real,
transp_ca_poudre real default 50::real,
transp_ethanol real default 50::real,
q_citrique real,
transp_soude_c real default 50::real,
transp_coagl real default 50::real,
q_ca_regen real,
q_poly real,
q_mhetanol real,
q_caco3 real,
transp_lait real default 50::real,
q_ca_poudre real,
q_rei real,
transp_catio real default 50::real,
q_ca_neuf real,
transp_fecl3 real default 50::real,
transp_poly real default 50::real,
transp_anio real default 50::real,
q_co2l real,
transp_sable_t real default 50::real,
q_coagl real,
transp_cl2 real default 50::real,
transp_co2l real default 50::real,
transp_sulf real default 50::real,
q_sulf_alu real,
q_ethanol real,
q_fecl3 real,
dbo5elim real,
w_dbo5_eau real,
dco real,
ntk real,
mes real,
dbo5 real,
s_geom1 real,
s_geom3 real,
s_geom2 real,
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
    ,additional_columns => '{prod_e_type_table.FE as prod_e_FE, prod_e_type_table.description as prod_e_description}'
    ,additional_join => 'left join ___.prod_e_type_table on prod_e_type_table.val = c.prod_e ') ;

select api.add_new_formula('ngl_s decanteur_lamellaire 3'::varchar, 'ngl_s=eh*ntk_eh*(1 - abatngl)'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 construction lagunage 1'::varchar, 'co2_c=eh*(feevac*h1*s_geom_eh1*rhoterre + feevac*h2*s_geom_eh2*rhoterre + feevac*h3*s_geom_eh3*rhoterre + fepelle*h1*s_geom_eh1*cad + fepelle*h2*s_geom_eh2*cad + fepelle*h3*s_geom_eh3*cad + fegeom*s_geom_eh1 + fegeom*s_geom_eh2 + fegeom*s_geom_eh3)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 exploitation fpr 3'::varchar, 'co2_e=feelec*dbo5elim*w_dbo5_eau'::varchar, 3, ''::text) ;
select api.add_new_formula('dco_s filiere_eau 3'::varchar, 'dco_s=dco*(1 - abatdco)'::varchar, 3, ''::text) ;
select api.add_new_formula('dco_s filiere_eau 3'::varchar, 'dco_s=eh*dco_eh*(1 - abatdco)'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 construction lagunage 3'::varchar, 'co2_c=feevac*h1*s_geom1*rhoterre + feevac*h2*s_geom2*rhoterre + feevac*h3*s_geom3*rhoterre + fepelle*h1*s_geom1*cad + fepelle*h2*s_geom2*cad + fepelle*h3*s_geom3*cad + fegeom*s_geom1 + fegeom*s_geom2 + fegeom*s_geom3'::varchar, 3, ''::text) ;
select api.add_new_formula('ngl_s decanteur_lamellaire 3'::varchar, 'ngl_s=ntk*(1 - abatngl)'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant sechage_thermique 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('tbentrant flottateur 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 exploitation intrant clarificateur 6'::varchar, 'co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_co2l*(fetransp*transp_co2l + 1000*fe_co2l) + 0.001*q_coagl*(fetransp*transp_coagl + 1000*fe_coagl) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_fecl3*(fetransp*transp_fecl3 + 1000*fe_fecl3) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_javel*(fetransp*transp_javel + 1000*fe_javel) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_lait*(fetransp*transp_lait + 1000*fe_lait) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)'::varchar, 6, ''::text) ;





alter type ___.bloc_type add value 'conditionnement_chimique' ;
commit ; 
insert into ___.input_output values ('conditionnement_chimique', array['d_vie', 'q_chaux', 'q_catio', 'transp_catio', 'transp_fecl3', 'q_anio', 'transp_chaux', 'transp_anio', 'q_fecl3', 'vboue', 'eh', 'mes', 'dbo5', 'tbentrant', 'welec']::varchar[], array['tbsortant_s']::varchar[], array['CO2 construction conditionnement_chimique 1', 'CO2 exploitation conditionnement_chimique 3', 'tbentrant sechage_thermique 1', 'CO2 construction conditionnement_chimique 2', 'CO2 exploitation intrant conditionnement_chimique 6', 'CO2 construction conditionnement_chimique 3', 'tbentrant flottateur 2', 'CO2 elec 6']::varchar[]) ;

create sequence ___.conditionnement_chimique_bloc_name_seq ;     




create table ___.conditionnement_chimique_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('conditionnement_chimique_bloc', abbreviation=>'conditionnement_chimique'),
formula varchar[] default array['co2_c=((feobj10_cc)*(eh<10000)+(feobj50_cc)*(eh>10000)*(eh<100000)+(feobj100_cc)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)*d_vie', 'co2_e=feelec*vboue*welec_cc', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'co2_c=((feobj10_cc)*(eh<10000)+(feobj50_cc)*(eh>10000)*(eh<100000)+(feobj100_cc)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)*d_vie', 'co2_e=0.001*q_anio*(1000*feanionique + fetransp*transp_anio) + 0.001*q_catio*(1000*fecationique + fetransp*transp_catio) + 0.001*q_chaux*(1000*fechaux + fetransp*transp_chaux) + 0.001*q_fecl3*(1000*fefecl3 + fetransp*transp_fecl3)', 'co2_c=((feobj10_cc)*(eh<10000)+(feobj50_cc)*(eh>10000)*(eh<100000)+(feobj100_cc)*(eh>100000))*tbentrant*d_vie', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec']::varchar[],
formula_name varchar[] default array['CO2 construction conditionnement_chimique 1', 'CO2 exploitation conditionnement_chimique 3', 'tbentrant sechage_thermique 1', 'CO2 construction conditionnement_chimique 2', 'CO2 exploitation intrant conditionnement_chimique 6', 'CO2 construction conditionnement_chimique 3', 'tbentrant flottateur 2', 'CO2 elec 6']::varchar[],
d_vie real default 15::real,
q_chaux real,
q_catio real,
transp_catio real,
transp_fecl3 real,
q_anio real,
transp_chaux real,
transp_anio real,
q_fecl3 real,
vboue real,
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
    
    ) ;

select api.add_new_formula('CO2 construction conditionnement_chimique 1'::varchar, 'co2_c=((feobj10_cc)*(eh<10000)+(feobj50_cc)*(eh>10000)*(eh<100000)+(feobj100_cc)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)*d_vie'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 exploitation conditionnement_chimique 3'::varchar, 'co2_e=feelec*vboue*welec_cc'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant sechage_thermique 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 construction conditionnement_chimique 2'::varchar, 'co2_c=((feobj10_cc)*(eh<10000)+(feobj50_cc)*(eh>10000)*(eh<100000)+(feobj100_cc)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)*d_vie'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 exploitation intrant conditionnement_chimique 6'::varchar, 'co2_e=0.001*q_anio*(1000*feanionique + fetransp*transp_anio) + 0.001*q_catio*(1000*fecationique + fetransp*transp_catio) + 0.001*q_chaux*(1000*fechaux + fetransp*transp_chaux) + 0.001*q_fecl3*(1000*fefecl3 + fetransp*transp_fecl3)'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 construction conditionnement_chimique 3'::varchar, 'co2_c=((feobj10_cc)*(eh<10000)+(feobj50_cc)*(eh>10000)*(eh<100000)+(feobj100_cc)*(eh>100000))*tbentrant*d_vie'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant flottateur 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;





alter type ___.bloc_type add value 'compostage' ;
commit ; 
insert into ___.input_output values ('compostage', array['d_vie', 'eh', 'tbsortant', 'mes', 'dbo5', 'tbentrant', 'welec']::varchar[], array['tbsortant_s']::varchar[], array['CO2 construction compostage 1', 'CO2 construction compostage 3', 'CO2 exploitation compostage 3', 'CO2 exploitation compostage 3', 'CH4 exploitation compostage 3', 'tbentrant sechage_thermique 1', 'CO2 construction compostage 2', 'CO2 elec 6', 'tbentrant flottateur 2', 'N2O exploitation compostage 3']::varchar[]) ;

create sequence ___.compostage_bloc_name_seq ;     




create table ___.compostage_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('compostage_bloc', abbreviation=>'compostage'),
formula varchar[] default array['co2_c=0.0005*eh*fecompost*nbjour*(dbo5_eh + mes_eh)', 'co2_c=fecompost*tbentrant', 'co2_e=fegazole*tbsortant*gazole_compost', 'co2_e=feelec*tbsortant*welec_compost', 'ch4_e=tbsortant*ch4_compost', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'co2_c=0.0005*fecompost*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'n2o_e=tbsortant*n2o_compost']::varchar[],
formula_name varchar[] default array['CO2 construction compostage 1', 'CO2 construction compostage 3', 'CO2 exploitation compostage 3', 'CO2 exploitation compostage 3', 'CH4 exploitation compostage 3', 'tbentrant sechage_thermique 1', 'CO2 construction compostage 2', 'CO2 elec 6', 'tbentrant flottateur 2', 'N2O exploitation compostage 3']::varchar[],
d_vie real default 25::real,
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

select api.add_new_formula('CO2 construction compostage 1'::varchar, 'co2_c=0.0005*eh*fecompost*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 construction compostage 3'::varchar, 'co2_c=fecompost*tbentrant'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 exploitation compostage 3'::varchar, 'co2_e=fegazole*tbsortant*gazole_compost'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 exploitation compostage 3'::varchar, 'co2_e=feelec*tbsortant*welec_compost'::varchar, 3, ''::text) ;
select api.add_new_formula('CH4 exploitation compostage 3'::varchar, 'ch4_e=tbsortant*ch4_compost'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant sechage_thermique 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 construction compostage 2'::varchar, 'co2_c=0.0005*fecompost*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('tbentrant flottateur 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('N2O exploitation compostage 3'::varchar, 'n2o_e=tbsortant*n2o_compost'::varchar, 3, ''::text) ;





alter type ___.bloc_type add value 'voirie' ;
commit ; 
insert into ___.input_output values ('voirie', array['d_vie', 's', 'ebit']::varchar[], array[]::varchar[], array['CO2 construction voirie 2']::varchar[]) ;

create sequence ___.voirie_bloc_name_seq ;     




create table ___.voirie_bloc(
id integer primary key,
shape ___.geo_type not null default 'LineString',
geom geometry('LINESTRING', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('voirie_bloc', abbreviation=>'voirie'),
formula varchar[] default array['co2_c=fevoirie*s*ebit*rhobit']::varchar[],
formula_name varchar[] default array['CO2 construction voirie 2']::varchar[],
d_vie real default 20::real,
s real,
ebit real default 0.08::real,

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





alter type ___.bloc_type add value 'epaississement_statique' ;
commit ; 
insert into ___.input_output values ('epaississement_statique', array['d_vie', 'eh', 'tbsortant', 'mes', 'dbo5', 'tbentrant', 'welec']::varchar[], array['tbsortant_s']::varchar[], array['CO2 construction epaississement_statique 1', 'CO2 construction epaississement_statique 2', 'CO2 exploitation epaississement_statique 3', 'tbentrant sechage_thermique 1', 'tbentrant flottateur 2', 'CO2 elec 6', 'CO2 construction epaississement_statique 3']::varchar[]) ;

create sequence ___.epaississement_statique_bloc_name_seq ;     




create table ___.epaississement_statique_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('epaississement_statique_bloc', abbreviation=>'epaississement_statique'),
formula varchar[] default array['co2_c=((feobj10_es)*(eh<10000)+(feobj50_es)*(eh>10000)*(eh<100000)+(feobj100_es)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)*d_vie', 'co2_c=((feobj10_es)*(eh<10000)+(feobj50_es)*(eh>10000)*(eh<100000)+(feobj100_es)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)*d_vie', 'co2_e=feelec*tbsortant*welec_es', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec', 'co2_c=((feobj10_es)*(eh<10000)+(feobj50_es)*(eh>10000)*(eh<100000)+(feobj100_es)*(eh>100000))*tbentrant*d_vie']::varchar[],
formula_name varchar[] default array['CO2 construction epaississement_statique 1', 'CO2 construction epaississement_statique 2', 'CO2 exploitation epaississement_statique 3', 'tbentrant sechage_thermique 1', 'tbentrant flottateur 2', 'CO2 elec 6', 'CO2 construction epaississement_statique 3']::varchar[],
d_vie real default 30::real,
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

select api.add_new_formula('CO2 construction epaississement_statique 1'::varchar, 'co2_c=((feobj10_es)*(eh<10000)+(feobj50_es)*(eh>10000)*(eh<100000)+(feobj100_es)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)*d_vie'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 construction epaississement_statique 2'::varchar, 'co2_c=((feobj10_es)*(eh<10000)+(feobj50_es)*(eh>10000)*(eh<100000)+(feobj100_es)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)*d_vie'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 exploitation epaississement_statique 3'::varchar, 'co2_e=feelec*tbsortant*welec_es'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant sechage_thermique 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('tbentrant flottateur 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 construction epaississement_statique 3'::varchar, 'co2_c=((feobj10_es)*(eh<10000)+(feobj50_es)*(eh>10000)*(eh<100000)+(feobj100_es)*(eh>100000))*tbentrant*d_vie'::varchar, 3, ''::text) ;





alter type ___.bloc_type add value 'filiere_eau' ;
commit ; 
insert into ___.input_output values ('filiere_eau', array['prod_e', 'd_vie', 'dcoelim', 'ntkelim', 'methode_2', 'eh', 'abatdco', 'abatngl', 'transp_rei', 'transp_naclo3', 'transp_phosphorique', 'q_h2o2', 'transp_citrique', 'q_oxyl', 'transp_javel', 'q_sulf_sod', 'q_sulf', 'q_anti_mousse', 'q_cl2', 'q_uree', 'q_chaux', 'q_catio', 'q_nahso3', 'transp_soude', 'q_hcl', 'q_kmno4', 'transp_anti_mousse', 'q_lait', 'transp_oxyl', 'transp_ca_regen', 'transp_uree', 'transp_sulf_alu', 'transp_nitrique', 'transp_ca_neuf', 'q_sable_t', 'q_soude_c', 'q_anio', 'q_soude', 'transp_nahso3', 'q_nitrique', 'q_naclo3', 'transp_kmno4', 'transp_h2o2', 'q_antiscalant', 'transp_chaux', 'q_phosphorique', 'transp_sulf_sod', 'q_javel', 'transp_mhetanol', 'transp_caco3', 'transp_antiscalant', 'transp_hcl', 'transp_ca_poudre', 'transp_ethanol', 'q_citrique', 'transp_soude_c', 'transp_coagl', 'q_ca_regen', 'q_poly', 'q_mhetanol', 'q_caco3', 'transp_lait', 'q_ca_poudre', 'q_rei', 'transp_catio', 'q_ca_neuf', 'transp_fecl3', 'transp_poly', 'transp_anio', 'q_co2l', 'transp_sable_t', 'q_coagl', 'transp_cl2', 'transp_co2l', 'transp_sulf', 'q_sulf_alu', 'q_ethanol', 'q_fecl3', 'dbo5elim', 'methode', 'dco', 'ntk', 'mes', 'dbo5', 'welec']::varchar[], array['ngl_s', 'dco_s', 'qe_s']::varchar[], array['CH4 exploitation filiere_eau 3', 'ngl_s decanteur_lamellaire 3', 'dco_s filiere_eau 3', 'dco_s filiere_eau 3', 'N2O exploitation filiere_eau 3', 'ngl_s decanteur_lamellaire 3', 'tbentrant sechage_thermique 1', 'CO2 exploitation filiere_eau 3', 'tbentrant flottateur 2', 'CO2 elec 6', 'CO2 exploitation intrant clarificateur 6']::varchar[]) ;

create sequence ___.filiere_eau_bloc_name_seq ;     

create type ___.methode_2_type as enum ('Autres', 'Boues activées', 'Biofiltres');
create type ___.methode_type as enum ('SBR', 'BRM', 'Boues activées', 'MBBR', 'Biofiltres', 'Autres');

create table ___.methode_2_type_table(val ___.methode_2_type primary key, FE real, incert real default 0, description text);
insert into ___.methode_2_type_table(val) values ('Autres') ;
insert into ___.methode_2_type_table(val) values ('Boues activées') ;
insert into ___.methode_2_type_table(val) values ('Biofiltres') ;
create table ___.methode_type_table(val ___.methode_type primary key, FE real, incert real default 0, description text);
insert into ___.methode_type_table(val) values ('SBR') ;
insert into ___.methode_type_table(val) values ('BRM') ;
insert into ___.methode_type_table(val) values ('Boues activées') ;
insert into ___.methode_type_table(val) values ('MBBR') ;
insert into ___.methode_type_table(val) values ('Biofiltres') ;
insert into ___.methode_type_table(val) values ('Autres') ;

select template.basic_view('methode_2_type_table') ;
select template.basic_view('methode_type_table') ;

create table ___.filiere_eau_bloc(
id integer primary key,
shape ___.geo_type not null default 'Polygon',
geom geometry('POLYGON', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('filiere_eau_bloc', abbreviation=>'filiere_eau'),
formula varchar[] default array['ch4_e=fefile_eau*dcoelim', 'ngl_s=eh*ntk_eh*(1 - abatngl)', 'dco_s=dco*(1 - abatdco)', 'dco_s=eh*dco_eh*(1 - abatdco)', 'n2o_e=methode_2*ntkelim', 'ngl_s=ntk*(1 - abatngl)', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'co2_e=feelec*dbo5elim*methode', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec', 'co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_co2l*(fetransp*transp_co2l + 1000*fe_co2l) + 0.001*q_coagl*(fetransp*transp_coagl + 1000*fe_coagl) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_fecl3*(fetransp*transp_fecl3 + 1000*fe_fecl3) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_javel*(fetransp*transp_javel + 1000*fe_javel) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_lait*(fetransp*transp_lait + 1000*fe_lait) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)']::varchar[],
formula_name varchar[] default array['CH4 exploitation filiere_eau 3', 'ngl_s decanteur_lamellaire 3', 'dco_s filiere_eau 3', 'dco_s filiere_eau 3', 'N2O exploitation filiere_eau 3', 'ngl_s decanteur_lamellaire 3', 'tbentrant sechage_thermique 1', 'CO2 exploitation filiere_eau 3', 'tbentrant flottateur 2', 'CO2 elec 6', 'CO2 exploitation intrant clarificateur 6']::varchar[],
prod_e ___.prod_e_type not null default 'Acide sulfurique' references ___.prod_e_type_table(val),
d_vie real default 50::real,
dcoelim real,
ntkelim real,
methode_2 ___.methode_2_type not null default 'Autres' references ___.methode_2_type_table(val),
eh real,
abatdco real,
abatngl real,
transp_rei real default 50::real,
transp_naclo3 real default 50::real,
transp_phosphorique real default 50::real,
q_h2o2 real,
transp_citrique real default 50::real,
q_oxyl real,
transp_javel real default 50::real,
q_sulf_sod real,
q_sulf real,
q_anti_mousse real,
q_cl2 real,
q_uree real,
q_chaux real,
q_catio real,
q_nahso3 real,
transp_soude real default 50::real,
q_hcl real,
q_kmno4 real,
transp_anti_mousse real default 50::real,
q_lait real,
transp_oxyl real default 50::real,
transp_ca_regen real default 50::real,
transp_uree real default 50::real,
transp_sulf_alu real default 50::real,
transp_nitrique real default 50::real,
transp_ca_neuf real default 50::real,
q_sable_t real,
q_soude_c real,
q_anio real,
q_soude real,
transp_nahso3 real default 50::real,
q_nitrique real,
q_naclo3 real,
transp_kmno4 real default 50::real,
transp_h2o2 real default 50::real,
q_antiscalant real,
transp_chaux real default 50::real,
q_phosphorique real,
transp_sulf_sod real default 50::real,
q_javel real,
transp_mhetanol real default 50::real,
transp_caco3 real default 50::real,
transp_antiscalant real default 50::real,
transp_hcl real default 50::real,
transp_ca_poudre real default 50::real,
transp_ethanol real default 50::real,
q_citrique real,
transp_soude_c real default 50::real,
transp_coagl real default 50::real,
q_ca_regen real,
q_poly real,
q_mhetanol real,
q_caco3 real,
transp_lait real default 50::real,
q_ca_poudre real,
q_rei real,
transp_catio real default 50::real,
q_ca_neuf real,
transp_fecl3 real default 50::real,
transp_poly real default 50::real,
transp_anio real default 50::real,
q_co2l real,
transp_sable_t real default 50::real,
q_coagl real,
transp_cl2 real default 50::real,
transp_co2l real default 50::real,
transp_sulf real default 50::real,
q_sulf_alu real,
q_ethanol real,
q_fecl3 real,
dbo5elim real,
methode ___.methode_type not null default 'SBR' references ___.methode_type_table(val),
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

create table ___.filiere_eau_bloc_config(
    like ___.filiere_eau_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.filiere_eau_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('filiere_eau', 'bloc', 'Polygon' 
    ,additional_columns => '{prod_e_type_table.FE as prod_e_FE, prod_e_type_table.description as prod_e_description, methode_2_type_table.FE as methode_2_FE, methode_2_type_table.description as methode_2_description, methode_type_table.FE as methode_FE, methode_type_table.description as methode_description}'
    ,additional_join => 'left join ___.prod_e_type_table on prod_e_type_table.val = c.prod_e  join ___.methode_2_type_table on methode_2_type_table.val = c.methode_2  join ___.methode_type_table on methode_type_table.val = c.methode ') ;

select api.add_new_formula('CH4 exploitation filiere_eau 3'::varchar, 'ch4_e=fefile_eau*dcoelim'::varchar, 3, ''::text) ;
select api.add_new_formula('ngl_s decanteur_lamellaire 3'::varchar, 'ngl_s=eh*ntk_eh*(1 - abatngl)'::varchar, 3, ''::text) ;
select api.add_new_formula('dco_s filiere_eau 3'::varchar, 'dco_s=dco*(1 - abatdco)'::varchar, 3, ''::text) ;
select api.add_new_formula('dco_s filiere_eau 3'::varchar, 'dco_s=eh*dco_eh*(1 - abatdco)'::varchar, 3, ''::text) ;
select api.add_new_formula('N2O exploitation filiere_eau 3'::varchar, 'n2o_e=methode_2*ntkelim'::varchar, 3, ''::text) ;
select api.add_new_formula('ngl_s decanteur_lamellaire 3'::varchar, 'ngl_s=ntk*(1 - abatngl)'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant sechage_thermique 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 exploitation filiere_eau 3'::varchar, 'co2_e=feelec*dbo5elim*methode'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant flottateur 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 exploitation intrant clarificateur 6'::varchar, 'co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_co2l*(fetransp*transp_co2l + 1000*fe_co2l) + 0.001*q_coagl*(fetransp*transp_coagl + 1000*fe_coagl) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_fecl3*(fetransp*transp_fecl3 + 1000*fe_fecl3) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_javel*(fetransp*transp_javel + 1000*fe_javel) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_lait*(fetransp*transp_lait + 1000*fe_lait) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)'::varchar, 6, ''::text) ;





alter type ___.bloc_type add value 'decanteur_lamellaire' ;
commit ; 
insert into ___.input_output values ('decanteur_lamellaire', array['prod_e', 'd_vie', 'tauenterre', 'eh', 'prop_l', 'e', 'h', 'vit', 'vlam', 'abatdco', 'abatngl', 'transp_rei', 'transp_naclo3', 'transp_phosphorique', 'q_h2o2', 'transp_citrique', 'q_oxyl', 'transp_javel', 'q_sulf_sod', 'q_sulf', 'q_anti_mousse', 'q_cl2', 'q_uree', 'q_chaux', 'q_catio', 'q_nahso3', 'transp_soude', 'q_hcl', 'q_kmno4', 'transp_anti_mousse', 'q_lait', 'transp_oxyl', 'transp_ca_regen', 'transp_uree', 'transp_sulf_alu', 'transp_nitrique', 'transp_ca_neuf', 'q_sable_t', 'q_soude_c', 'q_anio', 'q_soude', 'transp_nahso3', 'q_nitrique', 'q_naclo3', 'transp_kmno4', 'transp_h2o2', 'q_antiscalant', 'transp_chaux', 'q_phosphorique', 'transp_sulf_sod', 'q_javel', 'transp_mhetanol', 'transp_caco3', 'transp_antiscalant', 'transp_hcl', 'transp_ca_poudre', 'transp_ethanol', 'q_citrique', 'transp_soude_c', 'transp_coagl', 'q_ca_regen', 'q_poly', 'q_mhetanol', 'q_caco3', 'transp_lait', 'q_ca_poudre', 'q_rei', 'transp_catio', 'q_ca_neuf', 'transp_fecl3', 'transp_poly', 'transp_anio', 'q_co2l', 'transp_sable_t', 'q_coagl', 'transp_cl2', 'transp_co2l', 'transp_sulf', 'q_sulf_alu', 'q_ethanol', 'q_fecl3', 'dbo5elim', 'w_dbo5_eau', 'qe', 'dco', 'ntk', 'mes', 'dbo5', 'long', 'larg', 'vu', 'welec']::varchar[], array['ngl_s', 'dco_s', 'qe_s']::varchar[], array['ngl_s decanteur_lamellaire 3', 'CO2 construction decanteur_lamellaire 3', 'CO2 exploitation fpr 3', 'dco_s filiere_eau 3', 'dco_s filiere_eau 3', 'CO2 construction decanteur_lamellaire 1', 'CO2 construction decanteur_lamellaire 2', 'ngl_s decanteur_lamellaire 3', 'CO2 construction decanteur_lamellaire 3', 'tbentrant sechage_thermique 1', 'CO2 construction decanteur_lamellaire 2', 'CO2 construction decanteur_lamellaire 3', 'CO2 construction decanteur_lamellaire 1', 'tbentrant flottateur 2', 'CO2 elec 6', 'CO2 exploitation intrant clarificateur 6', 'CO2 construction decanteur_lamellaire 3']::varchar[]) ;

create sequence ___.decanteur_lamellaire_bloc_name_seq ;     




create table ___.decanteur_lamellaire_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('decanteur_lamellaire_bloc', abbreviation=>'decanteur_lamellaire'),
formula varchar[] default array['ngl_s=eh*ntk_eh*(1 - abatngl)', 'co2_c=(fepelle*tauenterre*(h + e)*(e + 4.89898*prop_l*(vu/(h*prop_l))**0.5)*(e + 4.89898*(vu/(h*prop_l))**0.5) + cad*(febet*e*rhobet*(9.79796*prop_l*(vu/(h*prop_l))**0.5*(h + e) + 24.0*prop_l*(vu/(h*prop_l))**1.0 + 9.79796*(vu/(h*prop_l))**0.5*(h + e)) + feevac*rhoterre*tauenterre*(h + e)*(e + 4.89898*prop_l*(vu/(h*prop_l))**0.5)*(e + 4.89898*(vu/(h*prop_l))**0.5) + fefonda*(e + 4.89898*prop_l*(vu/(h*prop_l))**0.5)*(e + 4.89898*(vu/(h*prop_l))**0.5) + felam*vlam*rholam))/cad', 'co2_e=feelec*dbo5elim*w_dbo5_eau', 'dco_s=dco*(1 - abatdco)', 'dco_s=eh*dco_eh*(1 - abatdco)', 'co2_c=(fepelle*tauenterre*(h + e)*(e + 4.89898*prop_l*(eh*qe_eh/(prop_l*vit))**0.5)*(e + 4.89898*(eh*qe_eh/(prop_l*vit))**0.5) + cad*(febet*e*rhobet*(9.79796*prop_l*(eh*qe_eh/(prop_l*vit))**0.5*(h + e) + 24.0*prop_l*(eh*qe_eh/(prop_l*vit))**1.0 + 9.79796*(eh*qe_eh/(prop_l*vit))**0.5*(h + e)) + feevac*rhoterre*tauenterre*(h + e)*(e + 4.89898*prop_l*(eh*qe_eh/(prop_l*vit))**0.5)*(e + 4.89898*(eh*qe_eh/(prop_l*vit))**0.5) + fefonda*(e + 4.89898*prop_l*(eh*qe_eh/(prop_l*vit))**0.5)*(e + 4.89898*(eh*qe_eh/(prop_l*vit))**0.5)))/cad', 'co2_c=(fepelle*tauenterre*(h + e)*(e + 4.89898*prop_l*(qe/(prop_l*vit))**0.5)*(e + 4.89898*(qe/(prop_l*vit))**0.5) + cad*(febet*e*rhobet*(9.79796*prop_l*(qe/(prop_l*vit))**0.5*(h + e) + 24.0*prop_l*(qe/(prop_l*vit))**1.0 + 9.79796*(qe/(prop_l*vit))**0.5*(h + e)) + feevac*rhoterre*tauenterre*(h + e)*(e + 4.89898*prop_l*(qe/(prop_l*vit))**0.5)*(e + 4.89898*(qe/(prop_l*vit))**0.5) + fefonda*(e + 4.89898*prop_l*(qe/(prop_l*vit))**0.5)*(e + 4.89898*(qe/(prop_l*vit))**0.5) + felam*vlam*rholam))/cad', 'ngl_s=ntk*(1 - abatngl)', 'co2_c=(fepelle*tauenterre*(h + e)*(e + 4.89898*prop_l*(vu/(h*prop_l))**0.5)*(e + 4.89898*(vu/(h*prop_l))**0.5) + cad*(febet*e*rhobet*(9.79796*prop_l*(vu/(h*prop_l))**0.5*(h + e) + 24.0*prop_l*(vu/(h*prop_l))**1.0 + 9.79796*(vu/(h*prop_l))**0.5*(h + e)) + feevac*rhoterre*tauenterre*(h + e)*(e + 4.89898*prop_l*(vu/(h*prop_l))**0.5)*(e + 4.89898*(vu/(h*prop_l))**0.5) + fefonda*(e + 4.89898*prop_l*(vu/(h*prop_l))**0.5)*(e + 4.89898*(vu/(h*prop_l))**0.5)))/cad', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'co2_c=(fepelle*tauenterre*(h + e)*(e + 4.89898*prop_l*(qe/(prop_l*vit))**0.5)*(e + 4.89898*(qe/(prop_l*vit))**0.5) + cad*(febet*e*rhobet*(9.79796*prop_l*(qe/(prop_l*vit))**0.5*(h + e) + 24.0*prop_l*(qe/(prop_l*vit))**1.0 + 9.79796*(qe/(prop_l*vit))**0.5*(h + e)) + feevac*rhoterre*tauenterre*(h + e)*(e + 4.89898*prop_l*(qe/(prop_l*vit))**0.5)*(e + 4.89898*(qe/(prop_l*vit))**0.5) + fefonda*(e + 4.89898*prop_l*(qe/(prop_l*vit))**0.5)*(e + 4.89898*(qe/(prop_l*vit))**0.5)))/cad', 'co2_c=(fepelle*tauenterre*(h + e)*(e + larg)*(e + long) + cad*(febet*e*rhobet*(larg*long + 2*larg*(h + e) + 2*long*(h + e)) + feevac*rhoterre*tauenterre*(h + e)*(e + larg)*(e + long) + fefonda*(e + larg)*(e + long)))/cad', 'co2_c=(fepelle*tauenterre*(h + e)*(e + 4.89898*prop_l*(eh*qe_eh/(prop_l*vit))**0.5)*(e + 4.89898*(eh*qe_eh/(prop_l*vit))**0.5) + cad*(febet*e*rhobet*(9.79796*prop_l*(eh*qe_eh/(prop_l*vit))**0.5*(h + e) + 24.0*prop_l*(eh*qe_eh/(prop_l*vit))**1.0 + 9.79796*(eh*qe_eh/(prop_l*vit))**0.5*(h + e)) + feevac*rhoterre*tauenterre*(h + e)*(e + 4.89898*prop_l*(eh*qe_eh/(prop_l*vit))**0.5)*(e + 4.89898*(eh*qe_eh/(prop_l*vit))**0.5) + fefonda*(e + 4.89898*prop_l*(eh*qe_eh/(prop_l*vit))**0.5)*(e + 4.89898*(eh*qe_eh/(prop_l*vit))**0.5) + felam*vlam*rholam))/cad', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec', 'co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_co2l*(fetransp*transp_co2l + 1000*fe_co2l) + 0.001*q_coagl*(fetransp*transp_coagl + 1000*fe_coagl) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_fecl3*(fetransp*transp_fecl3 + 1000*fe_fecl3) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_javel*(fetransp*transp_javel + 1000*fe_javel) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_lait*(fetransp*transp_lait + 1000*fe_lait) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)', 'co2_c=(fepelle*tauenterre*(h + e)*(e + larg)*(e + long) + cad*(febet*e*rhobet*(larg*long + 2*larg*(h + e) + 2*long*(h + e)) + feevac*rhoterre*tauenterre*(h + e)*(e + larg)*(e + long) + fefonda*(e + larg)*(e + long) + felam*vlam*rholam))/cad']::varchar[],
formula_name varchar[] default array['ngl_s decanteur_lamellaire 3', 'CO2 construction decanteur_lamellaire 3', 'CO2 exploitation fpr 3', 'dco_s filiere_eau 3', 'dco_s filiere_eau 3', 'CO2 construction decanteur_lamellaire 1', 'CO2 construction decanteur_lamellaire 2', 'ngl_s decanteur_lamellaire 3', 'CO2 construction decanteur_lamellaire 3', 'tbentrant sechage_thermique 1', 'CO2 construction decanteur_lamellaire 2', 'CO2 construction decanteur_lamellaire 3', 'CO2 construction decanteur_lamellaire 1', 'tbentrant flottateur 2', 'CO2 elec 6', 'CO2 exploitation intrant clarificateur 6', 'CO2 construction decanteur_lamellaire 3']::varchar[],
prod_e ___.prod_e_type not null default 'Acide sulfurique' references ___.prod_e_type_table(val),
d_vie real default 50::real,
tauenterre real default 0.75::real,
eh real,
prop_l real default 1::real,
e real default 0.25::real,
h real default 5::real,
vit real default 15::real,
vlam real default 20::real,
abatdco real,
abatngl real,
transp_rei real default 50::real,
transp_naclo3 real default 50::real,
transp_phosphorique real default 50::real,
q_h2o2 real,
transp_citrique real default 50::real,
q_oxyl real,
transp_javel real default 50::real,
q_sulf_sod real,
q_sulf real,
q_anti_mousse real,
q_cl2 real,
q_uree real,
q_chaux real,
q_catio real,
q_nahso3 real,
transp_soude real default 50::real,
q_hcl real,
q_kmno4 real,
transp_anti_mousse real default 50::real,
q_lait real,
transp_oxyl real default 50::real,
transp_ca_regen real default 50::real,
transp_uree real default 50::real,
transp_sulf_alu real default 50::real,
transp_nitrique real default 50::real,
transp_ca_neuf real default 50::real,
q_sable_t real,
q_soude_c real,
q_anio real,
q_soude real,
transp_nahso3 real default 50::real,
q_nitrique real,
q_naclo3 real,
transp_kmno4 real default 50::real,
transp_h2o2 real default 50::real,
q_antiscalant real,
transp_chaux real default 50::real,
q_phosphorique real,
transp_sulf_sod real default 50::real,
q_javel real,
transp_mhetanol real default 50::real,
transp_caco3 real default 50::real,
transp_antiscalant real default 50::real,
transp_hcl real default 50::real,
transp_ca_poudre real default 50::real,
transp_ethanol real default 50::real,
q_citrique real,
transp_soude_c real default 50::real,
transp_coagl real default 50::real,
q_ca_regen real,
q_poly real,
q_mhetanol real,
q_caco3 real,
transp_lait real default 50::real,
q_ca_poudre real,
q_rei real,
transp_catio real default 50::real,
q_ca_neuf real,
transp_fecl3 real default 50::real,
transp_poly real default 50::real,
transp_anio real default 50::real,
q_co2l real,
transp_sable_t real default 50::real,
q_coagl real,
transp_cl2 real default 50::real,
transp_co2l real default 50::real,
transp_sulf real default 50::real,
q_sulf_alu real,
q_ethanol real,
q_fecl3 real,
dbo5elim real,
w_dbo5_eau real,
qe real,
dco real,
ntk real,
mes real,
dbo5 real,
long real,
larg real,
vu real,
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
    ,additional_columns => '{prod_e_type_table.FE as prod_e_FE, prod_e_type_table.description as prod_e_description}'
    ,additional_join => 'left join ___.prod_e_type_table on prod_e_type_table.val = c.prod_e ') ;

select api.add_new_formula('ngl_s decanteur_lamellaire 3'::varchar, 'ngl_s=eh*ntk_eh*(1 - abatngl)'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 construction decanteur_lamellaire 3'::varchar, 'co2_c=(fepelle*tauenterre*(h + e)*(e + 4.89898*prop_l*(vu/(h*prop_l))**0.5)*(e + 4.89898*(vu/(h*prop_l))**0.5) + cad*(febet*e*rhobet*(9.79796*prop_l*(vu/(h*prop_l))**0.5*(h + e) + 24.0*prop_l*(vu/(h*prop_l))**1.0 + 9.79796*(vu/(h*prop_l))**0.5*(h + e)) + feevac*rhoterre*tauenterre*(h + e)*(e + 4.89898*prop_l*(vu/(h*prop_l))**0.5)*(e + 4.89898*(vu/(h*prop_l))**0.5) + fefonda*(e + 4.89898*prop_l*(vu/(h*prop_l))**0.5)*(e + 4.89898*(vu/(h*prop_l))**0.5) + felam*vlam*rholam))/cad'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 exploitation fpr 3'::varchar, 'co2_e=feelec*dbo5elim*w_dbo5_eau'::varchar, 3, ''::text) ;
select api.add_new_formula('dco_s filiere_eau 3'::varchar, 'dco_s=dco*(1 - abatdco)'::varchar, 3, ''::text) ;
select api.add_new_formula('dco_s filiere_eau 3'::varchar, 'dco_s=eh*dco_eh*(1 - abatdco)'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 construction decanteur_lamellaire 1'::varchar, 'co2_c=(fepelle*tauenterre*(h + e)*(e + 4.89898*prop_l*(eh*qe_eh/(prop_l*vit))**0.5)*(e + 4.89898*(eh*qe_eh/(prop_l*vit))**0.5) + cad*(febet*e*rhobet*(9.79796*prop_l*(eh*qe_eh/(prop_l*vit))**0.5*(h + e) + 24.0*prop_l*(eh*qe_eh/(prop_l*vit))**1.0 + 9.79796*(eh*qe_eh/(prop_l*vit))**0.5*(h + e)) + feevac*rhoterre*tauenterre*(h + e)*(e + 4.89898*prop_l*(eh*qe_eh/(prop_l*vit))**0.5)*(e + 4.89898*(eh*qe_eh/(prop_l*vit))**0.5) + fefonda*(e + 4.89898*prop_l*(eh*qe_eh/(prop_l*vit))**0.5)*(e + 4.89898*(eh*qe_eh/(prop_l*vit))**0.5)))/cad'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 construction decanteur_lamellaire 2'::varchar, 'co2_c=(fepelle*tauenterre*(h + e)*(e + 4.89898*prop_l*(qe/(prop_l*vit))**0.5)*(e + 4.89898*(qe/(prop_l*vit))**0.5) + cad*(febet*e*rhobet*(9.79796*prop_l*(qe/(prop_l*vit))**0.5*(h + e) + 24.0*prop_l*(qe/(prop_l*vit))**1.0 + 9.79796*(qe/(prop_l*vit))**0.5*(h + e)) + feevac*rhoterre*tauenterre*(h + e)*(e + 4.89898*prop_l*(qe/(prop_l*vit))**0.5)*(e + 4.89898*(qe/(prop_l*vit))**0.5) + fefonda*(e + 4.89898*prop_l*(qe/(prop_l*vit))**0.5)*(e + 4.89898*(qe/(prop_l*vit))**0.5) + felam*vlam*rholam))/cad'::varchar, 2, ''::text) ;
select api.add_new_formula('ngl_s decanteur_lamellaire 3'::varchar, 'ngl_s=ntk*(1 - abatngl)'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 construction decanteur_lamellaire 3'::varchar, 'co2_c=(fepelle*tauenterre*(h + e)*(e + 4.89898*prop_l*(vu/(h*prop_l))**0.5)*(e + 4.89898*(vu/(h*prop_l))**0.5) + cad*(febet*e*rhobet*(9.79796*prop_l*(vu/(h*prop_l))**0.5*(h + e) + 24.0*prop_l*(vu/(h*prop_l))**1.0 + 9.79796*(vu/(h*prop_l))**0.5*(h + e)) + feevac*rhoterre*tauenterre*(h + e)*(e + 4.89898*prop_l*(vu/(h*prop_l))**0.5)*(e + 4.89898*(vu/(h*prop_l))**0.5) + fefonda*(e + 4.89898*prop_l*(vu/(h*prop_l))**0.5)*(e + 4.89898*(vu/(h*prop_l))**0.5)))/cad'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant sechage_thermique 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 construction decanteur_lamellaire 2'::varchar, 'co2_c=(fepelle*tauenterre*(h + e)*(e + 4.89898*prop_l*(qe/(prop_l*vit))**0.5)*(e + 4.89898*(qe/(prop_l*vit))**0.5) + cad*(febet*e*rhobet*(9.79796*prop_l*(qe/(prop_l*vit))**0.5*(h + e) + 24.0*prop_l*(qe/(prop_l*vit))**1.0 + 9.79796*(qe/(prop_l*vit))**0.5*(h + e)) + feevac*rhoterre*tauenterre*(h + e)*(e + 4.89898*prop_l*(qe/(prop_l*vit))**0.5)*(e + 4.89898*(qe/(prop_l*vit))**0.5) + fefonda*(e + 4.89898*prop_l*(qe/(prop_l*vit))**0.5)*(e + 4.89898*(qe/(prop_l*vit))**0.5)))/cad'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 construction decanteur_lamellaire 3'::varchar, 'co2_c=(fepelle*tauenterre*(h + e)*(e + larg)*(e + long) + cad*(febet*e*rhobet*(larg*long + 2*larg*(h + e) + 2*long*(h + e)) + feevac*rhoterre*tauenterre*(h + e)*(e + larg)*(e + long) + fefonda*(e + larg)*(e + long)))/cad'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 construction decanteur_lamellaire 1'::varchar, 'co2_c=(fepelle*tauenterre*(h + e)*(e + 4.89898*prop_l*(eh*qe_eh/(prop_l*vit))**0.5)*(e + 4.89898*(eh*qe_eh/(prop_l*vit))**0.5) + cad*(febet*e*rhobet*(9.79796*prop_l*(eh*qe_eh/(prop_l*vit))**0.5*(h + e) + 24.0*prop_l*(eh*qe_eh/(prop_l*vit))**1.0 + 9.79796*(eh*qe_eh/(prop_l*vit))**0.5*(h + e)) + feevac*rhoterre*tauenterre*(h + e)*(e + 4.89898*prop_l*(eh*qe_eh/(prop_l*vit))**0.5)*(e + 4.89898*(eh*qe_eh/(prop_l*vit))**0.5) + fefonda*(e + 4.89898*prop_l*(eh*qe_eh/(prop_l*vit))**0.5)*(e + 4.89898*(eh*qe_eh/(prop_l*vit))**0.5) + felam*vlam*rholam))/cad'::varchar, 1, ''::text) ;
select api.add_new_formula('tbentrant flottateur 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 exploitation intrant clarificateur 6'::varchar, 'co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_co2l*(fetransp*transp_co2l + 1000*fe_co2l) + 0.001*q_coagl*(fetransp*transp_coagl + 1000*fe_coagl) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_fecl3*(fetransp*transp_fecl3 + 1000*fe_fecl3) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_javel*(fetransp*transp_javel + 1000*fe_javel) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_lait*(fetransp*transp_lait + 1000*fe_lait) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 construction decanteur_lamellaire 3'::varchar, 'co2_c=(fepelle*tauenterre*(h + e)*(e + larg)*(e + long) + cad*(febet*e*rhobet*(larg*long + 2*larg*(h + e) + 2*long*(h + e)) + feevac*rhoterre*tauenterre*(h + e)*(e + larg)*(e + long) + fefonda*(e + larg)*(e + long) + felam*vlam*rholam))/cad'::varchar, 3, ''::text) ;





alter type ___.bloc_type add value 'chaulage' ;
commit ; 
insert into ___.input_output values ('chaulage', array['d_vie', 'eh', 'mes', 'dbo5', 'tbentrant', 'welec', 'transp_chaux', 'q_chaux']::varchar[], array['tbsortant_s']::varchar[], array['CO2 exploitation q_chaux chaulage 6', 'CO2 construction chaulage 2', 'tbentrant sechage_thermique 1', 'CO2 construction chaulage 3', 'tbentrant flottateur 2', 'CO2 construction chaulage 1', 'CO2 elec 6']::varchar[]) ;

create sequence ___.chaulage_bloc_name_seq ;     




create table ___.chaulage_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('chaulage_bloc', abbreviation=>'chaulage'),
formula varchar[] default array['co2_e=0.001*q_chaux*(1000*fechaux + fetransp*transp_chaux)', 'co2_c=((feobj10_ch)*(eh<10000)+(feobj50_ch)*(eh>10000)*(eh<100000)+(feobj100_ch)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)*d_vie', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'co2_c=((feobj10_ch)*(eh<10000)+(feobj50_ch)*(eh>10000)*(eh<100000)+(feobj100_ch)*(eh>100000))*tbentrant*d_vie', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_c=((feobj10_ch)*(eh<10000)+(feobj50_ch)*(eh>10000)*(eh<100000)+(feobj100_ch)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)*d_vie', 'co2_e=feelec*welec']::varchar[],
formula_name varchar[] default array['CO2 exploitation q_chaux chaulage 6', 'CO2 construction chaulage 2', 'tbentrant sechage_thermique 1', 'CO2 construction chaulage 3', 'tbentrant flottateur 2', 'CO2 construction chaulage 1', 'CO2 elec 6']::varchar[],
d_vie real default 15::real,
eh real,
mes real,
dbo5 real,
tbentrant real,
welec real,
transp_chaux real default 50::real,
q_chaux real,
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

select api.add_new_formula('CO2 exploitation q_chaux chaulage 6'::varchar, 'co2_e=0.001*q_chaux*(1000*fechaux + fetransp*transp_chaux)'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 construction chaulage 2'::varchar, 'co2_c=((feobj10_ch)*(eh<10000)+(feobj50_ch)*(eh>10000)*(eh<100000)+(feobj100_ch)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)*d_vie'::varchar, 2, ''::text) ;
select api.add_new_formula('tbentrant sechage_thermique 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 construction chaulage 3'::varchar, 'co2_c=((feobj10_ch)*(eh<10000)+(feobj50_ch)*(eh>10000)*(eh<100000)+(feobj100_ch)*(eh>100000))*tbentrant*d_vie'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant flottateur 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 construction chaulage 1'::varchar, 'co2_c=((feobj10_ch)*(eh<10000)+(feobj50_ch)*(eh>10000)*(eh<100000)+(feobj100_ch)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)*d_vie'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;





alter type ___.bloc_type add value 'clarificateur' ;
commit ; 
insert into ___.input_output values ('clarificateur', array['prod_e', 'd_vie', 'taur', 'tauenterre', 'eh', 'e', 'h', 'vit', 'abatdco', 'abatngl', 'transp_rei', 'transp_naclo3', 'transp_phosphorique', 'q_h2o2', 'transp_citrique', 'q_oxyl', 'transp_javel', 'q_sulf_sod', 'q_sulf', 'q_anti_mousse', 'q_cl2', 'q_uree', 'q_chaux', 'q_catio', 'q_nahso3', 'transp_soude', 'q_hcl', 'q_kmno4', 'transp_anti_mousse', 'q_lait', 'transp_oxyl', 'transp_ca_regen', 'transp_uree', 'transp_sulf_alu', 'transp_nitrique', 'transp_ca_neuf', 'q_sable_t', 'q_soude_c', 'q_anio', 'q_soude', 'transp_nahso3', 'q_nitrique', 'q_naclo3', 'transp_kmno4', 'transp_h2o2', 'q_antiscalant', 'transp_chaux', 'q_phosphorique', 'transp_sulf_sod', 'q_javel', 'transp_mhetanol', 'transp_caco3', 'transp_antiscalant', 'transp_hcl', 'transp_ca_poudre', 'transp_ethanol', 'q_citrique', 'transp_soude_c', 'transp_coagl', 'q_ca_regen', 'q_poly', 'q_mhetanol', 'q_caco3', 'transp_lait', 'q_ca_poudre', 'q_rei', 'transp_catio', 'q_ca_neuf', 'transp_fecl3', 'transp_poly', 'transp_anio', 'q_co2l', 'transp_sable_t', 'q_coagl', 'transp_cl2', 'transp_co2l', 'transp_sulf', 'q_sulf_alu', 'q_ethanol', 'q_fecl3', 'dbo5elim', 'w_dbo5_eau', 'qe', 'dco', 'ntk', 'mes', 'dbo5', 'vu', 'welec']::varchar[], array['tbentrant_s', 'ngl_s', 'dco_s', 'qe_s']::varchar[], array['ngl_s decanteur_lamellaire 3', 'CO2 exploitation fpr 3', 'dco_s filiere_eau 3', 'CO2 construction bassin_cylindrique 3', 'CO2 construction clarificateur 1', 'dco_s filiere_eau 3', 'ngl_s decanteur_lamellaire 3', 'tbentrant sechage_thermique 1', 'tbentrant flottateur 2', 'CO2 elec 6', 'CO2 exploitation intrant clarificateur 6', 'CO2 construction clarificateur 2']::varchar[]) ;

create sequence ___.clarificateur_bloc_name_seq ;     




create table ___.clarificateur_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('clarificateur_bloc', abbreviation=>'clarificateur'),
formula varchar[] default array['ngl_s=eh*ntk_eh*(1 - abatngl)', 'co2_e=feelec*dbo5elim*w_dbo5_eau', 'dco_s=dco*(1 - abatdco)', 'co2_c=(febet*cad*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*fepelle*h*tauenterre*(h + e)*(0.3618*e + (vu/h)**0.5)**2 + 24.0*h*cad*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad)', 'co2_c=(febet*cad*e*rhobet*(24*eh*qe_eh*(taur + 1) + 3.14159*h*vit*(e + 5.52791*(eh*qe_eh*(taur + 1)/vit)**0.5)) + 24.0*fepelle*tauenterre*vit*(h + e)*(0.3618*e + (eh*qe_eh*(taur + 1)/vit)**0.5)**2 + 24.0*cad*vit*(0.3618*e + (eh*qe_eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(cad*vit)', 'dco_s=eh*dco_eh*(1 - abatdco)', 'ngl_s=ntk*(1 - abatngl)', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec', 'co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_co2l*(fetransp*transp_co2l + 1000*fe_co2l) + 0.001*q_coagl*(fetransp*transp_coagl + 1000*fe_coagl) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_fecl3*(fetransp*transp_fecl3 + 1000*fe_fecl3) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_javel*(fetransp*transp_javel + 1000*fe_javel) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_lait*(fetransp*transp_lait + 1000*fe_lait) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)', 'co2_c=(febet*cad*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*fepelle*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2 + 24.0*cad*vit*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(cad*vit)']::varchar[],
formula_name varchar[] default array['ngl_s decanteur_lamellaire 3', 'CO2 exploitation fpr 3', 'dco_s filiere_eau 3', 'CO2 construction bassin_cylindrique 3', 'CO2 construction clarificateur 1', 'dco_s filiere_eau 3', 'ngl_s decanteur_lamellaire 3', 'tbentrant sechage_thermique 1', 'tbentrant flottateur 2', 'CO2 elec 6', 'CO2 exploitation intrant clarificateur 6', 'CO2 construction clarificateur 2']::varchar[],
prod_e ___.prod_e_type not null default 'Acide sulfurique' references ___.prod_e_type_table(val),
d_vie real default 50::real,
taur real default 1::real,
tauenterre real default 0.75::real,
eh real,
e real default 0.25::real,
h real default 3::real,
vit real default 60::real,
abatdco real,
abatngl real,
transp_rei real default 50::real,
transp_naclo3 real default 50::real,
transp_phosphorique real default 50::real,
q_h2o2 real,
transp_citrique real default 50::real,
q_oxyl real,
transp_javel real default 50::real,
q_sulf_sod real,
q_sulf real,
q_anti_mousse real,
q_cl2 real,
q_uree real,
q_chaux real,
q_catio real,
q_nahso3 real,
transp_soude real default 50::real,
q_hcl real,
q_kmno4 real,
transp_anti_mousse real default 50::real,
q_lait real,
transp_oxyl real default 50::real,
transp_ca_regen real default 50::real,
transp_uree real default 50::real,
transp_sulf_alu real default 50::real,
transp_nitrique real default 50::real,
transp_ca_neuf real default 50::real,
q_sable_t real,
q_soude_c real,
q_anio real,
q_soude real,
transp_nahso3 real default 50::real,
q_nitrique real,
q_naclo3 real,
transp_kmno4 real default 50::real,
transp_h2o2 real default 50::real,
q_antiscalant real,
transp_chaux real default 50::real,
q_phosphorique real,
transp_sulf_sod real default 50::real,
q_javel real,
transp_mhetanol real default 50::real,
transp_caco3 real default 50::real,
transp_antiscalant real default 50::real,
transp_hcl real default 50::real,
transp_ca_poudre real default 50::real,
transp_ethanol real default 50::real,
q_citrique real,
transp_soude_c real default 50::real,
transp_coagl real default 50::real,
q_ca_regen real,
q_poly real,
q_mhetanol real,
q_caco3 real,
transp_lait real default 50::real,
q_ca_poudre real,
q_rei real,
transp_catio real default 50::real,
q_ca_neuf real,
transp_fecl3 real default 50::real,
transp_poly real default 50::real,
transp_anio real default 50::real,
q_co2l real,
transp_sable_t real default 50::real,
q_coagl real,
transp_cl2 real default 50::real,
transp_co2l real default 50::real,
transp_sulf real default 50::real,
q_sulf_alu real,
q_ethanol real,
q_fecl3 real,
dbo5elim real,
w_dbo5_eau real,
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
    ,additional_columns => '{prod_e_type_table.FE as prod_e_FE, prod_e_type_table.description as prod_e_description}'
    ,additional_join => 'left join ___.prod_e_type_table on prod_e_type_table.val = c.prod_e ') ;

select api.add_new_formula('ngl_s decanteur_lamellaire 3'::varchar, 'ngl_s=eh*ntk_eh*(1 - abatngl)'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 exploitation fpr 3'::varchar, 'co2_e=feelec*dbo5elim*w_dbo5_eau'::varchar, 3, ''::text) ;
select api.add_new_formula('dco_s filiere_eau 3'::varchar, 'dco_s=dco*(1 - abatdco)'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 construction bassin_cylindrique 3'::varchar, 'co2_c=(febet*cad*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*fepelle*h*tauenterre*(h + e)*(0.3618*e + (vu/h)**0.5)**2 + 24.0*h*cad*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad)'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 construction clarificateur 1'::varchar, 'co2_c=(febet*cad*e*rhobet*(24*eh*qe_eh*(taur + 1) + 3.14159*h*vit*(e + 5.52791*(eh*qe_eh*(taur + 1)/vit)**0.5)) + 24.0*fepelle*tauenterre*vit*(h + e)*(0.3618*e + (eh*qe_eh*(taur + 1)/vit)**0.5)**2 + 24.0*cad*vit*(0.3618*e + (eh*qe_eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(cad*vit)'::varchar, 1, ''::text) ;
select api.add_new_formula('dco_s filiere_eau 3'::varchar, 'dco_s=eh*dco_eh*(1 - abatdco)'::varchar, 3, ''::text) ;
select api.add_new_formula('ngl_s decanteur_lamellaire 3'::varchar, 'ngl_s=ntk*(1 - abatngl)'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant sechage_thermique 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('tbentrant flottateur 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 exploitation intrant clarificateur 6'::varchar, 'co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_co2l*(fetransp*transp_co2l + 1000*fe_co2l) + 0.001*q_coagl*(fetransp*transp_coagl + 1000*fe_coagl) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_fecl3*(fetransp*transp_fecl3 + 1000*fe_fecl3) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_javel*(fetransp*transp_javel + 1000*fe_javel) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_lait*(fetransp*transp_lait + 1000*fe_lait) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 construction clarificateur 2'::varchar, 'co2_c=(febet*cad*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*fepelle*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2 + 24.0*cad*vit*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(cad*vit)'::varchar, 2, ''::text) ;





alter type ___.bloc_type add value 'deconstruction' ;
commit ; 
insert into ___.input_output values ('deconstruction', array['d_vie', 's']::varchar[], array[]::varchar[], array['CO2 construction deconstruction 1']::varchar[]) ;

create sequence ___.deconstruction_bloc_name_seq ;     




create table ___.deconstruction_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('deconstruction_bloc', abbreviation=>'deconstruction'),
formula varchar[] default array['co2_c=fedec_surface*s/d_vie']::varchar[],
formula_name varchar[] default array['CO2 construction deconstruction 1']::varchar[],
d_vie real default 80::real,
s real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.deconstruction_bloc_config(
    like ___.deconstruction_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.deconstruction_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('deconstruction', 'bloc', 'Point' 
    
    ) ;

select api.add_new_formula('CO2 construction deconstruction 1'::varchar, 'co2_c=fedec_surface*s/d_vie'::varchar, 1, ''::text) ;





alter type ___.bloc_type add value 'filtre_a_presse' ;
commit ; 
insert into ___.input_output values ('filtre_a_presse', array['d_vie', 'transp_fecl3', 'transp_chaux', 'q_chaux', 'transp_poly', 'q_poly', 'q_fecl3', 'eh', 'mes', 'dbo5', 'tbentrant', 'welec']::varchar[], array['tbsortant_s']::varchar[], array['CO2 construction filtre_a_presse 2', 'CO2 construction filtre_a_presse 1', 'CO2 exploitation intrant filtre_a_presse 6', 'tbentrant sechage_thermique 1', 'tbentrant flottateur 2', 'CO2 elec 6', 'CO2 construction filtre_a_presse 3']::varchar[]) ;

create sequence ___.filtre_a_presse_bloc_name_seq ;     




create table ___.filtre_a_presse_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('filtre_a_presse_bloc', abbreviation=>'filtre_a_presse'),
formula varchar[] default array['co2_c=((feobj10_fp)*(eh<10000)+(feobj50_fp)*(eh>10000)*(eh<100000)+(feobj100_fp)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)*d_vie', 'co2_c=((feobj10_fp)*(eh<10000)+(feobj50_fp)*(eh>10000)*(eh<100000)+(feobj100_fp)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)*d_vie', 'co2_e=fepolymere*q_poly + 0.001*fetransp*q_poly*transp_poly + 0.001*q_chaux*(1000*fechaux + fetransp*transp_chaux) + 0.001*q_fecl3*(1000*fefecl3 + fetransp*transp_fecl3)', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec', 'co2_c=((feobj10_fp)*(eh<10000)+(feobj50_fp)*(eh>10000)*(eh<100000)+(feobj100_fp)*(eh>100000))*tbentrant*d_vie']::varchar[],
formula_name varchar[] default array['CO2 construction filtre_a_presse 2', 'CO2 construction filtre_a_presse 1', 'CO2 exploitation intrant filtre_a_presse 6', 'tbentrant sechage_thermique 1', 'tbentrant flottateur 2', 'CO2 elec 6', 'CO2 construction filtre_a_presse 3']::varchar[],
d_vie real default 15::real,
transp_fecl3 real default 50::real,
transp_chaux real default 50::real,
q_chaux real,
transp_poly real default 50::real,
q_poly real,
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

select api.add_new_formula('CO2 construction filtre_a_presse 2'::varchar, 'co2_c=((feobj10_fp)*(eh<10000)+(feobj50_fp)*(eh>10000)*(eh<100000)+(feobj100_fp)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)*d_vie'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 construction filtre_a_presse 1'::varchar, 'co2_c=((feobj10_fp)*(eh<10000)+(feobj50_fp)*(eh>10000)*(eh<100000)+(feobj100_fp)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)*d_vie'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 exploitation intrant filtre_a_presse 6'::varchar, 'co2_e=fepolymere*q_poly + 0.001*fetransp*q_poly*transp_poly + 0.001*q_chaux*(1000*fechaux + fetransp*transp_chaux) + 0.001*q_fecl3*(1000*fefecl3 + fetransp*transp_fecl3)'::varchar, 6, ''::text) ;
select api.add_new_formula('tbentrant sechage_thermique 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('tbentrant flottateur 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 construction filtre_a_presse 3'::varchar, 'co2_c=((feobj10_fp)*(eh<10000)+(feobj50_fp)*(eh>10000)*(eh<100000)+(feobj100_fp)*(eh>100000))*tbentrant*d_vie'::varchar, 3, ''::text) ;





alter type ___.bloc_type add value 'brm' ;
commit ; 
insert into ___.input_output values ('brm', array['prod_e', 'd_vie', 'tauenterre', 'vu', 'h', 'mmembrane', 'e', 'eh', 'abatdco', 'abatngl', 'transp_rei', 'transp_naclo3', 'transp_phosphorique', 'q_h2o2', 'transp_citrique', 'q_oxyl', 'transp_javel', 'q_sulf_sod', 'q_sulf', 'q_anti_mousse', 'q_cl2', 'q_uree', 'q_chaux', 'q_catio', 'q_nahso3', 'transp_soude', 'q_hcl', 'q_kmno4', 'transp_anti_mousse', 'q_lait', 'transp_oxyl', 'transp_ca_regen', 'transp_uree', 'transp_sulf_alu', 'transp_nitrique', 'transp_ca_neuf', 'q_sable_t', 'q_soude_c', 'q_anio', 'q_soude', 'transp_nahso3', 'q_nitrique', 'q_naclo3', 'transp_kmno4', 'transp_h2o2', 'q_antiscalant', 'transp_chaux', 'q_phosphorique', 'transp_sulf_sod', 'q_javel', 'transp_mhetanol', 'transp_caco3', 'transp_antiscalant', 'transp_hcl', 'transp_ca_poudre', 'transp_ethanol', 'q_citrique', 'transp_soude_c', 'transp_coagl', 'q_ca_regen', 'q_poly', 'q_mhetanol', 'q_caco3', 'transp_lait', 'q_ca_poudre', 'q_rei', 'transp_catio', 'q_ca_neuf', 'transp_fecl3', 'transp_poly', 'transp_anio', 'q_co2l', 'transp_sable_t', 'q_coagl', 'transp_cl2', 'transp_co2l', 'transp_sulf', 'q_sulf_alu', 'q_ethanol', 'q_fecl3', 'dbo5elim', 'w_dbo5_eau', 'dco', 'ntk', 'mes', 'dbo5', 'welec']::varchar[], array['ngl_s', 'dco_s', 'qe_s']::varchar[], array['ngl_s decanteur_lamellaire 3', 'CO2 exploitation fpr 3', 'dco_s filiere_eau 3', 'dco_s filiere_eau 3', 'ngl_s decanteur_lamellaire 3', 'tbentrant sechage_thermique 1', 'CO2 construction brm 4', 'CO2 elec 6', 'CO2 exploitation intrant clarificateur 6', 'tbentrant flottateur 2']::varchar[]) ;

create sequence ___.brm_bloc_name_seq ;     




create table ___.brm_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('brm_bloc', abbreviation=>'brm'),
formula varchar[] default array['ngl_s=eh*ntk_eh*(1 - abatngl)', 'co2_e=feelec*dbo5elim*w_dbo5_eau', 'dco_s=dco*(1 - abatdco)', 'dco_s=eh*dco_eh*(1 - abatdco)', 'ngl_s=ntk*(1 - abatngl)', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'co2_c=(febet*cad*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*fepelle*h*tauenterre*(h + e)*(0.3618*e + (vu/h)**0.5)**2 + h*cad*(24.0*feevac*rhoterre*tauenterre*(h + e)*(0.3618*e + (vu/h)**0.5)**2 + fefiltre_memb*mmembrane + 24.0*fefonda*(0.3618*e + (vu/h)**0.5)**2))/(h*cad)', 'co2_e=feelec*welec', 'co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_co2l*(fetransp*transp_co2l + 1000*fe_co2l) + 0.001*q_coagl*(fetransp*transp_coagl + 1000*fe_coagl) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_fecl3*(fetransp*transp_fecl3 + 1000*fe_fecl3) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_javel*(fetransp*transp_javel + 1000*fe_javel) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_lait*(fetransp*transp_lait + 1000*fe_lait) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)', 'tbentrant=0.0005*nbjour*(dbo5 + mes)']::varchar[],
formula_name varchar[] default array['ngl_s decanteur_lamellaire 3', 'CO2 exploitation fpr 3', 'dco_s filiere_eau 3', 'dco_s filiere_eau 3', 'ngl_s decanteur_lamellaire 3', 'tbentrant sechage_thermique 1', 'CO2 construction brm 4', 'CO2 elec 6', 'CO2 exploitation intrant clarificateur 6', 'tbentrant flottateur 2']::varchar[],
prod_e ___.prod_e_type not null default 'Acide sulfurique' references ___.prod_e_type_table(val),
d_vie real default 50::real,
tauenterre real default 0.75::real,
vu real,
h real default 4::real,
mmembrane real,
e real default 0.25::real,
eh real,
abatdco real,
abatngl real,
transp_rei real default 50::real,
transp_naclo3 real default 50::real,
transp_phosphorique real default 50::real,
q_h2o2 real,
transp_citrique real default 50::real,
q_oxyl real,
transp_javel real default 50::real,
q_sulf_sod real,
q_sulf real,
q_anti_mousse real,
q_cl2 real,
q_uree real,
q_chaux real,
q_catio real,
q_nahso3 real,
transp_soude real default 50::real,
q_hcl real,
q_kmno4 real,
transp_anti_mousse real default 50::real,
q_lait real,
transp_oxyl real default 50::real,
transp_ca_regen real default 50::real,
transp_uree real default 50::real,
transp_sulf_alu real default 50::real,
transp_nitrique real default 50::real,
transp_ca_neuf real default 50::real,
q_sable_t real,
q_soude_c real,
q_anio real,
q_soude real,
transp_nahso3 real default 50::real,
q_nitrique real,
q_naclo3 real,
transp_kmno4 real default 50::real,
transp_h2o2 real default 50::real,
q_antiscalant real,
transp_chaux real default 50::real,
q_phosphorique real,
transp_sulf_sod real default 50::real,
q_javel real,
transp_mhetanol real default 50::real,
transp_caco3 real default 50::real,
transp_antiscalant real default 50::real,
transp_hcl real default 50::real,
transp_ca_poudre real default 50::real,
transp_ethanol real default 50::real,
q_citrique real,
transp_soude_c real default 50::real,
transp_coagl real default 50::real,
q_ca_regen real,
q_poly real,
q_mhetanol real,
q_caco3 real,
transp_lait real default 50::real,
q_ca_poudre real,
q_rei real,
transp_catio real default 50::real,
q_ca_neuf real,
transp_fecl3 real default 50::real,
transp_poly real default 50::real,
transp_anio real default 50::real,
q_co2l real,
transp_sable_t real default 50::real,
q_coagl real,
transp_cl2 real default 50::real,
transp_co2l real default 50::real,
transp_sulf real default 50::real,
q_sulf_alu real,
q_ethanol real,
q_fecl3 real,
dbo5elim real,
w_dbo5_eau real,
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

create table ___.brm_bloc_config(
    like ___.brm_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.brm_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('brm', 'bloc', 'Point' 
    ,additional_columns => '{prod_e_type_table.FE as prod_e_FE, prod_e_type_table.description as prod_e_description}'
    ,additional_join => 'left join ___.prod_e_type_table on prod_e_type_table.val = c.prod_e ') ;

select api.add_new_formula('ngl_s decanteur_lamellaire 3'::varchar, 'ngl_s=eh*ntk_eh*(1 - abatngl)'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 exploitation fpr 3'::varchar, 'co2_e=feelec*dbo5elim*w_dbo5_eau'::varchar, 3, ''::text) ;
select api.add_new_formula('dco_s filiere_eau 3'::varchar, 'dco_s=dco*(1 - abatdco)'::varchar, 3, ''::text) ;
select api.add_new_formula('dco_s filiere_eau 3'::varchar, 'dco_s=eh*dco_eh*(1 - abatdco)'::varchar, 3, ''::text) ;
select api.add_new_formula('ngl_s decanteur_lamellaire 3'::varchar, 'ngl_s=ntk*(1 - abatngl)'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant sechage_thermique 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 construction brm 4'::varchar, 'co2_c=(febet*cad*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*fepelle*h*tauenterre*(h + e)*(0.3618*e + (vu/h)**0.5)**2 + h*cad*(24.0*feevac*rhoterre*tauenterre*(h + e)*(0.3618*e + (vu/h)**0.5)**2 + fefiltre_memb*mmembrane + 24.0*fefonda*(0.3618*e + (vu/h)**0.5)**2))/(h*cad)'::varchar, 4, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 exploitation intrant clarificateur 6'::varchar, 'co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_co2l*(fetransp*transp_co2l + 1000*fe_co2l) + 0.001*q_coagl*(fetransp*transp_coagl + 1000*fe_coagl) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_fecl3*(fetransp*transp_fecl3 + 1000*fe_fecl3) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_javel*(fetransp*transp_javel + 1000*fe_javel) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_lait*(fetransp*transp_lait + 1000*fe_lait) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)'::varchar, 6, ''::text) ;
select api.add_new_formula('tbentrant flottateur 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;





alter type ___.bloc_type add value 'dessableurdegraisseur' ;
commit ; 
insert into ___.input_output values ('dessableurdegraisseur', array['prod_e', 'd_vie', 'lavage', 'eh', 'conc', 'transp_rei', 'transp_naclo3', 'transp_phosphorique', 'q_h2o2', 'transp_citrique', 'q_oxyl', 'transp_javel', 'q_sulf_sod', 'q_sulf', 'q_anti_mousse', 'q_cl2', 'q_uree', 'q_chaux', 'q_catio', 'q_nahso3', 'transp_soude', 'q_hcl', 'q_kmno4', 'transp_anti_mousse', 'q_lait', 'transp_oxyl', 'transp_ca_regen', 'transp_uree', 'transp_sulf_alu', 'transp_nitrique', 'transp_ca_neuf', 'q_sable_t', 'q_soude_c', 'q_anio', 'q_soude', 'transp_nahso3', 'q_nitrique', 'q_naclo3', 'transp_kmno4', 'transp_h2o2', 'q_antiscalant', 'transp_chaux', 'q_phosphorique', 'transp_sulf_sod', 'q_javel', 'transp_mhetanol', 'transp_caco3', 'transp_antiscalant', 'transp_hcl', 'transp_ca_poudre', 'transp_ethanol', 'q_citrique', 'transp_soude_c', 'transp_coagl', 'q_ca_regen', 'q_poly', 'q_mhetanol', 'q_caco3', 'transp_lait', 'q_ca_poudre', 'q_rei', 'transp_catio', 'q_ca_neuf', 'transp_fecl3', 'transp_poly', 'transp_anio', 'q_co2l', 'transp_sable_t', 'q_coagl', 'transp_cl2', 'transp_co2l', 'transp_sulf', 'q_sulf_alu', 'q_ethanol', 'q_fecl3', 'dbo5elim', 'w_dbo5_eau', 'tauenterre', 'e', 'h', 'vit', 'abatdco', 'abatngl', 'qe', 'dco', 'ntk', 'mes', 'dbo5', 'tsables', 'tgraisses', 'vu', 'welec']::varchar[], array['qe_s', 'ngl_s', 'dco_s']::varchar[], array['ngl_s decanteur_lamellaire 3', 'CO2 exploitation fpr 3', 'CO2 construction dessableurdegraisseur 1', 'dco_s filiere_eau 3', 'CO2 exploitation dessableurdegraisseur 3', 'dco_s filiere_eau 3', 'CO2 construction bassin_cylindrique 3', 'ngl_s decanteur_lamellaire 3', 'tbentrant sechage_thermique 1', 'CO2 exploitation dessableurdegraisseur 1', 'tbentrant flottateur 2', 'CO2 elec 6', 'CO2 exploitation intrant clarificateur 6', 'CO2 construction degazage 2']::varchar[]) ;

create sequence ___.dessableurdegraisseur_bloc_name_seq ;     




create table ___.dessableurdegraisseur_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('dessableurdegraisseur_bloc', abbreviation=>'dessableurdegraisseur'),
formula varchar[] default array['ngl_s=eh*ntk_eh*(1 - abatngl)', 'co2_e=feelec*dbo5elim*w_dbo5_eau', 'co2_c=(febet*cad*e*rhobet*(24*eh*qe_eh + 3.14159*h*vit*(e + 5.52791*(eh*qe_eh/vit)**0.5)) + 24.0*fepelle*tauenterre*vit*(h + e)*(0.3618*e + (eh*qe_eh/vit)**0.5)**2 + 24.0*cad*vit*(0.3618*e + (eh*qe_eh/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(cad*vit)', 'dco_s=dco*(1 - abatdco)', 'co2_e=fedechet*tgraisses + fesables*tsables', 'dco_s=eh*dco_eh*(1 - abatdco)', 'co2_c=(febet*cad*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*fepelle*h*tauenterre*(h + e)*(0.3618*e + (vu/h)**0.5)**2 + 24.0*h*cad*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad)', 'ngl_s=ntk*(1 - abatngl)', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'co2_e=eh*(fedechet*dgraisses*(lgraisses_c*conc - lgraisses_nc*(conc - 1)) + fesables*(lavage*sables_lavé - sables_nlavé*(lavage - 1)))', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec', 'co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_co2l*(fetransp*transp_co2l + 1000*fe_co2l) + 0.001*q_coagl*(fetransp*transp_coagl + 1000*fe_coagl) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_fecl3*(fetransp*transp_fecl3 + 1000*fe_fecl3) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_javel*(fetransp*transp_javel + 1000*fe_javel) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_lait*(fetransp*transp_lait + 1000*fe_lait) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)', 'co2_c=(febet*cad*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe/vit)**0.5) + 24*qe) + 24.0*fepelle*tauenterre*vit*(h + e)*(0.3618*e + (qe/vit)**0.5)**2 + 24.0*cad*vit*(0.3618*e + (qe/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(cad*vit)']::varchar[],
formula_name varchar[] default array['ngl_s decanteur_lamellaire 3', 'CO2 exploitation fpr 3', 'CO2 construction dessableurdegraisseur 1', 'dco_s filiere_eau 3', 'CO2 exploitation dessableurdegraisseur 3', 'dco_s filiere_eau 3', 'CO2 construction bassin_cylindrique 3', 'ngl_s decanteur_lamellaire 3', 'tbentrant sechage_thermique 1', 'CO2 exploitation dessableurdegraisseur 1', 'tbentrant flottateur 2', 'CO2 elec 6', 'CO2 exploitation intrant clarificateur 6', 'CO2 construction degazage 2']::varchar[],
prod_e ___.prod_e_type not null default 'Acide sulfurique' references ___.prod_e_type_table(val),
d_vie real default 50::real,
lavage boolean default 0::boolean,
eh real,
conc boolean default 1::boolean,
transp_rei real default 50::real,
transp_naclo3 real default 50::real,
transp_phosphorique real default 50::real,
q_h2o2 real,
transp_citrique real default 50::real,
q_oxyl real,
transp_javel real default 50::real,
q_sulf_sod real,
q_sulf real,
q_anti_mousse real,
q_cl2 real,
q_uree real,
q_chaux real,
q_catio real,
q_nahso3 real,
transp_soude real default 50::real,
q_hcl real,
q_kmno4 real,
transp_anti_mousse real default 50::real,
q_lait real,
transp_oxyl real default 50::real,
transp_ca_regen real default 50::real,
transp_uree real default 50::real,
transp_sulf_alu real default 50::real,
transp_nitrique real default 50::real,
transp_ca_neuf real default 50::real,
q_sable_t real,
q_soude_c real,
q_anio real,
q_soude real,
transp_nahso3 real default 50::real,
q_nitrique real,
q_naclo3 real,
transp_kmno4 real default 50::real,
transp_h2o2 real default 50::real,
q_antiscalant real,
transp_chaux real default 50::real,
q_phosphorique real,
transp_sulf_sod real default 50::real,
q_javel real,
transp_mhetanol real default 50::real,
transp_caco3 real default 50::real,
transp_antiscalant real default 50::real,
transp_hcl real default 50::real,
transp_ca_poudre real default 50::real,
transp_ethanol real default 50::real,
q_citrique real,
transp_soude_c real default 50::real,
transp_coagl real default 50::real,
q_ca_regen real,
q_poly real,
q_mhetanol real,
q_caco3 real,
transp_lait real default 50::real,
q_ca_poudre real,
q_rei real,
transp_catio real default 50::real,
q_ca_neuf real,
transp_fecl3 real default 50::real,
transp_poly real default 50::real,
transp_anio real default 50::real,
q_co2l real,
transp_sable_t real default 50::real,
q_coagl real,
transp_cl2 real default 50::real,
transp_co2l real default 50::real,
transp_sulf real default 50::real,
q_sulf_alu real,
q_ethanol real,
q_fecl3 real,
dbo5elim real,
w_dbo5_eau real,
tauenterre real default 0.75::real,
e real default 0.25::real,
h real default 4::real,
vit real default 20::real,
abatdco real,
abatngl real,
qe real,
dco real,
ntk real,
mes real,
dbo5 real,
tsables real,
tgraisses real,
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
    ,additional_columns => '{prod_e_type_table.FE as prod_e_FE, prod_e_type_table.description as prod_e_description}'
    ,additional_join => 'left join ___.prod_e_type_table on prod_e_type_table.val = c.prod_e ') ;

select api.add_new_formula('ngl_s decanteur_lamellaire 3'::varchar, 'ngl_s=eh*ntk_eh*(1 - abatngl)'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 exploitation fpr 3'::varchar, 'co2_e=feelec*dbo5elim*w_dbo5_eau'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 construction dessableurdegraisseur 1'::varchar, 'co2_c=(febet*cad*e*rhobet*(24*eh*qe_eh + 3.14159*h*vit*(e + 5.52791*(eh*qe_eh/vit)**0.5)) + 24.0*fepelle*tauenterre*vit*(h + e)*(0.3618*e + (eh*qe_eh/vit)**0.5)**2 + 24.0*cad*vit*(0.3618*e + (eh*qe_eh/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(cad*vit)'::varchar, 1, ''::text) ;
select api.add_new_formula('dco_s filiere_eau 3'::varchar, 'dco_s=dco*(1 - abatdco)'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 exploitation dessableurdegraisseur 3'::varchar, 'co2_e=fedechet*tgraisses + fesables*tsables'::varchar, 3, ''::text) ;
select api.add_new_formula('dco_s filiere_eau 3'::varchar, 'dco_s=eh*dco_eh*(1 - abatdco)'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 construction bassin_cylindrique 3'::varchar, 'co2_c=(febet*cad*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*fepelle*h*tauenterre*(h + e)*(0.3618*e + (vu/h)**0.5)**2 + 24.0*h*cad*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad)'::varchar, 3, ''::text) ;
select api.add_new_formula('ngl_s decanteur_lamellaire 3'::varchar, 'ngl_s=ntk*(1 - abatngl)'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant sechage_thermique 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 exploitation dessableurdegraisseur 1'::varchar, 'co2_e=eh*(fedechet*dgraisses*(lgraisses_c*conc - lgraisses_nc*(conc - 1)) + fesables*(lavage*sables_lavé - sables_nlavé*(lavage - 1)))'::varchar, 1, ''::text) ;
select api.add_new_formula('tbentrant flottateur 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 exploitation intrant clarificateur 6'::varchar, 'co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_co2l*(fetransp*transp_co2l + 1000*fe_co2l) + 0.001*q_coagl*(fetransp*transp_coagl + 1000*fe_coagl) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_fecl3*(fetransp*transp_fecl3 + 1000*fe_fecl3) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_javel*(fetransp*transp_javel + 1000*fe_javel) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_lait*(fetransp*transp_lait + 1000*fe_lait) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 construction degazage 2'::varchar, 'co2_c=(febet*cad*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe/vit)**0.5) + 24*qe) + 24.0*fepelle*tauenterre*vit*(h + e)*(0.3618*e + (qe/vit)**0.5)**2 + 24.0*cad*vit*(0.3618*e + (qe/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(cad*vit)'::varchar, 2, ''::text) ;





alter type ___.bloc_type add value 'centrifugeuse_pour_epais' ;
commit ; 
insert into ___.input_output values ('centrifugeuse_pour_epais', array['d_vie', 'transp_poly', 'q_poly', 'eh', 'mes', 'dbo5', 'tbentrant', 'welec']::varchar[], array['tbsortant_s']::varchar[], array['CO2 construction centrifugeuse_pour_epais 3', 'tbentrant flottateur 2', 'tbentrant sechage_thermique 1', 'CO2 construction centrifugeuse_pour_epais 1', 'CO2 elec 6', 'CO2 exploitation q_poly tables_degouttage 6', 'CO2 construction centrifugeuse_pour_epais 2']::varchar[]) ;

create sequence ___.centrifugeuse_pour_epais_bloc_name_seq ;     




create table ___.centrifugeuse_pour_epais_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('centrifugeuse_pour_epais_bloc', abbreviation=>'centrifugeuse_pour_epais'),
formula varchar[] default array['co2_c=((feobj10_ce)*(eh<10000)+(feobj50_ce)*(eh>10000)*(eh<100000)+(feobj100_ce)*(eh>100000))*tbentrant*d_vie', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'co2_c=((feobj10_ce)*(eh<10000)+(feobj50_ce)*(eh>10000)*(eh<100000)+(feobj100_ce)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)*d_vie', 'co2_e=feelec*welec', 'co2_e=0.001*q_poly*(1000*fepolymere + fetransp*transp_poly)', 'co2_c=((feobj10_ce)*(eh<10000)+(feobj50_ce)*(eh>10000)*(eh<100000)+(feobj100_ce)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)*d_vie']::varchar[],
formula_name varchar[] default array['CO2 construction centrifugeuse_pour_epais 3', 'tbentrant flottateur 2', 'tbentrant sechage_thermique 1', 'CO2 construction centrifugeuse_pour_epais 1', 'CO2 elec 6', 'CO2 exploitation q_poly tables_degouttage 6', 'CO2 construction centrifugeuse_pour_epais 2']::varchar[],
d_vie real default 15::real,
transp_poly real default 50::real,
q_poly real,
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

select api.add_new_formula('CO2 construction centrifugeuse_pour_epais 3'::varchar, 'co2_c=((feobj10_ce)*(eh<10000)+(feobj50_ce)*(eh>10000)*(eh<100000)+(feobj100_ce)*(eh>100000))*tbentrant*d_vie'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant flottateur 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('tbentrant sechage_thermique 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 construction centrifugeuse_pour_epais 1'::varchar, 'co2_c=((feobj10_ce)*(eh<10000)+(feobj50_ce)*(eh>10000)*(eh<100000)+(feobj100_ce)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)*d_vie'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 exploitation q_poly tables_degouttage 6'::varchar, 'co2_e=0.001*q_poly*(1000*fepolymere + fetransp*transp_poly)'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 construction centrifugeuse_pour_epais 2'::varchar, 'co2_c=((feobj10_ce)*(eh<10000)+(feobj50_ce)*(eh>10000)*(eh<100000)+(feobj100_ce)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)*d_vie'::varchar, 2, ''::text) ;





alter type ___.bloc_type add value 'mbbr' ;
commit ; 
insert into ___.input_output values ('mbbr', array['prod_e', 'd_vie', 'tauenterre', 'smateriau', 'tau_remp', 'rho_media', 's_v', 'e', 'h', 'eh', 'abatdco', 'abatngl', 'transp_rei', 'transp_naclo3', 'transp_phosphorique', 'q_h2o2', 'transp_citrique', 'q_oxyl', 'transp_javel', 'q_sulf_sod', 'q_sulf', 'q_anti_mousse', 'q_cl2', 'q_uree', 'q_chaux', 'q_catio', 'q_nahso3', 'transp_soude', 'q_hcl', 'q_kmno4', 'transp_anti_mousse', 'q_lait', 'transp_oxyl', 'transp_ca_regen', 'transp_uree', 'transp_sulf_alu', 'transp_nitrique', 'transp_ca_neuf', 'q_sable_t', 'q_soude_c', 'q_anio', 'q_soude', 'transp_nahso3', 'q_nitrique', 'q_naclo3', 'transp_kmno4', 'transp_h2o2', 'q_antiscalant', 'transp_chaux', 'q_phosphorique', 'transp_sulf_sod', 'q_javel', 'transp_mhetanol', 'transp_caco3', 'transp_antiscalant', 'transp_hcl', 'transp_ca_poudre', 'transp_ethanol', 'q_citrique', 'transp_soude_c', 'transp_coagl', 'q_ca_regen', 'q_poly', 'q_mhetanol', 'q_caco3', 'transp_lait', 'q_ca_poudre', 'q_rei', 'transp_catio', 'q_ca_neuf', 'transp_fecl3', 'transp_poly', 'transp_anio', 'q_co2l', 'transp_sable_t', 'q_coagl', 'transp_cl2', 'transp_co2l', 'transp_sulf', 'q_sulf_alu', 'q_ethanol', 'q_fecl3', 'dbo5elim', 'w_dbo5_eau', 'dco', 'ntk', 'mes', 'dbo5', 'vu', 'welec']::varchar[], array['dbo5_s', 'ngl_s', 'dco_s', 'qe_s']::varchar[], array['ngl_s decanteur_lamellaire 3', 'CO2 exploitation fpr 3', 'dco_s filiere_eau 3', 'CO2 construction mbbr 3', 'dco_s filiere_eau 3', 'ngl_s decanteur_lamellaire 3', 'tbentrant sechage_thermique 1', 'CO2 construction mbbr 3', 'tbentrant flottateur 2', 'CO2 elec 6', 'CO2 exploitation intrant clarificateur 6']::varchar[]) ;

create sequence ___.mbbr_bloc_name_seq ;     




create table ___.mbbr_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('mbbr_bloc', abbreviation=>'mbbr'),
formula varchar[] default array['ngl_s=eh*ntk_eh*(1 - abatngl)', 'co2_e=feelec*dbo5elim*w_dbo5_eau', 'dco_s=dco*(1 - abatdco)', 'co2_c=(febet*cad*e*rhobet*s_v*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + fepehd*h*smateriau*cad*rho_media + 24.0*fepelle*h*s_v*tauenterre*(h + e)*(0.3618*e + (vu/h)**0.5)**2 + 24.0*h*cad*s_v*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad*s_v)', 'dco_s=eh*dco_eh*(1 - abatdco)', 'ngl_s=ntk*(1 - abatngl)', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'co2_c=(febet*cad*e*rhobet*(3.14159*h**2*s_v*tau_remp*(e + 5.52791*(smateriau/(h*s_v*tau_remp))**0.5) + 24*smateriau) + fepehd*h*smateriau*cad*rho_media*tau_remp + 24.0*fepelle*h*s_v*tau_remp*tauenterre*(h + e)*(0.3618*e + (smateriau/(h*s_v*tau_remp))**0.5)**2 + 24.0*h*cad*s_v*tau_remp*(0.3618*e + (smateriau/(h*s_v*tau_remp))**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad*s_v*tau_remp)', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec', 'co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_co2l*(fetransp*transp_co2l + 1000*fe_co2l) + 0.001*q_coagl*(fetransp*transp_coagl + 1000*fe_coagl) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_fecl3*(fetransp*transp_fecl3 + 1000*fe_fecl3) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_javel*(fetransp*transp_javel + 1000*fe_javel) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_lait*(fetransp*transp_lait + 1000*fe_lait) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)']::varchar[],
formula_name varchar[] default array['ngl_s decanteur_lamellaire 3', 'CO2 exploitation fpr 3', 'dco_s filiere_eau 3', 'CO2 construction mbbr 3', 'dco_s filiere_eau 3', 'ngl_s decanteur_lamellaire 3', 'tbentrant sechage_thermique 1', 'CO2 construction mbbr 3', 'tbentrant flottateur 2', 'CO2 elec 6', 'CO2 exploitation intrant clarificateur 6']::varchar[],
prod_e ___.prod_e_type not null default 'Acide sulfurique' references ___.prod_e_type_table(val),
d_vie real default 50::real,
tauenterre real default 0.75::real,
smateriau real,
tau_remp real default 0.4::real,
rho_media real default 145::real,
s_v real default 500::real,
e real default 0.25::real,
h real default 4::real,
eh real,
abatdco real,
abatngl real,
transp_rei real default 50::real,
transp_naclo3 real default 50::real,
transp_phosphorique real default 50::real,
q_h2o2 real,
transp_citrique real default 50::real,
q_oxyl real,
transp_javel real default 50::real,
q_sulf_sod real,
q_sulf real,
q_anti_mousse real,
q_cl2 real,
q_uree real,
q_chaux real,
q_catio real,
q_nahso3 real,
transp_soude real default 50::real,
q_hcl real,
q_kmno4 real,
transp_anti_mousse real default 50::real,
q_lait real,
transp_oxyl real default 50::real,
transp_ca_regen real default 50::real,
transp_uree real default 50::real,
transp_sulf_alu real default 50::real,
transp_nitrique real default 50::real,
transp_ca_neuf real default 50::real,
q_sable_t real,
q_soude_c real,
q_anio real,
q_soude real,
transp_nahso3 real default 50::real,
q_nitrique real,
q_naclo3 real,
transp_kmno4 real default 50::real,
transp_h2o2 real default 50::real,
q_antiscalant real,
transp_chaux real default 50::real,
q_phosphorique real,
transp_sulf_sod real default 50::real,
q_javel real,
transp_mhetanol real default 50::real,
transp_caco3 real default 50::real,
transp_antiscalant real default 50::real,
transp_hcl real default 50::real,
transp_ca_poudre real default 50::real,
transp_ethanol real default 50::real,
q_citrique real,
transp_soude_c real default 50::real,
transp_coagl real default 50::real,
q_ca_regen real,
q_poly real,
q_mhetanol real,
q_caco3 real,
transp_lait real default 50::real,
q_ca_poudre real,
q_rei real,
transp_catio real default 50::real,
q_ca_neuf real,
transp_fecl3 real default 50::real,
transp_poly real default 50::real,
transp_anio real default 50::real,
q_co2l real,
transp_sable_t real default 50::real,
q_coagl real,
transp_cl2 real default 50::real,
transp_co2l real default 50::real,
transp_sulf real default 50::real,
q_sulf_alu real,
q_ethanol real,
q_fecl3 real,
dbo5elim real,
w_dbo5_eau real,
dco real,
ntk real,
mes real,
dbo5 real,
vu real,
welec real,
dbo5_s real default 0.01::real,
ngl_s real,
dco_s real,
qe_s real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.mbbr_bloc_config(
    like ___.mbbr_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.mbbr_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('mbbr', 'bloc', 'Point' 
    ,additional_columns => '{prod_e_type_table.FE as prod_e_FE, prod_e_type_table.description as prod_e_description}'
    ,additional_join => 'left join ___.prod_e_type_table on prod_e_type_table.val = c.prod_e ') ;

select api.add_new_formula('ngl_s decanteur_lamellaire 3'::varchar, 'ngl_s=eh*ntk_eh*(1 - abatngl)'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 exploitation fpr 3'::varchar, 'co2_e=feelec*dbo5elim*w_dbo5_eau'::varchar, 3, ''::text) ;
select api.add_new_formula('dco_s filiere_eau 3'::varchar, 'dco_s=dco*(1 - abatdco)'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 construction mbbr 3'::varchar, 'co2_c=(febet*cad*e*rhobet*s_v*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + fepehd*h*smateriau*cad*rho_media + 24.0*fepelle*h*s_v*tauenterre*(h + e)*(0.3618*e + (vu/h)**0.5)**2 + 24.0*h*cad*s_v*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad*s_v)'::varchar, 3, ''::text) ;
select api.add_new_formula('dco_s filiere_eau 3'::varchar, 'dco_s=eh*dco_eh*(1 - abatdco)'::varchar, 3, ''::text) ;
select api.add_new_formula('ngl_s decanteur_lamellaire 3'::varchar, 'ngl_s=ntk*(1 - abatngl)'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant sechage_thermique 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 construction mbbr 3'::varchar, 'co2_c=(febet*cad*e*rhobet*(3.14159*h**2*s_v*tau_remp*(e + 5.52791*(smateriau/(h*s_v*tau_remp))**0.5) + 24*smateriau) + fepehd*h*smateriau*cad*rho_media*tau_remp + 24.0*fepelle*h*s_v*tau_remp*tauenterre*(h + e)*(0.3618*e + (smateriau/(h*s_v*tau_remp))**0.5)**2 + 24.0*h*cad*s_v*tau_remp*(0.3618*e + (smateriau/(h*s_v*tau_remp))**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad*s_v*tau_remp)'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant flottateur 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 exploitation intrant clarificateur 6'::varchar, 'co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_co2l*(fetransp*transp_co2l + 1000*fe_co2l) + 0.001*q_coagl*(fetransp*transp_coagl + 1000*fe_coagl) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_fecl3*(fetransp*transp_fecl3 + 1000*fe_fecl3) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_javel*(fetransp*transp_javel + 1000*fe_javel) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_lait*(fetransp*transp_lait + 1000*fe_lait) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)'::varchar, 6, ''::text) ;





alter type ___.bloc_type add value 'pompe' ;
commit ; 
insert into ___.input_output values ('pompe', array['d_vie', 'mpompe', 'welec']::varchar[], array[]::varchar[], array['CO2 elec 6', 'CO2 construction poste_de_refoulement 5']::varchar[]) ;

create sequence ___.pompe_bloc_name_seq ;     




create table ___.pompe_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('pompe_bloc', abbreviation=>'pompe'),
formula varchar[] default array['co2_e=feelec*welec', 'co2_c=fepoids*mpompe']::varchar[],
formula_name varchar[] default array['CO2 elec 6', 'CO2 construction poste_de_refoulement 5']::varchar[],
d_vie real default 15::real,
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

select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 construction poste_de_refoulement 5'::varchar, 'co2_c=fepoids*mpompe'::varchar, 5, ''::text) ;





alter type ___.bloc_type add value 'chateau_deau' ;
commit ; 
insert into ___.input_output values ('chateau_deau', array['d_vie', 'vbet', 'mpompe', 'welec']::varchar[], array[]::varchar[], array['CO2 elec 6', 'CO2 construction chateau_deau 5']::varchar[]) ;

create sequence ___.chateau_deau_bloc_name_seq ;     




create table ___.chateau_deau_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('chateau_deau_bloc', abbreviation=>'chateau_deau'),
formula varchar[] default array['co2_e=feelec*welec', 'co2_c=febet*vbet*rhobet + fepoids*mpompe']::varchar[],
formula_name varchar[] default array['CO2 elec 6', 'CO2 construction chateau_deau 5']::varchar[],
d_vie real default 90::real,
vbet real,
mpompe real,
welec real,

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

select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 construction chateau_deau 5'::varchar, 'co2_c=febet*vbet*rhobet + fepoids*mpompe'::varchar, 5, ''::text) ;





alter type ___.bloc_type add value 'station_de_pompage' ;
commit ; 
insert into ___.input_output values ('station_de_pompage', array['d_vie', 'welec', 'h', 'tauenterre', 'e', 'vu']::varchar[], array[]::varchar[], array['CO2 elec 6', 'CO2 construction bassin_cylindrique 3']::varchar[]) ;

create sequence ___.station_de_pompage_bloc_name_seq ;     




create table ___.station_de_pompage_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('station_de_pompage_bloc', abbreviation=>'station_de_pompage'),
formula varchar[] default array['co2_e=feelec*welec', 'co2_c=(febet*cad*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*fepelle*h*tauenterre*(h + e)*(0.3618*e + (vu/h)**0.5)**2 + 24.0*h*cad*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad)']::varchar[],
formula_name varchar[] default array['CO2 elec 6', 'CO2 construction bassin_cylindrique 3']::varchar[],
d_vie real default 30::real,
welec real,
h real,
tauenterre real default 0.75::real,
e real default 0.25::real,
vu real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.station_de_pompage_bloc_config(
    like ___.station_de_pompage_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.station_de_pompage_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('station_de_pompage', 'bloc', 'Point' 
    
    ) ;

select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 construction bassin_cylindrique 3'::varchar, 'co2_c=(febet*cad*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*fepelle*h*tauenterre*(h + e)*(0.3618*e + (vu/h)**0.5)**2 + 24.0*h*cad*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad)'::varchar, 3, ''::text) ;





alter type ___.bloc_type add value 'branchement' ;
commit ; 
insert into ___.input_output values ('branchement', array['d_vie', 'ml', 'tau_reparation']::varchar[], array[]::varchar[], array['CO2 exploitation branchement 1', 'CO2 construction branchement 1']::varchar[]) ;

create sequence ___.branchement_bloc_name_seq ;     




create table ___.branchement_bloc(
id integer primary key,
shape ___.geo_type not null default 'LineString',
geom geometry('LINESTRING', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('branchement_bloc', abbreviation=>'branchement'),
formula varchar[] default array['co2_e=ml*tau_reparation', 'co2_c=febranche*ml']::varchar[],
formula_name varchar[] default array['CO2 exploitation branchement 1', 'CO2 construction branchement 1']::varchar[],
d_vie real default 30::real,
ml real,
tau_reparation real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.branchement_bloc_config(
    like ___.branchement_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.branchement_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('branchement', 'bloc', 'LineString' 
    
    ) ;

select api.add_new_formula('CO2 exploitation branchement 1'::varchar, 'co2_e=ml*tau_reparation'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 construction branchement 1'::varchar, 'co2_c=febranche*ml'::varchar, 1, ''::text) ;





alter type ___.bloc_type add value 'tables_degouttage' ;
commit ; 
insert into ___.input_output values ('tables_degouttage', array['d_vie', 'transp_poly', 'q_poly', 'tbsortant', 'eh', 'mes', 'dbo5', 'tbentrant', 'welec']::varchar[], array['tbsortant_s']::varchar[], array['CO2 construction tables_degouttage 2', 'CO2 construction tables_degouttage 3', 'CO2 exploitation tables_degouttage 3', 'tbentrant sechage_thermique 1', 'tbentrant flottateur 2', 'CO2 construction tables_degouttage 1', 'CO2 elec 6', 'CO2 exploitation q_poly tables_degouttage 6']::varchar[]) ;

create sequence ___.tables_degouttage_bloc_name_seq ;     




create table ___.tables_degouttage_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('tables_degouttage_bloc', abbreviation=>'tables_degouttage'),
formula varchar[] default array['co2_c=((feobj10_te)*(eh<10000)+(feobj50_te)*(eh>10000)*(eh<100000)+(feobj100_te)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)*d_vie', 'co2_c=((feobj10_te)*(eh<10000)+(feobj50_te)*(eh>10000)*(eh<100000)+(feobj100_te)*(eh>100000))*tbentrant*d_vie', 'co2_e=feelec*tbsortant*welec_te', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_c=((feobj10_te)*(eh<10000)+(feobj50_te)*(eh>10000)*(eh<100000)+(feobj100_te)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)*d_vie', 'co2_e=feelec*welec', 'co2_e=0.001*q_poly*(1000*fepolymere + fetransp*transp_poly)']::varchar[],
formula_name varchar[] default array['CO2 construction tables_degouttage 2', 'CO2 construction tables_degouttage 3', 'CO2 exploitation tables_degouttage 3', 'tbentrant sechage_thermique 1', 'tbentrant flottateur 2', 'CO2 construction tables_degouttage 1', 'CO2 elec 6', 'CO2 exploitation q_poly tables_degouttage 6']::varchar[],
d_vie real default 15::real,
transp_poly real default 50::real,
q_poly real,
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

select api.add_new_formula('CO2 construction tables_degouttage 2'::varchar, 'co2_c=((feobj10_te)*(eh<10000)+(feobj50_te)*(eh>10000)*(eh<100000)+(feobj100_te)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)*d_vie'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 construction tables_degouttage 3'::varchar, 'co2_c=((feobj10_te)*(eh<10000)+(feobj50_te)*(eh>10000)*(eh<100000)+(feobj100_te)*(eh>100000))*tbentrant*d_vie'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 exploitation tables_degouttage 3'::varchar, 'co2_e=feelec*tbsortant*welec_te'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant sechage_thermique 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('tbentrant flottateur 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 construction tables_degouttage 1'::varchar, 'co2_c=((feobj10_te)*(eh<10000)+(feobj50_te)*(eh>10000)*(eh<100000)+(feobj100_te)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)*d_vie'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 exploitation q_poly tables_degouttage 6'::varchar, 'co2_e=0.001*q_poly*(1000*fepolymere + fetransp*transp_poly)'::varchar, 6, ''::text) ;





alter type ___.bloc_type add value 'digesteur_aerobie' ;
commit ; 
insert into ___.input_output values ('digesteur_aerobie', array['d_vie', 'eh', 'tbsortant', 'tau_abattement', 'mes', 'dbo5', 'tbentrant', 'welec']::varchar[], array['tbsortant_s']::varchar[], array['CO2 construction digesteur_aerobie 2', 'tbsortant_s digesteur_aerobie 3', 'tbentrant sechage_thermique 1', 'CO2 construction digesteur_aerobie 3', 'CO2 construction digesteur_aerobie 1', 'tbentrant flottateur 2', 'CO2 elec 6', 'CO2 exploitation digesteur_aerobie 3']::varchar[]) ;

create sequence ___.digesteur_aerobie_bloc_name_seq ;     




create table ___.digesteur_aerobie_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('digesteur_aerobie_bloc', abbreviation=>'digesteur_aerobie'),
formula varchar[] default array['co2_c=((feobj10_da)*(eh<10000)+(feobj50_da)*(eh>10000)*(eh<100000)+(feobj100_da)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)*d_vie', 'tbsortant_s=tbsortant*tau_abattement', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'co2_c=((feobj10_da)*(eh<10000)+(feobj50_da)*(eh>10000)*(eh<100000)+(feobj100_da)*(eh>100000))*tbentrant*d_vie', 'co2_c=((feobj10_da)*(eh<10000)+(feobj50_da)*(eh>10000)*(eh<100000)+(feobj100_da)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)*d_vie', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec', 'co2_e=feelec*tbsortant*welec_da']::varchar[],
formula_name varchar[] default array['CO2 construction digesteur_aerobie 2', 'tbsortant_s digesteur_aerobie 3', 'tbentrant sechage_thermique 1', 'CO2 construction digesteur_aerobie 3', 'CO2 construction digesteur_aerobie 1', 'tbentrant flottateur 2', 'CO2 elec 6', 'CO2 exploitation digesteur_aerobie 3']::varchar[],
d_vie real default 30::real,
eh real,
tbsortant real,
tau_abattement real default 35::real,
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

select api.add_new_formula('CO2 construction digesteur_aerobie 2'::varchar, 'co2_c=((feobj10_da)*(eh<10000)+(feobj50_da)*(eh>10000)*(eh<100000)+(feobj100_da)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)*d_vie'::varchar, 2, ''::text) ;
select api.add_new_formula('tbsortant_s digesteur_aerobie 3'::varchar, 'tbsortant_s=tbsortant*tau_abattement'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant sechage_thermique 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 construction digesteur_aerobie 3'::varchar, 'co2_c=((feobj10_da)*(eh<10000)+(feobj50_da)*(eh>10000)*(eh<100000)+(feobj100_da)*(eh>100000))*tbentrant*d_vie'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 construction digesteur_aerobie 1'::varchar, 'co2_c=((feobj10_da)*(eh<10000)+(feobj50_da)*(eh>10000)*(eh<100000)+(feobj100_da)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)*d_vie'::varchar, 1, ''::text) ;
select api.add_new_formula('tbentrant flottateur 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 exploitation digesteur_aerobie 3'::varchar, 'co2_e=feelec*tbsortant*welec_da'::varchar, 3, ''::text) ;





alter type ___.bloc_type add value 'batiment_dexploitation' ;
commit ; 
insert into ___.input_output values ('batiment_dexploitation', array['d_vie', 's', 'feexpl', 'welec']::varchar[], array[]::varchar[], array['CO2 construction batiment_dexploitation 6', 'CO2 elec 6']::varchar[]) ;

create sequence ___.batiment_dexploitation_bloc_name_seq ;     

create type ___.feexpl_type as enum ('Structure métallique', 'Structure en béton');

create table ___.feexpl_type_table(val ___.feexpl_type primary key, FE real, incert real default 0, description text);
insert into ___.feexpl_type_table(val) values ('Structure métallique') ;
insert into ___.feexpl_type_table(val) values ('Structure en béton') ;

select template.basic_view('feexpl_type_table') ;

create table ___.batiment_dexploitation_bloc(
id integer primary key,
shape ___.geo_type not null default 'Polygon',
geom geometry('POLYGON', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('batiment_dexploitation_bloc', abbreviation=>'batiment_dexploitation'),
formula varchar[] default array['co2_c=feexpl*s', 'co2_e=feelec*welec']::varchar[],
formula_name varchar[] default array['CO2 construction batiment_dexploitation 6', 'CO2 elec 6']::varchar[],
d_vie real default 50::real,
s real,
feexpl ___.feexpl_type not null default 'Structure métallique' references ___.feexpl_type_table(val),
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
    ,additional_columns => '{feexpl_type_table.FE as feexpl_FE, feexpl_type_table.description as feexpl_description}'
    ,additional_join => 'left join ___.feexpl_type_table on feexpl_type_table.val = c.feexpl ') ;

select api.add_new_formula('CO2 construction batiment_dexploitation 6'::varchar, 'co2_c=feexpl*s'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;





alter type ___.bloc_type add value 'lspr' ;
commit ; 
insert into ___.input_output values ('lspr', array['d_vie', 'eh']::varchar[], array[]::varchar[], array['N2O exploitation lspr 1', 'CH4 exploitation lspr 1']::varchar[]) ;

create sequence ___.lspr_bloc_name_seq ;     




create table ___.lspr_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('lspr_bloc', abbreviation=>'lspr'),
formula varchar[] default array['n2o_e=eh*fe_lspr_n2o', 'ch4_e=eh*fe_lspr_ch4']::varchar[],
formula_name varchar[] default array['N2O exploitation lspr 1', 'CH4 exploitation lspr 1']::varchar[],
d_vie real default 30::real,
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

select api.add_new_formula('N2O exploitation lspr 1'::varchar, 'n2o_e=eh*fe_lspr_n2o'::varchar, 1, ''::text) ;
select api.add_new_formula('CH4 exploitation lspr 1'::varchar, 'ch4_e=eh*fe_lspr_ch4'::varchar, 1, ''::text) ;





alter type ___.bloc_type add value 'degazage' ;
commit ; 
insert into ___.input_output values ('degazage', array['prod_e', 'd_vie', 'tauenterre', 'eh', 'e', 'h', 'vit', 'abatdco', 'abatngl', 'transp_rei', 'transp_naclo3', 'transp_phosphorique', 'q_h2o2', 'transp_citrique', 'q_oxyl', 'transp_javel', 'q_sulf_sod', 'q_sulf', 'q_anti_mousse', 'q_cl2', 'q_uree', 'q_chaux', 'q_catio', 'q_nahso3', 'transp_soude', 'q_hcl', 'q_kmno4', 'transp_anti_mousse', 'q_lait', 'transp_oxyl', 'transp_ca_regen', 'transp_uree', 'transp_sulf_alu', 'transp_nitrique', 'transp_ca_neuf', 'q_sable_t', 'q_soude_c', 'q_anio', 'q_soude', 'transp_nahso3', 'q_nitrique', 'q_naclo3', 'transp_kmno4', 'transp_h2o2', 'q_antiscalant', 'transp_chaux', 'q_phosphorique', 'transp_sulf_sod', 'q_javel', 'transp_mhetanol', 'transp_caco3', 'transp_antiscalant', 'transp_hcl', 'transp_ca_poudre', 'transp_ethanol', 'q_citrique', 'transp_soude_c', 'transp_coagl', 'q_ca_regen', 'q_poly', 'q_mhetanol', 'q_caco3', 'transp_lait', 'q_ca_poudre', 'q_rei', 'transp_catio', 'q_ca_neuf', 'transp_fecl3', 'transp_poly', 'transp_anio', 'q_co2l', 'transp_sable_t', 'q_coagl', 'transp_cl2', 'transp_co2l', 'transp_sulf', 'q_sulf_alu', 'q_ethanol', 'q_fecl3', 'dbo5elim', 'w_dbo5_eau', 'qe', 'dco', 'ntk', 'mes', 'dbo5', 'vu', 'welec']::varchar[], array['ngl_s', 'dco_s', 'qe_s']::varchar[], array['ngl_s decanteur_lamellaire 3', 'CO2 exploitation fpr 3', 'CO2 construction dessableurdegraisseur 1', 'dco_s filiere_eau 3', 'CO2 construction bassin_cylindrique 3', 'dco_s filiere_eau 3', 'ngl_s decanteur_lamellaire 3', 'tbentrant sechage_thermique 1', 'tbentrant flottateur 2', 'CO2 elec 6', 'CO2 exploitation intrant clarificateur 6', 'CO2 construction degazage 2']::varchar[]) ;

create sequence ___.degazage_bloc_name_seq ;     




create table ___.degazage_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('degazage_bloc', abbreviation=>'degazage'),
formula varchar[] default array['ngl_s=eh*ntk_eh*(1 - abatngl)', 'co2_e=feelec*dbo5elim*w_dbo5_eau', 'co2_c=(febet*cad*e*rhobet*(24*eh*qe_eh + 3.14159*h*vit*(e + 5.52791*(eh*qe_eh/vit)**0.5)) + 24.0*fepelle*tauenterre*vit*(h + e)*(0.3618*e + (eh*qe_eh/vit)**0.5)**2 + 24.0*cad*vit*(0.3618*e + (eh*qe_eh/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(cad*vit)', 'dco_s=dco*(1 - abatdco)', 'co2_c=(febet*cad*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*fepelle*h*tauenterre*(h + e)*(0.3618*e + (vu/h)**0.5)**2 + 24.0*h*cad*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad)', 'dco_s=eh*dco_eh*(1 - abatdco)', 'ngl_s=ntk*(1 - abatngl)', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec', 'co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_co2l*(fetransp*transp_co2l + 1000*fe_co2l) + 0.001*q_coagl*(fetransp*transp_coagl + 1000*fe_coagl) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_fecl3*(fetransp*transp_fecl3 + 1000*fe_fecl3) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_javel*(fetransp*transp_javel + 1000*fe_javel) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_lait*(fetransp*transp_lait + 1000*fe_lait) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)', 'co2_c=(febet*cad*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe/vit)**0.5) + 24*qe) + 24.0*fepelle*tauenterre*vit*(h + e)*(0.3618*e + (qe/vit)**0.5)**2 + 24.0*cad*vit*(0.3618*e + (qe/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(cad*vit)']::varchar[],
formula_name varchar[] default array['ngl_s decanteur_lamellaire 3', 'CO2 exploitation fpr 3', 'CO2 construction dessableurdegraisseur 1', 'dco_s filiere_eau 3', 'CO2 construction bassin_cylindrique 3', 'dco_s filiere_eau 3', 'ngl_s decanteur_lamellaire 3', 'tbentrant sechage_thermique 1', 'tbentrant flottateur 2', 'CO2 elec 6', 'CO2 exploitation intrant clarificateur 6', 'CO2 construction degazage 2']::varchar[],
prod_e ___.prod_e_type not null default 'Acide sulfurique' references ___.prod_e_type_table(val),
d_vie real default 50::real,
tauenterre real default 0.75::real,
eh real,
e real default 0.25::real,
h real default 5::real,
vit real default 60::real,
abatdco real,
abatngl real,
transp_rei real default 50::real,
transp_naclo3 real default 50::real,
transp_phosphorique real default 50::real,
q_h2o2 real,
transp_citrique real default 50::real,
q_oxyl real,
transp_javel real default 50::real,
q_sulf_sod real,
q_sulf real,
q_anti_mousse real,
q_cl2 real,
q_uree real,
q_chaux real,
q_catio real,
q_nahso3 real,
transp_soude real default 50::real,
q_hcl real,
q_kmno4 real,
transp_anti_mousse real default 50::real,
q_lait real,
transp_oxyl real default 50::real,
transp_ca_regen real default 50::real,
transp_uree real default 50::real,
transp_sulf_alu real default 50::real,
transp_nitrique real default 50::real,
transp_ca_neuf real default 50::real,
q_sable_t real,
q_soude_c real,
q_anio real,
q_soude real,
transp_nahso3 real default 50::real,
q_nitrique real,
q_naclo3 real,
transp_kmno4 real default 50::real,
transp_h2o2 real default 50::real,
q_antiscalant real,
transp_chaux real default 50::real,
q_phosphorique real,
transp_sulf_sod real default 50::real,
q_javel real,
transp_mhetanol real default 50::real,
transp_caco3 real default 50::real,
transp_antiscalant real default 50::real,
transp_hcl real default 50::real,
transp_ca_poudre real default 50::real,
transp_ethanol real default 50::real,
q_citrique real,
transp_soude_c real default 50::real,
transp_coagl real default 50::real,
q_ca_regen real,
q_poly real,
q_mhetanol real,
q_caco3 real,
transp_lait real default 50::real,
q_ca_poudre real,
q_rei real,
transp_catio real default 50::real,
q_ca_neuf real,
transp_fecl3 real default 50::real,
transp_poly real default 50::real,
transp_anio real default 50::real,
q_co2l real,
transp_sable_t real default 50::real,
q_coagl real,
transp_cl2 real default 50::real,
transp_co2l real default 50::real,
transp_sulf real default 50::real,
q_sulf_alu real,
q_ethanol real,
q_fecl3 real,
dbo5elim real,
w_dbo5_eau real,
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
    ,additional_columns => '{prod_e_type_table.FE as prod_e_FE, prod_e_type_table.description as prod_e_description}'
    ,additional_join => 'left join ___.prod_e_type_table on prod_e_type_table.val = c.prod_e ') ;

select api.add_new_formula('ngl_s decanteur_lamellaire 3'::varchar, 'ngl_s=eh*ntk_eh*(1 - abatngl)'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 exploitation fpr 3'::varchar, 'co2_e=feelec*dbo5elim*w_dbo5_eau'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 construction dessableurdegraisseur 1'::varchar, 'co2_c=(febet*cad*e*rhobet*(24*eh*qe_eh + 3.14159*h*vit*(e + 5.52791*(eh*qe_eh/vit)**0.5)) + 24.0*fepelle*tauenterre*vit*(h + e)*(0.3618*e + (eh*qe_eh/vit)**0.5)**2 + 24.0*cad*vit*(0.3618*e + (eh*qe_eh/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(cad*vit)'::varchar, 1, ''::text) ;
select api.add_new_formula('dco_s filiere_eau 3'::varchar, 'dco_s=dco*(1 - abatdco)'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 construction bassin_cylindrique 3'::varchar, 'co2_c=(febet*cad*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*fepelle*h*tauenterre*(h + e)*(0.3618*e + (vu/h)**0.5)**2 + 24.0*h*cad*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad)'::varchar, 3, ''::text) ;
select api.add_new_formula('dco_s filiere_eau 3'::varchar, 'dco_s=eh*dco_eh*(1 - abatdco)'::varchar, 3, ''::text) ;
select api.add_new_formula('ngl_s decanteur_lamellaire 3'::varchar, 'ngl_s=ntk*(1 - abatngl)'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant sechage_thermique 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('tbentrant flottateur 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 exploitation intrant clarificateur 6'::varchar, 'co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_co2l*(fetransp*transp_co2l + 1000*fe_co2l) + 0.001*q_coagl*(fetransp*transp_coagl + 1000*fe_coagl) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_fecl3*(fetransp*transp_fecl3 + 1000*fe_fecl3) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_javel*(fetransp*transp_javel + 1000*fe_javel) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_lait*(fetransp*transp_lait + 1000*fe_lait) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 construction degazage 2'::varchar, 'co2_c=(febet*cad*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe/vit)**0.5) + 24*qe) + 24.0*fepelle*tauenterre*vit*(h + e)*(0.3618*e + (qe/vit)**0.5)**2 + 24.0*cad*vit*(0.3618*e + (qe/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(cad*vit)'::varchar, 2, ''::text) ;





alter type ___.bloc_type add value 'sechage_solaire' ;
commit ; 
insert into ___.input_output values ('sechage_solaire', array['siccite_e', 'd_vie', 'eh', 'mes', 'dbo5', 'tbentrant', 'welec']::varchar[], array['siccite_s', 'tbsortant_s']::varchar[], array['CO2 construction sechage_solaire 2', 'tbentrant sechage_thermique 1', 'tbentrant flottateur 2', 'CO2 construction sechage_solaire 1', 'CO2 elec 6', 'CO2 construction sechage_solaire 3']::varchar[]) ;

create sequence ___.sechage_solaire_bloc_name_seq ;     




create table ___.sechage_solaire_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('sechage_solaire_bloc', abbreviation=>'sechage_solaire'),
formula varchar[] default array['co2_c=((feobj50_ss)*(eh>10000)*(eh<100000)+(feobj100_ss)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)*d_vie', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_c=((feobj50_ss)*(eh>10000)*(eh<100000)+(feobj100_ss)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)*d_vie', 'co2_e=feelec*welec', 'co2_c=((feobj50_ss)*(eh>10000)*(eh<100000)+(feobj100_ss)*(eh>100000))*tbentrant*d_vie']::varchar[],
formula_name varchar[] default array['CO2 construction sechage_solaire 2', 'tbentrant sechage_thermique 1', 'tbentrant flottateur 2', 'CO2 construction sechage_solaire 1', 'CO2 elec 6', 'CO2 construction sechage_solaire 3']::varchar[],
siccite_e real,
d_vie real default 30::real,
eh real,
mes real,
dbo5 real,
tbentrant real,
welec real,
siccite_s real,
tbsortant_s real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.sechage_solaire_bloc_config(
    like ___.sechage_solaire_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.sechage_solaire_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('sechage_solaire', 'bloc', 'Point' 
    
    ) ;

select api.add_new_formula('CO2 construction sechage_solaire 2'::varchar, 'co2_c=((feobj50_ss)*(eh>10000)*(eh<100000)+(feobj100_ss)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)*d_vie'::varchar, 2, ''::text) ;
select api.add_new_formula('tbentrant sechage_thermique 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('tbentrant flottateur 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 construction sechage_solaire 1'::varchar, 'co2_c=((feobj50_ss)*(eh>10000)*(eh<100000)+(feobj100_ss)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)*d_vie'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 construction sechage_solaire 3'::varchar, 'co2_c=((feobj50_ss)*(eh>10000)*(eh<100000)+(feobj100_ss)*(eh>100000))*tbentrant*d_vie'::varchar, 3, ''::text) ;





alter type ___.bloc_type add value 'conditionnement_thermiqu' ;
commit ; 
insert into ___.input_output values ('conditionnement_thermiqu', array['d_vie', 'eh', 'vboue', 'mes', 'dbo5', 'tbentrant', 'welec']::varchar[], array['tbsortant_s']::varchar[], array['CO2 exploitation conditionnement_thermiqu 3', 'CO2 construction conditionnement_thermiqu 2', 'tbentrant sechage_thermique 1', 'CO2 construction conditionnement_thermiqu 1', 'CO2 construction conditionnement_thermiqu 3', 'tbentrant flottateur 2', 'CO2 elec 6']::varchar[]) ;

create sequence ___.conditionnement_thermiqu_bloc_name_seq ;     




create table ___.conditionnement_thermiqu_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('conditionnement_thermiqu_bloc', abbreviation=>'conditionnement_thermiqu'),
formula varchar[] default array['co2_e=feelec*vboue*welec_ct', 'co2_c=((feobj50_ct)*(eh>10000)*(eh<100000)+(feobj100_ct)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)*d_vie', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'co2_c=((feobj50_ct)*(eh>10000)*(eh<100000)+(feobj100_ct)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)*d_vie', 'co2_c=((feobj50_ct)*(eh>10000)*(eh<100000)+(feobj100_ct)*(eh>100000))*tbentrant*d_vie', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec']::varchar[],
formula_name varchar[] default array['CO2 exploitation conditionnement_thermiqu 3', 'CO2 construction conditionnement_thermiqu 2', 'tbentrant sechage_thermique 1', 'CO2 construction conditionnement_thermiqu 1', 'CO2 construction conditionnement_thermiqu 3', 'tbentrant flottateur 2', 'CO2 elec 6']::varchar[],
d_vie real default 15::real,
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

select api.add_new_formula('CO2 exploitation conditionnement_thermiqu 3'::varchar, 'co2_e=feelec*vboue*welec_ct'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 construction conditionnement_thermiqu 2'::varchar, 'co2_c=((feobj50_ct)*(eh>10000)*(eh<100000)+(feobj100_ct)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)*d_vie'::varchar, 2, ''::text) ;
select api.add_new_formula('tbentrant sechage_thermique 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 construction conditionnement_thermiqu 1'::varchar, 'co2_c=((feobj50_ct)*(eh>10000)*(eh<100000)+(feobj100_ct)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)*d_vie'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 construction conditionnement_thermiqu 3'::varchar, 'co2_c=((feobj50_ct)*(eh>10000)*(eh<100000)+(feobj100_ct)*(eh>100000))*tbentrant*d_vie'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant flottateur 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;





alter type ___.bloc_type add value 'bassin_cylindrique' ;
commit ; 
insert into ___.input_output values ('bassin_cylindrique', array['h', 'tauenterre', 'e', 'vu']::varchar[], array[]::varchar[], array['CO2 construction bassin_cylindrique 3']::varchar[]) ;

create sequence ___.bassin_cylindrique_bloc_name_seq ;     




create table ___.bassin_cylindrique_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('bassin_cylindrique_bloc', abbreviation=>'bassin_cylindrique'),
formula varchar[] default array['co2_c=(febet*cad*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*fepelle*h*tauenterre*(h + e)*(0.3618*e + (vu/h)**0.5)**2 + 24.0*h*cad*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad)']::varchar[],
formula_name varchar[] default array['CO2 construction bassin_cylindrique 3']::varchar[],
h real,
tauenterre real default 0.75::real,
e real default 0.25::real,
vu real,

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

select api.add_new_formula('CO2 construction bassin_cylindrique 3'::varchar, 'co2_c=(febet*cad*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*fepelle*h*tauenterre*(h + e)*(0.3618*e + (vu/h)**0.5)**2 + 24.0*h*cad*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad)'::varchar, 3, ''::text) ;





alter type ___.bloc_type add value 'rejets' ;
commit ; 
insert into ___.input_output values ('rejets', array['fech4_mil', 'eh', 'abatdco', 'fen2o_oxi', 'abatngl', 'dco', 'ngl']::varchar[], array[]::varchar[], array['N2O exploitation rejets 1', 'CH4 exploitation rejets 1', 'CH4 exploitation rejets 2', 'N2O exploitation rejets 2']::varchar[]) ;

create sequence ___.rejets_bloc_name_seq ;     

create type ___.fech4_mil_type as enum ('Réservoirs, lac, estuaires', 'Autres');
create type ___.fen2o_oxi_type as enum ('Bien oxygéné', 'Peu oxygéné');

create table ___.fech4_mil_type_table(val ___.fech4_mil_type primary key, FE real, incert real default 0, description text);
insert into ___.fech4_mil_type_table(val) values ('Réservoirs, lac, estuaires') ;
insert into ___.fech4_mil_type_table(val) values ('Autres') ;
create table ___.fen2o_oxi_type_table(val ___.fen2o_oxi_type primary key, FE real, incert real default 0, description text);
insert into ___.fen2o_oxi_type_table(val) values ('Bien oxygéné') ;
insert into ___.fen2o_oxi_type_table(val) values ('Peu oxygéné') ;

select template.basic_view('fech4_mil_type_table') ;
select template.basic_view('fen2o_oxi_type_table') ;

create table ___.rejets_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('rejets_bloc', abbreviation=>'rejets'),
formula varchar[] default array['n2o_e=eh*fen2o_oxi*ntk_eh*(1 - abatngl)', 'ch4_e=eh*fech4_mil*dco_eh*(1 - abatdco)', 'ch4_e=dco*fech4_mil', 'n2o_e=fen2o_oxi*ngl']::varchar[],
formula_name varchar[] default array['N2O exploitation rejets 1', 'CH4 exploitation rejets 1', 'CH4 exploitation rejets 2', 'N2O exploitation rejets 2']::varchar[],
fech4_mil ___.fech4_mil_type not null default 'Réservoirs, lac, estuaires' references ___.fech4_mil_type_table(val),
eh real,
abatdco real default 0.75::real,
fen2o_oxi ___.fen2o_oxi_type not null default 'Bien oxygéné' references ___.fen2o_oxi_type_table(val),
abatngl real default 0.8::real,
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

select api.add_new_formula('N2O exploitation rejets 1'::varchar, 'n2o_e=eh*fen2o_oxi*ntk_eh*(1 - abatngl)'::varchar, 1, ''::text) ;
select api.add_new_formula('CH4 exploitation rejets 1'::varchar, 'ch4_e=eh*fech4_mil*dco_eh*(1 - abatdco)'::varchar, 1, ''::text) ;
select api.add_new_formula('CH4 exploitation rejets 2'::varchar, 'ch4_e=dco*fech4_mil'::varchar, 2, ''::text) ;
select api.add_new_formula('N2O exploitation rejets 2'::varchar, 'n2o_e=fen2o_oxi*ngl'::varchar, 2, ''::text) ;





alter type ___.bloc_type add value 'bassin_biologique' ;
commit ; 
insert into ___.input_output values ('bassin_biologique', array['prod_e', 'd_vie', 'tauenterre', 'eh', 'charge_bio', 'e', 'h', 'abatdco', 'abatngl', 'transp_rei', 'transp_naclo3', 'transp_phosphorique', 'q_h2o2', 'transp_citrique', 'q_oxyl', 'transp_javel', 'q_sulf_sod', 'q_sulf', 'q_anti_mousse', 'q_cl2', 'q_uree', 'q_chaux', 'q_catio', 'q_nahso3', 'transp_soude', 'q_hcl', 'q_kmno4', 'transp_anti_mousse', 'q_lait', 'transp_oxyl', 'transp_ca_regen', 'transp_uree', 'transp_sulf_alu', 'transp_nitrique', 'transp_ca_neuf', 'q_sable_t', 'q_soude_c', 'q_anio', 'q_soude', 'transp_nahso3', 'q_nitrique', 'q_naclo3', 'transp_kmno4', 'transp_h2o2', 'q_antiscalant', 'transp_chaux', 'q_phosphorique', 'transp_sulf_sod', 'q_javel', 'transp_mhetanol', 'transp_caco3', 'transp_antiscalant', 'transp_hcl', 'transp_ca_poudre', 'transp_ethanol', 'q_citrique', 'transp_soude_c', 'transp_coagl', 'q_ca_regen', 'q_poly', 'q_mhetanol', 'q_caco3', 'transp_lait', 'q_ca_poudre', 'q_rei', 'transp_catio', 'q_ca_neuf', 'transp_fecl3', 'transp_poly', 'transp_anio', 'q_co2l', 'transp_sable_t', 'q_coagl', 'transp_cl2', 'transp_co2l', 'transp_sulf', 'q_sulf_alu', 'q_ethanol', 'q_fecl3', 'dbo5elim', 'w_dbo5_eau', 'dbo5', 'dco', 'ntk', 'mes', 'vu', 'welec']::varchar[], array['ngl_s', 'dco_s', 'qe_s']::varchar[], array['ngl_s decanteur_lamellaire 3', 'CO2 exploitation fpr 3', 'dco_s filiere_eau 3', 'CO2 construction bassin_cylindrique 3', 'dco_s filiere_eau 3', 'ngl_s decanteur_lamellaire 3', 'tbentrant sechage_thermique 1', 'CO2 construction bassin_biologique 1', 'tbentrant flottateur 2', 'CO2 elec 6', 'CO2 exploitation intrant clarificateur 6', 'CO2 construction bassin_biologique 2']::varchar[]) ;

create sequence ___.bassin_biologique_bloc_name_seq ;     

create type ___.charge_bio_type as enum ('Charge élevée', 'Charge moyenne', 'Charge faible');

create table ___.charge_bio_type_table(val ___.charge_bio_type primary key, FE real, incert real default 0, description text);
insert into ___.charge_bio_type_table(val) values ('Charge élevée') ;
insert into ___.charge_bio_type_table(val) values ('Charge moyenne') ;
insert into ___.charge_bio_type_table(val) values ('Charge faible') ;

select template.basic_view('charge_bio_type_table') ;

create table ___.bassin_biologique_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('bassin_biologique_bloc', abbreviation=>'bassin_biologique'),
formula varchar[] default array['ngl_s=eh*ntk_eh*(1 - abatngl)', 'co2_e=feelec*dbo5elim*w_dbo5_eau', 'dco_s=dco*(1 - abatdco)', 'co2_c=(febet*cad*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*fepelle*h*tauenterre*(h + e)*(0.3618*e + (vu/h)**0.5)**2 + 24.0*h*cad*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad)', 'dco_s=eh*dco_eh*(1 - abatdco)', 'ngl_s=ntk*(1 - abatngl)', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'co2_c=(febet*cad*e*rhobet*(24*eh*dbo5_eh + 3.14159*h**2*charge_bio*(e + 5.52791*(eh*dbo5_eh/(h*charge_bio))**0.5)) + 24.0*fepelle*h*charge_bio*tauenterre*(h + e)*(0.3618*e + (eh*dbo5_eh/(h*charge_bio))**0.5)**2 + 24.0*h*cad*charge_bio*(0.3618*e + (eh*dbo5_eh/(h*charge_bio))**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad*charge_bio)', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec', 'co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_co2l*(fetransp*transp_co2l + 1000*fe_co2l) + 0.001*q_coagl*(fetransp*transp_coagl + 1000*fe_coagl) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_fecl3*(fetransp*transp_fecl3 + 1000*fe_fecl3) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_javel*(fetransp*transp_javel + 1000*fe_javel) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_lait*(fetransp*transp_lait + 1000*fe_lait) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)', 'co2_c=(febet*cad*e*rhobet*(24*dbo5 + 3.14159*h**2*charge_bio*(e + 5.52791*(dbo5/(h*charge_bio))**0.5)) + 24.0*fepelle*h*charge_bio*tauenterre*(h + e)*(0.3618*e + (dbo5/(h*charge_bio))**0.5)**2 + 24.0*h*cad*charge_bio*(0.3618*e + (dbo5/(h*charge_bio))**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad*charge_bio)']::varchar[],
formula_name varchar[] default array['ngl_s decanteur_lamellaire 3', 'CO2 exploitation fpr 3', 'dco_s filiere_eau 3', 'CO2 construction bassin_cylindrique 3', 'dco_s filiere_eau 3', 'ngl_s decanteur_lamellaire 3', 'tbentrant sechage_thermique 1', 'CO2 construction bassin_biologique 1', 'tbentrant flottateur 2', 'CO2 elec 6', 'CO2 exploitation intrant clarificateur 6', 'CO2 construction bassin_biologique 2']::varchar[],
prod_e ___.prod_e_type not null default 'Acide sulfurique' references ___.prod_e_type_table(val),
d_vie real default 50::real,
tauenterre real default 0.75::real,
eh real,
charge_bio ___.charge_bio_type not null default 'Charge élevée' references ___.charge_bio_type_table(val),
e real default 0.25::real,
h real default 4::real,
abatdco real,
abatngl real,
transp_rei real default 50::real,
transp_naclo3 real default 50::real,
transp_phosphorique real default 50::real,
q_h2o2 real,
transp_citrique real default 50::real,
q_oxyl real,
transp_javel real default 50::real,
q_sulf_sod real,
q_sulf real,
q_anti_mousse real,
q_cl2 real,
q_uree real,
q_chaux real,
q_catio real,
q_nahso3 real,
transp_soude real default 50::real,
q_hcl real,
q_kmno4 real,
transp_anti_mousse real default 50::real,
q_lait real,
transp_oxyl real default 50::real,
transp_ca_regen real default 50::real,
transp_uree real default 50::real,
transp_sulf_alu real default 50::real,
transp_nitrique real default 50::real,
transp_ca_neuf real default 50::real,
q_sable_t real,
q_soude_c real,
q_anio real,
q_soude real,
transp_nahso3 real default 50::real,
q_nitrique real,
q_naclo3 real,
transp_kmno4 real default 50::real,
transp_h2o2 real default 50::real,
q_antiscalant real,
transp_chaux real default 50::real,
q_phosphorique real,
transp_sulf_sod real default 50::real,
q_javel real,
transp_mhetanol real default 50::real,
transp_caco3 real default 50::real,
transp_antiscalant real default 50::real,
transp_hcl real default 50::real,
transp_ca_poudre real default 50::real,
transp_ethanol real default 50::real,
q_citrique real,
transp_soude_c real default 50::real,
transp_coagl real default 50::real,
q_ca_regen real,
q_poly real,
q_mhetanol real,
q_caco3 real,
transp_lait real default 50::real,
q_ca_poudre real,
q_rei real,
transp_catio real default 50::real,
q_ca_neuf real,
transp_fecl3 real default 50::real,
transp_poly real default 50::real,
transp_anio real default 50::real,
q_co2l real,
transp_sable_t real default 50::real,
q_coagl real,
transp_cl2 real default 50::real,
transp_co2l real default 50::real,
transp_sulf real default 50::real,
q_sulf_alu real,
q_ethanol real,
q_fecl3 real,
dbo5elim real,
w_dbo5_eau real,
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
    ,additional_columns => '{prod_e_type_table.FE as prod_e_FE, prod_e_type_table.description as prod_e_description, charge_bio_type_table.FE as charge_bio_FE, charge_bio_type_table.description as charge_bio_description}'
    ,additional_join => 'left join ___.prod_e_type_table on prod_e_type_table.val = c.prod_e  join ___.charge_bio_type_table on charge_bio_type_table.val = c.charge_bio ') ;

select api.add_new_formula('ngl_s decanteur_lamellaire 3'::varchar, 'ngl_s=eh*ntk_eh*(1 - abatngl)'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 exploitation fpr 3'::varchar, 'co2_e=feelec*dbo5elim*w_dbo5_eau'::varchar, 3, ''::text) ;
select api.add_new_formula('dco_s filiere_eau 3'::varchar, 'dco_s=dco*(1 - abatdco)'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 construction bassin_cylindrique 3'::varchar, 'co2_c=(febet*cad*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*fepelle*h*tauenterre*(h + e)*(0.3618*e + (vu/h)**0.5)**2 + 24.0*h*cad*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad)'::varchar, 3, ''::text) ;
select api.add_new_formula('dco_s filiere_eau 3'::varchar, 'dco_s=eh*dco_eh*(1 - abatdco)'::varchar, 3, ''::text) ;
select api.add_new_formula('ngl_s decanteur_lamellaire 3'::varchar, 'ngl_s=ntk*(1 - abatngl)'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant sechage_thermique 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 construction bassin_biologique 1'::varchar, 'co2_c=(febet*cad*e*rhobet*(24*eh*dbo5_eh + 3.14159*h**2*charge_bio*(e + 5.52791*(eh*dbo5_eh/(h*charge_bio))**0.5)) + 24.0*fepelle*h*charge_bio*tauenterre*(h + e)*(0.3618*e + (eh*dbo5_eh/(h*charge_bio))**0.5)**2 + 24.0*h*cad*charge_bio*(0.3618*e + (eh*dbo5_eh/(h*charge_bio))**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad*charge_bio)'::varchar, 1, ''::text) ;
select api.add_new_formula('tbentrant flottateur 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 exploitation intrant clarificateur 6'::varchar, 'co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_co2l*(fetransp*transp_co2l + 1000*fe_co2l) + 0.001*q_coagl*(fetransp*transp_coagl + 1000*fe_coagl) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_fecl3*(fetransp*transp_fecl3 + 1000*fe_fecl3) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_javel*(fetransp*transp_javel + 1000*fe_javel) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_lait*(fetransp*transp_lait + 1000*fe_lait) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 construction bassin_biologique 2'::varchar, 'co2_c=(febet*cad*e*rhobet*(24*dbo5 + 3.14159*h**2*charge_bio*(e + 5.52791*(dbo5/(h*charge_bio))**0.5)) + 24.0*fepelle*h*charge_bio*tauenterre*(h + e)*(0.3618*e + (dbo5/(h*charge_bio))**0.5)**2 + 24.0*h*cad*charge_bio*(0.3618*e + (dbo5/(h*charge_bio))**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad*charge_bio)'::varchar, 2, ''::text) ;





alter type ___.bloc_type add value 'stockage_boue' ;
commit ; 
insert into ___.input_output values ('stockage_boue', array['d_vie', 'dbo', 'aere', 'grand', 'welec', 'eh', 'festock', 'mes', 'dbo5', 'tbentrant']::varchar[], array['tbsortant_s']::varchar[], array['CO2 exploitation stockage_boue 3', 'CO2 construction stockage_boue 3', 'CO2 construction stockage_boue 1', 'CO2 exploitation stockage_boue 2', 'CH4 exploitation stockage_boue 2', 'tbentrant sechage_thermique 1', 'CO2 exploitation stockage_boue 1', 'tbentrant flottateur 2', 'CO2 elec 6', 'CO2 construction stockage_boue 2']::varchar[]) ;

create sequence ___.stockage_boue_bloc_name_seq ;     

create type ___.festock_type as enum ('Silo de 500m3', 'Silo de 250m3', 'Silo de 5m3');

create table ___.festock_type_table(val ___.festock_type primary key, FE real, incert real default 0, description text);
insert into ___.festock_type_table(val) values ('Silo de 500m3') ;
insert into ___.festock_type_table(val) values ('Silo de 250m3') ;
insert into ___.festock_type_table(val) values ('Silo de 5m3') ;

select template.basic_view('festock_type_table') ;

create table ___.stockage_boue_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('stockage_boue_bloc', abbreviation=>'stockage_boue'),
formula varchar[] default array['co2_e=fesilo_aere*tbentrant*aere', 'co2_c=festock*tbentrant*d_vie', 'co2_c=0.0005*eh*festock*nbjour*d_vie*(dbo5_eh + mes_eh)', 'co2_e=0.0005*fesilo_aere*nbjour*aere*(dbo5 + mes)', 'ch4_e=-dbo*(aere - 1)*(fesilo_grand*grand - fesilo_petit*(grand - 1))', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'co2_e=0.0005*eh*fesilo_aere*nbjour*aere*(dbo5_eh + mes_eh)', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec', 'co2_c=0.0005*festock*nbjour*d_vie*(dbo5 + mes)']::varchar[],
formula_name varchar[] default array['CO2 exploitation stockage_boue 3', 'CO2 construction stockage_boue 3', 'CO2 construction stockage_boue 1', 'CO2 exploitation stockage_boue 2', 'CH4 exploitation stockage_boue 2', 'tbentrant sechage_thermique 1', 'CO2 exploitation stockage_boue 1', 'tbentrant flottateur 2', 'CO2 elec 6', 'CO2 construction stockage_boue 2']::varchar[],
d_vie real default 30::real,
dbo real,
aere boolean default 0::boolean,
grand boolean default 0::boolean,
welec real,
eh real,
festock ___.festock_type not null default 'Silo de 500m3' references ___.festock_type_table(val),
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

select api.add_new_formula('CO2 exploitation stockage_boue 3'::varchar, 'co2_e=fesilo_aere*tbentrant*aere'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 construction stockage_boue 3'::varchar, 'co2_c=festock*tbentrant*d_vie'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 construction stockage_boue 1'::varchar, 'co2_c=0.0005*eh*festock*nbjour*d_vie*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 exploitation stockage_boue 2'::varchar, 'co2_e=0.0005*fesilo_aere*nbjour*aere*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CH4 exploitation stockage_boue 2'::varchar, 'ch4_e=-dbo*(aere - 1)*(fesilo_grand*grand - fesilo_petit*(grand - 1))'::varchar, 2, ''::text) ;
select api.add_new_formula('tbentrant sechage_thermique 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 exploitation stockage_boue 1'::varchar, 'co2_e=0.0005*eh*fesilo_aere*nbjour*aere*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('tbentrant flottateur 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 construction stockage_boue 2'::varchar, 'co2_c=0.0005*festock*nbjour*d_vie*(dbo5 + mes)'::varchar, 2, ''::text) ;





alter type ___.bloc_type add value 'flottateur' ;
commit ; 
insert into ___.input_output values ('flottateur', array['d_vie', 'transp_poly', 'q_poly', 'tbsortant', 'eh', 'mes', 'dbo5', 'tbentrant', 'welec']::varchar[], array['tbsortant_s']::varchar[], array['CO2 construction flottateur 2', 'CO2 exploitation flottateur 3', 'CO2 construction flottateur 1', 'CO2 construction flottateur 3', 'tbentrant sechage_thermique 1', 'tbentrant flottateur 2', 'CO2 elec 6', 'CO2 exploitation q_poly tables_degouttage 6']::varchar[]) ;

create sequence ___.flottateur_bloc_name_seq ;     




create table ___.flottateur_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('flottateur_bloc', abbreviation=>'flottateur'),
formula varchar[] default array['co2_c=((feobj10_flot)*(eh<10000)+(feobj50_flot)*(eh>10000)*(eh<100000)+(feobj100_flot)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)*d_vie', 'co2_e=feelec*tbsortant*welec_flot', 'co2_c=((feobj10_flot)*(eh<10000)+(feobj50_flot)*(eh>10000)*(eh<100000)+(feobj100_flot)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)*d_vie', 'co2_c=((feobj10_flot)*(eh<10000)+(feobj50_flot)*(eh>10000)*(eh<100000)+(feobj100_flot)*(eh>100000))*tbentrant*d_vie', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec', 'co2_e=0.001*q_poly*(1000*fepolymere + fetransp*transp_poly)']::varchar[],
formula_name varchar[] default array['CO2 construction flottateur 2', 'CO2 exploitation flottateur 3', 'CO2 construction flottateur 1', 'CO2 construction flottateur 3', 'tbentrant sechage_thermique 1', 'tbentrant flottateur 2', 'CO2 elec 6', 'CO2 exploitation q_poly tables_degouttage 6']::varchar[],
d_vie real default 30::real,
transp_poly real default 50::real,
q_poly real,
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

select api.add_new_formula('CO2 construction flottateur 2'::varchar, 'co2_c=((feobj10_flot)*(eh<10000)+(feobj50_flot)*(eh>10000)*(eh<100000)+(feobj100_flot)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)*d_vie'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 exploitation flottateur 3'::varchar, 'co2_e=feelec*tbsortant*welec_flot'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 construction flottateur 1'::varchar, 'co2_c=((feobj10_flot)*(eh<10000)+(feobj50_flot)*(eh>10000)*(eh<100000)+(feobj100_flot)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)*d_vie'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 construction flottateur 3'::varchar, 'co2_c=((feobj10_flot)*(eh<10000)+(feobj50_flot)*(eh>10000)*(eh<100000)+(feobj100_flot)*(eh>100000))*tbentrant*d_vie'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant sechage_thermique 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('tbentrant flottateur 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 exploitation q_poly tables_degouttage 6'::varchar, 'co2_e=0.001*q_poly*(1000*fepolymere + fetransp*transp_poly)'::varchar, 6, ''::text) ;





alter type ___.bloc_type add value 'excavation' ;
commit ; 
insert into ___.input_output values ('excavation', array['d_vie', 'vterre']::varchar[], array[]::varchar[], array['CO2 construction excavation 5']::varchar[]) ;

create sequence ___.excavation_bloc_name_seq ;     




create table ___.excavation_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('excavation_bloc', abbreviation=>'excavation'),
formula varchar[] default array['co2_c=vterre*(feevac*rhoterre + fepelle*cad)']::varchar[],
formula_name varchar[] default array['CO2 construction excavation 5']::varchar[],
d_vie real default 80::real,
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





alter type ___.bloc_type add value 'fpr' ;
commit ; 
insert into ___.input_output values ('fpr', array['prod_e', 'd_vie', 'h', 'eh', 's_geom_eh', 'abatdco', 'abatngl', 'transp_rei', 'transp_naclo3', 'transp_phosphorique', 'q_h2o2', 'transp_citrique', 'q_oxyl', 'transp_javel', 'q_sulf_sod', 'q_sulf', 'q_anti_mousse', 'q_cl2', 'q_uree', 'q_chaux', 'q_catio', 'q_nahso3', 'transp_soude', 'q_hcl', 'q_kmno4', 'transp_anti_mousse', 'q_lait', 'transp_oxyl', 'transp_ca_regen', 'transp_uree', 'transp_sulf_alu', 'transp_nitrique', 'transp_ca_neuf', 'q_sable_t', 'q_soude_c', 'q_anio', 'q_soude', 'transp_nahso3', 'q_nitrique', 'q_naclo3', 'transp_kmno4', 'transp_h2o2', 'q_antiscalant', 'transp_chaux', 'q_phosphorique', 'transp_sulf_sod', 'q_javel', 'transp_mhetanol', 'transp_caco3', 'transp_antiscalant', 'transp_hcl', 'transp_ca_poudre', 'transp_ethanol', 'q_citrique', 'transp_soude_c', 'transp_coagl', 'q_ca_regen', 'q_poly', 'q_mhetanol', 'q_caco3', 'transp_lait', 'q_ca_poudre', 'q_rei', 'transp_catio', 'q_ca_neuf', 'transp_fecl3', 'transp_poly', 'transp_anio', 'q_co2l', 'transp_sable_t', 'q_coagl', 'transp_cl2', 'transp_co2l', 'transp_sulf', 'q_sulf_alu', 'q_ethanol', 'q_fecl3', 'dbo5elim', 'w_dbo5_eau', 'dco', 'ntk', 'mes', 'dbo5', 's_geom', 'welec']::varchar[], array['ngl_s', 'dco_s', 'qe_s']::varchar[], array['CO2 construction fpr 1', 'ngl_s decanteur_lamellaire 3', 'CO2 exploitation fpr 3', 'dco_s filiere_eau 3', 'CO2 construction fpr 3', 'dco_s filiere_eau 3', 'ngl_s decanteur_lamellaire 3', 'tbentrant sechage_thermique 1', 'tbentrant flottateur 2', 'CO2 elec 6', 'CO2 exploitation intrant clarificateur 6']::varchar[]) ;

create sequence ___.fpr_bloc_name_seq ;     




create table ___.fpr_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('fpr_bloc', abbreviation=>'fpr'),
formula varchar[] default array['co2_c=eh*s_geom_eh*(feevac*h*rhoterre + fegeom + fepelle*h*cad)', 'ngl_s=eh*ntk_eh*(1 - abatngl)', 'co2_e=feelec*dbo5elim*w_dbo5_eau', 'dco_s=dco*(1 - abatdco)', 'co2_c=s_geom*(feevac*h*rhoterre + fegeom + fepelle*h*cad)', 'dco_s=eh*dco_eh*(1 - abatdco)', 'ngl_s=ntk*(1 - abatngl)', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec', 'co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_co2l*(fetransp*transp_co2l + 1000*fe_co2l) + 0.001*q_coagl*(fetransp*transp_coagl + 1000*fe_coagl) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_fecl3*(fetransp*transp_fecl3 + 1000*fe_fecl3) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_javel*(fetransp*transp_javel + 1000*fe_javel) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_lait*(fetransp*transp_lait + 1000*fe_lait) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)']::varchar[],
formula_name varchar[] default array['CO2 construction fpr 1', 'ngl_s decanteur_lamellaire 3', 'CO2 exploitation fpr 3', 'dco_s filiere_eau 3', 'CO2 construction fpr 3', 'dco_s filiere_eau 3', 'ngl_s decanteur_lamellaire 3', 'tbentrant sechage_thermique 1', 'tbentrant flottateur 2', 'CO2 elec 6', 'CO2 exploitation intrant clarificateur 6']::varchar[],
prod_e ___.prod_e_type not null default 'Acide sulfurique' references ___.prod_e_type_table(val),
d_vie real default 50::real,
h real default 2::real,
eh real,
s_geom_eh real default 1.5::real,
abatdco real,
abatngl real,
transp_rei real default 50::real,
transp_naclo3 real default 50::real,
transp_phosphorique real default 50::real,
q_h2o2 real,
transp_citrique real default 50::real,
q_oxyl real,
transp_javel real default 50::real,
q_sulf_sod real,
q_sulf real,
q_anti_mousse real,
q_cl2 real,
q_uree real,
q_chaux real,
q_catio real,
q_nahso3 real,
transp_soude real default 50::real,
q_hcl real,
q_kmno4 real,
transp_anti_mousse real default 50::real,
q_lait real,
transp_oxyl real default 50::real,
transp_ca_regen real default 50::real,
transp_uree real default 50::real,
transp_sulf_alu real default 50::real,
transp_nitrique real default 50::real,
transp_ca_neuf real default 50::real,
q_sable_t real,
q_soude_c real,
q_anio real,
q_soude real,
transp_nahso3 real default 50::real,
q_nitrique real,
q_naclo3 real,
transp_kmno4 real default 50::real,
transp_h2o2 real default 50::real,
q_antiscalant real,
transp_chaux real default 50::real,
q_phosphorique real,
transp_sulf_sod real default 50::real,
q_javel real,
transp_mhetanol real default 50::real,
transp_caco3 real default 50::real,
transp_antiscalant real default 50::real,
transp_hcl real default 50::real,
transp_ca_poudre real default 50::real,
transp_ethanol real default 50::real,
q_citrique real,
transp_soude_c real default 50::real,
transp_coagl real default 50::real,
q_ca_regen real,
q_poly real,
q_mhetanol real,
q_caco3 real,
transp_lait real default 50::real,
q_ca_poudre real,
q_rei real,
transp_catio real default 50::real,
q_ca_neuf real,
transp_fecl3 real default 50::real,
transp_poly real default 50::real,
transp_anio real default 50::real,
q_co2l real,
transp_sable_t real default 50::real,
q_coagl real,
transp_cl2 real default 50::real,
transp_co2l real default 50::real,
transp_sulf real default 50::real,
q_sulf_alu real,
q_ethanol real,
q_fecl3 real,
dbo5elim real,
w_dbo5_eau real,
dco real,
ntk real,
mes real,
dbo5 real,
s_geom real,
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
    ,additional_columns => '{prod_e_type_table.FE as prod_e_FE, prod_e_type_table.description as prod_e_description}'
    ,additional_join => 'left join ___.prod_e_type_table on prod_e_type_table.val = c.prod_e ') ;

select api.add_new_formula('CO2 construction fpr 1'::varchar, 'co2_c=eh*s_geom_eh*(feevac*h*rhoterre + fegeom + fepelle*h*cad)'::varchar, 1, ''::text) ;
select api.add_new_formula('ngl_s decanteur_lamellaire 3'::varchar, 'ngl_s=eh*ntk_eh*(1 - abatngl)'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 exploitation fpr 3'::varchar, 'co2_e=feelec*dbo5elim*w_dbo5_eau'::varchar, 3, ''::text) ;
select api.add_new_formula('dco_s filiere_eau 3'::varchar, 'dco_s=dco*(1 - abatdco)'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 construction fpr 3'::varchar, 'co2_c=s_geom*(feevac*h*rhoterre + fegeom + fepelle*h*cad)'::varchar, 3, ''::text) ;
select api.add_new_formula('dco_s filiere_eau 3'::varchar, 'dco_s=eh*dco_eh*(1 - abatdco)'::varchar, 3, ''::text) ;
select api.add_new_formula('ngl_s decanteur_lamellaire 3'::varchar, 'ngl_s=ntk*(1 - abatngl)'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant sechage_thermique 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('tbentrant flottateur 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 exploitation intrant clarificateur 6'::varchar, 'co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_co2l*(fetransp*transp_co2l + 1000*fe_co2l) + 0.001*q_coagl*(fetransp*transp_coagl + 1000*fe_coagl) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_fecl3*(fetransp*transp_fecl3 + 1000*fe_fecl3) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_javel*(fetransp*transp_javel + 1000*fe_javel) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_lait*(fetransp*transp_lait + 1000*fe_lait) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)'::varchar, 6, ''::text) ;





alter type ___.bloc_type add value 'filiere_boue' ;
commit ; 
insert into ___.input_output values ('filiere_boue', array['d_vie', 'eh', 'welec', 'mes', 'dbo5']::varchar[], array['tbsortant_s']::varchar[], array['tbentrant flottateur 2', 'CO2 elec 6', 'tbentrant sechage_thermique 1']::varchar[]) ;

create sequence ___.filiere_boue_bloc_name_seq ;     




create table ___.filiere_boue_bloc(
id integer primary key,
shape ___.geo_type not null default 'Polygon',
geom geometry('POLYGON', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('filiere_boue_bloc', abbreviation=>'filiere_boue'),
formula varchar[] default array['tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)']::varchar[],
formula_name varchar[] default array['tbentrant flottateur 2', 'CO2 elec 6', 'tbentrant sechage_thermique 1']::varchar[],
d_vie real default 15::real,
eh real,
welec real,
mes real,
dbo5 real,
tbsortant_s real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.filiere_boue_bloc_config(
    like ___.filiere_boue_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.filiere_boue_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('filiere_boue', 'bloc', 'Polygon' 
    
    ) ;

select api.add_new_formula('tbentrant flottateur 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('tbentrant sechage_thermique 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;





alter type ___.bloc_type add value 'poste_de_refoulement' ;
commit ; 
insert into ___.input_output values ('poste_de_refoulement', array['d_vie', 'mpompe', 'welec']::varchar[], array[]::varchar[], array['CO2 elec 6', 'CO2 construction poste_de_refoulement 5']::varchar[]) ;

create sequence ___.poste_de_refoulement_bloc_name_seq ;     




create table ___.poste_de_refoulement_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('poste_de_refoulement_bloc', abbreviation=>'poste_de_refoulement'),
formula varchar[] default array['co2_e=feelec*welec', 'co2_c=fepoids*mpompe']::varchar[],
formula_name varchar[] default array['CO2 elec 6', 'CO2 construction poste_de_refoulement 5']::varchar[],
d_vie real default 15::real,
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

select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 construction poste_de_refoulement 5'::varchar, 'co2_c=fepoids*mpompe'::varchar, 5, ''::text) ;





alter type ___.bloc_type add value 'tamis' ;
commit ; 
insert into ___.input_output values ('tamis', array['d_vie', 'munite_tamis', 'qmax', 'eh', 'welec', 'compt', 'qe', 'mes', 'dbo5']::varchar[], array['qe_s']::varchar[], array['CO2 construction tamis 2', 'CO2 exploitation tamis 1', 'tbentrant sechage_thermique 1', 'tbentrant flottateur 2', 'CO2 elec 6', 'CO2 construction tamis 1']::varchar[]) ;

create sequence ___.tamis_bloc_name_seq ;     




create table ___.tamis_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('tamis_bloc', abbreviation=>'tamis'),
formula varchar[] default array['co2_c=fepoids*munite_tamis*qe/qmax', 'co2_e=eh*fedechet*rhodechet*(compt*qdechet_tamis_comp - qdechet_tamis_ncomp*(compt - 1))', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec', 'co2_c=eh*fepoids*munite_tamis*qe_eh/qmax']::varchar[],
formula_name varchar[] default array['CO2 construction tamis 2', 'CO2 exploitation tamis 1', 'tbentrant sechage_thermique 1', 'tbentrant flottateur 2', 'CO2 elec 6', 'CO2 construction tamis 1']::varchar[],
d_vie real default 15::real,
munite_tamis real default 210::real,
qmax real default 270::real,
eh real,
welec real,
compt boolean default 0::boolean,
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

select api.add_new_formula('CO2 construction tamis 2'::varchar, 'co2_c=fepoids*munite_tamis*qe/qmax'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 exploitation tamis 1'::varchar, 'co2_e=eh*fedechet*rhodechet*(compt*qdechet_tamis_comp - qdechet_tamis_ncomp*(compt - 1))'::varchar, 1, ''::text) ;
select api.add_new_formula('tbentrant sechage_thermique 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('tbentrant flottateur 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 construction tamis 1'::varchar, 'co2_c=eh*fepoids*munite_tamis*qe_eh/qmax'::varchar, 1, ''::text) ;





alter type ___.bloc_type add value 'usine' ;
commit ; 
insert into ___.input_output values ('usine', array['d_vie', 'eh', 'welec', 'qe', 'mes', 'dbo5']::varchar[], array[]::varchar[], array['CO2 exploitation usine 2', 'CO2 construction usine 2', 'CO2 exploitation usine 1', 'tbentrant sechage_thermique 1', 'CO2 construction usine 1', 'tbentrant flottateur 2', 'CO2 elec 6']::varchar[]) ;

create sequence ___.usine_bloc_name_seq ;     




create table ___.usine_bloc(
id integer primary key,
shape ___.geo_type not null default 'Polygon',
geom geometry('POLYGON', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('usine_bloc', abbreviation=>'usine'),
formula varchar[] default array['co2_e=fetraitement_e*nbjour*qe', 'co2_c=fetraitement_c*nbjour*qe*d_vie', 'co2_e=eh*fetraitement_e*nbjour*qe_eh', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'co2_c=eh*fetraitement_c*nbjour*d_vie*qe_eh', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec']::varchar[],
formula_name varchar[] default array['CO2 exploitation usine 2', 'CO2 construction usine 2', 'CO2 exploitation usine 1', 'tbentrant sechage_thermique 1', 'CO2 construction usine 1', 'tbentrant flottateur 2', 'CO2 elec 6']::varchar[],
d_vie real default 50::real,
eh real,
welec real,
qe real,
mes real,
dbo5 real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.usine_bloc_config(
    like ___.usine_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.usine_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('usine', 'bloc', 'Polygon' 
    
    ) ;

select api.add_new_formula('CO2 exploitation usine 2'::varchar, 'co2_e=fetraitement_e*nbjour*qe'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 construction usine 2'::varchar, 'co2_c=fetraitement_c*nbjour*qe*d_vie'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 exploitation usine 1'::varchar, 'co2_e=eh*fetraitement_e*nbjour*qe_eh'::varchar, 1, ''::text) ;
select api.add_new_formula('tbentrant sechage_thermique 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 construction usine 1'::varchar, 'co2_c=eh*fetraitement_c*nbjour*d_vie*qe_eh'::varchar, 1, ''::text) ;
select api.add_new_formula('tbentrant flottateur 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;





alter type ___.bloc_type add value 'digesteur__methaniseur' ;
commit ; 
insert into ___.input_output values ('digesteur__methaniseur', array['d_vie', 'tbsortant', 'tau_abattement', 'eh', 'mes', 'dbo5', 'vbiogaz', 'welec']::varchar[], array['tbsortant_s']::varchar[], array['tbsortant_s digesteur_aerobie 3', 'CO2 exploitation digesteur__methaniseur 3', 'CO2 construction digesteur__methaniseur 3', 'tbentrant sechage_thermique 1', 'CH4 exploitation digesteur__methaniseur 3', 'CO2 construction digesteur__methaniseur 4', 'tbentrant flottateur 2', 'CO2 elec 6']::varchar[]) ;

create sequence ___.digesteur__methaniseur_bloc_name_seq ;     




create table ___.digesteur__methaniseur_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('digesteur__methaniseur_bloc', abbreviation=>'digesteur__methaniseur'),
formula varchar[] default array['tbsortant_s=tbsortant*tau_abattement', 'co2_e=feelec*tbsortant*welec_dan', 'co2_c=225*feobj_dan*tbsortant', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'ch4_e=tbsortant*tau_fuite*vol_ms', 'co2_c=feobj_dan*vbiogaz', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec']::varchar[],
formula_name varchar[] default array['tbsortant_s digesteur_aerobie 3', 'CO2 exploitation digesteur__methaniseur 3', 'CO2 construction digesteur__methaniseur 3', 'tbentrant sechage_thermique 1', 'CH4 exploitation digesteur__methaniseur 3', 'CO2 construction digesteur__methaniseur 4', 'tbentrant flottateur 2', 'CO2 elec 6']::varchar[],
d_vie real default 30::real,
tbsortant real,
tau_abattement real default 0.4::real,
eh real,
mes real,
dbo5 real,
vbiogaz real,
welec real,
tbsortant_s real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.digesteur__methaniseur_bloc_config(
    like ___.digesteur__methaniseur_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.digesteur__methaniseur_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('digesteur__methaniseur', 'bloc', 'Point' 
    
    ) ;

select api.add_new_formula('tbsortant_s digesteur_aerobie 3'::varchar, 'tbsortant_s=tbsortant*tau_abattement'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 exploitation digesteur__methaniseur 3'::varchar, 'co2_e=feelec*tbsortant*welec_dan'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 construction digesteur__methaniseur 3'::varchar, 'co2_c=225*feobj_dan*tbsortant'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant sechage_thermique 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CH4 exploitation digesteur__methaniseur 3'::varchar, 'ch4_e=tbsortant*tau_fuite*vol_ms'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 construction digesteur__methaniseur 4'::varchar, 'co2_c=feobj_dan*vbiogaz'::varchar, 4, ''::text) ;
select api.add_new_formula('tbentrant flottateur 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;





alter type ___.bloc_type add value 'grilles_degouttage' ;
commit ; 
insert into ___.input_output values ('grilles_degouttage', array['d_vie', 'tbsortant', 'transp_poly', 'q_poly', 'eh', 'mes', 'dbo5', 'tbentrant', 'welec']::varchar[], array['tbsortant_s']::varchar[], array['CO2 exploitation grilles_degouttage 3', 'tbentrant sechage_thermique 1', 'CO2 construction grilles_degouttage 1', 'CO2 construction grilles_degouttage 3', 'tbentrant flottateur 2', 'CO2 elec 6', 'CO2 exploitation q_poly tables_degouttage 6', 'CO2 construction grilles_degouttage 2']::varchar[]) ;

create sequence ___.grilles_degouttage_bloc_name_seq ;     




create table ___.grilles_degouttage_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('grilles_degouttage_bloc', abbreviation=>'grilles_degouttage'),
formula varchar[] default array['co2_e=feelec*tbsortant*welec_ge', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'co2_c=((feobj10_ge)*(eh<10000)+(feobj50_ge)*(eh>10000)*(eh<100000)+(feobj100_ge)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)*d_vie', 'co2_c=((feobj10_ge)*(eh<10000)+(feobj50_ge)*(eh>10000)*(eh<100000)+(feobj100_ge)*(eh>100000))*tbentrant*d_vie', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec', 'co2_e=0.001*q_poly*(1000*fepolymere + fetransp*transp_poly)', 'co2_c=((feobj10_ge)*(eh<10000)+(feobj50_ge)*(eh>10000)*(eh<100000)+(feobj100_ge)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)*d_vie']::varchar[],
formula_name varchar[] default array['CO2 exploitation grilles_degouttage 3', 'tbentrant sechage_thermique 1', 'CO2 construction grilles_degouttage 1', 'CO2 construction grilles_degouttage 3', 'tbentrant flottateur 2', 'CO2 elec 6', 'CO2 exploitation q_poly tables_degouttage 6', 'CO2 construction grilles_degouttage 2']::varchar[],
d_vie real default 15::real,
tbsortant real,
transp_poly real default 50::real,
q_poly real,
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
select api.add_new_formula('tbentrant sechage_thermique 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 construction grilles_degouttage 1'::varchar, 'co2_c=((feobj10_ge)*(eh<10000)+(feobj50_ge)*(eh>10000)*(eh<100000)+(feobj100_ge)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)*d_vie'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 construction grilles_degouttage 3'::varchar, 'co2_c=((feobj10_ge)*(eh<10000)+(feobj50_ge)*(eh>10000)*(eh<100000)+(feobj100_ge)*(eh>100000))*tbentrant*d_vie'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant flottateur 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 exploitation q_poly tables_degouttage 6'::varchar, 'co2_e=0.001*q_poly*(1000*fepolymere + fetransp*transp_poly)'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 construction grilles_degouttage 2'::varchar, 'co2_c=((feobj10_ge)*(eh<10000)+(feobj50_ge)*(eh>10000)*(eh<100000)+(feobj100_ge)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)*d_vie'::varchar, 2, ''::text) ;





alter type ___.bloc_type add value 'sechage_thermique' ;
commit ; 
insert into ___.input_output values ('sechage_thermique', array['siccite_e', 'd_vie', 'eh', 'pelletisation', 'tbsortant', 'mes', 'dbo5', 'tbentrant', 'tee', 'welec']::varchar[], array['siccite_s', 'tbsortant_s']::varchar[], array['CO2 construction sechage_thermique 1', 'CO2 construction sechage_thermique 3', 'CO2 construction sechage_thermique 2', 'CO2 exploitation sechage_thermique 3', 'tbentrant sechage_thermique 1', 'CO2 exploitation sechage_thermique 4', 'tbentrant flottateur 2', 'CO2 elec 6']::varchar[]) ;

create sequence ___.sechage_thermique_bloc_name_seq ;     




create table ___.sechage_thermique_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('sechage_thermique_bloc', abbreviation=>'sechage_thermique'),
formula varchar[] default array['co2_c=((feobj50_st)*(eh>10000)*(eh<100000)+(feobj100_st)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)*d_vie', 'co2_c=((feobj50_st)*(eh>10000)*(eh<100000)+(feobj100_st)*(eh>100000))*tbentrant*d_vie', 'co2_c=((feobj50_st)*(eh>10000)*(eh<100000)+(feobj100_st)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)*d_vie', 'co2_e=feelec*tbsortant*(24*nbjour*pth*(siccite_e - siccite_s) - welec_st_nopell*(pelletisation - 1) + welec_st_pell*pelletisation)', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'co2_e=feelec*(24*nbjour*pth*tee - tbsortant*(welec_st_nopell*(pelletisation - 1) - welec_st_pell*pelletisation))', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec']::varchar[],
formula_name varchar[] default array['CO2 construction sechage_thermique 1', 'CO2 construction sechage_thermique 3', 'CO2 construction sechage_thermique 2', 'CO2 exploitation sechage_thermique 3', 'tbentrant sechage_thermique 1', 'CO2 exploitation sechage_thermique 4', 'tbentrant flottateur 2', 'CO2 elec 6']::varchar[],
siccite_e real,
d_vie real default 15::real,
eh real,
pelletisation boolean default 0::boolean,
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

select api.add_new_formula('CO2 construction sechage_thermique 1'::varchar, 'co2_c=((feobj50_st)*(eh>10000)*(eh<100000)+(feobj100_st)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)*d_vie'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 construction sechage_thermique 3'::varchar, 'co2_c=((feobj50_st)*(eh>10000)*(eh<100000)+(feobj100_st)*(eh>100000))*tbentrant*d_vie'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 construction sechage_thermique 2'::varchar, 'co2_c=((feobj50_st)*(eh>10000)*(eh<100000)+(feobj100_st)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)*d_vie'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 exploitation sechage_thermique 3'::varchar, 'co2_e=feelec*tbsortant*(24*nbjour*pth*(siccite_e - siccite_s) - welec_st_nopell*(pelletisation - 1) + welec_st_pell*pelletisation)'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant sechage_thermique 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 exploitation sechage_thermique 4'::varchar, 'co2_e=feelec*(24*nbjour*pth*tee - tbsortant*(welec_st_nopell*(pelletisation - 1) - welec_st_pell*pelletisation))'::varchar, 4, ''::text) ;
select api.add_new_formula('tbentrant flottateur 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;





alter type ___.bloc_type add value 'cloture' ;
commit ; 
insert into ___.input_output values ('cloture', array['d_vie', 'ml']::varchar[], array[]::varchar[], array['CO2 construction cloture 2']::varchar[]) ;

create sequence ___.cloture_bloc_name_seq ;     




create table ___.cloture_bloc(
id integer primary key,
shape ___.geo_type not null default 'LineString',
geom geometry('LINESTRING', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('cloture_bloc', abbreviation=>'cloture'),
formula varchar[] default array['co2_c=feclot*ml']::varchar[],
formula_name varchar[] default array['CO2 construction cloture 2']::varchar[],
d_vie real default 100::real,
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
insert into ___.input_output values ('bassin_dorage', array['prod_e', 'd_vie', 'tauenterre', 'eh', 'h', 'e', 'tsejour', 'abatdco', 'abatngl', 'transp_rei', 'transp_naclo3', 'transp_phosphorique', 'q_h2o2', 'transp_citrique', 'q_oxyl', 'transp_javel', 'q_sulf_sod', 'q_sulf', 'q_anti_mousse', 'q_cl2', 'q_uree', 'q_chaux', 'q_catio', 'q_nahso3', 'transp_soude', 'q_hcl', 'q_kmno4', 'transp_anti_mousse', 'q_lait', 'transp_oxyl', 'transp_ca_regen', 'transp_uree', 'transp_sulf_alu', 'transp_nitrique', 'transp_ca_neuf', 'q_sable_t', 'q_soude_c', 'q_anio', 'q_soude', 'transp_nahso3', 'q_nitrique', 'q_naclo3', 'transp_kmno4', 'transp_h2o2', 'q_antiscalant', 'transp_chaux', 'q_phosphorique', 'transp_sulf_sod', 'q_javel', 'transp_mhetanol', 'transp_caco3', 'transp_antiscalant', 'transp_hcl', 'transp_ca_poudre', 'transp_ethanol', 'q_citrique', 'transp_soude_c', 'transp_coagl', 'q_ca_regen', 'q_poly', 'q_mhetanol', 'q_caco3', 'transp_lait', 'q_ca_poudre', 'q_rei', 'transp_catio', 'q_ca_neuf', 'transp_fecl3', 'transp_poly', 'transp_anio', 'q_co2l', 'transp_sable_t', 'q_coagl', 'transp_cl2', 'transp_co2l', 'transp_sulf', 'q_sulf_alu', 'q_ethanol', 'q_fecl3', 'dbo5elim', 'w_dbo5_eau', 'qe', 'dco', 'ntk', 'mes', 'dbo5', 'vu', 'welec']::varchar[], array['ngl_s', 'dco_s', 'qe_s']::varchar[], array['ngl_s decanteur_lamellaire 3', 'CO2 exploitation fpr 3', 'dco_s filiere_eau 3', 'CO2 construction bassin_cylindrique 3', 'dco_s filiere_eau 3', 'CO2 construction bassin_dorage 1', 'CO2 construction bassin_dorage 2', 'ngl_s decanteur_lamellaire 3', 'tbentrant sechage_thermique 1', 'tbentrant flottateur 2', 'CO2 elec 6', 'CO2 exploitation intrant clarificateur 6']::varchar[]) ;

create sequence ___.bassin_dorage_bloc_name_seq ;     




create table ___.bassin_dorage_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('bassin_dorage_bloc', abbreviation=>'bassin_dorage'),
formula varchar[] default array['ngl_s=eh*ntk_eh*(1 - abatngl)', 'co2_e=feelec*dbo5elim*w_dbo5_eau', 'dco_s=dco*(1 - abatdco)', 'co2_c=(febet*cad*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*fepelle*h*tauenterre*(h + e)*(0.3618*e + (vu/h)**0.5)**2 + 24.0*h*cad*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad)', 'dco_s=eh*dco_eh*(1 - abatdco)', 'co2_c=(febet*cad*e*rhobet*(24*eh*qe_eh*tsejour + 3.14159*h**2*(e + 5.52791*(eh*qe_eh*tsejour/h)**0.5)) + 24.0*fepelle*h*tauenterre*(h + e)*(0.3618*e + (eh*qe_eh*tsejour/h)**0.5)**2 + 24.0*h*cad*(0.3618*e + (eh*qe_eh*tsejour/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad)', 'co2_c=(febet*cad*e*rhobet*(3.14159*h**2*(e + 5.52791*(qe*tsejour/h)**0.5) + 24*qe*tsejour) + 24.0*fepelle*h*tauenterre*(h + e)*(0.3618*e + (qe*tsejour/h)**0.5)**2 + 24.0*h*cad*(0.3618*e + (qe*tsejour/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad)', 'ngl_s=ntk*(1 - abatngl)', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec', 'co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_co2l*(fetransp*transp_co2l + 1000*fe_co2l) + 0.001*q_coagl*(fetransp*transp_coagl + 1000*fe_coagl) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_fecl3*(fetransp*transp_fecl3 + 1000*fe_fecl3) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_javel*(fetransp*transp_javel + 1000*fe_javel) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_lait*(fetransp*transp_lait + 1000*fe_lait) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)']::varchar[],
formula_name varchar[] default array['ngl_s decanteur_lamellaire 3', 'CO2 exploitation fpr 3', 'dco_s filiere_eau 3', 'CO2 construction bassin_cylindrique 3', 'dco_s filiere_eau 3', 'CO2 construction bassin_dorage 1', 'CO2 construction bassin_dorage 2', 'ngl_s decanteur_lamellaire 3', 'tbentrant sechage_thermique 1', 'tbentrant flottateur 2', 'CO2 elec 6', 'CO2 exploitation intrant clarificateur 6']::varchar[],
prod_e ___.prod_e_type not null default 'Acide sulfurique' references ___.prod_e_type_table(val),
d_vie real default 50::real,
tauenterre real default 0.75::real,
eh real,
h real default 4::real,
e real default 0.25::real,
tsejour real default 1::real,
abatdco real,
abatngl real,
transp_rei real default 50::real,
transp_naclo3 real default 50::real,
transp_phosphorique real default 50::real,
q_h2o2 real,
transp_citrique real default 50::real,
q_oxyl real,
transp_javel real default 50::real,
q_sulf_sod real,
q_sulf real,
q_anti_mousse real,
q_cl2 real,
q_uree real,
q_chaux real,
q_catio real,
q_nahso3 real,
transp_soude real default 50::real,
q_hcl real,
q_kmno4 real,
transp_anti_mousse real default 50::real,
q_lait real,
transp_oxyl real default 50::real,
transp_ca_regen real default 50::real,
transp_uree real default 50::real,
transp_sulf_alu real default 50::real,
transp_nitrique real default 50::real,
transp_ca_neuf real default 50::real,
q_sable_t real,
q_soude_c real,
q_anio real,
q_soude real,
transp_nahso3 real default 50::real,
q_nitrique real,
q_naclo3 real,
transp_kmno4 real default 50::real,
transp_h2o2 real default 50::real,
q_antiscalant real,
transp_chaux real default 50::real,
q_phosphorique real,
transp_sulf_sod real default 50::real,
q_javel real,
transp_mhetanol real default 50::real,
transp_caco3 real default 50::real,
transp_antiscalant real default 50::real,
transp_hcl real default 50::real,
transp_ca_poudre real default 50::real,
transp_ethanol real default 50::real,
q_citrique real,
transp_soude_c real default 50::real,
transp_coagl real default 50::real,
q_ca_regen real,
q_poly real,
q_mhetanol real,
q_caco3 real,
transp_lait real default 50::real,
q_ca_poudre real,
q_rei real,
transp_catio real default 50::real,
q_ca_neuf real,
transp_fecl3 real default 50::real,
transp_poly real default 50::real,
transp_anio real default 50::real,
q_co2l real,
transp_sable_t real default 50::real,
q_coagl real,
transp_cl2 real default 50::real,
transp_co2l real default 50::real,
transp_sulf real default 50::real,
q_sulf_alu real,
q_ethanol real,
q_fecl3 real,
dbo5elim real,
w_dbo5_eau real,
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
    ,additional_columns => '{prod_e_type_table.FE as prod_e_FE, prod_e_type_table.description as prod_e_description}'
    ,additional_join => 'left join ___.prod_e_type_table on prod_e_type_table.val = c.prod_e ') ;

select api.add_new_formula('ngl_s decanteur_lamellaire 3'::varchar, 'ngl_s=eh*ntk_eh*(1 - abatngl)'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 exploitation fpr 3'::varchar, 'co2_e=feelec*dbo5elim*w_dbo5_eau'::varchar, 3, ''::text) ;
select api.add_new_formula('dco_s filiere_eau 3'::varchar, 'dco_s=dco*(1 - abatdco)'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 construction bassin_cylindrique 3'::varchar, 'co2_c=(febet*cad*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*fepelle*h*tauenterre*(h + e)*(0.3618*e + (vu/h)**0.5)**2 + 24.0*h*cad*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad)'::varchar, 3, ''::text) ;
select api.add_new_formula('dco_s filiere_eau 3'::varchar, 'dco_s=eh*dco_eh*(1 - abatdco)'::varchar, 3, ''::text) ;
select api.add_new_formula('CO2 construction bassin_dorage 1'::varchar, 'co2_c=(febet*cad*e*rhobet*(24*eh*qe_eh*tsejour + 3.14159*h**2*(e + 5.52791*(eh*qe_eh*tsejour/h)**0.5)) + 24.0*fepelle*h*tauenterre*(h + e)*(0.3618*e + (eh*qe_eh*tsejour/h)**0.5)**2 + 24.0*h*cad*(0.3618*e + (eh*qe_eh*tsejour/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad)'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 construction bassin_dorage 2'::varchar, 'co2_c=(febet*cad*e*rhobet*(3.14159*h**2*(e + 5.52791*(qe*tsejour/h)**0.5) + 24*qe*tsejour) + 24.0*fepelle*h*tauenterre*(h + e)*(0.3618*e + (qe*tsejour/h)**0.5)**2 + 24.0*h*cad*(0.3618*e + (qe*tsejour/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad)'::varchar, 2, ''::text) ;
select api.add_new_formula('ngl_s decanteur_lamellaire 3'::varchar, 'ngl_s=ntk*(1 - abatngl)'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant sechage_thermique 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('tbentrant flottateur 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 exploitation intrant clarificateur 6'::varchar, 'co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_co2l*(fetransp*transp_co2l + 1000*fe_co2l) + 0.001*q_coagl*(fetransp*transp_coagl + 1000*fe_coagl) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_fecl3*(fetransp*transp_fecl3 + 1000*fe_fecl3) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_javel*(fetransp*transp_javel + 1000*fe_javel) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_lait*(fetransp*transp_lait + 1000*fe_lait) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)'::varchar, 6, ''::text) ;





alter type ___.bloc_type add value 'filtre_a_bande' ;
commit ; 
insert into ___.input_output values ('filtre_a_bande', array['d_vie', 'transp_poly', 'q_poly', 'eh', 'mes', 'dbo5', 'tbentrant', 'welec']::varchar[], array['tbsortant_s']::varchar[], array['CO2 construction filtre_a_bande 1', 'CO2 construction filtre_a_bande 3', 'tbentrant sechage_thermique 1', 'tbentrant flottateur 2', 'CO2 elec 6', 'CO2 construction filtre_a_bande 2', 'CO2 exploitation q_poly tables_degouttage 6']::varchar[]) ;

create sequence ___.filtre_a_bande_bloc_name_seq ;     




create table ___.filtre_a_bande_bloc(
id integer primary key,
shape ___.geo_type not null default 'Point',
geom geometry('POINT', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('filtre_a_bande_bloc', abbreviation=>'filtre_a_bande'),
formula varchar[] default array['co2_c=((feobj10_fb)*(eh<10000)+(feobj50_fb)*(eh>10000)*(eh<100000)+(feobj100_fb)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)*d_vie', 'co2_c=((feobj10_fb)*(eh<10000)+(feobj50_fb)*(eh>10000)*(eh<100000)+(feobj100_fb)*(eh>100000))*tbentrant*d_vie', 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)', 'tbentrant=0.0005*nbjour*(dbo5 + mes)', 'co2_e=feelec*welec', 'co2_c=((feobj10_fb)*(eh<10000)+(feobj50_fb)*(eh>10000)*(eh<100000)+(feobj100_fb)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)*d_vie', 'co2_e=0.001*q_poly*(1000*fepolymere + fetransp*transp_poly)']::varchar[],
formula_name varchar[] default array['CO2 construction filtre_a_bande 1', 'CO2 construction filtre_a_bande 3', 'tbentrant sechage_thermique 1', 'tbentrant flottateur 2', 'CO2 elec 6', 'CO2 construction filtre_a_bande 2', 'CO2 exploitation q_poly tables_degouttage 6']::varchar[],
d_vie real default 15::real,
transp_poly real default 50::real,
q_poly real,
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

select api.add_new_formula('CO2 construction filtre_a_bande 1'::varchar, 'co2_c=((feobj10_fb)*(eh<10000)+(feobj50_fb)*(eh>10000)*(eh<100000)+(feobj100_fb)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)*d_vie'::varchar, 1, ''::text) ;
select api.add_new_formula('CO2 construction filtre_a_bande 3'::varchar, 'co2_c=((feobj10_fb)*(eh<10000)+(feobj50_fb)*(eh>10000)*(eh<100000)+(feobj100_fb)*(eh>100000))*tbentrant*d_vie'::varchar, 3, ''::text) ;
select api.add_new_formula('tbentrant sechage_thermique 1'::varchar, 'tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)'::varchar, 1, ''::text) ;
select api.add_new_formula('tbentrant flottateur 2'::varchar, 'tbentrant=0.0005*nbjour*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 elec 6'::varchar, 'co2_e=feelec*welec'::varchar, 6, ''::text) ;
select api.add_new_formula('CO2 construction filtre_a_bande 2'::varchar, 'co2_c=((feobj10_fb)*(eh<10000)+(feobj50_fb)*(eh>10000)*(eh<100000)+(feobj100_fb)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)*d_vie'::varchar, 2, ''::text) ;
select api.add_new_formula('CO2 exploitation q_poly tables_degouttage 6'::varchar, 'co2_e=0.001*q_poly*(1000*fepolymere + fetransp*transp_poly)'::varchar, 6, ''::text) ;



update ___.festock_type_table set fe = 0.0052, incert = 0.0, description = 'silo de 500m3 [10]' where val = 'Silo de 500m3' ;
update ___.methode_type_table set fe = 6.5, incert = 0.0, description = 'kgCO2eq/kgDBO5 eliminé [3]' where val = 'MBBR' ;
update ___.methode_2_type_table set fe = 0.0006, incert = 0.5, description = 'kgN2O/NTK eliminé [2]' where val = 'Boues activées' ;
update ___.festock_type_table set fe = 0.0352, incert = 0.0, description = 'kgCO2eq/tMS silo de 5m3 [10]' where val = 'Silo de 5m3' ;
update ___.fen2o_oxi_type_table set fe = 0.0007, incert = 0.45, description = 'kgN2O/kgNGL rejeté [2] Bien oxygéné' where val = 'Bien oxygéné' ;
update ___.fen2o_oxi_type_table set fe = 0.0034, incert = 0.45, description = 'kgN2O/kgNGL rejeté [2] peu oxygéné (par défault)' where val = 'Peu oxygéné' ;
update ___.methode_type_table set fe = 4.6, incert = 0.0, description = 'kgCO2eq/kgDBO5 eliminé [3]' where val = 'SBR' ;
update ___.methode_type_table set fe = 3.2, incert = 0.0, description = 'kgCO2eq/kgDBO5 eliminé [3]' where val = 'Boues activées' ;
update ___.methode_type_table set fe = 4.5, incert = 0.0, description = 'kgCO2eq/kgDBO5 eliminé [3] demandé données pour incertitude ' where val = 'Biofiltres' ;
update ___.qdechet_type_table set fe = 2.33, incert = 0.7, description = 'L/EH/an sans compactage [1]' where val = 'Sans compactage' ;
update ___.qdechet_type_table set fe = 0.99, incert = 0.4, description = 'compactage piston [1]' where val = 'Compactage avec piston' ;
update ___.methode_type_table set fe = 6.8, incert = 0.0, description = 'kgCO2eq/kgDBO5 eliminé [3]' where val = 'BRM' ;
update ___.festock_type_table set fe = 0.0067, incert = 0.0, description = 'silo de 250m3 [10]' where val = 'Silo de 250m3' ;
update ___.charge_bio_type_table set fe = 1.1, incert = 0.35, description = 'kgDBO5/m3/j charge moyenne [11]' where val = 'Charge moyenne' ;
update ___.fech4_mil_type_table set fe = 0.009, incert = 0.3, description = 'kgCH4/kgDCO rejeté [2] autres' where val = 'Autres' ;
update ___.charge_bio_type_table set fe = 2.25, incert = 0.35, description = 'kgDBO5/m3/j charge élevé [11]' where val = 'Charge élevée' ;
update ___.qdechet_type_table set fe = 1.12, incert = 0.5, description = 'compactage avec vis [1]' where val = 'Compactage avec vis' ;
update ___.fech4_mil_type_table set fe = 0.048, incert = 0.3, description = 'kgCH4/kgDCO rejeté [2] réservoirs, lac, estuaires' where val = 'Réservoirs, lac, estuaires' ;
update ___.methode_2_type_table set fe = 0.0165, incert = 0.15, description = 'kgN2O/NTK eliminé [2]' where val = 'Biofiltres' ;
update ___.feexpl_type_table set fe = 825.0, incert = 0.0, description = 'kgCO2eq/m2 [8]' where val = 'Structure en béton' ;
update ___.charge_bio_type_table set fe = 0.5, incert = 0.35, description = 'kgDBO5/m3/j charge faible [11]' where val = 'Charge faible' ;
update ___.feexpl_type_table set fe = 275.0, incert = 0.0, description = '' where val = 'Structure métallique' ;


insert into ___.global_values(name, val, incert, comment) values ('fe_nahso3', 416.0, 0.3, '') ;
insert into ___.global_values(name, val, incert, comment) values ('welec_fp', 30.0, 0.3, 'kWh/m3 [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('fe_cl2', 740.0, 0.3, '') ;
insert into ___.global_values(name, val, incert, comment) values ('fecurage_desob', 12.0, 0.5, 'kgCO2eq/km[2]') ;
insert into ___.global_values(name, val, incert, comment) values ('fe_naclo3', 46.0, 0.3, '') ;
insert into ___.global_values(name, val, incert, comment) values ('cad', 125.0, 0.0, 'm3/h') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj10_ge', 0.0021, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('fefiltre_memb', 5.5, 0.0, 'kgCO2eq/kg') ;
insert into ___.global_values(name, val, incert, comment) values ('munite_tamis', 610.0, 0.25, 'tamis à tambour') ;
insert into ___.global_values(name, val, incert, comment) values ('w_dbo5_eau', 5.0, 0.3, 'kWh/kDBO5 élim affiné les valeurs en allant chercher dans les données de base [3]') ;
insert into ___.global_values(name, val, incert, comment) values ('fe_lspr_n2o', 0.033, 0.0, 'kgN2O/EH/an [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('csables', 0.00104, 0.5, 't/EH/an tonnage de déchets sableux [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('q_poly_te', 5.0, 0.0, 'kg [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('fe_poly', 805.0, 0.3, '') ;
insert into ___.global_values(name, val, incert, comment) values ('fecompost', 2.892, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('welec_compost', 160.0, 0.8, 'kWh/tMS [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj50_ss', 3.9359, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('qdechet_tamis_comp', 4.0, 0.5, 'L/EH/an sans compactage') ;
insert into ___.global_values(name, val, incert, comment) values ('welec_da', 500.0, 0.0, '[10] kWh/tMS') ;
insert into ___.global_values(name, val, incert, comment) values ('fegazole', 3.1, 0.0, 'kgCO2eq/L [8]') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj10_cc', 0.0023, 0.0, 'kgCO2eq/tMS cuve pour conditionnement chimique [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('fe_phosphorique', 1420.0, 0.5, '') ;
insert into ___.global_values(name, val, incert, comment) values ('n2o_biofiltre', 0.0165, 0.15, 'kgN2O/kgNTK [2] Emission d''azote dans les biofiltres nitrifiants ') ;
insert into ___.global_values(name, val, incert, comment) values ('fe_caco3', 75.0, 0.5, '') ;
insert into ___.global_values(name, val, incert, comment) values ('sables_nlavé', 0.00163, 0.0, 't/EH/an tonnage de sables récupérer sans lavage [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('fe_uree', 4253.0, 0.3, 'Attention ici faudrait vérifier ce qu''implique l''asterix dans le guide de l''astee (est ce qu''il faut multiplier par 2 ?)') ;
insert into ___.global_values(name, val, incert, comment) values ('fe_ca_poudre', 10451.0, 0.95, '') ;
insert into ___.global_values(name, val, incert, comment) values ('fe_mhetanol', 521.0, 0.5, '') ;
insert into ___.global_values(name, val, incert, comment) values ('fepehd', 1.92, 0.0, 'kgCO2eq/kg [7]') ;
insert into ___.global_values(name, val, incert, comment) values ('fe_sulf_alu', 128.0, 0.3, '') ;
insert into ___.global_values(name, val, incert, comment) values ('fe_antiscalant', 2000.0, 0.3, '') ;
insert into ___.global_values(name, val, incert, comment) values ('fe_sulf', 148.0, 0.5, '') ;
insert into ___.global_values(name, val, incert, comment) values ('fe_sulf_sod', 473.0, 1.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('sables_lavé', 0.00131, 0.0, 't/EH/an tonnage de sables récupérer si lavage [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('dgraisses', 0.9, 0.1, 'densité des graisses [1]') ;
insert into ___.global_values(name, val, incert, comment) values ('fetraitement_c', 0.03, 0.5, 'kgCO2eq/m3') ;
insert into ___.global_values(name, val, incert, comment) values ('lgraisses_c', 0.00159, 3.0, 'kL/EH/an milliers de litres de graisses concentrées par eh par an [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('fepolymere', 0.805, 0.3, 'kgCO2eq/kg  [2]') ;
insert into ___.global_values(name, val, incert, comment) values ('fe_ethanol', 1470.0, 0.25, '') ;
insert into ___.global_values(name, val, incert, comment) values ('fesilo_petit', 0.12, 0.0, 'kgCH4/kgDBO silo de moins de 2 mètre [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj100_ch', 0.1219, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('felam', 3.6, 0.0, 'kgCO2eq/kg [8]') ;
insert into ___.global_values(name, val, incert, comment) values ('mes_eh', 0.09, 0.0, 'kg/j') ;
insert into ___.global_values(name, val, incert, comment) values ('fedec_nd', 22.04, 0.2, 'kgCO2eq/t [13]') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj100_ss', 3.3911, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('fecurage_cur', 53.0, 0.5, 'kgCO2eq/km[2]') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj100_cd', 0.1347, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('welec_st_pell', 62.5, 0.05, 'kWh/tee [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('fe_lait', 241.0, 0.3, 'Lait de chaux') ;
insert into ___.global_values(name, val, incert, comment) values ('fefile_eau', 0.0002, 0.3, 'kgCH4/DCO eliminé [2]') ;
insert into ___.global_values(name, val, incert, comment) values ('fe_h2o2', 469.0, 0.3, '') ;
insert into ___.global_values(name, val, incert, comment) values ('fe_catio', 1395.0, 0.3, '') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj100_te', 0.0018, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('fe_sable_t', 2.0, 0.3, '') ;
insert into ___.global_values(name, val, incert, comment) values ('fe_soude', 364.0, 0.5, '') ;
insert into ___.global_values(name, val, incert, comment) values ('nbjour', 365.0, 0.0, 'Nombre de jour d''activité d''une step par an') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj100_cc', 0.0007, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj100_st', 13.6647, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('fecationique', 1.395, 0.3, '[2] résine cathionique') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj50_st', 26.4856, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('fedec_bois', 5.12, 0.18, 'kgCO2eq/t [13]') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj50_fb', 0.0257, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('welec_cc', 225.0, 0.33, 'kgCO2eq/m3 boue [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj10_cd', 0.1296, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('fedec_surface', 40.0, 0.0, 'kgcO2eq/m2 [14]') ;
insert into ___.global_values(name, val, incert, comment) values ('munite_degrilleur', 925.0, 0.6, 'kg fixé par rapport au NG de FB procédés') ;
insert into ___.global_values(name, val, incert, comment) values ('fepelle', 61.0, 0.0, 'kgco2eq/h [7]') ;
insert into ___.global_values(name, val, incert, comment) values ('welec_ge', 115.0, 0.0, '[10] kWh/tMS') ;
insert into ___.global_values(name, val, incert, comment) values ('welec_cd', 60.0, 0.5, 'kWh/m3 [10] pour une non direct ') ;
insert into ___.global_values(name, val, incert, comment) values ('feelec', 0.052, 0.2, 'kgCO2eq/kWh électrique [9]') ;
insert into ___.global_values(name, val, incert, comment) values ('gazole_compost', 10.0, 0.0, 'L/tMS [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('rhobit', 2.35, 0.0, 't/m3 [plusieurs sources qui se recoupent]') ;
insert into ___.global_values(name, val, incert, comment) values ('fe_ca_neuf', 10514.0, 0.6, '') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj50_es', 0.0109, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj10_da', 0.0228, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('rhoterre', 1.5, 0.0, 't/m3 ') ;
insert into ___.global_values(name, val, incert, comment) values ('fe_lspr_ch4', 0.034, 0.0, 'kgCH4/EH/an  [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj10_es', 0.0245, 0.0, '[10] kgCO2eq/tMS même chose pour tout ce qui suit si non précisé') ;
insert into ___.global_values(name, val, incert, comment) values ('fe_citrique', 1000.0, 0.3, '') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj50_ch', 0.1611, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('fechaux', 1.032, 0.3, 'kgCO2eq/kg [2] chaux vive') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj100_da', 0.0102, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('tau_fuite', 0.1245, 0.3, '[2]') ;
insert into ___.global_values(name, val, incert, comment) values ('fecurage_prev', 42.0, 0.5, 'kgCO2eq/km[2]') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj50_ge', 0.0011, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('fe_anti_mousse', 40.0, 0.3, '') ;
insert into ___.global_values(name, val, incert, comment) values ('fefecl3', 0.33, 0.3, 'kgCO2eq/kg[2]') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj50_flot', 0.0062, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('fe_nitrique', 3180.0, 1.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj10_ch', 0.5875, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('welec_flot', 33.0, 0.0, '[10] kWh/tMS') ;
insert into ___.global_values(name, val, incert, comment) values ('febranche', 420.0, 0.95, 'kgCO2eq/ml [2]') ;
insert into ___.global_values(name, val, incert, comment) values ('rhoco2', 1.87, 0.0, 'kg/m3') ;
insert into ___.global_values(name, val, incert, comment) values ('fe_hcl', 1200.0, 0.5, 'kgCO2eq/t [2]') ;
insert into ___.global_values(name, val, incert, comment) values ('qmax_tamis', 270.0, 0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj100_flot', 0.0048, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj100_ce', 0.1363, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj10_fp', 0.2674, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('fe_kmno4', 1151.0, 0.5, '') ;
insert into ___.global_values(name, val, incert, comment) values ('welec_ct', 65.0, 0.5, 'kWh/m3 [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj50_ce', 0.0759, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('fe_oxyl', 408.0, 0.3, '') ;
insert into ___.global_values(name, val, incert, comment) values ('welec_te', 174.0, 0.0, '[10] kWh/tMS') ;
insert into ___.global_values(name, val, incert, comment) values ('fesilo_grand', 0.4, 0.0, 'kgCH4/kgDBO silo de plus de 2 mètre [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('fe_fecl3', 330.0, 0.3, '') ;
insert into ___.global_values(name, val, incert, comment) values ('pth', 1000.0, 0.1, 'kW/tee [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj_dan', 0.0062, 0.0, 'digestion anaérobie kgCO2eq/m3 biogaz produit [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('fe_ca_regen', 1320.0, 0.5, '') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj100_ge', 0.0012, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('lgraisses_nc', 0.00955, 3.0, 'kL/EH/an milliers de litres de graisses non concentrées par eh par an [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('feclot', 168.0, 0.0, 'kgCO2eq/ml [6]') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj10_te', 0.0044, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj10_flot', 0.0117, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('fedec_met', 4.31, 0.2, 'kgCO2eq/t [13]') ;
insert into ___.global_values(name, val, incert, comment) values ('welec_dan', 125.0, 0.6, '[10] kWh/tMS') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj50_te', 0.0022, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('welec_st_nopell', 105.0, 0.05, 'kWh/tee [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('fedec_inerte', 5.58, 0.14, 'kgCO2eq/t [13]') ;
insert into ___.global_values(name, val, incert, comment) values ('rholam', 1040.0, 0.0, 'kg/m3 [3]') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj100_fp', 0.4943, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj50_cd', 0.0735, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('p_eh', 0.004, 0.0, 'kg/j') ;
insert into ___.global_values(name, val, incert, comment) values ('fetraitement_e', 0.39, 0.5, 'kgCO2eq/m3') ;
insert into ___.global_values(name, val, incert, comment) values ('ntk_eh', 0.015, 0.0, 'kg/j') ;
insert into ___.global_values(name, val, incert, comment) values ('fe_lspr_co2', 0.0056, 0.0, 'kgCO2/EH/an [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('qdechet_tamis_ncomp', 8.0, 0.5, 'L/EH/an avec compactage (moyenne arbitraire incertitudes dégrillages)') ;
insert into ___.global_values(name, val, incert, comment) values ('fedechet_stock', 0.692, 0.5, 'kgco2eq/kg, [2] quand est ce qu''on stock ?') ;
insert into ___.global_values(name, val, incert, comment) values ('qmax_degrilleur', 6000.0, 0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('fegeom', 0.45, 0.0, 'kgCO2/m2 [7]') ;
insert into ___.global_values(name, val, incert, comment) values ('rhobet', 2.4, 0.0, 't/m3 ') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj10_ce', 0.1296, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('fe_coagl', 460.0, 0.3, '') ;
insert into ___.global_values(name, val, incert, comment) values ('rhometha', 0.657, 0.0, 'kg/m3') ;
insert into ___.global_values(name, val, incert, comment) values ('fefonda', 80.0, 0.0, 'kgCO2eq/m2 [7]') ;
insert into ___.global_values(name, val, incert, comment) values ('dco_eh', 0.135, 0.0, 'kg/j') ;
insert into ___.global_values(name, val, incert, comment) values ('ferep_branche_t', 400.0, 0.95, 'kgCO2eq/ml [2]') ;
insert into ___.global_values(name, val, incert, comment) values ('fedec_bet', 1.21, 0.2, 'kgCO2eq/t [13]') ;
insert into ___.global_values(name, val, incert, comment) values ('fe_co2l', 50.0, 0.3, '') ;
insert into ___.global_values(name, val, incert, comment) values ('fetransp', 0.145, 0.3, 'kgCO2eq/t/km') ;
insert into ___.global_values(name, val, incert, comment) values ('ch4_compost', 2.9, 1.5, 'kgCH4/t déchets [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('feanionique', 3.927, 0.3, '[2] résine anionique') ;
insert into ___.global_values(name, val, incert, comment) values ('ferep_branche', 7.0, 0.3, 'kgCO2eq/ml [2]') ;
insert into ___.global_values(name, val, incert, comment) values ('ferep_cana', 400.0, 0.95, 'kgCO2eq/ml[2]') ;
insert into ___.global_values(name, val, incert, comment) values ('fe_soude_c', 1052.0, 0.3, '') ;
insert into ___.global_values(name, val, incert, comment) values ('ch4_eau', 0.0002, 0.3, 'kgCH4/kgDCO [2] Emission de méthane dans la file eau') ;
insert into ___.global_values(name, val, incert, comment) values ('welec_fb', 5.0, 0.0, 'kWh/m3 [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj50_ct', 0.1572, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj10_fb', 0.0679, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj50_cc', 0.0009, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('rhodechet', 0.96, 0.65, '[1]') ;
insert into ___.global_values(name, val, incert, comment) values ('fe_rei', 6700.0, 0.3, '') ;
insert into ___.global_values(name, val, incert, comment) values ('fedec_platre', 15.69, 0.16, 'kgCO2eq/t [13]') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj100_es', 0.0096, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('fe_anio', 3927.0, 0.3, '') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj50_fp', 0.2103, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('fevoirie', 53.0, 0.2, 'kgCO2eq/t bitume [2]') ;
insert into ___.global_values(name, val, incert, comment) values ('fedechet', 0.045, 0.5, 'kgco2eq/kg facteur d''émissions des déchets émis par les dégrilleurs et tamis [2]') ;
insert into ___.global_values(name, val, incert, comment) values ('febet', 155.0, 0.2, 'kgco2eq/t [2]') ;
insert into ___.global_values(name, val, incert, comment) values ('n2o_compost', 0.65, 0.8, 'kgN2O/t déchets [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('fepoids', 5.5, 0.5, 'kgCO2eq/kg [2] facteur d''émission machines') ;
insert into ___.global_values(name, val, incert, comment) values ('vol_ms', 225.0, 0.45, '[12] m3CH4/tMS') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj100_ct', 0.0817, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('fesables', 0.013, 0.26, 'kgco2eq/kg [2]') ;
insert into ___.global_values(name, val, incert, comment) values ('feevac', 5.4, 0.0, 'kgco2eq/t de terre évacuée [6][7]') ;
insert into ___.global_values(name, val, incert, comment) values ('welec_es', 10.0, 0.0, '[10] kWh/tMS') ;
insert into ___.global_values(name, val, incert, comment) values ('fesilo_aere', 5.0, 0.0, 'kWh/tMS silo aéré [10]') ;
insert into ___.global_values(name, val, incert, comment) values ('welec_direct', 160.0, 0.2, 'kWh/m3 [10] pour une direct') ;
insert into ___.global_values(name, val, incert, comment) values ('dbo5_eh', 0.06, 0.0, 'kg/j') ;
insert into ___.global_values(name, val, incert, comment) values ('qe_eh', 0.12, 0.0, 'm3/j') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj10_ss', 7.6227, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('fe_chaux', 1032.0, 0.3, '') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj50_da', 0.0126, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('n2o_boue_act', 0.0006, 0.5, '') ;
insert into ___.global_values(name, val, incert, comment) values ('feobj100_fb', 0.0553, 0.0, '') ;
insert into ___.global_values(name, val, incert, comment) values ('fe_javel', 920.0, 1.0, '') ;
