-- cycle version 0.0.1
-- project SRID 2154
INSERT INTO api.model (name, creation_date, comment) VALUES ('model1', '2024-11-20 00:00:00', NULL);
INSERT INTO api.model (name, creation_date, comment) VALUES ('model2', '2024-11-20 00:00:00', NULL);
INSERT INTO api.model (name, creation_date, comment) VALUES ('model3', '2024-11-20 00:00:00', NULL);
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

INSERT INTO api.canalisation_bloc (id, shape, geom, name, formula, formula_name, qe_e, dbo5_e, mes_e, ngl_e, qe_s, dbo5_s, mes_s, ngl_s, ml, diam, materiau, urbain, d_vie, sans_tranche,model) VALUES (8, 'LineString', '01020000206A080000020000006D039D84A64F244126BF98CF251C5A4182B1E455E64F2441B6818E32131C5A41', 'canalisation_3', '{}', '{}', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 81.003265, '100', 'fonte', 'urbain', '80', 'classic', 'model1');
INSERT INTO api.canalisation_bloc (id, shape, geom, name, formula, formula_name, qe_e, dbo5_e, mes_e, ngl_e, qe_s, dbo5_s, mes_s, ngl_s, ml, diam, materiau, urbain, d_vie, sans_tranche,model) VALUES (26, 'LineString', '01020000206A08000002000000CB5F1D1A994F2441CB4913BA301C5A415FD0A017F04F244129FC3B2D121C5A41', 'canalisation_4', '{}', '{}', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 129.71054, '100', 'fonte', 'urbain', '80', 'classic', 'model2');


--
-- Data for Name: centrifugeuse_pour_deshy_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



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

INSERT INTO api.clarificateur_bloc (id, shape, geom, name, formula, formula_name, prod_e, d_vie, vit, h, taur, tauenterre, e, eh, abatdco, abatngl, w_dbo5_eau, dbo5elim, q_sable_t, transp_anti_mousse, q_sulf_sod, transp_cl2, q_citrique, transp_ca_regen, q_caco3, q_mhetanol, transp_ca_neuf, q_phosphorique, transp_mhetanol, q_uree, q_sulf_alu, transp_antiscalant, transp_poly, transp_sulf, transp_catio, transp_caco3, transp_nahso3, transp_soude_c, q_anio, transp_kmno4, q_poly, transp_oxyl, transp_anio, transp_naclo3, q_soude_c, q_anti_mousse, q_nahso3, q_hcl, transp_citrique, transp_rei, transp_ethanol, q_ethanol, transp_soude, q_rei, transp_sulf_sod, q_naclo3, q_nitrique, q_ca_poudre, q_ca_regen, transp_h2o2, q_kmno4, transp_sulf_alu, transp_uree, q_catio, q_chaux, q_oxyl, transp_nitrique, transp_ca_poudre, transp_hcl, transp_chaux, q_h2o2, q_soude, q_ca_neuf, transp_phosphorique, transp_sable_t, q_antiscalant, q_cl2, q_sulf, qe, dco, ntk, mes, dbo5, vu, welec, tbentrant_s, ngl_s, dco_s, qe_s,model) VALUES (30, 'Point', '01010000206A0800001C4B7E1B365024417877B7EFF91B5A41', 'clarificateur_1', '{"dco_s=eh*dco_eh*(1 - abatdco)","co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)","co2_c=(febet*cad*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*fepelle*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2 + 24.0*cad*vit*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(cad*vit)","co2_c=(febet*cad*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*fepelle*h*tauenterre*(h + e)*(0.3618*e + (vu/h)**0.5)**2 + 24.0*h*cad*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad)","tbentrant=0.0005*nbjour*(dbo5 + mes)",co2_e=feelec*welec,"ngl_s=eh*ntk_eh*(1 - abatngl)","dco_s=dco*(1 - abatdco)",co2_e=feelec*dbo5elim*w_dbo5_eau,"tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)","co2_c=(febet*cad*e*rhobet*(24*eh*qe_eh*(taur + 1) + 3.14159*h*vit*(e + 5.52791*(eh*qe_eh*(taur + 1)/vit)**0.5)) + 24.0*fepelle*tauenterre*vit*(h + e)*(0.3618*e + (eh*qe_eh*(taur + 1)/vit)**0.5)**2 + 24.0*cad*vit*(0.3618*e + (eh*qe_eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(cad*vit)","ngl_s=ntk*(1 - abatngl)"}', '{"dco_s fpr 3","CO2 exploitation intrant dessableurdegraisseur 6","CO2 construction clarificateur 2","CO2 construction bassin_cylindrique 3","tbentrant degazage 2","CO2 elec 6","ngl_s bassin_biologique 3","dco_s fpr 3","CO2 exploitation clarificateur 3","tbentrant digesteur_aerobie 1","CO2 construction clarificateur 1","ngl_s bassin_biologique 3"}', 'Soude', 50, 60, 3, 1, 0.75, 0.25, 20000, NULL, NULL, 5, NULL, NULL, 50, NULL, 50, NULL, 50, NULL, NULL, 50, NULL, 50, NULL, NULL, 50, 50, 50, 50, 50, 50, 50, NULL, 50, NULL, 50, 50, 50, NULL, NULL, NULL, NULL, 50, 50, 50, NULL, 50, NULL, 50, NULL, NULL, NULL, NULL, 50, NULL, 50, 50, NULL, NULL, NULL, 50, 50, 50, 50, NULL, NULL, NULL, 50, 50, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'model1');
INSERT INTO api.clarificateur_bloc (id, shape, geom, name, formula, formula_name, prod_e, d_vie, vit, h, taur, tauenterre, e, eh, abatdco, abatngl, w_dbo5_eau, dbo5elim, q_sable_t, transp_anti_mousse, q_sulf_sod, transp_cl2, q_citrique, transp_ca_regen, q_caco3, q_mhetanol, transp_ca_neuf, q_phosphorique, transp_mhetanol, q_uree, q_sulf_alu, transp_antiscalant, transp_poly, transp_sulf, transp_catio, transp_caco3, transp_nahso3, transp_soude_c, q_anio, transp_kmno4, q_poly, transp_oxyl, transp_anio, transp_naclo3, q_soude_c, q_anti_mousse, q_nahso3, q_hcl, transp_citrique, transp_rei, transp_ethanol, q_ethanol, transp_soude, q_rei, transp_sulf_sod, q_naclo3, q_nitrique, q_ca_poudre, q_ca_regen, transp_h2o2, q_kmno4, transp_sulf_alu, transp_uree, q_catio, q_chaux, q_oxyl, transp_nitrique, transp_ca_poudre, transp_hcl, transp_chaux, q_h2o2, q_soude, q_ca_neuf, transp_phosphorique, transp_sable_t, q_antiscalant, q_cl2, q_sulf, qe, dco, ntk, mes, dbo5, vu, welec, tbentrant_s, ngl_s, dco_s, qe_s,model) VALUES (52, 'Point', '01010000206A080000F12F6C801C5024410C352B04FA1B5A41', 'clarificateur_4', '{"dco_s=eh*dco_eh*(1 - abatdco)","co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)","co2_c=(febet*cad*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*fepelle*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2 + 24.0*cad*vit*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(cad*vit)","co2_c=(febet*cad*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*fepelle*h*tauenterre*(h + e)*(0.3618*e + (vu/h)**0.5)**2 + 24.0*h*cad*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad)","tbentrant=0.0005*nbjour*(dbo5 + mes)",co2_e=feelec*welec,"ngl_s=eh*ntk_eh*(1 - abatngl)","dco_s=dco*(1 - abatdco)",co2_e=feelec*dbo5elim*w_dbo5_eau,"tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)","co2_c=(febet*cad*e*rhobet*(24*eh*qe_eh*(taur + 1) + 3.14159*h*vit*(e + 5.52791*(eh*qe_eh*(taur + 1)/vit)**0.5)) + 24.0*fepelle*tauenterre*vit*(h + e)*(0.3618*e + (eh*qe_eh*(taur + 1)/vit)**0.5)**2 + 24.0*cad*vit*(0.3618*e + (eh*qe_eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(cad*vit)","ngl_s=ntk*(1 - abatngl)"}', '{"dco_s fpr 3","CO2 exploitation intrant dessableurdegraisseur 6","CO2 construction clarificateur 2","CO2 construction bassin_cylindrique 3","tbentrant degazage 2","CO2 elec 6","ngl_s bassin_biologique 3","dco_s fpr 3","CO2 exploitation clarificateur 3","tbentrant digesteur_aerobie 1","CO2 construction clarificateur 1","ngl_s bassin_biologique 3"}', 'Soude', 50, 60, 3, 1, 0.75, 0.25, NULL, NULL, NULL, 5, NULL, NULL, 50, NULL, 50, NULL, 50, NULL, NULL, 50, NULL, 50, NULL, NULL, 50, 50, 50, 50, 50, 50, 50, NULL, 50, NULL, 50, 50, 50, NULL, NULL, NULL, NULL, 50, 50, 50, NULL, 50, NULL, 50, NULL, NULL, NULL, NULL, 50, NULL, 50, 50, NULL, NULL, NULL, 50, 50, 50, 50, NULL, NULL, NULL, 50, 50, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'model3');
INSERT INTO api.clarificateur_bloc (id, shape, geom, name, formula, formula_name, prod_e, d_vie, vit, h, taur, tauenterre, e, eh, abatdco, abatngl, w_dbo5_eau, dbo5elim, q_sable_t, transp_anti_mousse, q_sulf_sod, transp_cl2, q_citrique, transp_ca_regen, q_caco3, q_mhetanol, transp_ca_neuf, q_phosphorique, transp_mhetanol, q_uree, q_sulf_alu, transp_antiscalant, transp_poly, transp_sulf, transp_catio, transp_caco3, transp_nahso3, transp_soude_c, q_anio, transp_kmno4, q_poly, transp_oxyl, transp_anio, transp_naclo3, q_soude_c, q_anti_mousse, q_nahso3, q_hcl, transp_citrique, transp_rei, transp_ethanol, q_ethanol, transp_soude, q_rei, transp_sulf_sod, q_naclo3, q_nitrique, q_ca_poudre, q_ca_regen, transp_h2o2, q_kmno4, transp_sulf_alu, transp_uree, q_catio, q_chaux, q_oxyl, transp_nitrique, transp_ca_poudre, transp_hcl, transp_chaux, q_h2o2, q_soude, q_ca_neuf, transp_phosphorique, transp_sable_t, q_antiscalant, q_cl2, q_sulf, qe, dco, ntk, mes, dbo5, vu, welec, tbentrant_s, ngl_s, dco_s, qe_s,model) VALUES (32, 'Point', '01010000206A080000075202BA3C5024415CB5F07BEF1B5A41', 'clarificateur_2', '{"dco_s=eh*dco_eh*(1 - abatdco)","co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)","co2_c=(febet*cad*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe*(taur + 1)/vit)**0.5) + 24*qe*(taur + 1)) + 24.0*fepelle*tauenterre*vit*(h + e)*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2 + 24.0*cad*vit*(0.3618*e + (qe*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(cad*vit)","co2_c=(febet*cad*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*fepelle*h*tauenterre*(h + e)*(0.3618*e + (vu/h)**0.5)**2 + 24.0*h*cad*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad)","tbentrant=0.0005*nbjour*(dbo5 + mes)",co2_e=feelec*welec,"ngl_s=eh*ntk_eh*(1 - abatngl)","dco_s=dco*(1 - abatdco)",co2_e=feelec*dbo5elim*w_dbo5_eau,"tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)","co2_c=(febet*cad*e*rhobet*(24*eh*qe_eh*(taur + 1) + 3.14159*h*vit*(e + 5.52791*(eh*qe_eh*(taur + 1)/vit)**0.5)) + 24.0*fepelle*tauenterre*vit*(h + e)*(0.3618*e + (eh*qe_eh*(taur + 1)/vit)**0.5)**2 + 24.0*cad*vit*(0.3618*e + (eh*qe_eh*(taur + 1)/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(cad*vit)","ngl_s=ntk*(1 - abatngl)"}', '{"dco_s fpr 3","CO2 exploitation intrant dessableurdegraisseur 6","CO2 construction clarificateur 2","CO2 construction bassin_cylindrique 3","tbentrant degazage 2","CO2 elec 6","ngl_s bassin_biologique 3","dco_s fpr 3","CO2 exploitation clarificateur 3","tbentrant digesteur_aerobie 1","CO2 construction clarificateur 1","ngl_s bassin_biologique 3"}', 'Soude', 50, 60, 3, 1, 0, 0.25, 20000, NULL, NULL, 5, NULL, NULL, 50, NULL, 50, NULL, 50, NULL, NULL, 50, NULL, 50, NULL, NULL, 50, 50, 50, 50, 50, 50, 50, NULL, 50, NULL, 50, 50, 50, NULL, NULL, NULL, NULL, 50, 50, 50, NULL, 50, NULL, 50, NULL, NULL, NULL, NULL, 50, NULL, 50, 50, NULL, NULL, NULL, 50, 50, 50, 50, NULL, NULL, NULL, 50, 50, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'model2');


