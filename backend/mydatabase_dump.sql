--
-- PostgreSQL database dump
--

-- Dumped from database version 16.2 (Ubuntu 16.2-1.pgdg22.04+1)
-- Dumped by pg_dump version 16.2 (Ubuntu 16.2-1.pgdg22.04+1)

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
-- Name: update_notification_count(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_notification_count() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE viewed_notification
    SET total_notification_count = total_notification_count + 1
    WHERE user_id = NEW.receiver_id; -- Use receiver_id from the new row in notification table

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_notification_count() OWNER TO postgres;

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
-- Name: clearance_request; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clearance_request (
    clearance_req_id integer NOT NULL,
    user_id integer,
    level integer,
    term integer,
    clearance_status integer,
    request_date date,
    forward_date date,
    verdict_date date,
    verdictor integer
);


ALTER TABLE public.clearance_request OWNER TO postgres;

--
-- Name: clearance_request_clearace_req_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.clearance_request_clearace_req_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.clearance_request_clearace_req_id_seq OWNER TO postgres;

--
-- Name: clearance_request_clearace_req_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.clearance_request_clearace_req_id_seq OWNED BY public.clearance_request.clearance_req_id;


--
-- Name: clearance_request_status; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clearance_request_status (
    clearance_status integer NOT NULL,
    status_name character varying(100) NOT NULL
);


ALTER TABLE public.clearance_request_status OWNER TO postgres;

--
-- Name: clearance_request_status_clearance_status_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.clearance_request_status_clearance_status_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.clearance_request_status_clearance_status_seq OWNER TO postgres;

--
-- Name: clearance_request_status_clearance_status_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.clearance_request_status_clearance_status_seq OWNED BY public.clearance_request_status.clearance_status;


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
    issue_date date,
    clear_date date,
    quantity integer,
    damage_quantity integer,
    monetary_assigned integer
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
-- Name: monetary_dues; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.monetary_dues (
    monetary_due_id integer NOT NULL,
    req_id integer,
    user_id integer,
    creater_id integer,
    receiver_id integer,
    amount integer,
    due_status integer,
    due_date date,
    issue_date date,
    clear_date date,
    damage_quantity integer
);


ALTER TABLE public.monetary_dues OWNER TO postgres;

--
-- Name: monetary_dues_monetary_due_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.monetary_dues_monetary_due_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.monetary_dues_monetary_due_id_seq OWNER TO postgres;

--
-- Name: monetary_dues_monetary_due_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.monetary_dues_monetary_due_id_seq OWNED BY public.monetary_dues.monetary_due_id;


--
-- Name: notification_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notification_types (
    notification_type integer NOT NULL,
    type_name character varying(100) NOT NULL
);


ALTER TABLE public.notification_types OWNER TO postgres;

--
-- Name: notification_types_notification_type_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notification_types_notification_type_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notification_types_notification_type_seq OWNER TO postgres;

--
-- Name: notification_types_notification_type_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notification_types_notification_type_seq OWNED BY public.notification_types.notification_type;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    notification_id integer NOT NULL,
    receiver_id integer,
    sender_name text,
    sender_role text,
    notification text,
    notification_time timestamp with time zone,
    notification_type integer,
    type_id integer
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
-- Name: clearance_request clearance_req_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clearance_request ALTER COLUMN clearance_req_id SET DEFAULT nextval('public.clearance_request_clearace_req_id_seq'::regclass);


--
-- Name: clearance_request_status clearance_status; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clearance_request_status ALTER COLUMN clearance_status SET DEFAULT nextval('public.clearance_request_status_clearance_status_seq'::regclass);


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
-- Name: monetary_dues monetary_due_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.monetary_dues ALTER COLUMN monetary_due_id SET DEFAULT nextval('public.monetary_dues_monetary_due_id_seq'::regclass);


--
-- Name: notification_types notification_type; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_types ALTER COLUMN notification_type SET DEFAULT nextval('public.notification_types_notification_type_seq'::regclass);


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
-- Data for Name: clearance_request; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.clearance_request (clearance_req_id, user_id, level, term, clearance_status, request_date, forward_date, verdict_date, verdictor) FROM stdin;
4	11	4	1	1	2024-02-27	\N	\N	\N
\.


--
-- Data for Name: clearance_request_status; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.clearance_request_status (clearance_status, status_name) FROM stdin;
1	Waiting for Superadmin Approval
\.


--
-- Data for Name: due_statuses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.due_statuses (due_status, status_name) FROM stdin;
1	Pending
2	Cleared
3	LostOrDamaged
\.


--
-- Data for Name: dues; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dues (due_id, req_id, alloter_id, receiver_id, due_status, due_date, issue_date, clear_date, quantity, damage_quantity, monetary_assigned) FROM stdin;
3	41	7	7	2	2024-02-29	2024-02-21	2024-02-25	7	0	0
2	34	7	\N	3	2024-02-21	2024-02-19	\N	2	1	0
4	38	7	\N	3	2024-03-01	2024-02-21	\N	2	3	0
5	43	7	\N	3	2024-03-30	2024-03-03	\N	3	0	0
6	54	7	\N	3	2024-03-28	2024-03-03	\N	5	3	0
7	55	7	\N	3	2024-03-26	2024-03-03	\N	5	2	1
8	56	7	\N	3	2024-03-19	2024-03-03	\N	4	2	1
\.


--
-- Data for Name: equipments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.equipments (equipment_id, equipment_name, type, cost, descript, borrowed, available, demand, permit, image_link) FROM stdin;
6	Iphone	Software	50000	iphone	8	72	1	3	https://www.91-img.com/gallery_images_uploads/3/d/3df5ca6a9b470f715b085991144a5b76e70da975.JPG?tr=h-550,w-0,c-at_max
2	Arduino	Hardware	100	Microcontroller	12	138	2	2	https://t4.ftcdn.net/jpg/03/33/90/55/240_F_333905577_NJ7hf7ekOjzPDA5yGDAAvlLyJdEwgFyt.jpg
5	LED	Hardware	5	Light	14	436	1	1	https://www.robotechbd.com/wp-content/uploads/2021/07/frosted-leds-red-green-blue-yellow-white-800x800-1.jpg
1	Breadboard	Hardware	90	Circuit building equipment	17	135	3	1	https://cdn.sparkfun.com/assets/learn_tutorials/4/7/12615-02_Full_Size_Breadboard_Split_Power_Rails.jpg
4	AtMega32	Hardware	500	Microcontroller device	11	99	1	2	https://upload.wikimedia.org/wikipedia/commons/f/f0/ATmega32_microcontroller.jpg?20090626195729
\.


--
-- Data for Name: equipments_in_locations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.equipments_in_locations (equipment_id, location_id, available, borrowed) FROM stdin;
2	1	100	0
1	1	52	0
5	1	345	0
4	1	60	0
6	1	35	0
6	2	37	8
2	2	38	12
5	2	91	14
1	2	83	17
4	2	39	11
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
-- Data for Name: monetary_dues; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.monetary_dues (monetary_due_id, req_id, user_id, creater_id, receiver_id, amount, due_status, due_date, issue_date, clear_date, damage_quantity) FROM stdin;
1	38	11	7	7	100	2	2024-03-07	2024-03-02	2024-03-03	\N
6	55	11	7	7	120	2	2024-03-18	2024-03-03	2024-03-03	2
7	56	1	7	7	800	2	2024-03-19	2024-03-03	2024-03-03	2
\.


--
-- Data for Name: notification_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notification_types (notification_type, type_name) FROM stdin;
1	Dues
2	Requests
3	Storage
4	Clearance
5	LostorDamaged
6	MonetaryDues
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notifications (notification_id, receiver_id, sender_name, sender_role, notification, notification_time, notification_type, type_id) FROM stdin;
1	1	raju	Lab Assistant	A due has been updated	2024-02-21 11:42:52.757204+06	1	3
2	11	raju	Lab Assistant	A due has been updated	2024-02-21 11:44:51.081872+06	1	4
3	1	raju	Lab Assistant	Your request has accepted. Collect it from the lab	2024-02-21 21:11:16.383899+06	2	46
4	11	raju	Lab Assistant	Collect it from lab 1	2024-02-21 21:12:31.422639+06	2	47
5	8	raju	Lab Assistant	You have been forwarded a request.	2024-02-21 22:13:31.728383+06	2	44
6	1	raju	Lab Assistant	Your request has been assigned to a supervisor.	2024-02-21 22:13:31.732377+06	2	44
7	8	raju	Lab Assistant	You have been forwarded a request.	2024-02-21 22:25:39.85293+06	2	48
8	11	raju	Lab Assistant	Your request has been assigned to a supervisor.	2024-02-21 22:25:39.854833+06	2	48
9	8	raju	Lab Assistant	You have been forwarded a request.	2024-02-21 22:40:11.936863+06	2	52
10	11	raju	Lab Assistant	Your request has been assigned to a supervisor.	2024-02-21 22:40:11.939786+06	2	52
11	8	raju	Lab Assistant	You have been forwarded a request.	2024-02-21 22:40:19.685196+06	2	51
12	11	raju	Lab Assistant	Your request has been assigned to a supervisor.	2024-02-21 22:40:19.68639+06	2	51
13	8	raju	Lab Assistant	You have been forwarded a request.	2024-02-21 22:40:23.713672+06	2	50
14	11	raju	Lab Assistant	Your request has been assigned to a supervisor.	2024-02-21 22:40:23.714858+06	2	50
15	15	tareqmahmood	Teacher	You have been forwarded a request.	2024-02-21 22:42:19.456027+06	2	51
16	7	tareqmahmood	Teacher	Your request has been forwarded to the Head of Department.	2024-02-21 22:42:19.461617+06	2	51
17	11	tareqmahmood	Teacher	Your request has been forwarded to the Head of Department.	2024-02-21 22:42:19.462749+06	2	51
18	8	raju	Lab Assistant	You have been forwarded a request.	2024-02-22 02:23:16.148189+06	2	53
19	11	raju	Lab Assistant	Your request has been assigned to a supervisor.	2024-02-22 02:23:16.151992+06	2	53
20	1	raju	Lab Assistant	A due has been cleared	2024-02-25 23:38:39.809118+06	1	3
21	7	1905091	Student	\N	2024-02-26 19:56:40.899753+06	1	4
22	7	1905091	Student	I have lost 1 item	2024-02-26 19:58:10.068953+06	1	4
23	7	1905091	Student	I have lost 1 item	2024-02-26 20:14:53.938042+06	1	4
24	14	1905103	Student	A clearance request has been sent	2024-02-27 12:59:20.583966+06	4	\N
25	11	raju	Lab Assistant	A monetary due has been created	2024-03-02 22:27:46.265352+06	6	1
26	11	raju	Lab Assistant	A monetary due has been cleared	2024-03-03 01:02:05.517299+06	6	1
27	7	1905091	Student	harai gelsi	2024-03-03 10:29:09.899026+06	1	2
28	1	raju	Lab Assistant	A monetary due has been created	2024-03-03 10:52:53.164308+06	6	2
29	7	1905103	Student	nothing to comment	2024-03-03 11:16:18.333054+06	1	4
30	11	raju	Lab Assistant	dont break it like u did previously	2024-03-03 11:21:25.799224+06	2	54
31	11	raju	Lab Assistant	A due has been updated	2024-03-03 11:25:09.932455+06	1	5
32	11	raju	Lab Assistant	A due has been updated	2024-03-03 11:26:00.682078+06	1	6
33	7	1905103	Student	nooo	2024-03-03 11:26:28.115591+06	1	6
34	11	raju	Lab Assistant	A monetary due has been created	2024-03-03 11:28:54.406599+06	6	3
35	7	1905103	Student	1	2024-03-03 11:36:33.504383+06	1	5
36	11	raju	Lab Assistant	A monetary due has been created	2024-03-03 11:37:33.834712+06	6	4
37	11	raju	Lab Assistant	NIye ja	2024-03-03 11:45:34.944627+06	2	55
38	11	raju	Lab Assistant	A due has been updated	2024-03-03 11:45:55.948911+06	1	6
39	11	raju	Lab Assistant	A due has been updated	2024-03-03 11:46:38.641593+06	1	7
40	7	1905103	Student	Haraisi	2024-03-03 11:47:13.801608+06	1	7
41	11	raju	Lab Assistant	A monetary due has been created	2024-03-03 11:47:45.656895+06	6	5
42	11	raju	Lab Assistant	A monetary due has been created	2024-03-03 12:06:40.777881+06	6	6
43	11	raju	Lab Assistant	A monetary due has been cleared	2024-03-03 12:20:37.738261+06	6	6
44	11	raju	Lab Assistant	A monetary due has been cleared	2024-03-03 12:23:06.134821+06	6	6
45	8	raju	Lab Assistant	You have been forwarded a request.	2024-03-03 12:26:09.80698+06	2	56
46	1	raju	Lab Assistant	Your request has been assigned to a supervisor.	2024-03-03 12:26:09.809096+06	2	56
47	1	tareqmahmood	Teacher		2024-03-03 12:27:09.966432+06	2	56
48	\N	tareqmahmood	Teacher	Your request has been accepted.	2024-03-03 12:27:09.971612+06	2	56
49	1	raju	Lab Assistant	A due has been updated	2024-03-03 12:28:22.431567+06	1	8
50	7	1905091	Student	haraisi	2024-03-03 12:28:55.128572+06	1	8
51	1	raju	Lab Assistant	A monetary due has been created	2024-03-03 12:29:52.021227+06	6	7
52	1	raju	Lab Assistant	A monetary due has been cleared	2024-03-03 12:30:16.154204+06	6	7
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
10	43	7		2024-02-21
11	45	7	Your request has accepted. Collect it from the lab	2024-02-21
12	46	7	Your request has accepted. Collect it from the lab	2024-02-21
13	47	7	Collect it from lab 1	2024-02-21
14	54	7	dont break it like u did previously	2024-03-03
15	55	7	NIye ja	2024-03-03
16	56	8		2024-03-03
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
44	8
48	8
52	8
51	8
50	8
53	8
56	8
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
43	11	2	1	3	2024-02-21	2	7	7	\N	\N	\N	\N
45	1	2	5	2	2024-02-21	2	7	7	\N	\N	\N	\N
46	1	2	5	5	2024-02-21	2	7	7	\N	\N	\N	\N
44	1	2	6	1	2024-02-21	5	\N	7	8	\N	\N	\N
47	11	2	1	2	2024-02-21	4	7	7	\N	\N	\N	\N
48	11	2	6	1	2024-02-21	5	\N	7	8	\N	\N	\N
49	7	1	6	30	2024-02-21	2	4	\N	\N	4	\N	\N
50	11	2	6	1	2024-02-21	4	\N	7	\N	\N	\N	\N
52	11	2	6	1	2024-02-21	5	\N	7	8	\N	\N	\N
51	11	2	6	1	2024-02-21	5	\N	7	8	\N	\N	\N
53	11	2	2	2	2024-02-22	4	\N	7	\N	\N	\N	\N
54	11	2	5	5	2024-03-03	2	7	7	\N	\N	\N	\N
55	11	2	1	5	2024-03-03	2	7	7	\N	\N	\N	\N
56	1	2	4	4	2024-03-03	2	8	7	8	\N	\N	\N
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
16	minu	Minu	Islam	minu@gmail.com	$2b$10$jUPLHVSaAFfMVTXlaVmM5uiY5kNFt7AoGtJZ4/TbN9Kzx3vSZojui	Lab Assistant	341234324	1
17	samia	Samia	Noor	samia@gmail.com	$2b$10$eXqLqLfDoRyLAhfq1hljWuOJP6pBdu.EK7ss5Ros6CNbdRepqR1bO	Lab Assistant	5282578025	1
18	rrd	Rayhan	Rashed	rayhan@gmail.com	$2b$10$hvNjP2uwuiGm72zPqvz6o.EMbbSz8bdkHN.3fPn.IF5Skql.C8rpy	Teacher	5632465437	1
19	asif	Asif	Haque	asif@gmail.com	$2b$10$ICJhsByjceWjHtjB/K2f4uwKELmVRS0aqGlMNTomgOZpanNnzA0vu	Lab Assistant	528780587	1
15	mmn	Mahmuda	Naznin	mmn@gmail.com	$2b$10$PH1lV/ciXVYgRrCbTHiKYumgcj4mPI8HYdU7py6h9Y54mEs1EBzAO	Department Head	52095720	1
20	abcd	Abcd	Efgh	abcd@gmail.com	$2b$10$0MOkOK3N4tHNnYZYTYGR0ufpUkQo3ujWPu1raooVA0Ayy4MTkFjQW	Teacher	6259324828	3
21	1409053	Amina	Islam	amina@gmail.com	$2b$10$poJ3W2Ae57bWlxSPhHUzveqeE4cwMQPbi8wnQGWLt9m.YAMKm9Y/G	Student	235670169501	2
22	1905066	Abir	Muhtasim	abir@gmail.com	$2b$10$gU6Y4FOF5NrgQtNqmlZXBesseVqzZQ3DmCDZ45JdSyoFEBfsxuToa	Student	85234950	1
23	badrul	Badrul	Alam	badrul@gmail.com	$2b$10$sS8SIdCj4OcVOUY6AOhc/euPgsMoFnF///ZnBZzOFgdqy9i0ikbwK	Lab Assistant	264754920	3
25	785629	mapla	islam	mapla@gmail.com	$2b$10$0PopS/Nu8ARXgsF5WauoTeGs9q/FR2mEzXevsSa6/NXgtFsnmEk9K	Student	64238959835	1
24	hanif	Hanif	Rahman	hanif@gmail.com	$2b$10$D9ReZTPCdlrRGUcDwFkhq.UX7VCY8ilvgfYqUIcZVy5mHj0dqTSyq	Lab Assistant	5624709	1
26	hislam	hamim	islam	hamim@gmail.com	$2b$10$eVy4pVIvO/wB3sDQyB2xIu.jU7eZixrafr4jFjFkJ5UkygjlUfHRa	Lab Assistant	2563270528	1
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
24	2	Lab Assistant
26	2	Lab Assistant
\.


--
-- Data for Name: viewed_notification; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.viewed_notification (user_id, viewed_notification_count, total_notification_count) FROM stdin;
2	0	0
4	0	0
5	0	0
9	0	0
12	0	0
13	0	0
15	1	1
16	0	0
17	0	0
18	0	0
19	0	0
14	0	1
20	0	0
21	0	0
22	0	0
23	0	0
24	0	0
25	0	0
26	0	0
11	18	22
8	5	7
7	1	10
1	9	10
\.


--
-- Name: clearance_request_clearace_req_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.clearance_request_clearace_req_id_seq', 4, true);


--
-- Name: clearance_request_status_clearance_status_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.clearance_request_status_clearance_status_seq', 1, true);


--
-- Name: due_statuses_due_status_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.due_statuses_due_status_seq', 3, true);


--
-- Name: dues_due_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dues_due_id_seq', 8, true);


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
-- Name: monetary_dues_monetary_due_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.monetary_dues_monetary_due_id_seq', 7, true);


--
-- Name: notification_types_notification_type_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.notification_types_notification_type_seq', 6, true);


--
-- Name: notifications_notification_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.notifications_notification_id_seq', 52, true);


--
-- Name: request_comments_req_comment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.request_comments_req_comment_id_seq', 16, true);


--
-- Name: request_status_req_status_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.request_status_req_status_seq', 6, true);


--
-- Name: requests_req_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.requests_req_id_seq', 56, true);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_user_id_seq', 26, true);


