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
    permit integer,
    image_link text
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
-- Name: due_statuses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.due_statuses (
    due_status integer NOT NULL,
    status_name character varying(100) NOT NULL
);


ALTER TABLE public.due_statuses OWNER TO postgres;

--
-- Name: due_statuses_due_status_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.due_statuses_due_status_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.due_statuses_due_status_seq OWNER TO postgres;

--
-- Name: due_statuses_due_status_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.due_statuses_due_status_seq OWNED BY public.due_statuses.due_status;


--
-- Name: dues; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dues (
    due_id integer NOT NULL,
    req_id integer,
    alloter_id integer,
    receiver_id integer,
    due_status integer,
    due_date date,
    issue_date date
);


ALTER TABLE public.dues OWNER TO postgres;

--
-- Name: dues_due_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dues_due_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dues_due_id_seq OWNER TO postgres;

--
-- Name: dues_due_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dues_due_id_seq OWNED BY public.dues.due_id;


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
    borrowed integer
);


ALTER TABLE public.equipments_in_locations OWNER TO postgres;

--
-- Name: location_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.location_types (
    location_type_id integer NOT NULL,
    location_type_name character varying(100) NOT NULL
);


ALTER TABLE public.location_types OWNER TO postgres;

--
-- Name: location_types_location_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.location_types_location_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.location_types_location_type_id_seq OWNER TO postgres;

--
-- Name: location_types_location_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.location_types_location_type_id_seq OWNED BY public.location_types.location_type_id;