--
-- Data for Name: cloture_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: compostage_bloc; Type: TABLE DATA; Schema: api; Owner: -
--

INSERT INTO api.compostage_bloc (id, shape, geom, name, formula, formula_name, d_vie, eh, tbsortant, mes, dbo5, tbentrant, welec, tbsortant_s,model) VALUES (35, 'Point', '01010000206A0800005AF9E83CD74F244178A0D455D51B5A41', 'compostage_2', '{n2o_e=tbsortant*n2o_compost,"tbentrant=0.0005*nbjour*(dbo5 + mes)","co2_c=0.0005*fecompost*nbjour*(dbo5 + mes)",ch4_e=tbsortant*ch4_compost,co2_e=feelec*tbsortant*welec_compost,co2_e=fegazole*tbsortant*gazole_compost,co2_c=fecompost*tbentrant,"tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)",co2_e=feelec*welec,"co2_c=0.0005*eh*fecompost*nbjour*(dbo5_eh + mes_eh)"}', '{"N2O exploitation compostage 3","tbentrant degazage 2","CO2 construction compostage 2","CH4 exploitation compostage 3","CO2 exploitation compostage 3","CO2 exploitation compostage 3","CO2 construction compostage 3","tbentrant digesteur_aerobie 1","CO2 elec 6","CO2 construction compostage 1"}', 25, 20000, NULL, NULL, NULL, 547.5, NULL, NULL, 'model2');
INSERT INTO api.compostage_bloc (id, shape, geom, name, formula, formula_name, d_vie, eh, tbsortant, mes, dbo5, tbentrant, welec, tbsortant_s,model) VALUES (19, 'Point', '01010000206A080000BC1E85E1E94F24419A9959CED91B5A41', 'compostage_1', '{n2o_e=tbsortant*n2o_compost,"tbentrant=0.0005*nbjour*(dbo5 + mes)","co2_c=0.0005*fecompost*nbjour*(dbo5 + mes)",ch4_e=tbsortant*ch4_compost,co2_e=feelec*tbsortant*welec_compost,co2_e=fegazole*tbsortant*gazole_compost,co2_c=fecompost*tbentrant,"tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)",co2_e=feelec*welec,"co2_c=0.0005*eh*fecompost*nbjour*(dbo5_eh + mes_eh)"}', '{"N2O exploitation compostage 3","tbentrant degazage 2","CO2 construction compostage 2","CH4 exploitation compostage 3","CO2 exploitation compostage 3","CO2 exploitation compostage 3","CO2 construction compostage 3","tbentrant digesteur_aerobie 1","CO2 elec 6","CO2 construction compostage 1"}', 25, 20000, 500, NULL, NULL, 547.5, NULL, NULL, 'model1');


--
-- Data for Name: conditionnement_chimique_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: conditionnement_thermiqu_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: decanteur_lamellaire_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: deconstruction_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: degazage_bloc; Type: TABLE DATA; Schema: api; Owner: -
--

