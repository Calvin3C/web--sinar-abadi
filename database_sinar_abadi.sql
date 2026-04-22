--
-- PostgreSQL database dump
--

\restrict r2MwwQidLbhC0gVkkufZL8bMdIPSzaBs1uUGc7DBeEykTmfpZUervbMxG0HKPk0

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
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
-- Name: order_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_items (
    id bigint NOT NULL,
    order_id character varying(30) NOT NULL,
    product_id character varying(20),
    name character varying(300) NOT NULL,
    qty bigint NOT NULL,
    price bigint NOT NULL
);


ALTER TABLE public.order_items OWNER TO postgres;

--
-- Name: order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_items_id_seq OWNER TO postgres;

--
-- Name: order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_items_id_seq OWNED BY public.order_items.id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    id character varying(30) NOT NULL,
    date character varying(20) NOT NULL,
    customer_id bigint NOT NULL,
    customer_name character varying(200),
    phone character varying(30),
    address text,
    shipping_method character varying(100),
    total bigint NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    shipping_status character varying(100) DEFAULT 'Menunggu Validasi'::character varying NOT NULL,
    proof_uploaded boolean DEFAULT false,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: payment_methods; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payment_methods (
    id bigint NOT NULL,
    name character varying(100) NOT NULL,
    description text
);


ALTER TABLE public.payment_methods OWNER TO postgres;

--
-- Name: payment_methods_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.payment_methods_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payment_methods_id_seq OWNER TO postgres;

--
-- Name: payment_methods_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.payment_methods_id_seq OWNED BY public.payment_methods.id;


