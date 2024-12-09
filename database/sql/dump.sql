-- cycle version 0.0.1
-- project SRID 2154
INSERT INTO api.model (name, creation_date, comment) VALUES ('step_tigery', '2024-11-15 00:00:00', NULL);
--
-- PostgreSQL database dump
--

-- Dumped from database version 13.3
-- Dumped by pg_dump version 16.2


--
-- Data for Name: model; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: bassin_biologique_bloc; Type: TABLE DATA; Schema: api; Owner: -
--

INSERT INTO api.bassin_biologique_bloc (id, shape, geom, name, formula, formula_name, prod_e, d_vie, charge_bio, e, eh, tauenterre, h, abatdco, abatngl, q_caco3, transp_catio, transp_co2l, transp_poly, transp_oxyl, transp_chaux, q_nahso3, q_co2l, transp_sulf, q_kmno4, q_nitrique, q_hcl, q_lait, transp_javel, q_phosphorique, q_ca_regen, q_chaux, q_sable_t, transp_ethanol, transp_rei, transp_citrique, transp_anti_mousse, transp_naclo3, q_fecl3, q_mhetanol, q_uree, q_cl2, transp_ca_regen, q_soude_c, q_ethanol, transp_ca_neuf, transp_mhetanol, transp_nitrique, transp_ca_poudre, q_anti_mousse, transp_phosphorique, q_coagl, transp_caco3, transp_sulf_sod, q_citrique, q_oxyl, q_naclo3, transp_coagl, q_poly, q_ca_poudre, transp_soude_c, q_h2o2, transp_lait, q_catio, q_sulf_sod, transp_kmno4, q_sulf_alu, q_antiscalant, q_javel, transp_soude, transp_sable_t, transp_fecl3, transp_anio, transp_sulf_alu, q_rei, q_sulf, transp_hcl, transp_antiscalant, q_ca_neuf, transp_nahso3, transp_uree, q_soude, q_anio, transp_cl2, transp_h2o2, dbo5elim, w_dbo5_eau, dbo5, dco, ntk, mes, vu, welec, ngl_s, dco_s, qe_s,model) VALUES (4, 'Point', '01010000206A0800009CF4E2CC6D392441C479C439AF155A41', 'bassin_biologique_1', '{"dco_s=eh*dco_eh*(1 - abatdco)","ngl_s=eh*ntk_eh*(1 - abatngl)","co2_c=(febet*cad*e*rhobet*(24*eh*dbo5_eh + 3.14159*h**2*charge_bio*(e + 5.52791*(eh*dbo5_eh/(h*charge_bio))**0.5)) + 24.0*fepelle*h*charge_bio*tauenterre*(h + e)*(0.3618*e + (eh*dbo5_eh/(h*charge_bio))**0.5)**2 + 24.0*h*cad*charge_bio*(0.3618*e + (eh*dbo5_eh/(h*charge_bio))**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad*charge_bio)","ngl_s=ntk*(1 - abatngl)",co2_e=feelec*welec,"tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)","dco_s=dco*(1 - abatdco)","co2_c=(febet*cad*e*rhobet*(24*dbo5 + 3.14159*h**2*charge_bio*(e + 5.52791*(dbo5/(h*charge_bio))**0.5)) + 24.0*fepelle*h*charge_bio*tauenterre*(h + e)*(0.3618*e + (dbo5/(h*charge_bio))**0.5)**2 + 24.0*h*cad*charge_bio*(0.3618*e + (dbo5/(h*charge_bio))**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad*charge_bio)","tbentrant=0.0005*nbjour*(dbo5 + mes)","co2_c=(febet*cad*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*fepelle*h*tauenterre*(h + e)*(0.3618*e + (vu/h)**0.5)**2 + 24.0*h*cad*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad)",co2_e=feelec*dbo5elim*w_dbo5_eau,"co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)"}', '{"dco_s decanteur_lamellaire 3","ngl_s dessableurdegraisseur 3","CO2 construction bassin_biologique 1","ngl_s dessableurdegraisseur 3","CO2 elec 6","tbentrant tamis 1","dco_s decanteur_lamellaire 3","CO2 construction bassin_biologique 2","tbentrant centrifugeuse_pour_epais 2","CO2 construction bassin_cylindrique 3","CO2 exploitation lagunage 3","CO2 exploitation intrant decanteur_lamellaire 6"}', 'Méthanol', 50, 'Charge faible', 0.25, NULL, 0.75, 4, NULL, NULL, NULL, 50, 50, 50, 50, 50, NULL, NULL, 50, NULL, NULL, NULL, NULL, 50, NULL, NULL, NULL, NULL, 50, 50, 50, 50, 50, NULL, NULL, NULL, NULL, 50, NULL, NULL, 50, 50, 50, 50, NULL, 50, NULL, 50, 50, NULL, NULL, NULL, 50, NULL, NULL, 50, NULL, 50, NULL, NULL, 50, NULL, NULL, NULL, 50, 50, 50, 50, 50, NULL, NULL, 50, 50, NULL, 50, 50, NULL, NULL, 50, 50, NULL, 5, NULL, 5.74875e+06, NULL, NULL, 6511.6, NULL, 215350, 689850, 16712, 'step_tigery');
INSERT INTO api.bassin_biologique_bloc (id, shape, geom, name, formula, formula_name, prod_e, d_vie, charge_bio, e, eh, tauenterre, h, abatdco, abatngl, q_caco3, transp_catio, transp_co2l, transp_poly, transp_oxyl, transp_chaux, q_nahso3, q_co2l, transp_sulf, q_kmno4, q_nitrique, q_hcl, q_lait, transp_javel, q_phosphorique, q_ca_regen, q_chaux, q_sable_t, transp_ethanol, transp_rei, transp_citrique, transp_anti_mousse, transp_naclo3, q_fecl3, q_mhetanol, q_uree, q_cl2, transp_ca_regen, q_soude_c, q_ethanol, transp_ca_neuf, transp_mhetanol, transp_nitrique, transp_ca_poudre, q_anti_mousse, transp_phosphorique, q_coagl, transp_caco3, transp_sulf_sod, q_citrique, q_oxyl, q_naclo3, transp_coagl, q_poly, q_ca_poudre, transp_soude_c, q_h2o2, transp_lait, q_catio, q_sulf_sod, transp_kmno4, q_sulf_alu, q_antiscalant, q_javel, transp_soude, transp_sable_t, transp_fecl3, transp_anio, transp_sulf_alu, q_rei, q_sulf, transp_hcl, transp_antiscalant, q_ca_neuf, transp_nahso3, transp_uree, q_soude, q_anio, transp_cl2, transp_h2o2, dbo5elim, w_dbo5_eau, dbo5, dco, ntk, mes, vu, welec, ngl_s, dco_s, qe_s,model) VALUES (19, 'Point', '01010000206A0800005E1F6C53EF392441DBAE4502A5155A41', 'bassin_biologique_2', '{"dco_s=eh*dco_eh*(1 - abatdco)","ngl_s=eh*ntk_eh*(1 - abatngl)","co2_c=(febet*cad*e*rhobet*(24*eh*dbo5_eh + 3.14159*h**2*charge_bio*(e + 5.52791*(eh*dbo5_eh/(h*charge_bio))**0.5)) + 24.0*fepelle*h*charge_bio*tauenterre*(h + e)*(0.3618*e + (eh*dbo5_eh/(h*charge_bio))**0.5)**2 + 24.0*h*cad*charge_bio*(0.3618*e + (eh*dbo5_eh/(h*charge_bio))**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad*charge_bio)","ngl_s=ntk*(1 - abatngl)",co2_e=feelec*welec,"tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)","dco_s=dco*(1 - abatdco)","co2_c=(febet*cad*e*rhobet*(24*dbo5 + 3.14159*h**2*charge_bio*(e + 5.52791*(dbo5/(h*charge_bio))**0.5)) + 24.0*fepelle*h*charge_bio*tauenterre*(h + e)*(0.3618*e + (dbo5/(h*charge_bio))**0.5)**2 + 24.0*h*cad*charge_bio*(0.3618*e + (dbo5/(h*charge_bio))**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad*charge_bio)","tbentrant=0.0005*nbjour*(dbo5 + mes)","co2_c=(febet*cad*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*fepelle*h*tauenterre*(h + e)*(0.3618*e + (vu/h)**0.5)**2 + 24.0*h*cad*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad)",co2_e=feelec*dbo5elim*w_dbo5_eau,"co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)"}', '{"dco_s decanteur_lamellaire 3","ngl_s dessableurdegraisseur 3","CO2 construction bassin_biologique 1","ngl_s dessableurdegraisseur 3","CO2 elec 6","tbentrant tamis 1","dco_s decanteur_lamellaire 3","CO2 construction bassin_biologique 2","tbentrant centrifugeuse_pour_epais 2","CO2 construction bassin_cylindrique 3","CO2 exploitation lagunage 3","CO2 exploitation intrant decanteur_lamellaire 6"}', 'Méthanol', 50, 'Charge moyenne', 0.25, NULL, 0.75, 4, NULL, NULL, NULL, 50, 50, 50, 50, 50, NULL, NULL, 50, NULL, NULL, NULL, NULL, 50, NULL, NULL, NULL, NULL, 50, 50, 50, 50, 50, NULL, NULL, NULL, NULL, 50, NULL, NULL, 50, 50, 50, 50, NULL, 50, NULL, 50, 50, NULL, NULL, NULL, 50, NULL, NULL, 50, NULL, 50, NULL, NULL, 50, NULL, NULL, NULL, 50, 50, 50, 50, 50, NULL, NULL, 50, 50, NULL, 50, 50, NULL, NULL, 50, 50, NULL, 5, NULL, 5.74875e+06, NULL, NULL, 6511.6, NULL, 21, 689850, NULL, 'step_tigery');