INSERT INTO api.degazage_bloc (id, shape, geom, name, formula, formula_name, prod_e, d_vie, vit, h, tauenterre, e, eh, abatdco, abatngl, w_dbo5_eau, dbo5elim, q_sable_t, transp_anti_mousse, q_sulf_sod, transp_cl2, q_citrique, transp_ca_regen, q_caco3, q_mhetanol, transp_ca_neuf, q_phosphorique, transp_mhetanol, q_uree, q_sulf_alu, transp_antiscalant, transp_poly, transp_sulf, transp_catio, transp_caco3, transp_nahso3, transp_soude_c, q_anio, transp_kmno4, q_poly, transp_oxyl, transp_anio, transp_naclo3, q_soude_c, q_anti_mousse, q_nahso3, q_hcl, transp_citrique, transp_rei, transp_ethanol, q_ethanol, transp_soude, q_rei, transp_sulf_sod, q_naclo3, q_nitrique, q_ca_poudre, q_ca_regen, transp_h2o2, q_kmno4, transp_sulf_alu, transp_uree, q_catio, q_chaux, q_oxyl, transp_nitrique, transp_ca_poudre, transp_hcl, transp_chaux, q_h2o2, q_soude, q_ca_neuf, transp_phosphorique, transp_sable_t, q_antiscalant, q_cl2, q_sulf, qe, dco, ntk, mes, dbo5, vu, welec, ngl_s, dco_s, qe_s,model) VALUES (46, 'Point', '01010000206A080000F9285C61245024413B6DE0E9011C5A41', 'degazage_1', '{"dco_s=eh*dco_eh*(1 - abatdco)","co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)","co2_c=(febet*cad*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*fepelle*h*tauenterre*(h + e)*(0.3618*e + (vu/h)**0.5)**2 + 24.0*h*cad*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad)","co2_c=(febet*cad*e*rhobet*(24*eh*qe_eh + 3.14159*h*vit*(e + 5.52791*(eh*qe_eh/vit)**0.5)) + 24.0*fepelle*tauenterre*vit*(h + e)*(0.3618*e + (eh*qe_eh/vit)**0.5)**2 + 24.0*cad*vit*(0.3618*e + (eh*qe_eh/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(cad*vit)","tbentrant=0.0005*nbjour*(dbo5 + mes)","ngl_s=eh*ntk_eh*(1 - abatngl)","dco_s=dco*(1 - abatdco)",co2_e=feelec*dbo5elim*w_dbo5_eau,"tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)",co2_e=feelec*welec,"co2_c=(febet*cad*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe/vit)**0.5) + 24*qe) + 24.0*fepelle*tauenterre*vit*(h + e)*(0.3618*e + (qe/vit)**0.5)**2 + 24.0*cad*vit*(0.3618*e + (qe/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(cad*vit)","ngl_s=ntk*(1 - abatngl)"}', '{"dco_s fpr 3","CO2 exploitation intrant dessableurdegraisseur 6","CO2 construction bassin_cylindrique 3","CO2 construction dessableurdegraisseur 1","tbentrant degazage 2","ngl_s bassin_biologique 3","dco_s fpr 3","CO2 exploitation clarificateur 3","tbentrant digesteur_aerobie 1","CO2 elec 6","CO2 construction degazage 2","ngl_s bassin_biologique 3"}', 'Soude', 50, 60, 5, 0.75, 0.25, 20000, NULL, NULL, 5, NULL, NULL, 50, NULL, 50, NULL, 50, NULL, NULL, 50, NULL, 50, NULL, NULL, 50, 50, 50, 50, 50, 50, 50, NULL, 50, NULL, 50, 50, 50, NULL, NULL, NULL, NULL, 50, 50, 50, NULL, 50, NULL, 50, NULL, NULL, NULL, NULL, 50, NULL, 50, 50, NULL, NULL, NULL, 50, 50, 50, 50, NULL, NULL, NULL, 50, 50, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'model1');
INSERT INTO api.degazage_bloc (id, shape, geom, name, formula, formula_name, prod_e, d_vie, vit, h, tauenterre, e, eh, abatdco, abatngl, w_dbo5_eau, dbo5elim, q_sable_t, transp_anti_mousse, q_sulf_sod, transp_cl2, q_citrique, transp_ca_regen, q_caco3, q_mhetanol, transp_ca_neuf, q_phosphorique, transp_mhetanol, q_uree, q_sulf_alu, transp_antiscalant, transp_poly, transp_sulf, transp_catio, transp_caco3, transp_nahso3, transp_soude_c, q_anio, transp_kmno4, q_poly, transp_oxyl, transp_anio, transp_naclo3, q_soude_c, q_anti_mousse, q_nahso3, q_hcl, transp_citrique, transp_rei, transp_ethanol, q_ethanol, transp_soude, q_rei, transp_sulf_sod, q_naclo3, q_nitrique, q_ca_poudre, q_ca_regen, transp_h2o2, q_kmno4, transp_sulf_alu, transp_uree, q_catio, q_chaux, q_oxyl, transp_nitrique, transp_ca_poudre, transp_hcl, transp_chaux, q_h2o2, q_soude, q_ca_neuf, transp_phosphorique, transp_sable_t, q_antiscalant, q_cl2, q_sulf, qe, dco, ntk, mes, dbo5, vu, welec, ngl_s, dco_s, qe_s,model) VALUES (47, 'Point', '01010000206A080000017B4ADF23502441DCE35919FA1B5A41', 'degazage_2', '{"dco_s=eh*dco_eh*(1 - abatdco)","co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)","co2_c=(febet*cad*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*fepelle*h*tauenterre*(h + e)*(0.3618*e + (vu/h)**0.5)**2 + 24.0*h*cad*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad)","co2_c=(febet*cad*e*rhobet*(24*eh*qe_eh + 3.14159*h*vit*(e + 5.52791*(eh*qe_eh/vit)**0.5)) + 24.0*fepelle*tauenterre*vit*(h + e)*(0.3618*e + (eh*qe_eh/vit)**0.5)**2 + 24.0*cad*vit*(0.3618*e + (eh*qe_eh/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(cad*vit)","tbentrant=0.0005*nbjour*(dbo5 + mes)","ngl_s=eh*ntk_eh*(1 - abatngl)","dco_s=dco*(1 - abatdco)",co2_e=feelec*dbo5elim*w_dbo5_eau,"tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)",co2_e=feelec*welec,"co2_c=(febet*cad*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe/vit)**0.5) + 24*qe) + 24.0*fepelle*tauenterre*vit*(h + e)*(0.3618*e + (qe/vit)**0.5)**2 + 24.0*cad*vit*(0.3618*e + (qe/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(cad*vit)","ngl_s=ntk*(1 - abatngl)"}', '{"dco_s fpr 3","CO2 exploitation intrant dessableurdegraisseur 6","CO2 construction bassin_cylindrique 3","CO2 construction dessableurdegraisseur 1","tbentrant degazage 2","ngl_s bassin_biologique 3","dco_s fpr 3","CO2 exploitation clarificateur 3","tbentrant digesteur_aerobie 1","CO2 elec 6","CO2 construction degazage 2","ngl_s bassin_biologique 3"}', 'Soude', 50, 60, 5, 0.75, 0.25, 20000, NULL, NULL, 5, NULL, NULL, 50, NULL, 50, NULL, 50, NULL, NULL, 50, NULL, 50, NULL, NULL, 50, 50, 50, 50, 50, 50, 50, NULL, 50, NULL, 50, 50, 50, NULL, NULL, NULL, NULL, 50, 50, 50, NULL, 50, NULL, 50, NULL, NULL, NULL, NULL, 50, NULL, 50, 50, NULL, NULL, NULL, 50, 50, 50, 50, NULL, NULL, NULL, 50, 50, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'model2');


--
-- Data for Name: degrilleur_bloc; Type: TABLE DATA; Schema: api; Owner: -
--