--
-- Name: locations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.locations (
    location_id integer NOT NULL,
    location_name character varying(30),
    room_no numeric,
    location_type integer
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
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    notification_id integer NOT NULL,
    receiver_id integer,
    sender_name text,
    sender_role text,
    notification text,
    notification_time date
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- Name: notifications_notification_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notifications_notification_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notifications_notification_id_seq OWNER TO postgres;

--
-- Name: notifications_notification_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notifications_notification_id_seq OWNED BY public.notifications.notification_id;


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
    lab_supervisor integer,
    inventory_manager integer,
    due_assigned integer,
    pickup_date date
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
    phone_no character varying(20) NOT NULL,
    assigned integer DEFAULT 0
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
-- Name: viewed_notification; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.viewed_notification (
    user_id integer,
    viewed_notification_count integer DEFAULT 0,
    total_notification_count integer DEFAULT 0
);


ALTER TABLE public.viewed_notification OWNER TO postgres;

--
-- Name: due_statuses due_status; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.due_statuses ALTER COLUMN due_status SET DEFAULT nextval('public.due_statuses_due_status_seq'::regclass);


--
-- Name: dues due_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dues ALTER COLUMN due_id SET DEFAULT nextval('public.dues_due_id_seq'::regclass);


--
-- Name: equipments equipment_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipments ALTER COLUMN equipment_id SET DEFAULT nextval('public.equipments_equipment_id_seq'::regclass);


--
-- Name: location_types location_type_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.location_types ALTER COLUMN location_type_id SET DEFAULT nextval('public.location_types_location_type_id_seq'::regclass);


--
-- Name: locations location_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.locations ALTER COLUMN location_id SET DEFAULT nextval('public.locations_location_id_seq'::regclass);


--
-- Name: notifications notification_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications ALTER COLUMN notification_id SET DEFAULT nextval('public.notifications_notification_id_seq'::regclass);


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
-- Data for Name: due_statuses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.due_statuses (due_status, status_name) FROM stdin;
1	Pending
\.


--
-- Data for Name: dues; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dues (due_id, req_id, alloter_id, receiver_id, due_status, due_date, issue_date) FROM stdin;
2	34	7	\N	1	2024-02-21	2024-02-19
\.


--
-- Data for Name: equipments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.equipments (equipment_id, equipment_name, type, cost, descript, borrowed, available, demand, permit, image_link) FROM stdin;
5	LED	Hardware	5	Light	2	448	1	1	https://www.robotechbd.com/wp-content/uploads/2021/07/frosted-leds-red-green-blue-yellow-white-800x800-1.jpg
6	Iphone	Software	50000	iphone	3	77	1	3	https://www.91-img.com/gallery_images_uploads/3/d/3df5ca6a9b470f715b085991144a5b76e70da975.JPG?tr=h-550,w-0,c-at_max
2	Arduino	Hardware	100	Microcontroller	10	140	2	2	https://t4.ftcdn.net/jpg/03/33/90/55/240_F_333905577_NJ7hf7ekOjzPDA5yGDAAvlLyJdEwgFyt.jpg
1	Breadboard	Hardware	90	Circuit building equipment	7	145	3	1	https://cdn.sparkfun.com/assets/learn_tutorials/4/7/12615-02_Full_Size_Breadboard_Split_Power_Rails.jpg
4	AtMega32	Hardware	500	Microcontroller device	14	96	1	2	https://upload.wikimedia.org/wikipedia/commons/f/f0/ATmega32_microcontroller.jpg?20090626195729
\.


--
-- Data for Name: equipments_in_locations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.equipments_in_locations (equipment_id, location_id, available, borrowed) FROM stdin;
2	1	100	0
1	1	52	0
2	2	40	10
1	2	93	7
5	1	345	0
5	2	103	2
4	2	36	14
6	1	65	0
6	2	12	3
4	1	60	0
\.


--
-- Data for Name: location_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.location_types (location_type_id, location_type_name) FROM stdin;
1	Inventory
2	Lab
\.


--
-- Data for Name: locations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.locations (location_id, location_name, room_no, location_type) FROM stdin;
1	Inventory1	101	1
2	Lab1	102	2
3	Lab2	103	2
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notifications (notification_id, receiver_id, sender_name, sender_role, notification, notification_time) FROM stdin;
\.


--
-- Data for Name: request_comments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.request_comments (req_comment_id, req_id, commenter_id, comment, comment_time) FROM stdin;
3	26	7	accepted\n	2024-02-12
4	31	8	Accepted	2024-02-12
5	34	7	accepted	2024-02-12
6	36	8		2024-02-12
7	37	18	Accepted	2024-02-12
8	38	7	accept	2024-02-12
9	41	8	Accepted	2024-02-12
\.


--
-- Data for Name: request_status; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.request_status (req_status, status_name) FROM stdin;
1	Waiting for Lab Assistant approval
2	Accepted
3	Rejected
4	Waiting for Supervisor approval
5	Waiting for Head of Department approval
6	Waiting for inventory manager approval
\.


--
-- Data for Name: request_supervisors; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.request_supervisors (req_id, supervisor_id) FROM stdin;
28	8
28	9
32	8
31	8
35	8
36	8
37	8
37	18
41	8
\.


--
-- Data for Name: requests; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.requests (req_id, user_id, location_id, equipment_id, quantity, req_time, req_status, verdictor, lab_assistant, lab_supervisor, inventory_manager, due_assigned, pickup_date) FROM stdin;
26	11	2	1	5	2024-02-12	2	7	7	\N	\N	\N	\N
27	7	1	2	50	2024-02-12	2	4	\N	\N	4	\N	\N
28	11	2	2	2	2024-02-12	3	8	7	8	\N	\N	\N
30	7	1	6	10	2024-02-12	2	4	\N	\N	4	\N	\N
29	7	1	4	50	2024-02-12	2	4	\N	\N	4	\N	\N
31	11	2	4	2	2024-02-12	2	8	7	8	\N	\N	\N
32	11	2	6	1	2024-02-12	5	\N	7	8	\N	\N	\N
33	7	1	5	5	2024-02-12	2	4	\N	\N	4	\N	\N
34	1	2	5	2	2024-02-12	2	7	7	\N	\N	\N	\N
35	1	2	6	2	2024-02-12	5	\N	7	8	\N	\N	\N
36	1	2	4	5	2024-02-12	2	8	7	8	\N	\N	\N
37	1	2	2	10	2024-02-12	2	18	7	18	\N	\N	\N
38	11	2	1	2	2024-02-12	2	7	7	\N	\N	\N	\N
39	7	1	5	100	2024-02-12	2	4	\N	\N	4	\N	\N
40	7	1	5	10	2024-02-12	6	\N	\N	\N	\N	\N	\N
25	7	1	1	100	2024-02-12	2	4	\N	\N	4	\N	\N
41	1	2	4	7	2024-02-12	2	8	7	8	\N	\N	\N
42	7	1	6	5	2024-02-12	2	4	\N	\N	4	\N	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (user_id, username, first_name, last_name, email, password, role, phone_no, assigned) FROM stdin;
1	1905091	Sadia	Tabassum	1905091@ugrad.cse.buet.ac.bd	$2b$10$ZZfW8Mk4rY2cWaDcpnMpWuaWCdba9rSprUdBdHGlI4o30.Ayh0LK.	Student	0170000000	1
2	1905099	Aline	Zaman	1905099@ugrad.cse.buet.ac.bd	$2b$10$I5sYZ1cNt6.AnQMy3meQtuXnat.HzsrhsqAaBK74yOuNAbjP1wEOG	Student	01803200049	1
4	abul	Abul	Kalam	abul@gmail.com	$2b$10$cCZ/WBvs6salEe/3y4/Cg.eqPixoBRsQAtrH4QtyLuAz6rL4QS3zi	Inventory Manager	293733373	1
5	mdalam	Alam	Islam	mdalam@gmail.com	$2b$10$m0azq/g3avWavEnOfy3IoO9IfUrY8Cyy2Dqp/slFYrUSmu6WSmSSC	Inventory Manager	0189459013	1
7	raju	Raju	Ahmed	raju@gmail.com	$2b$10$cUGWmfwgrbLzJs66FZHBZuzIjhEdhN41lwm1lOaBLJqKjGLo1LxvO	Lab Assistant	420957489	1
8	tareqmahmood	Tareq	Mahmood	tm@gmail.com	$2b$10$ZsXuM3BA2A71SBUe5OLZsOfuWwnIcDX7x.uV8edAJwqV/cj2706YS	Teacher	2978542095	1
9	mmm	Masum	Mushfiq	mmm@gmail.com	$2b$10$fmpBISGxEIhWIHSuAfJAye9Zr9QtfdSH99vXJ2IeB0iKZfy18wB42	Teacher	29845709475	1
10	arif	Arif	Haque	arif@gmail.com	$2b$10$IbIfx4OajIUmp9/QgNEYuePPTcLjpnU3B43dlSfGBXXoN00otF9Vu	Lab Assistant	62491087524	1
11	1905103	Mayesha	Rashid	mayesha1599@gmail.com	$2b$10$I274TLSaz6H5tSjkHZW6xeBlcfDXf/yRzY6Ga9aciWYStebs20lBG	Student	48795249	1
12	rimpi	Rimpi	Reyaz	rimpi@gmail.com	$2b$10$Rz//YNIuylh9OqXL.A.WL.tN27cXIE2zbAEtLu4P76Ko2Xun1trw6	Teacher	5268289562	1
13	krv	Kowsic	Roy	kowshic@gmail.com	$2b$10$STEJA6pxC040lp07TIi4RuXoYefwig07OiZnPJdPY2FJ9cHpo/Seq	Teacher	7285250	1
14	nazmul	Nazmul	Hasan	nazmul@gmail.com	$2b$10$xasXMjPqF2LSlOSxO1mckODM3TQDeUQl6WJ2haTVvPmgRAXLGK7Oa	Super Admin	27962906852	1
15	mmn	Mahmuda	Naznin	mmn@gmail.com	$2b$10$PH1lV/ciXVYgRrCbTHiKYumgcj4mPI8HYdU7py6h9Y54mEs1EBzAO	Deparment Head	52095720	1
16	minu	Minu	Islam	minu@gmail.com	$2b$10$jUPLHVSaAFfMVTXlaVmM5uiY5kNFt7AoGtJZ4/TbN9Kzx3vSZojui	Lab Assistant	341234324	1
17	samia	Samia	Noor	samia@gmail.com	$2b$10$eXqLqLfDoRyLAhfq1hljWuOJP6pBdu.EK7ss5Ros6CNbdRepqR1bO	Lab Assistant	5282578025	1
18	rrd	Rayhan	Rashed	rayhan@gmail.com	$2b$10$hvNjP2uwuiGm72zPqvz6o.EMbbSz8bdkHN.3fPn.IF5Skql.C8rpy	Teacher	5632465437	1
19	asif	Asif	Haque	asif@gmail.com	$2b$10$ICJhsByjceWjHtjB/K2f4uwKELmVRS0aqGlMNTomgOZpanNnzA0vu	Lab Assistant	528780587	1
\.


--
-- Data for Name: users_in_locations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users_in_locations (user_id, location_id, role) FROM stdin;
7	2	Lab Assistant
8	2	Teacher
9	2	Teacher
12	3	Teacher
13	3	Teacher
16	2	Lab Assistant
10	2	Lab Assistant
4	1	inventory manager
17	2	Lab Assistant
19	3	Lab Assistant
18	3	Teacher
\.


--
-- Data for Name: viewed_notification; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.viewed_notification (user_id, viewed_notification_count, total_notification_count) FROM stdin;
\.


--
-- Name: due_statuses_due_status_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.due_statuses_due_status_seq', 1, true);


--
-- Name: dues_due_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dues_due_id_seq', 2, true);


--
-- Name: equipments_equipment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.equipments_equipment_id_seq', 7, true);


--
-- Name: location_types_location_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.location_types_location_type_id_seq', 2, true);


--
-- Name: locations_location_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.locations_location_id_seq', 3, true);


--
-- Name: notifications_notification_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.notifications_notification_id_seq', 1, false);


--
-- Name: request_comments_req_comment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.request_comments_req_comment_id_seq', 9, true);


--
-- Name: request_status_req_status_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.request_status_req_status_seq', 6, true);


--
-- Name: requests_req_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.requests_req_id_seq', 42, true);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_user_id_seq', 19, true);


