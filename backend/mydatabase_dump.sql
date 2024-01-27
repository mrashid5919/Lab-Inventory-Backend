--
-- PostgreSQL database dump
--

-- Dumped from database version 16.1
-- Dumped by pg_dump version 16.1

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
-- Name: update_storage(integer, integer, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_storage(equipmentid integer, locationid integer, quant numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE EQUIPMENTS_IN_LOCATIONS
  SET QUANTITY = QUANTITY+Quant
  WHERE EQUIPMENT_ID = EquipmentID AND LOCATION_ID = LocationID;
  UPDATE EQUIPMENTS
  SET AVAILABLE = AVAILABLE+Quant
  WHERE EQUIPMENT_ID = EquipmentID;
END;
$$;


ALTER FUNCTION public.update_storage(equipmentid integer, locationid integer, quant numeric) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: equipments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.equipments (
    equipment_id integer NOT NULL,
    equipment_name character varying(100) NOT NULL,
    type character varying(20) NOT NULL,
    cost numeric,
    descript character varying(1000) NOT NULL,
    borrowed integer,
    available integer,
    demand integer,
    permit integer
);


ALTER TABLE public.equipments OWNER TO postgres;

--
-- Name: equipments_equipment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.equipments_equipment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.equipments_equipment_id_seq OWNER TO postgres;

--
-- Name: equipments_equipment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.equipments_equipment_id_seq OWNED BY public.equipments.equipment_id;


--
-- Name: equipments_in_locations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.equipments_in_locations (
    equipment_id integer NOT NULL,
    location_id integer NOT NULL,
    quantity numeric,
    loan numeric
);


ALTER TABLE public.equipments_in_locations OWNER TO postgres;

--
-- Name: locations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.locations (
    location_id integer NOT NULL,
    location_name character varying(30),
    room_no numeric
);


ALTER TABLE public.locations OWNER TO postgres;

--
-- Name: locations_location_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.locations_location_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.locations_location_id_seq OWNER TO postgres;

--
-- Name: locations_location_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.locations_location_id_seq OWNED BY public.locations.location_id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    user_id integer NOT NULL,
    username character varying(100) NOT NULL,
    first_name character varying(50),
    last_name character varying(50),
    email character varying(50) NOT NULL,
    password character varying(100) NOT NULL,
    role character varying(32) NOT NULL,
    phone_no character varying(20) NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_in_locations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users_in_locations (
    user_id integer NOT NULL,
    location_id integer NOT NULL,
    role character varying(32)
);


ALTER TABLE public.users_in_locations OWNER TO postgres;

--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_user_id_seq OWNER TO postgres;

--
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;


--
-- Name: equipments equipment_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipments ALTER COLUMN equipment_id SET DEFAULT nextval('public.equipments_equipment_id_seq'::regclass);


--
-- Name: locations location_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.locations ALTER COLUMN location_id SET DEFAULT nextval('public.locations_location_id_seq'::regclass);


--
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


--
-- Data for Name: equipments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.equipments (equipment_id, equipment_name, type, cost, descript, borrowed, available, demand, permit) FROM stdin;
2	Arduino	Hardware	100	Microcontroller	2	15	2	2
3	AtMega32	Hardware	500	Microcontroller device	0	10	1	1
1	Breadboard	Hardware	90	Circuit building equipment	10	42	3	1
\.


--
-- Data for Name: equipments_in_locations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.equipments_in_locations (equipment_id, location_id, quantity, loan) FROM stdin;
1	1	17	2
\.


--
-- Data for Name: locations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.locations (location_id, location_name, room_no) FROM stdin;
1	Inventory1	101
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (user_id, username, first_name, last_name, email, password, role, phone_no) FROM stdin;
1	1905091	Sadia	Tabassum	1905091@ugrad.cse.buet.ac.bd	$2b$10$ZZfW8Mk4rY2cWaDcpnMpWuaWCdba9rSprUdBdHGlI4o30.Ayh0LK.	Student	0170000000
2	1905099	Aline	Zaman	1905099@ugrad.cse.buet.ac.bd	$2b$10$I5sYZ1cNt6.AnQMy3meQtuXnat.HzsrhsqAaBK74yOuNAbjP1wEOG	Student	01803200049
3	19050103	Mayesha	Rashid	1905103@ugrad.cse.buet.ac.bd	$2b$10$jZAmLfmRfAJjT8Ep.YSSXuI0GQful/CmviiG24il.HL84oO3d5Cze	Student	0129037502
4	abul	Abul	Kalam	abul@gmail.com	$2b$10$cCZ/WBvs6salEe/3y4/Cg.eqPixoBRsQAtrH4QtyLuAz6rL4QS3zi	inventory manager	293733373
5	mdalam	Alam	Islam	mdalam@gmail.com	$2b$10$m0azq/g3avWavEnOfy3IoO9IfUrY8Cyy2Dqp/slFYrUSmu6WSmSSC	inventory manager	0189459013
\.


--
-- Data for Name: users_in_locations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users_in_locations (user_id, location_id, role) FROM stdin;
4	1	inventory manager
\.


--
-- Name: equipments_equipment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.equipments_equipment_id_seq', 3, true);


--
-- Name: locations_location_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.locations_location_id_seq', 1, false);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_user_id_seq', 5, true);


--
-- Name: equipments_in_locations equipments_in_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipments_in_locations
    ADD CONSTRAINT equipments_in_locations_pkey PRIMARY KEY (equipment_id, location_id);


--
-- Name: equipments equipments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipments
    ADD CONSTRAINT equipments_pkey PRIMARY KEY (equipment_id);


--
-- Name: locations locations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (location_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users_in_locations users_in_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_in_locations
    ADD CONSTRAINT users_in_locations_pkey PRIMARY KEY (user_id, location_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: equipments_in_locations equipments_in_locations_equipment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipments_in_locations
    ADD CONSTRAINT equipments_in_locations_equipment_id_fkey FOREIGN KEY (equipment_id) REFERENCES public.equipments(equipment_id);


--
-- Name: equipments_in_locations equipments_in_locations_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipments_in_locations
    ADD CONSTRAINT equipments_in_locations_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(location_id);


--
-- Name: users_in_locations users_in_locations_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_in_locations
    ADD CONSTRAINT users_in_locations_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(location_id);


--
-- Name: users_in_locations users_in_locations_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_in_locations
    ADD CONSTRAINT users_in_locations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id);


--
-- PostgreSQL database dump complete
--