INSERT INTO api.degrilleur_bloc (id, shape, geom, name, formula, formula_name, d_vie, welec, qdechet, eh, qmax, munite_degrilleur, qe, mes, dbo5, qe_s,model) VALUES (10, 'Point', '01010000206A08000082B1E455E64F2441B6818E32131C5A41', 'degrilleur_1', '{co2_c=eh*fepoids*munite_degrilleur*qe_eh/qmax,"tbentrant=0.0005*nbjour*(dbo5 + mes)",co2_c=fepoids*munite_degrilleur*qe/qmax,"tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)",co2_e=feelec*welec,co2_e=eh*fedechet*qdechet*rhodechet}', '{"CO2 construction degrilleur 1","tbentrant degazage 2","CO2 construction degrilleur 2","tbentrant digesteur_aerobie 1","CO2 elec 6","CO2 exploitation degrilleur 1"}', 15, NULL, 'Compactage avec piston', 20000, 6000, 1500, NULL, NULL, NULL, NULL, 'model1');
INSERT INTO api.degrilleur_bloc (id, shape, geom, name, formula, formula_name, d_vie, welec, qdechet, eh, qmax, munite_degrilleur, qe, mes, dbo5, qe_s,model) VALUES (50, 'Point', '01010000206A080000DAF0B4EBE44F244154639C8F111C5A41', 'degrilleur_3', '{co2_c=eh*fepoids*munite_degrilleur*qe_eh/qmax,"tbentrant=0.0005*nbjour*(dbo5 + mes)",co2_c=fepoids*munite_degrilleur*qe/qmax,"tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)",co2_e=feelec*welec,co2_e=eh*fedechet*qdechet*rhodechet}', '{"CO2 construction degrilleur 1","tbentrant degazage 2","CO2 construction degrilleur 2","tbentrant digesteur_aerobie 1","CO2 elec 6","CO2 exploitation degrilleur 1"}', 15, NULL, 'Compactage avec piston', NULL, 6000, 1500, NULL, NULL, NULL, NULL, 'model3');
INSERT INTO api.degrilleur_bloc (id, shape, geom, name, formula, formula_name, d_vie, welec, qdechet, eh, qmax, munite_degrilleur, qe, mes, dbo5, qe_s,model) VALUES (27, 'Point', '01010000206A0800005FD0A017F04F244129FC3B2D121C5A41', 'degrilleur_2', '{co2_c=eh*fepoids*munite_degrilleur*qe_eh/qmax,"tbentrant=0.0005*nbjour*(dbo5 + mes)",co2_c=fepoids*munite_degrilleur*qe/qmax,"tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)",co2_e=feelec*welec,co2_e=eh*fedechet*qdechet*rhodechet}', '{"CO2 construction degrilleur 1","tbentrant degazage 2","CO2 construction degrilleur 2","tbentrant digesteur_aerobie 1","CO2 elec 6","CO2 exploitation degrilleur 1"}', 15, NULL, 'Compactage avec piston', 20000, 6000, 1500, NULL, NULL, NULL, NULL, 'model2');


--
-- Data for Name: dessableurdegraisseur_bloc; Type: TABLE DATA; Schema: api; Owner: -
--