--
-- Data for Name: bassin_cylindrique_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: bassin_dorage_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: batiment_dexploitation_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: branchement_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: brm_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: canalisation_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: centrifugeuse_pour_deshy_bloc; Type: TABLE DATA; Schema: api; Owner: -
--

INSERT INTO api.centrifugeuse_pour_deshy_bloc (id, shape, geom, name, formula, formula_name, d_vie, q_poly, transp_poly, direct, tbsortant, eh, dbo5, mes, tbentrant, welec, tbsortant_s,model) VALUES (22, 'Point', '01010000206A080000C9996062E13A2441AAFE60095D155A41', 'centrifugeuse_pour_deshy_1', '{"co2_e=0.001*q_poly*(1000*fepolymere + fetransp*transp_poly)","tbentrant=0.0005*nbjour*(dbo5 + mes)",co2_c=((feobj10_cd)*(eh<10000)+(feobj50_cd)*(eh>10000)*(eh<100000)+(feobj100_cd)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour),co2_c=((feobj10_cd)*(eh<10000)+(feobj50_cd)*(eh>10000)*(eh<100000)+(feobj100_cd)*(eh>100000))*tbentrant,"tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)","co2_e=feelec*tbsortant*(-welec_cd*direct + welec_cd + welec_direct*direct)",co2_e=feelec*welec,co2_c=((feobj10_cd)*(eh<10000)+(feobj50_cd)*(eh>10000)*(eh<100000)+(feobj100_cd)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour)}', '{"CO2 exploitation q_poly centrifugeuse_pour_epais 6","tbentrant centrifugeuse_pour_deshy 2","CO2 construction centrifugeuse_pour_deshy 1","CO2 construction centrifugeuse_pour_deshy 3","tbentrant centrifugeuse_pour_deshy 1","CO2 exploitation centrifugeuse_pour_deshy 3","CO2 elec 6","CO2 construction centrifugeuse_pour_deshy 2"}', 15, 10, 50, false, 875, 105000, NULL, NULL, 875, NULL, 884, 'step_tigery');
INSERT INTO api.centrifugeuse_pour_deshy_bloc (id, shape, geom, name, formula, formula_name, d_vie, q_poly, transp_poly, direct, tbsortant, eh, dbo5, mes, tbentrant, welec, tbsortant_s,model) VALUES (8, 'Point', '01010000206A0800003645A8C4CE3B24414A18C9B36D155A41', 'centrifugeuse_pour_deshy_3', '{"co2_e=feelec*tbsortant*(-welec_cd*direct + welec_cd + welec_direct*direct)","co2_e=0.001*q_poly*(1000*fepolymere + fetransp*transp_poly)",co2_e=feelec*welec,"tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)",co2_c=((feobj10_cd)*(eh<10000)+(feobj50_cd)*(eh>10000)*(eh<100000)+(feobj100_cd)*(eh>100000))*tbentrant,"tbentrant=0.0005*nbjour*(dbo5 + mes)",co2_c=((feobj10_cd)*(eh<10000)+(feobj50_cd)*(eh>10000)*(eh<100000)+(feobj100_cd)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour),co2_c=((feobj10_cd)*(eh<10000)+(feobj50_cd)*(eh>10000)*(eh<100000)+(feobj100_cd)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)}', '{"CO2 exploitation centrifugeuse_pour_deshy 3","CO2 exploitation q_poly filtre_a_bande 6","CO2 elec 6","tbentrant tamis 1","CO2 construction centrifugeuse_pour_deshy 3","tbentrant centrifugeuse_pour_epais 2","CO2 construction centrifugeuse_pour_deshy 2","CO2 construction centrifugeuse_pour_deshy 1"}', 15, NULL, 50, false, 875, 105000, NULL, NULL, 875, NULL, 884, 'step_tigery');
INSERT INTO api.centrifugeuse_pour_deshy_bloc (id, shape, geom, name, formula, formula_name, d_vie, q_poly, transp_poly, direct, tbsortant, eh, dbo5, mes, tbentrant, welec, tbsortant_s,model) VALUES (7, 'Point', '01010000206A0800004541EF30463B2441C795ABFA65155A41', 'centrifugeuse_pour_deshy_2', '{"co2_e=feelec*tbsortant*(-welec_cd*direct + welec_cd + welec_direct*direct)","co2_e=0.001*q_poly*(1000*fepolymere + fetransp*transp_poly)",co2_e=feelec*welec,"tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)",co2_c=((feobj10_cd)*(eh<10000)+(feobj50_cd)*(eh>10000)*(eh<100000)+(feobj100_cd)*(eh>100000))*tbentrant,"tbentrant=0.0005*nbjour*(dbo5 + mes)",co2_c=((feobj10_cd)*(eh<10000)+(feobj50_cd)*(eh>10000)*(eh<100000)+(feobj100_cd)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour),co2_c=((feobj10_cd)*(eh<10000)+(feobj50_cd)*(eh>10000)*(eh<100000)+(feobj100_cd)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)}', '{"CO2 exploitation centrifugeuse_pour_deshy 3","CO2 exploitation q_poly filtre_a_bande 6","CO2 elec 6","tbentrant tamis 1","CO2 construction centrifugeuse_pour_deshy 3","tbentrant centrifugeuse_pour_epais 2","CO2 construction centrifugeuse_pour_deshy 2","CO2 construction centrifugeuse_pour_deshy 1"}', 15, NULL, 50, false, 875, 105000, NULL, NULL, 875, NULL, 884, 'step_tigery');


--
-- Data for Name: centrifugeuse_pour_epais_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: chateau_deau_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: chaulage_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: clarificateur_bloc; Type: TABLE DATA; Schema: api; Owner: -
--