--
-- Name: payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payments (
    id bigint NOT NULL,
    order_id character varying(30) NOT NULL,
    payment_method_id bigint,
    payment_method character varying(50),
    amount_paid bigint NOT NULL,
    payment_status character varying(20) DEFAULT 'Pending'::character varying NOT NULL,
    paid_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.payments OWNER TO postgres;

--
-- Name: payments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payments_id_seq OWNER TO postgres;

--
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.payments_id_seq OWNED BY public.payments.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    id character varying(20) NOT NULL,
    category character varying(100) NOT NULL,
    name character varying(300) NOT NULL,
    price bigint NOT NULL,
    stock bigint DEFAULT 0 NOT NULL,
    sold bigint DEFAULT 0 NOT NULL,
    is_large boolean DEFAULT false,
    image_url character varying(500),
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.products OWNER TO postgres;

--
-- Name: shippings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shippings (
    id bigint NOT NULL,
    order_id character varying(30) NOT NULL,
    shipping_method_id bigint,
    shipping_method_name character varying(100) NOT NULL,
    tracking_number character varying(30),
    shipping_cost bigint DEFAULT 0 NOT NULL,
    destination_address text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.shippings OWNER TO postgres;

--
-- Name: shippings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shippings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.shippings_id_seq OWNER TO postgres;

--
-- Name: shippings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shippings_id_seq OWNED BY public.shippings.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    username character varying(100) NOT NULL,
    password text NOT NULL,
    role character varying(20) DEFAULT 'customer'::character varying NOT NULL,
    name character varying(200) NOT NULL,
    is_blocked boolean DEFAULT false,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: order_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items ALTER COLUMN id SET DEFAULT nextval('public.order_items_id_seq'::regclass);


--
-- Name: payment_methods id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_methods ALTER COLUMN id SET DEFAULT nextval('public.payment_methods_id_seq'::regclass);


--
-- Name: payments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments ALTER COLUMN id SET DEFAULT nextval('public.payments_id_seq'::regclass);


--
-- Name: shippings id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shippings ALTER COLUMN id SET DEFAULT nextval('public.shippings_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_items (id, order_id, product_id, name, qty, price) FROM stdin;
1	ORD-260401-081	P-096	Lampu Philips LED 5 Watt	2	385000
2	ORD-260402-309	P-001	Semen Gresik 40 kg	10	59000
3	ORD-260419-920	P-088	Meteran Tukang 3 m	1	25000
4	ORD-260419-920	P-021	Pipa Maspion 5/8 C	1	9000
5	ORD-260421-290	P-096	Lampu Philips LED 5 Watt	1	25000
6	ORD-260421-290	P-097	Lampu Philips LED 7 Watt	1	29000
7	ORD-260421-938	P-096	Lampu Philips LED 5 Watt	1	25000
8	ORD-260421-938	P-097	Lampu Philips LED 7 Watt	1	29000
9	ORD-260422-626	P-103	Kuas Eterna 2 Inch	1	12000
10	ORD-260422-739	P-100	Lampu Philips LED 13 Watt	1	49500
11	ORD-260422-739	P-001	Semen Gresik 40 kg	2	59000
12	ORD-260422-842	P-096	Lampu Philips LED 5 Watt	1	25000
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (id, date, customer_id, customer_name, phone, address, shipping_method, total, status, shipping_status, proof_uploaded, created_at, updated_at) FROM stdin;
ORD-260402-309	2026-04-02	1	budi	081234567890	Toko Sinar Abadi	Ambil di Toko	721500	pending	Menunggu Validasi	t	2026-04-19 17:50:20.574837+07	2026-04-19 17:50:20.574837+07
ORD-260419-920	2026-04-19	4	Calvin3c	082331339737	Ambil di Toko Sinar Abadi	Ambil di Toko	37740	success	Siap Diambil	t	2026-04-19 18:18:45.932002+07	2026-04-19 18:21:02.520558+07
ORD-260401-081	2026-04-01	1	budi	081234567890	Jl. Merdeka, Malang	Kurir Toko Sinar Abadi	854700	success	Dalam Pengiriman	t	2026-04-19 17:50:20.569821+07	2026-04-21 11:26:17.239984+07
ORD-260421-290	2026-04-21	4	Calvin3c	082331339737	Ijen Nirwana	Ekspedisi JNE	59940	success	Sedang Dikemas	t	2026-04-21 11:08:34.109417+07	2026-04-21 11:30:12.281899+07
ORD-260421-938	2026-04-21	4	Calvin3c	082331339736	Ijen Nirwana Blok C3 no 11	Ambil di Toko	59940	pending	Menunggu Validasi	f	2026-04-21 14:45:56.781512+07	2026-04-21 14:45:56.781512+07
ORD-260422-626	2026-04-22	4	Calvin3c	082331339736	Kabupaten Malang	Kurir Toko Sinar Abadi	63320	pending	Menunggu Validasi	f	2026-04-22 08:43:04.538975+07	2026-04-22 08:43:04.538975+07
ORD-260422-739	2026-04-22	4	Calvin3c	08231339737	Calvin Alexander  Sucipto, Ijen Nirwana (Patokan: Ijen Nirwana dekat hotel ijen suites), Kec. Klojen, Kota Malang, Jawa Timur, Indonesia 65116	Kurir Toko Sinar Abadi	235925	pending	Menunggu Validasi	f	2026-04-22 09:05:39.558714+07	2026-04-22 09:05:39.558714+07
ORD-260422-842	2026-04-22	4	Calvin3c	082331339737	Ambil Di Toko Sinar Abadi Dampit, Malang (+62 8123388670)	Ambil di Toko	27750	pending	Menunggu Validasi	f	2026-04-22 12:40:33.472976+07	2026-04-22 12:40:33.472976+07
\.


--
-- Data for Name: payment_methods; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payment_methods (id, name, description) FROM stdin;
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payments (id, order_id, payment_method_id, payment_method, amount_paid, payment_status, paid_at, created_at, updated_at) FROM stdin;
1	ORD-260422-626	0	Virtual Account	63320	Pending	\N	2026-04-22 08:43:04.557789+07	2026-04-22 08:43:04.557789+07
2	ORD-260422-739	0	Virtual Account	235925	Pending	\N	2026-04-22 09:05:39.566313+07	2026-04-22 09:05:39.566313+07
3	ORD-260422-842	0	Virtual Account	27750	Pending	\N	2026-04-22 12:40:33.481939+07	2026-04-22 12:40:33.481939+07
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (id, category, name, price, stock, sold, is_large, image_url, created_at, updated_at) FROM stdin;
P-002	Semen	Semen Merah Putih 40 kg	47000	120	720	t	https://placehold.co/400x300/1e293b/white?text=Semen+Merah+Putih	2026-04-19 17:50:20.507501+07	2026-04-19 17:50:20.507501+07
P-003	Semen	Semen Singa Merah 40 kg	45000	100	650	t	https://placehold.co/400x300/1e293b/white?text=Semen+Singa+Merah	2026-04-19 17:50:20.508133+07	2026-04-19 17:50:20.508133+07
P-004	Semen	Semen Putih Tiga Roda 40 kg	120000	60	320	t	https://placehold.co/400x300/1e293b/white?text=Semen+Tiga+Roda	2026-04-19 17:50:20.509338+07	2026-04-19 17:50:20.509338+07
P-005	Semen	Semen Putih Panda 40 kg	65000	80	410	t	https://placehold.co/400x300/1e293b/white?text=Semen+Panda	2026-04-19 17:50:20.509858+07	2026-04-19 17:50:20.509858+07
P-006	Semen	Semen Sika Perekat Granit 20 kg	110000	50	280	t	https://placehold.co/400x300/1e293b/white?text=Semen+Sika	2026-04-19 17:50:20.510453+07	2026-04-19 17:50:20.510453+07
P-007	Semen	Semen Perekat Bata Ringan Drymix 20 kg	75000	70	350	t	https://placehold.co/400x300/1e293b/white?text=Drymix	2026-04-19 17:50:20.511493+07	2026-04-19 17:50:20.511493+07
P-008	Semen	Semen Perekat Bata Ringan Eco 20 kg	65000	70	300	t	https://placehold.co/400x300/1e293b/white?text=Eco+Bata	2026-04-19 17:50:20.512044+07	2026-04-19 17:50:20.512044+07
P-009	Plumbing	Pipa Maspion 1/2 AW	35000	200	1200	f	https://placehold.co/400x300/0284c7/white?text=Maspion+1/2+AW	2026-04-19 17:50:20.512593+07	2026-04-19 17:50:20.512593+07
P-010	Plumbing	Pipa Maspion 3/4 AW	42000	200	1100	f	https://placehold.co/400x300/0284c7/white?text=Maspion+3/4+AW	2026-04-19 17:50:20.512593+07	2026-04-19 17:50:20.512593+07
P-011	Plumbing	Pipa Maspion 1 AW	56000	150	900	f	https://placehold.co/400x300/0284c7/white?text=Maspion+1+AW	2026-04-19 17:50:20.513111+07	2026-04-19 17:50:20.513111+07
P-012	Plumbing	Pipa Maspion 1 1/4 AW	74000	100	600	f	https://placehold.co/400x300/0284c7/white?text=Maspion+1+1/4+AW	2026-04-19 17:50:20.513625+07	2026-04-19 17:50:20.513625+07
P-013	Plumbing	Pipa Maspion 1 1/2 AW	98000	100	500	f	https://placehold.co/400x300/0284c7/white?text=Maspion+1+1/2+AW	2026-04-19 17:50:20.513625+07	2026-04-19 17:50:20.513625+07
P-014	Plumbing	Pipa Maspion 2 AW	138000	80	400	f	https://placehold.co/400x300/0284c7/white?text=Maspion+2+AW	2026-04-19 17:50:20.51414+07	2026-04-19 17:50:20.51414+07
P-015	Plumbing	Pipa Maspion 2 1/2 AW	185000	60	250	f	https://placehold.co/400x300/0284c7/white?text=Maspion+2+1/2+AW	2026-04-19 17:50:20.51414+07	2026-04-19 17:50:20.51414+07
P-016	Plumbing	Pipa Maspion 3 AW	255000	50	200	f	https://placehold.co/400x300/0284c7/white?text=Maspion+3+AW	2026-04-19 17:50:20.514673+07	2026-04-19 17:50:20.514673+07
P-017	Plumbing	Pipa Maspion 4 AW	385000	40	150	f	https://placehold.co/400x300/0284c7/white?text=Maspion+4+AW	2026-04-19 17:50:20.51519+07	2026-04-19 17:50:20.51519+07
P-018	Plumbing	Pipa Maspion 5 AW	575000	30	80	f	https://placehold.co/400x300/0284c7/white?text=Maspion+5+AW	2026-04-19 17:50:20.51519+07	2026-04-19 17:50:20.51519+07
P-019	Plumbing	Pipa Maspion 6 AW	765000	20	50	f	https://placehold.co/400x300/0284c7/white?text=Maspion+6+AW	2026-04-19 17:50:20.51571+07	2026-04-19 17:50:20.51571+07
P-020	Plumbing	Pipa Maspion 8 AW	1275000	15	30	f	https://placehold.co/400x300/0284c7/white?text=Maspion+8+AW	2026-04-19 17:50:20.51571+07	2026-04-19 17:50:20.51571+07
P-022	Plumbing	Pipa Maspion 3/4 C	16000	250	1300	f	https://placehold.co/400x300/0284c7/white?text=Maspion+3/4+C	2026-04-19 17:50:20.516742+07	2026-04-19 17:50:20.516742+07
P-023	Plumbing	Pipa Maspion 1 C	26000	200	1000	f	https://placehold.co/400x300/0284c7/white?text=Maspion+1+C	2026-04-19 17:50:20.517289+07	2026-04-19 17:50:20.517289+07
P-024	Plumbing	Pipa Maspion 1 1/4 C	31000	150	700	f	https://placehold.co/400x300/0284c7/white?text=Maspion+1+1/4+C	2026-04-19 17:50:20.517289+07	2026-04-19 17:50:20.517289+07
P-025	Plumbing	Pipa Maspion 1 1/2 C	37000	150	600	f	https://placehold.co/400x300/0284c7/white?text=Maspion+1+1/2+C	2026-04-19 17:50:20.517817+07	2026-04-19 17:50:20.517817+07
P-026	Plumbing	Pipa Maspion 2 C	58000	100	400	f	https://placehold.co/400x300/0284c7/white?text=Maspion+2+C	2026-04-19 17:50:20.518342+07	2026-04-19 17:50:20.518342+07
P-027	Plumbing	Pipa Maspion 2 1/2 C	69000	80	300	f	https://placehold.co/400x300/0284c7/white?text=Maspion+2+1/2+C	2026-04-19 17:50:20.518867+07	2026-04-19 17:50:20.518867+07
P-028	Plumbing	Pipa Maspion 3 C	79000	60	200	f	https://placehold.co/400x300/0284c7/white?text=Maspion+3+C	2026-04-19 17:50:20.518867+07	2026-04-19 17:50:20.518867+07
P-029	Plumbing	Pipa Maspion 4 C	102000	50	150	f	https://placehold.co/400x300/0284c7/white?text=Maspion+4+C	2026-04-19 17:50:20.519388+07	2026-04-19 17:50:20.519388+07
P-030	Plumbing	Pipa Maspion 1 1/4 D	45000	100	400	f	https://placehold.co/400x300/0284c7/white?text=Maspion+1+1/4+D	2026-04-19 17:50:20.519388+07	2026-04-19 17:50:20.519388+07
P-031	Plumbing	Pipa Maspion 1 1/2 D	55000	100	350	f	https://placehold.co/400x300/0284c7/white?text=Maspion+1+1/2+D	2026-04-19 17:50:20.519907+07	2026-04-19 17:50:20.519907+07
P-032	Plumbing	Pipa Maspion 2 D	68000	80	300	f	https://placehold.co/400x300/0284c7/white?text=Maspion+2+D	2026-04-19 17:50:20.520695+07	2026-04-19 17:50:20.520695+07
P-033	Plumbing	Pipa Maspion 2 1/2 D	98000	60	200	f	https://placehold.co/400x300/0284c7/white?text=Maspion+2+1/2+D	2026-04-19 17:50:20.520695+07	2026-04-19 17:50:20.520695+07
P-034	Plumbing	Pipa Maspion 3 D	137000	50	150	f	https://placehold.co/400x300/0284c7/white?text=Maspion+3+D	2026-04-19 17:50:20.521223+07	2026-04-19 17:50:20.521223+07
P-035	Plumbing	Pipa Maspion 4 D	189000	40	100	f	https://placehold.co/400x300/0284c7/white?text=Maspion+4+D	2026-04-19 17:50:20.521748+07	2026-04-19 17:50:20.521748+07
P-036	Plumbing	Pipa Maspion 5 D	320000	30	60	f	https://placehold.co/400x300/0284c7/white?text=Maspion+5+D	2026-04-19 17:50:20.522267+07	2026-04-19 17:50:20.522267+07
P-037	Plumbing	Pipa Maspion 6 D	410000	20	40	f	https://placehold.co/400x300/0284c7/white?text=Maspion+6+D	2026-04-19 17:50:20.522267+07	2026-04-19 17:50:20.522267+07
P-038	Plumbing	Pipa Maspion 8 D	730000	15	25	f	https://placehold.co/400x300/0284c7/white?text=Maspion+8+D	2026-04-19 17:50:20.522787+07	2026-04-19 17:50:20.522787+07
P-039	Plumbing	Pipa Rucika 1/2 AW	32000	200	1100	f	https://placehold.co/400x300/0284c7/white?text=Rucika+1/2+AW	2026-04-19 17:50:20.523314+07	2026-04-19 17:50:20.523314+07
P-040	Plumbing	Pipa Rucika 3/4 AW	42000	200	1000	f	https://placehold.co/400x300/0284c7/white?text=Rucika+3/4+AW	2026-04-19 17:50:20.523838+07	2026-04-19 17:50:20.523838+07
P-041	Plumbing	Pipa Rucika 1 AW	55000	150	800	f	https://placehold.co/400x300/0284c7/white?text=Rucika+1+AW	2026-04-19 17:50:20.523838+07	2026-04-19 17:50:20.523838+07
P-042	Plumbing	Pipa Rucika 1 1/4 AW	74000	100	500	f	https://placehold.co/400x300/0284c7/white?text=Rucika+1+1/4+AW	2026-04-19 17:50:20.524363+07	2026-04-19 17:50:20.524363+07
P-043	Plumbing	Pipa Rucika 1 1/2 AW	92000	100	450	f	https://placehold.co/400x300/0284c7/white?text=Rucika+1+1/2+AW	2026-04-19 17:50:20.524885+07	2026-04-19 17:50:20.524885+07
P-044	Plumbing	Pipa Rucika 2 AW	128000	80	350	f	https://placehold.co/400x300/0284c7/white?text=Rucika+2+AW	2026-04-19 17:50:20.524885+07	2026-04-19 17:50:20.524885+07
P-045	Plumbing	Pipa Rucika 2 1/2 AW	175000	60	200	f	https://placehold.co/400x300/0284c7/white?text=Rucika+2+1/2+AW	2026-04-19 17:50:20.525405+07	2026-04-19 17:50:20.525405+07
P-046	Plumbing	Pipa Rucika 3 AW	255000	50	150	f	https://placehold.co/400x300/0284c7/white?text=Rucika+3+AW	2026-04-19 17:50:20.525927+07	2026-04-19 17:50:20.525927+07
P-047	Plumbing	Pipa Rucika 4 AW	385000	40	100	f	https://placehold.co/400x300/0284c7/white?text=Rucika+4+AW	2026-04-19 17:50:20.525927+07	2026-04-19 17:50:20.525927+07
P-001	Semen	Semen Gresik 40 kg	59000	98	852	t	https://placehold.co/400x300/1e293b/white?text=Semen+Gresik	2026-04-19 17:50:20.505703+07	2026-04-22 09:05:39.556932+07
P-048	Plumbing	Pipa Rucika 5 AW	595000	25	60	f	https://placehold.co/400x300/0284c7/white?text=Rucika+5+AW	2026-04-19 17:50:20.526447+07	2026-04-19 17:50:20.526447+07
P-049	Plumbing	Pipa Rucika 6 AW	775000	20	40	f	https://placehold.co/400x300/0284c7/white?text=Rucika+6+AW	2026-04-19 17:50:20.529111+07	2026-04-19 17:50:20.529111+07
P-050	Plumbing	Pipa Rucika 8 AW	1325000	10	20	f	https://placehold.co/400x300/0284c7/white?text=Rucika+8+AW	2026-04-19 17:50:20.529638+07	2026-04-19 17:50:20.529638+07
P-051	Cat Tembok	Decolith 5 kg	145000	100	900	f	https://placehold.co/400x300/dc2626/white?text=Decolith+5kg	2026-04-19 17:50:20.530159+07	2026-04-19 17:50:20.530159+07
P-052	Cat Tembok	Decolith 25 kg	725000	40	300	f	https://placehold.co/400x300/dc2626/white?text=Decolith+25kg	2026-04-19 17:50:20.530159+07	2026-04-19 17:50:20.530159+07
P-053	Cat Tembok	Avitex 5 kg	155000	100	850	f	https://placehold.co/400x300/dc2626/white?text=Avitex+5kg	2026-04-19 17:50:20.530679+07	2026-04-19 17:50:20.530679+07
P-054	Cat Tembok	Avitex 25 kg	775000	35	250	f	https://placehold.co/400x300/dc2626/white?text=Avitex+25kg	2026-04-19 17:50:20.530679+07	2026-04-19 17:50:20.530679+07
P-055	Cat Tembok	No. Drop 4 kg	245000	60	500	f	https://placehold.co/400x300/dc2626/white?text=No+Drop+4kg	2026-04-19 17:50:20.531281+07	2026-04-19 17:50:20.531281+07
P-056	Cat Tembok	No. Drop 20 kg	1225000	20	150	f	https://placehold.co/400x300/dc2626/white?text=No+Drop+20kg	2026-04-19 17:50:20.531793+07	2026-04-19 17:50:20.531793+07
P-057	Cat Tembok	Aquaproof 4 kg	265000	50	450	f	https://placehold.co/400x300/dc2626/white?text=Aquaproof+4kg	2026-04-19 17:50:20.532376+07	2026-04-19 17:50:20.532376+07
P-058	Cat Tembok	Aquaproof 20 kg	1275000	15	100	f	https://placehold.co/400x300/dc2626/white?text=Aquaproof+20kg	2026-04-19 17:50:20.532932+07	2026-04-19 17:50:20.532932+07
P-059	Cat Tembok	Aries 5 kg	70000	120	700	f	https://placehold.co/400x300/dc2626/white?text=Aries+5kg	2026-04-19 17:50:20.533456+07	2026-04-19 17:50:20.533456+07
P-060	Cat Tembok	Aries 20 kg	280000	40	250	f	https://placehold.co/400x300/dc2626/white?text=Aries+20kg	2026-04-19 17:50:20.534133+07	2026-04-19 17:50:20.534133+07
P-061	Cat Kayu	Emco Warna Standart 1 kg	85000	80	600	f	https://placehold.co/400x300/b91c1c/white?text=Emco+Std+1kg	2026-04-19 17:50:20.534705+07	2026-04-19 17:50:20.534705+07
P-062	Cat Kayu	Emco Warna Standart 0.5 kg	47500	100	700	f	https://placehold.co/400x300/b91c1c/white?text=Emco+Std+0.5kg	2026-04-19 17:50:20.535226+07	2026-04-19 17:50:20.535226+07
P-063	Cat Kayu	Emco Warna Gunung 1 kg	95000	60	400	f	https://placehold.co/400x300/b91c1c/white?text=Emco+Gunung+1kg	2026-04-19 17:50:20.535226+07	2026-04-19 17:50:20.535226+07
P-064	Cat Kayu	Emco Warna Gunung 0.5 kg	55000	80	500	f	https://placehold.co/400x300/b91c1c/white?text=Emco+Gunung+0.5kg	2026-04-19 17:50:20.536287+07	2026-04-19 17:50:20.536287+07
P-065	Cat Kayu	Emco Warna Bintang 1 kg	102000	50	300	f	https://placehold.co/400x300/b91c1c/white?text=Emco+Bintang+1kg	2026-04-19 17:50:20.536811+07	2026-04-19 17:50:20.536811+07
P-066	Cat Kayu	Emco Warna Bintang 0.5 kg	60000	70	400	f	https://placehold.co/400x300/b91c1c/white?text=Emco+Bintang+0.5kg	2026-04-19 17:50:20.537365+07	2026-04-19 17:50:20.537365+07
P-067	Cat Kayu	Avian 1 kg	85000	80	550	f	https://placehold.co/400x300/b91c1c/white?text=Avian+1kg	2026-04-19 17:50:20.537365+07	2026-04-19 17:50:20.537365+07
P-068	Cat Kayu	Avian 0.5 kg	47500	100	650	f	https://placehold.co/400x300/b91c1c/white?text=Avian+0.5kg	2026-04-19 17:50:20.538068+07	2026-04-19 17:50:20.538068+07
P-069	Besi Beton	Besi Beton 6 SNI	28000	200	1500	t	https://placehold.co/400x300/374151/white?text=Besi+6+SNI	2026-04-19 17:50:20.538623+07	2026-04-19 17:50:20.538623+07
P-070	Besi Beton	Besi Beton 8 SNI	46000	150	1200	t	https://placehold.co/400x300/374151/white?text=Besi+8+SNI	2026-04-19 17:50:20.538623+07	2026-04-19 17:50:20.538623+07
P-071	Besi Beton	Besi Beton 10 SNI	71000	120	900	t	https://placehold.co/400x300/374151/white?text=Besi+10+SNI	2026-04-19 17:50:20.539143+07	2026-04-19 17:50:20.539143+07
P-072	Besi Beton	Besi Beton 12 SNI	105000	100	700	t	https://placehold.co/400x300/374151/white?text=Besi+12+SNI	2026-04-19 17:50:20.539519+07	2026-04-19 17:50:20.539519+07
P-073	Besi Beton	Besi Beton 14 SNI	134000	80	500	t	https://placehold.co/400x300/374151/white?text=Besi+14+SNI	2026-04-19 17:50:20.540123+07	2026-04-19 17:50:20.540123+07
P-074	Besi Beton	Besi Beton 16 SNI	195000	60	350	t	https://placehold.co/400x300/374151/white?text=Besi+16+SNI	2026-04-19 17:50:20.540635+07	2026-04-19 17:50:20.540635+07
P-075	Kloset	Kloset Jongkok INA	210000	30	200	t	https://placehold.co/400x300/0f172a/white?text=Kloset+INA	2026-04-19 17:50:20.541215+07	2026-04-19 17:50:20.541215+07
P-076	Kloset	Kloset Jongkok Triliun	205000	30	180	t	https://placehold.co/400x300/0f172a/white?text=Kloset+Triliun	2026-04-19 17:50:20.541739+07	2026-04-19 17:50:20.541739+07
P-077	Kloset	Kloset Jongkok Duty	145000	40	250	t	https://placehold.co/400x300/0f172a/white?text=Kloset+Duty	2026-04-19 17:50:20.542892+07	2026-04-19 17:50:20.542892+07
P-078	Kloset	Monoblok INA	1550000	10	50	t	https://placehold.co/400x300/0f172a/white?text=Monoblok+INA	2026-04-19 17:50:20.543408+07	2026-04-19 17:50:20.543408+07
P-079	Kloset	Monoblok Triliun	1525000	10	45	t	https://placehold.co/400x300/0f172a/white?text=Monoblok+Triliun	2026-04-19 17:50:20.544116+07	2026-04-19 17:50:20.544116+07
P-080	Kloset	Monoblok Volk	1250000	12	60	t	https://placehold.co/400x300/0f172a/white?text=Monoblok+Volk	2026-04-19 17:50:20.544644+07	2026-04-19 17:50:20.544644+07
P-081	Tools	Mesin Pasrah Modern M2900	495000	15	120	f	https://placehold.co/400x300/059669/white?text=Pasrah+M2900	2026-04-19 17:50:20.545172+07	2026-04-19 17:50:20.545172+07
P-082	Tools	Mesin Pasrah Modern M2950	475000	15	100	f	https://placehold.co/400x300/059669/white?text=Pasrah+M2950	2026-04-19 17:50:20.545883+07	2026-04-19 17:50:20.545883+07
P-083	Tools	Mesin Bor Modern M2100	295000	20	200	f	https://placehold.co/400x300/059669/white?text=Bor+M2100	2026-04-19 17:50:20.546641+07	2026-04-19 17:50:20.546641+07
P-084	Tools	Mesin Bor Modern M2130	395000	15	150	f	https://placehold.co/400x300/059669/white?text=Bor+M2130	2026-04-19 17:50:20.547198+07	2026-04-19 17:50:20.547198+07
P-085	Tools	Mesin Gerinda Modern M2350	325000	18	180	f	https://placehold.co/400x300/059669/white?text=Gerinda+M2350	2026-04-19 17:50:20.547715+07	2026-04-19 17:50:20.547715+07
P-086	Tools	Mesin Profil Modern M2700	425000	12	90	f	https://placehold.co/400x300/059669/white?text=Profil+M2700	2026-04-19 17:50:20.548319+07	2026-04-19 17:50:20.548319+07
P-087	Tools	Mesin Gergaji Modern M2600	625000	10	70	f	https://placehold.co/400x300/059669/white?text=Gergaji+M2600	2026-04-19 17:50:20.548319+07	2026-04-19 17:50:20.548319+07
P-089	Tools	Meteran Tukang 5 m	35000	200	1400	f	https://placehold.co/400x300/059669/white?text=Meteran+5m	2026-04-19 17:50:20.549416+07	2026-04-19 17:50:20.549416+07
P-090	Tools	Meteran Tukang 7.5 m	55000	150	1000	f	https://placehold.co/400x300/059669/white?text=Meteran+7.5m	2026-04-19 17:50:20.549416+07	2026-04-19 17:50:20.549416+07
P-091	Tools	Meteran Tukang 10 m	55000	150	900	f	https://placehold.co/400x300/059669/white?text=Meteran+10m	2026-04-19 17:50:20.55004+07	2026-04-19 17:50:20.55004+07
P-092	Tools	Palu Tukang Supit 8 oz	35000	100	800	f	https://placehold.co/400x300/059669/white?text=Palu+8oz	2026-04-19 17:50:20.55004+07	2026-04-19 17:50:20.55004+07
P-093	Tools	Palu Tukang Supit 12 oz	45000	100	700	f	https://placehold.co/400x300/059669/white?text=Palu+12oz	2026-04-19 17:50:20.550553+07	2026-04-19 17:50:20.550553+07
P-094	Tools	Palu Tukang Kotak 200 gram	35000	100	600	f	https://placehold.co/400x300/059669/white?text=Palu+200g	2026-04-19 17:50:20.550553+07	2026-04-19 17:50:20.550553+07
P-095	Tools	Palu Tukang Kotak 300 gram	45000	100	550	f	https://placehold.co/400x300/059669/white?text=Palu+300g	2026-04-19 17:50:20.551067+07	2026-04-19 17:50:20.551067+07
P-098	Electrical	Lampu Philips LED 9 Watt	35000	250	2500	f	https://placehold.co/400x300/d97706/white?text=Philips+9W	2026-04-19 17:50:20.552108+07	2026-04-19 17:50:20.552108+07
P-099	Electrical	Lampu Philips LED 11 Watt	42500	200	2000	f	https://placehold.co/400x300/d97706/white?text=Philips+11W	2026-04-19 17:50:20.552108+07	2026-04-19 17:50:20.552108+07
P-101	Kuas Cat	Kuas Eterna 1 Inch	7000	300	2000	f	https://placehold.co/400x300/e11d48/white?text=Kuas+1in	2026-04-19 17:50:20.55315+07	2026-04-19 17:50:20.55315+07
P-102	Kuas Cat	Kuas Eterna 1.5 Inch	10000	300	1800	f	https://placehold.co/400x300/e11d48/white?text=Kuas+1.5in	2026-04-19 17:50:20.55315+07	2026-04-19 17:50:20.55315+07
P-104	Kuas Cat	Kuas Eterna 2.5 Inch	15000	250	1400	f	https://placehold.co/400x300/e11d48/white?text=Kuas+2.5in	2026-04-19 17:50:20.554293+07	2026-04-19 17:50:20.554293+07
P-105	Kuas Cat	Kuas Eterna 3 Inch	18000	200	1200	f	https://placehold.co/400x300/e11d48/white?text=Kuas+3in	2026-04-19 17:50:20.554853+07	2026-04-19 17:50:20.554853+07
P-106	Kuas Cat	Kuas Eterna 4 Inch	25000	200	1000	f	https://placehold.co/400x300/e11d48/white?text=Kuas+4in	2026-04-19 17:50:20.555387+07	2026-04-19 17:50:20.555387+07
P-107	Kuas Cat	Kuas Eterna 5 Inch	30000	150	800	f	https://placehold.co/400x300/e11d48/white?text=Kuas+5in	2026-04-19 17:50:20.556441+07	2026-04-19 17:50:20.556441+07
P-108	Kuas Cat	Kuas Eterna 6 Inch	35000	150	700	f	https://placehold.co/400x300/e11d48/white?text=Kuas+6in	2026-04-19 17:50:20.556441+07	2026-04-19 17:50:20.556441+07
P-109	Kuas Cat	Kuas Roll Eterna 9 Inch	30000	100	900	f	https://placehold.co/400x300/e11d48/white?text=Roll+Eterna+9in	2026-04-19 17:50:20.557552+07	2026-04-19 17:50:20.557552+07
P-110	Kuas Cat	Kuas Roll 4 Inch	15000	150	800	f	https://placehold.co/400x300/e11d48/white?text=Roll+4in	2026-04-19 17:50:20.55813+07	2026-04-19 17:50:20.55813+07
P-111	Kuas Cat	Kuas Roll Imundex 9 Inch	30000	100	600	f	https://placehold.co/400x300/e11d48/white?text=Roll+Imundex+9in	2026-04-19 17:50:20.558654+07	2026-04-19 17:50:20.558654+07
P-112	Kuas Cat	Kuas Roll Imundex 7 Inch	25000	120	650	f	https://placehold.co/400x300/e11d48/white?text=Roll+Imundex+7in	2026-04-19 17:50:20.559177+07	2026-04-19 17:50:20.559177+07
P-113	Kunci Pintu	Kunci Pintu Zeona Besar	175000	50	350	f	https://placehold.co/400x300/1e293b/white?text=Zeona+Besar	2026-04-19 17:50:20.559177+07	2026-04-19 17:50:20.559177+07
P-114	Kunci Pintu	Kunci Pintu Zeona Tanggung	110000	60	400	f	https://placehold.co/400x300/1e293b/white?text=Zeona+Tanggung	2026-04-19 17:50:20.559703+07	2026-04-19 17:50:20.559703+07
P-115	Kunci Pintu	Kunci Pintu WanLi Kecil	75000	80	500	f	https://placehold.co/400x300/1e293b/white?text=WanLi+Kecil	2026-04-19 17:50:20.560231+07	2026-04-19 17:50:20.560231+07
P-116	Kunci Pintu	Kunci Pintu Muller Besar	325000	30	200	f	https://placehold.co/400x300/1e293b/white?text=Muller+Besar	2026-04-19 17:50:20.560758+07	2026-04-19 17:50:20.560758+07
P-117	Kunci Pintu	Kunci Pintu Muller Tanggung	245000	40	250	f	https://placehold.co/400x300/1e293b/white?text=Muller+Tanggung	2026-04-19 17:50:20.560758+07	2026-04-19 17:50:20.560758+07
P-118	Kunci Pintu	Kunci Pintu Kuda Besar	125000	60	350	f	https://placehold.co/400x300/1e293b/white?text=Kuda+Besar	2026-04-19 17:50:20.561282+07	2026-04-19 17:50:20.561282+07
P-119	Kunci Pintu	Kunci Pintu Kuda Kecil	95000	70	400	f	https://placehold.co/400x300/1e293b/white?text=Kuda+Kecil	2026-04-19 17:50:20.561805+07	2026-04-19 17:50:20.561805+07
P-120	Engsel	Engsel Pintu Muller 5 Inch	95000	100	400	f	https://placehold.co/400x300/64748b/white?text=Engsel+Muller+5in	2026-04-19 17:50:20.561805+07	2026-04-19 17:50:20.561805+07
P-121	Engsel	Engsel Pintu Muller 4 Inch	75000	100	450	f	https://placehold.co/400x300/64748b/white?text=Engsel+Muller+4in	2026-04-19 17:50:20.562329+07	2026-04-19 17:50:20.562329+07
P-122	Engsel	Engsel Pintu Muller 3 Inch	45000	120	500	f	https://placehold.co/400x300/64748b/white?text=Engsel+Muller+3in	2026-04-19 17:50:20.562854+07	2026-04-19 17:50:20.562854+07
P-123	Engsel	Engsel Pintu Nishio 5 Inch	45000	100	350	f	https://placehold.co/400x300/64748b/white?text=Engsel+Nishio+5in	2026-04-19 17:50:20.562854+07	2026-04-19 17:50:20.562854+07
P-124	Engsel	Engsel Pintu Nishio 4 Inch	35000	120	400	f	https://placehold.co/400x300/64748b/white?text=Engsel+Nishio+4in	2026-04-19 17:50:20.563373+07	2026-04-19 17:50:20.563373+07
P-125	Engsel	Engsel Pintu Nishio 3 Inch	20000	150	600	f	https://placehold.co/400x300/64748b/white?text=Engsel+Nishio+3in	2026-04-19 17:50:20.563889+07	2026-04-19 17:50:20.563889+07
P-126	Engsel	Engsel Lemari Tipis 3 Inch	10000	200	800	f	https://placehold.co/400x300/64748b/white?text=Engsel+Lemari+3in	2026-04-19 17:50:20.563889+07	2026-04-19 17:50:20.563889+07
P-127	Engsel	Engsel Lemari Tipis 2.5 Inch	8000	200	750	f	https://placehold.co/400x300/64748b/white?text=Engsel+Lemari+2.5in	2026-04-19 17:50:20.564413+07	2026-04-19 17:50:20.564413+07
P-128	Engsel	Engsel Lemari Tipis 2 Inch	7000	250	900	f	https://placehold.co/400x300/64748b/white?text=Engsel+Lemari+2in	2026-04-19 17:50:20.564932+07	2026-04-19 17:50:20.564932+07
P-129	Keramik & Granite	Keramik Lantai 40x40 cm	55000	200	1200	t	https://placehold.co/400x300/0f172a/white?text=Keramik+40x40	2026-04-19 17:50:20.565442+07	2026-04-19 17:50:20.565442+07
P-130	Keramik & Granite	Keramik Lantai 50x50 cm	65000	180	1000	t	https://placehold.co/400x300/0f172a/white?text=Keramik+50x50	2026-04-19 17:50:20.565442+07	2026-04-19 17:50:20.565442+07
P-131	Keramik & Granite	Keramik Lantai 60x60 cm	135000	100	600	t	https://placehold.co/400x300/0f172a/white?text=Keramik+60x60	2026-04-19 17:50:20.56597+07	2026-04-19 17:50:20.56597+07
P-132	Keramik & Granite	Keramik Dinding 25x40 cm	65000	150	800	t	https://placehold.co/400x300/0f172a/white?text=Keramik+25x40	2026-04-19 17:50:20.56649+07	2026-04-19 17:50:20.56649+07
P-133	Keramik & Granite	Keramik Dinding 25x50 cm	75000	130	700	t	https://placehold.co/400x300/0f172a/white?text=Keramik+25x50	2026-04-19 17:50:20.56649+07	2026-04-19 17:50:20.56649+07
P-134	Keramik & Granite	Keramik Dinding 30x60 cm	90000	100	500	t	https://placehold.co/400x300/0f172a/white?text=Keramik+30x60	2026-04-19 17:50:20.56701+07	2026-04-19 17:50:20.56701+07
P-135	Keramik & Granite	Granite Polos 60x60 cm	145000	80	400	t	https://placehold.co/400x300/0f172a/white?text=Granite+Polos	2026-04-19 17:50:20.567531+07	2026-04-19 17:50:20.567531+07
P-136	Keramik & Granite	Granite Motif 60x60 cm	165000	70	350	t	https://placehold.co/400x300/0f172a/white?text=Granite+Motif	2026-04-19 17:50:20.567531+07	2026-04-19 17:50:20.567531+07
P-137	Keramik & Granite	Granite Warna Gelap 60x60 cm	255000	50	200	t	https://placehold.co/400x300/0f172a/white?text=Granite+Gelap	2026-04-19 17:50:20.568056+07	2026-04-19 17:50:20.568056+07
P-088	Tools	Meteran Tukang 3 m	25000	199	1501	f	https://placehold.co/400x300/059669/white?text=Meteran+3m	2026-04-19 17:50:20.548836+07	2026-04-19 18:18:45.881017+07
P-021	Plumbing	Pipa Maspion 5/8 C	9000	299	1501	f	https://placehold.co/400x300/0284c7/white?text=Maspion+5/8+C	2026-04-19 17:50:20.516233+07	2026-04-19 18:18:45.931459+07
P-103	Kuas Cat	Kuas Eterna 2 Inch	12000	249	1601	f	https://placehold.co/400x300/e11d48/white?text=Kuas+2in	2026-04-19 17:50:20.553689+07	2026-04-22 08:43:04.533048+07
P-100	Electrical	Lampu Philips LED 13 Watt	49500	199	1801	f	https://placehold.co/400x300/d97706/white?text=Philips+13W	2026-04-19 17:50:20.552633+07	2026-04-22 09:05:39.552974+07
P-096	Electrical	Lampu Philips LED 5 Watt	25000	297	3003	f	https://placehold.co/400x300/d97706/white?text=Philips+5W	2026-04-19 17:50:20.551586+07	2026-04-22 12:40:33.464006+07
P-097	Electrical	Lampu Philips LED 7 Watt	29000	298	2802	f	https://placehold.co/400x300/d97706/white?text=Philips+7W	2026-04-19 17:50:20.551586+07	2026-04-21 14:45:56.779058+07
\.


--
-- Data for Name: shippings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shippings (id, order_id, shipping_method_id, shipping_method_name, tracking_number, shipping_cost, destination_address, created_at, updated_at) FROM stdin;
1	ORD-260422-626	0	Kurir Toko Sinar Abadi	082331339736	50000	Kabupaten Malang	2026-04-22 08:43:04.548759+07	2026-04-22 08:43:04.548759+07
2	ORD-260422-739	0	Kurir Toko Sinar Abadi	08231339737	50000	Calvin Alexander  Sucipto, Ijen Nirwana (Patokan: Ijen Nirwana dekat hotel ijen suites), Kec. Klojen, Kota Malang, Jawa Timur, Indonesia 65116	2026-04-22 09:05:39.564219+07	2026-04-22 09:05:39.564219+07
3	ORD-260422-842	0	Ambil di Toko	082331339737	0	Ambil Di Toko Sinar Abadi Dampit, Malang (+62 8123388670)	2026-04-22 12:40:33.47775+07	2026-04-22 12:40:33.47775+07
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, password, role, name, is_blocked, created_at, updated_at) FROM stdin;
1	budi	$2a$10$.XBjXcHNOQtUAE5S8sKyAO4EHrMIZ.W0TfWxHaU8nhkqkzX3hhkMu	customer	Budi Santoso	f	2026-04-19 17:50:20.496256+07	2026-04-19 17:50:20.496256+07
2	admin	$2a$10$Id5AM.ZlUe8q7T1MjdmOTeSez8xwMlEfTVpTPgh.qAXNEuk142cky	admin	Admin Operasional	f	2026-04-19 17:50:20.499143+07	2026-04-19 17:50:20.499143+07
3	owner	$2a$10$wdlUpNkXNMDxPIpt48sMSO1eoLk29Wt/Hmcy5vd3omwGMsmbs4JB.	owner	Dewan Direksi	f	2026-04-19 17:50:20.502466+07	2026-04-19 17:50:20.502466+07
4	Calvin3c	$2a$10$B6VPEqEP58NbR1xNoBXTLOeMxaTAo9d2Cyx8vjYT6FSekpvpYBr8W	customer	Calvin3c	f	2026-04-19 18:17:05.228031+07	2026-04-19 18:17:05.228031+07
5	budi123	$2a$10$MH8iJPy0kyxsxBVqYAbXMO/JMwSyy4tfKuA2P9x8837sEnPtRaAnC	customer	Budi Santoso	f	2026-04-21 14:51:47.903886+07	2026-04-21 14:51:47.903886+07
6	Chris3c	$2a$10$6EmKnUXuX5idpfhjN9e6zOY1BVkXmqCOU73oe0oOzQ9nnjoAFLZTm	customer	Christian Anthony Sucipto	f	2026-04-21 14:52:56.608042+07	2026-04-21 14:52:56.608042+07
7	Cathlen3c	$2a$10$nXGFmJR0IrHilkU7.rIGBOVmPu81ENnzupGm16HbDKQRDWcX1Igha	customer	Cathlen Gabriela	f	2026-04-21 14:55:56.186017+07	2026-04-21 14:55:56.186017+07
\.


--
-- Name: order_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_items_id_seq', 12, true);


--
-- Name: payment_methods_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payment_methods_id_seq', 1, false);


--
-- Name: payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payments_id_seq', 3, true);


--
-- Name: shippings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shippings_id_seq', 3, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 7, true);


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: payment_methods payment_methods_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_methods
    ADD CONSTRAINT payment_methods_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: shippings shippings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shippings
    ADD CONSTRAINT shippings_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_order_items_order_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_order_items_order_id ON public.order_items USING btree (order_id);


--
-- Name: idx_payments_order_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_payments_order_id ON public.payments USING btree (order_id);


--
-- Name: idx_shippings_order_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_shippings_order_id ON public.shippings USING btree (order_id);


--
-- Name: idx_users_username; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_users_username ON public.users USING btree (username);


--
-- Name: orders fk_orders_customer; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES public.users(id);


--
-- Name: order_items fk_orders_items; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT fk_orders_items FOREIGN KEY (order_id) REFERENCES public.orders(id);


--
-- Name: payments fk_orders_payment; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT fk_orders_payment FOREIGN KEY (order_id) REFERENCES public.orders(id);


--
-- Name: shippings fk_orders_shipping; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shippings
    ADD CONSTRAINT fk_orders_shipping FOREIGN KEY (order_id) REFERENCES public.orders(id);


--
-- PostgreSQL database dump complete
--

\unrestrict r2MwwQidLbhC0gVkkufZL8bMdIPSzaBs1uUGc7DBeEykTmfpZUervbMxG0HKPk0