INSERT INTO api.dessableurdegraisseur_bloc (id, shape, geom, name, formula, formula_name, prod_e, d_vie, w_dbo5_eau, dbo5elim, q_sable_t, transp_anti_mousse, q_sulf_sod, transp_cl2, q_citrique, transp_ca_regen, q_caco3, q_mhetanol, transp_ca_neuf, q_phosphorique, transp_mhetanol, q_uree, q_sulf_alu, transp_antiscalant, transp_poly, transp_sulf, transp_catio, transp_caco3, transp_nahso3, transp_soude_c, q_anio, transp_kmno4, q_poly, transp_oxyl, transp_anio, transp_naclo3, q_soude_c, q_anti_mousse, q_nahso3, q_hcl, transp_citrique, transp_rei, transp_ethanol, q_ethanol, transp_soude, q_rei, transp_sulf_sod, q_naclo3, q_nitrique, q_ca_poudre, q_ca_regen, transp_h2o2, q_kmno4, transp_sulf_alu, transp_uree, q_catio, q_chaux, q_oxyl, transp_nitrique, transp_ca_poudre, transp_hcl, transp_chaux, q_h2o2, q_soude, q_ca_neuf, transp_phosphorique, transp_sable_t, q_antiscalant, q_cl2, q_sulf, conc, lavage, eh, vit, h, tauenterre, e, abatdco, abatngl, qe, dco, ntk, mes, dbo5, tsables, tgraisses, vu, welec, qe_s, ngl_s, dco_s,model) VALUES (51, 'Point', '01010000206A080000C295D22AFF4F2441848B4BFB051C5A41', 'dessableurdegraisseur_3', '{"dco_s=eh*dco_eh*(1 - abatdco)","co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)","co2_c=(febet*cad*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*fepelle*h*tauenterre*(h + e)*(0.3618*e + (vu/h)**0.5)**2 + 24.0*h*cad*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad)","co2_e=eh*(fedechet*dgraisses*(lgraisses_c*conc - lgraisses_nc*(conc - 1)) + fesables*(lavage*sables_lavé - sables_nlavé*(lavage - 1)))","co2_c=(febet*cad*e*rhobet*(24*eh*qe_eh + 3.14159*h*vit*(e + 5.52791*(eh*qe_eh/vit)**0.5)) + 24.0*fepelle*tauenterre*vit*(h + e)*(0.3618*e + (eh*qe_eh/vit)**0.5)**2 + 24.0*cad*vit*(0.3618*e + (eh*qe_eh/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(cad*vit)","tbentrant=0.0005*nbjour*(dbo5 + mes)","ngl_s=eh*ntk_eh*(1 - abatngl)","dco_s=dco*(1 - abatdco)",co2_e=feelec*dbo5elim*w_dbo5_eau,"tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)",co2_e=feelec*welec,"co2_c=(febet*cad*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe/vit)**0.5) + 24*qe) + 24.0*fepelle*tauenterre*vit*(h + e)*(0.3618*e + (qe/vit)**0.5)**2 + 24.0*cad*vit*(0.3618*e + (qe/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(cad*vit)","co2_e=fedechet*tgraisses + fesables*tsables","ngl_s=ntk*(1 - abatngl)"}', '{"dco_s fpr 3","CO2 exploitation intrant dessableurdegraisseur 6","CO2 construction bassin_cylindrique 3","CO2 exploitation dessableurdegraisseur 1","CO2 construction dessableurdegraisseur 1","tbentrant degazage 2","ngl_s bassin_biologique 3","dco_s fpr 3","CO2 exploitation clarificateur 3","tbentrant digesteur_aerobie 1","CO2 elec 6","CO2 construction degazage 2","CO2 exploitation dessableurdegraisseur 3","ngl_s bassin_biologique 3"}', 'Soude', 50, 5, NULL, NULL, 50, NULL, 50, NULL, 50, NULL, NULL, 50, NULL, 50, NULL, NULL, 50, 50, 50, 50, 50, 50, 50, NULL, 50, NULL, 50, 50, 50, NULL, NULL, NULL, NULL, 50, 50, 50, NULL, 50, NULL, 50, NULL, NULL, NULL, NULL, 50, NULL, 50, 50, NULL, NULL, NULL, 50, 50, 50, 50, NULL, NULL, NULL, 50, 50, NULL, NULL, NULL, true, false, NULL, 20, 4, 0.75, 0.25, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'model3');
INSERT INTO api.dessableurdegraisseur_bloc (id, shape, geom, name, formula, formula_name, prod_e, d_vie, w_dbo5_eau, dbo5elim, q_sable_t, transp_anti_mousse, q_sulf_sod, transp_cl2, q_citrique, transp_ca_regen, q_caco3, q_mhetanol, transp_ca_neuf, q_phosphorique, transp_mhetanol, q_uree, q_sulf_alu, transp_antiscalant, transp_poly, transp_sulf, transp_catio, transp_caco3, transp_nahso3, transp_soude_c, q_anio, transp_kmno4, q_poly, transp_oxyl, transp_anio, transp_naclo3, q_soude_c, q_anti_mousse, q_nahso3, q_hcl, transp_citrique, transp_rei, transp_ethanol, q_ethanol, transp_soude, q_rei, transp_sulf_sod, q_naclo3, q_nitrique, q_ca_poudre, q_ca_regen, transp_h2o2, q_kmno4, transp_sulf_alu, transp_uree, q_catio, q_chaux, q_oxyl, transp_nitrique, transp_ca_poudre, transp_hcl, transp_chaux, q_h2o2, q_soude, q_ca_neuf, transp_phosphorique, transp_sable_t, q_antiscalant, q_cl2, q_sulf, conc, lavage, eh, vit, h, tauenterre, e, abatdco, abatngl, qe, dco, ntk, mes, dbo5, tsables, tgraisses, vu, welec, qe_s, ngl_s, dco_s,model) VALUES (11, 'Point', '01010000206A080000DE40A79BFB4F2441F38B65380B1C5A41', 'dessableurdegraisseur_1', '{"dco_s=eh*dco_eh*(1 - abatdco)","co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)","co2_c=(febet*cad*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*fepelle*h*tauenterre*(h + e)*(0.3618*e + (vu/h)**0.5)**2 + 24.0*h*cad*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad)","co2_e=eh*(fedechet*dgraisses*(lgraisses_c*conc - lgraisses_nc*(conc - 1)) + fesables*(lavage*sables_lavé - sables_nlavé*(lavage - 1)))","co2_c=(febet*cad*e*rhobet*(24*eh*qe_eh + 3.14159*h*vit*(e + 5.52791*(eh*qe_eh/vit)**0.5)) + 24.0*fepelle*tauenterre*vit*(h + e)*(0.3618*e + (eh*qe_eh/vit)**0.5)**2 + 24.0*cad*vit*(0.3618*e + (eh*qe_eh/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(cad*vit)","tbentrant=0.0005*nbjour*(dbo5 + mes)","ngl_s=eh*ntk_eh*(1 - abatngl)","dco_s=dco*(1 - abatdco)",co2_e=feelec*dbo5elim*w_dbo5_eau,"tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)",co2_e=feelec*welec,"co2_c=(febet*cad*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe/vit)**0.5) + 24*qe) + 24.0*fepelle*tauenterre*vit*(h + e)*(0.3618*e + (qe/vit)**0.5)**2 + 24.0*cad*vit*(0.3618*e + (qe/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(cad*vit)","co2_e=fedechet*tgraisses + fesables*tsables","ngl_s=ntk*(1 - abatngl)"}', '{"dco_s fpr 3","CO2 exploitation intrant dessableurdegraisseur 6","CO2 construction bassin_cylindrique 3","CO2 exploitation dessableurdegraisseur 1","CO2 construction dessableurdegraisseur 1","tbentrant degazage 2","ngl_s bassin_biologique 3","dco_s fpr 3","CO2 exploitation clarificateur 3","tbentrant digesteur_aerobie 1","CO2 elec 6","CO2 construction degazage 2","CO2 exploitation dessableurdegraisseur 3","ngl_s bassin_biologique 3"}', 'Soude', 50, 5, NULL, NULL, 50, NULL, 50, NULL, 50, NULL, NULL, 50, NULL, 50, NULL, NULL, 50, 50, 50, 50, 50, 50, 50, NULL, 50, NULL, 50, 50, 50, NULL, NULL, NULL, NULL, 50, 50, 50, NULL, 50, NULL, 50, NULL, NULL, NULL, NULL, 50, NULL, 50, 50, NULL, NULL, NULL, 50, 50, 50, 50, NULL, 1, NULL, 50, 50, NULL, NULL, NULL, true, false, 20000, 20, 4, 0.75, 0.25, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'model1');
INSERT INTO api.dessableurdegraisseur_bloc (id, shape, geom, name, formula, formula_name, prod_e, d_vie, w_dbo5_eau, dbo5elim, q_sable_t, transp_anti_mousse, q_sulf_sod, transp_cl2, q_citrique, transp_ca_regen, q_caco3, q_mhetanol, transp_ca_neuf, q_phosphorique, transp_mhetanol, q_uree, q_sulf_alu, transp_antiscalant, transp_poly, transp_sulf, transp_catio, transp_caco3, transp_nahso3, transp_soude_c, q_anio, transp_kmno4, q_poly, transp_oxyl, transp_anio, transp_naclo3, q_soude_c, q_anti_mousse, q_nahso3, q_hcl, transp_citrique, transp_rei, transp_ethanol, q_ethanol, transp_soude, q_rei, transp_sulf_sod, q_naclo3, q_nitrique, q_ca_poudre, q_ca_regen, transp_h2o2, q_kmno4, transp_sulf_alu, transp_uree, q_catio, q_chaux, q_oxyl, transp_nitrique, transp_ca_poudre, transp_hcl, transp_chaux, q_h2o2, q_soude, q_ca_neuf, transp_phosphorique, transp_sable_t, q_antiscalant, q_cl2, q_sulf, conc, lavage, eh, vit, h, tauenterre, e, abatdco, abatngl, qe, dco, ntk, mes, dbo5, tsables, tgraisses, vu, welec, qe_s, ngl_s, dco_s,model) VALUES (28, 'Point', '01010000206A080000CFAA1EE00650244133D64162021C5A41', 'dessableurdegraisseur_2', '{"dco_s=eh*dco_eh*(1 - abatdco)","co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)","co2_c=(febet*cad*e*rhobet*(3.14159*h**2*(e + 5.52791*(vu/h)**0.5) + 24*vu) + 24.0*fepelle*h*tauenterre*(h + e)*(0.3618*e + (vu/h)**0.5)**2 + 24.0*h*cad*(0.3618*e + (vu/h)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(h*cad)","co2_e=eh*(fedechet*dgraisses*(lgraisses_c*conc - lgraisses_nc*(conc - 1)) + fesables*(lavage*sables_lavé - sables_nlavé*(lavage - 1)))","co2_c=(febet*cad*e*rhobet*(24*eh*qe_eh + 3.14159*h*vit*(e + 5.52791*(eh*qe_eh/vit)**0.5)) + 24.0*fepelle*tauenterre*vit*(h + e)*(0.3618*e + (eh*qe_eh/vit)**0.5)**2 + 24.0*cad*vit*(0.3618*e + (eh*qe_eh/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(cad*vit)","tbentrant=0.0005*nbjour*(dbo5 + mes)","ngl_s=eh*ntk_eh*(1 - abatngl)","dco_s=dco*(1 - abatdco)",co2_e=feelec*dbo5elim*w_dbo5_eau,"tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)",co2_e=feelec*welec,"co2_c=(febet*cad*e*rhobet*(3.14159*h*vit*(e + 5.52791*(qe/vit)**0.5) + 24*qe) + 24.0*fepelle*tauenterre*vit*(h + e)*(0.3618*e + (qe/vit)**0.5)**2 + 24.0*cad*vit*(0.3618*e + (qe/vit)**0.5)**2*(feevac*rhoterre*tauenterre*(h + e) + fefonda))/(cad*vit)","co2_e=fedechet*tgraisses + fesables*tsables","ngl_s=ntk*(1 - abatngl)"}', '{"dco_s fpr 3","CO2 exploitation intrant dessableurdegraisseur 6","CO2 construction bassin_cylindrique 3","CO2 exploitation dessableurdegraisseur 1","CO2 construction dessableurdegraisseur 1","tbentrant degazage 2","ngl_s bassin_biologique 3","dco_s fpr 3","CO2 exploitation clarificateur 3","tbentrant digesteur_aerobie 1","CO2 elec 6","CO2 construction degazage 2","CO2 exploitation dessableurdegraisseur 3","ngl_s bassin_biologique 3"}', 'Soude', 50, 5, NULL, NULL, 50, NULL, 50, NULL, 50, NULL, NULL, 50, NULL, 50, NULL, NULL, 50, 50, 50, 50, 50, 50, 50, NULL, 50, NULL, 50, 50, 50, NULL, NULL, NULL, NULL, 50, 50, 50, NULL, 50, NULL, 50, NULL, NULL, NULL, NULL, 50, NULL, 50, 50, NULL, NULL, NULL, 50, 50, 50, 50, NULL, NULL, NULL, 50, 50, NULL, NULL, NULL, true, false, 20000, 20, 4, 1, 0.25, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'model2');


--
-- Data for Name: digesteur__methaniseur_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: digesteur_aerobie_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: epaississement_statique_bloc; Type: TABLE DATA; Schema: api; Owner: -
--