INSERT INTO api.clarificateur_bloc (id, shape, geom, name, formula, formula_name, prod_e, d_vie, e, vit, eh, tauenterre, taur, h, abatdco, abatngl, q_caco3, transp_catio, transp_co2l, transp_poly, transp_oxyl, transp_chaux, q_nahso3, q_co2l, transp_sulf, q_kmno4, q_nitrique, q_hcl, q_lait, transp_javel, q_phosphorique, q_ca_regen, q_chaux, q_sable_t, transp_ethanol, transp_rei, transp_citrique, transp_anti_mousse, transp_naclo3, q_fecl3, q_mhetanol, q_uree, q_cl2, transp_ca_regen, q_soude_c, q_ethanol, transp_ca_neuf, transp_mhetanol, transp_nitrique, transp_ca_poudre, q_anti_mousse, transp_phosphorique, q_coagl, transp_caco3, transp_sulf_sod, q_citrique, q_oxyl, q_naclo3, transp_coagl, q_poly, q_ca_poudre, transp_soude_c, q_h2o2, transp_lait, q_catio, q_sulf_sod, transp_kmno4, q_sulf_alu, q_antiscalant, q_javel, transp_soude, transp_sable_t, transp_fecl3, transp_anio, transp_sulf_alu, q_rei, q_sulf, transp_hcl, transp_antiscalant, q_ca_neuf, transp_nahso3, transp_uree, q_soude, q_anio, transp_cl2, transp_h2o2, dbo5elim, w_dbo5_eau, qe, dco, ntk, mes, dbo5, vu, welec, tbentrant_s, ngl_s, dco_s, qe_s,model) VALUES (18, 'Point', '01010000206A080000F84ADB28A63924413C7F51679E155A41', 'clarificateur_2', '{"dco_s=eh*dco_eh*(1 - abatdco)","ngl_s=eh*ntk_eh*(1 - abatngl)","ngl_s=ntk*(1 - abatngl)",co2_e=feelec*welec,"tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)","dco_s=dco*(1 - abatdco)","co2_c=(febet*cad*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*fepelle*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2 + 24.0*cad*vit*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(cad*vit)","co2_c=(febet*cad*e*rhobet*(24*eh*qe_eh*(taur + 1) + 3.14159*h*vit*(e + 5.52791*(eh*qe_eh*(taur + 1)/vit)**0.5)) + 24.0*fepelle*tauenterre*vit*(h + e)*(0.3618*e + (eh*qe_eh*(taur + 1)/vit)**0.5)**2 + 24.0*cad*vit*(0.3618*e + (eh*qe_eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(cad*vit)","tbentrant=0.0005*nbjour*(dbo5 + mes)","co2_c=(febet*cad*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*fepelle*h*tauenterre*(h + e)*(0.3618*e + (vu/h)**0.5)**2 + 24.0*h*cad*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad)",co2_e=feelec*dbo5elim*w_dbo5_eau,"co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)"}', '{"dco_s decanteur_lamellaire 3","ngl_s dessableurdegraisseur 3","ngl_s dessableurdegraisseur 3","CO2 elec 6","tbentrant tamis 1","dco_s decanteur_lamellaire 3","CO2 construction clarificateur 2","CO2 construction clarificateur 1","tbentrant centrifugeuse_pour_epais 2","CO2 construction bassin_cylindrique 3","CO2 exploitation lagunage 3","CO2 exploitation intrant decanteur_lamellaire 6"}', 'Méthanol', 50, 0.25, 60, NULL, 0.75, 1, 3, NULL, NULL, NULL, 50, 50, 50, 50, 50, NULL, NULL, 50, NULL, NULL, NULL, NULL, 50, NULL, NULL, NULL, NULL, 50, 50, 50, 50, 50, NULL, NULL, NULL, NULL, 50, NULL, NULL, 50, 50, 50, 50, NULL, 50, NULL, 50, 50, NULL, NULL, NULL, 50, NULL, NULL, 50, NULL, 50, NULL, NULL, 50, NULL, NULL, NULL, 50, 50, 50, 50, 50, NULL, NULL, 50, 50, NULL, 50, 50, NULL, NULL, 50, 50, NULL, 5, 16712, 689850, NULL, NULL, NULL, NULL, NULL, 517387, 215350, 689, 16712, 'step_tigery');
INSERT INTO api.clarificateur_bloc (id, shape, geom, name, formula, formula_name, prod_e, d_vie, e, vit, eh, tauenterre, taur, h, abatdco, abatngl, q_caco3, transp_catio, transp_co2l, transp_poly, transp_oxyl, transp_chaux, q_nahso3, q_co2l, transp_sulf, q_kmno4, q_nitrique, q_hcl, q_lait, transp_javel, q_phosphorique, q_ca_regen, q_chaux, q_sable_t, transp_ethanol, transp_rei, transp_citrique, transp_anti_mousse, transp_naclo3, q_fecl3, q_mhetanol, q_uree, q_cl2, transp_ca_regen, q_soude_c, q_ethanol, transp_ca_neuf, transp_mhetanol, transp_nitrique, transp_ca_poudre, q_anti_mousse, transp_phosphorique, q_coagl, transp_caco3, transp_sulf_sod, q_citrique, q_oxyl, q_naclo3, transp_coagl, q_poly, q_ca_poudre, transp_soude_c, q_h2o2, transp_lait, q_catio, q_sulf_sod, transp_kmno4, q_sulf_alu, q_antiscalant, q_javel, transp_soude, transp_sable_t, transp_fecl3, transp_anio, transp_sulf_alu, q_rei, q_sulf, transp_hcl, transp_antiscalant, q_ca_neuf, transp_nahso3, transp_uree, q_soude, q_anio, transp_cl2, transp_h2o2, dbo5elim, w_dbo5_eau, qe, dco, ntk, mes, dbo5, vu, welec, tbentrant_s, ngl_s, dco_s, qe_s,model) VALUES (37, 'Point', '01010000206A080000F20658A72B3924416F46FC15AA155A41', 'clarificateur_1', '{"ngl_s=eh*ntk_eh*(1 - abatngl)","tbentrant=0.0005*nbjour*(dbo5 + mes)","co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)","co2_c=(febet*e*rhobet*(24*eh*qe_eh*(taur + 1) + 3.14159*h*vit*(e + 5.52791*(eh*qe_eh*(taur + 1)/vit)**0.5)) + 24.0*vit*(0.3618*e + (eh*qe_eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda + fepelle*cad*tauenterre*(h + e)))/vit","tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)","co2_c=(febet*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*h*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda + fepelle*cad*tauenterre*(h + e)))/h",co2_e=feelec*welec,co2_e=feelec*dbo5elim*w_dbo5_eau,"dco_s=eh*dco_eh*(1 - abatdco)","co2_c=(febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*vit*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda + fepelle*cad*tauenterre*(h + e)))/vit","dco_s=dco*(1 - abatdco)","ngl_s=ntk*(1 - abatngl)"}', '{"ngl_s bassin_biologique 3","tbentrant centrifugeuse_pour_deshy 2","CO2 exploitation intrant bassin_biologique 6","CO2 construction clarificateur 1","tbentrant centrifugeuse_pour_deshy 1","CO2 construction bassin_cylindrique 3","CO2 elec 6","CO2 exploitation lagunage 3","dco_s bassin_biologique 3","CO2 construction clarificateur 2","dco_s bassin_biologique 3","ngl_s bassin_biologique 3"}', 'Sulfate de sodium', 50, 0.25, 60, 105000, 0.75, 1, 3, NULL, NULL, NULL, 50, 50, 50, 50, 50, NULL, NULL, 50, NULL, NULL, NULL, NULL, 50, NULL, NULL, NULL, NULL, 50, 50, 50, 50, 50, NULL, NULL, NULL, NULL, 50, NULL, NULL, 50, 50, 50, 50, NULL, 50, NULL, 50, 50, NULL, NULL, NULL, 50, NULL, NULL, 50, NULL, 50, NULL, NULL, 50, NULL, NULL, NULL, 50, 50, 50, 50, 50, NULL, NULL, 50, 50, NULL, 50, 50, NULL, NULL, 50, 50, NULL, 5, 16712, 5.74875e+06, NULL, NULL, NULL, NULL, NULL, 517387, 215350, 689, 16712, 'step_tigery');


--
-- Data for Name: cloture_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: compostage_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: conditionnement_chimique_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: conditionnement_thermiqu_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: decanteur_lamellaire_bloc; Type: TABLE DATA; Schema: api; Owner: -
--

INSERT INTO api.decanteur_lamellaire_bloc (id, shape, geom, name, formula, formula_name, prod_e, d_vie, eh, abatdco, abatngl, q_caco3, transp_catio, transp_co2l, transp_poly, transp_oxyl, transp_chaux, q_nahso3, q_co2l, transp_sulf, q_kmno4, q_nitrique, q_hcl, q_lait, transp_javel, q_phosphorique, q_ca_regen, q_chaux, q_sable_t, transp_ethanol, transp_rei, transp_citrique, transp_anti_mousse, transp_naclo3, q_fecl3, q_mhetanol, q_uree, q_cl2, transp_ca_regen, q_soude_c, q_ethanol, transp_ca_neuf, transp_mhetanol, transp_nitrique, transp_ca_poudre, q_anti_mousse, transp_phosphorique, q_coagl, transp_caco3, transp_sulf_sod, q_citrique, q_oxyl, q_naclo3, transp_coagl, q_poly, q_ca_poudre, transp_soude_c, q_h2o2, transp_lait, q_catio, q_sulf_sod, transp_kmno4, q_sulf_alu, q_antiscalant, q_javel, transp_soude, transp_sable_t, transp_fecl3, transp_anio, transp_sulf_alu, q_rei, q_sulf, transp_hcl, transp_antiscalant, q_ca_neuf, transp_nahso3, transp_uree, q_soude, q_anio, transp_cl2, transp_h2o2, dbo5elim, w_dbo5_eau, dco, ntk, mes, dbo5, long, e, larg, tauenterre, h, welec, ngl_s, dco_s, qe_s,model) VALUES (13, 'Point', '01010000206A080000CE89C590BA3A244149F6B3EAAE155A41', 'decanteur_lamellaire_2', '{"dco_s=eh*dco_eh*(1 - abatdco)","ngl_s=eh*ntk_eh*(1 - abatngl)","ngl_s=ntk*(1 - abatngl)",co2_e=feelec*welec,"tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)","dco_s=dco*(1 - abatdco)","tbentrant=0.0005*nbjour*(dbo5 + mes)",co2_e=feelec*dbo5elim*w_dbo5_eau,"co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)","co2_c=(fepelle*tauenterre*(h + e)*(e + larg)*(e + long) + cad*(febet*e*rhobet*(larg*long + 2*larg*(h + e) + 2*long*(h + e)) + feevac*rhoterre*tauenterre*(h + e)*(e + larg)*(e + long) + fefonda*(e + larg)*(e + long)))/cad"}', '{"dco_s decanteur_lamellaire 3","ngl_s dessableurdegraisseur 3","ngl_s dessableurdegraisseur 3","CO2 elec 6","tbentrant tamis 1","dco_s decanteur_lamellaire 3","tbentrant centrifugeuse_pour_epais 2","CO2 exploitation lagunage 3","CO2 exploitation intrant decanteur_lamellaire 6","CO2 construction decanteur_lamellaire 3"}', 'Méthanol', 50, NULL, NULL, NULL, NULL, 50, 50, 50, 50, 50, NULL, NULL, 50, NULL, NULL, NULL, NULL, 50, NULL, NULL, NULL, NULL, 50, 50, 50, 50, 50, NULL, NULL, NULL, NULL, 50, NULL, NULL, 50, 50, 50, 50, NULL, 50, NULL, 50, 50, NULL, NULL, NULL, 50, NULL, NULL, 50, NULL, 50, NULL, NULL, 50, NULL, NULL, NULL, 50, 50, 50, 50, 50, NULL, NULL, 50, 50, NULL, 50, 50, NULL, NULL, 50, 50, NULL, 5, 5.74875e+06, NULL, NULL, NULL, 10, 0.25, 7, 0.75, 5, NULL, 574875, 689850, 16712, 'step_tigery');
INSERT INTO api.decanteur_lamellaire_bloc (id, shape, geom, name, formula, formula_name, prod_e, d_vie, eh, abatdco, abatngl, q_caco3, transp_catio, transp_co2l, transp_poly, transp_oxyl, transp_chaux, q_nahso3, q_co2l, transp_sulf, q_kmno4, q_nitrique, q_hcl, q_lait, transp_javel, q_phosphorique, q_ca_regen, q_chaux, q_sable_t, transp_ethanol, transp_rei, transp_citrique, transp_anti_mousse, transp_naclo3, q_fecl3, q_mhetanol, q_uree, q_cl2, transp_ca_regen, q_soude_c, q_ethanol, transp_ca_neuf, transp_mhetanol, transp_nitrique, transp_ca_poudre, q_anti_mousse, transp_phosphorique, q_coagl, transp_caco3, transp_sulf_sod, q_citrique, q_oxyl, q_naclo3, transp_coagl, q_poly, q_ca_poudre, transp_soude_c, q_h2o2, transp_lait, q_catio, q_sulf_sod, transp_kmno4, q_sulf_alu, q_antiscalant, q_javel, transp_soude, transp_sable_t, transp_fecl3, transp_anio, transp_sulf_alu, q_rei, q_sulf, transp_hcl, transp_antiscalant, q_ca_neuf, transp_nahso3, transp_uree, q_soude, q_anio, transp_cl2, transp_h2o2, dbo5elim, w_dbo5_eau, dco, ntk, mes, dbo5, long, e, larg, tauenterre, h, welec, ngl_s, dco_s, qe_s,model) VALUES (35, 'Point', '01010000206A080000B27D6A9D303A244141D1DA2CC0155A41', 'decanteur_lamellaire_1', '{"ngl_s=eh*ntk_eh*(1 - abatngl)","tbentrant=0.0005*nbjour*(dbo5 + mes)","co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)","co2_c=febet*e*rhobet*(larg*long + 2*larg*(h + e) + 2*long*(h + e)) + feevac*rhoterre*tauenterre*(h + e)*(e + larg)*(e + long) + fefonda*(e + larg)*(e + long) + fepelle*cad*tauenterre*(h + e)*(e + larg)*(e + long)","tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)",co2_e=feelec*welec,co2_e=feelec*dbo5elim*w_dbo5_eau,"dco_s=eh*dco_eh*(1 - abatdco)","dco_s=dco*(1 - abatdco)","ngl_s=ntk*(1 - abatngl)"}', '{"ngl_s bassin_biologique 3","tbentrant centrifugeuse_pour_deshy 2","CO2 exploitation intrant bassin_biologique 6","CO2 construction decanteur_lamellaire 3","tbentrant centrifugeuse_pour_deshy 1","CO2 elec 6","CO2 exploitation lagunage 3","dco_s bassin_biologique 3","dco_s bassin_biologique 3","ngl_s bassin_biologique 3"}', 'Sulfate de sodium', 50, NULL, NULL, NULL, NULL, 50, 50, 50, 50, 50, NULL, NULL, 50, NULL, NULL, NULL, NULL, 50, NULL, NULL, NULL, NULL, 50, 50, 50, 50, 50, NULL, NULL, NULL, NULL, 50, NULL, NULL, 50, 50, 50, 50, NULL, 50, NULL, 50, 50, NULL, NULL, NULL, 50, NULL, NULL, 50, NULL, 50, NULL, NULL, 50, NULL, NULL, NULL, 50, 50, 50, 50, 50, NULL, NULL, 50, 50, NULL, 50, 50, NULL, NULL, 50, 50, NULL, 5, 5.74875e+06, NULL, NULL, NULL, 10, 0.25, 7, 0.75, 5, NULL, 574875, 689850, 16712, 'step_tigery');


