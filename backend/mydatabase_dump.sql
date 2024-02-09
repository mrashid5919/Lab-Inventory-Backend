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
-- Name: update_storage(integer, integer, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_storage(p_equipment_id integer, p_location_id integer, p_quantity numeric) RETURNS public.equipments
    LANGUAGE plpgsql
    AS $$
DECLARE
    updated_equipment_row EQUIPMENTS;
BEGIN
    -- Update quantity in EQUIPMENTS_IN_LOCATIONS
    UPDATE EQUIPMENTS_IN_LOCATIONS
    SET QUANTITY = QUANTITY + p_quantity
    WHERE EQUIPMENT_ID = p_equipment_id AND LOCATION_ID = p_location_id;

    -- Update available quantity in EQUIPMENTS and capture the updated row
    UPDATE EQUIPMENTS
    SET AVAILABLE = AVAILABLE + p_quantity
    WHERE EQUIPMENT_ID = p_equipment_id
    RETURNING * INTO updated_equipment_row;

    -- Return the updated equipment row
    RETURN updated_equipment_row;
END;
$$;


ALTER FUNCTION public.update_storage(p_equipment_id integer, p_location_id integer, p_quantity numeric) OWNER TO postgres;

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
    available integer,
    borrowed numeric
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
-- Name: request_comments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.request_comments (
    req_comment_id integer NOT NULL,
    req_id integer,
    commenter_id integer,
    comment text,
    comment_time date
);


ALTER TABLE public.request_comments OWNER TO postgres;

--
-- Name: request_comments_req_comment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.request_comments_req_comment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.request_comments_req_comment_id_seq OWNER TO postgres;

--
-- Name: request_comments_req_comment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.request_comments_req_comment_id_seq OWNED BY public.request_comments.req_comment_id;


--
-- Name: request_status; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.request_status (
    req_status integer NOT NULL,
    status_name character varying(100) NOT NULL
);


ALTER TABLE public.request_status OWNER TO postgres;

--
-- Name: request_status_req_status_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.request_status_req_status_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.request_status_req_status_seq OWNER TO postgres;

--
-- Name: request_status_req_status_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.request_status_req_status_seq OWNED BY public.request_status.req_status;


--
-- Name: request_supervisors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.request_supervisors (
    req_id integer,
    supervisor_id integer
);


ALTER TABLE public.request_supervisors OWNER TO postgres;

--
-- Name: requests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.requests (
    req_id integer NOT NULL,
    user_id integer,
    location_id integer,
    equipment_id integer,
    quantity integer,
    req_time date,
    req_status integer,
    verdictor integer,
    lab_assistant integer,
    lab_supervisor integer
);


ALTER TABLE public.requests OWNER TO postgres;

--
-- Name: requests_req_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.requests_req_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.requests_req_id_seq OWNER TO postgres;

--
-- Name: requests_req_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.requests_req_id_seq OWNED BY public.requests.req_id;


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
-- Name: request_comments req_comment_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.request_comments ALTER COLUMN req_comment_id SET DEFAULT nextval('public.request_comments_req_comment_id_seq'::regclass);


--
-- Name: request_status req_status; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.request_status ALTER COLUMN req_status SET DEFAULT nextval('public.request_status_req_status_seq'::regclass);


--
-- Name: requests req_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.requests ALTER COLUMN req_id SET DEFAULT nextval('public.requests_req_id_seq'::regclass);


--
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


--
-- Data for Name: equipments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.equipments (equipment_id, equipment_name, type, cost, descript, borrowed, available, demand, permit) FROM stdin;
2	Arduino	Hardware	100	Microcontroller	2	15	2	2
4	AtMega32	Hardware	500	Microcontroller device	0	10	1	1
5	LED	Hardware	5	Light	0	50	1	1
1	Breadboard	Hardware	90	Circuit building equipment	20	112	3	1
\.


--
-- Data for Name: equipments_in_locations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.equipments_in_locations (equipment_id, location_id, available, borrowed) FROM stdin;
4	1	10	0
5	1	50	0
1	1	27	210
1	2	22	2105
\.


--
-- Data for Name: locations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.locations (location_id, location_name, room_no) FROM stdin;
1	Inventory1	101
2	Lab1	102
\.


--
-- Data for Name: request_comments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.request_comments (req_comment_id, req_id, commenter_id, comment, comment_time) FROM stdin;
1	2	7	Sorry some our product was damaged	2024-02-08
\.


--
-- Data for Name: request_status; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.request_status (req_status, status_name) FROM stdin;
1	Waiting for Lab Assistant approval
2	Accepted
3	Rejected
4	Waiting for Supervisor approval
\.


--
-- Data for Name: request_supervisors; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.request_supervisors (req_id, supervisor_id) FROM stdin;
2	7
3	7
3	8
\.


--
-- Data for Name: requests; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.requests (req_id, user_id, location_id, equipment_id, quantity, req_time, req_status, verdictor, lab_assistant, lab_supervisor) FROM stdin;
2	1	2	1	10	2024-02-08	4	7	7	\N
3	1	2	1	5	2024-02-09	4	\N	7	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (user_id, username, first_name, last_name, email, password, role, phone_no) FROM stdin;
1	1905091	Sadia	Tabassum	1905091@ugrad.cse.buet.ac.bd	$2b$10$ZZfW8Mk4rY2cWaDcpnMpWuaWCdba9rSprUdBdHGlI4o30.Ayh0LK.	Student	0170000000
2	1905099	Aline	Zaman	1905099@ugrad.cse.buet.ac.bd	$2b$10$I5sYZ1cNt6.AnQMy3meQtuXnat.HzsrhsqAaBK74yOuNAbjP1wEOG	Student	01803200049
3	19050103	Mayesha	Rashid	1905103@ugrad.cse.buet.ac.bd	$2b$10$jZAmLfmRfAJjT8Ep.YSSXuI0GQful/CmviiG24il.HL84oO3d5Cze	Student	0129037502
4	abul	Abul	Kalam	abul@gmail.com	$2b$10$cCZ/WBvs6salEe/3y4/Cg.eqPixoBRsQAtrH4QtyLuAz6rL4QS3zi	Inventory Manager	293733373
5	mdalam	Alam	Islam	mdalam@gmail.com	$2b$10$m0azq/g3avWavEnOfy3IoO9IfUrY8Cyy2Dqp/slFYrUSmu6WSmSSC	Inventory Manager	0189459013
7	raju	Raju	Ahmed	raju@gmail.com	$2b$10$cUGWmfwgrbLzJs66FZHBZuzIjhEdhN41lwm1lOaBLJqKjGLo1LxvO	Lab Assistant	420957489
8	tareqmahmood	Tareq	Mahmood	tm@gmail.com	$2b$10$ZsXuM3BA2A71SBUe5OLZsOfuWwnIcDX7x.uV8edAJwqV/cj2706YS	Teacher	2978542095
9	mmm	Masum	Mushfiq	mmm@gmail.com	$2b$10$fmpBISGxEIhWIHSuAfJAye9Zr9QtfdSH99vXJ2IeB0iKZfy18wB42	Teacher	29845709475
\.


--
-- Data for Name: users_in_locations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users_in_locations (user_id, location_id, role) FROM stdin;
4	1	inventory manager
7	2	Lab Assistant
8	2	Teacher
9	2	Teacher
\.


--
-- Name: equipments_equipment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.equipments_equipment_id_seq', 5, true);


--
-- Name: locations_location_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.locations_location_id_seq', 2, true);


--
-- Name: request_comments_req_comment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.request_comments_req_comment_id_seq', 1, true);


--
-- Name: request_status_req_status_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.request_status_req_status_seq', 4, true);


--
-- Name: requests_req_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.requests_req_id_seq', 3, true);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_user_id_seq', 9, true);


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
-- Name: request_comments request_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.request_comments
    ADD CONSTRAINT request_comments_pkey PRIMARY KEY (req_comment_id);