INSERT INTO api.epaississement_statique_bloc (id, shape, geom, name, formula, formula_name, d_vie, eh, tbsortant, mes, dbo5, tbentrant, welec, tbsortant_s,model) VALUES (34, 'Point', '01010000206A080000CFAA1EE0065024411417F407DB1B5A41', 'epaississement_statique_2', '{"tbentrant=0.0005*nbjour*(dbo5 + mes)",co2_c=((feobj10_es)*(eh<10000)+(feobj50_es)*(eh>10000)*(eh<100000)+(feobj100_es)*(eh>100000))*tbentrant,"tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)",co2_e=feelec*tbsortant*welec_es,co2_e=feelec*welec,co2_c=((feobj10_es)*(eh<10000)+(feobj50_es)*(eh>10000)*(eh<100000)+(feobj100_es)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour),co2_c=((feobj10_es)*(eh<10000)+(feobj50_es)*(eh>10000)*(eh<100000)+(feobj100_es)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)}', '{"tbentrant degazage 2","CO2 construction epaississement_statique 3","tbentrant digesteur_aerobie 1","CO2 exploitation epaississement_statique 3","CO2 elec 6","CO2 construction epaississement_statique 2","CO2 construction epaississement_statique 1"}', 30, 20000, NULL, NULL, NULL, 547.5, NULL, NULL, 'model2');
INSERT INTO api.epaississement_statique_bloc (id, shape, geom, name, formula, formula_name, d_vie, eh, tbsortant, mes, dbo5, tbentrant, welec, tbsortant_s,model) VALUES (18, 'Point', '01010000206A080000D1CCCCB2295024418988C88FE11B5A41', 'epaississement_statique_1', '{"tbentrant=0.0005*nbjour*(dbo5 + mes)",co2_c=((feobj10_es)*(eh<10000)+(feobj50_es)*(eh>10000)*(eh<100000)+(feobj100_es)*(eh>100000))*tbentrant,"tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)",co2_e=feelec*tbsortant*welec_es,co2_e=feelec*welec,co2_c=((feobj10_es)*(eh<10000)+(feobj50_es)*(eh>10000)*(eh<100000)+(feobj100_es)*(eh>100000))*((dbo5/2+mes/2)/1000*nbjour),co2_c=((feobj10_es)*(eh<10000)+(feobj50_es)*(eh>10000)*(eh<100000)+(feobj100_es)*(eh>100000))*(((dbo5_eh*eh)/2+(mes_eh*eh)/2)/1000*nbjour)}', '{"tbentrant degazage 2","CO2 construction epaississement_statique 3","tbentrant digesteur_aerobie 1","CO2 exploitation epaississement_statique 3","CO2 elec 6","CO2 construction epaississement_statique 2","CO2 construction epaississement_statique 1"}', 30, 20000, 500, NULL, NULL, 547.5, NULL, NULL, 'model1');


--
-- Data for Name: excavation_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: filiere_boue_bloc; Type: TABLE DATA; Schema: api; Owner: -
--

INSERT INTO api.filiere_boue_bloc (id, shape, geom, name, formula, formula_name, d_vie, eh, welec, mes, dbo5, tbsortant_s,model) VALUES (5, 'Polygon', '01030000206A0800000100000006000000F9285C61245024410BD7636BEC1B5A412C5C8F04BA4F2441073A2DB4D61B5A41B147E1F8C94F2441E27AD47FD01B5A41FA285C55A95024417FB124E4E21B5A41079D363E7B502441184BBE2FF01B5A41F9285C61245024410BD7636BEC1B5A41', 'filiere_boue_1', '{co2_e=feelec*welec,"tbentrant=0.0005*nbjour*(dbo5 + mes)","tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)"}', '{"CO2 elec 6","tbentrant degazage 2","tbentrant digesteur_aerobie 1"}', 15, NULL, NULL, NULL, NULL, NULL, 'model1');
INSERT INTO api.filiere_boue_bloc (id, shape, geom, name, formula, formula_name, d_vie, eh, welec, mes, dbo5, tbsortant_s,model) VALUES (45, 'Polygon', '01030000206A080000010000000500000054168A7020502441D816CE8BE71B5A419E943BE5A74F244145B721D3D31B5A418AE6F307ED4F24419035539DCF1B5A41450579879C502441D4791773E21B5A4154168A7020502441D816CE8BE71B5A41', 'filiere_boue_2', '{co2_e=feelec*welec,"tbentrant=0.0005*nbjour*(dbo5 + mes)","tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)"}', '{"CO2 elec 6","tbentrant degazage 2","tbentrant digesteur_aerobie 1"}', 15, NULL, NULL, NULL, NULL, NULL, 'model2');


--
-- Data for Name: filiere_eau_bloc; Type: TABLE DATA; Schema: api; Owner: -
--

INSERT INTO api.filiere_eau_bloc (id, shape, geom, name, formula, formula_name, prod_e, d_vie, abatdco, eh, abatngl, dbo5elim, q_sable_t, transp_anti_mousse, q_sulf_sod, transp_cl2, q_citrique, transp_ca_regen, q_caco3, q_mhetanol, transp_ca_neuf, q_phosphorique, transp_mhetanol, q_uree, q_sulf_alu, transp_antiscalant, transp_poly, transp_sulf, transp_catio, transp_caco3, transp_nahso3, transp_soude_c, q_anio, transp_kmno4, q_poly, transp_oxyl, transp_anio, transp_naclo3, q_soude_c, q_anti_mousse, q_nahso3, q_hcl, transp_citrique, transp_rei, transp_ethanol, q_ethanol, transp_soude, q_rei, transp_sulf_sod, q_naclo3, q_nitrique, q_ca_poudre, q_ca_regen, transp_h2o2, q_kmno4, transp_sulf_alu, transp_uree, q_catio, q_chaux, q_oxyl, transp_nitrique, transp_ca_poudre, transp_hcl, transp_chaux, q_h2o2, q_soude, q_ca_neuf, transp_phosphorique, transp_sable_t, q_antiscalant, q_cl2, q_sulf, dco, ntk, mes, dbo5, welec, ngl_s, dco_s, qe_s,model) VALUES (4, 'Polygon', '01030000206A08000001000000050000006D039D84A64F244175DA0014161C5A41521BE8B2025024413B6D604BF11B5A41C7F528BE8E502441B91E450EF71B5A41B9814EE1375024419A9959481C1C5A416D039D84A64F244175DA0014161C5A41', 'filiere_eau_1', '{"dco_s=eh*dco_eh*(1 - abatdco)","co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)","tbentrant=0.0005*nbjour*(dbo5 + mes)","ngl_s=eh*ntk_eh*(1 - abatngl)","dco_s=dco*(1 - abatdco)",co2_e=feelec*dbo5elim*w_dbo5_eau,"tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)",co2_e=feelec*welec,"ngl_s=ntk*(1 - abatngl)"}', '{"dco_s fpr 3","CO2 exploitation intrant dessableurdegraisseur 6","tbentrant degazage 2","ngl_s bassin_biologique 3","dco_s fpr 3","CO2 exploitation clarificateur 3","tbentrant digesteur_aerobie 1","CO2 elec 6","ngl_s bassin_biologique 3"}', 'Soude', 50, NULL, NULL, NULL, 5, NULL, 50, NULL, 50, NULL, 50, NULL, NULL, 50, NULL, 50, NULL, NULL, 50, 50, 50, 50, 50, 50, 50, NULL, 50, NULL, 50, 50, 50, NULL, NULL, NULL, NULL, 50, 50, 50, NULL, 50, NULL, 50, NULL, NULL, NULL, NULL, 50, NULL, 50, 50, NULL, NULL, NULL, 50, 50, 50, 50, NULL, NULL, NULL, 50, 50, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'model1');
INSERT INTO api.filiere_eau_bloc (id, shape, geom, name, formula, formula_name, prod_e, d_vie, abatdco, eh, abatngl, dbo5elim, q_sable_t, transp_anti_mousse, q_sulf_sod, transp_cl2, q_citrique, transp_ca_regen, q_caco3, q_mhetanol, transp_ca_neuf, q_phosphorique, transp_mhetanol, q_uree, q_sulf_alu, transp_antiscalant, transp_poly, transp_sulf, transp_catio, transp_caco3, transp_nahso3, transp_soude_c, q_anio, transp_kmno4, q_poly, transp_oxyl, transp_anio, transp_naclo3, q_soude_c, q_anti_mousse, q_nahso3, q_hcl, transp_citrique, transp_rei, transp_ethanol, q_ethanol, transp_soude, q_rei, transp_sulf_sod, q_naclo3, q_nitrique, q_ca_poudre, q_ca_regen, transp_h2o2, q_kmno4, transp_sulf_alu, transp_uree, q_catio, q_chaux, q_oxyl, transp_nitrique, transp_ca_poudre, transp_hcl, transp_chaux, q_h2o2, q_soude, q_ca_neuf, transp_phosphorique, transp_sable_t, q_antiscalant, q_cl2, q_sulf, dco, ntk, mes, dbo5, welec, ngl_s, dco_s, qe_s,model) VALUES (44, 'Polygon', '01030000206A08000001000000050000003BCB0BABA94F2441F79B396A151C5A41382ED5AAF74F2441F061CCFBE91B5A4133F467AA935024418D989CC1EB1B5A413CCB0B9F2E502441CE3FAABB1A1C5A413BCB0BABA94F2441F79B396A151C5A41', 'filiere_eau_2', '{"dco_s=eh*dco_eh*(1 - abatdco)","co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)","tbentrant=0.0005*nbjour*(dbo5 + mes)","ngl_s=eh*ntk_eh*(1 - abatngl)","dco_s=dco*(1 - abatdco)",co2_e=feelec*dbo5elim*w_dbo5_eau,"tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)",co2_e=feelec*welec,"ngl_s=ntk*(1 - abatngl)"}', '{"dco_s fpr 3","CO2 exploitation intrant dessableurdegraisseur 6","tbentrant degazage 2","ngl_s bassin_biologique 3","dco_s fpr 3","CO2 exploitation clarificateur 3","tbentrant digesteur_aerobie 1","CO2 elec 6","ngl_s bassin_biologique 3"}', 'Soude', 50, NULL, NULL, NULL, 5, NULL, 50, NULL, 50, NULL, 50, NULL, NULL, 50, NULL, 50, NULL, NULL, 50, 50, 50, 50, 50, 50, 50, NULL, 50, NULL, 50, 50, 50, NULL, NULL, NULL, NULL, 50, 50, 50, NULL, 50, NULL, 50, NULL, NULL, NULL, NULL, 50, NULL, 50, 50, NULL, NULL, NULL, 50, 50, 50, 50, NULL, NULL, NULL, 50, 50, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'model2');


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