--
-- Name: due_statuses due_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.due_statuses
    ADD CONSTRAINT due_statuses_pkey PRIMARY KEY (due_status);


--
-- Name: dues dues_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dues
    ADD CONSTRAINT dues_pkey PRIMARY KEY (due_id);


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
-- Name: location_types location_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.location_types
    ADD CONSTRAINT location_types_pkey PRIMARY KEY (location_type_id);


--
-- Name: locations locations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (location_id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (notification_id);


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
-- Name: dues dues_alloter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dues
    ADD CONSTRAINT dues_alloter_id_fkey FOREIGN KEY (alloter_id) REFERENCES public.users(user_id);


--
-- Name: dues dues_due_status_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dues
    ADD CONSTRAINT dues_due_status_fkey FOREIGN KEY (due_status) REFERENCES public.due_statuses(due_status);


--
-- Name: dues dues_req_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dues
    ADD CONSTRAINT dues_req_id_fkey FOREIGN KEY (req_id) REFERENCES public.requests(req_id);


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
-- Name: notifications notifications_receiver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_receiver_id_fkey FOREIGN KEY (receiver_id) REFERENCES public.users(user_id);


--
-- Name: notifications notifications_sender_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_sender_name_fkey FOREIGN KEY (sender_name) REFERENCES public.users(username);


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
-- Name: viewed_notification viewed_notification_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.viewed_notification
    ADD CONSTRAINT viewed_notification_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id);


--
-- PostgreSQL database dump complete
--