--
-- Name: request_status request_status_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.request_status
    ADD CONSTRAINT request_status_pkey PRIMARY KEY (req_status);


--
-- Name: requests requests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.requests
    ADD CONSTRAINT requests_pkey PRIMARY KEY (req_id);


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
-- Name: request_comments request_comments_commenter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.request_comments
    ADD CONSTRAINT request_comments_commenter_id_fkey FOREIGN KEY (commenter_id) REFERENCES public.users(user_id);


--
-- Name: request_comments request_comments_req_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.request_comments
    ADD CONSTRAINT request_comments_req_id_fkey FOREIGN KEY (req_id) REFERENCES public.requests(req_id);


--
-- Name: request_supervisors request_supervisors_req_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.request_supervisors
    ADD CONSTRAINT request_supervisors_req_id_fkey FOREIGN KEY (req_id) REFERENCES public.requests(req_id);


--
-- Name: request_supervisors request_supervisors_supervisor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.request_supervisors
    ADD CONSTRAINT request_supervisors_supervisor_id_fkey FOREIGN KEY (supervisor_id) REFERENCES public.users(user_id);


--
-- Name: requests requests_equipment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.requests
    ADD CONSTRAINT requests_equipment_id_fkey FOREIGN KEY (equipment_id) REFERENCES public.equipments(equipment_id);


--
-- Name: requests requests_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.requests
    ADD CONSTRAINT requests_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(location_id);


--
-- Name: requests requests_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.requests
    ADD CONSTRAINT requests_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id);


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

