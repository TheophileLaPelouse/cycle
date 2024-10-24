update api.tsejour_type_table set fe = 0.0833, description = 'kgDBO5/m3/j' where val = 'Faible charge' ;
update api.tsejour_type_table set fe = 0.20833, description = 'kgDBO5/m3/j' where val = 'Moyenne charge' ;
update api.tsejour_type_table set fe = 0.417, description = 'kgDBO5/m3/j' where val = 'Forte charge' ;
update api.oxi_type_table set fe = 3.03, description = 'kgNO2/kgNGL pour un milieu bien oxygéné (concentration en O2 supérieu à 3 mg/L)' where val = 'bien oxygéné' ;
update api.oxi_type_table set fe = 1.46, description = 'kgNO2/kgNGL pour un milieu peu oxygéné (concentration en O2 entre 0.1 et 3 mg/L)' where val = 'peu oxygéné' ;
update api.milieu_type_table set fe = 0.2682, description = '' where val = 'réserve,lac, estuaire' ;
update api.milieu_type_table set fe = 1.4304, description = '' where val = 'autres' ;


alter type ___.bloc_type add value 'dessableurdegraisseur' ;
commit ; 
insert into ___.input_output values ('dessableurdegraisseur', array['eh', 'vit', 'vu', 'e', 'cad', 'h', 'taur', 'tauenterre', 'qe']::varchar[], array['qe_s']::varchar[], array['Bassin vitesse construction niveau 2', 'Bassin dimension construction niveau 3', 'sables et graisses exploitation niveau 1', 'Sables et graisses exploitation débit', 'sables et graisses exploitation niveau 3', 'Bassin vitesse construction niveau 1', 'centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[]) ;

create sequence ___.dessableurdegraisseur_bloc_name_seq ;     




create table ___.dessableurdegraisseur_bloc(
id integer primary key,
shape ___.geo_type not null default ''Point'::___.geo_type',
geom geometry(''POINT'::___.GEO_TYPE', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('dessableurdegraisseur_bloc', abbreviation=>'dessableurdegraisseur_bloc'),
formula varchar[] default array['co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_e = eh*(432.0338 - 0.0221*lavage)', 'co2_e = qe*(7200.56333 - 0.36833*lavage)', 'co2_e = qe*(720.0*cgraisses + 216.66667*csables)', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant']::varchar[],
formula_name varchar[] default array['Bassin vitesse construction niveau 2', 'Bassin dimension construction niveau 3', 'sables et graisses exploitation niveau 1', 'Sables et graisses exploitation débit', 'sables et graisses exploitation niveau 3', 'Bassin vitesse construction niveau 1', 'centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[],
eh real,
vit real default 20,
vu real,
e real default 0.25,
cad real default 125,
h real default 5,
taur real default 1,
tauenterre real default 0.75,
qe real,
qe_s real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.dessableurdegraisseur_bloc_config(
    like ___.dessableurdegraisseur_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.dessableurdegraisseur_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('dessableurdegraisseur', 'bloc', ''Point'' 
    
    ) ;

select api.add_new_formula('Bassin vitesse construction niveau 2'::varchar, 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit'::varchar, 2, ''::text) ;
select api.add_new_formula('Bassin dimension construction niveau 3'::varchar, 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h'::varchar, 3, ''::text) ;
select api.add_new_formula('sables et graisses exploitation niveau 1'::varchar, 'co2_e = eh*(432.0338 - 0.0221*lavage)'::varchar, 1, ''::text) ;
select api.add_new_formula('Sables et graisses exploitation débit'::varchar, 'co2_e = qe*(7200.56333 - 0.36833*lavage)'::varchar, 2, ''::text) ;
select api.add_new_formula('sables et graisses exploitation niveau 3'::varchar, 'co2_e = qe*(720.0*cgraisses + 216.66667*csables)'::varchar, 3, ''::text) ;
select api.add_new_formula('Bassin vitesse construction niveau 1'::varchar, 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit'::varchar, 1, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 1'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000'::varchar, 1, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 2'::varchar, 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000'::varchar, 2, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 3'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant'::varchar, 3, ''::text) ;





alter type ___.bloc_type add value 'degrilleur' ;
commit ; 
insert into ___.input_output values ('degrilleur', array[]::varchar[], array[]::varchar[], array['machine construction débit max niveau 1', 'machine construction débit max niveau 2', 'degrilleur exploitation niveau 1', 'degrilleur exploitation niveau 2', 'degrilleur exploitation niveau 3', 'Bassin vitesse construction niveau 1', 'Bassin vitesse construction niveau 2', 'Bassin dimension construction niveau 3', 'centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[]) ;

create sequence ___.degrilleur_bloc_name_seq ;     




create table ___.degrilleur_bloc(
id integer primary key,
shape ___.geo_type not null default ''Point'::___.geo_type',
geom geometry(''POINT'::___.GEO_TYPE', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('degrilleur_bloc', abbreviation=>'degrilleur_bloc'),
formula varchar[] default array['co2_c = 0.12*eh*fepoids*munite/qmax\n', 'co2_c = fepoids*munite*qe/qmax\n', 'co2_e = 0.3024*eh', 'co2_e = 5.04*qe\n', 'co2_e = qe*(0.36*compd*gros - 1.44*compd - 2.88*gros + 5.04)\n', 'co2_c = 0.12*eh*fepoids*munite/qmax\n', 'co2_c = fepoids*munite*qe/qmax\n', 'co2_e = 0.3024*eh', 'co2_e = 5.04*qe\n', 'co2_e = qe*(0.36*compd*gros - 1.44*compd - 2.88*gros + 5.04)\n', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant']::varchar[],
formula_name varchar[] default array['machine construction débit max niveau 1', 'machine construction débit max niveau 2', 'degrilleur exploitation niveau 1', 'degrilleur exploitation niveau 2', 'degrilleur exploitation niveau 3', 'Bassin vitesse construction niveau 1', 'Bassin vitesse construction niveau 2', 'Bassin dimension construction niveau 3', 'centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[],

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.degrilleur_bloc_config(
    like ___.degrilleur_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.degrilleur_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('degrilleur', 'bloc', ''Point'' 
    
    ) ;

select api.add_new_formula('machine construction débit max niveau 1'::varchar, 'co2_c = 0.12*eh*fepoids*munite/qmax
'::varchar, 1, ''::text) ;
select api.add_new_formula('machine construction débit max niveau 2'::varchar, 'co2_c = fepoids*munite*qe/qmax
'::varchar, 2, ''::text) ;
select api.add_new_formula('degrilleur exploitation niveau 1'::varchar, 'co2_e = 0.3024*eh'::varchar, 1, ''::text) ;
select api.add_new_formula('degrilleur exploitation niveau 2'::varchar, 'co2_e = 5.04*qe
'::varchar, 2, ''::text) ;
select api.add_new_formula('degrilleur exploitation niveau 3'::varchar, 'co2_e = qe*(0.36*compd*gros - 1.44*compd - 2.88*gros + 5.04)
'::varchar, 3, ''::text) ;
select api.add_new_formula('Bassin vitesse construction niveau 1'::varchar, 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit'::varchar, 1, ''::text) ;
select api.add_new_formula('Bassin vitesse construction niveau 2'::varchar, 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit'::varchar, 2, ''::text) ;
select api.add_new_formula('Bassin dimension construction niveau 3'::varchar, 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h'::varchar, 3, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 1'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000'::varchar, 1, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 2'::varchar, 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000'::varchar, 2, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 3'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant'::varchar, 3, ''::text) ;





alter type ___.bloc_type add value 'methanisation' ;
commit ; 
insert into ___.input_output values ('methanisation', array['eh', 'dbo5', 'mes', 'vbiogaz', 'tau_fuite', 'tau_ch4', 'tau_co2', 'tau_abattement']::varchar[], array['tbsortant']::varchar[], array['methanisation exploitation co2 niveau 1', 'methanisation exploitation ch4 niveau 1', 'methanisation exploitation co2 niveau 2', 'methanisation exploitation ch4 niveau 2', 'methanisation exploitation co2 niveau 3', 'methanisation exploitation ch4 niveau 3', 'methanisation exploitation co2 niveau 4', 'methanisation exploitation ch4 niveau 4', 'centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[]) ;

create sequence ___.methanisation_bloc_name_seq ;     




create table ___.methanisation_bloc(
id integer primary key,
shape ___.geo_type not null default ''Point'::___.geo_type',
geom geometry(''POINT'::___.GEO_TYPE', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('methanisation_bloc', abbreviation=>'methanisation_bloc'),
formula varchar[] default array['co2_e = 0.03156*eh*tau_abattement*tau_co2', 'ch4_e = 0.01109*eh*tau_abattement*tau_fuite', 'co2_e = 0.21038*tau_abattement*tau_co2*(dbo5 + mes)', 'ch4_e = 0.07391*tau_abattement*tau_fuite*(dbo5 + mes)', 'co2_e = 420.75*tbsortant*tauco2', 'ch4_e = 147.825*tbsortant*tau_fuite', 'co2_e = 420.75*tbsortant*tauco2', 'co2_e = 1.87*vbiogaz*tau_co2\n', 'ch4_e = 0.657*vbiogaz*tau_fuite\n', 'co2_e = 0.03156*eh*tau_abattement*tau_co2', 'ch4_e = 0.01109*eh*tau_abattement*tau_fuite', 'co2_e = 0.21038*tau_abattement*tau_co2*(dbo5 + mes)', 'ch4_e = 0.07391*tau_abattement*tau_fuite*(dbo5 + mes)', 'co2_e = 420.75*tbsortant*tauco2', 'ch4_e = 147.825*tbsortant*tau_fuite', 'co2_e = 420.75*tbsortant*tauco2', 'co2_e = 1.87*vbiogaz*tau_co2\n', 'ch4_e = 0.657*vbiogaz*tau_fuite\n', 'co2_e = 0.03156*eh*tau_abattement*tau_co2', 'ch4_e = 0.01109*eh*tau_abattement*tau_fuite', 'co2_e = 0.21038*tau_abattement*tau_co2*(dbo5 + mes)', 'ch4_e = 0.07391*tau_abattement*tau_fuite*(dbo5 + mes)', 'co2_e = 420.75*tbsortant*tauco2', 'ch4_e = 147.825*tbsortant*tau_fuite', 'co2_e = 420.75*tbsortant*tauco2', 'co2_e = 1.87*vbiogaz*tau_co2\n', 'ch4_e = 0.657*vbiogaz*tau_fuite\n', 'co2_e = 0.03156*eh*tau_abattement*tau_co2', 'ch4_e = 0.01109*eh*tau_abattement*tau_fuite', 'co2_e = 0.21038*tau_abattement*tau_co2*(dbo5 + mes)', 'ch4_e = 0.07391*tau_abattement*tau_fuite*(dbo5 + mes)', 'co2_e = 420.75*tbsortant*tauco2', 'ch4_e = 147.825*tbsortant*tau_fuite', 'co2_e = 420.75*tbsortant*tauco2', 'co2_e = 1.87*vbiogaz*tau_co2\n', 'ch4_e = 0.657*vbiogaz*tau_fuite\n', 'co2_e = 0.03156*eh*tau_abattement*tau_co2', 'ch4_e = 0.01109*eh*tau_abattement*tau_fuite', 'co2_e = 0.21038*tau_abattement*tau_co2*(dbo5 + mes)', 'ch4_e = 0.07391*tau_abattement*tau_fuite*(dbo5 + mes)', 'co2_e = 420.75*tbsortant*tauco2', 'ch4_e = 147.825*tbsortant*tau_fuite', 'co2_e = 420.75*tbsortant*tauco2', 'co2_e = 1.87*vbiogaz*tau_co2\n', 'ch4_e = 0.657*vbiogaz*tau_fuite\n', 'co2_e = 0.03156*eh*tau_abattement*tau_co2', 'ch4_e = 0.01109*eh*tau_abattement*tau_fuite', 'co2_e = 0.21038*tau_abattement*tau_co2*(dbo5 + mes)', 'ch4_e = 0.07391*tau_abattement*tau_fuite*(dbo5 + mes)', 'co2_e = 420.75*tbsortant*tauco2', 'ch4_e = 147.825*tbsortant*tau_fuite', 'co2_e = 420.75*tbsortant*tauco2', 'co2_e = 1.87*vbiogaz*tau_co2\n', 'ch4_e = 0.657*vbiogaz*tau_fuite\n', 'co2_e = 0.03156*eh*tau_abattement*tau_co2', 'ch4_e = 0.01109*eh*tau_abattement*tau_fuite', 'co2_e = 0.21038*tau_abattement*tau_co2*(dbo5 + mes)', 'ch4_e = 0.07391*tau_abattement*tau_fuite*(dbo5 + mes)', 'co2_e = 420.75*tbsortant*tauco2', 'ch4_e = 147.825*tbsortant*tau_fuite', 'co2_e = 420.75*tbsortant*tauco2', 'co2_e = 1.87*vbiogaz*tau_co2\n', 'ch4_e = 0.657*vbiogaz*tau_fuite\n', 'co2_e = 0.03156*eh*tau_abattement*tau_co2', 'ch4_e = 0.01109*eh*tau_abattement*tau_fuite', 'co2_e = 0.21038*tau_abattement*tau_co2*(dbo5 + mes)', 'ch4_e = 0.07391*tau_abattement*tau_fuite*(dbo5 + mes)', 'co2_e = 420.75*tbsortant*tauco2', 'ch4_e = 147.825*tbsortant*tau_fuite', 'co2_e = 420.75*tbsortant*tauco2', 'co2_e = 1.87*vbiogaz*tau_co2\n', 'ch4_e = 0.657*vbiogaz*tau_fuite\n', 'co2_e = 0.03156*eh*tau_abattement*tau_co2', 'ch4_e = 0.01109*eh*tau_abattement*tau_fuite', 'co2_e = 0.21038*tau_abattement*tau_co2*(dbo5 + mes)', 'ch4_e = 0.07391*tau_abattement*tau_fuite*(dbo5 + mes)', 'co2_e = 420.75*tbsortant*tauco2', 'ch4_e = 147.825*tbsortant*tau_fuite', 'co2_e = 420.75*tbsortant*tauco2', 'co2_e = 1.87*vbiogaz*tau_co2\n', 'ch4_e = 0.657*vbiogaz*tau_fuite\n', 'co2_e = 0.03156*eh*tau_abattement*tau_co2', 'ch4_e = 0.01109*eh*tau_abattement*tau_fuite', 'co2_e = 0.21038*tau_abattement*tau_co2*(dbo5 + mes)', 'ch4_e = 0.07391*tau_abattement*tau_fuite*(dbo5 + mes)', 'co2_e = 420.75*tbsortant*tauco2', 'ch4_e = 147.825*tbsortant*tau_fuite', 'co2_e = 420.75*tbsortant*tauco2', 'co2_e = 1.87*vbiogaz*tau_co2\n', 'ch4_e = 0.657*vbiogaz*tau_fuite\n', 'co2_e = 0.03156*eh*tau_abattement*tau_co2', 'ch4_e = 0.01109*eh*tau_abattement*tau_fuite', 'co2_e = 0.21038*tau_abattement*tau_co2*(dbo5 + mes)', 'ch4_e = 0.07391*tau_abattement*tau_fuite*(dbo5 + mes)', 'co2_e = 420.75*tbsortant*tauco2', 'ch4_e = 147.825*tbsortant*tau_fuite', 'co2_e = 420.75*tbsortant*tauco2', 'co2_e = 1.87*vbiogaz*tau_co2\n', 'ch4_e = 0.657*vbiogaz*tau_fuite\n', 'co2_e = 0.03156*eh*tau_abattement*tau_co2', 'ch4_e = 0.01109*eh*tau_abattement*tau_fuite', 'co2_e = 0.21038*tau_abattement*tau_co2*(dbo5 + mes)', 'ch4_e = 0.07391*tau_abattement*tau_fuite*(dbo5 + mes)', 'co2_e = 420.75*tbsortant*tauco2', 'ch4_e = 147.825*tbsortant*tau_fuite', 'co2_e = 420.75*tbsortant*tauco2', 'co2_e = 1.87*vbiogaz*tau_co2\n', 'ch4_e = 0.657*vbiogaz*tau_fuite\n', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant']::varchar[],
formula_name varchar[] default array['methanisation exploitation co2 niveau 1', 'methanisation exploitation ch4 niveau 1', 'methanisation exploitation co2 niveau 2', 'methanisation exploitation ch4 niveau 2', 'methanisation exploitation co2 niveau 3', 'methanisation exploitation ch4 niveau 3', 'methanisation exploitation co2 niveau 4', 'methanisation exploitation ch4 niveau 4', 'centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[],
eh real,
dbo5 real,
mes real,
vbiogaz real,
tau_fuite real default 0.1245,
tau_ch4 real default 0.75,
tau_co2 real default 0.2,
tau_abattement real default 0.5,
tbsortant real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.methanisation_bloc_config(
    like ___.methanisation_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.methanisation_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('methanisation', 'bloc', ''Point'' 
    
    ) ;

select api.add_new_formula('methanisation exploitation co2 niveau 1'::varchar, 'co2_e = 0.03156*eh*tau_abattement*tau_co2'::varchar, 1, ''::text) ;
select api.add_new_formula('methanisation exploitation ch4 niveau 1'::varchar, 'ch4_e = 0.01109*eh*tau_abattement*tau_fuite'::varchar, 1, ''::text) ;
select api.add_new_formula('methanisation exploitation co2 niveau 2'::varchar, 'co2_e = 0.21038*tau_abattement*tau_co2*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('methanisation exploitation ch4 niveau 2'::varchar, 'ch4_e = 0.07391*tau_abattement*tau_fuite*(dbo5 + mes)'::varchar, 2, ''::text) ;
select api.add_new_formula('methanisation exploitation co2 niveau 3'::varchar, 'co2_e = 420.75*tbsortant*tauco2'::varchar, 3, ''::text) ;
select api.add_new_formula('methanisation exploitation ch4 niveau 3'::varchar, 'ch4_e = 147.825*tbsortant*tau_fuite'::varchar, 3, ''::text) ;
select api.add_new_formula('methanisation exploitation co2 niveau 4'::varchar, 'co2_e = 1.87*vbiogaz*tau_co2
'::varchar, 4, ''::text) ;
select api.add_new_formula('methanisation exploitation ch4 niveau 4'::varchar, 'ch4_e = 0.657*vbiogaz*tau_fuite
'::varchar, 4, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 1'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000'::varchar, 1, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 2'::varchar, 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000'::varchar, 2, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 3'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant'::varchar, 3, ''::text) ;





alter type ___.bloc_type add value 'clarificateur' ;
commit ; 
insert into ___.input_output values ('clarificateur', array['eh', 'vit', 'vu', 'e', 'cad', 'h', 'taur', 'tauenterre', 'qe']::varchar[], array['qe_s']::varchar[], array['Bassin vitesse construction niveau 1', 'Bassin vitesse construction niveau 2', 'Bassin dimension construction niveau 3', 'centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[]) ;

create sequence ___.clarificateur_bloc_name_seq ;     




create table ___.clarificateur_bloc(
id integer primary key,
shape ___.geo_type not null default ''Point'::___.geo_type',
geom geometry(''POINT'::___.GEO_TYPE', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('clarificateur_bloc', abbreviation=>'clarificateur_bloc'),
formula varchar[] default array['co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant']::varchar[],
formula_name varchar[] default array['Bassin vitesse construction niveau 1', 'Bassin vitesse construction niveau 2', 'Bassin dimension construction niveau 3', 'centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[],
eh real,
vit real default 60,
vu real,
e real default 0.25,
cad real default 125,
h real default 5,
taur real default 1,
tauenterre real default 0.75,
qe real,
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

select api.add_new_bloc('clarificateur', 'bloc', ''Point'' 
    
    ) ;

select api.add_new_formula('Bassin vitesse construction niveau 1'::varchar, 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit'::varchar, 1, ''::text) ;
select api.add_new_formula('Bassin vitesse construction niveau 2'::varchar, 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit'::varchar, 2, ''::text) ;
select api.add_new_formula('Bassin dimension construction niveau 3'::varchar, 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h'::varchar, 3, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 1'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000'::varchar, 1, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 2'::varchar, 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000'::varchar, 2, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 3'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant'::varchar, 3, ''::text) ;





alter type ___.bloc_type add value 'bassin_biologique' ;
commit ; 
insert into ___.input_output values ('bassin_biologique', array['eh', 'vu', 'e', 'cad', 'h', 'tauenterre', 'tsejour', 'qe']::varchar[], array['qe_s']::varchar[], array['Bassin vitesse construction niveau 1', 'Bassin vitesse construction niveau 2', 'Bassin dimension construction niveau 3', 'Bassin biologique construction niveau 1', 'Bassin biologique construction niveau 2', 'centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[]) ;

create sequence ___.bassin_biologique_bloc_name_seq ;     

create type ___.tsejour_type as enum ('Faible charge', 'Moyenne charge', 'Forte charge');

create table ___.tsejour_type_table(val ___.tsejour_type primary key, FE real, description text);
insert into ___.tsejour_type_table(val) values ('Faible charge') ;
insert into ___.tsejour_type_table(val) values ('Moyenne charge') ;
insert into ___.tsejour_type_table(val) values ('Forte charge') ;

select template.basic_view('tsejour_type_table') ;

create table ___.bassin_biologique_bloc(
id integer primary key,
shape ___.geo_type not null default ''Point'::___.geo_type',
geom geometry(''POINT'::___.GEO_TYPE', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('bassin_biologique_bloc', abbreviation=>'bassin_biologique_bloc'),
formula varchar[] default array['co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(0.12*eh*tsejour*(taur + 1) + 3.14159*h**2*(e + 0.39088*(eh*tsejour*(taur + 1)/h)**0.5)) + 3.14159*h*tauenterre*(h + e)*(e + 0.19544*(eh*tsejour*(taur + 1)/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(qe*tsejour*(taur + 1)/h)**0.5) + qe*tsejour*(taur + 1)) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(qe*tsejour*(taur + 1)/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(0.12*eh*tsejour*(taur + 1) + 3.14159*h**2*(e + 0.39088*(eh*tsejour*(taur + 1)/h)**0.5)) + 3.14159*h*tauenterre*(h + e)*(e + 0.19544*(eh*tsejour*(taur + 1)/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(qe*tsejour*(taur + 1)/h)**0.5) + qe*tsejour*(taur + 1)) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(qe*tsejour*(taur + 1)/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(0.12*eh*tsejour*(taur + 1) + 3.14159*h**2*(e + 0.39088*(eh*tsejour*(taur + 1)/h)**0.5)) + 3.14159*h*tauenterre*(h + e)*(e + 0.19544*(eh*tsejour*(taur + 1)/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(qe*tsejour*(taur + 1)/h)**0.5) + qe*tsejour*(taur + 1)) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(qe*tsejour*(taur + 1)/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(0.12*eh*tsejour*(taur + 1) + 3.14159*h**2*(e + 0.39088*(eh*tsejour*(taur + 1)/h)**0.5)) + 3.14159*h*tauenterre*(h + e)*(e + 0.19544*(eh*tsejour*(taur + 1)/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(qe*tsejour*(taur + 1)/h)**0.5) + qe*tsejour*(taur + 1)) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(qe*tsejour*(taur + 1)/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(0.12*eh*tsejour*(taur + 1) + 3.14159*h**2*(e + 0.39088*(eh*tsejour*(taur + 1)/h)**0.5)) + 3.14159*h*tauenterre*(h + e)*(e + 0.19544*(eh*tsejour*(taur + 1)/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(qe*tsejour*(taur + 1)/h)**0.5) + qe*tsejour*(taur + 1)) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(qe*tsejour*(taur + 1)/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(0.12*eh*tsejour*(taur + 1) + 3.14159*h**2*(e + 0.39088*(eh*tsejour*(taur + 1)/h)**0.5)) + 3.14159*h*tauenterre*(h + e)*(e + 0.19544*(eh*tsejour*(taur + 1)/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(qe*tsejour*(taur + 1)/h)**0.5) + qe*tsejour*(taur + 1)) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(qe*tsejour*(taur + 1)/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(0.12*eh*tsejour*(taur + 1) + 3.14159*h**2*(e + 0.39088*(eh*tsejour*(taur + 1)/h)**0.5)) + 3.14159*h*tauenterre*(h + e)*(e + 0.19544*(eh*tsejour*(taur + 1)/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(qe*tsejour*(taur + 1)/h)**0.5) + qe*tsejour*(taur + 1)) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(qe*tsejour*(taur + 1)/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(0.12*eh*tsejour*(taur + 1) + 3.14159*h**2*(e + 0.39088*(eh*tsejour*(taur + 1)/h)**0.5)) + 3.14159*h*tauenterre*(h + e)*(e + 0.19544*(eh*tsejour*(taur + 1)/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(qe*tsejour*(taur + 1)/h)**0.5) + qe*tsejour*(taur + 1)) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(qe*tsejour*(taur + 1)/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(0.12*eh*tsejour*(taur + 1) + 3.14159*h**2*(e + 0.39088*(eh*tsejour*(taur + 1)/h)**0.5)) + 3.14159*h*tauenterre*(h + e)*(e + 0.19544*(eh*tsejour*(taur + 1)/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(qe*tsejour*(taur + 1)/h)**0.5) + qe*tsejour*(taur + 1)) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(qe*tsejour*(taur + 1)/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(0.12*eh*tsejour*(taur + 1) + 3.14159*h**2*(e + 0.39088*(eh*tsejour*(taur + 1)/h)**0.5)) + 3.14159*h*tauenterre*(h + e)*(e + 0.19544*(eh*tsejour*(taur + 1)/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(qe*tsejour*(taur + 1)/h)**0.5) + qe*tsejour*(taur + 1)) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(qe*tsejour*(taur + 1)/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(0.12*eh*tsejour*(taur + 1) + 3.14159*h**2*(e + 0.39088*(eh*tsejour*(taur + 1)/h)**0.5)) + 3.14159*h*tauenterre*(h + e)*(e + 0.19544*(eh*tsejour*(taur + 1)/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(qe*tsejour*(taur + 1)/h)**0.5) + qe*tsejour*(taur + 1)) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(qe*tsejour*(taur + 1)/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(0.12*eh*tsejour*(taur + 1) + 3.14159*h**2*(e + 0.39088*(eh*tsejour*(taur + 1)/h)**0.5)) + 3.14159*h*tauenterre*(h + e)*(e + 0.19544*(eh*tsejour*(taur + 1)/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(qe*tsejour*(taur + 1)/h)**0.5) + qe*tsejour*(taur + 1)) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(qe*tsejour*(taur + 1)/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(0.12*eh*tsejour*(taur + 1) + 3.14159*h**2*(e + 0.39088*(eh*tsejour*(taur + 1)/h)**0.5)) + 3.14159*h*tauenterre*(h + e)*(e + 0.19544*(eh*tsejour*(taur + 1)/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(qe*tsejour*(taur + 1)/h)**0.5) + qe*tsejour*(taur + 1)) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(qe*tsejour*(taur + 1)/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(0.12*eh*tsejour*(taur + 1) + 3.14159*h**2*(e + 0.39088*(eh*tsejour*(taur + 1)/h)**0.5)) + 3.14159*h*tauenterre*(h + e)*(e + 0.19544*(eh*tsejour*(taur + 1)/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(qe*tsejour*(taur + 1)/h)**0.5) + qe*tsejour*(taur + 1)) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(qe*tsejour*(taur + 1)/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(0.12*eh*tsejour*(taur + 1) + 3.14159*h**2*(e + 0.39088*(eh*tsejour*(taur + 1)/h)**0.5)) + 3.14159*h*tauenterre*(h + e)*(e + 0.19544*(eh*tsejour*(taur + 1)/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(qe*tsejour*(taur + 1)/h)**0.5) + qe*tsejour*(taur + 1)) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(qe*tsejour*(taur + 1)/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(0.12*eh*tsejour*(taur + 1) + 3.14159*h**2*(e + 0.39088*(eh*tsejour*(taur + 1)/h)**0.5)) + 3.14159*h*tauenterre*(h + e)*(e + 0.19544*(eh*tsejour*(taur + 1)/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(qe*tsejour*(taur + 1)/h)**0.5) + qe*tsejour*(taur + 1)) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(qe*tsejour*(taur + 1)/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(0.12*eh*tsejour*(taur + 1) + 3.14159*h**2*(e + 0.39088*(eh*tsejour*(taur + 1)/h)**0.5)) + 3.14159*h*tauenterre*(h + e)*(e + 0.19544*(eh*tsejour*(taur + 1)/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(qe*tsejour*(taur + 1)/h)**0.5) + qe*tsejour*(taur + 1)) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(qe*tsejour*(taur + 1)/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant']::varchar[],
formula_name varchar[] default array['Bassin vitesse construction niveau 1', 'Bassin vitesse construction niveau 2', 'Bassin dimension construction niveau 3', 'Bassin biologique construction niveau 1', 'Bassin biologique construction niveau 2', 'centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[],
eh real,
vu real,
e real default 0.25,
cad real default 125,
h real default 5,
tauenterre real default 0.75,
tsejour ___.tsejour_type not null default 'Faible charge' references ___.tsejour_type_table(val) default 'Faible charge'::___.tsejour_type,
qe real,
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

select api.add_new_bloc('bassin_biologique', 'bloc', ''Point'' 
    ,additional_columns => '{tsejour_type_table.FE as tsejour_FE, tsejour_type_table.description as tsejour_description}'
    ,additional_join => 'left join ___.tsejour_type_table on tsejour_type_table.val = c.tsejour ') ;

select api.add_new_formula('Bassin vitesse construction niveau 1'::varchar, 'co2_c = (febet*e*rhobet*(2.88*eh*(taur + 1) + 3.14159*h*vit*(e + 1.91492*(eh*(taur + 1)/vit)**0.5)) + 3.14159*tauenterre*vit*(h + e)*(e + 0.95746*(eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit'::varchar, 1, ''::text) ;
select api.add_new_formula('Bassin vitesse construction niveau 2'::varchar, 'co2_c = (febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre + fepelle*cad))/vit'::varchar, 2, ''::text) ;
select api.add_new_formula('Bassin dimension construction niveau 3'::varchar, 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h'::varchar, 3, ''::text) ;
select api.add_new_formula('Bassin biologique construction niveau 1'::varchar, 'co2_c = (febet*e*rhobet*(0.12*eh*tsejour*(taur + 1) + 3.14159*h**2*(e + 0.39088*(eh*tsejour*(taur + 1)/h)**0.5)) + 3.14159*h*tauenterre*(h + e)*(e + 0.19544*(eh*tsejour*(taur + 1)/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h'::varchar, 1, ''::text) ;
select api.add_new_formula('Bassin biologique construction niveau 2'::varchar, 'co2_c = (febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(qe*tsejour*(taur + 1)/h)**0.5) + qe*tsejour*(taur + 1)) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(qe*tsejour*(taur + 1)/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h'::varchar, 2, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 1'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000'::varchar, 1, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 2'::varchar, 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000'::varchar, 2, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 3'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant'::varchar, 3, ''::text) ;





alter type ___.bloc_type add value 'bassin_dorage' ;
commit ; 
insert into ___.input_output values ('bassin_dorage', array['eh', 'vu', 'e', 'cad', 'h', 'taur', 'tauenterre', 'tjour', 'qe']::varchar[], array['qe_s']::varchar[], array['Bassin dimension construction niveau 3', 'bassin orage construction niveau 1', 'bassin orage construction niveau 2', 'centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[]) ;

create sequence ___.bassin_dorage_bloc_name_seq ;     




create table ___.bassin_dorage_bloc(
id integer primary key,
shape ___.geo_type not null default ''Point'::___.geo_type',
geom geometry(''POINT'::___.GEO_TYPE', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('bassin_dorage_bloc', abbreviation=>'bassin_dorage_bloc'),
formula varchar[] default array['co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(0.12*eh*tjour + 3.14159*h**2*(e + 0.39088*(eh*tjour/h)**0.5)) + 3.14159*h*(h + e)*(e + 0.19544*(eh*tjour/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(qe*tjour/h)**0.5) + qe*tjour) + 3.14159*h*(h + e)*(e + 0.56419*(qe*tjour/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(0.12*eh*tjour + 3.14159*h**2*(e + 0.39088*(eh*tjour/h)**0.5)) + 3.14159*h*(h + e)*(e + 0.19544*(eh*tjour/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(qe*tjour/h)**0.5) + qe*tjour) + 3.14159*h*(h + e)*(e + 0.56419*(qe*tjour/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(0.12*eh*tjour + 3.14159*h**2*(e + 0.39088*(eh*tjour/h)**0.5)) + 3.14159*h*(h + e)*(e + 0.19544*(eh*tjour/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(qe*tjour/h)**0.5) + qe*tjour) + 3.14159*h*(h + e)*(e + 0.56419*(qe*tjour/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(0.12*eh*tjour + 3.14159*h**2*(e + 0.39088*(eh*tjour/h)**0.5)) + 3.14159*h*(h + e)*(e + 0.19544*(eh*tjour/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(qe*tjour/h)**0.5) + qe*tjour) + 3.14159*h*(h + e)*(e + 0.56419*(qe*tjour/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(0.12*eh*tjour + 3.14159*h**2*(e + 0.39088*(eh*tjour/h)**0.5)) + 3.14159*h*(h + e)*(e + 0.19544*(eh*tjour/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(qe*tjour/h)**0.5) + qe*tjour) + 3.14159*h*(h + e)*(e + 0.56419*(qe*tjour/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(0.12*eh*tjour + 3.14159*h**2*(e + 0.39088*(eh*tjour/h)**0.5)) + 3.14159*h*(h + e)*(e + 0.19544*(eh*tjour/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(qe*tjour/h)**0.5) + qe*tjour) + 3.14159*h*(h + e)*(e + 0.56419*(qe*tjour/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(0.12*eh*tjour + 3.14159*h**2*(e + 0.39088*(eh*tjour/h)**0.5)) + 3.14159*h*(h + e)*(e + 0.19544*(eh*tjour/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(qe*tjour/h)**0.5) + qe*tjour) + 3.14159*h*(h + e)*(e + 0.56419*(qe*tjour/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(0.12*eh*tjour + 3.14159*h**2*(e + 0.39088*(eh*tjour/h)**0.5)) + 3.14159*h*(h + e)*(e + 0.19544*(eh*tjour/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(qe*tjour/h)**0.5) + qe*tjour) + 3.14159*h*(h + e)*(e + 0.56419*(qe*tjour/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(0.12*eh*tjour + 3.14159*h**2*(e + 0.39088*(eh*tjour/h)**0.5)) + 3.14159*h*(h + e)*(e + 0.19544*(eh*tjour/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(qe*tjour/h)**0.5) + qe*tjour) + 3.14159*h*(h + e)*(e + 0.56419*(qe*tjour/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(0.12*eh*tjour + 3.14159*h**2*(e + 0.39088*(eh*tjour/h)**0.5)) + 3.14159*h*(h + e)*(e + 0.19544*(eh*tjour/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(qe*tjour/h)**0.5) + qe*tjour) + 3.14159*h*(h + e)*(e + 0.56419*(qe*tjour/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(0.12*eh*tjour + 3.14159*h**2*(e + 0.39088*(eh*tjour/h)**0.5)) + 3.14159*h*(h + e)*(e + 0.19544*(eh*tjour/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(qe*tjour/h)**0.5) + qe*tjour) + 3.14159*h*(h + e)*(e + 0.56419*(qe*tjour/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(0.12*eh*tjour + 3.14159*h**2*(e + 0.39088*(eh*tjour/h)**0.5)) + 3.14159*h*(h + e)*(e + 0.19544*(eh*tjour/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(qe*tjour/h)**0.5) + qe*tjour) + 3.14159*h*(h + e)*(e + 0.56419*(qe*tjour/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(0.12*eh*tjour + 3.14159*h**2*(e + 0.39088*(eh*tjour/h)**0.5)) + 3.14159*h*(h + e)*(e + 0.19544*(eh*tjour/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(qe*tjour/h)**0.5) + qe*tjour) + 3.14159*h*(h + e)*(e + 0.56419*(qe*tjour/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(0.12*eh*tjour + 3.14159*h**2*(e + 0.39088*(eh*tjour/h)**0.5)) + 3.14159*h*(h + e)*(e + 0.19544*(eh*tjour/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(qe*tjour/h)**0.5) + qe*tjour) + 3.14159*h*(h + e)*(e + 0.56419*(qe*tjour/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(0.12*eh*tjour + 3.14159*h**2*(e + 0.39088*(eh*tjour/h)**0.5)) + 3.14159*h*(h + e)*(e + 0.19544*(eh*tjour/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(qe*tjour/h)**0.5) + qe*tjour) + 3.14159*h*(h + e)*(e + 0.56419*(qe*tjour/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(0.12*eh*tjour + 3.14159*h**2*(e + 0.39088*(eh*tjour/h)**0.5)) + 3.14159*h*(h + e)*(e + 0.19544*(eh*tjour/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(qe*tjour/h)**0.5) + qe*tjour) + 3.14159*h*(h + e)*(e + 0.56419*(qe*tjour/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(0.12*eh*tjour + 3.14159*h**2*(e + 0.39088*(eh*tjour/h)**0.5)) + 3.14159*h*(h + e)*(e + 0.19544*(eh*tjour/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(qe*tjour/h)**0.5) + qe*tjour) + 3.14159*h*(h + e)*(e + 0.56419*(qe*tjour/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant']::varchar[],
formula_name varchar[] default array['Bassin dimension construction niveau 3', 'bassin orage construction niveau 1', 'bassin orage construction niveau 2', 'centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[],
eh real,
vu real,
e real default 0.25,
cad real default 125,
h real default 5,
taur real default 1,
tauenterre real default 0.75,
tjour real default 1,
qe real,
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

select api.add_new_bloc('bassin_dorage', 'bloc', ''Point'' 
    
    ) ;

select api.add_new_formula('Bassin dimension construction niveau 3'::varchar, 'co2_c =(febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(vu/h)**0.5) + 1.0*vu) + 3.14159*h*tauenterre*(h + e)*(e + 0.56419*(vu/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h'::varchar, 3, ''::text) ;
select api.add_new_formula('bassin orage construction niveau 1'::varchar, 'co2_c = (febet*e*rhobet*(0.12*eh*tjour + 3.14159*h**2*(e + 0.39088*(eh*tjour/h)**0.5)) + 3.14159*h*(h + e)*(e + 0.19544*(eh*tjour/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h'::varchar, 1, ''::text) ;
select api.add_new_formula('bassin orage construction niveau 2'::varchar, 'co2_c = (febet*e*rhobet*(3.14159*h**2*(e + 1.12838*(qe*tjour/h)**0.5) + qe*tjour) + 3.14159*h*(h + e)*(e + 0.56419*(qe*tjour/h)**0.5)**2*(feevac*rhoterre + fepelle*cad))/h'::varchar, 2, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 1'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000'::varchar, 1, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 2'::varchar, 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000'::varchar, 2, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 3'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant'::varchar, 3, ''::text) ;





alter type ___.bloc_type add value 'decanteur_lamellaire' ;
commit ; 
insert into ___.input_output values ('decanteur_lamellaire', array['eh', 'e', 'cad', 'h', 'tauenterre', 'vit', 'vlam', 'long', 'larg', 'qe']::varchar[], array['qe_s']::varchar[], array['decanteur lamellaire construction niveau 1', 'decanteur lamellaire construction niveau 2', 'decanteur lamellaire construction niveau 3', 'centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[]) ;

create sequence ___.decanteur_lamellaire_bloc_name_seq ;     




create table ___.decanteur_lamellaire_bloc(
id integer primary key,
shape ___.geo_type not null default ''Point'::___.geo_type',
geom geometry(''POINT'::___.GEO_TYPE', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('decanteur_lamellaire_bloc', abbreviation=>'decanteur_lamellaire_bloc'),
formula varchar[] default array['co2_c = (eh*febet*e*rhobet*vlam*(0.00173*eh**2 + 0.0288*eh*hterre*vit + 0.24*hterre*vit**2) + 0.00024*eh*felam*rholam*vit**3 + hterre*vlam*(0.12*eh + e*vit)*(0.0144*eh**2 + e*vit**2)*(feevac*rhoterre + fepelle*cad))/(vit**3*vlam)\n', 'co2_c = (febet*qe*e*rhobet*vlam*(2*hterre*qe*vit + 2*hterre*vit**2 + qe**2) + 0.002*felam*qe*rholam*vit**3 + hterre*vlam*(qe + e*vit)*(qe**2 + e*vit**2)*(feevac*rhoterre + fepelle*cad))/(vit**3*vlam)\n', 'co2_c = (0.002*felam*qe*rholam + vlam*(febet*e*rhobet*(2*(h+e)*larg + 2*(h+e)*long + larg*long) + feevac*(h+e)*rhoterre*(e + larg)*(e + long) + fepelle*(h+e)*cad*(e + larg)*(e + long)))/vlam\n', 'co2_c = (eh*febet*e*rhobet*vlam*(0.00173*eh**2 + 0.0288*eh*hterre*vit + 0.24*hterre*vit**2) + 0.00024*eh*felam*rholam*vit**3 + hterre*vlam*(0.12*eh + e*vit)*(0.0144*eh**2 + e*vit**2)*(feevac*rhoterre + fepelle*cad))/(vit**3*vlam)\n', 'co2_c = (febet*qe*e*rhobet*vlam*(2*hterre*qe*vit + 2*hterre*vit**2 + qe**2) + 0.002*felam*qe*rholam*vit**3 + hterre*vlam*(qe + e*vit)*(qe**2 + e*vit**2)*(feevac*rhoterre + fepelle*cad))/(vit**3*vlam)\n', 'co2_c = (0.002*felam*qe*rholam + vlam*(febet*e*rhobet*(2*(h+e)*larg + 2*(h+e)*long + larg*long) + feevac*(h+e)*rhoterre*(e + larg)*(e + long) + fepelle*(h+e)*cad*(e + larg)*(e + long)))/vlam\n', 'co2_c = (eh*febet*e*rhobet*vlam*(0.00173*eh**2 + 0.0288*eh*hterre*vit + 0.24*hterre*vit**2) + 0.00024*eh*felam*rholam*vit**3 + hterre*vlam*(0.12*eh + e*vit)*(0.0144*eh**2 + e*vit**2)*(feevac*rhoterre + fepelle*cad))/(vit**3*vlam)\n', 'co2_c = (febet*qe*e*rhobet*vlam*(2*hterre*qe*vit + 2*hterre*vit**2 + qe**2) + 0.002*felam*qe*rholam*vit**3 + hterre*vlam*(qe + e*vit)*(qe**2 + e*vit**2)*(feevac*rhoterre + fepelle*cad))/(vit**3*vlam)\n', 'co2_c = (0.002*felam*qe*rholam + vlam*(febet*e*rhobet*(2*(h+e)*larg + 2*(h+e)*long + larg*long) + feevac*(h+e)*rhoterre*(e + larg)*(e + long) + fepelle*(h+e)*cad*(e + larg)*(e + long)))/vlam\n', 'co2_c = (eh*febet*e*rhobet*vlam*(0.00173*eh**2 + 0.0288*eh*hterre*vit + 0.24*hterre*vit**2) + 0.00024*eh*felam*rholam*vit**3 + hterre*vlam*(0.12*eh + e*vit)*(0.0144*eh**2 + e*vit**2)*(feevac*rhoterre + fepelle*cad))/(vit**3*vlam)\n', 'co2_c = (febet*qe*e*rhobet*vlam*(2*hterre*qe*vit + 2*hterre*vit**2 + qe**2) + 0.002*felam*qe*rholam*vit**3 + hterre*vlam*(qe + e*vit)*(qe**2 + e*vit**2)*(feevac*rhoterre + fepelle*cad))/(vit**3*vlam)\n', 'co2_c = (0.002*felam*qe*rholam + vlam*(febet*e*rhobet*(2*(h+e)*larg + 2*(h+e)*long + larg*long) + feevac*(h+e)*rhoterre*(e + larg)*(e + long) + fepelle*(h+e)*cad*(e + larg)*(e + long)))/vlam\n', 'co2_c = (eh*febet*e*rhobet*vlam*(0.00173*eh**2 + 0.0288*eh*hterre*vit + 0.24*hterre*vit**2) + 0.00024*eh*felam*rholam*vit**3 + hterre*vlam*(0.12*eh + e*vit)*(0.0144*eh**2 + e*vit**2)*(feevac*rhoterre + fepelle*cad))/(vit**3*vlam)\n', 'co2_c = (febet*qe*e*rhobet*vlam*(2*hterre*qe*vit + 2*hterre*vit**2 + qe**2) + 0.002*felam*qe*rholam*vit**3 + hterre*vlam*(qe + e*vit)*(qe**2 + e*vit**2)*(feevac*rhoterre + fepelle*cad))/(vit**3*vlam)\n', 'co2_c = (0.002*felam*qe*rholam + vlam*(febet*e*rhobet*(2*(h+e)*larg + 2*(h+e)*long + larg*long) + feevac*(h+e)*rhoterre*(e + larg)*(e + long) + fepelle*(h+e)*cad*(e + larg)*(e + long)))/vlam\n', 'co2_c = (eh*febet*e*rhobet*vlam*(0.00173*eh**2 + 0.0288*eh*hterre*vit + 0.24*hterre*vit**2) + 0.00024*eh*felam*rholam*vit**3 + hterre*vlam*(0.12*eh + e*vit)*(0.0144*eh**2 + e*vit**2)*(feevac*rhoterre + fepelle*cad))/(vit**3*vlam)\n', 'co2_c = (febet*qe*e*rhobet*vlam*(2*hterre*qe*vit + 2*hterre*vit**2 + qe**2) + 0.002*felam*qe*rholam*vit**3 + hterre*vlam*(qe + e*vit)*(qe**2 + e*vit**2)*(feevac*rhoterre + fepelle*cad))/(vit**3*vlam)\n', 'co2_c = (0.002*felam*qe*rholam + vlam*(febet*e*rhobet*(2*(h+e)*larg + 2*(h+e)*long + larg*long) + feevac*(h+e)*rhoterre*(e + larg)*(e + long) + fepelle*(h+e)*cad*(e + larg)*(e + long)))/vlam\n', 'co2_c = (eh*febet*e*rhobet*vlam*(0.00173*eh**2 + 0.0288*eh*hterre*vit + 0.24*hterre*vit**2) + 0.00024*eh*felam*rholam*vit**3 + hterre*vlam*(0.12*eh + e*vit)*(0.0144*eh**2 + e*vit**2)*(feevac*rhoterre + fepelle*cad))/(vit**3*vlam)\n', 'co2_c = (febet*qe*e*rhobet*vlam*(2*hterre*qe*vit + 2*hterre*vit**2 + qe**2) + 0.002*felam*qe*rholam*vit**3 + hterre*vlam*(qe + e*vit)*(qe**2 + e*vit**2)*(feevac*rhoterre + fepelle*cad))/(vit**3*vlam)\n', 'co2_c = (0.002*felam*qe*rholam + vlam*(febet*e*rhobet*(2*(h+e)*larg + 2*(h+e)*long + larg*long) + feevac*(h+e)*rhoterre*(e + larg)*(e + long) + fepelle*(h+e)*cad*(e + larg)*(e + long)))/vlam\n', 'co2_c = (eh*febet*e*rhobet*vlam*(0.00173*eh**2 + 0.0288*eh*hterre*vit + 0.24*hterre*vit**2) + 0.00024*eh*felam*rholam*vit**3 + hterre*vlam*(0.12*eh + e*vit)*(0.0144*eh**2 + e*vit**2)*(feevac*rhoterre + fepelle*cad))/(vit**3*vlam)\n', 'co2_c = (febet*qe*e*rhobet*vlam*(2*hterre*qe*vit + 2*hterre*vit**2 + qe**2) + 0.002*felam*qe*rholam*vit**3 + hterre*vlam*(qe + e*vit)*(qe**2 + e*vit**2)*(feevac*rhoterre + fepelle*cad))/(vit**3*vlam)\n', 'co2_c = (0.002*felam*qe*rholam + vlam*(febet*e*rhobet*(2*(h+e)*larg + 2*(h+e)*long + larg*long) + feevac*(h+e)*rhoterre*(e + larg)*(e + long) + fepelle*(h+e)*cad*(e + larg)*(e + long)))/vlam\n', 'co2_c = (eh*febet*e*rhobet*vlam*(0.00173*eh**2 + 0.0288*eh*hterre*vit + 0.24*hterre*vit**2) + 0.00024*eh*felam*rholam*vit**3 + hterre*vlam*(0.12*eh + e*vit)*(0.0144*eh**2 + e*vit**2)*(feevac*rhoterre + fepelle*cad))/(vit**3*vlam)\n', 'co2_c = (febet*qe*e*rhobet*vlam*(2*hterre*qe*vit + 2*hterre*vit**2 + qe**2) + 0.002*felam*qe*rholam*vit**3 + hterre*vlam*(qe + e*vit)*(qe**2 + e*vit**2)*(feevac*rhoterre + fepelle*cad))/(vit**3*vlam)\n', 'co2_c = (0.002*felam*qe*rholam + vlam*(febet*e*rhobet*(2*(h+e)*larg + 2*(h+e)*long + larg*long) + feevac*(h+e)*rhoterre*(e + larg)*(e + long) + fepelle*(h+e)*cad*(e + larg)*(e + long)))/vlam\n', 'co2_c = (eh*febet*e*rhobet*vlam*(0.00173*eh**2 + 0.0288*eh*hterre*vit + 0.24*hterre*vit**2) + 0.00024*eh*felam*rholam*vit**3 + hterre*vlam*(0.12*eh + e*vit)*(0.0144*eh**2 + e*vit**2)*(feevac*rhoterre + fepelle*cad))/(vit**3*vlam)\n', 'co2_c = (febet*qe*e*rhobet*vlam*(2*hterre*qe*vit + 2*hterre*vit**2 + qe**2) + 0.002*felam*qe*rholam*vit**3 + hterre*vlam*(qe + e*vit)*(qe**2 + e*vit**2)*(feevac*rhoterre + fepelle*cad))/(vit**3*vlam)\n', 'co2_c = (0.002*felam*qe*rholam + vlam*(febet*e*rhobet*(2*(h+e)*larg + 2*(h+e)*long + larg*long) + feevac*(h+e)*rhoterre*(e + larg)*(e + long) + fepelle*(h+e)*cad*(e + larg)*(e + long)))/vlam\n', 'co2_c = (eh*febet*e*rhobet*vlam*(0.00173*eh**2 + 0.0288*eh*hterre*vit + 0.24*hterre*vit**2) + 0.00024*eh*felam*rholam*vit**3 + hterre*vlam*(0.12*eh + e*vit)*(0.0144*eh**2 + e*vit**2)*(feevac*rhoterre + fepelle*cad))/(vit**3*vlam)\n', 'co2_c = (febet*qe*e*rhobet*vlam*(2*hterre*qe*vit + 2*hterre*vit**2 + qe**2) + 0.002*felam*qe*rholam*vit**3 + hterre*vlam*(qe + e*vit)*(qe**2 + e*vit**2)*(feevac*rhoterre + fepelle*cad))/(vit**3*vlam)\n', 'co2_c = (0.002*felam*qe*rholam + vlam*(febet*e*rhobet*(2*(h+e)*larg + 2*(h+e)*long + larg*long) + feevac*(h+e)*rhoterre*(e + larg)*(e + long) + fepelle*(h+e)*cad*(e + larg)*(e + long)))/vlam\n', 'co2_c = (eh*febet*e*rhobet*vlam*(0.00173*eh**2 + 0.0288*eh*hterre*vit + 0.24*hterre*vit**2) + 0.00024*eh*felam*rholam*vit**3 + hterre*vlam*(0.12*eh + e*vit)*(0.0144*eh**2 + e*vit**2)*(feevac*rhoterre + fepelle*cad))/(vit**3*vlam)\n', 'co2_c = (febet*qe*e*rhobet*vlam*(2*hterre*qe*vit + 2*hterre*vit**2 + qe**2) + 0.002*felam*qe*rholam*vit**3 + hterre*vlam*(qe + e*vit)*(qe**2 + e*vit**2)*(feevac*rhoterre + fepelle*cad))/(vit**3*vlam)\n', 'co2_c = (0.002*felam*qe*rholam + vlam*(febet*e*rhobet*(2*(h+e)*larg + 2*(h+e)*long + larg*long) + feevac*(h+e)*rhoterre*(e + larg)*(e + long) + fepelle*(h+e)*cad*(e + larg)*(e + long)))/vlam\n', 'co2_c = (eh*febet*e*rhobet*vlam*(0.00173*eh**2 + 0.0288*eh*hterre*vit + 0.24*hterre*vit**2) + 0.00024*eh*felam*rholam*vit**3 + hterre*vlam*(0.12*eh + e*vit)*(0.0144*eh**2 + e*vit**2)*(feevac*rhoterre + fepelle*cad))/(vit**3*vlam)\n', 'co2_c = (febet*qe*e*rhobet*vlam*(2*hterre*qe*vit + 2*hterre*vit**2 + qe**2) + 0.002*felam*qe*rholam*vit**3 + hterre*vlam*(qe + e*vit)*(qe**2 + e*vit**2)*(feevac*rhoterre + fepelle*cad))/(vit**3*vlam)\n', 'co2_c = (0.002*felam*qe*rholam + vlam*(febet*e*rhobet*(2*(h+e)*larg + 2*(h+e)*long + larg*long) + feevac*(h+e)*rhoterre*(e + larg)*(e + long) + fepelle*(h+e)*cad*(e + larg)*(e + long)))/vlam\n', 'co2_c = (eh*febet*e*rhobet*vlam*(0.00173*eh**2 + 0.0288*eh*hterre*vit + 0.24*hterre*vit**2) + 0.00024*eh*felam*rholam*vit**3 + hterre*vlam*(0.12*eh + e*vit)*(0.0144*eh**2 + e*vit**2)*(feevac*rhoterre + fepelle*cad))/(vit**3*vlam)\n', 'co2_c = (febet*qe*e*rhobet*vlam*(2*hterre*qe*vit + 2*hterre*vit**2 + qe**2) + 0.002*felam*qe*rholam*vit**3 + hterre*vlam*(qe + e*vit)*(qe**2 + e*vit**2)*(feevac*rhoterre + fepelle*cad))/(vit**3*vlam)\n', 'co2_c = (0.002*felam*qe*rholam + vlam*(febet*e*rhobet*(2*(h+e)*larg + 2*(h+e)*long + larg*long) + feevac*(h+e)*rhoterre*(e + larg)*(e + long) + fepelle*(h+e)*cad*(e + larg)*(e + long)))/vlam\n', 'co2_c = (eh*febet*e*rhobet*vlam*(0.00173*eh**2 + 0.0288*eh*hterre*vit + 0.24*hterre*vit**2) + 0.00024*eh*felam*rholam*vit**3 + hterre*vlam*(0.12*eh + e*vit)*(0.0144*eh**2 + e*vit**2)*(feevac*rhoterre + fepelle*cad))/(vit**3*vlam)\n', 'co2_c = (febet*qe*e*rhobet*vlam*(2*hterre*qe*vit + 2*hterre*vit**2 + qe**2) + 0.002*felam*qe*rholam*vit**3 + hterre*vlam*(qe + e*vit)*(qe**2 + e*vit**2)*(feevac*rhoterre + fepelle*cad))/(vit**3*vlam)\n', 'co2_c = (0.002*felam*qe*rholam + vlam*(febet*e*rhobet*(2*(h+e)*larg + 2*(h+e)*long + larg*long) + feevac*(h+e)*rhoterre*(e + larg)*(e + long) + fepelle*(h+e)*cad*(e + larg)*(e + long)))/vlam\n', 'co2_c = (eh*febet*e*rhobet*vlam*(0.00173*eh**2 + 0.0288*eh*hterre*vit + 0.24*hterre*vit**2) + 0.00024*eh*felam*rholam*vit**3 + hterre*vlam*(0.12*eh + e*vit)*(0.0144*eh**2 + e*vit**2)*(feevac*rhoterre + fepelle*cad))/(vit**3*vlam)\n', 'co2_c = (febet*qe*e*rhobet*vlam*(2*hterre*qe*vit + 2*hterre*vit**2 + qe**2) + 0.002*felam*qe*rholam*vit**3 + hterre*vlam*(qe + e*vit)*(qe**2 + e*vit**2)*(feevac*rhoterre + fepelle*cad))/(vit**3*vlam)\n', 'co2_c = (0.002*felam*qe*rholam + vlam*(febet*e*rhobet*(2*(h+e)*larg + 2*(h+e)*long + larg*long) + feevac*(h+e)*rhoterre*(e + larg)*(e + long) + fepelle*(h+e)*cad*(e + larg)*(e + long)))/vlam\n', 'co2_c = (eh*febet*e*rhobet*vlam*(0.00173*eh**2 + 0.0288*eh*hterre*vit + 0.24*hterre*vit**2) + 0.00024*eh*felam*rholam*vit**3 + hterre*vlam*(0.12*eh + e*vit)*(0.0144*eh**2 + e*vit**2)*(feevac*rhoterre + fepelle*cad))/(vit**3*vlam)\n', 'co2_c = (febet*qe*e*rhobet*vlam*(2*hterre*qe*vit + 2*hterre*vit**2 + qe**2) + 0.002*felam*qe*rholam*vit**3 + hterre*vlam*(qe + e*vit)*(qe**2 + e*vit**2)*(feevac*rhoterre + fepelle*cad))/(vit**3*vlam)\n', 'co2_c = (0.002*felam*qe*rholam + vlam*(febet*e*rhobet*(2*(h+e)*larg + 2*(h+e)*long + larg*long) + feevac*(h+e)*rhoterre*(e + larg)*(e + long) + fepelle*(h+e)*cad*(e + larg)*(e + long)))/vlam\n', 'co2_c = (eh*febet*e*rhobet*vlam*(0.00173*eh**2 + 0.0288*eh*hterre*vit + 0.24*hterre*vit**2) + 0.00024*eh*felam*rholam*vit**3 + hterre*vlam*(0.12*eh + e*vit)*(0.0144*eh**2 + e*vit**2)*(feevac*rhoterre + fepelle*cad))/(vit**3*vlam)\n', 'co2_c = (febet*qe*e*rhobet*vlam*(2*hterre*qe*vit + 2*hterre*vit**2 + qe**2) + 0.002*felam*qe*rholam*vit**3 + hterre*vlam*(qe + e*vit)*(qe**2 + e*vit**2)*(feevac*rhoterre + fepelle*cad))/(vit**3*vlam)\n', 'co2_c = (0.002*felam*qe*rholam + vlam*(febet*e*rhobet*(2*(h+e)*larg + 2*(h+e)*long + larg*long) + feevac*(h+e)*rhoterre*(e + larg)*(e + long) + fepelle*(h+e)*cad*(e + larg)*(e + long)))/vlam\n', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant']::varchar[],
formula_name varchar[] default array['decanteur lamellaire construction niveau 1', 'decanteur lamellaire construction niveau 2', 'decanteur lamellaire construction niveau 3', 'centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[],
eh real,
e real default 0.25,
cad real default 125,
h real default 5,
tauenterre real default 0.75,
vit real default 15,
vlam real default 20,
long real,
larg real,
qe real,
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

select api.add_new_bloc('decanteur_lamellaire', 'bloc', ''Point'' 
    
    ) ;

select api.add_new_formula('decanteur lamellaire construction niveau 1'::varchar, 'co2_c = (eh*febet*e*rhobet*vlam*(0.00173*eh**2 + 0.0288*eh*hterre*vit + 0.24*hterre*vit**2) + 0.00024*eh*felam*rholam*vit**3 + hterre*vlam*(0.12*eh + e*vit)*(0.0144*eh**2 + e*vit**2)*(feevac*rhoterre + fepelle*cad))/(vit**3*vlam)
'::varchar, 1, ''::text) ;
select api.add_new_formula('decanteur lamellaire construction niveau 2'::varchar, 'co2_c = (febet*qe*e*rhobet*vlam*(2*hterre*qe*vit + 2*hterre*vit**2 + qe**2) + 0.002*felam*qe*rholam*vit**3 + hterre*vlam*(qe + e*vit)*(qe**2 + e*vit**2)*(feevac*rhoterre + fepelle*cad))/(vit**3*vlam)
'::varchar, 2, ''::text) ;
select api.add_new_formula('decanteur lamellaire construction niveau 3'::varchar, 'co2_c = (0.002*felam*qe*rholam + vlam*(febet*e*rhobet*(2*(h+e)*larg + 2*(h+e)*long + larg*long) + feevac*(h+e)*rhoterre*(e + larg)*(e + long) + fepelle*(h+e)*cad*(e + larg)*(e + long)))/vlam
'::varchar, 3, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 1'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000'::varchar, 1, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 2'::varchar, 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000'::varchar, 2, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 3'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant'::varchar, 3, ''::text) ;





alter type ___.bloc_type add value 'sur_bloc' ;
commit ; 
insert into ___.input_output values ('sur_bloc', array[]::varchar[], array[]::varchar[], array['centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[]) ;

create sequence ___.sur_bloc_bloc_name_seq ;     




create table ___.sur_bloc_bloc(
id integer primary key,
shape ___.geo_type not null default ''Polygon'::___.geo_type',
geom geometry(''POLYGON'::___.GEO_TYPE', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('sur_bloc_bloc', abbreviation=>'sur_bloc_bloc'),
formula varchar[] default array['co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant']::varchar[],
formula_name varchar[] default array['centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[],

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.sur_bloc_bloc_config(
    like ___.sur_bloc_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.sur_bloc_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('sur_bloc', 'bloc', ''Polygon'' 
    
    ) ;

select api.add_new_formula('centrifugeuse construction niveau 1'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000'::varchar, 1, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 2'::varchar, 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000'::varchar, 2, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 3'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant'::varchar, 3, ''::text) ;





alter type ___.bloc_type add value 'tamis' ;
commit ; 
insert into ___.input_output values ('tamis', array['qe', 'compt', 'eh']::varchar[], array[]::varchar[], array['tamis statique construction niveau de détail 1', 'tamis statique construction niveau de détail 2', 'tamis exploitation niveau 1', 'tamis exploitation niveau 2', 'tamis exploitation niveau 3', 'centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[]) ;

create sequence ___.tamis_bloc_name_seq ;     




create table ___.tamis_bloc(
id integer primary key,
shape ___.geo_type not null default ''Point'::___.geo_type',
geom geometry(''POINT'::___.GEO_TYPE', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('tamis_bloc', abbreviation=>'tamis_bloc'),
formula varchar[] default array['co2_c = 0.12*eh*fepoids*210/270\n', 'co2_c =qe*fepoids*210/270\n', 'co2_e = 0.3024*eh\n', 'co2_e = 5.76*qe\n', 'co2_e = qe*(5.76 - 2.88*compt)\n', 'co2_c = 0.12*eh*fepoids*210/270\n', 'co2_c =qe*fepoids*210/270\n', 'co2_e = 0.3024*eh\n', 'co2_e = 5.76*qe\n', 'co2_e = qe*(5.76 - 2.88*compt)\n', 'co2_c = 0.12*eh*fepoids*210/270\n', 'co2_c =qe*fepoids*210/270\n', 'co2_e = 0.3024*eh\n', 'co2_e = 5.76*qe\n', 'co2_e = qe*(5.76 - 2.88*compt)\n', 'co2_c = 0.12*eh*fepoids*210/270\n', 'co2_c =qe*fepoids*210/270\n', 'co2_e = 0.3024*eh\n', 'co2_e = 5.76*qe\n', 'co2_e = qe*(5.76 - 2.88*compt)\n', 'co2_c = 0.12*eh*fepoids*210/270\n', 'co2_c =qe*fepoids*210/270\n', 'co2_e = 0.3024*eh\n', 'co2_e = 5.76*qe\n', 'co2_e = qe*(5.76 - 2.88*compt)\n', 'co2_c = 0.12*eh*fepoids*210/270\n', 'co2_c =qe*fepoids*210/270\n', 'co2_e = 0.3024*eh\n', 'co2_e = 5.76*qe\n', 'co2_e = qe*(5.76 - 2.88*compt)\n', 'co2_c = 0.12*eh*fepoids*210/270\n', 'co2_c =qe*fepoids*210/270\n', 'co2_e = 0.3024*eh\n', 'co2_e = 5.76*qe\n', 'co2_e = qe*(5.76 - 2.88*compt)\n', 'co2_c = 0.12*eh*fepoids*210/270\n', 'co2_c =qe*fepoids*210/270\n', 'co2_e = 0.3024*eh\n', 'co2_e = 5.76*qe\n', 'co2_e = qe*(5.76 - 2.88*compt)\n', 'co2_c = 0.12*eh*fepoids*210/270\n', 'co2_c =qe*fepoids*210/270\n', 'co2_e = 0.3024*eh\n', 'co2_e = 5.76*qe\n', 'co2_e = qe*(5.76 - 2.88*compt)\n', 'co2_c = 0.12*eh*fepoids*210/270\n', 'co2_c =qe*fepoids*210/270\n', 'co2_e = 0.3024*eh\n', 'co2_e = 5.76*qe\n', 'co2_e = qe*(5.76 - 2.88*compt)\n', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant']::varchar[],
formula_name varchar[] default array['tamis statique construction niveau de détail 1', 'tamis statique construction niveau de détail 2', 'tamis exploitation niveau 1', 'tamis exploitation niveau 2', 'tamis exploitation niveau 3', 'centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[],
qe real,
compt integer default 0,
eh real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.tamis_bloc_config(
    like ___.tamis_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.tamis_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('tamis', 'bloc', ''Point'' 
    
    ) ;

select api.add_new_formula('tamis statique construction niveau de détail 1'::varchar, 'co2_c = 0.12*eh*fepoids*210/270
'::varchar, 1, ''::text) ;
select api.add_new_formula('tamis statique construction niveau de détail 2'::varchar, 'co2_c =qe*fepoids*210/270
'::varchar, 2, ''::text) ;
select api.add_new_formula('tamis exploitation niveau 1'::varchar, 'co2_e = 0.3024*eh
'::varchar, 1, ''::text) ;
select api.add_new_formula('tamis exploitation niveau 2'::varchar, 'co2_e = 5.76*qe
'::varchar, 2, ''::text) ;
select api.add_new_formula('tamis exploitation niveau 3'::varchar, 'co2_e = qe*(5.76 - 2.88*compt)
'::varchar, 3, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 1'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000'::varchar, 1, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 2'::varchar, 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000'::varchar, 2, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 3'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant'::varchar, 3, ''::text) ;





alter type ___.bloc_type add value 'digesteur' ;
commit ; 
insert into ___.input_output values ('digesteur', array['eh', 'tbentrant', 'mes', 'dbo5']::varchar[], array['tbsortant']::varchar[], array['digesteur construction niveau 1', 'digesteur construction niveau 2', 'digesteur construction niveau 3', 'centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[]) ;

create sequence ___.digesteur_bloc_name_seq ;     




create table ___.digesteur_bloc(
id integer primary key,
shape ___.geo_type not null default ''Point'::___.geo_type',
geom geometry(''POINT'::___.GEO_TYPE', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('digesteur_bloc', abbreviation=>'digesteur_bloc'),
formula varchar[] default array['co2_c = (0.0228*(eh<10000)+0.0126*(eh>10000)*(eh<100000)+0.0102*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0228*(eh<10000)+0.0126*(eh>10000)*(eh<100000)+0.0102*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.0228*(eh<10000)+0.0126*(eh>10000)*(eh<100000)+0.0102*(eh>100000))*tbentrant', 'co2_c = (0.0228*(eh<10000)+0.0126*(eh>10000)*(eh<100000)+0.0102*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0228*(eh<10000)+0.0126*(eh>10000)*(eh<100000)+0.0102*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.0228*(eh<10000)+0.0126*(eh>10000)*(eh<100000)+0.0102*(eh>100000))*tbentrant', 'co2_c = (0.0228*(eh<10000)+0.0126*(eh>10000)*(eh<100000)+0.0102*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0228*(eh<10000)+0.0126*(eh>10000)*(eh<100000)+0.0102*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.0228*(eh<10000)+0.0126*(eh>10000)*(eh<100000)+0.0102*(eh>100000))*tbentrant', 'co2_c = (0.0228*(eh<10000)+0.0126*(eh>10000)*(eh<100000)+0.0102*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0228*(eh<10000)+0.0126*(eh>10000)*(eh<100000)+0.0102*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.0228*(eh<10000)+0.0126*(eh>10000)*(eh<100000)+0.0102*(eh>100000))*tbentrant', 'co2_c = (0.0228*(eh<10000)+0.0126*(eh>10000)*(eh<100000)+0.0102*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0228*(eh<10000)+0.0126*(eh>10000)*(eh<100000)+0.0102*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.0228*(eh<10000)+0.0126*(eh>10000)*(eh<100000)+0.0102*(eh>100000))*tbentrant', 'co2_c = (0.0228*(eh<10000)+0.0126*(eh>10000)*(eh<100000)+0.0102*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0228*(eh<10000)+0.0126*(eh>10000)*(eh<100000)+0.0102*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.0228*(eh<10000)+0.0126*(eh>10000)*(eh<100000)+0.0102*(eh>100000))*tbentrant', 'co2_c = (0.0228*(eh<10000)+0.0126*(eh>10000)*(eh<100000)+0.0102*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0228*(eh<10000)+0.0126*(eh>10000)*(eh<100000)+0.0102*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.0228*(eh<10000)+0.0126*(eh>10000)*(eh<100000)+0.0102*(eh>100000))*tbentrant', 'co2_c = (0.0228*(eh<10000)+0.0126*(eh>10000)*(eh<100000)+0.0102*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0228*(eh<10000)+0.0126*(eh>10000)*(eh<100000)+0.0102*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.0228*(eh<10000)+0.0126*(eh>10000)*(eh<100000)+0.0102*(eh>100000))*tbentrant', 'co2_c = (0.0228*(eh<10000)+0.0126*(eh>10000)*(eh<100000)+0.0102*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0228*(eh<10000)+0.0126*(eh>10000)*(eh<100000)+0.0102*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.0228*(eh<10000)+0.0126*(eh>10000)*(eh<100000)+0.0102*(eh>100000))*tbentrant', 'co2_c = (0.0228*(eh<10000)+0.0126*(eh>10000)*(eh<100000)+0.0102*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0228*(eh<10000)+0.0126*(eh>10000)*(eh<100000)+0.0102*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.0228*(eh<10000)+0.0126*(eh>10000)*(eh<100000)+0.0102*(eh>100000))*tbentrant', 'co2_c = (0.0228*(eh<10000)+0.0126*(eh>10000)*(eh<100000)+0.0102*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0228*(eh<10000)+0.0126*(eh>10000)*(eh<100000)+0.0102*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.0228*(eh<10000)+0.0126*(eh>10000)*(eh<100000)+0.0102*(eh>100000))*tbentrant', 'co2_c = (0.0228*(eh<10000)+0.0126*(eh>10000)*(eh<100000)+0.0102*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0228*(eh<10000)+0.0126*(eh>10000)*(eh<100000)+0.0102*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.0228*(eh<10000)+0.0126*(eh>10000)*(eh<100000)+0.0102*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant']::varchar[],
formula_name varchar[] default array['digesteur construction niveau 1', 'digesteur construction niveau 2', 'digesteur construction niveau 3', 'centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[],
eh real,
tbentrant real,
mes real,
dbo5 real,
tbsortant real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.digesteur_bloc_config(
    like ___.digesteur_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.digesteur_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('digesteur', 'bloc', ''Point'' 
    
    ) ;

select api.add_new_formula('digesteur construction niveau 1'::varchar, 'co2_c = (0.0228*(eh<10000)+0.0126*(eh>10000)*(eh<100000)+0.0102*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000'::varchar, 1, ''::text) ;
select api.add_new_formula('digesteur construction niveau 2'::varchar, 'co2_c = (0.0228*(eh<10000)+0.0126*(eh>10000)*(eh<100000)+0.0102*(eh>100000))*(dbo5/2+mes/2)/1000'::varchar, 2, ''::text) ;
select api.add_new_formula('digesteur construction niveau 3'::varchar, 'co2_c = (0.0228*(eh<10000)+0.0126*(eh>10000)*(eh<100000)+0.0102*(eh>100000))*tbentrant'::varchar, 3, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 1'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000'::varchar, 1, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 2'::varchar, 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000'::varchar, 2, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 3'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant'::varchar, 3, ''::text) ;





alter type ___.bloc_type add value 'test' ;
commit ; 
insert into ___.input_output values ('test', array['dbo5', 'q', 'eh']::varchar[], array['dbo5', 'q', 'eh']::varchar[], array['centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[]) ;

create sequence ___.test_bloc_name_seq ;     




create table ___.test_bloc(
id integer primary key,
shape ___.geo_type not null default ''Polygon'::___.geo_type',
geom geometry(''POLYGON'::___.GEO_TYPE', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('test_bloc', abbreviation=>'test_bloc'),
formula varchar[] default array['co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant']::varchar[],
formula_name varchar[] default array['centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[],
dbo5 real,
q real,
eh integer,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.test_bloc_config(
    like ___.test_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.test_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('test', 'bloc', ''Polygon'' 
    
    ) ;

select api.add_new_formula('centrifugeuse construction niveau 1'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000'::varchar, 1, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 2'::varchar, 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000'::varchar, 2, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 3'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant'::varchar, 3, ''::text) ;





alter type ___.bloc_type add value 'piptest' ;
commit ; 
insert into ___.input_output values ('piptest', array['q']::varchar[], array['q']::varchar[], array['centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[]) ;

create sequence ___.piptest_bloc_name_seq ;     




create table ___.piptest_bloc(
id integer primary key,
shape ___.geo_type not null default ''LineString'::___.geo_type',
geom geometry(''LINESTRING'::___.GEO_TYPE', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('piptest_bloc', abbreviation=>'piptest_bloc'),
formula varchar[] default array['co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant']::varchar[],
formula_name varchar[] default array['centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[],
q real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.piptest_bloc_config(
    like ___.piptest_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.piptest_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('piptest', 'bloc', ''LineString'' 
    
    ) ;

select api.add_new_formula('centrifugeuse construction niveau 1'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000'::varchar, 1, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 2'::varchar, 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000'::varchar, 2, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 3'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant'::varchar, 3, ''::text) ;





alter type ___.bloc_type add value 'file_boue' ;
commit ; 
insert into ___.input_output values ('file_boue', array['eh']::varchar[], array['tbhaut']::varchar[], array['centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[]) ;

create sequence ___.file_boue_bloc_name_seq ;     




create table ___.file_boue_bloc(
id integer primary key,
shape ___.geo_type not null default ''Polygon'::___.geo_type',
geom geometry(''POLYGON'::___.GEO_TYPE', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('file_boue_bloc', abbreviation=>'file_boue_bloc'),
formula varchar[] default array['co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant']::varchar[],
formula_name varchar[] default array['centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[],
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

select api.add_new_bloc('file_boue', 'bloc', ''Polygon'' 
    
    ) ;

select api.add_new_formula('centrifugeuse construction niveau 1'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000'::varchar, 1, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 2'::varchar, 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000'::varchar, 2, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 3'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant'::varchar, 3, ''::text) ;





alter type ___.bloc_type add value 'traitement' ;
commit ; 
insert into ___.input_output values ('traitement', array['eh', 'v', 'w', 'reac']::varchar[], array[]::varchar[], array['construction eh traitement', 'exploitation traitement eh ', 'consommation électrique', 'centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[]) ;

create sequence ___.traitement_bloc_name_seq ;     




create table ___.traitement_bloc(
id integer primary key,
shape ___.geo_type not null default ''Polygon'::___.geo_type',
geom geometry(''POLYGON'::___.GEO_TYPE', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('traitement_bloc', abbreviation=>'traitement_bloc'),
formula varchar[] default array['co2_c = eh*30*0.15', 'co2_e = 390*0.15*eh', 'co2_e = w*0.052', 'co2_c = eh*30*0.15', 'co2_e = 390*0.15*eh', 'co2_e = w*0.052', 'co2_c = eh*30*0.15', 'co2_e = 390*0.15*eh', 'co2_e = w*0.052', 'co2_c = eh*30*0.15', 'co2_e = 390*0.15*eh', 'co2_e = w*0.052', 'co2_c = eh*30*0.15', 'co2_e = 390*0.15*eh', 'co2_e = w*0.052', 'co2_c = eh*30*0.15', 'co2_e = 390*0.15*eh', 'co2_e = w*0.052', 'co2_c = eh*30*0.15', 'co2_e = 390*0.15*eh', 'co2_e = w*0.052', 'co2_c = eh*30*0.15', 'co2_e = 390*0.15*eh', 'co2_e = w*0.052', 'co2_c = eh*30*0.15', 'co2_e = 390*0.15*eh', 'co2_e = w*0.052', 'co2_c = eh*30*0.15', 'co2_e = 390*0.15*eh', 'co2_e = w*0.052', 'co2_c = eh*30*0.15', 'co2_e = 390*0.15*eh', 'co2_e = w*0.052', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant']::varchar[],
formula_name varchar[] default array['construction eh traitement', 'exploitation traitement eh ', 'consommation électrique', 'centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[],
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

select api.add_new_bloc('traitement', 'bloc', ''Polygon'' 
    
    ) ;

select api.add_new_formula('construction eh traitement'::varchar, 'co2_c = eh*30*0.15'::varchar, 1, ''::text) ;
select api.add_new_formula('exploitation traitement eh '::varchar, 'co2_e = 390*0.15*eh'::varchar, 1, ''::text) ;
select api.add_new_formula('consommation électrique'::varchar, 'co2_e = w*0.052'::varchar, 5, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 1'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000'::varchar, 1, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 2'::varchar, 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000'::varchar, 2, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 3'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant'::varchar, 3, ''::text) ;





alter type ___.bloc_type add value 'flottateur' ;
commit ; 
insert into ___.input_output values ('flottateur', array['dbo5_e', 'mes_e', 'tbhaut', 'eh']::varchar[], array['dbo5_s', 'mes_s', 'tbhaut_s']::varchar[], array['flottateur construction boue amont', 'centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[]) ;

create sequence ___.flottateur_bloc_name_seq ;     




create table ___.flottateur_bloc(
id integer primary key,
shape ___.geo_type not null default ''Point'::___.geo_type',
geom geometry(''POINT'::___.GEO_TYPE', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('flottateur_bloc', abbreviation=>'flottateur_bloc'),
formula varchar[] default array['co2_c = eh*tbhaut', 'co2_c = eh*tbhaut', 'co2_c = eh*tbhaut', 'co2_c = eh*tbhaut', 'co2_c = eh*tbhaut', 'co2_c = eh*tbhaut', 'co2_c = eh*tbhaut', 'co2_c = eh*tbhaut', 'co2_c = eh*tbhaut', 'co2_c = eh*tbhaut', 'co2_c = eh*tbhaut', 'co2_c = eh*tbhaut', 'co2_c = eh*tbhaut', 'co2_c = eh*tbhaut', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant']::varchar[],
formula_name varchar[] default array['flottateur construction boue amont', 'centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[],
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

select api.add_new_bloc('flottateur', 'bloc', ''Point'' 
    
    ) ;

select api.add_new_formula('flottateur construction boue amont'::varchar, 'co2_c = eh*tbhaut'::varchar, 3, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 1'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000'::varchar, 1, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 2'::varchar, 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000'::varchar, 2, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 3'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant'::varchar, 3, ''::text) ;





alter type ___.bloc_type add value 'usine_de_compostage' ;
commit ; 
insert into ___.input_output values ('usine_de_compostage', array['tbhaut', 'w']::varchar[], array['tbhaut']::varchar[], array['construction usine de compostage boue', 'Consommation électrique', 'centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[]) ;

create sequence ___.usine_de_compostage_bloc_name_seq ;     




create table ___.usine_de_compostage_bloc(
id integer primary key,
shape ___.geo_type not null default ''Point'::___.geo_type',
geom geometry(''POINT'::___.GEO_TYPE', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('usine_de_compostage_bloc', abbreviation=>'usine_de_compostage_bloc'),
formula varchar[] default array['co2_c = tbhaut*2.892', 'co2_e = 0.052*w', 'co2_c = tbhaut*2.892', 'co2_e = 0.052*w', 'co2_c = tbhaut*2.892', 'co2_e = 0.052*w', 'co2_c = tbhaut*2.892', 'co2_e = 0.052*w', 'co2_c = tbhaut*2.892', 'co2_e = 0.052*w', 'co2_c = tbhaut*2.892', 'co2_e = 0.052*w', 'co2_c = tbhaut*2.892', 'co2_e = 0.052*w', 'co2_c = tbhaut*2.892', 'co2_e = 0.052*w', 'co2_c = tbhaut*2.892', 'co2_e = 0.052*w', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant']::varchar[],
formula_name varchar[] default array['construction usine de compostage boue', 'Consommation électrique', 'centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[],
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

select api.add_new_bloc('usine_de_compostage', 'bloc', ''Point'' 
    
    ) ;

select api.add_new_formula('construction usine de compostage boue'::varchar, 'co2_c = tbhaut*2.892'::varchar, 1, ''::text) ;
select api.add_new_formula('Consommation électrique'::varchar, 'co2_e = 0.052*w'::varchar, 1, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 1'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000'::varchar, 1, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 2'::varchar, 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000'::varchar, 2, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 3'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant'::varchar, 3, ''::text) ;





alter type ___.bloc_type add value 'compostage' ;
commit ; 
insert into ___.input_output values ('compostage', array['d', 'tbhaut', 'eh', 'dbo5', 'mes']::varchar[], array[]::varchar[], array['compostage exploitation boue', 'centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[]) ;

create sequence ___.compostage_bloc_name_seq ;     




create table ___.compostage_bloc(
id integer primary key,
shape ___.geo_type not null default ''Point'::___.geo_type',
geom geometry(''POINT'::___.GEO_TYPE', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('compostage_bloc', abbreviation=>'compostage_bloc'),
formula varchar[] default array['co2_e = 444.5*tbhaut', 'co2_e = 444.5*tbhaut', 'co2_e = 444.5*tbhaut', 'co2_e = 444.5*tbhaut', 'co2_e = 444.5*tbhaut', 'co2_e = 444.5*tbhaut', 'co2_e = 444.5*tbhaut', 'co2_e = 444.5*tbhaut', 'co2_e = 444.5*tbhaut', 'co2_e = 444.5*tbhaut', 'co2_e = 444.5*tbhaut', 'co2_e = 444.5*tbhaut', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant']::varchar[],
formula_name varchar[] default array['compostage exploitation boue', 'centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[],
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

select api.add_new_bloc('compostage', 'bloc', ''Point'' 
    
    ) ;

select api.add_new_formula('compostage exploitation boue'::varchar, 'co2_e = 444.5*tbhaut'::varchar, 3, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 1'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000'::varchar, 1, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 2'::varchar, 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000'::varchar, 2, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 3'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant'::varchar, 3, ''::text) ;





alter type ___.bloc_type add value 'file_eau' ;
commit ; 
insert into ___.input_output values ('file_eau', array['eh', 'dco_elim']::varchar[], array[]::varchar[], array['Exploitation file eau', 'centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[]) ;

create sequence ___.file_eau_bloc_name_seq ;     




create table ___.file_eau_bloc(
id integer primary key,
shape ___.geo_type not null default ''Polygon'::___.geo_type',
geom geometry(''POLYGON'::___.GEO_TYPE', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('file_eau_bloc', abbreviation=>'file_eau_bloc'),
formula varchar[] default array['ch4_e = dco_elim*0.0002', 'ch4_e = dco_elim*0.0002', 'ch4_e = dco_elim*0.0002', 'ch4_e = dco_elim*0.0002', 'ch4_e = dco_elim*0.0002', 'ch4_e = dco_elim*0.0002', 'ch4_e = dco_elim*0.0002', 'ch4_e = dco_elim*0.0002', 'ch4_e = dco_elim*0.0002', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant']::varchar[],
formula_name varchar[] default array['Exploitation file eau', 'centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[],
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

select api.add_new_bloc('file_eau', 'bloc', ''Polygon'' 
    
    ) ;

select api.add_new_formula('Exploitation file eau'::varchar, 'ch4_e = dco_elim*0.0002'::varchar, 5, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 1'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000'::varchar, 1, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 2'::varchar, 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000'::varchar, 2, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 3'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant'::varchar, 3, ''::text) ;





alter type ___.bloc_type add value 'rejets_eau' ;
commit ; 
insert into ___.input_output values ('rejets_eau', array['eh', 'ngl', 'dco', 'oxi', 'milieu']::varchar[], array[]::varchar[], array['emission exploitation rejets eau azote', 'emission exploitation rejets eau méthane', 'centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[]) ;

create sequence ___.rejets_eau_bloc_name_seq ;     

create type ___.oxi_type as enum ('bien oxygéné', 'peu oxygéné');
create type ___.milieu_type as enum ('réserve,lac, estuaire', 'autres');

create table ___.oxi_type_table(val ___.oxi_type primary key, FE real, description text);
insert into ___.oxi_type_table(val) values ('bien oxygéné') ;
insert into ___.oxi_type_table(val) values ('peu oxygéné') ;
create table ___.milieu_type_table(val ___.milieu_type primary key, FE real, description text);
insert into ___.milieu_type_table(val) values ('réserve,lac, estuaire') ;
insert into ___.milieu_type_table(val) values ('autres') ;

select template.basic_view('oxi_type_table') ;
select template.basic_view('milieu_type_table') ;

create table ___.rejets_eau_bloc(
id integer primary key,
shape ___.geo_type not null default ''Point'::___.geo_type',
geom geometry(''POINT'::___.GEO_TYPE', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('rejets_eau_bloc', abbreviation=>'rejets_eau_bloc'),
formula varchar[] default array['n2o_e = ngl*oxi', 'ch4_e = dco*milieu', 'n2o_e = ngl*oxi', 'ch4_e = dco*milieu', 'n2o_e = ngl*oxi', 'ch4_e = dco*milieu', 'n2o_e = ngl*oxi', 'ch4_e = dco*milieu', 'n2o_e = ngl*oxi', 'ch4_e = dco*milieu', 'n2o_e = ngl*oxi', 'ch4_e = dco*milieu', 'n2o_e = ngl*oxi', 'ch4_e = dco*milieu', 'n2o_e = ngl*oxi', 'ch4_e = dco*milieu', 'n2o_e = ngl*oxi', 'ch4_e = dco*milieu', 'n2o_e = ngl*oxi', 'ch4_e = dco*milieu', 'n2o_e = ngl*oxi', 'ch4_e = dco*milieu', 'n2o_e = ngl*oxi', 'ch4_e = dco*milieu', 'n2o_e = ngl*oxi', 'ch4_e = dco*milieu', 'n2o_e = ngl*oxi', 'ch4_e = dco*milieu', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant']::varchar[],
formula_name varchar[] default array['emission exploitation rejets eau azote', 'emission exploitation rejets eau méthane', 'centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[],
eh real,
ngl real,
dco real,
oxi ___.oxi_type not null default 'bien oxygéné' references ___.oxi_type_table(val) default 'peu oxygéné'::___.oxi_type,
milieu ___.milieu_type not null default 'réserve,lac, estuaire' references ___.milieu_type_table(val) default 'réserve,lac, estuaire'::___.milieu_type,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.rejets_eau_bloc_config(
    like ___.rejets_eau_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.rejets_eau_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('rejets_eau', 'bloc', ''Point'' 
    ,additional_columns => '{oxi_type_table.FE as oxi_FE, oxi_type_table.description as oxi_description, milieu_type_table.FE as milieu_FE, milieu_type_table.description as milieu_description}'
    ,additional_join => 'left join ___.oxi_type_table on oxi_type_table.val = c.oxi  join ___.milieu_type_table on milieu_type_table.val = c.milieu ') ;

select api.add_new_formula('emission exploitation rejets eau azote'::varchar, 'n2o_e = ngl*oxi'::varchar, 3, ''::text) ;
select api.add_new_formula('emission exploitation rejets eau méthane'::varchar, 'ch4_e = dco*milieu'::varchar, 3, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 1'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000'::varchar, 1, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 2'::varchar, 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000'::varchar, 2, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 3'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant'::varchar, 3, ''::text) ;





alter type ___.bloc_type add value 'lien' ;
commit ; 
insert into ___.input_output values ('lien', array[]::varchar[], array[]::varchar[], array['centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[]) ;

create sequence ___.lien_bloc_name_seq ;     




create table ___.lien_bloc(
id integer primary key,
shape ___.geo_type not null default ''LineString'::___.geo_type',
geom geometry(''LINESTRING'::___.GEO_TYPE', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('lien_bloc', abbreviation=>'lien_bloc'),
formula varchar[] default array['co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant']::varchar[],
formula_name varchar[] default array['centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[],

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.lien_bloc_config(
    like ___.lien_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.lien_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('lien', 'bloc', ''LineString'' 
    
    ) ;

select api.add_new_formula('centrifugeuse construction niveau 1'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000'::varchar, 1, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 2'::varchar, 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000'::varchar, 2, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 3'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant'::varchar, 3, ''::text) ;





alter type ___.bloc_type add value 'table_degouttage' ;
commit ; 
insert into ___.input_output values ('table_degouttage', array['eh', 'dbo5', 'mes', 'tbentrant']::varchar[], array['tbentrant', 'tbsortant']::varchar[], array['table egouttage construction niveau 1', 'table egouttage construction niveau 2', 'table egouttage construction niveau 3', 'centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[]) ;

create sequence ___.table_degouttage_bloc_name_seq ;     




create table ___.table_degouttage_bloc(
id integer primary key,
shape ___.geo_type not null default ''Point'::___.geo_type',
geom geometry(''POINT'::___.GEO_TYPE', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('table_degouttage_bloc', abbreviation=>'table_degouttage_bloc'),
formula varchar[] default array['co2_c = (0.0044*(eh<10000)+0.0022*(eh>10000)*(eh<100000)+0.0018*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0044*(eh<10000)+0.0022*(eh>10000)*(eh<100000)+0.0018*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*tbentrant', 'co2_c = (0.0044*(eh<10000)+0.0022*(eh>10000)*(eh<100000)+0.0018*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0044*(eh<10000)+0.0022*(eh>10000)*(eh<100000)+0.0018*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*tbentrant', 'co2_c = (0.0044*(eh<10000)+0.0022*(eh>10000)*(eh<100000)+0.0018*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0044*(eh<10000)+0.0022*(eh>10000)*(eh<100000)+0.0018*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*tbentrant', 'co2_c = (0.0044*(eh<10000)+0.0022*(eh>10000)*(eh<100000)+0.0018*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0044*(eh<10000)+0.0022*(eh>10000)*(eh<100000)+0.0018*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*tbentrant', 'co2_c = (0.0044*(eh<10000)+0.0022*(eh>10000)*(eh<100000)+0.0018*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0044*(eh<10000)+0.0022*(eh>10000)*(eh<100000)+0.0018*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*tbentrant', 'co2_c = (0.0044*(eh<10000)+0.0022*(eh>10000)*(eh<100000)+0.0018*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0044*(eh<10000)+0.0022*(eh>10000)*(eh<100000)+0.0018*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*tbentrant', 'co2_c = (0.0044*(eh<10000)+0.0022*(eh>10000)*(eh<100000)+0.0018*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0044*(eh<10000)+0.0022*(eh>10000)*(eh<100000)+0.0018*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*tbentrant', 'co2_c = (0.0044*(eh<10000)+0.0022*(eh>10000)*(eh<100000)+0.0018*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0044*(eh<10000)+0.0022*(eh>10000)*(eh<100000)+0.0018*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*tbentrant', 'co2_c = (0.0044*(eh<10000)+0.0022*(eh>10000)*(eh<100000)+0.0018*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0044*(eh<10000)+0.0022*(eh>10000)*(eh<100000)+0.0018*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*tbentrant', 'co2_c = (0.0044*(eh<10000)+0.0022*(eh>10000)*(eh<100000)+0.0018*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0044*(eh<10000)+0.0022*(eh>10000)*(eh<100000)+0.0018*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*tbentrant', 'co2_c = (0.0044*(eh<10000)+0.0022*(eh>10000)*(eh<100000)+0.0018*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0044*(eh<10000)+0.0022*(eh>10000)*(eh<100000)+0.0018*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*tbentrant', 'co2_c = (0.0044*(eh<10000)+0.0022*(eh>10000)*(eh<100000)+0.0018*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0044*(eh<10000)+0.0022*(eh>10000)*(eh<100000)+0.0018*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant']::varchar[],
formula_name varchar[] default array['table egouttage construction niveau 1', 'table egouttage construction niveau 2', 'table egouttage construction niveau 3', 'centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[],
eh real,
dbo5 real,
mes real,
tbentrant real,
tbsortant real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.table_degouttage_bloc_config(
    like ___.table_degouttage_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.table_degouttage_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('table_degouttage', 'bloc', ''Point'' 
    
    ) ;

select api.add_new_formula('table egouttage construction niveau 1'::varchar, 'co2_c = (0.0044*(eh<10000)+0.0022*(eh>10000)*(eh<100000)+0.0018*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000'::varchar, 1, ''::text) ;
select api.add_new_formula('table egouttage construction niveau 2'::varchar, 'co2_c = (0.0044*(eh<10000)+0.0022*(eh>10000)*(eh<100000)+0.0018*(eh>100000))*(dbo5/2+mes/2)/1000'::varchar, 2, ''::text) ;
select api.add_new_formula('table egouttage construction niveau 3'::varchar, 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*tbentrant'::varchar, 3, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 1'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000'::varchar, 1, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 2'::varchar, 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000'::varchar, 2, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 3'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant'::varchar, 3, ''::text) ;





alter type ___.bloc_type add value 'centrifugeuse_pour_epais' ;
commit ; 
insert into ___.input_output values ('centrifugeuse_pour_epais', array['eh', 'mes', 'dbo5', 'tbentrant']::varchar[], array['tbentrant', 'tbsortant']::varchar[], array['centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[]) ;

create sequence ___.centrifugeuse_pour_epais_bloc_name_seq ;     




create table ___.centrifugeuse_pour_epais_bloc(
id integer primary key,
shape ___.geo_type not null default ''Point'::___.geo_type',
geom geometry(''POINT'::___.GEO_TYPE', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('centrifugeuse_pour_epais_bloc', abbreviation=>'centrifugeuse_pour_epais_bloc'),
formula varchar[] default array['co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000', 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000', 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant']::varchar[],
formula_name varchar[] default array['centrifugeuse construction niveau 1', 'centrifugeuse construction niveau 2', 'centrifugeuse construction niveau 3']::varchar[],
eh real,
mes real,
dbo5 real,
tbentrant real,
tbsortant real,

foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.centrifugeuse_pour_epais_bloc_config(
    like ___.centrifugeuse_pour_epais_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.centrifugeuse_pour_epais_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('centrifugeuse_pour_epais', 'bloc', ''Point'' 
    
    ) ;

select api.add_new_formula('centrifugeuse construction niveau 1'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*((0.06*eh)/2+(0.09*eh)/2)/1000'::varchar, 1, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 2'::varchar, 'co2_c = (0.0245*(eh<10000)+0.0109*(eh>10000)*(eh<100000)+0.0096*(eh>100000))*(dbo5/2+mes/2)/1000'::varchar, 2, ''::text) ;
select api.add_new_formula('centrifugeuse construction niveau 3'::varchar, 'co2_c = (0.1296*(eh<10000)+0.0759*(eh>10000)*(eh<100000)+0.1363*(eh>100000))*tbentrant'::varchar, 3, ''::text) ;



update api.tsejour_type_table set fe = 0.0833, description = 'kgDBO5/m3/j' where val = 'Faible charge' ;
update api.tsejour_type_table set fe = 0.20833, description = 'kgDBO5/m3/j' where val = 'Moyenne charge' ;
update api.tsejour_type_table set fe = 0.417, description = 'kgDBO5/m3/j' where val = 'Forte charge' ;
update api.oxi_type_table set fe = 3.03, description = 'kgNO2/kgNGL pour un milieu bien oxygéné (concentration en O2 supérieu à 3 mg/L)' where val = 'bien oxygéné' ;
update api.oxi_type_table set fe = 1.46, description = 'kgNO2/kgNGL pour un milieu peu oxygéné (concentration en O2 entre 0.1 et 3 mg/L)' where val = 'peu oxygéné' ;
update api.milieu_type_table set fe = 0.2682, description = '' where val = 'réserve,lac, estuaire' ;
update api.milieu_type_table set fe = 1.4304, description = '' where val = 'autres' ;