--
-- Data for Name: deconstruction_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: degazage_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: degrilleur_bloc; Type: TABLE DATA; Schema: api; Owner: -
--

INSERT INTO api.degrilleur_bloc (id, shape, geom, name, formula, formula_name, d_vie, eh, qdechet, welec, munite_degrilleur, qmax, qe, mes, dbo5, qe_s,model) VALUES (24, 'Point', '01010000206A080000996C8D94353B24412E87E108D5155A41', 'degrilleur_gros1', '{"tbentrant=0.0005*nbjour*(dbo5 + mes)",co2_e=eh*fedechet*qdechet*rhodechet,co2_c=fepoids*munite_degrilleur*qe/qmax,"tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)",co2_c=eh*fepoids*munite_degrilleur*qe_eh/qmax,co2_e=feelec*welec}', '{"tbentrant centrifugeuse_pour_deshy 2","CO2 exploitation degrilleur 1","CO2 construction degrilleur 2","tbentrant centrifugeuse_pour_deshy 1","CO2 construction degrilleur 1","CO2 elec 6"}', 15, 10500, 'Compactage avec vis', NULL, 1500, 6000, 16712.5, NULL, NULL, 16712.5, 'step_tigery');
INSERT INTO api.degrilleur_bloc (id, shape, geom, name, formula, formula_name, d_vie, eh, qdechet, welec, munite_degrilleur, qmax, qe, mes, dbo5, qe_s,model) VALUES (34, 'Point', '01010000206A08000001FFF88BFE3A2441A039DA43CF155A41', 'degrilleur_fin1', '{"tbentrant=0.0005*nbjour*(dbo5 + mes)",co2_e=eh*fedechet*qdechet*rhodechet,co2_c=fepoids*munite_degrilleur*qe/qmax,"tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)",co2_c=eh*fepoids*munite_degrilleur*qe_eh/qmax,co2_e=feelec*welec}', '{"tbentrant centrifugeuse_pour_deshy 2","CO2 exploitation degrilleur 1","CO2 construction degrilleur 2","tbentrant centrifugeuse_pour_deshy 1","CO2 construction degrilleur 1","CO2 elec 6"}', 15, 105000, 'Compactage avec piston', NULL, 1500, 6000, 16712.5, NULL, NULL, 16712.5, 'step_tigery');
INSERT INTO api.degrilleur_bloc (id, shape, geom, name, formula, formula_name, d_vie, eh, qdechet, welec, munite_degrilleur, qmax, qe, mes, dbo5, qe_s,model) VALUES (11, 'Point', '01010000206A08000011F1B751673B2441C3FB639ABA155A41', 'degrilleur_fin2', '{co2_e=feelec*welec,co2_e=eh*fedechet*qdechet*rhodechet,"tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)",co2_c=fepoids*munite_degrilleur*qe/qmax,"tbentrant=0.0005*nbjour*(dbo5 + mes)",co2_c=eh*fepoids*munite_degrilleur*qe_eh/qmax}', '{"CO2 elec 6","CO2 exploitation degrilleur 1","tbentrant tamis 1","CO2 construction degrilleur 2","tbentrant centrifugeuse_pour_epais 2","CO2 construction degrilleur 1"}', 15, 10500, 'Compactage avec piston', NULL, 1500, 6000, 16712.5, NULL, NULL, 16712.5, 'step_tigery');
INSERT INTO api.degrilleur_bloc (id, shape, geom, name, formula, formula_name, d_vie, eh, qdechet, welec, munite_degrilleur, qmax, qe, mes, dbo5, qe_s,model) VALUES (10, 'Point', '01010000206A0800009961CEDFC83B2441425874F8C1155A41', 'degrilleur_gros2', '{co2_e=feelec*welec,co2_e=eh*fedechet*qdechet*rhodechet,"tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)",co2_c=fepoids*munite_degrilleur*qe/qmax,"tbentrant=0.0005*nbjour*(dbo5 + mes)",co2_c=eh*fepoids*munite_degrilleur*qe_eh/qmax}', '{"CO2 elec 6","CO2 exploitation degrilleur 1","tbentrant tamis 1","CO2 construction degrilleur 2","tbentrant centrifugeuse_pour_epais 2","CO2 construction degrilleur 1"}', 15, 105000, 'Compactage avec piston', NULL, 1500, 6000, 16712, NULL, NULL, 16712, 'step_tigery');


--
-- Data for Name: dessableurdegraisseur_bloc; Type: TABLE DATA; Schema: api; Owner: -
--