--
-- Data for Name: lagunage_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: lien_bloc; Type: TABLE DATA; Schema: api; Owner: -
--

INSERT INTO api.lien_bloc (id, shape, geom, name, formula, formula_name,model) VALUES (14, 'LineString', '01020000206A0800000200000082B1E455E64F2441B6818E32131C5A41DE40A79BFB4F2441F38B65380B1C5A41', 'lien_bloc_1', '{}', '{}', 'model1');
INSERT INTO api.lien_bloc (id, shape, geom, name, formula, formula_name,model) VALUES (15, 'LineString', '01020000206A08000002000000DE40A79BFB4F2441F38B65380B1C5A41F9285C61245024413B6DE0E9011C5A41', 'lien_bloc_2', '{}', '{}', 'model1');
INSERT INTO api.lien_bloc (id, shape, geom, name, formula, formula_name,model) VALUES (16, 'LineString', '01020000206A08000002000000F9285C61245024413B6DE0E9011C5A411C4B7E1B365024417877B7EFF91B5A41', 'lien_bloc_3', '{}', '{}', 'model1');
INSERT INTO api.lien_bloc (id, shape, geom, name, formula, formula_name,model) VALUES (20, 'LineString', '01020000206A080000020000001C4B7E1B365024417877B7EFF91B5A41151111274D5024414C7EF189E91B5A41', 'lien_bloc_4', '{}', '{}', 'model1');
INSERT INTO api.lien_bloc (id, shape, geom, name, formula, formula_name,model) VALUES (21, 'LineString', '01020000206A08000002000000151111274D5024414C7EF189E91B5A41D1CCCCB2295024418988C88FE11B5A41', 'lien_bloc_5', '{}', '{}', 'model1');
INSERT INTO api.lien_bloc (id, shape, geom, name, formula, formula_name,model) VALUES (22, 'LineString', '01020000206A08000002000000D1CCCCB2295024418988C88FE11B5A41BC1E85E1E94F24419A9959CED91B5A41', 'lien_bloc_6', '{}', '{}', 'model1');
INSERT INTO api.lien_bloc (id, shape, geom, name, formula, formula_name,model) VALUES (24, 'LineString', '01020000206A080000020000001C4B7E1B365024417877B7EFF91B5A419372DEB58D4F2441A940700AFC1B5A41', 'lien_bloc_7', '{}', '{}', 'model1');
INSERT INTO api.lien_bloc (id, shape, geom, name, formula, formula_name,model) VALUES (37, 'LineString', '01020000206A080000020000005FD0A017F04F244129FC3B2D121C5A41CFAA1EE00650244133D64162021C5A41', 'lien_bloc_8', '{}', '{}', 'model2');
INSERT INTO api.lien_bloc (id, shape, geom, name, formula, formula_name,model) VALUES (38, 'LineString', '01020000206A08000002000000CFAA1EE00650244133D64162021C5A41017B4ADF23502441DCE35919FA1B5A41', 'lien_bloc_9', '{}', '{}', 'model2');
INSERT INTO api.lien_bloc (id, shape, geom, name, formula, formula_name,model) VALUES (39, 'LineString', '01020000206A08000002000000017B4ADF23502441DCE35919FA1B5A41075202BA3C5024415CB5F07BEF1B5A41', 'lien_bloc_10', '{}', '{}', 'model2');
INSERT INTO api.lien_bloc (id, shape, geom, name, formula, formula_name,model) VALUES (40, 'LineString', '01020000206A08000002000000075202BA3C5024415CB5F07BEF1B5A4167330F07B44F2441EEF437BEEF1B5A41', 'lien_bloc_11', '{}', '{}', 'model2');
INSERT INTO api.lien_bloc (id, shape, geom, name, formula, formula_name,model) VALUES (41, 'LineString', '01020000206A08000002000000075202BA3C5024415CB5F07BEF1B5A41AF5F1A7134502441D9C9940EE31B5A41', 'lien_bloc_12', '{}', '{}', 'model2');
INSERT INTO api.lien_bloc (id, shape, geom, name, formula, formula_name,model) VALUES (42, 'LineString', '01020000206A08000002000000AF5F1A7134502441D9C9940EE31B5A41CFAA1EE0065024411417F407DB1B5A41', 'lien_bloc_13', '{}', '{}', 'model2');
INSERT INTO api.lien_bloc (id, shape, geom, name, formula, formula_name,model) VALUES (43, 'LineString', '01020000206A08000002000000CFAA1EE0065024411417F407DB1B5A415AF9E83CD74F244178A0D455D51B5A41', 'lien_bloc_14', '{}', '{}', 'model2');
INSERT INTO api.lien_bloc (id, shape, geom, name, formula, formula_name,model) VALUES (53, 'LineString', '01020000206A08000002000000DAF0B4EBE44F244154639C8F111C5A41C295D22AFF4F2441848B4BFB051C5A41', 'lien_bloc_15', '{}', '{}', 'model3');
INSERT INTO api.lien_bloc (id, shape, geom, name, formula, formula_name,model) VALUES (54, 'LineString', '01020000206A08000002000000C295D22AFF4F2441848B4BFB051C5A41F12F6C801C5024410C352B04FA1B5A41', 'lien_bloc_16', '{}', '{}', 'model3');


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

INSERT INTO api.rejets_bloc (id, shape, geom, name, formula, formula_name, abatdco, fech4_mil, eh, abatngl, fen2o_oxi, dco, ngl,model) VALUES (23, 'Point', '01010000206A0800009372DEB58D4F2441A940700AFC1B5A41', 'rejets_1', '{ch4_e=dco*fech4_mil,"ch4_e=eh*fech4_mil*dco_eh*(1 - abatdco)",n2o_e=fen2o_oxi*ngl,"n2o_e=eh*fen2o_oxi*ntk_eh*(1 - abatngl)"}', '{"CH4 exploitation rejets 2","CH4 exploitation rejets 1","N2O exploitation rejets 2","N2O exploitation rejets 1"}', 0.75, 'Réservoirs, lac, estuaires', 20000, 0.8, 'Peu oxygéné', NULL, NULL, 'model1');
INSERT INTO api.rejets_bloc (id, shape, geom, name, formula, formula_name, abatdco, fech4_mil, eh, abatngl, fen2o_oxi, dco, ngl,model) VALUES (36, 'Point', '01010000206A08000067330F07B44F2441EEF437BEEF1B5A41', 'rejets_2', '{ch4_e=dco*fech4_mil,"ch4_e=eh*fech4_mil*dco_eh*(1 - abatdco)",n2o_e=fen2o_oxi*ngl,"n2o_e=eh*fen2o_oxi*ntk_eh*(1 - abatngl)"}', '{"CH4 exploitation rejets 2","CH4 exploitation rejets 1","N2O exploitation rejets 2","N2O exploitation rejets 1"}', 0.75, 'Réservoirs, lac, estuaires', 20000, 0.8, 'Peu oxygéné', NULL, NULL, 'model2');


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