--
-- Name: clearance_request clearance_request_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clearance_request
    ADD CONSTRAINT clearance_request_pkey PRIMARY KEY (clearance_req_id);


--
-- Name: clearance_request_status clearance_request_status_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clearance_request_status
    ADD CONSTRAINT clearance_request_status_pkey PRIMARY KEY (clearance_status);


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
-- Name: monetary_dues monetary_dues_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.monetary_dues
    ADD CONSTRAINT monetary_dues_pkey PRIMARY KEY (monetary_due_id);


--
-- Name: notification_types notification_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_types
    ADD CONSTRAINT notification_types_pkey PRIMARY KEY (notification_type);


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
-- Name: notifications after_notification_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER after_notification_insert AFTER INSERT ON public.notifications FOR EACH ROW EXECUTE FUNCTION public.update_notification_count();


--
-- Name: clearance_request clearance_request_clearance_status_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clearance_request
    ADD CONSTRAINT clearance_request_clearance_status_fkey FOREIGN KEY (clearance_status) REFERENCES public.clearance_request_status(clearance_status);


--
-- Name: clearance_request clearance_request_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clearance_request
    ADD CONSTRAINT clearance_request_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id);


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
-- Name: monetary_dues monetary_dues_due_status_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.monetary_dues
    ADD CONSTRAINT monetary_dues_due_status_fkey FOREIGN KEY (due_status) REFERENCES public.due_statuses(due_status);


--
-- Name: monetary_dues monetary_dues_req_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.monetary_dues
    ADD CONSTRAINT monetary_dues_req_id_fkey FOREIGN KEY (req_id) REFERENCES public.requests(req_id);


--
-- Name: monetary_dues monetary_dues_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.monetary_dues
    ADD CONSTRAINT monetary_dues_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id);


--
-- Name: notifications notifications_notification_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_notification_type_fkey FOREIGN KEY (notification_type) REFERENCES public.notification_types(notification_type);


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