INSERT INTO api.dessableurdegraisseur_bloc (id, shape, geom, name, formula, formula_name, prod_e, d_vie, eh, lavage, conc, q_caco3, transp_catio, transp_co2l, transp_poly, transp_oxyl, transp_chaux, q_nahso3, q_co2l, transp_sulf, q_kmno4, q_nitrique, q_hcl, q_lait, transp_javel, q_phosphorique, q_ca_regen, q_chaux, q_sable_t, transp_ethanol, transp_rei, transp_citrique, transp_anti_mousse, transp_naclo3, q_fecl3, q_mhetanol, q_uree, q_cl2, transp_ca_regen, q_soude_c, q_ethanol, transp_ca_neuf, transp_mhetanol, transp_nitrique, transp_ca_poudre, q_anti_mousse, transp_phosphorique, q_coagl, transp_caco3, transp_sulf_sod, q_citrique, q_oxyl, q_naclo3, transp_coagl, q_poly, q_ca_poudre, transp_soude_c, q_h2o2, transp_lait, q_catio, q_sulf_sod, transp_kmno4, q_sulf_alu, q_antiscalant, q_javel, transp_soude, transp_sable_t, transp_fecl3, transp_anio, transp_sulf_alu, q_rei, q_sulf, transp_hcl, transp_antiscalant, q_ca_neuf, transp_nahso3, transp_uree, q_soude, q_anio, transp_cl2, transp_h2o2, dbo5elim, w_dbo5_eau, e, vit, tauenterre, h, abatdco, abatngl, qe, dco, ntk, mes, dbo5, tgraisses, tsables, vu, welec, qe_s, ngl_s, dco_s,model) VALUES (12, 'Point', '01010000206A080000C551CB71303B24416F307940B4155A41', 'dessableurdegraisseur_2', '{"dco_s=eh*dco_eh*(1 - abatdco)","co2_c=(febet*cad*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe/vit)**0.5) + 24*qe) + 24.0*fepelle*tauenterre*vit*(h + e)*(0.3618*e + (qe/vit)**0.5)**2 + 24.0*cad*vit*(0.3618*e + (qe/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(cad*vit)","ngl_s=eh*ntk_eh*(1 - abatngl)","ngl_s=ntk*(1 - abatngl)",co2_e=feelec*welec,"tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)","dco_s=dco*(1 - abatdco)","co2_e=fedechet*tgraisses + fesables*tsables","co2_e=eh*(fedechet*dgraisses*(lgraisses_c*conc - lgraisses_nc*(conc - 1)) + fesables*(lavage*sables_lavé - sables_nlavé*(lavage - 1)))","tbentrant=0.0005*nbjour*(dbo5 + mes)","co2_c=(febet*cad*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*fepelle*h*tauenterre*(h + e)*(0.3618*e + (vu/h)**0.5)**2 + 24.0*h*cad*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad)",co2_e=feelec*dbo5elim*w_dbo5_eau,"co2_c=(febet*cad*e*rhobet*(24*eh*qe_eh + 3.14159*h*vit*(e + 5.52791*(eh*qe_eh/vit)**0.5)) + 24.0*fepelle*tauenterre*vit*(h + e)*(0.3618*e + (eh*qe_eh/vit)**0.5)**2 + 24.0*cad*vit*(0.3618*e + (eh*qe_eh/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(cad*vit)","co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)"}', '{"dco_s decanteur_lamellaire 3","CO2 construction degazage 2","ngl_s dessableurdegraisseur 3","ngl_s dessableurdegraisseur 3","CO2 elec 6","tbentrant tamis 1","dco_s decanteur_lamellaire 3","CO2 exploitation dessableurdegraisseur 3","CO2 exploitation dessableurdegraisseur 1","tbentrant centrifugeuse_pour_epais 2","CO2 construction bassin_cylindrique 3","CO2 exploitation lagunage 3","CO2 construction dessableurdegraisseur 1","CO2 exploitation intrant decanteur_lamellaire 6"}', 'Méthanol', 50, NULL, false, true, NULL, 50, 50, 50, 50, 50, NULL, NULL, 50, NULL, NULL, NULL, NULL, 50, NULL, NULL, NULL, NULL, 50, 50, 50, 50, 50, NULL, NULL, NULL, NULL, 50, NULL, NULL, 50, 50, 50, 50, NULL, 50, NULL, 50, 50, NULL, NULL, NULL, 50, NULL, NULL, 50, NULL, 50, NULL, NULL, 50, NULL, NULL, NULL, 50, 50, 50, 50, 50, NULL, NULL, 50, 50, NULL, 50, 50, NULL, NULL, 50, 50, NULL, 5, 0.25, 20, 0.75, 4, NULL, NULL, 16712, NULL, NULL, NULL, NULL, 3, 213.3, 218, NULL, NULL, NULL, NULL, 'step_tigery');
INSERT INTO api.dessableurdegraisseur_bloc (id, shape, geom, name, formula, formula_name, prod_e, d_vie, eh, lavage, conc, q_caco3, transp_catio, transp_co2l, transp_poly, transp_oxyl, transp_chaux, q_nahso3, q_co2l, transp_sulf, q_kmno4, q_nitrique, q_hcl, q_lait, transp_javel, q_phosphorique, q_ca_regen, q_chaux, q_sable_t, transp_ethanol, transp_rei, transp_citrique, transp_anti_mousse, transp_naclo3, q_fecl3, q_mhetanol, q_uree, q_cl2, transp_ca_regen, q_soude_c, q_ethanol, transp_ca_neuf, transp_mhetanol, transp_nitrique, transp_ca_poudre, q_anti_mousse, transp_phosphorique, q_coagl, transp_caco3, transp_sulf_sod, q_citrique, q_oxyl, q_naclo3, transp_coagl, q_poly, q_ca_poudre, transp_soude_c, q_h2o2, transp_lait, q_catio, q_sulf_sod, transp_kmno4, q_sulf_alu, q_antiscalant, q_javel, transp_soude, transp_sable_t, transp_fecl3, transp_anio, transp_sulf_alu, q_rei, q_sulf, transp_hcl, transp_antiscalant, q_ca_neuf, transp_nahso3, transp_uree, q_soude, q_anio, transp_cl2, transp_h2o2, dbo5elim, w_dbo5_eau, e, vit, tauenterre, h, abatdco, abatngl, qe, dco, ntk, mes, dbo5, tgraisses, tsables, vu, welec, qe_s, ngl_s, dco_s,model) VALUES (36, 'Point', '01010000206A0800009D8BA2219B3A2441449229F1C7155A41', 'dessableurdegraisseur_1', '{"co2_e=eh*(fedechet*dgraisses*(lgraisses_c*conc - lgraisses_nc*(conc - 1)) + fesables*(lavage*sables_lavé - sables_nlavé*(lavage - 1)))","ngl_s=eh*ntk_eh*(1 - abatngl)","tbentrant=0.0005*nbjour*(dbo5 + mes)","co2_e=fedechet*tgraisses + fesables*tsables","co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)","tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)","co2_c=(febet*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe/vit)**0.5) + 24*qe) + 24.0*vit*(0.3618*e + (qe/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda + fepelle*cad*tauenterre*(h + e)))/vit","co2_c=(febet*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*h*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda + fepelle*cad*tauenterre*(h + e)))/h",co2_e=feelec*welec,co2_e=feelec*dbo5elim*w_dbo5_eau,"dco_s=eh*dco_eh*(1 - abatdco)","dco_s=dco*(1 - abatdco)","ngl_s=ntk*(1 - abatngl)","co2_c=(febet*e*rhobet*(24*eh*qe_eh + 3.14159*h*vit*(e + 5.52791*(eh*qe_eh/vit)**0.5)) + 24.0*vit*(0.3618*e + (eh*qe_eh/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda + fepelle*cad*tauenterre*(h + e)))/vit"}', '{"CO2 exploitation dessableurdegraisseur 1","ngl_s bassin_biologique 3","tbentrant centrifugeuse_pour_deshy 2","CO2 exploitation dessableurdegraisseur 3","CO2 exploitation intrant bassin_biologique 6","tbentrant centrifugeuse_pour_deshy 1","CO2 construction degazage 2","CO2 construction bassin_cylindrique 3","CO2 elec 6","CO2 exploitation lagunage 3","dco_s bassin_biologique 3","dco_s bassin_biologique 3","ngl_s bassin_biologique 3","CO2 construction dessableurdegraisseur 1"}', 'Sulfate de sodium', 50, 105000, false, true, NULL, 50, 50, 50, 50, 50, NULL, NULL, 50, NULL, NULL, NULL, NULL, 50, NULL, NULL, NULL, NULL, 50, 50, 50, 50, 50, NULL, NULL, NULL, NULL, 50, NULL, NULL, 50, 50, 50, 50, NULL, 50, NULL, 50, 50, NULL, NULL, NULL, 50, NULL, NULL, 50, NULL, 50, NULL, NULL, 50, NULL, NULL, NULL, 50, 50, 50, 50, 50, NULL, NULL, 50, 50, NULL, 50, 50, NULL, NULL, 50, 50, NULL, 5, 0.25, 20, 0.75, 4, NULL, NULL, 16712, 5.74875e+06, NULL, NULL, NULL, 3, 213.5, 218, NULL, 16712, 215350, 689850, 'step_tigery');


--
-- Data for Name: digesteur__methaniseur_bloc; Type: TABLE DATA; Schema: api; Owner: -
--

INSERT INTO api.digesteur__methaniseur_bloc (id, shape, geom, name, formula, formula_name, d_vie, tbsortant, tau_abattement, eh, mes, dbo5, vbiogaz, welec, tbsortant_s,model) VALUES (21, 'Point', '01010000206A0800004EF2D1937C3A2441BBCC233B69155A41', 'digesteur__methaniseur_1', '{ch4_e=tbsortant*tau_fuite*vol_ms,"tbentrant=0.0005*nbjour*(dbo5 + mes)","tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)",co2_e=feelec*welec,co2_c=feobj_dan*vbiogaz,co2_e=feelec*tbsortant*welec_dan,co2_c=225*feobj_dan*tbsortant,tbsortant_s=tbsortant*tau_abattement}', '{"CH4 exploitation digesteur__methaniseur 3","tbentrant centrifugeuse_pour_deshy 2","tbentrant centrifugeuse_pour_deshy 1","CO2 elec 6","CO2 construction digesteur__methaniseur 4","CO2 exploitation digesteur__methaniseur 3","CO2 construction digesteur__methaniseur 3","tbsortant_s digesteur__methaniseur 3"}', 30, 1750, 0.4, NULL, NULL, NULL, NULL, NULL, 1312, 'step_tigery');
INSERT INTO api.digesteur__methaniseur_bloc (id, shape, geom, name, formula, formula_name, d_vie, tbsortant, tau_abattement, eh, mes, dbo5, vbiogaz, welec, tbsortant_s,model) VALUES (6, 'Point', '01010000206A0800001A9BF3E80E3B24410F8DC89C74155A41', 'digesteur__methaniseur_2', '{tbsortant_s=tbsortant*tau_abattement,co2_c=feobj_dan*vbiogaz,ch4_e=tbsortant*tau_fuite*vol_ms,co2_c=225*feobj_dan*tbsortant,"tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)",co2_e=feelec*welec,co2_e=feelec*tbsortant*welec_dan,"tbentrant=0.0005*nbjour*(dbo5 + mes)"}', '{"tbsortant_s digesteur_aerobie 3","CO2 construction digesteur__methaniseur 4","CH4 exploitation digesteur__methaniseur 3","CO2 construction digesteur__methaniseur 3","tbentrant tamis 1","CO2 elec 6","CO2 exploitation digesteur__methaniseur 3","tbentrant centrifugeuse_pour_epais 2"}', 30, 1750, 0.4, NULL, NULL, NULL, NULL, NULL, 1312, 'step_tigery');