INSERT INTO api.stockage_boue_bloc (id, shape, geom, name, formula, formula_name, d_vie, grand, aere, dbo, welec, eh, festock, mes, dbo5, tbentrant, tbsortant_s,model) VALUES (33, 'Point', '01010000206A080000AF5F1A7134502441D9C9940EE31B5A41', 'stockage_boue_2', '{co2_e=fesilo_aere*tbentrant*aere,"tbentrant=0.0005*nbjour*(dbo5 + mes)","co2_e=0.0005*eh*fesilo_aere*nbjour*aere*(dbo5_eh + mes_eh)","co2_c=0.0005*eh*festock*nbjour*(dbo5_eh + mes_eh)","co2_c=0.0005*festock*nbjour*(dbo5 + mes)",co2_c=festock*tbentrant,"co2_e=0.0005*fesilo_aere*nbjour*aere*(dbo5 + mes)","tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)",co2_e=feelec*welec,"ch4_e=-dbo*(aere - 1)*(fesilo_grand*grand - fesilo_petit*(grand - 1))"}', '{"CO2 exploitation stockage_boue 3","tbentrant degazage 2","CO2 exploitation stockage_boue 1","CO2 construction stockage_boue 1","CO2 construction stockage_boue 2","CO2 construction stockage_boue 3","CO2 exploitation stockage_boue 2","tbentrant digesteur_aerobie 1","CO2 elec 6","CH4 exploitation stockage_boue 2"}', 30, false, false, NULL, NULL, 20000, 'Silo de 500m3', NULL, NULL, 547.5, NULL, 'model2');
INSERT INTO api.stockage_boue_bloc (id, shape, geom, name, formula, formula_name, d_vie, grand, aere, dbo, welec, eh, festock, mes, dbo5, tbentrant, tbsortant_s,model) VALUES (17, 'Point', '01010000206A080000151111274D5024414C7EF189E91B5A41', 'stockage_boue_1', '{co2_e=fesilo_aere*tbentrant*aere,"tbentrant=0.0005*nbjour*(dbo5 + mes)","co2_e=0.0005*eh*fesilo_aere*nbjour*aere*(dbo5_eh + mes_eh)","co2_c=0.0005*eh*festock*nbjour*(dbo5_eh + mes_eh)","co2_c=0.0005*festock*nbjour*(dbo5 + mes)",co2_c=festock*tbentrant,"co2_e=0.0005*fesilo_aere*nbjour*aere*(dbo5 + mes)","tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)",co2_e=feelec*welec,"ch4_e=-dbo*(aere - 1)*(fesilo_grand*grand - fesilo_petit*(grand - 1))"}', '{"CO2 exploitation stockage_boue 3","tbentrant degazage 2","CO2 exploitation stockage_boue 1","CO2 construction stockage_boue 1","CO2 construction stockage_boue 2","CO2 construction stockage_boue 3","CO2 exploitation stockage_boue 2","tbentrant digesteur_aerobie 1","CO2 elec 6","CH4 exploitation stockage_boue 2"}', 30, false, false, NULL, NULL, 20000, 'Silo de 500m3', NULL, NULL, 547.5, NULL, 'model1');


--
-- Data for Name: sur_bloc_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: tables_degouttage_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: tamis_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: test_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: usine_bloc; Type: TABLE DATA; Schema: api; Owner: -
--

INSERT INTO api.usine_bloc (id, shape, geom, name, formula, formula_name, d_vie, eh, welec, qe, mes, dbo5,model) VALUES (3, 'Polygon', '01030000206A0800000100000008000000069D3656714F24411CE87485161C5A41373333EDD94F244197FCA2F2F51B5A4130F9C5F8F04F244178773751E91B5A41854E1B56984F2441073A2DB4D61B5A41743D0A798F4F24411F85AB85C81B5A41CA925FB2C55024413A6DE0ACE01B5A414F7EB1B250502441C058B27C221C5A41069D3656714F24411CE87485161C5A41', 'usine_3', '{co2_e=eh*fetraitement_e*nbjour*qe_eh,co2_c=fetraitement_c*nbjour*qe/d_vie,"tbentrant=0.0005*nbjour*(dbo5 + mes)",co2_e=fetraitement_e*nbjour*qe,co2_c=eh*fetraitement_c*nbjour*qe_eh/d_vie,"tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)",co2_e=feelec*welec}', '{"CO2 exploitation usine 1","CO2 construction usine 2","tbentrant degazage 2","CO2 exploitation usine 2","CO2 construction usine 1","tbentrant digesteur_aerobie 1","CO2 elec 6"}', 1, 20000, NULL, NULL, NULL, NULL, 'model1');
INSERT INTO api.usine_bloc (id, shape, geom, name, formula, formula_name, d_vie, eh, welec, qe, mes, dbo5,model) VALUES (25, 'Polygon', '01030000206A0800000100000008000000877E1376864F244155F5AF51161C5A4185F25C61DB4F2441EEF437BEEF1B5A41DDE444AAE34F2441BAC4EB29E61B5A411D7B4D88884F2441E6608D13D51B5A41F758913E9D4F2441CD78F793C61B5A41FE62DDB5CD502441D34FAF6EDF1B5A415E44EA02455024413F27DFDC1E1C5A41877E1376864F244155F5AF51161C5A41', 'usine_4', '{co2_e=eh*fetraitement_e*nbjour*qe_eh,co2_c=fetraitement_c*nbjour*qe/d_vie,"tbentrant=0.0005*nbjour*(dbo5 + mes)",co2_e=fetraitement_e*nbjour*qe,co2_c=eh*fetraitement_c*nbjour*qe_eh/d_vie,"tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)",co2_e=feelec*welec}', '{"CO2 exploitation usine 1","CO2 construction usine 2","tbentrant degazage 2","CO2 exploitation usine 2","CO2 construction usine 1","tbentrant digesteur_aerobie 1","CO2 elec 6"}', 1, 20000, NULL, NULL, NULL, NULL, 'model2');
INSERT INTO api.usine_bloc (id, shape, geom, name, formula, formula_name, d_vie, eh, welec, qe, mes, dbo5,model) VALUES (49, 'Polygon', '01030000206A0800000100000008000000647DCAAB724F24419F1AE111141C5A41DAF0B4EBE44F2441EA5F3BAAED1B5A4189812B3CBB4F244174CBE31EE11B5A41173DB232854F24416E4C9466CE1B5A416DF7D744994F2441EEAF192CC41B5A41B812E06FB85024411B88EA15E21B5A412F8FAFD14A5024416EF231A61F1C5A41647DCAAB724F24419F1AE111141C5A41', 'usine_5', '{co2_e=eh*fetraitement_e*nbjour*qe_eh,co2_c=fetraitement_c*nbjour*qe/d_vie,"tbentrant=0.0005*nbjour*(dbo5 + mes)",co2_e=fetraitement_e*nbjour*qe,co2_c=eh*fetraitement_c*nbjour*qe_eh/d_vie,"tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)",co2_e=feelec*welec}', '{"CO2 exploitation usine 1","CO2 construction usine 2","tbentrant degazage 2","CO2 exploitation usine 2","CO2 construction usine 1","tbentrant digesteur_aerobie 1","CO2 elec 6"}', 1, NULL, NULL, NULL, NULL, NULL, 'model3');


--
-- Data for Name: voirie_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Name: bloc_id_seq; Type: SEQUENCE SET; Schema: api; Owner: -
--



--
-- PostgreSQL database dump complete
--

