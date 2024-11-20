INSERT INTO api.model (name, creation_date, comment) VALUES ('bonjour', '2024-11-20 00:00:00', NULL);
--
-- PostgreSQL database dump
--

CREATE EXTENSION postgis;

-- Dumped from database version 13.3
-- Dumped by pg_dump version 16.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

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



--
-- Data for Name: deconstruction_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: degazage_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: degrilleur_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: dessableurdegraisseur_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Data for Name: digesteur__methaniseur_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



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



--
-- Data for Name: filiere_eau_bloc; Type: TABLE DATA; Schema: api; Owner: -
--

INSERT INTO api.filiere_eau_bloc (id, shape, geom, name, formula, formula_name, prod_e, d_vie, abatdco, eh, abatngl, w_dbo5_eau, dbo5elim, q_sable_t, transp_anti_mousse, q_sulf_sod, transp_cl2, q_citrique, transp_ca_regen, q_caco3, q_mhetanol, transp_ca_neuf, q_phosphorique, transp_mhetanol, q_uree, q_sulf_alu, transp_antiscalant, transp_poly, transp_sulf, transp_catio, transp_caco3, transp_nahso3, transp_soude_c, q_anio, transp_kmno4, q_poly, transp_oxyl, transp_anio, transp_naclo3, q_soude_c, q_anti_mousse, q_nahso3, q_hcl, transp_citrique, transp_rei, transp_ethanol, q_ethanol, transp_soude, q_rei, transp_sulf_sod, q_naclo3, q_nitrique, q_ca_poudre, q_ca_regen, transp_h2o2, q_kmno4, transp_sulf_alu, transp_uree, q_catio, q_chaux, q_oxyl, transp_nitrique, transp_ca_poudre, transp_hcl, transp_chaux, q_h2o2, q_soude, q_ca_neuf, transp_phosphorique, transp_sable_t, q_antiscalant, q_cl2, q_sulf, dco, ntk, mes, dbo5, welec, ngl_s, dco_s, qe_s,model) VALUES (33, 'Polygon', '01030000206A08000001000000050000001D16FC74FF273BC19599A640E8E43141A9FE63C4D4813BC17E395A97D1532341545123AA2AF532C1153B71DB26592441D3816A4FD54633C1FB59AC913D2632411D16FC74FF273BC19599A640E8E43141', 'filiere_eau_2', '{"dco_s=eh*dco_eh*(1 - abatdco)","co2_e=0.001*q_anio*(fetransp*transp_anio + 1000*fe_anio) + 0.001*q_anti_mousse*(fetransp*transp_anti_mousse + 1000*fe_anti_mousse) + 0.001*q_antiscalant*(fetransp*transp_antiscalant + 1000*fe_antiscalant) + 0.001*q_ca_neuf*(fetransp*transp_ca_neuf + 1000*fe_ca_neuf) + 0.001*q_ca_poudre*(fetransp*transp_ca_poudre + 1000*fe_ca_poudre) + 0.001*q_ca_regen*(fetransp*transp_ca_regen + 1000*fe_ca_regen) + 0.001*q_caco3*(fetransp*transp_caco3 + 1000*fe_caco3) + 0.001*q_catio*(fetransp*transp_catio + 1000*fe_catio) + 0.001*q_chaux*(fetransp*transp_chaux + 1000*fe_chaux) + 0.001*q_citrique*(fetransp*transp_citrique + 1000*fe_citrique) + 0.001*q_cl2*(fetransp*transp_cl2 + 1000*fe_cl2) + 0.001*q_ethanol*(fetransp*transp_ethanol + 1000*fe_ethanol) + 0.001*q_h2o2*(fetransp*transp_h2o2 + 1000*fe_h2o2) + 0.001*q_hcl*(fetransp*transp_hcl + 1000*fe_hcl) + 0.001*q_kmno4*(fetransp*transp_kmno4 + 1000*fe_kmno4) + 0.001*q_mhetanol*(fetransp*transp_mhetanol + 1000*fe_mhetanol) + 0.001*q_naclo3*(fetransp*transp_naclo3 + 1000*fe_naclo3) + 0.001*q_nahso3*(fetransp*transp_nahso3 + 1000*fe_nahso3) + 0.001*q_nitrique*(fetransp*transp_nitrique + 1000*fe_nitrique) + 0.001*q_oxyl*(fetransp*transp_oxyl + 1000*fe_oxyl) + 0.001*q_phosphorique*(fetransp*transp_phosphorique + 1000*fe_phosphorique) + 0.001*q_poly*(fetransp*transp_poly + 1000*fe_poly) + 0.001*q_rei*(fetransp*transp_rei + 1000*fe_rei) + 0.001*q_sable_t*(fetransp*transp_sable_t + 1000*fe_sable_t) + 0.001*q_soude*(fetransp*transp_soude + 1000*fe_soude) + 0.001*q_soude_c*(fetransp*transp_soude_c + 1000*fe_soude_c) + 0.001*q_sulf*(fetransp*transp_sulf + 1000*fe_sulf) + 0.001*q_sulf_alu*(fetransp*transp_sulf_alu + 1000*fe_sulf_alu) + 0.001*q_sulf_sod*(fetransp*transp_sulf_sod + 1000*fe_sulf_sod) + 0.001*q_uree*(fetransp*transp_uree + 1000*fe_uree)","tbentrant=0.0005*nbjour*(dbo5 + mes)","ngl_s=eh*ntk_eh*(1 - abatngl)","dco_s=dco*(1 - abatdco)",co2_e=feelec*dbo5elim*w_dbo5_eau,"tbentrant=0.0005*eh*nbjour*(dbo5_eh + mes_eh)",co2_e=feelec*welec,"ngl_s=ntk*(1 - abatngl)"}', '{"dco_s fpr 3","CO2 exploitation intrant dessableurdegraisseur 6","tbentrant degazage 2","ngl_s bassin_biologique 3","dco_s fpr 3","CO2 exploitation clarificateur 3","tbentrant digesteur_aerobie 1","CO2 elec 6","ngl_s bassin_biologique 3"}', 'Soude', 50, NULL, NULL, NULL, 5, NULL, NULL, 50, NULL, 50, NULL, 50, NULL, NULL, 50, NULL, 50, NULL, NULL, 50, 50, 50, 50, 50, 50, 50, NULL, 50, NULL, 50, 50, 50, NULL, NULL, NULL, NULL, 50, 50, 50, NULL, 50, NULL, 50, NULL, NULL, NULL, NULL, 50, NULL, 50, 50, NULL, NULL, NULL, 50, 50, 50, 50, NULL, NULL, NULL, 50, 50, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'bonjour');


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

INSERT INTO api.rejets_bloc (id, shape, geom, name, formula, formula_name, abatdco, fech4_mil, eh, abatngl, fen2o_oxi, dco, ngl,model) VALUES (34, 'Point', '01010000206A0800008E2EA4D8000729C16AE8B1F5D0E52C41', 'rejets_2', '{ch4_e=dco*fech4_mil,"ch4_e=eh*fech4_mil*dco_eh*(1 - abatdco)",n2o_e=fen2o_oxi*ngl,"n2o_e=eh*fen2o_oxi*ntk_eh*(1 - abatngl)"}', '{"CH4 exploitation rejets 2","CH4 exploitation rejets 1","N2O exploitation rejets 2","N2O exploitation rejets 1"}', 0.75, 'Réservoirs, lac, estuaires', NULL, 0.8, 'Peu oxygéné', NULL, NULL, 'bonjour');


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



--
-- Data for Name: voirie_bloc; Type: TABLE DATA; Schema: api; Owner: -
--



--
-- Name: bloc_id_seq; Type: SEQUENCE SET; Schema: api; Owner: -
--

SELECT pg_catalog.setval('api.bloc_id_seq', 34, true);


--
-- PostgreSQL database dump complete
--