--
-- Data for Name: digesteur_aerobie_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: epaississement_statique_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: excavation_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: filiere_boue_bloc; Type: TABLE DATA; Schema: api; Owner: -
--

INSERT INTO api.filiere_boue_bloc (id, shape, geom, name, formula, formula_name, d_vie, eh, welec, mes, dbo5, tbsortant_s,model) VALUES (1, 'Polygon', '01030000206A08000001000000060000008ED70E04A739244100F65BB993155A4198A855E35F3A24410A2DC0455A155A41E6C77393963B24410C61EEBD56155A416FFE27CEE13C2441444456D06E155A41FE6A1B69443B24410BC7C5DEA9155A418ED70E04A739244100F65BB993155A41', 'filiere_boue_1', '{co2_e=feelec*welec,"tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)","tbentrant=0.0005*nbjour*(dbo5 + mes)"}', '{"CO2 elec 6","tbentrant tamis 1","tbentrant centrifugeuse_pour_epais 2"}', 15, NULL, NULL, NULL, NULL, NULL, 'step_tigery');


--
-- Data for Name: filiere_eau_bloc; Type: TABLE DATA; Schema: api; Owner: -
--

INSERT INTO api.filiere_eau_bloc (id, shape, geom, name, formula, formula_name, prod_e, d_vie, eh, abatdco, abatngl, dbo5elim, methode, q_caco3, transp_catio, transp_co2l, transp_poly, transp_oxyl, transp_chaux, q_nahso3, q_co2l, transp_sulf, q_kmno4, q_nitrique, q_hcl, q_lait, transp_javel, q_phosphorique, q_ca_regen, q_chaux, q_sable_t, transp_ethanol, transp_rei, transp_citrique, transp_anti_mousse, transp_naclo3, q_fecl3, q_mhetanol, q_uree, q_cl2, transp_ca_regen, q_soude_c, q_ethanol, transp_ca_neuf, transp_mhetanol, transp_nitrique, transp_ca_poudre, q_anti_mousse, transp_phosphorique, q_coagl, transp_caco3, transp_sulf_sod, q_citrique, q_oxyl, q_naclo3, transp_coagl, q_poly, q_ca_poudre, transp_soude_c, q_h2o2, transp_lait, q_catio, q_sulf_sod, transp_kmno4, q_sulf_alu, q_antiscalant, q_javel, transp_soude, transp_sable_t, transp_fecl3, transp_anio, transp_sulf_alu, q_rei, q_sulf, transp_hcl, transp_antiscalant, q_ca_neuf, transp_nahso3, transp_uree, q_soude, q_anio, transp_cl2, transp_h2o2, dco, ntk, mes, dbo5, welec, ngl_s, dco_s, qe_s,model) VALUES (26, 'Polygon', '01030000206A08000001000000050000007B8117B23F3824413A28F1B8A2155A4106A655498F3824415430BBE496155A41C29B49AD8B3B2441F0B8932ED1155A4168BCA2AB6D3B2441A0FC81E3EB155A417B8117B23F3824413A28F1B8A2155A41', 'filiere_eau_2', '{"dco_s=eh*dco_eh*(1 - abatdco)","ngl_s=eh*ntk_eh*(1 - abatngl)","ngl_s=ntk*(1 - abatngl)",co2_e=feelec*welec,"tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)","dco_s=dco*(1 - abatdco)","tbentrant=0.0005*nbjour*(dbo5 + mes)",co2_e=feelec*dbo5elim*methode,"co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)"}', '{"dco_s decanteur_lamellaire 3","ngl_s dessableurdegraisseur 3","ngl_s dessableurdegraisseur 3","CO2 elec 6","tbentrant tamis 1","dco_s decanteur_lamellaire 3","tbentrant centrifugeuse_pour_epais 2","CO2 exploitation filiere_eau 2","CO2 exploitation intrant decanteur_lamellaire 6"}', 'Méthanol', 50, NULL, NULL, NULL, 1.994496e+06, 'BRM', NULL, 50, 50, 50, 50, 50, NULL, NULL, 50, NULL, NULL, NULL, NULL, 50, NULL, NULL, NULL, NULL, 50, 50, 50, 50, 50, NULL, NULL, NULL, NULL, 50, NULL, NULL, 50, 50, 50, 50, NULL, 50, NULL, 50, 50, NULL, NULL, NULL, 50, NULL, NULL, 50, NULL, 50, NULL, NULL, 50, NULL, NULL, NULL, 50, 50, 50, 50, 50, NULL, NULL, 50, 50, NULL, 50, 50, NULL, NULL, 50, 50, 5.74875e+06, NULL, NULL, NULL, NULL, 215350, 4178.13, 33425, 'step_tigery');
INSERT INTO api.filiere_eau_bloc (id, shape, geom, name, formula, formula_name, prod_e, d_vie, eh, abatdco, abatngl, dbo5elim, methode, q_caco3, transp_catio, transp_co2l, transp_poly, transp_oxyl, transp_chaux, q_nahso3, q_co2l, transp_sulf, q_kmno4, q_nitrique, q_hcl, q_lait, transp_javel, q_phosphorique, q_ca_regen, q_chaux, q_sable_t, transp_ethanol, transp_rei, transp_citrique, transp_anti_mousse, transp_naclo3, q_fecl3, q_mhetanol, q_uree, q_cl2, transp_ca_regen, q_soude_c, q_ethanol, transp_ca_neuf, transp_mhetanol, transp_nitrique, transp_ca_poudre, q_anti_mousse, transp_phosphorique, q_coagl, transp_caco3, transp_sulf_sod, q_citrique, q_oxyl, q_naclo3, transp_coagl, q_poly, q_ca_poudre, transp_soude_c, q_h2o2, transp_lait, q_catio, q_sulf_sod, transp_kmno4, q_sulf_alu, q_antiscalant, q_javel, transp_soude, transp_sable_t, transp_fecl3, transp_anio, transp_sulf_alu, q_rei, q_sulf, transp_hcl, transp_antiscalant, q_ca_neuf, transp_nahso3, transp_uree, q_soude, q_anio, transp_cl2, transp_h2o2, dco, ntk, mes, dbo5, welec, ngl_s, dco_s, qe_s,model) VALUES (51, 'Polygon', '01030000206A0800000100000005000000B3C255F2B73B2441FDB6ECF7CE155A413F6D3CC0AF3824416059850C95155A41FA9BE4DFE4382441AACEEEDF88155A41AB8767DA363C24416C7C43E4BC155A41B3C255F2B73B2441FDB6ECF7CE155A41', 'filiere_eau_1', '{co2_e=feelec*dbo5elim*methode,"dco_s=dco*(1 - abatdco)","tbentrant=0.0005*nbjour*(dbo5 + mes)","ngl_s=ntk*(1 - abatngl)","tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)","co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_co2l*(fetransp*transp_co2l + 1000*fe_co2l) + 0.001*q_coagl*(fetransp*transp_coagl + 1000*fe_coagl) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_fecl3*(fetransp*transp_fecl3 + 1000*fe_fecl3) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_javel*(fetransp*transp_javel + 1000*fe_javel) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_lait*(fetransp*transp_lait + 1000*fe_lait) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)","dco_s=eh*dco_eh*(1 - abatdco)",co2_e=feelec*welec,"ngl_s=eh*ntk_eh*(1 - abatngl)"}', '{"CO2 exploitation filiere_eau 3","dco_s bassin_biologique 3","tbentrant filtre_a_bande 2","ngl_s decanteur_lamellaire 3","tbentrant filiere_boue 1","CO2 exploitation intrant filiere_eau 6","dco_s bassin_biologique 3","CO2 elec 6","ngl_s decanteur_lamellaire 3"}', 'Résine cationique', 50, NULL, NULL, NULL, 1.994496e+06, 'BRM', NULL, 50, 50, 50, 50, 50, NULL, NULL, 50, NULL, NULL, NULL, NULL, 50, NULL, NULL, NULL, NULL, 50, 50, 50, 50, 50, NULL, NULL, NULL, NULL, 50, NULL, NULL, 50, 50, 50, 50, NULL, 50, NULL, 50, 50, NULL, NULL, NULL, 50, NULL, NULL, 50, NULL, 50, NULL, NULL, 50, NULL, NULL, NULL, 50, 50, 50, 50, 50, NULL, NULL, 50, 50, NULL, 50, 50, NULL, NULL, 50, 50, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'step_tigery');


--
-- Data for Name: filtre_a_bande_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: filtre_a_presse_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: flottateur_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: fpr_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: grilles_degouttage_bloc; Type: TABLE DATA; Schema: api; Owner: -
--

INSERT INTO api.grilles_degouttage_bloc (id, shape, geom, name, formula, formula_name, d_vie, tbsortant, q_poly, transp_poly, eh, dbo5, mes, tbentrant, welec, tbsortant_s,model) VALUES (20, 'Point', '01010000206A080000D5C1BFAF443A2441AF64FF4195155A41', 'grilles_degouttage_bio', '{"co2_e=0.001*q_poly*(1000*fepolymere + fetransp*transp_poly)","tbentrant=0.0005*nbjour*(dbo5 + mes)",co2_c=((feobj10_ge)*(eh<10000)+(feobj50_ge)*(eh>10000)*(eh<100000)+(feobj100_ge)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour),"tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)",co2_e=feelec*tbsortant*welec_ge,co2_c=((feobj10_ge)*(eh<10000)+(feobj50_ge)*(eh>10000)*(eh<100000)+(feobj100_ge)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour),co2_c=((feobj10_ge)*(eh<10000)+(feobj50_ge)*(eh>10000)*(eh<100000)+(feobj100_ge)*(eh>100000))*tbentrant,co2_e=feelec*welec}', '{"CO2 exploitation q_poly centrifugeuse_pour_epais 6","tbentrant centrifugeuse_pour_deshy 2","CO2 construction grilles_degouttage 2","tbentrant centrifugeuse_pour_deshy 1","CO2 exploitation grilles_degouttage 3","CO2 construction grilles_degouttage 1","CO2 construction grilles_degouttage 3","CO2 elec 6"}', 15, 1258, 5, 50, 105000, NULL, NULL, 1258, NULL, 1255, 'step_tigery');
INSERT INTO api.grilles_degouttage_bloc (id, shape, geom, name, formula, formula_name, d_vie, tbsortant, q_poly, transp_poly, eh, dbo5, mes, tbentrant, welec, tbsortant_s,model) VALUES (16, 'Point', '01010000206A08000080BBF1B6073A2441D38E432D90155A41', 'grilles_degouttage_primaire', '{"co2_e=0.001*q_poly*(1000*fepolymere + fetransp*transp_poly)","tbentrant=0.0005*nbjour*(dbo5 + mes)",co2_c=((feobj10_ge)*(eh<10000)+(feobj50_ge)*(eh>10000)*(eh<100000)+(feobj100_ge)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour),"tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)",co2_e=feelec*tbsortant*welec_ge,co2_c=((feobj10_ge)*(eh<10000)+(feobj50_ge)*(eh>10000)*(eh<100000)+(feobj100_ge)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour),co2_c=((feobj10_ge)*(eh<10000)+(feobj50_ge)*(eh>10000)*(eh<100000)+(feobj100_ge)*(eh>100000))*tbentrant,co2_e=feelec*welec}', '{"CO2 exploitation q_poly centrifugeuse_pour_epais 6","tbentrant centrifugeuse_pour_deshy 2","CO2 construction grilles_degouttage 2","tbentrant centrifugeuse_pour_deshy 1","CO2 exploitation grilles_degouttage 3","CO2 construction grilles_degouttage 1","CO2 construction grilles_degouttage 3","CO2 elec 6"}', 15, 2241, 5, 50, 105000, NULL, NULL, 2241, NULL, 2236, 'step_tigery');


--
-- Data for Name: lagunage_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: lien_bloc; Type: TABLE DATA; Schema: api; Owner: -
--

INSERT INTO api.lien_bloc (id, shape, geom, name, formula, formula_name,model) VALUES (42, 'LineString', '01020000206A08000002000000996C8D94353B24412E87E108D5155A4101FFF88BFE3A2441A039DA43CF155A41', 'lien_bloc_6', '{}', '{}', 'step_tigery');
INSERT INTO api.lien_bloc (id, shape, geom, name, formula, formula_name,model) VALUES (43, 'LineString', '01020000206A0800000200000001FFF88BFE3A2441A039DA43CF155A419D8BA2219B3A2441449229F1C7155A41', 'lien_bloc_7', '{}', '{}', 'step_tigery');
INSERT INTO api.lien_bloc (id, shape, geom, name, formula, formula_name,model) VALUES (44, 'LineString', '01020000206A080000020000009D8BA2219B3A2441449229F1C7155A41B27D6A9D303A244141D1DA2CC0155A41', 'lien_bloc_8', '{}', '{}', 'step_tigery');
INSERT INTO api.lien_bloc (id, shape, geom, name, formula, formula_name,model) VALUES (52, 'LineString', '01020000206A08000002000000B27D6A9D303A244141D1DA2CC0155A41C2069845BF3924418C2213BAB7155A41', 'lien_bloc_10', '{}', '{}', 'step_tigery');
INSERT INTO api.lien_bloc (id, shape, geom, name, formula, formula_name,model) VALUES (53, 'LineString', '01020000206A08000002000000C2069845BF3924418C2213BAB7155A419CF4E2CC6D392441C479C439AF155A41', 'lien_bloc_11', '{}', '{}', 'step_tigery');
INSERT INTO api.lien_bloc (id, shape, geom, name, formula, formula_name,model) VALUES (54, 'LineString', '01020000206A080000020000009CF4E2CC6D392441C479C439AF155A41F20658A72B3924416F46FC15AA155A41', 'lien_bloc_12', '{}', '{}', 'step_tigery');
INSERT INTO api.lien_bloc (id, shape, geom, name, formula, formula_name,model) VALUES (55, 'LineString', '01020000206A08000002000000F20658A72B3924416F46FC15AA155A418BDC9943CD382441033CA52CA4155A41', 'lien_bloc_13', '{}', '{}', 'step_tigery');
INSERT INTO api.lien_bloc (id, shape, geom, name, formula, formula_name,model) VALUES (56, 'LineString', '01020000206A080000020000009961CEDFC83B2441425874F8C1155A4111F1B751673B2441C3FB639ABA155A41', 'lien_bloc_14', '{}', '{}', 'step_tigery');
INSERT INTO api.lien_bloc (id, shape, geom, name, formula, formula_name,model) VALUES (57, 'LineString', '01020000206A0800000200000011F1B751673B2441C3FB639ABA155A41C551CB71303B24416F307940B4155A41', 'lien_bloc_15', '{}', '{}', 'step_tigery');
INSERT INTO api.lien_bloc (id, shape, geom, name, formula, formula_name,model) VALUES (58, 'LineString', '01020000206A08000002000000C551CB71303B24416F307940B4155A41CE89C590BA3A244149F6B3EAAE155A41', 'lien_bloc_16', '{}', '{}', 'step_tigery');
INSERT INTO api.lien_bloc (id, shape, geom, name, formula, formula_name,model) VALUES (59, 'LineString', '01020000206A08000002000000CE89C590BA3A244149F6B3EAAE155A414EDBE1E24F3A2441D86C0B2FAB155A41', 'lien_bloc_17', '{}', '{}', 'step_tigery');
INSERT INTO api.lien_bloc (id, shape, geom, name, formula, formula_name,model) VALUES (60, 'LineString', '01020000206A080000020000004EDBE1E24F3A2441D86C0B2FAB155A415E1F6C53EF392441DBAE4502A5155A41', 'lien_bloc_18', '{}', '{}', 'step_tigery');
INSERT INTO api.lien_bloc (id, shape, geom, name, formula, formula_name,model) VALUES (61, 'LineString', '01020000206A080000020000005E1F6C53EF392441DBAE4502A5155A41F84ADB28A63924413C7F51679E155A41', 'lien_bloc_19', '{}', '{}', 'step_tigery');
INSERT INTO api.lien_bloc (id, shape, geom, name, formula, formula_name,model) VALUES (62, 'LineString', '01020000206A08000002000000F84ADB28A63924413C7F51679E155A41D91A7A18143924415BAF67C995155A41', 'lien_bloc_20', '{}', '{}', 'step_tigery');


--
-- Data for Name: lspr_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: mbbr_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: piptest_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: pointest_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: pompe_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: poste_de_refoulement_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: rejets_bloc; Type: TABLE DATA; Schema: api; Owner: -
--

INSERT INTO api.rejets_bloc (id, shape, geom, name, formula, formula_name, eh, abatdco, fech4_mil, fen2o_oxi, abatngl, dco, ngl,model) VALUES (41, 'Point', '01010000206A080000910D441EF53C24415A7F33109E155A41', 'rejets_1', '{ch4_e=dco*fech4_mil,n2o_e=fen2o_oxi*ngl,"n2o_e=eh*fen2o_oxi*ntk_eh*(1 - abatngl)","ch4_e=eh*fech4_mil*dco_eh*(1 - abatdco)"}', '{"CH4 exploitation rejets 2","N2O exploitation rejets 2","N2O exploitation rejets 1","CH4 exploitation rejets 1"}', 105000, 0.75, 'Réservoirs, lac, estuaires', 'Bien oxygéné', 0.8, NULL, NULL, 'step_tigery');


--
-- Data for Name: sechage_solaire_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: sechage_thermique_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: source_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: station_de_pompage_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: stockage_boue_bloc; Type: TABLE DATA; Schema: api; Owner: -
--

INSERT INTO api.stockage_boue_bloc (id, shape, geom, name, formula, formula_name, d_vie, grand, dbo, aere, eh, welec, festock, mes, dbo5, tbentrant, tbsortant_s,model) VALUES (2, 'Point', '01010000206A080000981CAEE2053A24412A0E879D87155A41', 'stockage_boue_primaire', '{"tbentrant=0.0005*nbjour*(dbo5 + mes)","co2_e=0.0005*fesilo_aere*nbjour*aere*(dbo5 + mes)","co2_c=0.0005*festock*nbjour*(dbo5 + mes)","ch4_e=-dbo*(aere - 1)*(fesilo_grand*grand - fesilo_petit*(grand - 1))","co2_c=0.0005*eh*festock*nbjour*(dbo5_eh + mes_eh)","tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)",co2_c=festock*tbentrant,"co2_e=0.0005*eh*fesilo_aere*nbjour*aere*(dbo5_eh + mes_eh)",co2_e=fesilo_aere*tbentrant*aere,co2_e=feelec*welec}', '{"tbentrant centrifugeuse_pour_deshy 2","CO2 exploitation stockage_boue 2","CO2 construction stockage_boue 2","CH4 exploitation stockage_boue 2","CO2 construction stockage_boue 1","tbentrant centrifugeuse_pour_deshy 1","CO2 construction stockage_boue 3","CO2 exploitation stockage_boue 1","CO2 exploitation stockage_boue 3","CO2 elec 6"}', 30, false, NULL, true, 105000, NULL, 'Silo de 500m3', NULL, NULL, 2241, 2241, 'step_tigery');
INSERT INTO api.stockage_boue_bloc (id, shape, geom, name, formula, formula_name, d_vie, grand, dbo, aere, eh, welec, festock, mes, dbo5, tbentrant, tbsortant_s,model) VALUES (17, 'Point', '01010000206A080000F6721B57933A2441A63F4F2E7F155A41', 'stockage_boue_mixte', '{"tbentrant=0.0005*nbjour*(dbo5 + mes)","co2_e=0.0005*fesilo_aere*nbjour*aere*(dbo5 + mes)","co2_c=0.0005*festock*nbjour*(dbo5 + mes)","ch4_e=-dbo*(aere - 1)*(fesilo_grand*grand - fesilo_petit*(grand - 1))","co2_c=0.0005*eh*festock*nbjour*(dbo5_eh + mes_eh)","tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)",co2_c=festock*tbentrant,"co2_e=0.0005*eh*fesilo_aere*nbjour*aere*(dbo5_eh + mes_eh)",co2_e=fesilo_aere*tbentrant*aere,co2_e=feelec*welec}', '{"tbentrant centrifugeuse_pour_deshy 2","CO2 exploitation stockage_boue 2","CO2 construction stockage_boue 2","CH4 exploitation stockage_boue 2","CO2 construction stockage_boue 1","tbentrant centrifugeuse_pour_deshy 1","CO2 construction stockage_boue 3","CO2 exploitation stockage_boue 1","CO2 exploitation stockage_boue 3","CO2 elec 6"}', 30, false, NULL, true, NULL, NULL, 'Silo de 500m3', NULL, NULL, 424000, 42400, 'step_tigery');
INSERT INTO api.stockage_boue_bloc (id, shape, geom, name, formula, formula_name, d_vie, grand, dbo, aere, eh, welec, festock, mes, dbo5, tbentrant, tbsortant_s,model) VALUES (14, 'Point', '01010000206A080000033CA316903A244148A5D18E90155A41', 'stockage_boues_bio', '{"tbentrant=0.0005*nbjour*(dbo5 + mes)","co2_e=0.0005*fesilo_aere*nbjour*aere*(dbo5 + mes)","co2_c=0.0005*festock*nbjour*(dbo5 + mes)","ch4_e=-dbo*(aere - 1)*(fesilo_grand*grand - fesilo_petit*(grand - 1))","co2_c=0.0005*eh*festock*nbjour*(dbo5_eh + mes_eh)","tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)",co2_c=festock*tbentrant,"co2_e=0.0005*eh*fesilo_aere*nbjour*aere*(dbo5_eh + mes_eh)",co2_e=fesilo_aere*tbentrant*aere,co2_e=feelec*welec}', '{"tbentrant centrifugeuse_pour_deshy 2","CO2 exploitation stockage_boue 2","CO2 construction stockage_boue 2","CH4 exploitation stockage_boue 2","CO2 construction stockage_boue 1","tbentrant centrifugeuse_pour_deshy 1","CO2 construction stockage_boue 3","CO2 exploitation stockage_boue 1","CO2 exploitation stockage_boue 3","CO2 elec 6"}', 30, false, NULL, true, NULL, NULL, 'Silo de 5m3', NULL, NULL, 1258, 1258, 'step_tigery');


--
-- Data for Name: sur_bloc_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: tables_degouttage_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: tamis_bloc; Type: TABLE DATA; Schema: api; Owner: -
--

INSERT INTO api.tamis_bloc (id, shape, geom, name, formula, formula_name, d_vie, qmax, eh, munite_tamis, compt, welec, qe, mes, dbo5, qe_s,model) VALUES (46, 'Point', '01010000206A080000C2069845BF3924418C2213BAB7155A41', 'tamis_tert_1', '{co2_c=fepoids*munite_tamis*qe/qmax,co2_c=eh*fepoids*munite_tamis*qe_eh/qmax,"tbentrant=0.0005*nbjour*(dbo5 + mes)","tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)",co2_e=feelec*welec,"co2_e=eh*fedechet*rhodechet*(compt*qdechet_tamis_comp - qdechet_tamis_ncomp*(compt - 1))"}', '{"CO2 construction tamis 2","CO2 construction tamis 1","tbentrant filtre_a_bande 2","tbentrant filiere_boue 1","CO2 elec 6","CO2 exploitation tamis 1"}', 15, 270, 10500, 210, false, NULL, 16712, NULL, NULL, NULL, 'step_tigery');
INSERT INTO api.tamis_bloc (id, shape, geom, name, formula, formula_name, d_vie, qmax, eh, munite_tamis, compt, welec, qe, mes, dbo5, qe_s,model) VALUES (48, 'Point', '01010000206A0800008BDC9943CD382441033CA52CA4155A41', 'tamis_1', '{co2_c=fepoids*munite_tamis*qe/qmax,co2_c=eh*fepoids*munite_tamis*qe_eh/qmax,"tbentrant=0.0005*nbjour*(dbo5 + mes)","tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)",co2_e=feelec*welec,"co2_e=eh*fedechet*rhodechet*(compt*qdechet_tamis_comp - qdechet_tamis_ncomp*(compt - 1))"}', '{"CO2 construction tamis 2","CO2 construction tamis 1","tbentrant filtre_a_bande 2","tbentrant filiere_boue 1","CO2 elec 6","CO2 exploitation tamis 1"}', 15, 270, 10500, 210, false, NULL, 16712, NULL, NULL, NULL, 'step_tigery');
INSERT INTO api.tamis_bloc (id, shape, geom, name, formula, formula_name, d_vie, qmax, eh, munite_tamis, compt, welec, qe, mes, dbo5, qe_s,model) VALUES (49, 'Point', '01010000206A0800004EDBE1E24F3A2441D86C0B2FAB155A41', 'tamis_tert_2', '{co2_c=fepoids*munite_tamis*qe/qmax,co2_c=eh*fepoids*munite_tamis*qe_eh/qmax,"tbentrant=0.0005*nbjour*(dbo5 + mes)","tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)",co2_e=feelec*welec,"co2_e=eh*fedechet*rhodechet*(compt*qdechet_tamis_comp - qdechet_tamis_ncomp*(compt - 1))"}', '{"CO2 construction tamis 2","CO2 construction tamis 1","tbentrant filtre_a_bande 2","tbentrant filiere_boue 1","CO2 elec 6","CO2 exploitation tamis 1"}', 15, 270, 10500, 210, false, NULL, 16712, NULL, NULL, NULL, 'step_tigery');
INSERT INTO api.tamis_bloc (id, shape, geom, name, formula, formula_name, d_vie, qmax, eh, munite_tamis, compt, welec, qe, mes, dbo5, qe_s,model) VALUES (50, 'Point', '01010000206A080000D91A7A18143924415BAF67C995155A41', 'tamis_2', '{co2_c=fepoids*munite_tamis*qe/qmax,co2_c=eh*fepoids*munite_tamis*qe_eh/qmax,"tbentrant=0.0005*nbjour*(dbo5 + mes)","tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)",co2_e=feelec*welec,"co2_e=eh*fedechet*rhodechet*(compt*qdechet_tamis_comp - qdechet_tamis_ncomp*(compt - 1))"}', '{"CO2 construction tamis 2","CO2 construction tamis 1","tbentrant filtre_a_bande 2","tbentrant filiere_boue 1","CO2 elec 6","CO2 exploitation tamis 1"}', 15, 270, 10500, 210, false, NULL, 16712, NULL, NULL, NULL, 'step_tigery');


--
-- Data for Name: test_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: usine_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: voirie_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Name: bloc_id_seq; Type: SEQUENCE SET; Schema: api; Owner: -
--



--
-- PostgreSQL database dump complete
--


    
    with max_id as (select max(id) as max from api.bloc)
    select setval('___.bloc_id_seq', (select max from max_id));
    