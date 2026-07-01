--
-- PostgreSQL database dump
--

\restrict 5SMgr5JoejPk5aR1NcwEfgluqtQP4y5UKn3KhCekBRGCZjldEXcyeVKEnv1Etvp

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
-- Name: admins; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admins (
    id bigint NOT NULL,
    username character varying(100) NOT NULL,
    password text NOT NULL,
    name character varying(200) NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email character varying(200),
    phone character varying(50)
);


ALTER TABLE public.admins OWNER TO postgres;

--
-- Name: admins_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.admins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.admins_id_seq OWNER TO postgres;

--
-- Name: admins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.admins_id_seq OWNED BY public.admins.id;


--
-- Name: customer_addresses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customer_addresses (
    id bigint NOT NULL,
    customer_id bigint NOT NULL,
    label character varying(100) NOT NULL,
    recipient_name character varying(200) NOT NULL,
    phone_number character varying(50) NOT NULL,
    city character varying(200),
    full_address text NOT NULL,
    notes character varying(200),
    postal_code character varying(20),
    biteship_area_id character varying(100),
    is_primary boolean DEFAULT false,
    pinpoint boolean DEFAULT false,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.customer_addresses OWNER TO postgres;

--
-- Name: customer_addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.customer_addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.customer_addresses_id_seq OWNER TO postgres;

--
-- Name: customer_addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.customer_addresses_id_seq OWNED BY public.customer_addresses.id;


--
-- Name: customers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customers (
    id bigint NOT NULL,
    username character varying(100) NOT NULL,
    password text NOT NULL,
    name character varying(200) NOT NULL,
    phone character varying(50),
    email character varying(200),
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.customers OWNER TO postgres;

--
-- Name: customers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.customers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.customers_id_seq OWNER TO postgres;

--
-- Name: customers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.customers_id_seq OWNED BY public.customers.id;


--
-- Name: inbound_order_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inbound_order_items (
    id bigint NOT NULL,
    inbound_order_id bigint NOT NULL,
    product_id character varying(30) NOT NULL,
    variant_id bigint,
    warehouse_id bigint NOT NULL,
    qty bigint NOT NULL,
    unit_cost bigint NOT NULL,
    subtotal bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.inbound_order_items OWNER TO postgres;

--
-- Name: inbound_order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.inbound_order_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.inbound_order_items_id_seq OWNER TO postgres;

--
-- Name: inbound_order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.inbound_order_items_id_seq OWNED BY public.inbound_order_items.id;


--
-- Name: inbound_orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inbound_orders (
    id bigint NOT NULL,
    supplier_name character varying(100) NOT NULL,
    expected_date timestamp with time zone,
    total_cost bigint DEFAULT 0 NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    admin_id bigint,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.inbound_orders OWNER TO postgres;

--
-- Name: inbound_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.inbound_orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.inbound_orders_id_seq OWNER TO postgres;

--
-- Name: inbound_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.inbound_orders_id_seq OWNED BY public.inbound_orders.id;


--
-- Name: order_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_items (
    id bigint NOT NULL,
    order_id character varying(30) NOT NULL,
    product_id character varying(20),
    name character varying(300) NOT NULL,
    qty bigint NOT NULL,
    price bigint NOT NULL,
    color character varying(100),
    weight bigint DEFAULT 0,
    length bigint DEFAULT 1,
    width bigint DEFAULT 1,
    height bigint DEFAULT 1,
    variant_id bigint,
    warehouse_id bigint DEFAULT 1 NOT NULL
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
    proof_url text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: owners; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.owners (
    id bigint NOT NULL,
    username character varying(100) NOT NULL,
    password text NOT NULL,
    name character varying(200) NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email character varying(200),
    phone character varying(50)
);


ALTER TABLE public.owners OWNER TO postgres;

--
-- Name: owners_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.owners_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.owners_id_seq OWNER TO postgres;

--
-- Name: owners_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.owners_id_seq OWNED BY public.owners.id;


--
-- Name: payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payments (
    id bigint NOT NULL,
    order_id character varying(30) NOT NULL,
    payment_method character varying(50),
    amount_paid bigint NOT NULL,
    payment_status character varying(20) DEFAULT 'Pending'::character varying NOT NULL,
    paid_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    snap_token character varying(255),
    midtrans_trans_id character varying(100)
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
-- Name: product_variants; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_variants (
    id bigint NOT NULL,
    product_id character varying(20) NOT NULL,
    name character varying(100) NOT NULL,
    price bigint DEFAULT 0 NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.product_variants OWNER TO postgres;

--
-- Name: product_variants_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.product_variants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.product_variants_id_seq OWNER TO postgres;

--
-- Name: product_variants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.product_variants_id_seq OWNED BY public.product_variants.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    id character varying(20) NOT NULL,
    category character varying(100) NOT NULL,
    name character varying(300) NOT NULL,
    price bigint NOT NULL,
    sold bigint DEFAULT 0 NOT NULL,
    is_large boolean DEFAULT false,
    image_url character varying(500),
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    brand character varying(100),
    weight bigint DEFAULT 0,
    unit character varying(50),
    min_purchase bigint DEFAULT 1,
    length bigint DEFAULT 1,
    width bigint DEFAULT 1,
    height bigint DEFAULT 1
);


ALTER TABLE public.products OWNER TO postgres;

--
-- Name: shippings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shippings (
    id bigint NOT NULL,
    order_id character varying(30) NOT NULL,
    shipping_method_name character varying(100) NOT NULL,
    tracking_number character varying(30),
    shipping_cost bigint DEFAULT 0 NOT NULL,
    destination_address text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    biteship_area_id text,
    biteship_order_id character varying(100),
    waybill_id character varying(100),
    courier_company character varying(50),
    courier_type character varying(50),
    courier_code character varying(50),
    courier_service_code character varying(50),
    admin_id bigint,
    shipping_method_id bigint
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
-- Name: stock_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stock_logs (
    id bigint NOT NULL,
    product_id character varying(20) NOT NULL,
    owner_id bigint,
    change_type character varying(20) NOT NULL,
    qty_changed bigint NOT NULL,
    final_stock bigint NOT NULL,
    description text,
    created_at timestamp with time zone,
    warehouse_id bigint DEFAULT 1 NOT NULL,
    variant_id bigint
);


ALTER TABLE public.stock_logs OWNER TO postgres;

--
-- Name: stock_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.stock_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.stock_logs_id_seq OWNER TO postgres;

--
-- Name: stock_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.stock_logs_id_seq OWNED BY public.stock_logs.id;


--
-- Name: warehouse_stocks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.warehouse_stocks (
    id bigint NOT NULL,
    product_id character varying(20) NOT NULL,
    variant_id bigint,
    warehouse_id bigint NOT NULL,
    stock bigint DEFAULT 0
);


ALTER TABLE public.warehouse_stocks OWNER TO postgres;

--
-- Name: warehouse_stocks_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.warehouse_stocks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.warehouse_stocks_id_seq OWNER TO postgres;

--
-- Name: warehouse_stocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.warehouse_stocks_id_seq OWNED BY public.warehouse_stocks.id;


--
-- Name: warehouses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.warehouses (
    id bigint NOT NULL,
    name character varying(100) NOT NULL,
    description character varying(255),
    is_active boolean DEFAULT true,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.warehouses OWNER TO postgres;

--
-- Name: warehouses_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.warehouses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.warehouses_id_seq OWNER TO postgres;

--
-- Name: warehouses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.warehouses_id_seq OWNED BY public.warehouses.id;


--
-- Name: admins id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admins ALTER COLUMN id SET DEFAULT nextval('public.admins_id_seq'::regclass);


--
-- Name: customer_addresses id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_addresses ALTER COLUMN id SET DEFAULT nextval('public.customer_addresses_id_seq'::regclass);


--
-- Name: customers id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers ALTER COLUMN id SET DEFAULT nextval('public.customers_id_seq'::regclass);


--
-- Name: inbound_order_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inbound_order_items ALTER COLUMN id SET DEFAULT nextval('public.inbound_order_items_id_seq'::regclass);


--
-- Name: inbound_orders id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inbound_orders ALTER COLUMN id SET DEFAULT nextval('public.inbound_orders_id_seq'::regclass);


--
-- Name: order_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items ALTER COLUMN id SET DEFAULT nextval('public.order_items_id_seq'::regclass);


--
-- Name: owners id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.owners ALTER COLUMN id SET DEFAULT nextval('public.owners_id_seq'::regclass);


--
-- Name: payments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments ALTER COLUMN id SET DEFAULT nextval('public.payments_id_seq'::regclass);


--
-- Name: product_variants id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_variants ALTER COLUMN id SET DEFAULT nextval('public.product_variants_id_seq'::regclass);


--
-- Name: shippings id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shippings ALTER COLUMN id SET DEFAULT nextval('public.shippings_id_seq'::regclass);


--
-- Name: stock_logs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_logs ALTER COLUMN id SET DEFAULT nextval('public.stock_logs_id_seq'::regclass);


--
-- Name: warehouse_stocks id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouse_stocks ALTER COLUMN id SET DEFAULT nextval('public.warehouse_stocks_id_seq'::regclass);


--
-- Name: warehouses id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouses ALTER COLUMN id SET DEFAULT nextval('public.warehouses_id_seq'::regclass);


--
-- Data for Name: admins; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.admins VALUES (2, 'admin', '$2a$10$E7xlA4IsXdqB1EHV.JsWGOSyc0xpkNGpmMXG6viymdvbF6nimeVRi', 'Admin Operasional', '2026-06-14 15:31:36.198198+07', '2026-06-14 15:31:36.198198+07', 'admin123@gmail.com', '');


--
-- Data for Name: customer_addresses; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.customer_addresses VALUES (1, 1, 'Kantor Sinar Abadi', 'Budi Santoso', '08123456789', 'Lowokwaru, Kota Malang, Jawa Timur', 'Jl. Letjen Sutoyo No. 12, Lowokwaru, Malang, Jawa Timur 65141', '', '65141', 'IDNP11IDNC250IDND2612IDZ65141', true, false, '2026-06-05 15:25:01.845476+07', '2026-06-05 15:25:01.845476+07');
INSERT INTO public.customer_addresses VALUES (3, 3, 'Rumah', 'Christian Anthony Sucipto', '+6282132148698', 'Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'Perumahan Ijen Nirwana Blok C3 no 11', 'Lewat jalan langsep', '65116', 'IDNP11IDNC250IDND2615IDZ65116', true, false, '2026-06-05 16:34:39.883664+07', '2026-06-05 16:34:39.883664+07');
INSERT INTO public.customer_addresses VALUES (2, 2, 'Rumah ', 'Calvin Alexander Sucipto', '082331339737', 'Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'Perumahan ijen nirwana cluster green river blokc3 no 11', 'Lewat jalan langsep', '65116', 'IDNP11IDNC250IDND2615IDZ65116', true, false, '2026-06-05 15:43:08.718819+07', '2026-06-05 23:05:09.757383+07');
INSERT INTO public.customer_addresses VALUES (4, 5, 'jalan rumah', 'Yohanes', '+62822328829292', 'Blimbing, Malang, Jawa Timur. 65121, Malang, Jawa Timur', 'jalan rumah', '', '65121', 'IDNP11IDNC250IDND2602IDZ65121', true, false, '2026-06-10 13:39:09.991961+07', '2026-06-10 13:39:10.006115+07');
INSERT INTO public.customer_addresses VALUES (5, 6, 'Rumah', 'Metodius Valentino', '+62823345678', 'Merauke, Merauke, Papua. 99612, Merauke, Papua', 'Jalan Mandala', '', '99612', 'IDNP24IDNC277IDND2993IDZ99612', true, false, '2026-06-10 14:11:17.058647+07', '2026-06-10 14:11:17.058647+07');
INSERT INTO public.customer_addresses VALUES (6, 9, 'Rumah', 'Andy Anthony', '081234567890', 'Klojen, Malang, Jawa Timur. 65116', 'Perumahan Ijen Nirwana Blok C3 no 11', 'Lewat jalan langsep', '65116', 'IDNP11IDNC250IDND2615IDZ65116', true, false, '2026-06-13 21:09:55.645769+07', '2026-06-13 21:09:55.656414+07');
INSERT INTO public.customer_addresses VALUES (7, 4, 'Rumah', 'Cathlen Gabriela', '+628123456', 'Klojen, Malang, Jawa Timur. 65116', 'Ijen Nirwana', '-', '65116', 'IDNP11IDNC250IDND2615IDZ65116', true, false, '2026-06-14 17:40:58.896597+07', '2026-06-14 17:40:58.907872+07');


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.customers VALUES (1, 'budi', '$2a$10$m1yC.drbFSEChraGNFUz/.UOUEeE4NgxAL3FJzjfC6Lvi3j4Xx7xC', 'Budi Santoso', '', '', '2026-05-31 14:39:51.818583+07', '2026-05-31 14:39:51.818583+07');
INSERT INTO public.customers VALUES (3, 'SirChrizz', '$2a$10$UjSkY3bxhNd9da8ENuEDfOr1HTBE0xkBH5uH8hfYou9a2YuB96GZ6', 'Christian Anthony Sucipto', '+6282132148698', 'christian.anthony721@gmai.com', '2026-06-05 16:06:09.812996+07', '2026-06-05 16:06:09.812996+07');
INSERT INTO public.customers VALUES (2, 'Calvin3c', '$2a$10$AJwgZn/Qoz9jZ0sBpilSru8EMSX1x4hFBc8NCaDMskpdPsLaib1xi', 'Calvin Alexander Sucipto', '082331339737', 'calvinsucipto711@gmail.com', '2026-05-31 15:00:46.057297+07', '2026-06-06 12:16:56.02083+07');
INSERT INTO public.customers VALUES (4, 'cathlen3c', '$2a$10$ma3wKnjO8CKfyggNCI9xeeG9yhPBFSRwBmn44ll9M2c7gVq0SIvly', 'Cathlen Gabriela', '+628123456', 'cathlengabriella@gmail.com', '2026-06-08 09:14:02.52953+07', '2026-06-08 09:14:02.52953+07');
INSERT INTO public.customers VALUES (5, 'Yohanes', '$2a$10$0pkVM.xkikPzqpy8OREfe.XFt5rzxVJ7Os6h3Pr/vm5a/A6iCsl0u', 'Yohanes', '+62822328829292', 'testing@gmail.com', '2026-06-10 13:37:42.754902+07', '2026-06-10 13:37:42.754902+07');
INSERT INTO public.customers VALUES (6, 'Metodius', '$2a$10$L.AgyEmfZmYwk7ZCiCsS8OOhSnsXrCYuvGua4nW/5l2LouSUVBRoC', 'Metodius Valentino', '+62823345678', 'meto@gmail.com', '2026-06-10 14:08:31.478784+07', '2026-06-10 14:08:31.478784+07');
INSERT INTO public.customers VALUES (7, 'Andy123', '$2a$10$tMLRLjb51Kc7lvi86ppWnufWwwmyCkWdQNuQPxZkpg1IKcnV7ACES', 'Andy Sucipto', '081234567890', 'andy123@gmail.com', '2026-06-13 19:53:22.537427+07', '2026-06-13 19:53:22.537427+07');
INSERT INTO public.customers VALUES (8, 'Andy999', '$2a$10$6tr3ghXogsBoZeiN5BVUR.PQlx/kWqf8H1NR9TbKbXiapAdg3SzGm', 'Andy Anthony', '081234567890', 'andy999@gmail.com', '2026-06-13 20:01:48.49007+07', '2026-06-13 20:01:48.49007+07');
INSERT INTO public.customers VALUES (9, 'Boo123', '$2a$10$7w/DcZp7J/5L4QSCvVWo0ujzJ2HtOBNxm5hix.OeLei/ne4xfPjF.', 'Andy Anthony', '081234567890', 'andy999@gmail.com', '2026-06-13 20:02:16.912237+07', '2026-06-13 20:02:16.912237+07');


--
-- Data for Name: inbound_order_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.inbound_order_items VALUES (1, 1, 'P-002', NULL, 1, 50, 420000, 21000000, '2026-06-14 14:54:48.953336+07', '2026-06-14 14:54:48.953336+07');
INSERT INTO public.inbound_order_items VALUES (2, 2, 'P-002', NULL, 2, 30, 400000, 12000000, '2026-06-14 15:29:14.545979+07', '2026-06-14 15:29:14.545979+07');
INSERT INTO public.inbound_order_items VALUES (3, 3, 'P-001', NULL, 2, 30, 40000, 1200000, '2026-06-14 16:42:40.04+07', '2026-06-14 16:42:40.04+07');
INSERT INTO public.inbound_order_items VALUES (4, 4, 'P-001', NULL, 2, 200, 57000, 11400000, '2026-06-14 20:00:41.116447+07', '2026-06-14 20:00:41.116447+07');


--
-- Data for Name: inbound_orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.inbound_orders VALUES (1, 'Toko ABC', '2026-06-14 07:00:00+07', 21000000, 'cancelled', NULL, '2026-06-14 14:54:48.950887+07', '2026-06-14 15:01:06.29259+07');
INSERT INTO public.inbound_orders VALUES (2, 'PT Jawa', '2026-06-15 07:00:00+07', 12000000, 'received', NULL, '2026-06-14 15:29:14.54522+07', '2026-06-14 15:32:04.036594+07');
INSERT INTO public.inbound_orders VALUES (3, 'PT Jawa', '2026-06-15 07:00:00+07', 1200000, 'received', NULL, '2026-06-14 16:42:40.035376+07', '2026-06-14 17:57:42.382086+07');
INSERT INTO public.inbound_orders VALUES (4, 'PT Jawa', '2026-06-14 07:00:00+07', 11400000, 'received', NULL, '2026-06-14 20:00:41.113715+07', '2026-06-14 20:01:18.911523+07');


--
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.order_items VALUES (2, 'ORD-260402-309', 'P-001', 'Semen Gresik 40 kg', 10, 59000, NULL, 0, 1, 1, 1, NULL, 1);
INSERT INTO public.order_items VALUES (3, 'ORD-260531-793', 'P-002', 'Semen Merah Putih 40 kg', 20, 47000, NULL, 0, 1, 1, 1, NULL, 1);
INSERT INTO public.order_items VALUES (4, 'ORD-260531-793', 'P-004', 'Semen Putih Tiga Roda 40 kg', 20, 120000, NULL, 0, 1, 1, 1, NULL, 1);
INSERT INTO public.order_items VALUES (5, 'ORD-260531-325', 'P-004', 'Semen Putih Tiga Roda 40 kg', 10, 120000, NULL, 0, 1, 1, 1, NULL, 1);
INSERT INTO public.order_items VALUES (6, 'ORD-260601-785', 'P-004', 'Semen Putih Tiga Roda 40 kg', 10, 120000, NULL, 0, 1, 1, 1, NULL, 1);
INSERT INTO public.order_items VALUES (7, 'ORD-260601-785', 'P-002', 'Semen Merah Putih 40 kg', 10, 47000, NULL, 0, 1, 1, 1, NULL, 1);
INSERT INTO public.order_items VALUES (8, 'ORD-260601-741', 'P-061', 'Emco Warna Standart 1 kg', 2, 85000, NULL, 0, 1, 1, 1, NULL, 1);
INSERT INTO public.order_items VALUES (45, 'ORD-260605-558', 'P-004', 'Semen Putih Tiga Roda 40 kg', 10, 120000, '', 40000, 55, 40, 10, NULL, 1);
INSERT INTO public.order_items VALUES (12, 'ORD-260603-541', 'P-002', 'Semen Merah Putih 40 kg', 20, 47000, '', 0, 1, 1, 1, NULL, 1);
INSERT INTO public.order_items VALUES (13, 'ORD-260603-437', 'P-002', 'Semen Merah Putih 40 kg', 10, 47000, '', 0, 1, 1, 1, NULL, 1);
INSERT INTO public.order_items VALUES (15, 'ORD-260603-820', 'P-002', 'Semen Merah Putih 40 kg', 12, 47000, '', 0, 1, 1, 1, NULL, 1);
INSERT INTO public.order_items VALUES (16, 'ORD-260603-503', 'P-083', 'Mesin Bor Modern M2100', 1, 295000, '', 0, 1, 1, 1, NULL, 1);
INSERT INTO public.order_items VALUES (17, 'ORD-260603-731', 'P-004', 'Semen Putih Tiga Roda 40 kg', 10, 120000, '', 0, 1, 1, 1, NULL, 1);
INSERT INTO public.order_items VALUES (33, 'ORD-260604-871', 'P-001', 'Semen Gresik 40 kg', 10, 59000, '', 40000, 55, 40, 10, NULL, 1);
INSERT INTO public.order_items VALUES (31, 'ORD-260604-224', 'P-001', 'Semen Gresik 40 kg', 10, 59000, '', 0, 1, 1, 1, NULL, 1);
INSERT INTO public.order_items VALUES (32, 'ORD-260604-224', 'P-061', 'Emco Warna Standart 1 kg', 3, 85000, '127 Pink', 0, 1, 1, 1, NULL, 1);
INSERT INTO public.order_items VALUES (22, 'ORD-260603-210', 'P-074', 'Besi Beton 16 SNI', 3, 195000, '', 0, 1, 1, 1, NULL, 1);
INSERT INTO public.order_items VALUES (21, 'ORD-260603-849', 'P-074', 'Besi Beton 16 SNI', 4, 195000, '', 0, 1, 1, 1, NULL, 1);
INSERT INTO public.order_items VALUES (20, 'ORD-260603-480', 'P-074', 'Besi Beton 16 SNI', 3, 195000, '', 0, 1, 1, 1, NULL, 1);
INSERT INTO public.order_items VALUES (19, 'ORD-260603-300', 'P-074', 'Besi Beton 16 SNI', 5, 195000, '', 0, 1, 1, 1, NULL, 1);
INSERT INTO public.order_items VALUES (18, 'ORD-260603-256', 'P-074', 'Besi Beton 16 SNI', 5, 195000, '', 0, 1, 1, 1, NULL, 1);
INSERT INTO public.order_items VALUES (14, 'ORD-260603-153', 'P-002', 'Semen Merah Putih 40 kg', 11, 47000, '', 0, 1, 1, 1, NULL, 1);
INSERT INTO public.order_items VALUES (9, 'ORD-260603-721', 'P-002', 'Semen Merah Putih 40 kg', 20, 47000, '', 0, 1, 1, 1, NULL, 1);
INSERT INTO public.order_items VALUES (10, 'ORD-260603-721', 'P-054', 'Avitex 25 kg', 3, 775000, '601 Blue Romance', 0, 1, 1, 1, NULL, 1);
INSERT INTO public.order_items VALUES (11, 'ORD-260603-721', 'P-074', 'Besi Beton 16 SNI', 20, 195000, '', 0, 1, 1, 1, NULL, 1);
INSERT INTO public.order_items VALUES (1, 'ORD-260401-081', 'P-096', 'Lampu Philips LED 5 Watt', 2, 385000, NULL, 0, 1, 1, 1, NULL, 1);
INSERT INTO public.order_items VALUES (40, 'ORD-260604-216', 'P-021', 'Pipa Maspion 5/8 C', 10, 9000, '', 900, 400, 2, 2, NULL, 1);
INSERT INTO public.order_items VALUES (23, 'ORD-260603-971', 'P-061', 'Emco Warna Standart 1 kg', 5, 85000, '121 Cyan', 0, 1, 1, 1, NULL, 1);
INSERT INTO public.order_items VALUES (24, 'ORD-260603-941', 'P-083', 'Mesin Bor Modern M2100', 1, 295000, '', 0, 1, 1, 1, NULL, 1);
INSERT INTO public.order_items VALUES (25, 'ORD-260603-324', 'P-083', 'Mesin Bor Modern M2100', 1, 295000, '', 0, 1, 1, 1, NULL, 1);
INSERT INTO public.order_items VALUES (44, 'ORD-260605-629', 'P-004', 'Semen Putih Tiga Roda 40 kg', 10, 120000, '', 40000, 55, 40, 10, NULL, 1);
INSERT INTO public.order_items VALUES (34, 'ORD-260604-204', 'P-001', 'Semen Gresik 40 kg', 10, 59000, '', 40000, 55, 40, 10, NULL, 1);
INSERT INTO public.order_items VALUES (26, 'ORD-260603-526', 'P-083', 'Mesin Bor Modern M2100', 1, 295000, '', 0, 1, 1, 1, NULL, 1);
INSERT INTO public.order_items VALUES (27, 'ORD-260603-391', 'P-101', 'Kuas Eterna 1 Inch', 10, 7000, '', 0, 1, 1, 1, NULL, 1);
INSERT INTO public.order_items VALUES (28, 'ORD-260603-629', 'P-061', 'Emco Warna Standart 1 kg', 1, 85000, '48 Cream', 0, 1, 1, 1, NULL, 1);
INSERT INTO public.order_items VALUES (29, 'ORD-260603-818', 'P-001', 'Semen Gresik 40 kg', 10, 59000, '', 0, 1, 1, 1, NULL, 1);
INSERT INTO public.order_items VALUES (35, 'ORD-260604-204', 'P-074', 'Besi Beton 16 SNI', 5, 195000, '', 18960, 1200, 2, 2, NULL, 1);
INSERT INTO public.order_items VALUES (30, 'ORD-260603-817', 'P-001', 'Semen Gresik 40 kg', 10, 59000, '', 0, 1, 1, 1, NULL, 1);
INSERT INTO public.order_items VALUES (41, 'ORD-260604-787', 'P-061', 'Emco Warna Standart 1 kg', 3, 85000, '111 Bata', 1000, 12, 12, 13, NULL, 1);
INSERT INTO public.order_items VALUES (42, 'ORD-260604-787', 'P-077', 'Kloset Jongkok Duty', 1, 225000, 'Merah Maroon', 25000, 50, 40, 25, NULL, 1);
INSERT INTO public.order_items VALUES (36, 'ORD-260604-705', 'P-101', 'Kuas Eterna 1 Inch', 10, 7000, '', 60, 18, 3, 1, NULL, 1);
INSERT INTO public.order_items VALUES (37, 'ORD-260604-795', 'P-101', 'Kuas Eterna 1 Inch', 10, 7000, '', 60, 18, 3, 1, NULL, 1);
INSERT INTO public.order_items VALUES (46, 'ORD-260605-444', 'P-001', 'Semen Gresik 40 kg', 10, 59000, '', 40000, 55, 40, 10, NULL, 1);
INSERT INTO public.order_items VALUES (38, 'ORD-260604-969', 'P-101', 'Kuas Eterna 1 Inch', 10, 7000, '', 60, 18, 3, 1, NULL, 1);
INSERT INTO public.order_items VALUES (43, 'ORD-260605-340', 'P-002', 'Semen Merah Putih 40 kg', 10, 47000, '', 40000, 55, 40, 10, NULL, 1);
INSERT INTO public.order_items VALUES (39, 'ORD-260604-507', 'P-004', 'Semen Putih Tiga Roda 40 kg', 10, 120000, '', 40000, 55, 40, 10, NULL, 1);
INSERT INTO public.order_items VALUES (50, 'ORD-260605-279', 'P-083', 'Mesin Bor Modern M2100', 1, 295000, '', 1300, 25, 22, 7, NULL, 1);
INSERT INTO public.order_items VALUES (47, 'ORD-260605-505', 'P-001', 'Semen Gresik 40 kg', 10, 59000, '', 40000, 55, 40, 10, NULL, 1);
INSERT INTO public.order_items VALUES (53, 'ORD-260606-964', 'P-106', 'Kuas Eterna 4 Inch', 10, 25000, '', 80, 23, 10, 2, NULL, 1);
INSERT INTO public.order_items VALUES (48, 'ORD-260605-636', 'P-083', 'Mesin Bor Modern M2100', 1, 295000, '', 1300, 25, 22, 7, NULL, 1);
INSERT INTO public.order_items VALUES (51, 'ORD-260605-300', 'P-102', 'Kuas Eterna 1.5 Inch', 10, 10000, '', 60, 19, 4, 1, NULL, 1);
INSERT INTO public.order_items VALUES (49, 'ORD-260605-729', 'P-083', 'Mesin Bor Modern M2100', 1, 295000, '', 1300, 25, 22, 7, NULL, 1);
INSERT INTO public.order_items VALUES (52, 'ORD-260605-128', 'P-102', 'Kuas Eterna 1.5 Inch', 1, 10000, '', 60, 19, 4, 1, NULL, 1);
INSERT INTO public.order_items VALUES (55, 'ORD-260606-731', 'P-061', 'Emco Warna Standart 1 kg', 5, 85000, '48 Kuning Krem', 1000, 12, 12, 13, NULL, 1);
INSERT INTO public.order_items VALUES (54, 'ORD-260606-149', 'P-069', 'Besi Beton 6 SNI', 10, 28000, '', 2660, 1200, 1, 1, NULL, 1);
INSERT INTO public.order_items VALUES (59, 'ORD-260606-680', 'P-101', 'Kuas Eterna 1 Inch', 11, 7000, '', 60, 18, 3, 1, NULL, 1);
INSERT INTO public.order_items VALUES (60, 'ORD-260606-995', 'P-003', 'Semen Singa Merah 40 kg', 10, 45000, '', 40000, 55, 40, 10, NULL, 1);
INSERT INTO public.order_items VALUES (61, 'ORD-260608-999', 'P-054', 'Avitex 25 kg', 1, 775000, '651 Carnation Pink', 25000, 32, 32, 38, NULL, 1);
INSERT INTO public.order_items VALUES (62, 'ORD-260608-999', 'P-004', 'Semen Putih Tiga Roda 40 kg', 11, 120000, '', 40000, 55, 40, 10, NULL, 1);
INSERT INTO public.order_items VALUES (63, 'ORD-260608-999', 'P-061', 'Emco Warna Standart 1 kg', 5, 85000, '48 Kuning Krem', 1000, 12, 12, 13, NULL, 1);
INSERT INTO public.order_items VALUES (65, 'ORD-260610-883', 'P-001', 'Semen Gresik 40 kg', 10, 59000, '', 40000, 55, 40, 10, NULL, 1);
INSERT INTO public.order_items VALUES (67, 'ORD-260610-330', 'P-003', 'Semen Singa Merah 40 kg', 10, 45000, '', 40000, 55, 40, 10, NULL, 1);
INSERT INTO public.order_items VALUES (68, 'ORD-260611-975', 'P-003', 'Semen Singa Merah 40 kg', 10, 45000, '', 40000, 55, 40, 10, NULL, 1);
INSERT INTO public.order_items VALUES (64, 'ORD-260610-321', 'P-061', 'Emco Warna Standart 1 kg', 5, 85000, '48 Kuning Krem', 1000, 12, 12, 13, NULL, 1);
INSERT INTO public.order_items VALUES (69, 'ORD-260611-855', 'P-003', 'Semen Singa Merah 40 kg', 10, 45000, '', 40000, 55, 40, 10, NULL, 1);
INSERT INTO public.order_items VALUES (70, 'ORD-260611-298', 'P-003', 'Semen Singa Merah 40 kg', 10, 45000, '', 40000, 55, 40, 10, NULL, 1);
INSERT INTO public.order_items VALUES (71, 'ORD-260611-681', 'P-101', 'Kuas Eterna 1 Inch', 1, 7000, '', 60, 18, 3, 1, NULL, 1);
INSERT INTO public.order_items VALUES (72, 'ORD-260611-815', 'P-101', 'Kuas Eterna 1 Inch', 1, 7000, '', 60, 18, 3, 1, NULL, 1);
INSERT INTO public.order_items VALUES (73, 'ORD-260611-735', 'P-101', 'Kuas Eterna 1 Inch', 1, 7000, '', 60, 18, 3, 1, NULL, 1);
INSERT INTO public.order_items VALUES (74, 'ORD-260611-740', 'P-101', 'Kuas Eterna 1 Inch', 1, 7000, '', 60, 18, 3, 1, NULL, 1);
INSERT INTO public.order_items VALUES (75, 'ORD-260611-474', 'P-101', 'Kuas Eterna 1 Inch', 1, 7000, '', 60, 18, 3, 1, NULL, 1);
INSERT INTO public.order_items VALUES (76, 'ORD-260611-253', 'P-101', 'Kuas Eterna 1 Inch', 1, 7000, '', 60, 18, 3, 1, NULL, 1);
INSERT INTO public.order_items VALUES (77, 'ORD-260611-824', 'P-101', 'Kuas Eterna 1 Inch', 1, 7000, '', 60, 18, 3, 1, NULL, 1);
INSERT INTO public.order_items VALUES (78, 'ORD-260611-870', 'P-101', 'Kuas Eterna 1 Inch', 1, 7000, '', 60, 18, 3, 1, NULL, 1);
INSERT INTO public.order_items VALUES (79, 'ORD-260611-305', 'P-101', 'Kuas Eterna 1 Inch', 1, 7000, '', 60, 18, 3, 1, NULL, 1);
INSERT INTO public.order_items VALUES (80, 'ORD-260611-457', 'P-101', 'Kuas Eterna 1 Inch', 1, 7000, '', 60, 18, 3, 1, NULL, 1);
INSERT INTO public.order_items VALUES (81, 'ORD-260611-487', 'P-101', 'Kuas Eterna 1 Inch', 1, 7000, '', 60, 18, 3, 1, NULL, 1);
INSERT INTO public.order_items VALUES (82, 'ORD-260611-311', 'P-101', 'Kuas Eterna 1 Inch', 1, 7000, '', 60, 18, 3, 1, NULL, 1);
INSERT INTO public.order_items VALUES (83, 'ORD-260611-359', 'P-101', 'Kuas Eterna 1 Inch', 1, 7000, '', 60, 18, 3, 1, NULL, 1);
INSERT INTO public.order_items VALUES (84, 'ORD-260611-761', 'P-101', 'Kuas Eterna 1 Inch', 1, 7000, '', 60, 18, 3, 1, NULL, 1);
INSERT INTO public.order_items VALUES (85, 'ORD-260611-708', 'P-101', 'Kuas Eterna 1 Inch', 5, 7000, '', 60, 18, 3, 1, NULL, 1);
INSERT INTO public.order_items VALUES (86, 'ORD-260611-353', 'P-101', 'Kuas Eterna 1 Inch', 1, 7000, '', 60, 18, 3, 1, NULL, 1);
INSERT INTO public.order_items VALUES (87, 'ORD-260611-973', 'P-101', 'Kuas Eterna 1 Inch', 1, 7000, '', 60, 18, 3, 1, NULL, 1);
INSERT INTO public.order_items VALUES (88, 'ORD-260611-780', 'P-102', 'Kuas Eterna 1.5 Inch', 1, 10000, '', 60, 19, 4, 1, NULL, 1);
INSERT INTO public.order_items VALUES (89, 'ORD-260611-590', 'P-102', 'Kuas Eterna 1.5 Inch', 1, 10000, '', 60, 19, 4, 1, NULL, 1);
INSERT INTO public.order_items VALUES (90, 'ORD-260611-399', 'P-102', 'Kuas Eterna 1.5 Inch', 1, 10000, '', 60, 19, 4, 1, NULL, 1);
INSERT INTO public.order_items VALUES (91, 'ORD-260613-471', 'P-001', 'Semen Gresik 40 kg', 10, 59000, '', 40000, 55, 40, 10, NULL, 1);
INSERT INTO public.order_items VALUES (92, 'ORD-260613-517', 'P-102', 'Kuas Eterna 1.5 Inch', 5, 10000, '', 60, 19, 4, 1, NULL, 1);
INSERT INTO public.order_items VALUES (93, 'ORD-260613-517', 'P-061', 'Emco Warna Standart 1 kg', 1, 85000, '54 Merah Muda Pucat', 1000, 12, 12, 13, NULL, 1);
INSERT INTO public.order_items VALUES (97, 'ORD-260613-221', 'P-102', 'Kuas Eterna 1.5 Inch', 5, 10000, '', 60, 19, 4, 1, NULL, 1);
INSERT INTO public.order_items VALUES (98, 'ORD-260613-221', 'P-061', 'Emco Warna Standart 1 kg', 1, 85000, '54 Merah Muda Pucat', 1000, 12, 12, 13, NULL, 1);
INSERT INTO public.order_items VALUES (101, 'ORD-260614-130', 'P-002', 'Semen Merah Putih 40 kg', 10, 47000, '', 40000, 55, 40, 10, NULL, 2);
INSERT INTO public.order_items VALUES (94, 'ORD-260613-888', 'P-102', 'Kuas Eterna 1.5 Inch', 5, 10000, '', 60, 19, 4, 1, NULL, 1);
INSERT INTO public.order_items VALUES (95, 'ORD-260613-888', 'P-061', 'Emco Warna Standart 1 kg', 1, 85000, '54 Merah Muda Pucat', 1000, 12, 12, 13, NULL, 1);
INSERT INTO public.order_items VALUES (96, 'ORD-260613-832', 'P-102', 'Kuas Eterna 1.5 Inch', 10, 10000, '', 60, 19, 4, 1, NULL, 1);
INSERT INTO public.order_items VALUES (100, 'ORD-260614-699', 'P-002', 'Semen Merah Putih 40 kg', 10, 47000, '', 40000, 55, 40, 10, NULL, 2);
INSERT INTO public.order_items VALUES (99, 'ORD-260613-153', 'P-068', 'Avian 0.5 kg', 3, 47500, '', 500, 10, 10, 10, NULL, 1);
INSERT INTO public.order_items VALUES (102, 'ORD-260614-268', 'P-128', 'Engsel Lemari Tipis 2 Inch', 10, 7000, '', 100, 5, 4, 1, NULL, 1);
INSERT INTO public.order_items VALUES (103, 'ORD-260614-231', 'P-128', 'Engsel Lemari Tipis 2 Inch', 5, 7000, '', 100, 5, 4, 1, NULL, 1);
INSERT INTO public.order_items VALUES (104, 'ORD-260614-564', 'P-128', 'Engsel Lemari Tipis 2 Inch', 5, 7000, '', 100, 5, 4, 1, NULL, 1);


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.orders VALUES ('ORD-260603-256', '2026-06-03', 2, 'Calvin3c', '082331339737', 'Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE JNE Trucking', 1127250, 'cancelled', 'Menunggu Validasi', true, 'http://localhost:8000/storage/proofs/kh5xVV1z1JUlSYZzMygrGswQiGmgnc1Nboc2h0lz.png', '2026-06-03 18:02:28.556039+07', '2026-06-03 19:01:58.58911+07');
INSERT INTO public.orders VALUES ('ORD-260603-731', '2026-06-03', 2, 'Calvin3c', '082331339737', 'Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'Kurir Toko Sinar Abadi', 1332000, 'COMPLETED', 'Menunggu Validasi', true, 'http://localhost:8000/storage/proofs/8p1cueNCemjPqpSITOhvd3c1chkTYbAEtJwasVHO.png', '2026-06-03 14:34:02.584205+07', '2026-06-03 14:37:16.6184+07');
INSERT INTO public.orders VALUES ('ORD-260402-309', '2026-04-02', 1, 'budi', '081234567890', 'Toko Sinar Abadi', 'Ambil di Toko', 721500, 'cancelled', 'Menunggu Validasi', true, '', '2026-05-31 14:39:52.139977+07', '2026-05-31 19:46:15.927171+07');
INSERT INTO public.orders VALUES ('ORD-260603-541', '2026-06-03', 2, 'Calvin3c', '082331339737', 'Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE JNE Trucking', 2243400, 'COMPLETED', 'Kurir Sedang Dijadwalkan', true, 'http://localhost:8000/storage/proofs/zmQaYDcxFnWtRZV4wX0AkRDJ2CgcIkC80ryzkU6y.png', '2026-06-03 12:56:55.369639+07', '2026-06-03 13:55:17.727033+07');
INSERT INTO public.orders VALUES ('ORD-260531-793', '2026-05-31', 2, 'Calvin3c', '+62 8123388670', 'Jalan Utara Masjid No.9, Dampit Wetan, Dampit, Kec. Dampit, Kabupaten Malang, Jawa Timur 65181', 'Ambil Di Toko', 3707400, 'COMPLETED', 'Menunggu Validasi', true, 'http://localhost:8000/storage/proofs/xeCf0ZIuEMma9CIGJCQ66zuuFHshuNHeRpgbjHc5.png', '2026-05-31 20:15:04.110778+07', '2026-05-31 20:29:26.625628+07');
INSERT INTO public.orders VALUES ('ORD-260531-325', '2026-05-31', 2, 'Calvin3c', '+62 8123388670', 'Jalan Utara Masjid No.9, Dampit Wetan, Dampit, Kec. Dampit, Kabupaten Malang, Jawa Timur 65181', 'Ambil Di Toko', 1332000, 'pending', 'Menunggu Validasi', true, 'http://localhost:8000/storage/proofs/UBpgQhjvcixtsQzszkLfRQC7sPSMJ1Z3QXRWidtw.jpg', '2026-05-31 21:02:38.606347+07', '2026-05-31 21:02:38.63735+07');
INSERT INTO public.orders VALUES ('ORD-260603-820', '2026-06-03', 2, 'Calvin3c', '082331339737', 'Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE JNE Trucking', 1346040, 'COMPLETED', 'Kurir Sedang Dijadwalkan', true, 'http://localhost:8000/storage/proofs/qhrnNT8L7hMCJ9GBkeh89O2IykoYJLTnjzpY3xgz.png', '2026-06-03 14:12:25.638876+07', '2026-06-03 14:20:32.656989+07');
INSERT INTO public.orders VALUES ('ORD-260601-785', '2026-06-01', 2, 'Calvin3c', '082331339737', 'Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Kec.Klojen, Kota Malang', 'Kurir Toko Sinar Abadi', 1903700, 'COMPLETED', 'Menunggu Validasi', true, 'http://localhost:8000/storage/proofs/GzNAWF9L87efBOTH1bATT1x5Ig2X9oyFaZwjjATc.png', '2026-06-01 19:38:17.393072+07', '2026-06-01 19:41:01.158241+07');
INSERT INTO public.orders VALUES ('ORD-260601-741', '2026-06-01', 2, 'Calvin3c', '082331339737', 'Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Kec.Klojen, Kota Malang', 'Kurir Toko Sinar Abadi', 238700, 'pending', 'Menunggu Validasi', true, 'http://localhost:8000/storage/proofs/Q5yg5fjel3k6uzDmBVMV2FKR1Z4nH2ylRAjwENnn.png', '2026-06-01 19:43:12.074783+07', '2026-06-01 19:43:12.111391+07');
INSERT INTO public.orders VALUES ('ORD-260603-437', '2026-06-03', 2, 'Calvin3c', '082331339737', 'Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'Kurir Toko Sinar Abadi', 521700, 'COMPLETED', 'Menunggu Validasi', true, 'http://localhost:8000/storage/proofs/uQ8KoF4yZAVZ074Tbw9BTJu8rA88kZIqsdGgdDdj.png', '2026-06-03 13:56:18.757021+07', '2026-06-03 13:57:48.554728+07');
INSERT INTO public.orders VALUES ('ORD-260401-081', '2026-04-01', 1, 'budi', '081234567890', 'Jl. Merdeka, Malang', 'Kurir Toko Sinar Abadi', 854700, 'cancelled', 'Selesai', true, '', '2026-05-31 14:39:52.136779+07', '2026-06-03 19:04:13.819173+07');
INSERT INTO public.orders VALUES ('ORD-260603-849', '2026-06-03', 2, 'Calvin3c', '082331339737', 'Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE JNE Trucking', 1105800, 'cancelled', 'Kurir Sedang Dijadwalkan', true, 'http://localhost:8000/storage/proofs/SZ7s7lT1nwf9T7pzxuA0J4cohiMrZORsyz44NeUg.png', '2026-06-03 18:32:25.600771+07', '2026-06-03 19:00:47.889731+07');
INSERT INTO public.orders VALUES ('ORD-260603-971', '2026-06-03', 2, 'Calvin3c', '082331339737', 'Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE JNE Trucking', 511750, 'COMPLETED', 'Kurir Sedang Dijadwalkan', true, 'http://localhost:8000/storage/proofs/lTkE5Soap4HesHJluk51LP26T6wCutLpWUSTw4wn.png', '2026-06-03 19:30:22.983726+07', '2026-06-03 20:33:21.555901+07');
INSERT INTO public.orders VALUES ('ORD-260603-503', '2026-06-03', 2, 'Calvin3c', '+62 8123388670', 'Jalan Utara Masjid No.9, Dampit Wetan, Dampit, Kec. Dampit, Kabupaten Malang, Jawa Timur 65181', 'Ambil Di Toko', 327450, 'COMPLETED', 'Menunggu Validasi', true, 'http://localhost:8000/storage/proofs/7VcClUpevFFYynYvr8tyKZodGIhjRt6WEUBEqMu5.png', '2026-06-03 14:23:00.284299+07', '2026-06-03 14:25:42.600166+07');
INSERT INTO public.orders VALUES ('ORD-260603-153', '2026-06-03', 2, 'Calvin3c', '082331339737', 'Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE', 648870, 'cancelled', 'Menunggu Validasi', true, 'http://localhost:8000/storage/proofs/3nd94ZK3GM1uXlXTzXWv7w1P9cxSM6ta9bNEq4Lj.png', '2026-06-03 14:07:54.030389+07', '2026-06-03 19:02:02.237482+07');
INSERT INTO public.orders VALUES ('ORD-260603-721', '2026-06-03', 2, 'Calvin3c', '082331339737', 'Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE JNE Trucking', 10377150, 'cancelled', 'Kurir Sedang Dijadwalkan', true, 'http://localhost:8000/storage/proofs/VnJTa1ydjT9wTOFf60t8SjXSmgDg1Duq8maWfbN3.png', '2026-06-03 12:43:09.765501+07', '2026-06-03 19:02:05.563297+07');
INSERT INTO public.orders VALUES ('ORD-260603-480', '2026-06-03', 2, 'Calvin3c', '082331339737', 'Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE JNE Trucking', 684350, 'cancelled', 'Menunggu Validasi', true, 'http://localhost:8000/storage/proofs/kUrOjwp0OhjAqwJA2gmyEd9qJgDleMUm3U9Syqs0.png', '2026-06-03 18:21:57.438075+07', '2026-06-03 19:01:54.765004+07');
INSERT INTO public.orders VALUES ('ORD-260603-300', '2026-06-03', 2, 'Calvin3c', '082331339737', 'Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE JNE Trucking', 1127250, 'cancelled', 'Menunggu Validasi', true, 'http://localhost:8000/storage/proofs/obtFex1hotjNCc0NkSmgkhz26XW1eFeyhVrsVDjc.png', '2026-06-03 18:09:36.866011+07', '2026-06-03 19:01:56.426173+07');
INSERT INTO public.orders VALUES ('ORD-260603-210', '2026-06-03', 2, 'Calvin3c', '082331339737', 'Perumahan Ijen Nirwana Cluster Green River Blok C3 No 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE JNE Trucking', 829350, 'cancelled', 'Kurir Sedang Dijadwalkan', true, 'http://localhost:8000/storage/proofs/I3qCz3Exzv7KSqG7gNgNxcx20I3bKPHuOCxAtqYr.png', '2026-06-03 18:42:25.491473+07', '2026-06-03 18:58:17.948579+07');
INSERT INTO public.orders VALUES ('ORD-260603-941', '2026-06-03', 2, 'Calvin3c', '082331339737', 'Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE Reguler', 341450, 'success', 'Kurir Sedang Dijadwalkan', true, 'http://localhost:8000/storage/proofs/UXNBmTKH1vNg5dbFJH56tvInJcOvWzgoRngX1VVB.png', '2026-06-03 20:35:00.097887+07', '2026-06-03 20:36:08.195473+07');
INSERT INTO public.orders VALUES ('ORD-260603-324', '2026-06-03', 2, 'Calvin3c', '082331339737', 'Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE JNE Trucking', 367450, 'COMPLETED', 'Kurir Sedang Dijadwalkan', true, 'http://localhost:8000/storage/proofs/qntYPJLm6lLOQkPfiwbXgF31jdBD3KRdIlwVH780.png', '2026-06-03 20:39:29.376263+07', '2026-06-03 20:43:42.263298+07');
INSERT INTO public.orders VALUES ('ORD-260604-705', '2026-06-04', 2, 'Calvin3c', '082331339737', 'Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116', 'JNE Reguler', 84700, 'cancelled', 'Kurir Sedang Dijadwalkan', true, 'http://localhost:8000/storage/proofs/qB0pxnt9JnvZ75FXGZHKq1wdD7QPg0KTrbgQ1ohh.png', '2026-06-04 20:15:41.652405+07', '2026-06-04 20:26:12.950921+07');
INSERT INTO public.orders VALUES ('ORD-260603-526', '2026-06-03', 2, 'Calvin3c', '082331339737', 'Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE', 341450, 'SHIPPING', 'Kurir Sedang Dijadwalkan', true, 'http://localhost:8000/storage/proofs/A10LyA379zWOaIopzfCVcGY6YdYJqQfibyeR9k7q.png', '2026-06-03 21:01:13.646391+07', '2026-06-03 21:08:47.805066+07');
INSERT INTO public.orders VALUES ('ORD-260603-391', '2026-06-03', 2, 'Calvin3c', '082331339737', 'Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE', 217700, 'success', 'Menunggu Validasi', true, 'http://localhost:8000/storage/proofs/pTKP2SMOl1YZEDqUHoxmL7CEtOOLsShi8SL2nfh7.png', '2026-06-03 21:22:38.207669+07', '2026-06-03 21:23:09.142237+07');
INSERT INTO public.orders VALUES ('ORD-260603-629', '2026-06-03', 2, 'Calvin3c', '082331339737', 'Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE', 134350, 'pending', 'Menunggu Validasi', true, 'http://localhost:8000/storage/proofs/B9j5w6VXT4jAGxS4GvO5LNPpD6QFdL8VKwcwIsdn.png', '2026-06-03 21:30:02.744526+07', '2026-06-03 21:30:02.761375+07');
INSERT INTO public.orders VALUES ('ORD-260603-818', '2026-06-03', 2, 'Calvin3c', '082331339737', 'Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE', 1254900, 'success', 'Menunggu Validasi', true, 'http://localhost:8000/storage/proofs/RICAipTTwaEtnh0NA4yEdvxWb50XxRH5xW92cvMJ.png', '2026-06-03 21:33:29.824554+07', '2026-06-03 21:34:47.351099+07');
INSERT INTO public.orders VALUES ('ORD-260604-871', '2026-06-04', 2, 'Calvin3c', '082331339737', 'Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'SiCepat Cargo per kg with minimum 10 kg', 2054900, 'cancelled', 'Kurir Sedang Dijadwalkan', true, 'http://localhost:8000/storage/proofs/VzeqjOqLybPjs3nZh0FR3YZN4Ggc2AYChR0SW47L.png', '2026-06-04 19:02:01.163007+07', '2026-06-04 19:13:24.193606+07');
INSERT INTO public.orders VALUES ('ORD-260604-224', '2026-06-04', 2, 'Calvin3c', '082331339737', 'Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'SiCepat Cargo per kg with minimum 10 kg', 1483950, 'cancelled', 'Kurir Sedang Dijadwalkan', true, 'http://localhost:8000/storage/proofs/3dEERsy0cjRmzwCdFfyHsguPz1w9yL9xnCEdg5dD.png', '2026-06-04 18:13:00.957274+07', '2026-06-04 19:32:35.307+07');
INSERT INTO public.orders VALUES ('ORD-260604-795', '2026-06-04', 2, 'Calvin3c', '082331339737', 'Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE Reguler', 84700, 'cancelled', 'Menunggu Validasi', true, 'http://localhost:8000/storage/proofs/XEdESdzFMFDdm1UlqHwdmC5MCfODIgdZ6Q8f1C5f.png', '2026-06-04 20:29:13.16172+07', '2026-06-04 20:29:45.788679+07');
INSERT INTO public.orders VALUES ('ORD-260603-817', '2026-06-03', 2, 'Calvin3c', '082331339737', 'Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE JNE Trucking', 1254900, 'COMPLETED', 'Kurir Sedang Dijadwalkan', true, 'http://localhost:8000/storage/proofs/oVqaSJw7gzzWxNp4FVri35cxbofdjamKjR3i4XCA.png', '2026-06-03 21:38:19.442259+07', '2026-06-03 21:57:30.158478+07');
INSERT INTO public.orders VALUES ('ORD-260604-787', '2026-06-04', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE JNE Trucking', 644800, 'success', 'Kurir Sedang Dijadwalkan', true, 'http://localhost:8000/storage/proofs/3a1U1wk1PcrQ5cw2vKtp6nKyeIjubpxKLQhezRYu.png', '2026-06-04 22:41:12.787118+07', '2026-06-04 22:47:24.626379+07');
INSERT INTO public.orders VALUES ('ORD-260604-969', '2026-06-04', 2, 'Calvin3c', '+62 8123388670', 'Jalan Utara Masjid No.9, Dampit Wetan, Dampit, Kec. Dampit, Kabupaten Malang, Jawa Timur 65181', 'Ambil Di Toko', 77700, 'COMPLETED', 'Menunggu Validasi', true, 'http://localhost:8000/storage/proofs/4ImFpz2ARPD1Xkp3bSVXPjTdm8VKa9jDtGnw34ss.png', '2026-06-04 20:32:14.766349+07', '2026-06-04 20:34:02.6065+07');
INSERT INTO public.orders VALUES ('ORD-260604-204', '2026-06-04', 2, 'Calvin3c', '082331339737', 'Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'SiCepat Cargo per kg with minimum 10 kg', 3469650, 'COMPLETED', 'Kurir Sedang Dijadwalkan', true, 'http://localhost:8000/storage/proofs/TRX41UOMUOBdTL5QeAU2ipyBknRbKuDTxbU2Nid7.png', '2026-06-04 19:51:34.408617+07', '2026-06-04 20:00:11.806675+07');
INSERT INTO public.orders VALUES ('ORD-260605-558', '2026-06-05', 3, 'Christian Anthony Sucipto', '+6282132148698', 'Perumahan Ijen Nirwana Blok C3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'SiCepat Cargo per kg with minimum 10 kg', 2732000, 'COMPLETED', 'Kurir Sedang Dijadwalkan', true, 'http://localhost:8000/storage/proofs/naSY2OH6hFGM3bGTRl6yanZPr97r6nAyn3vA071D.png', '2026-06-05 16:36:47.720974+07', '2026-06-05 16:54:07.776833+07');
INSERT INTO public.orders VALUES ('ORD-260604-216', '2026-06-04', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE JNE Trucking', 139900, 'cancelled', 'Kurir Sedang Dijadwalkan', true, 'http://localhost:8000/storage/proofs/tbpzlvWGzSyiIg5lSuFdNjZs5K781ofepDuHM2zO.png', '2026-06-04 21:15:20.643802+07', '2026-06-04 21:20:57.003455+07');
INSERT INTO public.orders VALUES ('ORD-260604-507', '2026-06-04', 2, 'Calvin3c', '082331339737', 'Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'Kurir Toko Sinar Abadi', 1332000, 'COMPLETED', 'Menunggu Validasi', true, 'http://localhost:8000/storage/proofs/I34zqzorYTUn7aAwM5qldUiWq1XzTtOhsMJpLUNW.png', '2026-06-04 20:36:37.788674+07', '2026-06-04 20:44:16.345137+07');
INSERT INTO public.orders VALUES ('ORD-260605-629', '2026-06-05', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116', 'SiCepat Cargo per kg with minimum 10 kg', 2732000, 'cancelled', 'Kurir Sedang Dijadwalkan', true, 'http://localhost:8000/storage/proofs/G0K2Cpw6e3Vsw9bQnriKT1bJr8JitER2rQI2duKG.png', '2026-06-05 15:44:02.096292+07', '2026-06-05 16:55:19.151188+07');
INSERT INTO public.orders VALUES ('ORD-260605-444', '2026-06-05', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116', 'SiCepat Cargo per kg with minimum 10 kg', 2054900, 'cancelled', 'Menunggu Validasi', true, 'http://localhost:8000/storage/proofs/wCIYmVDFsUKuKjdh6rgpShZycHvcMqnZCAF1IeIH.png', '2026-06-05 20:25:48.686921+07', '2026-06-05 20:27:51.902015+07');
INSERT INTO public.orders VALUES ('ORD-260605-340', '2026-06-05', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'SiCepat Cargo per kg with minimum 10 kg', 1921700, 'COMPLETED', 'Kurir Sedang Dijadwalkan', true, 'http://localhost:8000/storage/proofs/nqJ82PKxe8ew3oTNA6m6a0NmmYyKOmAMIGs6I76T.png', '2026-06-05 10:25:25.563087+07', '2026-06-05 10:38:17.083006+07');
INSERT INTO public.orders VALUES ('ORD-260605-505', '2026-06-05', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116', 'SiCepat Cargo per kg with minimum 10 kg', 2054900, 'COMPLETED', 'Kurir Sedang Dijadwalkan', true, 'http://localhost:8000/storage/proofs/T5i93Yhve7lD3vrz45ZzC6XedrfEMTvi3TPQj0eM.png', '2026-06-05 20:31:16.24613+07', '2026-06-05 20:41:27.654841+07');
INSERT INTO public.orders VALUES ('ORD-260605-636', '2026-06-05', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Gambir, Jakarta Pusat, DKI Jakarta. 10110', 'Kurir Toko Sinar Abadi', 327450, 'cancelled', 'Menunggu Validasi', true, 'http://localhost:8000/storage/proofs/I9B0Eyg6nvnqxjpBr7P13UZJCaJmyaj3uNxkmNQw.png', '2026-06-05 22:09:03.377179+07', '2026-06-05 22:16:25.710575+07');
INSERT INTO public.orders VALUES ('ORD-260605-729', '2026-06-05', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116', 'JNE Reguler', 334450, 'COMPLETED', 'Kurir Sedang Dijadwalkan', true, 'http://localhost:8000/storage/proofs/1sd3qCDO0zAFiO1EcrQHw1bec9zZ5BlgQQhVNRzC.png', '2026-06-05 22:21:44.924195+07', '2026-06-05 23:01:39.912029+07');
INSERT INTO public.orders VALUES ('ORD-260605-279', '2026-06-05', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116', 'JNE Reguler', 334450, 'success', 'Kurir Sedang Dijadwalkan', true, 'http://localhost:8000/storage/proofs/T2KCe31TMA1dNEQ1pBDUaT2XOFHt0ZakhbAolqBM.png', '2026-06-05 22:59:15.51669+07', '2026-06-05 23:02:32.33826+07');
INSERT INTO public.orders VALUES ('ORD-260606-995', '2026-06-06', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE JNE Trucking', 2099500, 'COMPLETED', 'Kurir Sedang Dijadwalkan', true, 'http://localhost:8000/storage/proofs/b35RH0WSnWIHzeztLkh1WHxsIN3vj4Dmo5AMtuf4.png', '2026-06-06 20:50:00.930407+07', '2026-06-06 20:55:28.793576+07');
INSERT INTO public.orders VALUES ('ORD-260605-300', '2026-06-05', 2, 'Calvin Alexander Sucipto', '+62 8123388670', 'Jalan Utara Masjid No.9, Dampit Wetan, Dampit, Kec. Dampit, Kabupaten Malang, Jawa Timur 65181', 'Ambil Di Toko', 111000, 'COMPLETED', 'Menunggu Validasi', true, 'http://localhost:8000/storage/proofs/WYuiUkxjCADHnPUMcqVdNAqGZe8bM7EooklPJYiJ.png', '2026-06-05 23:06:56.935182+07', '2026-06-05 23:07:51.079879+07');
INSERT INTO public.orders VALUES ('ORD-260606-731', '2026-06-06', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE Reguler', 506750, 'success', 'Kurir Sedang Dijadwalkan', true, 'http://localhost:8000/storage/proofs/bEbcia4NPw0LLnWTxcfN6oWYLcg6e3ryDts4jSoW.png', '2026-06-06 14:56:38.025216+07', '2026-06-06 14:58:17.778049+07');
INSERT INTO public.orders VALUES ('ORD-260605-128', '2026-06-05', 2, 'Calvin Alexander Sucipto', '+62 8123388670', 'Jalan Utara Masjid No.9, Dampit Wetan, Dampit, Kec. Dampit, Kabupaten Malang, Jawa Timur 65181', 'Ambil Di Toko', 11100, 'COMPLETED', 'Menunggu Validasi', true, 'http://localhost:8000/storage/proofs/NoP6W1Y8KHlOfN3JlA9RUn99Y16QzGzIwRY5QcR2.png', '2026-06-05 23:09:54.046139+07', '2026-06-05 23:10:41.678875+07');
INSERT INTO public.orders VALUES ('ORD-260606-964', '2026-06-06', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE Reguler', 284500, 'SHIPPING', 'Kurir Sedang Dijadwalkan', true, 'http://localhost:8000/storage/proofs/vDElCEBs6gpoPHVK3Dlxhg3b7QS2FlzowkxqJGOZ.png', '2026-06-06 10:10:18.514186+07', '2026-06-06 10:26:59.822853+07');
INSERT INTO public.orders VALUES ('ORD-260610-330', '2026-06-10', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE JNE Trucking', 2099500, 'pending', 'Menunggu Validasi', false, '', '2026-06-10 23:31:12.016759+07', '2026-06-10 23:31:12.016759+07');
INSERT INTO public.orders VALUES ('ORD-260606-680', '2026-06-06', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE Reguler', 92470, 'success', 'Kurir Sedang Dijadwalkan', true, 'http://localhost:8000/storage/proofs/HGsmfJSEmvonK1EGlfrCoy79xs4C2JdhmxZuSt6E.png', '2026-06-06 20:39:01.667325+07', '2026-06-06 20:40:06.759377+07');
INSERT INTO public.orders VALUES ('ORD-260606-149', '2026-06-06', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'SiCepat Cargo per kg with minimum 10 kg', 405300, 'SHIPPING', 'Kurir Sedang Dijadwalkan', true, 'http://localhost:8000/storage/proofs/0Z2DahWjmwwcbKhdO1X1gzCmAHf2BeCsSTPmYHtb.png', '2026-06-06 10:54:28.531067+07', '2026-06-06 10:58:53.05103+07');
INSERT INTO public.orders VALUES ('ORD-260611-975', '2026-06-11', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE JNE Trucking', 2099500, 'cancelled', 'Menunggu Validasi', false, '', '2026-06-11 11:35:05.197797+07', '2026-06-11 11:46:33.681877+07');
INSERT INTO public.orders VALUES ('ORD-260608-999', '2026-06-08', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE JNE Trucking', 4677200, 'COMPLETED', 'Kurir Sedang Dijadwalkan', true, 'http://localhost:8000/storage/proofs/Q4iISTOLf7p7vAbhh11gfxgtBDWuE9o4JzOtpwes.png', '2026-06-08 07:51:36.863346+07', '2026-06-08 07:58:12.710238+07');
INSERT INTO public.orders VALUES ('ORD-260611-735', '2026-06-11', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE Reguler', 14770, 'pending', 'Menunggu Validasi', false, '', '2026-06-11 12:32:45.182033+07', '2026-06-11 12:32:45.182033+07');
INSERT INTO public.orders VALUES ('ORD-260611-740', '2026-06-11', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE Reguler', 14770, 'pending', 'Menunggu Validasi', false, '', '2026-06-11 12:41:21.520325+07', '2026-06-11 12:41:21.520325+07');
INSERT INTO public.orders VALUES ('ORD-260610-883', '2026-06-10', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE JNE Trucking', 2254900, 'pending', 'Menunggu Validasi', true, 'http://localhost:8000/storage/proofs/GLp8loe394KIoRATN7s6nYjK7J60Qdt4IIOxg0RF.png', '2026-06-10 14:49:22.882207+07', '2026-06-10 14:49:22.930773+07');
INSERT INTO public.orders VALUES ('ORD-260611-855', '2026-06-11', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE JNE Trucking', 2099500, 'cancelled', 'Kurir Sedang Dijadwalkan', false, '', '2026-06-11 11:49:15.629234+07', '2026-06-11 11:56:36.763675+07');
INSERT INTO public.orders VALUES ('ORD-260611-298', '2026-06-11', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE JNE Trucking', 2099500, 'pending', 'Menunggu Validasi', false, '', '2026-06-11 11:58:25.743317+07', '2026-06-11 11:58:25.743317+07');
INSERT INTO public.orders VALUES ('ORD-260611-681', '2026-06-11', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE Reguler', 14770, 'pending', 'Menunggu Validasi', false, '', '2026-06-11 12:15:51.091737+07', '2026-06-11 12:15:51.091737+07');
INSERT INTO public.orders VALUES ('ORD-260611-815', '2026-06-11', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE Reguler', 14770, 'pending', 'Menunggu Validasi', false, '', '2026-06-11 12:31:51.126528+07', '2026-06-11 12:31:51.126528+07');
INSERT INTO public.orders VALUES ('ORD-260611-474', '2026-06-11', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE Reguler', 14770, 'pending', 'Menunggu Validasi', false, '', '2026-06-11 18:33:38.905043+07', '2026-06-11 18:33:38.905043+07');
INSERT INTO public.orders VALUES ('ORD-260611-253', '2026-06-11', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE Reguler', 14770, 'pending', 'Menunggu Validasi', false, '', '2026-06-11 18:36:06.417568+07', '2026-06-11 18:36:06.417568+07');
INSERT INTO public.orders VALUES ('ORD-260611-824', '2026-06-11', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE Reguler', 14770, 'pending', 'Menunggu Validasi', false, '', '2026-06-11 18:36:15.467818+07', '2026-06-11 18:36:15.467818+07');
INSERT INTO public.orders VALUES ('ORD-260611-870', '2026-06-11', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE Reguler', 14770, 'pending', 'Menunggu Validasi', false, '', '2026-06-11 18:38:01.131586+07', '2026-06-11 18:38:01.131586+07');
INSERT INTO public.orders VALUES ('ORD-260611-305', '2026-06-11', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE Reguler', 14770, 'pending', 'Menunggu Validasi', false, '', '2026-06-11 18:40:36.957757+07', '2026-06-11 18:40:36.957757+07');
INSERT INTO public.orders VALUES ('ORD-260611-457', '2026-06-11', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE Reguler', 14770, 'pending', 'Menunggu Validasi', false, '', '2026-06-11 18:42:25.804723+07', '2026-06-11 18:42:25.804723+07');
INSERT INTO public.orders VALUES ('ORD-260611-487', '2026-06-11', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE Reguler', 14770, 'cancelled', 'Menunggu Validasi', false, '', '2026-06-11 18:48:46.707315+07', '2026-06-11 18:48:51.027288+07');
INSERT INTO public.orders VALUES ('ORD-260611-311', '2026-06-11', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE Reguler', 14770, 'pending', 'Menunggu Validasi', false, '', '2026-06-11 18:48:58.06218+07', '2026-06-11 18:48:58.06218+07');
INSERT INTO public.orders VALUES ('ORD-260611-359', '2026-06-11', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE Reguler', 14770, 'pending', 'Menunggu Validasi', false, '', '2026-06-11 18:49:47.137373+07', '2026-06-11 18:49:47.137373+07');
INSERT INTO public.orders VALUES ('ORD-260611-761', '2026-06-11', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE Reguler', 14770, 'pending', 'Menunggu Validasi', false, '', '2026-06-11 18:51:22.046194+07', '2026-06-11 18:51:22.046194+07');
INSERT INTO public.orders VALUES ('ORD-260611-708', '2026-06-11', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE Reguler', 45850, 'pending', 'Menunggu Validasi', false, '', '2026-06-11 18:55:49.007851+07', '2026-06-11 18:55:49.007851+07');
INSERT INTO public.orders VALUES ('ORD-260611-353', '2026-06-11', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE Reguler', 14770, 'cancelled', 'Menunggu Validasi', false, '', '2026-06-11 18:58:30.797783+07', '2026-06-11 18:58:52.496507+07');
INSERT INTO public.orders VALUES ('ORD-260611-973', '2026-06-11', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE Reguler', 14770, 'pending', 'Menunggu Validasi', false, '', '2026-06-11 19:00:04.583383+07', '2026-06-11 19:00:04.583383+07');
INSERT INTO public.orders VALUES ('ORD-260611-780', '2026-06-11', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE Reguler', 18100, 'cancelled', 'Menunggu Validasi', false, '', '2026-06-11 19:09:20.942133+07', '2026-06-11 19:09:56.668438+07');
INSERT INTO public.orders VALUES ('ORD-260611-590', '2026-06-11', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE Reguler', 18100, 'cancelled', 'Menunggu Validasi', false, '', '2026-06-11 19:10:38.478005+07', '2026-06-11 19:10:49.653527+07');
INSERT INTO public.orders VALUES ('ORD-260611-399', '2026-06-11', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE Reguler', 18100, 'pending', 'Menunggu Validasi', false, '', '2026-06-11 19:12:01.385026+07', '2026-06-11 19:12:01.385026+07');
INSERT INTO public.orders VALUES ('ORD-260613-471', '2026-06-13', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE JNE Trucking', 2254900, 'pending', 'Menunggu Validasi', false, '', '2026-06-13 18:32:22.63475+07', '2026-06-13 18:32:22.63475+07');
INSERT INTO public.orders VALUES ('ORD-260613-517', '2026-06-13', 9, 'Andy Anthony', '081234567890', 'Perumahan Ijen Nirwana Blok C3 no 11', 'JNE Reguler', 163850, 'pending', 'Menunggu Validasi', false, '', '2026-06-13 21:14:24.488036+07', '2026-06-13 21:14:24.488036+07');
INSERT INTO public.orders VALUES ('ORD-260613-221', '2026-06-13', 9, 'Andy Anthony', '081234567890', 'Perumahan Ijen Nirwana Blok C3 no 11', 'JNE Reguler', 163850, 'pending', 'Menunggu Validasi', false, '', '2026-06-13 21:35:01.483887+07', '2026-06-13 21:35:01.483887+07');
INSERT INTO public.orders VALUES ('ORD-260614-130', '2026-06-14', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE JNE Trucking', 2121700, 'COMPLETED', 'Kurir Sedang Dijadwalkan', true, 'http://localhost:8000/storage/proofs/kRiidSQx3dY3xVCDNqVLqb0mapYLpXXqfRRm9cks.png', '2026-06-14 16:28:49.58411+07', '2026-06-14 17:13:38.546092+07');
INSERT INTO public.orders VALUES ('ORD-260614-268', '2026-06-14', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE Reguler', 84700, 'COMPLETED', 'Kurir Sedang Dijadwalkan', true, 'http://localhost:8000/storage/proofs/6HgpNDMt1Zm8Al8HYZd1okNxEQhuHcZYgE1hKvO0.png', '2026-06-14 17:36:28.487778+07', '2026-06-14 17:54:39.829576+07');
INSERT INTO public.orders VALUES ('ORD-260613-888', '2026-06-13', 9, 'Andy Anthony', '081234567890', 'Perumahan Ijen Nirwana Blok C3 no 11', 'JNE Reguler', 163850, 'SHIPPING', 'Kurir Sedang Dijadwalkan', false, '', '2026-06-13 21:28:19.986687+07', '2026-06-13 21:53:58.245099+07');
INSERT INTO public.orders VALUES ('ORD-260613-832', '2026-06-13', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE Reguler', 118000, 'success', 'Kurir Sedang Dijadwalkan', true, 'http://localhost:8000/storage/proofs/bIEstwbdcndJptjg3bkRQ815zA5ZlO0xHnqRmhur.png', '2026-06-13 21:32:02.479946+07', '2026-06-14 17:23:27.161741+07');
INSERT INTO public.orders VALUES ('ORD-260613-153', '2026-06-13', 9, 'Andy Anthony', '081234567890', 'Perumahan Ijen Nirwana Blok C3 no 11', 'JNE Reguler', 186175, 'SHIPPING', 'Kurir Sedang Dijadwalkan', false, '', '2026-06-13 22:00:42.697177+07', '2026-06-14 16:18:31.814603+07');
INSERT INTO public.orders VALUES ('ORD-260610-321', '2026-06-10', 6, 'Metodius Valentino', '+62823345678', 'Jalan Mandala, Merauke, Merauke, Papua. 99612, Merauke, Papua', 'JNE JNE Trucking', 796750, 'SHIPPING', 'Kurir Sedang Dijadwalkan', true, 'http://localhost:8000/storage/proofs/T7VuelifMFcEJ9gAAt0ljdtdGAtkPZtT0h2ib4tb.png', '2026-06-10 14:12:46.595869+07', '2026-06-14 16:25:47.053298+07');
INSERT INTO public.orders VALUES ('ORD-260614-699', '2026-06-14', 2, 'Calvin Alexander Sucipto', '082331339737', 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE JNE Trucking', 2121700, 'COMPLETED', 'Kurir Sedang Dijadwalkan', true, 'http://localhost:8000/storage/proofs/3PpZxPv6iVut4XIly3RqUlr1rijzcWkASR9p97Wy.png', '2026-06-14 15:35:16.117252+07', '2026-06-14 17:13:18.919685+07');
INSERT INTO public.orders VALUES ('ORD-260614-564', '2026-06-14', 4, 'Cathlen Gabriela', '+628123456', 'Ijen Nirwana, Klojen, Malang, Jawa Timur. 65116', 'JNE Reguler', 45850, 'cancelled', 'Menunggu Validasi', true, 'http://localhost:8000/storage/proofs/RBzipmr1WS24OPSLEFaYXKQH9dqzfuGS5LeRrGhp.png', '2026-06-14 17:41:16.98647+07', '2026-06-14 18:21:24.665895+07');
INSERT INTO public.orders VALUES ('ORD-260614-231', '2026-06-14', 3, 'Christian Anthony Sucipto', '+6282132148698', 'Perumahan Ijen Nirwana Blok C3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', 'JNE Reguler', 45850, 'SHIPPING', 'Kurir Sedang Dijadwalkan', true, 'http://localhost:8000/storage/proofs/OITTUYEqve2U5kFAUb7KesL0MyF9syct8ZeyhSlr.png', '2026-06-14 17:39:14.462187+07', '2026-06-14 17:49:56.096024+07');


--
-- Data for Name: owners; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.owners VALUES (1, 'owner', '$2a$10$8ZIevq04oONBIm/O1Jq62e61Y2DbrPmr2SWekkfzfGR7yezhU5frO', 'Duvaltina Prihatini', '2026-05-31 14:39:51.96124+07', '2026-06-10 20:49:45.304199+07', 'prihatini.duvaltina@gmail.com', '082132148699');


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.payments VALUES (1, 'ORD-260531-793', 'Transfer Bank BCA', 3707400, 'Pending', NULL, '2026-05-31 20:15:04.120787+07', '2026-05-31 20:15:04.120787+07', NULL, NULL);
INSERT INTO public.payments VALUES (2, 'ORD-260531-325', 'Transfer Bank BCA', 1332000, 'Pending', NULL, '2026-05-31 21:02:38.610584+07', '2026-05-31 21:02:38.610584+07', NULL, NULL);
INSERT INTO public.payments VALUES (3, 'ORD-260601-785', 'Transfer Bank BCA', 1903700, 'Pending', NULL, '2026-06-01 19:38:17.411193+07', '2026-06-01 19:38:17.411193+07', NULL, NULL);
INSERT INTO public.payments VALUES (4, 'ORD-260601-741', 'Transfer Bank BCA', 238700, 'Pending', NULL, '2026-06-01 19:43:12.080496+07', '2026-06-01 19:43:12.080496+07', NULL, NULL);
INSERT INTO public.payments VALUES (5, 'ORD-260603-721', 'Transfer Bank BCA', 10377150, 'Pending', NULL, '2026-06-03 12:43:09.775378+07', '2026-06-03 12:43:09.775378+07', NULL, NULL);
INSERT INTO public.payments VALUES (6, 'ORD-260603-541', 'Transfer Bank BCA', 2243400, 'Pending', NULL, '2026-06-03 12:56:55.374804+07', '2026-06-03 12:56:55.374804+07', NULL, NULL);
INSERT INTO public.payments VALUES (7, 'ORD-260603-437', 'Transfer Bank BCA', 521700, 'Pending', NULL, '2026-06-03 13:56:18.762306+07', '2026-06-03 13:56:18.762306+07', NULL, NULL);
INSERT INTO public.payments VALUES (8, 'ORD-260603-153', 'Transfer Bank BCA', 648870, 'Pending', NULL, '2026-06-03 14:07:54.032978+07', '2026-06-03 14:07:54.032978+07', NULL, NULL);
INSERT INTO public.payments VALUES (9, 'ORD-260603-820', 'Transfer Bank BCA', 1346040, 'Pending', NULL, '2026-06-03 14:12:25.640642+07', '2026-06-03 14:12:25.640642+07', NULL, NULL);
INSERT INTO public.payments VALUES (10, 'ORD-260603-503', 'Transfer Bank BCA', 327450, 'Pending', NULL, '2026-06-03 14:23:00.286944+07', '2026-06-03 14:23:00.286944+07', NULL, NULL);
INSERT INTO public.payments VALUES (11, 'ORD-260603-731', 'Transfer Bank BCA', 1332000, 'Pending', NULL, '2026-06-03 14:34:02.585738+07', '2026-06-03 14:34:02.585738+07', NULL, NULL);
INSERT INTO public.payments VALUES (12, 'ORD-260603-256', 'Transfer Bank BCA', 1127250, 'Pending', NULL, '2026-06-03 18:02:28.566854+07', '2026-06-03 18:02:28.566854+07', NULL, NULL);
INSERT INTO public.payments VALUES (13, 'ORD-260603-300', 'Transfer Bank BCA', 1127250, 'Pending', NULL, '2026-06-03 18:09:36.875732+07', '2026-06-03 18:09:36.875732+07', NULL, NULL);
INSERT INTO public.payments VALUES (14, 'ORD-260603-480', 'Transfer Bank BCA', 684350, 'Pending', NULL, '2026-06-03 18:21:57.444871+07', '2026-06-03 18:21:57.444871+07', NULL, NULL);
INSERT INTO public.payments VALUES (15, 'ORD-260603-849', 'Transfer Bank BCA', 1105800, 'Pending', NULL, '2026-06-03 18:32:25.606623+07', '2026-06-03 18:32:25.606623+07', NULL, NULL);
INSERT INTO public.payments VALUES (16, 'ORD-260603-210', 'Transfer Bank BCA', 829350, 'Pending', NULL, '2026-06-03 18:42:25.494397+07', '2026-06-03 18:42:25.494397+07', NULL, NULL);
INSERT INTO public.payments VALUES (17, 'ORD-260603-971', 'Transfer Bank BCA', 511750, 'Pending', NULL, '2026-06-03 19:30:22.985804+07', '2026-06-03 19:30:22.985804+07', NULL, NULL);
INSERT INTO public.payments VALUES (18, 'ORD-260603-941', 'Transfer Bank BCA', 341450, 'Pending', NULL, '2026-06-03 20:35:00.103106+07', '2026-06-03 20:35:00.103106+07', NULL, NULL);
INSERT INTO public.payments VALUES (19, 'ORD-260603-324', 'Transfer Bank BCA', 367450, 'Pending', NULL, '2026-06-03 20:39:29.377839+07', '2026-06-03 20:39:29.377839+07', NULL, NULL);
INSERT INTO public.payments VALUES (20, 'ORD-260603-526', 'Transfer Bank BCA', 341450, 'Pending', NULL, '2026-06-03 21:01:13.649796+07', '2026-06-03 21:01:13.649796+07', NULL, NULL);
INSERT INTO public.payments VALUES (21, 'ORD-260603-391', 'Transfer Bank BCA', 217700, 'Pending', NULL, '2026-06-03 21:22:38.219809+07', '2026-06-03 21:22:38.219809+07', NULL, NULL);
INSERT INTO public.payments VALUES (22, 'ORD-260603-629', 'Transfer Bank BCA', 134350, 'Pending', NULL, '2026-06-03 21:30:02.746863+07', '2026-06-03 21:30:02.746863+07', NULL, NULL);
INSERT INTO public.payments VALUES (23, 'ORD-260603-818', 'Transfer Bank BCA', 1254900, 'Pending', NULL, '2026-06-03 21:33:29.826314+07', '2026-06-03 21:33:29.826314+07', NULL, NULL);
INSERT INTO public.payments VALUES (24, 'ORD-260603-817', 'Transfer Bank BCA', 1254900, 'Pending', NULL, '2026-06-03 21:38:19.444355+07', '2026-06-03 21:38:19.444355+07', NULL, NULL);
INSERT INTO public.payments VALUES (25, 'ORD-260604-224', 'Transfer Bank BCA', 1483950, 'Pending', NULL, '2026-06-04 18:13:00.972294+07', '2026-06-04 18:13:00.972294+07', NULL, NULL);
INSERT INTO public.payments VALUES (26, 'ORD-260604-871', 'Transfer Bank BCA', 2054900, 'Pending', NULL, '2026-06-04 19:02:01.176554+07', '2026-06-04 19:02:01.176554+07', NULL, NULL);
INSERT INTO public.payments VALUES (27, 'ORD-260604-204', 'Transfer Bank BCA', 3469650, 'Pending', NULL, '2026-06-04 19:51:34.44507+07', '2026-06-04 19:51:34.44507+07', NULL, NULL);
INSERT INTO public.payments VALUES (28, 'ORD-260604-705', 'Transfer Bank BCA', 84700, 'Pending', NULL, '2026-06-04 20:15:41.658065+07', '2026-06-04 20:15:41.658065+07', NULL, NULL);
INSERT INTO public.payments VALUES (29, 'ORD-260604-795', 'Transfer Bank BCA', 84700, 'Pending', NULL, '2026-06-04 20:29:13.16945+07', '2026-06-04 20:29:13.16945+07', NULL, NULL);
INSERT INTO public.payments VALUES (30, 'ORD-260604-969', 'Transfer Bank BCA', 77700, 'Pending', NULL, '2026-06-04 20:32:14.769862+07', '2026-06-04 20:32:14.769862+07', NULL, NULL);
INSERT INTO public.payments VALUES (31, 'ORD-260604-507', 'Transfer Bank BCA', 1332000, 'Pending', NULL, '2026-06-04 20:36:37.792132+07', '2026-06-04 20:36:37.792132+07', NULL, NULL);
INSERT INTO public.payments VALUES (32, 'ORD-260604-216', 'Transfer Bank BCA', 139900, 'Pending', NULL, '2026-06-04 21:15:20.65021+07', '2026-06-04 21:15:20.65021+07', NULL, NULL);
INSERT INTO public.payments VALUES (33, 'ORD-260604-787', 'Transfer Bank BCA', 644800, 'Pending', NULL, '2026-06-04 22:41:12.81431+07', '2026-06-04 22:41:12.81431+07', NULL, NULL);
INSERT INTO public.payments VALUES (34, 'ORD-260605-340', 'Transfer Bank BCA', 1921700, 'Pending', NULL, '2026-06-05 10:25:25.589989+07', '2026-06-05 10:25:25.589989+07', NULL, NULL);
INSERT INTO public.payments VALUES (35, 'ORD-260605-629', 'Transfer Bank BCA', 2732000, 'Pending', NULL, '2026-06-05 15:44:02.118791+07', '2026-06-05 15:44:02.118791+07', NULL, NULL);
INSERT INTO public.payments VALUES (36, 'ORD-260605-558', 'Transfer Bank BCA', 2732000, 'Pending', NULL, '2026-06-05 16:36:47.730693+07', '2026-06-05 16:36:47.730693+07', NULL, NULL);
INSERT INTO public.payments VALUES (37, 'ORD-260605-444', 'Transfer Bank BCA', 2054900, 'Pending', NULL, '2026-06-05 20:25:48.74254+07', '2026-06-05 20:25:48.74254+07', NULL, NULL);
INSERT INTO public.payments VALUES (38, 'ORD-260605-505', 'Transfer Bank BCA', 2054900, 'Pending', NULL, '2026-06-05 20:31:16.296801+07', '2026-06-05 20:31:16.296801+07', NULL, NULL);
INSERT INTO public.payments VALUES (39, 'ORD-260605-636', 'Transfer Bank BCA', 327450, 'Pending', NULL, '2026-06-05 22:09:03.383326+07', '2026-06-05 22:09:03.383326+07', NULL, NULL);
INSERT INTO public.payments VALUES (40, 'ORD-260605-729', 'Transfer Bank BCA', 334450, 'Pending', NULL, '2026-06-05 22:21:44.928387+07', '2026-06-05 22:21:44.928387+07', NULL, NULL);
INSERT INTO public.payments VALUES (41, 'ORD-260605-279', 'Transfer Bank BCA', 334450, 'Pending', NULL, '2026-06-05 22:59:15.52052+07', '2026-06-05 22:59:15.52052+07', NULL, NULL);
INSERT INTO public.payments VALUES (42, 'ORD-260605-300', 'Transfer Bank BCA', 111000, 'Pending', NULL, '2026-06-05 23:06:56.936577+07', '2026-06-05 23:06:56.936577+07', NULL, NULL);
INSERT INTO public.payments VALUES (43, 'ORD-260605-128', 'Transfer Bank BCA', 11100, 'Pending', NULL, '2026-06-05 23:09:54.04878+07', '2026-06-05 23:09:54.04878+07', NULL, NULL);
INSERT INTO public.payments VALUES (44, 'ORD-260606-964', 'Transfer Bank BCA', 284500, 'Pending', NULL, '2026-06-06 10:10:18.539629+07', '2026-06-06 10:10:18.539629+07', NULL, NULL);
INSERT INTO public.payments VALUES (45, 'ORD-260606-149', 'Transfer Bank BCA', 405300, 'Pending', NULL, '2026-06-06 10:54:28.536584+07', '2026-06-06 10:54:28.536584+07', NULL, NULL);
INSERT INTO public.payments VALUES (46, 'ORD-260606-731', 'Transfer Bank BCA', 506750, 'Pending', NULL, '2026-06-06 14:56:38.054393+07', '2026-06-06 14:56:38.054393+07', NULL, NULL);
INSERT INTO public.payments VALUES (47, 'ORD-260606-680', 'Transfer Bank BCA', 92470, 'Pending', NULL, '2026-06-06 20:39:01.721885+07', '2026-06-06 20:39:01.721885+07', NULL, NULL);
INSERT INTO public.payments VALUES (48, 'ORD-260606-995', 'Transfer Bank BCA', 2099500, 'Pending', NULL, '2026-06-06 20:50:00.935553+07', '2026-06-06 20:50:00.935553+07', NULL, NULL);
INSERT INTO public.payments VALUES (49, 'ORD-260608-999', 'Transfer Bank BCA', 4677200, 'Pending', NULL, '2026-06-08 07:51:36.913735+07', '2026-06-08 07:51:36.913735+07', NULL, NULL);
INSERT INTO public.payments VALUES (50, 'ORD-260610-321', 'Transfer Bank BCA', 796750, 'Pending', NULL, '2026-06-10 14:12:46.64355+07', '2026-06-10 14:12:46.64355+07', NULL, NULL);
INSERT INTO public.payments VALUES (51, 'ORD-260610-883', 'Transfer Bank BCA', 2254900, 'Pending', NULL, '2026-06-10 14:49:22.888304+07', '2026-06-10 14:49:22.888304+07', NULL, NULL);
INSERT INTO public.payments VALUES (52, 'ORD-260610-330', 'Midtrans Online', 2099500, 'Pending', NULL, '2026-06-10 23:31:12.164584+07', '2026-06-10 23:31:12.164584+07', '80e948af-30e4-40a1-a354-9cae79875fb6', '');
INSERT INTO public.payments VALUES (53, 'ORD-260611-975', 'Midtrans Online', 2099500, 'Pending', NULL, '2026-06-11 11:35:05.431478+07', '2026-06-11 11:35:05.431478+07', 'f6ec89e1-5f42-4530-98de-076c9f2c35ca', '');
INSERT INTO public.payments VALUES (54, 'ORD-260611-855', 'Midtrans Online', 2099500, 'Pending', NULL, '2026-06-11 11:49:16.072334+07', '2026-06-11 11:49:16.072334+07', '890f1318-0bfc-4bdf-b0b2-97f91cdefffd', '');
INSERT INTO public.payments VALUES (55, 'ORD-260611-298', 'Midtrans Online', 2099500, 'Pending', NULL, '2026-06-11 11:58:25.917451+07', '2026-06-11 11:58:25.917451+07', '9d612ed1-8bd4-47fa-98dd-88235587e923', '');
INSERT INTO public.payments VALUES (56, 'ORD-260611-681', 'Midtrans Online', 14770, 'Pending', NULL, '2026-06-11 12:15:51.392952+07', '2026-06-11 12:15:51.392952+07', '66f347cc-f6f5-498e-8a1f-11875acb4edf', '');
INSERT INTO public.payments VALUES (57, 'ORD-260611-815', 'Midtrans Online', 14770, 'Pending', NULL, '2026-06-11 12:31:51.450667+07', '2026-06-11 12:31:51.450667+07', '4a851ec1-5cc1-4382-a005-2c419504ca38', '');
INSERT INTO public.payments VALUES (58, 'ORD-260611-735', 'Midtrans Online', 14770, 'Pending', NULL, '2026-06-11 12:32:45.353262+07', '2026-06-11 12:32:45.353262+07', '2e6f628b-498a-4086-aa63-95af8676fbb3', '');
INSERT INTO public.payments VALUES (59, 'ORD-260611-740', 'Midtrans Online', 14770, 'Pending', NULL, '2026-06-11 12:41:21.912373+07', '2026-06-11 12:41:21.912373+07', 'd389560f-1011-44a3-b400-4ffd5a679b6c', '');
INSERT INTO public.payments VALUES (60, 'ORD-260611-474', 'Midtrans Online', 14770, 'Pending', NULL, '2026-06-11 18:33:39.620661+07', '2026-06-11 18:33:39.620661+07', '868dae0c-77e1-4ab3-a744-3253e20910ad', '');
INSERT INTO public.payments VALUES (61, 'ORD-260611-253', 'Midtrans Online', 14770, 'Pending', NULL, '2026-06-11 18:36:06.961464+07', '2026-06-11 18:36:06.961464+07', '10def031-f7f2-4e7a-a15e-419d2a8098a8', '');
INSERT INTO public.payments VALUES (62, 'ORD-260611-824', 'Midtrans Online', 14770, 'Pending', NULL, '2026-06-11 18:36:15.574568+07', '2026-06-11 18:36:15.574568+07', '137f7c58-a1ed-415f-934d-047ba55bbcce', '');
INSERT INTO public.payments VALUES (63, 'ORD-260611-870', 'Midtrans Online', 14770, 'Pending', NULL, '2026-06-11 18:38:01.954423+07', '2026-06-11 18:38:01.954423+07', 'c242a7dc-130c-4597-941b-a10e2a57db2b', '');
INSERT INTO public.payments VALUES (64, 'ORD-260611-305', 'Midtrans Online', 14770, 'Pending', NULL, '2026-06-11 18:40:37.583221+07', '2026-06-11 18:40:37.583221+07', '6ae5ba2f-b646-4750-b0d9-b35cf3cac741', '');
INSERT INTO public.payments VALUES (65, 'ORD-260611-457', 'Midtrans Online', 14770, 'Pending', NULL, '2026-06-11 18:42:26.501653+07', '2026-06-11 18:42:26.501653+07', '42c09854-90d2-43c7-b79f-d618864c97bc', '');
INSERT INTO public.payments VALUES (66, 'ORD-260611-487', 'Midtrans Online', 14770, 'Pending', NULL, '2026-06-11 18:48:47.394162+07', '2026-06-11 18:48:47.394162+07', '6418b576-5ccc-4f82-a6a4-7d9abd3dc529', '');
INSERT INTO public.payments VALUES (67, 'ORD-260611-311', 'Midtrans Online', 14770, 'Pending', NULL, '2026-06-11 18:48:58.169131+07', '2026-06-11 18:48:58.169131+07', '45ebac93-e4b6-4ea1-993e-f8f80d4e3831', '');
INSERT INTO public.payments VALUES (68, 'ORD-260611-359', 'Midtrans Online', 14770, 'Pending', NULL, '2026-06-11 18:49:47.248363+07', '2026-06-11 18:49:47.248363+07', 'f3beec7a-a1a0-48ac-b26e-685ef7c2ac77', '');
INSERT INTO public.payments VALUES (69, 'ORD-260611-761', 'Midtrans Online', 14770, 'Pending', NULL, '2026-06-11 18:51:22.827724+07', '2026-06-11 18:51:22.827724+07', 'f423b659-3e8d-4384-a759-f348361cc369', '');
INSERT INTO public.payments VALUES (70, 'ORD-260611-708', 'Midtrans Online', 45850, 'Pending', NULL, '2026-06-11 18:55:50.360794+07', '2026-06-11 18:55:50.360794+07', '7a3b879a-c2ec-46b8-b38a-629f560b8b52', '');
INSERT INTO public.payments VALUES (71, 'ORD-260611-353', 'Midtrans Online', 14770, 'Pending', NULL, '2026-06-11 18:58:31.559032+07', '2026-06-11 18:58:31.559032+07', 'c731d198-8021-43c2-916c-8b3694e54f6e', '');
INSERT INTO public.payments VALUES (72, 'ORD-260611-973', 'Midtrans Online', 14770, 'Pending', NULL, '2026-06-11 19:00:05.756828+07', '2026-06-11 19:00:05.756828+07', '3623f930-7c9f-4d07-82fd-0ae38d2079af', '');
INSERT INTO public.payments VALUES (73, 'ORD-260611-780', 'Midtrans Online', 18100, 'Pending', NULL, '2026-06-11 19:09:21.599209+07', '2026-06-11 19:09:21.599209+07', '41ea2607-27f7-4c88-9306-cb63f3d680c1', '');
INSERT INTO public.payments VALUES (74, 'ORD-260611-590', 'Midtrans Online', 18100, 'Pending', NULL, '2026-06-11 19:10:38.598437+07', '2026-06-11 19:10:38.598437+07', '126e022f-fd2f-4618-8859-b81c30cce444', '');
INSERT INTO public.payments VALUES (75, 'ORD-260611-399', 'Midtrans Online', 18100, 'Pending', NULL, '2026-06-11 19:12:01.490936+07', '2026-06-11 19:12:01.490936+07', 'c62b1031-6fc0-4a8e-ab19-dfc5726ee5f1', '');
INSERT INTO public.payments VALUES (76, 'ORD-260613-471', 'Midtrans Online', 2254900, 'Pending', NULL, '2026-06-13 18:32:23.338353+07', '2026-06-13 18:32:23.338353+07', '565079ad-d776-4178-9dbc-d1709d6b2152', '');
INSERT INTO public.payments VALUES (77, 'ORD-260613-517', 'Transfer Bank', 163850, 'Pending', NULL, '2026-06-13 21:14:24.524424+07', '2026-06-13 21:14:24.524424+07', '', '');
INSERT INTO public.payments VALUES (78, 'ORD-260613-888', 'Transfer Bank', 163850, 'Pending', NULL, '2026-06-13 21:28:19.989503+07', '2026-06-13 21:28:19.989503+07', '', '');
INSERT INTO public.payments VALUES (79, 'ORD-260613-832', 'Transfer Bank BCA', 118000, 'Pending', NULL, '2026-06-13 21:32:02.481591+07', '2026-06-13 21:32:02.481591+07', '', '');
INSERT INTO public.payments VALUES (80, 'ORD-260613-221', 'Midtrans', 163850, 'Pending', NULL, '2026-06-13 21:35:02.189742+07', '2026-06-13 21:35:02.189742+07', '280c8283-2239-4f81-a945-d75c449bd3a5', '');
INSERT INTO public.payments VALUES (81, 'ORD-260613-153', 'Transfer Bank', 186175, 'Pending', NULL, '2026-06-13 22:00:42.722511+07', '2026-06-13 22:00:42.722511+07', '', '');
INSERT INTO public.payments VALUES (82, 'ORD-260614-699', 'Transfer Bank BCA', 2121700, 'Pending', NULL, '2026-06-14 15:35:16.148669+07', '2026-06-14 15:35:16.148669+07', '', '');
INSERT INTO public.payments VALUES (83, 'ORD-260614-130', 'Transfer Bank BCA', 2121700, 'Pending', NULL, '2026-06-14 16:28:49.606556+07', '2026-06-14 16:28:49.606556+07', '', '');
INSERT INTO public.payments VALUES (84, 'ORD-260614-268', 'Transfer Bank BCA', 84700, 'Pending', NULL, '2026-06-14 17:36:28.493914+07', '2026-06-14 17:36:28.493914+07', '', '');
INSERT INTO public.payments VALUES (85, 'ORD-260614-231', 'Transfer Bank BCA', 45850, 'Pending', NULL, '2026-06-14 17:39:14.468022+07', '2026-06-14 17:39:14.468022+07', '', '');
INSERT INTO public.payments VALUES (86, 'ORD-260614-564', 'Transfer Bank BCA', 45850, 'Pending', NULL, '2026-06-14 17:41:16.995983+07', '2026-06-14 17:41:16.995983+07', '', '');


--
-- Data for Name: product_variants; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.product_variants VALUES (1, 'P-075', 'Biru Muda', 0, '2026-06-04 22:34:31.511437+07', '2026-06-04 22:34:31.511437+07');
INSERT INTO public.product_variants VALUES (2, 'P-075', 'Merah Muda', 0, '2026-06-04 22:34:31.513113+07', '2026-06-04 22:34:31.513113+07');
INSERT INTO public.product_variants VALUES (3, 'P-075', 'Putih', 0, '2026-06-04 22:34:31.514292+07', '2026-06-04 22:34:31.514292+07');
INSERT INTO public.product_variants VALUES (4, 'P-075', 'Merah Maroon', 295000, '2026-06-04 22:34:31.515424+07', '2026-06-04 22:34:31.515424+07');
INSERT INTO public.product_variants VALUES (5, 'P-076', 'Biru Muda', 0, '2026-06-04 22:34:31.51599+07', '2026-06-04 22:34:31.51599+07');
INSERT INTO public.product_variants VALUES (6, 'P-076', 'Merah Muda', 0, '2026-06-04 22:34:31.516515+07', '2026-06-04 22:34:31.516515+07');
INSERT INTO public.product_variants VALUES (7, 'P-076', 'Putih', 0, '2026-06-04 22:34:31.517038+07', '2026-06-04 22:34:31.517038+07');
INSERT INTO public.product_variants VALUES (8, 'P-076', 'Merah Maroon', 295000, '2026-06-04 22:34:31.517555+07', '2026-06-04 22:34:31.517555+07');
INSERT INTO public.product_variants VALUES (9, 'P-077', 'Biru Muda', 0, '2026-06-04 22:34:31.518077+07', '2026-06-04 22:34:31.518077+07');
INSERT INTO public.product_variants VALUES (10, 'P-077', 'Merah Muda', 0, '2026-06-04 22:34:31.518077+07', '2026-06-04 22:34:31.518077+07');
INSERT INTO public.product_variants VALUES (11, 'P-077', 'Putih', 0, '2026-06-04 22:34:31.518624+07', '2026-06-04 22:34:31.518624+07');
INSERT INTO public.product_variants VALUES (12, 'P-077', 'Merah Maroon', 225000, '2026-06-04 22:34:31.519139+07', '2026-06-04 22:34:31.519139+07');
INSERT INTO public.product_variants VALUES (13, 'P-078', 'Biru Muda', 0, '2026-06-04 22:34:31.519139+07', '2026-06-04 22:34:31.519139+07');
INSERT INTO public.product_variants VALUES (14, 'P-078', 'Merah Muda', 0, '2026-06-04 22:34:31.519658+07', '2026-06-04 22:34:31.519658+07');
INSERT INTO public.product_variants VALUES (15, 'P-078', 'Putih', 0, '2026-06-04 22:34:31.520173+07', '2026-06-04 22:34:31.520173+07');
INSERT INTO public.product_variants VALUES (16, 'P-079', 'Biru Muda', 0, '2026-06-04 22:34:31.520173+07', '2026-06-04 22:34:31.520173+07');
INSERT INTO public.product_variants VALUES (17, 'P-079', 'Merah Muda', 0, '2026-06-04 22:34:31.520682+07', '2026-06-04 22:34:31.520682+07');
INSERT INTO public.product_variants VALUES (18, 'P-079', 'Putih', 0, '2026-06-04 22:34:31.521205+07', '2026-06-04 22:34:31.521205+07');
INSERT INTO public.product_variants VALUES (19, 'P-080', 'Biru Muda', 0, '2026-06-04 22:34:31.521205+07', '2026-06-04 22:34:31.521205+07');
INSERT INTO public.product_variants VALUES (20, 'P-080', 'Merah Muda', 0, '2026-06-04 22:34:31.521725+07', '2026-06-04 22:34:31.521725+07');
INSERT INTO public.product_variants VALUES (21, 'P-080', 'Putih', 0, '2026-06-04 22:34:31.522242+07', '2026-06-04 22:34:31.522242+07');


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.products VALUES ('P-034', 'Perpipaan', 'Pipa Maspion 3 D', 137000, 0, false, 'http://localhost:8000/images/products/pipa_maspion_d.png', '2026-05-31 14:39:51.999763+07', '2026-06-04 18:57:11.588665+07', 'Maspion', 4600, 'Batang', 1, 400, 9, 9);
INSERT INTO public.products VALUES ('P-049', 'Perpipaan', 'Pipa Rucika 6 AW', 775000, 0, false, 'http://localhost:8000/images/products/pipa_rucika_aw.png', '2026-05-31 14:39:52.011758+07', '2026-06-04 18:57:11.596245+07', 'Rucika', 26800, 'Batang', 1, 400, 17, 17);
INSERT INTO public.products VALUES ('P-004', 'Semen', 'Semen Putih Tiga Roda 40 kg', 120000, 81, true, 'http://localhost:8000/images/products/semen_tiga_roda.png', '2026-05-31 14:39:51.979954+07', '2026-06-08 07:51:36.854467+07', 'Tiga Roda', 40000, 'Sak', 10, 55, 40, 10);
INSERT INTO public.products VALUES ('P-006', 'Semen', 'Semen Sika Perekat Granit 20 kg', 110000, 0, true, 'http://localhost:8000/storage/products/Bovw01FAu0yC1Wg9EkpLBd1V8HeKv1MSmFWgqAUA.jpg', '2026-05-31 14:39:51.981494+07', '2026-06-13 18:13:40.945358+07', 'Semen', 20000, 'Sak', 10, 45, 30, 10);
INSERT INTO public.products VALUES ('P-008', 'Semen', 'Semen Perekat Bata Ringan Eco 20 kg', 65000, 0, true, 'http://localhost:8000/storage/products/bic9BLkcAlKZZrOFiF865G3BG9q3SOUWa0a3CgWT.jpg', '2026-05-31 14:39:51.983034+07', '2026-06-04 18:57:11.598928+07', 'Semen', 20000, 'Sak', 10, 45, 30, 10);
INSERT INTO public.products VALUES ('P-002', 'Semen', 'Semen Merah Putih 40 kg', 47000, 133, true, 'http://localhost:8000/storage/products/Qe3hxSlf75AUUr458V8ogQ3fKRYPXmuCRV1YD8Zo.png', '2026-05-31 14:39:51.977791+07', '2026-06-14 16:28:49.575962+07', 'Merah Putih', 40000, 'Sak', 10, 55, 40, 10);
INSERT INTO public.products VALUES ('P-106', 'Kuas Cat', 'Kuas Eterna 4 Inch', 25000, 10, false, 'http://localhost:8000/images/products/kuas_eterna.png', '2026-05-31 14:39:52.114084+07', '2026-06-06 10:10:18.484807+07', 'Eterna', 80, 'Pcs', 1, 23, 10, 2);
INSERT INTO public.products VALUES ('P-007', 'Semen', 'Semen Perekat Bata Ringan Drymix 20 kg', 75000, 0, true, 'http://localhost:8000/images/products/semen_drymix.png', '2026-05-31 14:39:51.982006+07', '2026-06-04 18:57:11.598928+07', 'Semen', 20000, 'Sak', 10, 45, 30, 10);
INSERT INTO public.products VALUES ('P-127', 'Engsel', 'Engsel Lemari Tipis 2.5 Inch', 8000, 0, false, 'http://localhost:8000/images/products/engsel_lemari.png', '2026-05-31 14:39:52.127868+07', '2026-06-04 18:57:11.504456+07', 'Lokal / Tanpa Merek', 100, 'Buah', 1, 6, 4, 1);
INSERT INTO public.products VALUES ('P-005', 'Semen', 'Semen Putih Panda 40 kg', 65000, 0, true, 'http://localhost:8000/images/products/semen_panda.png', '2026-05-31 14:39:51.980982+07', '2026-06-04 18:57:11.598412+07', 'Semen', 40000, 'Sak', 10, 55, 40, 10);
INSERT INTO public.products VALUES ('P-021', 'Perpipaan', 'Pipa Maspion 5/8 C', 9000, 0, false, 'http://localhost:8000/images/products/pipa_maspion_c.png', '2026-05-31 14:39:51.991542+07', '2026-06-04 21:20:56.984348+07', 'Maspion', 900, 'Batang', 1, 400, 2, 2);
INSERT INTO public.products VALUES ('P-066', 'Cat Kayu', 'Emco Warna Bintang 0.5 kg', 60000, 0, false, 'http://localhost:8000/images/products/cat_emco.png', '2026-05-31 14:39:52.025815+07', '2026-06-04 18:57:11.480695+07', 'Lokal / Tanpa Merek', 500, 'Pcs', 1, 10, 10, 10);
INSERT INTO public.products VALUES ('P-131', 'Keramik & Granite', 'Keramik Lantai 60x60 cm', 135000, 0, true, 'http://localhost:8000/images/products/keramik_lantai.png', '2026-05-31 14:39:52.130162+07', '2026-06-04 18:57:11.512873+07', 'Lokal / Tanpa Merek', 17000, 'Dus', 1, 60, 60, 1);
INSERT INTO public.products VALUES ('P-137', 'Keramik & Granite', 'Granite Warna Gelap 60x60 cm', 255000, 0, true, 'http://localhost:8000/images/products/granite_tile.png', '2026-05-31 14:39:52.134081+07', '2026-06-04 18:57:11.513914+07', 'Lokal / Tanpa Merek', 30000, 'Dus', 1, 60, 60, 1);
INSERT INTO public.products VALUES ('P-115', 'Kunci Pintu', 'Kunci Pintu WanLi Kecil', 75000, 0, false, 'http://localhost:8000/images/products/kunci_pintu_wanli.png', '2026-05-31 14:39:52.119212+07', '2026-06-04 18:57:11.533011+07', 'WanLi', 600, 'Buah', 1, 17, 7, 7);
INSERT INTO public.products VALUES ('P-096', 'Listrik', 'Lampu Philips LED 5 Watt', 25000, 0, false, 'http://localhost:8000/storage/products/CvsUIVkxLIHqDAcZkQcm0vXE5veItAGlAEKeST2S.jpg', '2026-05-31 14:39:52.092449+07', '2026-06-04 18:57:11.53748+07', 'Philips', 60, 'Buah', 1, 11, 6, 6);
INSERT INTO public.products VALUES ('P-022', 'Perpipaan', 'Pipa Maspion 3/4 C', 16000, 0, false, 'http://localhost:8000/images/products/pipa_maspion_c.png', '2026-05-31 14:39:51.992802+07', '2026-06-04 18:57:11.5654+07', 'Maspion', 1600, 'Batang', 1, 400, 3, 3);
INSERT INTO public.products VALUES ('P-023', 'Perpipaan', 'Pipa Maspion 1 C', 26000, 0, false, 'http://localhost:8000/images/products/pipa_maspion_c.png', '2026-05-31 14:39:51.993359+07', '2026-06-04 18:57:11.566175+07', 'Maspion', 2200, 'Batang', 1, 400, 3, 3);
INSERT INTO public.products VALUES ('P-024', 'Perpipaan', 'Pipa Maspion 1 1/4 C', 31000, 0, false, 'http://localhost:8000/images/products/pipa_maspion_c.png', '2026-05-31 14:39:51.993978+07', '2026-06-04 18:57:11.567284+07', 'Maspion', 3200, 'Batang', 1, 400, 4, 4);
INSERT INTO public.products VALUES ('P-009', 'Perpipaan', 'Pipa Maspion 1/2 AW', 35000, 0, false, 'http://localhost:8000/images/products/pipa_maspion_aw.png', '2026-05-31 14:39:51.983591+07', '2026-06-04 18:57:11.568274+07', 'Maspion', 1000, 'Batang', 1, 400, 2, 2);
INSERT INTO public.products VALUES ('P-025', 'Perpipaan', 'Pipa Maspion 1 1/2 C', 37000, 0, false, 'http://localhost:8000/images/products/pipa_maspion_c.png', '2026-05-31 14:39:51.994492+07', '2026-06-04 18:57:11.572507+07', 'Maspion', 4000, 'Batang', 1, 400, 5, 5);
INSERT INTO public.products VALUES ('P-041', 'Perpipaan', 'Pipa Rucika 1 AW', 55000, 0, false, 'http://localhost:8000/images/products/pipa_rucika_aw.png', '2026-05-31 14:39:52.003916+07', '2026-06-04 18:57:11.579431+07', 'Rucika', 1790, 'Batang', 1, 400, 3, 3);
INSERT INTO public.products VALUES ('P-101', 'Kuas Cat', 'Kuas Eterna 1 Inch', 7000, 50, false, 'http://localhost:8000/images/products/kuas_eterna.png', '2026-05-31 14:39:52.111384+07', '2026-06-11 19:00:04.581135+07', 'Eterna', 60, 'Pcs', 1, 18, 3, 1);
INSERT INTO public.products VALUES ('P-100', 'Listrik', 'Lampu Philips LED 13 Watt', 49500, 0, false, 'http://localhost:8000/storage/products/P7l7ELMT0OlnwsUqEkv61hdozBPbF9vDmnDuzval.jpg', '2026-05-31 14:39:52.110341+07', '2026-06-04 18:57:11.546102+07', 'Philips', 100, 'Buah', 1, 13, 7, 7);
INSERT INTO public.products VALUES ('P-068', 'Cat Kayu', 'Avian 0.5 kg', 47500, 3, false, 'http://localhost:8000/images/products/cat_avian.png', '2026-05-31 14:39:52.028496+07', '2026-06-13 22:00:42.678478+07', 'Lokal / Tanpa Merek', 500, 'Pcs', 1, 10, 10, 10);
INSERT INTO public.products VALUES ('P-053', 'Cat Tembok', 'Avitex 5 kg', 155000, 0, false, 'http://localhost:8000/images/products/cat_avitex.png', '2026-05-31 14:39:52.015689+07', '2026-06-04 18:57:11.494317+07', 'Avitex', 5000, 'Galon', 1, 20, 20, 21);
INSERT INTO public.products VALUES ('P-082', 'Perkakas', 'Mesin Pasrah Modern M2950', 475000, 0, false, 'http://localhost:8000/images/products/mesin_pasrah_m2950.png', '2026-05-31 14:39:52.058216+07', '2026-06-04 18:57:11.560603+07', 'Modern', 4000, 'Unit', 1, 30, 17, 16);
INSERT INTO public.products VALUES ('P-081', 'Perkakas', 'Mesin Pasrah Modern M2900', 495000, 0, false, 'http://localhost:8000/images/products/mesin_pasrah_m2900.png', '2026-05-31 14:39:52.055069+07', '2026-06-04 18:57:11.563094+07', 'Modern', 3000, 'Unit', 1, 30, 17, 16);
INSERT INTO public.products VALUES ('P-077', 'Kloset', 'Kloset Jongkok Duty', 145000, 1, true, 'http://localhost:8000/images/products/kloset_duty.png', '2026-05-31 14:39:52.037042+07', '2026-06-10 14:32:33.913629+07', 'Duty', 25000, 'Buah', 1, 50, 40, 25);
INSERT INTO public.products VALUES ('P-078', 'Kloset', 'Monoblok INA', 1550000, 0, true, 'http://localhost:8000/images/products/monoblok_ina.png', '2026-05-31 14:39:52.038121+07', '2026-06-04 18:57:11.527901+07', 'INA', 25000, 'Buah', 1, 69, 40, 79);
INSERT INTO public.products VALUES ('P-056', 'Cat Tembok', 'No. Drop 20 kg', 1225000, 0, false, 'http://localhost:8000/images/products/cat_nodrop.png', '2026-05-31 14:39:52.017243+07', '2026-06-04 18:57:11.502282+07', 'Cat Tembok', 20000, 'Pail', 1, 32, 32, 38);
INSERT INTO public.products VALUES ('P-054', 'Cat Tembok', 'Avitex 25 kg', 775000, 4, false, 'http://localhost:8000/images/products/cat_avitex.png', '2026-05-31 14:39:52.016211+07', '2026-06-08 07:51:36.813224+07', 'Avitex', 25000, 'Pail', 1, 32, 32, 38);
INSERT INTO public.products VALUES ('P-059', 'Cat Tembok', 'Aries 5 kg', 70000, 0, false, 'http://localhost:8000/images/products/cat_aries.png', '2026-05-31 14:39:52.018943+07', '2026-06-04 18:57:11.488621+07', 'Cat Tembok', 5000, 'Galon', 1, 20, 20, 21);
INSERT INTO public.products VALUES ('P-060', 'Cat Tembok', 'Aries 20 kg', 280000, 0, false, 'http://localhost:8000/images/products/cat_aries.png', '2026-05-31 14:39:52.01948+07', '2026-06-04 18:57:11.500705+07', 'Cat Tembok', 20000, 'Pail', 1, 32, 32, 38);
INSERT INTO public.products VALUES ('P-067', 'Cat Kayu', 'Avian 1 kg', 85000, 0, false, 'http://localhost:8000/images/products/cat_avian.png', '2026-05-31 14:39:52.027204+07', '2026-06-04 18:57:11.485202+07', 'Lokal / Tanpa Merek', 1000, 'Galon', 1, 12, 12, 13);
INSERT INTO public.products VALUES ('P-069', 'Besi Beton', 'Besi Beton 6 SNI', 28000, 10, true, 'http://localhost:8000/images/products/besi_beton.png', '2026-05-31 14:39:52.029651+07', '2026-06-06 10:54:28.527552+07', 'Lokal / Tanpa Merek', 2660, 'Batang', 1, 1200, 1, 1);
INSERT INTO public.products VALUES ('P-076', 'Kloset', 'Kloset Jongkok Triliun', 205000, 0, true, 'http://localhost:8000/images/products/kloset_triliun.png', '2026-05-31 14:39:52.036426+07', '2026-06-04 18:57:11.525715+07', 'Triliun', 25000, 'Buah', 1, 51, 41, 24);
INSERT INTO public.products VALUES ('P-098', 'Listrik', 'Lampu Philips LED 9 Watt', 35000, 0, false, 'http://localhost:8000/storage/products/ZKSqy459MDsHotOFFmOwsUv4z6I4tZCQQGGmA4g3.webp', '2026-05-31 14:39:52.108225+07', '2026-06-04 18:57:11.540935+07', 'Philips', 80, 'Buah', 1, 11, 6, 6);
INSERT INTO public.products VALUES ('P-084', 'Perkakas', 'Mesin Bor Modern M2130', 395000, 0, false, 'http://localhost:8000/images/products/mesin_bor_m2130.png', '2026-05-31 14:39:52.064272+07', '2026-06-04 18:57:11.560096+07', 'Modern', 3000, 'Unit', 1, 21, 20, 7);
INSERT INTO public.products VALUES ('P-051', 'Cat Tembok', 'Decolith 5 kg', 145000, 0, false, 'http://localhost:8000/images/products/cat_decolith.png', '2026-05-31 14:39:52.013452+07', '2026-06-04 18:57:11.49023+07', 'Decolith', 5000, 'Galon', 1, 20, 20, 21);
INSERT INTO public.products VALUES ('P-099', 'Listrik', 'Lampu Philips LED 11 Watt', 42500, 0, false, 'http://localhost:8000/storage/products/QA0BglgcAbqnH6UIsPPugwbzFb4CZAnFBt4Te9bx.jpg', '2026-05-31 14:39:52.10964+07', '2026-06-04 18:57:11.54361+07', 'Philips', 100, 'Buah', 1, 13, 7, 7);
INSERT INTO public.products VALUES ('P-087', 'Perkakas', 'Mesin Gergaji Modern M2600', 625000, 0, false, 'http://localhost:8000/images/products/mesin_gergaji_m2600.png', '2026-05-31 14:39:52.066418+07', '2026-06-04 18:57:11.563615+07', 'Modern', 5000, 'Unit', 1, 30, 23, 24);
INSERT INTO public.products VALUES ('P-083', 'Perkakas', 'Mesin Bor Modern M2100', 295000, 6, false, 'http://localhost:8000/images/products/mesin_bor_m2100.png', '2026-05-31 14:39:52.062476+07', '2026-06-05 22:59:15.513395+07', 'Modern', 1300, 'Unit', 1, 25, 22, 7);
INSERT INTO public.products VALUES ('P-058', 'Cat Tembok', 'Aquaproof 20 kg', 1275000, 0, false, 'http://localhost:8000/images/products/cat_aquaproof.png', '2026-05-31 14:39:52.018376+07', '2026-06-04 18:57:11.502805+07', 'Aquaproof', 20000, 'Pail', 1, 32, 32, 38);
INSERT INTO public.products VALUES ('P-071', 'Besi Beton', 'Besi Beton 10 SNI', 71000, 0, true, 'http://localhost:8000/images/products/besi_beton.png', '2026-05-31 14:39:52.030857+07', '2026-06-04 18:57:11.470492+07', 'Lokal / Tanpa Merek', 7400, 'Batang', 1, 1200, 1, 1);
INSERT INTO public.products VALUES ('P-072', 'Besi Beton', 'Besi Beton 12 SNI', 105000, 0, true, 'http://localhost:8000/images/products/besi_beton.png', '2026-05-31 14:39:52.031946+07', '2026-06-04 18:57:11.471543+07', 'Lokal / Tanpa Merek', 10660, 'Batang', 1, 1200, 1, 1);
INSERT INTO public.products VALUES ('P-073', 'Besi Beton', 'Besi Beton 14 SNI', 134000, 0, true, 'http://localhost:8000/images/products/besi_beton.png', '2026-05-31 14:39:52.033126+07', '2026-06-04 18:57:11.472588+07', 'Lokal / Tanpa Merek', 13500, 'Batang', 1, 1200, 1, 1);
INSERT INTO public.products VALUES ('P-074', 'Besi Beton', 'Besi Beton 16 SNI', 195000, 45, true, 'http://localhost:8000/images/products/besi_beton.png', '2026-05-31 14:39:52.034298+07', '2026-06-04 19:51:34.406411+07', 'Lokal / Tanpa Merek', 18960, 'Batang', 1, 1200, 2, 2);
INSERT INTO public.products VALUES ('P-062', 'Cat Kayu', 'Emco Warna Standart 0.5 kg', 47500, 0, false, 'http://localhost:8000/images/products/cat_emco.png', '2026-05-31 14:39:52.020583+07', '2026-06-04 18:57:11.473631+07', 'Lokal / Tanpa Merek', 500, 'Pcs', 1, 10, 10, 10);
INSERT INTO public.products VALUES ('P-080', 'Kloset', 'Monoblok Volk', 1250000, 0, true, 'http://localhost:8000/images/products/monoblok_volk.png', '2026-05-31 14:39:52.045146+07', '2026-06-04 18:57:11.527379+07', 'Volk', 25000, 'Buah', 1, 66, 35, 77);
INSERT INTO public.products VALUES ('P-061', 'Cat Kayu', 'Emco Warna Standart 1 kg', 85000, 32, false, 'http://localhost:8000/images/products/cat_emco.png', '2026-05-31 14:39:52.020021+07', '2026-06-13 21:35:01.481526+07', 'Emco', 1000, 'Kaleng', 1, 12, 12, 13);
INSERT INTO public.products VALUES ('P-055', 'Cat Tembok', 'No. Drop 4 kg', 245000, 0, false, 'http://localhost:8000/images/products/cat_nodrop.png', '2026-05-31 14:39:52.016722+07', '2026-06-04 18:57:11.496909+07', 'Cat Tembok', 4000, 'Galon', 1, 20, 20, 21);
INSERT INTO public.products VALUES ('P-079', 'Kloset', 'Monoblok Triliun', 1525000, 0, true, 'http://localhost:8000/images/products/monoblok_triliun.png', '2026-05-31 14:39:52.042023+07', '2026-06-04 18:57:11.527379+07', 'Triliun', 25000, 'Buah', 1, 65, 37, 75);
INSERT INTO public.products VALUES ('P-057', 'Cat Tembok', 'Aquaproof 4 kg', 265000, 0, false, 'http://localhost:8000/images/products/cat_aquaproof.png', '2026-05-31 14:39:52.01783+07', '2026-06-04 18:57:11.499407+07', 'Aquaproof', 4000, 'Galon', 1, 20, 20, 21);
INSERT INTO public.products VALUES ('P-070', 'Besi Beton', 'Besi Beton 8 SNI', 46000, 0, true, 'http://localhost:8000/images/products/besi_beton.png', '2026-05-31 14:39:52.030209+07', '2026-06-04 18:57:11.469977+07', 'Lokal / Tanpa Merek', 4740, 'Batang', 1, 1200, 1, 1);
INSERT INTO public.products VALUES ('P-107', 'Kuas Cat', 'Kuas Eterna 5 Inch', 30000, 0, false, 'http://localhost:8000/images/products/kuas_eterna.png', '2026-05-31 14:39:52.114666+07', '2026-06-04 18:57:11.531415+07', 'Eterna', 80, 'Pcs', 1, 24, 13, 2);
INSERT INTO public.products VALUES ('P-105', 'Kuas Cat', 'Kuas Eterna 3 Inch', 18000, 0, false, 'http://localhost:8000/images/products/kuas_eterna.png', '2026-05-31 14:39:52.113546+07', '2026-06-04 18:57:11.530167+07', 'Eterna', 80, 'Pcs', 1, 22, 8, 1);
INSERT INTO public.products VALUES ('P-075', 'Kloset', 'Kloset Jongkok INA', 210000, 0, true, 'http://localhost:8000/images/products/kloset_ina.png', '2026-05-31 14:39:52.034827+07', '2026-06-04 18:57:11.526856+07', 'INA', 25000, 'Buah', 1, 50, 40, 24);
INSERT INTO public.products VALUES ('P-011', 'Perpipaan', 'Pipa Maspion 1 AW', 56000, 0, false, 'http://localhost:8000/images/products/semen_sika_granit.png', '2026-05-31 14:39:51.984831+07', '2026-06-04 18:57:11.579935+07', 'Maspion', 1800, 'Batang', 1, 400, 3, 3);
INSERT INTO public.products VALUES ('P-128', 'Engsel', 'Engsel Lemari Tipis 2 Inch', 7000, 15, false, 'http://localhost:8000/images/products/engsel_lemari.png', '2026-05-31 14:39:52.128423+07', '2026-06-14 18:21:24.656898+07', 'Lokal / Tanpa Merek', 100, 'Buah', 1, 5, 4, 1);
INSERT INTO public.products VALUES ('P-121', 'Engsel', 'Engsel Pintu Muller 4 Inch', 75000, 0, false, 'http://localhost:8000/images/products/engsel_muller.png', '2026-05-31 14:39:52.123095+07', '2026-06-04 18:57:11.508119+07', 'Muller', 200, 'Buah', 1, 10, 8, 1);
INSERT INTO public.products VALUES ('P-134', 'Keramik & Granite', 'Keramik Dinding 30x60 cm', 90000, 0, true, 'http://localhost:8000/images/products/keramik_dinding.png', '2026-05-31 14:39:52.131875+07', '2026-06-04 18:57:11.512351+07', 'Lokal / Tanpa Merek', 16000, 'Dus', 1, 60, 30, 1);
INSERT INTO public.products VALUES ('P-110', 'Kuas Cat', 'Kuas Roll 4 Inch', 15000, 0, false, 'http://localhost:8000/images/products/kuas_roll.png', '2026-05-31 14:39:52.116373+07', '2026-06-04 18:57:11.530167+07', 'Lokal / Tanpa Merek', 1000, 'Pcs', 1, 30, 10, 5);
INSERT INTO public.products VALUES ('P-119', 'Kunci Pintu', 'Kunci Pintu Kuda Kecil', 95000, 0, false, 'http://localhost:8000/images/products/kunci_pintu.png', '2026-05-31 14:39:52.121969+07', '2026-06-04 18:57:11.533541+07', 'Lokal / Tanpa Merek', 600, 'Buah', 1, 20, 13, 7);
INSERT INTO public.products VALUES ('P-125', 'Engsel', 'Engsel Pintu Nishio 3 Inch', 20000, 0, false, 'http://localhost:8000/images/products/engsel_nishio.png', '2026-05-31 14:39:52.126761+07', '2026-06-04 18:57:11.505504+07', 'Nishio', 100, 'Buah', 1, 8, 6, 1);
INSERT INTO public.products VALUES ('P-132', 'Keramik & Granite', 'Keramik Dinding 25x40 cm', 65000, 0, true, 'http://localhost:8000/images/products/keramik_dinding.png', '2026-05-31 14:39:52.130712+07', '2026-06-04 18:57:11.510267+07', 'Lokal / Tanpa Merek', 16000, 'Dus', 1, 40, 25, 1);
INSERT INTO public.products VALUES ('P-010', 'Perpipaan', 'Pipa Maspion 3/4 AW', 42000, 0, false, 'http://localhost:8000/images/products/semen_drymix.png', '2026-05-31 14:39:51.984233+07', '2026-06-04 18:57:11.573132+07', 'Maspion', 1200, 'Batang', 1, 400, 3, 3);
INSERT INTO public.products VALUES ('P-109', 'Kuas Cat', 'Kuas Roll Eterna 9 Inch', 30000, 0, false, 'http://localhost:8000/images/products/kuas_roll.png', '2026-05-31 14:39:52.115807+07', '2026-06-04 18:57:11.531985+07', 'Eterna', 1000, 'Pcs', 1, 33, 23, 7);
INSERT INTO public.products VALUES ('P-114', 'Kunci Pintu', 'Kunci Pintu Zeona Tanggung', 110000, 0, false, 'http://localhost:8000/images/products/kunci_pintu_zeona.png', '2026-05-31 14:39:52.118648+07', '2026-06-04 18:57:11.533541+07', 'Zeona', 800, 'Buah', 1, 24, 14, 8);
INSERT INTO public.products VALUES ('P-136', 'Keramik & Granite', 'Granite Motif 60x60 cm', 165000, 0, true, 'http://localhost:8000/images/products/granite_tile.png', '2026-05-31 14:39:52.133564+07', '2026-06-04 18:57:11.513394+07', 'Lokal / Tanpa Merek', 30000, 'Dus', 1, 60, 60, 1);
INSERT INTO public.products VALUES ('P-135', 'Keramik & Granite', 'Granite Polos 60x60 cm', 145000, 0, true, 'http://localhost:8000/images/products/granite_tile.png', '2026-05-31 14:39:52.132463+07', '2026-06-04 18:57:11.512873+07', 'Lokal / Tanpa Merek', 30000, 'Dus', 1, 60, 60, 1);
INSERT INTO public.products VALUES ('P-129', 'Keramik & Granite', 'Keramik Lantai 40x40 cm', 55000, 0, true, 'http://localhost:8000/images/products/keramik_lantai.png', '2026-05-31 14:39:52.129018+07', '2026-06-04 18:57:11.50973+07', 'Lokal / Tanpa Merek', 17000, 'Dus', 1, 40, 40, 1);
INSERT INTO public.products VALUES ('P-013', 'Perpipaan', 'Pipa Maspion 1 1/2 AW', 98000, 0, false, 'http://localhost:8000/images/products/pipa_maspion_aw.png', '2026-05-31 14:39:51.985925+07', '2026-06-04 18:57:11.587561+07', 'Maspion', 3100, 'Batang', 1, 400, 5, 5);
INSERT INTO public.products VALUES ('P-111', 'Kuas Cat', 'Kuas Roll Imundex 9 Inch', 30000, 0, false, 'http://localhost:8000/images/products/kuas_roll_imundex.png', '2026-05-31 14:39:52.116944+07', '2026-06-04 18:57:11.531985+07', 'Imundex', 1000, 'Pcs', 1, 33, 23, 7);
INSERT INTO public.products VALUES ('P-112', 'Kuas Cat', 'Kuas Roll Imundex 7 Inch', 25000, 0, false, 'http://localhost:8000/images/products/kuas_roll_imundex.png', '2026-05-31 14:39:52.117502+07', '2026-06-04 18:57:11.531415+07', 'Imundex', 1000, 'Pcs', 1, 30, 18, 6);
INSERT INTO public.products VALUES ('P-133', 'Keramik & Granite', 'Keramik Dinding 25x50 cm', 75000, 0, true, 'http://localhost:8000/images/products/keramik_dinding.png', '2026-05-31 14:39:52.131302+07', '2026-06-04 18:57:11.511819+07', 'Lokal / Tanpa Merek', 16000, 'Dus', 1, 50, 25, 1);
INSERT INTO public.products VALUES ('P-012', 'Perpipaan', 'Pipa Maspion 1 1/4 AW', 74000, 0, false, 'http://localhost:8000/images/products/pipa_maspion_aw.png', '2026-05-31 14:39:51.985415+07', '2026-06-04 18:57:11.584516+07', 'Maspion', 2400, 'Batang', 1, 400, 4, 4);
INSERT INTO public.products VALUES ('P-124', 'Engsel', 'Engsel Pintu Nishio 4 Inch', 35000, 0, false, 'http://localhost:8000/images/products/engsel_nishio.png', '2026-05-31 14:39:52.126219+07', '2026-06-04 18:57:11.506029+07', 'Nishio', 200, 'Buah', 1, 10, 8, 1);
INSERT INTO public.products VALUES ('P-014', 'Perpipaan', 'Pipa Maspion 2 AW', 138000, 0, false, 'http://localhost:8000/images/products/pipa_maspion_aw.png', '2026-05-31 14:39:51.986459+07', '2026-06-04 18:57:11.589208+07', 'Maspion', 4500, 'Batang', 1, 400, 6, 6);
INSERT INTO public.products VALUES ('P-118', 'Kunci Pintu', 'Kunci Pintu Kuda Besar', 125000, 0, false, 'http://localhost:8000/images/products/kunci_pintu.png', '2026-05-31 14:39:52.120818+07', '2026-06-04 18:57:11.534071+07', 'Lokal / Tanpa Merek', 1000, 'Buah', 1, 26, 15, 8);
INSERT INTO public.products VALUES ('P-113', 'Kunci Pintu', 'Kunci Pintu Zeona Besar', 175000, 0, false, 'http://localhost:8000/images/products/kunci_pintu_zeona.png', '2026-05-31 14:39:52.118099+07', '2026-06-04 18:57:11.535626+07', 'Zeona', 1000, 'Buah', 1, 26, 15, 8);
INSERT INTO public.products VALUES ('P-117', 'Kunci Pintu', 'Kunci Pintu Muller Tanggung', 245000, 0, false, 'http://localhost:8000/images/products/kunci_pintu_muller.png', '2026-05-31 14:39:52.120308+07', '2026-06-04 18:57:11.536144+07', 'Muller', 800, 'Buah', 1, 24, 14, 8);
INSERT INTO public.products VALUES ('P-015', 'Perpipaan', 'Pipa Maspion 2 1/2 AW', 185000, 0, false, 'http://localhost:8000/images/products/pipa_maspion_aw.png', '2026-05-31 14:39:51.987042+07', '2026-06-04 18:57:11.589733+07', 'Maspion', 5700, 'Batang', 1, 400, 8, 8);
INSERT INTO public.products VALUES ('P-104', 'Kuas Cat', 'Kuas Eterna 2.5 Inch', 15000, 0, false, 'http://localhost:8000/images/products/kuas_eterna.png', '2026-05-31 14:39:52.11295+07', '2026-06-04 18:57:11.529661+07', 'Eterna', 60, 'Pcs', 1, 21, 6, 1);
INSERT INTO public.products VALUES ('P-116', 'Kunci Pintu', 'Kunci Pintu Muller Besar', 325000, 0, false, 'http://localhost:8000/images/products/kunci_pintu_muller.png', '2026-05-31 14:39:52.11976+07', '2026-06-04 18:57:11.536775+07', 'Muller', 1000, 'Buah', 1, 30, 16, 9);
INSERT INTO public.products VALUES ('P-123', 'Engsel', 'Engsel Pintu Nishio 5 Inch', 45000, 0, false, 'http://localhost:8000/images/products/engsel_nishio.png', '2026-05-31 14:39:52.12514+07', '2026-06-04 18:57:11.506545+07', 'Nishio', 300, 'Buah', 1, 13, 8, 1);
INSERT INTO public.products VALUES ('P-130', 'Keramik & Granite', 'Keramik Lantai 50x50 cm', 65000, 0, true, 'http://localhost:8000/images/products/keramik_lantai.png', '2026-05-31 14:39:52.129583+07', '2026-06-04 18:57:11.511297+07', 'Lokal / Tanpa Merek', 17000, 'Dus', 1, 50, 50, 1);
INSERT INTO public.products VALUES ('P-120', 'Engsel', 'Engsel Pintu Muller 5 Inch', 95000, 0, false, 'http://localhost:8000/images/products/engsel_muller.png', '2026-05-31 14:39:52.122497+07', '2026-06-04 18:57:11.508642+07', 'Muller', 300, 'Buah', 1, 13, 8, 1);
INSERT INTO public.products VALUES ('P-003', 'Semen', 'Semen Singa Merah 40 kg', 45000, 30, true, 'http://localhost:8000/storage/products/TQMhtGWD7ZCbL8BRjLbSqdxcKXCUpHdM4LmrcHAa.jpg', '2026-05-31 14:39:51.978921+07', '2026-06-11 11:58:25.742002+07', 'Semen', 40000, 'Sak', 10, 55, 40, 10);
INSERT INTO public.products VALUES ('P-122', 'Engsel', 'Engsel Pintu Muller 3 Inch', 45000, 0, false, 'http://localhost:8000/images/products/engsel_muller.png', '2026-05-31 14:39:52.123625+07', '2026-06-04 18:57:11.507068+07', 'Muller', 100, 'Buah', 1, 8, 6, 1);
INSERT INTO public.products VALUES ('P-126', 'Engsel', 'Engsel Lemari Tipis 3 Inch', 10000, 0, false, 'http://localhost:8000/images/products/engsel_lemari.png', '2026-05-31 14:39:52.127349+07', '2026-06-04 18:57:11.504984+07', 'Lokal / Tanpa Merek', 100, 'Buah', 1, 8, 5, 1);
INSERT INTO public.products VALUES ('P-048', 'Perpipaan', 'Pipa Rucika 5 AW', 595000, 0, false, 'http://localhost:8000/images/products/pipa_rucika_aw.png', '2026-05-31 14:39:52.011244+07', '2026-06-04 18:57:11.595726+07', 'Rucika', 17850, 'Batang', 1, 400, 14, 14);
INSERT INTO public.products VALUES ('P-044', 'Perpipaan', 'Pipa Rucika 2 AW', 128000, 0, false, 'http://localhost:8000/images/products/pipa_rucika_aw.png', '2026-05-31 14:39:52.006316+07', '2026-06-04 18:57:11.588665+07', 'Rucika', 4490, 'Batang', 1, 400, 6, 6);
INSERT INTO public.products VALUES ('P-035', 'Perpipaan', 'Pipa Maspion 4 D', 189000, 0, false, 'http://localhost:8000/images/products/pipa_maspion_d.png', '2026-05-31 14:39:52.000348+07', '2026-06-04 18:57:11.590245+07', 'Maspion', 7000, 'Batang', 1, 400, 11, 11);
INSERT INTO public.products VALUES ('P-085', 'Perkakas', 'Mesin Gerinda Modern M2350', 325000, 0, false, 'http://localhost:8000/images/products/mesin_gerinda_m2350.png', '2026-05-31 14:39:52.065288+07', '2026-06-04 18:57:11.558887+07', 'Modern', 2000, 'Unit', 1, 30, 12, 11);
INSERT INTO public.products VALUES ('P-017', 'Perpipaan', 'Pipa Maspion 4 AW', 385000, 0, false, 'http://localhost:8000/images/products/pipa_maspion_aw.png', '2026-05-31 14:39:51.98871+07', '2026-06-04 18:57:11.593451+07', 'Maspion', 13600, 'Batang', 1, 400, 11, 11);
INSERT INTO public.products VALUES ('P-065', 'Cat Kayu', 'Emco Warna Bintang 1 kg', 102000, 0, false, 'http://localhost:8000/images/products/cat_emco.png', '2026-05-31 14:39:52.02355+07', '2026-06-04 18:57:11.488114+07', 'Lokal / Tanpa Merek', 1000, 'Galon', 1, 12, 12, 13);
INSERT INTO public.products VALUES ('P-063', 'Cat Kayu', 'Emco Warna Gunung 1 kg', 95000, 0, false, 'http://localhost:8000/images/products/cat_emco.png', '2026-05-31 14:39:52.021619+07', '2026-06-04 18:57:11.487083+07', 'Lokal / Tanpa Merek', 1000, 'Galon', 1, 12, 12, 13);
INSERT INTO public.products VALUES ('P-052', 'Cat Tembok', 'Decolith 25 kg', 725000, 0, false, 'http://localhost:8000/images/products/cat_decolith.png', '2026-05-31 14:39:52.015031+07', '2026-06-04 18:57:11.50123+07', 'Decolith', 25000, 'Pail', 1, 32, 32, 38);
INSERT INTO public.products VALUES ('P-016', 'Perpipaan', 'Pipa Maspion 3 AW', 255000, 0, false, 'http://localhost:8000/images/products/pipa_maspion_aw.png', '2026-05-31 14:39:51.987616+07', '2026-06-04 18:57:11.590245+07', 'Maspion', 8800, 'Batang', 1, 400, 9, 9);
INSERT INTO public.products VALUES ('P-029', 'Perpipaan', 'Pipa Maspion 4 C', 102000, 0, false, 'http://localhost:8000/images/products/pipa_maspion_c.png', '2026-05-31 14:39:51.996827+07', '2026-06-04 18:57:11.588074+07', 'Maspion', 13200, 'Batang', 1, 400, 11, 11);
INSERT INTO public.products VALUES ('P-026', 'Perpipaan', 'Pipa Maspion 2 C', 58000, 0, false, 'http://localhost:8000/images/products/pipa_maspion_c.png', '2026-05-31 14:39:51.995067+07', '2026-06-04 18:57:11.581666+07', 'Maspion', 5200, 'Batang', 1, 400, 6, 6);
INSERT INTO public.products VALUES ('P-108', 'Kuas Cat', 'Kuas Eterna 6 Inch', 35000, 0, false, 'http://localhost:8000/images/products/kuas_eterna.png', '2026-05-31 14:39:52.115245+07', '2026-06-04 18:57:11.532506+07', 'Eterna', 80, 'Pcs', 1, 25, 15, 2);
INSERT INTO public.products VALUES ('P-039', 'Perpipaan', 'Pipa Rucika 1/2 AW', 32000, 0, false, 'http://localhost:8000/images/products/pipa_rucika_aw.png', '2026-05-31 14:39:52.002734+07', '2026-06-04 18:57:11.567771+07', 'Rucika', 1020, 'Batang', 1, 400, 2, 2);
INSERT INTO public.products VALUES ('P-018', 'Perpipaan', 'Pipa Maspion 5 AW', 575000, 0, false, 'http://localhost:8000/images/products/pipa_maspion_aw.png', '2026-05-31 14:39:51.989223+07', '2026-06-04 18:57:11.595219+07', 'Maspion', 17800, 'Batang', 1, 400, 14, 14);
INSERT INTO public.products VALUES ('P-064', 'Cat Kayu', 'Emco Warna Gunung 0.5 kg', 55000, 0, false, 'http://localhost:8000/images/products/cat_emco.png', '2026-05-31 14:39:52.022136+07', '2026-06-04 18:57:11.480695+07', 'Lokal / Tanpa Merek', 500, 'Pcs', 1, 10, 10, 10);
INSERT INTO public.products VALUES ('P-045', 'Perpipaan', 'Pipa Rucika 2 1/2 AW', 175000, 0, false, 'http://localhost:8000/images/products/pipa_rucika_aw.png', '2026-05-31 14:39:52.006858+07', '2026-06-04 18:57:11.589733+07', 'Rucika', 5780, 'Batang', 1, 400, 8, 8);
INSERT INTO public.products VALUES ('P-040', 'Perpipaan', 'Pipa Rucika 3/4 AW', 42000, 0, false, 'http://localhost:8000/images/products/pipa_rucika_aw.png', '2026-05-31 14:39:52.003304+07', '2026-06-04 18:57:11.5745+07', 'Rucika', 1240, 'Batang', 1, 400, 3, 3);
INSERT INTO public.products VALUES ('P-046', 'Perpipaan', 'Pipa Rucika 3 AW', 255000, 0, false, 'http://localhost:8000/images/products/pipa_rucika_aw.png', '2026-05-31 14:39:52.00907+07', '2026-06-04 18:57:11.590793+07', 'Rucika', 8810, 'Batang', 1, 400, 9, 9);
INSERT INTO public.products VALUES ('P-027', 'Perpipaan', 'Pipa Maspion 2 1/2 C', 69000, 0, false, 'http://localhost:8000/images/products/pipa_maspion_c.png', '2026-05-31 14:39:51.995666+07', '2026-06-04 18:57:11.583329+07', 'Maspion', 6500, 'Batang', 1, 400, 8, 8);
INSERT INTO public.products VALUES ('P-030', 'Perpipaan', 'Pipa Maspion 1 1/4 D', 45000, 0, false, 'http://localhost:8000/images/products/pipa_maspion_d.png', '2026-05-31 14:39:51.997445+07', '2026-06-04 18:57:11.577052+07', 'Maspion', 1200, 'Batang', 1, 400, 4, 4);
INSERT INTO public.products VALUES ('P-036', 'Perpipaan', 'Pipa Maspion 5 D', 320000, 0, false, 'http://localhost:8000/images/products/pipa_maspion_d.png', '2026-05-31 14:39:52.000977+07', '2026-06-04 18:57:11.591386+07', 'Maspion', 10900, 'Batang', 1, 400, 14, 14);
INSERT INTO public.products VALUES ('P-032', 'Perpipaan', 'Pipa Maspion 2 D', 68000, 0, false, 'http://localhost:8000/images/products/pipa_maspion_d.png', '2026-05-31 14:39:51.998573+07', '2026-06-04 18:57:11.582712+07', 'Maspion', 2100, 'Batang', 1, 400, 6, 6);
INSERT INTO public.products VALUES ('P-020', 'Perpipaan', 'Pipa Maspion 8 AW', 1275000, 0, false, 'http://localhost:8000/images/products/pipa_maspion_aw.png', '2026-05-31 14:39:51.990424+07', '2026-06-04 18:57:11.59679+07', 'Maspion', 40500, 'Batang', 1, 400, 22, 22);
INSERT INTO public.products VALUES ('P-033', 'Perpipaan', 'Pipa Maspion 2 1/2 D', 98000, 0, false, 'http://localhost:8000/images/products/pipa_maspion_d.png', '2026-05-31 14:39:51.999155+07', '2026-06-04 18:57:11.587561+07', 'Maspion', 3300, 'Batang', 1, 400, 8, 8);
INSERT INTO public.products VALUES ('P-038', 'Perpipaan', 'Pipa Maspion 8 D', 730000, 0, false, 'http://localhost:8000/images/products/pipa_maspion_d.png', '2026-05-31 14:39:52.002145+07', '2026-06-04 18:57:11.595726+07', 'Maspion', 25000, 'Batang', 1, 400, 22, 22);
INSERT INTO public.products VALUES ('P-050', 'Perpipaan', 'Pipa Rucika 8 AW', 1325000, 0, false, 'http://localhost:8000/images/products/pipa_rucika_aw.png', '2026-05-31 14:39:52.01237+07', '2026-06-04 18:57:11.59679+07', 'Rucika', 40500, 'Batang', 1, 400, 22, 22);
INSERT INTO public.products VALUES ('P-028', 'Perpipaan', 'Pipa Maspion 3 C', 79000, 0, false, 'http://localhost:8000/images/products/pipa_maspion_c.png', '2026-05-31 14:39:51.996273+07', '2026-06-04 18:57:11.586255+07', 'Maspion', 8000, 'Batang', 1, 400, 9, 9);
INSERT INTO public.products VALUES ('P-043', 'Perpipaan', 'Pipa Rucika 1 1/2 AW', 92000, 0, false, 'http://localhost:8000/images/products/pipa_rucika_aw.png', '2026-05-31 14:39:52.005098+07', '2026-06-04 18:57:11.587014+07', 'Rucika', 3160, 'Batang', 1, 400, 5, 5);
INSERT INTO public.products VALUES ('P-031', 'Perpipaan', 'Pipa Maspion 1 1/2 D', 55000, 0, false, 'http://localhost:8000/images/products/pipa_maspion_d.png', '2026-05-31 14:39:51.997991+07', '2026-06-04 18:57:11.577805+07', 'Maspion', 1700, 'Batang', 1, 400, 5, 5);
INSERT INTO public.products VALUES ('P-097', 'Listrik', 'Lampu Philips LED 7 Watt', 29000, 0, false, 'http://localhost:8000/storage/products/j4dV3hjEHL1p38w8hM6bkrdAhteqBJ4EW5TT6I3N.webp', '2026-05-31 14:39:52.102459+07', '2026-06-04 18:57:11.538508+07', 'Philips', 80, 'Buah', 1, 11, 6, 6);
INSERT INTO public.products VALUES ('P-088', 'Perkakas', 'Meteran Tukang 3 m', 25000, 0, false, 'http://localhost:8000/images/products/meteran_tukang.png', '2026-05-31 14:39:52.066933+07', '2026-06-04 18:57:11.546709+07', 'Perkakas', 150, 'Unit', 1, 7, 7, 3);
INSERT INTO public.products VALUES ('P-094', 'Perkakas', 'Palu Tukang Kotak 200 gram', 35000, 0, false, 'http://localhost:8000/images/products/palu_kotak.png', '2026-05-31 14:39:52.07218+07', '2026-06-04 18:57:11.549193+07', 'Perkakas', 200, 'Unit', 1, 28, 10, 3);
INSERT INTO public.products VALUES ('P-089', 'Perkakas', 'Meteran Tukang 5 m', 35000, 0, false, 'http://localhost:8000/images/products/meteran_tukang.png', '2026-05-31 14:39:52.067495+07', '2026-06-04 18:57:11.549695+07', 'Perkakas', 300, 'Unit', 1, 8, 8, 4);
INSERT INTO public.products VALUES ('P-086', 'Perkakas', 'Mesin Profil Modern M2700', 425000, 0, false, 'http://localhost:8000/images/products/mesin_profil_m2700.png', '2026-05-31 14:39:52.065829+07', '2026-06-04 18:57:11.560603+07', 'Modern', 2800, 'Unit', 1, 20, 15, 20);
INSERT INTO public.products VALUES ('P-092', 'Perkakas', 'Palu Tukang Supit 8 oz', 35000, 0, false, 'http://localhost:8000/images/products/palu_supit.png', '2026-05-31 14:39:52.069156+07', '2026-06-04 18:57:11.55044+07', 'Perkakas', 250, 'Unit', 1, 28, 10, 3);
INSERT INTO public.products VALUES ('P-001', 'Semen', 'Semen Gresik 40 kg', 59000, 80, true, 'http://localhost:8000/images/products/semen_gresik.png', '2026-05-31 14:39:51.972869+07', '2026-06-13 18:32:22.619396+07', 'Semen Gresik', 40000, 'Sak', 10, 55, 40, 10);
INSERT INTO public.products VALUES ('P-095', 'Perkakas', 'Palu Tukang Kotak 300 gram', 45000, 0, false, 'http://localhost:8000/images/products/palu_kotak.png', '2026-05-31 14:39:52.083282+07', '2026-06-04 18:57:11.55114+07', 'Perkakas', 300, 'Unit', 1, 30, 11, 3);
INSERT INTO public.products VALUES ('P-093', 'Perkakas', 'Palu Tukang Supit 12 oz', 45000, 0, false, 'http://localhost:8000/images/products/palu_supit.png', '2026-05-31 14:39:52.069677+07', '2026-06-04 18:57:11.552942+07', 'Perkakas', 350, 'Unit', 1, 32, 12, 3);
INSERT INTO public.products VALUES ('P-090', 'Perkakas', 'Meteran Tukang 7.5 m', 55000, 0, false, 'http://localhost:8000/images/products/meteran_tukang.png', '2026-05-31 14:39:52.068033+07', '2026-06-04 18:57:11.554015+07', 'Perkakas', 300, 'Unit', 1, 9, 9, 4);
INSERT INTO public.products VALUES ('P-091', 'Perkakas', 'Meteran Tukang 10 m', 55000, 0, false, 'http://localhost:8000/images/products/meteran_tukang.png', '2026-05-31 14:39:52.068589+07', '2026-06-04 18:57:11.554561+07', 'Perkakas', 600, 'Unit', 1, 10, 10, 5);
INSERT INTO public.products VALUES ('P-042', 'Perpipaan', 'Pipa Rucika 1 1/4 AW', 74000, 0, false, 'http://localhost:8000/images/products/pipa_rucika_aw.png', '2026-05-31 14:39:52.004529+07', '2026-06-04 18:57:11.585752+07', 'Rucika', 2420, 'Batang', 1, 400, 4, 4);
INSERT INTO public.products VALUES ('P-047', 'Perpipaan', 'Pipa Rucika 4 AW', 385000, 0, false, 'http://localhost:8000/images/products/pipa_rucika_aw.png', '2026-05-31 14:39:52.010145+07', '2026-06-04 18:57:11.592946+07', 'Rucika', 13630, 'Batang', 1, 400, 11, 11);
INSERT INTO public.products VALUES ('P-102', 'Kuas Cat', 'Kuas Eterna 1.5 Inch', 10000, 37, false, 'http://localhost:8000/images/products/kuas_eterna.png', '2026-05-31 14:39:52.1119+07', '2026-06-13 21:35:01.465812+07', 'Eterna', 60, 'Pcs', 1, 19, 4, 1);
INSERT INTO public.products VALUES ('P-037', 'Perpipaan', 'Pipa Maspion 6 D', 410000, 0, false, 'http://localhost:8000/images/products/pipa_maspion_d.png', '2026-05-31 14:39:52.001548+07', '2026-06-04 18:57:11.594702+07', 'Maspion', 15700, 'Batang', 1, 400, 17, 17);
INSERT INTO public.products VALUES ('P-019', 'Perpipaan', 'Pipa Maspion 6 AW', 765000, 0, false, 'http://localhost:8000/images/products/pipa_maspion_aw.png', '2026-05-31 14:39:51.989822+07', '2026-06-04 18:57:11.596245+07', 'Maspion', 26800, 'Batang', 1, 400, 17, 17);
INSERT INTO public.products VALUES ('P-103', 'Kuas Cat', 'Kuas Eterna 2 Inch', 12000, 0, false, 'http://localhost:8000/images/products/kuas_eterna.png', '2026-05-31 14:39:52.112428+07', '2026-06-04 18:57:11.528924+07', 'Eterna', 60, 'Pcs', 1, 20, 5, 1);


--
-- Data for Name: shippings; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.shippings VALUES (1, 'ORD-260531-793', 'Ambil Di Toko', '+62 8123388670', 0, 'Jalan Utara Masjid No.9, Dampit Wetan, Dampit, Kec. Dampit, Kabupaten Malang, Jawa Timur 65181', '2026-05-31 20:15:04.117735+07', '2026-05-31 20:15:04.117735+07', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.shippings VALUES (2, 'ORD-260531-325', 'Ambil Di Toko', '+62 8123388670', 0, 'Jalan Utara Masjid No.9, Dampit Wetan, Dampit, Kec. Dampit, Kabupaten Malang, Jawa Timur 65181', '2026-05-31 21:02:38.608987+07', '2026-05-31 21:02:38.608987+07', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.shippings VALUES (3, 'ORD-260601-785', 'Kurir Toko Sinar Abadi', '082331339737', 50000, 'Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Kec.Klojen, Kota Malang', '2026-06-01 19:38:17.40838+07', '2026-06-01 19:38:17.40838+07', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.shippings VALUES (4, 'ORD-260601-741', 'Kurir Toko Sinar Abadi', '082331339737', 50000, 'Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Kec.Klojen, Kota Malang', '2026-06-01 19:43:12.079096+07', '2026-06-01 19:43:12.079096+07', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.shippings VALUES (6, 'ORD-260603-541', 'JNE JNE Trucking', '082331339737', 1200000, 'Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-03 12:56:55.373742+07', '2026-06-03 13:04:20.398524+07', 'IDNP11IDNC250IDND2615IDZ65116', '6a1fc3e4cbc65424d57325cf', 'WYB-1780466660482', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.shippings VALUES (7, 'ORD-260603-437', 'Kurir Toko Sinar Abadi', '082331339737', 0, 'Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-03 13:56:18.760667+07', '2026-06-03 13:56:18.760667+07', 'IDNP11IDNC250IDND2615IDZ65116', '', '', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.shippings VALUES (9, 'ORD-260603-820', 'JNE JNE Trucking', '082331339737', 720000, 'Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-03 14:12:25.640116+07', '2026-06-03 14:12:50.919082+07', 'IDNP11IDNC250IDND2615IDZ65116', '6a1fd3f2023c6a44c4aba971', 'WYB-1780470770989', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.shippings VALUES (10, 'ORD-260603-503', 'Ambil Di Toko', '+62 8123388670', 0, 'Jalan Utara Masjid No.9, Dampit Wetan, Dampit, Kec. Dampit, Kabupaten Malang, Jawa Timur 65181', '2026-06-03 14:23:00.285802+07', '2026-06-03 14:23:00.285802+07', '', '', '', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.shippings VALUES (11, 'ORD-260603-731', 'Kurir Toko Sinar Abadi', '082331339737', 0, 'Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-03 14:34:02.584727+07', '2026-06-03 14:34:02.584727+07', 'IDNP11IDNC250IDND2615IDZ65116', '', '', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.shippings VALUES (20, 'ORD-260603-526', 'JNE', '082331339737', 14000, 'Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-03 21:01:13.648671+07', '2026-06-03 21:02:10.046842+07', 'IDNP11IDNC250IDND2615IDZ65116', 'TEST-ORDER-ID-210210', 'TEST-WAYBILL-ID', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.shippings VALUES (17, 'ORD-260603-971', 'JNE JNE Trucking', '082331339737', 40000, 'Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-03 19:30:22.984957+07', '2026-06-03 19:31:05.800237+07', 'IDNP11IDNC250IDND2615IDZ65116', '6a201e89b039b955b610526d', 'WYB-1780489865951', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.shippings VALUES (19, 'ORD-260603-324', 'JNE JNE Trucking', '082331339737', 40000, 'Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-03 20:39:29.377323+07', '2026-06-03 20:39:59.273208+07', 'IDNP11IDNC250IDND2615IDZ65116', '6a202eafb494767c15e4a51a', 'WYB-1780493999199', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.shippings VALUES (18, 'ORD-260603-941', 'JNE Reguler', '082331339737', 14000, 'Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-03 20:35:00.101123+07', '2026-06-03 20:36:08.19402+07', 'IDNP11IDNC250IDND2615IDZ65116', 'TEST-ORDER-ID-203608', 'TEST-WAYBILL-ID', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.shippings VALUES (16, 'ORD-260603-210', 'JNE JNE Trucking', '082331339737', 180000, 'Perumahan Ijen Nirwana Cluster Green River Blok C3 No 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-03 18:42:25.493049+07', '2026-06-03 18:43:01.259918+07', 'IDNP11IDNC250IDND2615IDZ65116', '6a201345fc5a3062a06561a1', 'WYB-1780486981486', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.shippings VALUES (15, 'ORD-260603-849', 'JNE JNE Trucking', '082331339737', 240000, 'Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-03 18:32:25.604474+07', '2026-06-03 18:33:03.467064+07', 'IDNP11IDNC250IDND2615IDZ65116', '6a2010efb49476dde6e404f4', 'WYB-1780486383638', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.shippings VALUES (14, 'ORD-260603-480', 'JNE JNE Trucking', '082331339737', 35000, 'Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-03 18:21:57.442688+07', '2026-06-03 18:30:28.357701+07', 'IDNP11IDNC250IDND2600IDZ65116', '', '', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.shippings VALUES (13, 'ORD-260603-300', 'JNE JNE Trucking', '082331339737', 45000, 'Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-03 18:09:36.873266+07', '2026-06-03 18:30:28.356221+07', 'IDNP11IDNC250IDND2600IDZ65116', '', '', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.shippings VALUES (12, 'ORD-260603-256', 'JNE JNE Trucking', '082331339737', 45000, 'Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-03 18:02:28.564516+07', '2026-06-03 18:30:28.353979+07', 'IDNP11IDNC250IDND2600IDZ65116', '', '', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.shippings VALUES (8, 'ORD-260603-153', 'JNE', '082331339737', 75000, 'Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-03 14:07:54.031833+07', '2026-06-03 18:30:28.34964+07', 'IDNP11IDNC250IDND2600IDZ65116', '', '', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.shippings VALUES (5, 'ORD-260603-721', 'JNE JNE Trucking', '082331339737', 2424000, 'Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-03 12:43:09.772773+07', '2026-06-03 12:52:25.47935+07', 'IDNP11IDNC250IDND2615IDZ65116', 'TEST-ORDER-ID-12345', 'TEST-WAYBILL-ID', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.shippings VALUES (23, 'ORD-260603-818', 'JNE', '082331339737', 600000, 'Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-03 21:33:29.825719+07', '2026-06-03 21:33:29.825719+07', 'IDNP11IDNC250IDND2615IDZ65116', '', '', '', '', NULL, NULL, NULL, NULL);
INSERT INTO public.shippings VALUES (21, 'ORD-260603-391', 'JNE', '082331339737', 140000, 'Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-03 21:22:38.218653+07', '2026-06-03 21:22:38.218653+07', 'IDNP11IDNC250IDND2615IDZ65116', '', '', '', '', NULL, NULL, NULL, NULL);
INSERT INTO public.shippings VALUES (22, 'ORD-260603-629', 'JNE', '082331339737', 40000, 'Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-03 21:30:02.74633+07', '2026-06-03 21:30:02.74633+07', 'IDNP11IDNC250IDND2615IDZ65116', '', '', '', '', NULL, NULL, NULL, NULL);
INSERT INTO public.shippings VALUES (24, 'ORD-260603-817', 'JNE JNE Trucking', '082331339737', 600000, 'Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-03 21:38:19.443334+07', '2026-06-03 21:38:55.613714+07', 'IDNP11IDNC250IDND2615IDZ65116', '6a203c7f3c6b1eb4c5464713', 'WYB-1780497535260', '', '', NULL, NULL, NULL, NULL);
INSERT INTO public.shippings VALUES (25, 'ORD-260604-224', 'SiCepat Cargo per kg with minimum 10 kg', '082331339737', 546000, 'Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-04 18:13:00.970167+07', '2026-06-04 18:13:48.698943+07', 'IDNP11IDNC250IDND2615IDZ65116', '6a215dede2940a2ed4bd75ff', 'WYB-1780571629236', NULL, NULL, 'sicepat', 'gokil', NULL, NULL);
INSERT INTO public.shippings VALUES (53, 'ORD-260610-330', 'JNE JNE Trucking', '082331339737', 1600000, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-10 23:31:12.020289+07', '2026-06-10 23:31:12.020289+07', 'IDNP11IDNC250IDND2615IDZ65116', '', '', NULL, NULL, 'jne', 'jtr', NULL, 0);
INSERT INTO public.shippings VALUES (26, 'ORD-260604-871', 'SiCepat Cargo per kg with minimum 10 kg', '082331339737', 1400000, 'Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-04 19:02:01.173541+07', '2026-06-04 19:02:44.049259+07', 'IDNP11IDNC250IDND2615IDZ65116', '6a216964d0b0cf146ccaff3f', 'WYB-1780574564529', NULL, NULL, 'sicepat', 'gokil', NULL, NULL);
INSERT INTO public.shippings VALUES (36, 'ORD-260605-558', 'SiCepat Cargo per kg with minimum 10 kg', '+6282132148698', 1400000, 'Perumahan Ijen Nirwana Blok C3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-05 16:36:47.726333+07', '2026-06-05 16:37:18.441033+07', 'IDNP11IDNC250IDND2615IDZ65116', '6a2298ce910e73db97e34508', 'WYB-1780652238694', NULL, NULL, 'sicepat', 'gokil', NULL, NULL);
INSERT INTO public.shippings VALUES (35, 'ORD-260605-629', 'SiCepat Cargo per kg with minimum 10 kg', '082331339737', 1400000, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116', '2026-06-05 15:44:02.10981+07', '2026-06-05 15:51:18.617431+07', 'IDNP11IDNC250IDND2615IDZ65116', '6a228e06cfb90453454968bb', 'WYB-1780649478843', NULL, NULL, 'sicepat', 'gokil', NULL, NULL);
INSERT INTO public.shippings VALUES (27, 'ORD-260604-204', 'SiCepat Cargo per kg with minimum 10 kg', '082331339737', 1732500, 'Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-04 19:51:34.414058+07', '2026-06-04 19:52:48.884328+07', 'IDNP11IDNC250IDND2615IDZ65116', '6a2175214c47f43a6329d657', 'WYB-1780577569085', NULL, NULL, 'sicepat', 'gokil', NULL, NULL);
INSERT INTO public.shippings VALUES (33, 'ORD-260604-787', 'JNE JNE Trucking', '082331339737', 112000, 'Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-04 22:41:12.802688+07', '2026-06-04 22:47:24.623649+07', 'IDNP11IDNC250IDND2615IDZ65116', '6a219e0c3c6b1ebd6f4eac7d', 'WYB-1780588044450', NULL, NULL, 'jne', 'jtr', NULL, NULL);
INSERT INTO public.shippings VALUES (28, 'ORD-260604-705', 'JNE Reguler', '082331339737', 7000, 'Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116', '2026-06-04 20:15:41.655741+07', '2026-06-04 20:19:12.265681+07', 'IDNP11IDNC250IDND2615IDZ65116', '6a217b50f5bd98286373e3c2', 'WYB-1780579152219', NULL, NULL, 'jne', 'reg', NULL, NULL);
INSERT INTO public.shippings VALUES (29, 'ORD-260604-795', 'JNE Reguler', '082331339737', 7000, 'Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-04 20:29:13.166322+07', '2026-06-04 20:29:13.166322+07', 'IDNP11IDNC250IDND2615IDZ65116', '', '', NULL, NULL, 'jne', 'reg', NULL, NULL);
INSERT INTO public.shippings VALUES (37, 'ORD-260605-444', 'SiCepat Cargo per kg with minimum 10 kg', '082331339737', 1400000, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116', '2026-06-05 20:25:48.71584+07', '2026-06-05 20:25:48.71584+07', 'IDNP11IDNC250IDND2615IDZ65116', '', '', NULL, NULL, 'sicepat', 'gokil', NULL, NULL);
INSERT INTO public.shippings VALUES (30, 'ORD-260604-969', 'Ambil Di Toko', '+62 8123388670', 0, 'Jalan Utara Masjid No.9, Dampit Wetan, Dampit, Kec. Dampit, Kabupaten Malang, Jawa Timur 65181', '2026-06-04 20:32:14.768082+07', '2026-06-04 20:32:14.768082+07', '', '', '', NULL, NULL, '', '', NULL, NULL);
INSERT INTO public.shippings VALUES (34, 'ORD-260605-340', 'SiCepat Cargo per kg with minimum 10 kg', '082331339737', 1400000, 'Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-05 10:25:25.577801+07', '2026-06-05 10:27:03.023196+07', 'IDNP11IDNC250IDND2615IDZ65116', '6a224207cfb904596b478a29', 'WYB-1780630023314', NULL, NULL, 'sicepat', 'gokil', NULL, NULL);
INSERT INTO public.shippings VALUES (31, 'ORD-260604-507', 'Kurir Toko Sinar Abadi', '082331339737', 0, 'Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-04 20:36:37.790421+07', '2026-06-04 20:36:37.790421+07', 'IDNP11IDNC250IDND2615IDZ65116', '', '', NULL, NULL, '', '', NULL, NULL);
INSERT INTO public.shippings VALUES (43, 'ORD-260605-128', 'Ambil Di Toko', '+62 8123388670', 0, 'Jalan Utara Masjid No.9, Dampit Wetan, Dampit, Kec. Dampit, Kabupaten Malang, Jawa Timur 65181', '2026-06-05 23:09:54.048255+07', '2026-06-05 23:09:54.048255+07', '', '', '', NULL, NULL, '', '', NULL, NULL);
INSERT INTO public.shippings VALUES (40, 'ORD-260605-729', 'JNE Reguler', '082331339737', 7000, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116', '2026-06-05 22:21:44.926951+07', '2026-06-05 22:22:18.698249+07', 'IDNP11IDNC250IDND2615IDZ65116', '6a22e9a9b039b9126b2156f1', 'WYB-1780672937884', NULL, NULL, 'jne', 'reg', NULL, NULL);
INSERT INTO public.shippings VALUES (32, 'ORD-260604-216', 'JNE JNE Trucking', '082331339737', 40000, 'Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-04 21:15:20.64804+07', '2026-06-04 21:16:05.843354+07', 'IDNP11IDNC250IDND2615IDZ65116', '6a2188a5e2940a4e82be6cf0', 'WYB-1780582565674', NULL, NULL, 'jne', 'jtr', NULL, NULL);
INSERT INTO public.shippings VALUES (38, 'ORD-260605-505', 'SiCepat Cargo per kg with minimum 10 kg', '082331339737', 1400000, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116', '2026-06-05 20:31:16.264906+07', '2026-06-05 20:31:56.314274+07', 'IDNP11IDNC250IDND2615IDZ65116', '6a22cfcbb039b9f5eb20ad63', 'WYB-1780666315610', NULL, NULL, 'sicepat', 'gokil', NULL, NULL);
INSERT INTO public.shippings VALUES (39, 'ORD-260605-636', 'Kurir Toko Sinar Abadi', '082331339737', 0, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Gambir, Jakarta Pusat, DKI Jakarta. 10110', '2026-06-05 22:09:03.381613+07', '2026-06-05 22:09:03.381613+07', 'IDNP6IDNC147IDND829IDZ10110', '', '', NULL, NULL, 'jne', 'reg', NULL, NULL);
INSERT INTO public.shippings VALUES (41, 'ORD-260605-279', 'JNE Reguler', '082331339737', 7000, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116', '2026-06-05 22:59:15.52+07', '2026-06-05 23:02:32.335716+07', 'IDNP11IDNC250IDND2615IDZ65116', '6a22f312cfb90459dd4bf116', 'WYB-1780675346481', NULL, NULL, 'jne', 'reg', NULL, NULL);
INSERT INTO public.shippings VALUES (42, 'ORD-260605-300', 'Ambil Di Toko', '+62 8123388670', 0, 'Jalan Utara Masjid No.9, Dampit Wetan, Dampit, Kec. Dampit, Kabupaten Malang, Jawa Timur 65181', '2026-06-05 23:06:56.935763+07', '2026-06-05 23:06:56.935763+07', '', '', '', NULL, NULL, '', '', NULL, NULL);
INSERT INTO public.shippings VALUES (45, 'ORD-260606-149', 'SiCepat Cargo per kg with minimum 10 kg', '082331339737', 94500, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-06 10:54:28.534878+07', '2026-06-06 10:55:23.350629+07', 'IDNP11IDNC250IDND2615IDZ65116', '6a239a2b35e4ab234e78d177', 'WYB-1780718123329', NULL, NULL, 'sicepat', 'gokil', NULL, NULL);
INSERT INTO public.shippings VALUES (44, 'ORD-260606-964', 'JNE Reguler', '082331339737', 7000, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-06 10:10:18.528861+07', '2026-06-06 10:11:28.645867+07', 'IDNP11IDNC250IDND2615IDZ65116', '6a238fe03c6b1ea2805a832b', 'WYB-1780715488532', NULL, NULL, 'jne', 'reg', NULL, NULL);
INSERT INTO public.shippings VALUES (46, 'ORD-260606-731', 'JNE Reguler', '082331339737', 35000, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-06 14:56:38.051148+07', '2026-06-06 14:58:17.769778+07', 'IDNP11IDNC250IDND2615IDZ65116', '6a23d319910e734986eb37af', 'WYB-1780732697284', NULL, NULL, 'jne', 'reg', NULL, NULL);
INSERT INTO public.shippings VALUES (47, 'ORD-260606-680', 'JNE Reguler', '082331339737', 7000, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-06 20:39:01.696732+07', '2026-06-06 20:40:06.756523+07', 'IDNP11IDNC250IDND2615IDZ65116', '6a242336b039b96d32292f02', 'WYB-1780753206544', NULL, NULL, 'jne', 'reg', NULL, 0);
INSERT INTO public.shippings VALUES (48, 'ORD-260606-995', 'JNE JNE Trucking', '082331339737', 1600000, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-06 20:50:00.933044+07', '2026-06-06 20:51:13.959809+07', 'IDNP11IDNC250IDND2615IDZ65116', '6a2425d1b039b9aa02293f3e', 'WYB-1780753873795', NULL, NULL, 'jne', 'jtr', NULL, 0);
INSERT INTO public.shippings VALUES (49, 'ORD-260608-999', 'JNE JNE Trucking', '082331339737', 1880000, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-08 07:51:36.891347+07', '2026-06-08 07:53:23.887157+07', 'IDNP11IDNC250IDND2615IDZ65116', '6a261283d5f8a57c7b604f60', 'WYB-1780880003770', NULL, NULL, 'jne', 'jtr', NULL, 0);
INSERT INTO public.shippings VALUES (51, 'ORD-260610-883', 'JNE JNE Trucking', '082331339737', 1600000, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-10 14:49:22.886242+07', '2026-06-10 14:49:22.886242+07', 'IDNP11IDNC250IDND2615IDZ65116', '', '', NULL, NULL, 'jne', 'jtr', NULL, 0);
INSERT INTO public.shippings VALUES (54, 'ORD-260611-975', 'JNE JNE Trucking', '082331339737', 1600000, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-11 11:35:05.214734+07', '2026-06-11 11:35:05.214734+07', 'IDNP11IDNC250IDND2615IDZ65116', '', '', NULL, NULL, 'jne', 'jtr', NULL, 0);
INSERT INTO public.shippings VALUES (76, 'ORD-260611-399', 'JNE Reguler', '082331339737', 7000, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-11 19:12:01.389035+07', '2026-06-11 19:12:01.389035+07', 'IDNP11IDNC250IDND2615IDZ65116', '', '', NULL, NULL, 'jne', 'reg', NULL, 0);
INSERT INTO public.shippings VALUES (77, 'ORD-260613-471', 'JNE JNE Trucking', '082331339737', 1600000, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-13 18:32:22.653088+07', '2026-06-13 18:32:22.653088+07', 'IDNP11IDNC250IDND2615IDZ65116', '', '', NULL, NULL, 'jne', 'jtr', NULL, 0);
INSERT INTO public.shippings VALUES (78, 'ORD-260613-517', 'JNE Reguler', '081234567890', 7000, 'Perumahan Ijen Nirwana Blok C3 no 11', '2026-06-13 21:14:24.512424+07', '2026-06-13 21:14:24.512424+07', 'IDNP11IDNC250IDND2615IDZ65116', '', '', NULL, NULL, 'jne', 'reg', NULL, 0);
INSERT INTO public.shippings VALUES (55, 'ORD-260611-855', 'JNE JNE Trucking', '082331339737', 1600000, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-11 11:49:15.662876+07', '2026-06-11 11:51:01.589625+07', 'IDNP11IDNC250IDND2615IDZ65116', '6a2a3eb5a720080330539a70', 'WYB-1781153461541', NULL, NULL, 'jne', 'jtr', NULL, 0);
INSERT INTO public.shippings VALUES (56, 'ORD-260611-298', 'JNE JNE Trucking', '082331339737', 1600000, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-11 11:58:25.745679+07', '2026-06-11 11:58:25.745679+07', 'IDNP11IDNC250IDND2615IDZ65116', '', '', NULL, NULL, 'jne', 'jtr', NULL, 0);
INSERT INTO public.shippings VALUES (57, 'ORD-260611-681', 'JNE Reguler', '082331339737', 7000, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-11 12:15:51.093905+07', '2026-06-11 12:15:51.093905+07', 'IDNP11IDNC250IDND2615IDZ65116', '', '', NULL, NULL, 'jne', 'reg', NULL, 0);
INSERT INTO public.shippings VALUES (58, 'ORD-260611-815', 'JNE Reguler', '082331339737', 7000, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-11 12:31:51.127644+07', '2026-06-11 12:31:51.127644+07', 'IDNP11IDNC250IDND2615IDZ65116', '', '', NULL, NULL, 'jne', 'reg', NULL, 0);
INSERT INTO public.shippings VALUES (59, 'ORD-260611-735', 'JNE Reguler', '082331339737', 7000, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-11 12:32:45.184284+07', '2026-06-11 12:32:45.184284+07', 'IDNP11IDNC250IDND2615IDZ65116', '', '', NULL, NULL, 'jne', 'reg', NULL, 0);
INSERT INTO public.shippings VALUES (60, 'ORD-260611-740', 'JNE Reguler', '082331339737', 7000, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-11 12:41:21.524318+07', '2026-06-11 12:41:21.524318+07', 'IDNP11IDNC250IDND2615IDZ65116', '', '', NULL, NULL, 'jne', 'reg', NULL, 0);
INSERT INTO public.shippings VALUES (61, 'ORD-260611-474', 'JNE Reguler', '082331339737', 7000, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-11 18:33:38.945767+07', '2026-06-11 18:33:38.945767+07', 'IDNP11IDNC250IDND2615IDZ65116', '', '', NULL, NULL, 'jne', 'reg', NULL, 0);
INSERT INTO public.shippings VALUES (62, 'ORD-260611-253', 'JNE Reguler', '082331339737', 7000, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-11 18:36:06.420892+07', '2026-06-11 18:36:06.420892+07', 'IDNP11IDNC250IDND2615IDZ65116', '', '', NULL, NULL, 'jne', 'reg', NULL, 0);
INSERT INTO public.shippings VALUES (63, 'ORD-260611-824', 'JNE Reguler', '082331339737', 7000, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-11 18:36:15.471208+07', '2026-06-11 18:36:15.471208+07', 'IDNP11IDNC250IDND2615IDZ65116', '', '', NULL, NULL, 'jne', 'reg', NULL, 0);
INSERT INTO public.shippings VALUES (64, 'ORD-260611-870', 'JNE Reguler', '082331339737', 7000, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-11 18:38:01.136439+07', '2026-06-11 18:38:01.136439+07', 'IDNP11IDNC250IDND2615IDZ65116', '', '', NULL, NULL, 'jne', 'reg', NULL, 0);
INSERT INTO public.shippings VALUES (65, 'ORD-260611-305', 'JNE Reguler', '082331339737', 7000, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-11 18:40:36.962183+07', '2026-06-11 18:40:36.962183+07', 'IDNP11IDNC250IDND2615IDZ65116', '', '', NULL, NULL, 'jne', 'reg', NULL, 0);
INSERT INTO public.shippings VALUES (66, 'ORD-260611-457', 'JNE Reguler', '082331339737', 7000, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-11 18:42:25.82175+07', '2026-06-11 18:42:25.82175+07', 'IDNP11IDNC250IDND2615IDZ65116', '', '', NULL, NULL, 'jne', 'reg', NULL, 0);
INSERT INTO public.shippings VALUES (67, 'ORD-260611-487', 'JNE Reguler', '082331339737', 7000, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-11 18:48:46.722222+07', '2026-06-11 18:48:46.722222+07', 'IDNP11IDNC250IDND2615IDZ65116', '', '', NULL, NULL, 'jne', 'reg', NULL, 0);
INSERT INTO public.shippings VALUES (68, 'ORD-260611-311', 'JNE Reguler', '082331339737', 7000, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-11 18:48:58.065557+07', '2026-06-11 18:48:58.065557+07', 'IDNP11IDNC250IDND2615IDZ65116', '', '', NULL, NULL, 'jne', 'reg', NULL, 0);
INSERT INTO public.shippings VALUES (69, 'ORD-260611-359', 'JNE Reguler', '082331339737', 7000, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-11 18:49:47.142571+07', '2026-06-11 18:49:47.142571+07', 'IDNP11IDNC250IDND2615IDZ65116', '', '', NULL, NULL, 'jne', 'reg', NULL, 0);
INSERT INTO public.shippings VALUES (70, 'ORD-260611-761', 'JNE Reguler', '082331339737', 7000, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-11 18:51:22.050602+07', '2026-06-11 18:51:22.050602+07', 'IDNP11IDNC250IDND2615IDZ65116', '', '', NULL, NULL, 'jne', 'reg', NULL, 0);
INSERT INTO public.shippings VALUES (71, 'ORD-260611-708', 'JNE Reguler', '082331339737', 7000, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-11 18:55:49.012954+07', '2026-06-11 18:55:49.012954+07', 'IDNP11IDNC250IDND2615IDZ65116', '', '', NULL, NULL, 'jne', 'reg', NULL, 0);
INSERT INTO public.shippings VALUES (72, 'ORD-260611-353', 'JNE Reguler', '082331339737', 7000, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-11 18:58:30.802015+07', '2026-06-11 18:58:30.802015+07', 'IDNP11IDNC250IDND2615IDZ65116', '', '', NULL, NULL, 'jne', 'reg', NULL, 0);
INSERT INTO public.shippings VALUES (73, 'ORD-260611-973', 'JNE Reguler', '082331339737', 7000, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-11 19:00:04.60233+07', '2026-06-11 19:00:04.60233+07', 'IDNP11IDNC250IDND2615IDZ65116', '', '', NULL, NULL, 'jne', 'reg', NULL, 0);
INSERT INTO public.shippings VALUES (74, 'ORD-260611-780', 'JNE Reguler', '082331339737', 7000, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-11 19:09:20.947224+07', '2026-06-11 19:09:20.947224+07', 'IDNP11IDNC250IDND2615IDZ65116', '', '', NULL, NULL, 'jne', 'reg', NULL, 0);
INSERT INTO public.shippings VALUES (75, 'ORD-260611-590', 'JNE Reguler', '082331339737', 7000, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-11 19:10:38.485053+07', '2026-06-11 19:10:38.485053+07', 'IDNP11IDNC250IDND2615IDZ65116', '', '', NULL, NULL, 'jne', 'reg', NULL, 0);
INSERT INTO public.shippings VALUES (81, 'ORD-260613-221', 'JNE Reguler', '081234567890', 7000, 'Perumahan Ijen Nirwana Blok C3 no 11', '2026-06-13 21:35:01.488486+07', '2026-06-13 21:35:01.488486+07', 'IDNP11IDNC250IDND2615IDZ65116', '', '', NULL, NULL, 'jne', 'reg', NULL, 0);
INSERT INTO public.shippings VALUES (79, 'ORD-260613-888', 'JNE Reguler', '081234567890', 7000, 'Perumahan Ijen Nirwana Blok C3 no 11', '2026-06-13 21:28:19.988681+07', '2026-06-13 21:38:08.61193+07', 'IDNP11IDNC250IDND2615IDZ65116', '6a2d6b5184c80c8c72b08708', 'WYB-1781361489078', NULL, NULL, 'jne', 'reg', NULL, 0);
INSERT INTO public.shippings VALUES (80, 'ORD-260613-832', 'JNE Reguler', '082331339737', 7000, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-13 21:32:02.481079+07', '2026-06-14 17:23:27.138327+07', 'IDNP11IDNC250IDND2615IDZ65116', '6a2e811f1642414bcf25f23e', 'WYB-1781432607181', NULL, NULL, 'jne', 'reg', NULL, 0);
INSERT INTO public.shippings VALUES (82, 'ORD-260613-153', 'JNE Reguler', '081234567890', 14000, 'Perumahan Ijen Nirwana Blok C3 no 11', '2026-06-13 22:00:42.719877+07', '2026-06-13 22:01:54.882649+07', 'IDNP11IDNC250IDND2615IDZ65116', '6a2d70e353aaf9bff22be705', 'WYB-1781362915520', NULL, NULL, 'jne', 'reg', NULL, 0);
INSERT INTO public.shippings VALUES (83, 'ORD-260614-699', 'JNE JNE Trucking', '082331339737', 1600000, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-14 15:35:16.138936+07', '2026-06-14 15:37:02.113177+07', 'IDNP11IDNC250IDND2615IDZ65116', '6a2e682e941f356907d2fbaa', 'WYB-1781426222110', NULL, NULL, 'jne', 'jtr', NULL, 0);
INSERT INTO public.shippings VALUES (50, 'ORD-260610-321', 'JNE JNE Trucking', '+62823345678', 325000, 'Jalan Mandala, Merauke, Merauke, Papua. 99612, Merauke, Papua', '2026-06-10 14:12:46.618275+07', '2026-06-10 14:14:14.095626+07', 'IDNP24IDNC277IDND2993IDZ99612', '6a290ec5244e9a3cfd04b083', 'WYB-1781075653396', NULL, NULL, 'jne', 'jtr', NULL, 0);
INSERT INTO public.shippings VALUES (84, 'ORD-260614-130', 'JNE JNE Trucking', '082331339737', 1600000, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-14 16:28:49.605483+07', '2026-06-14 16:29:53.550693+07', 'IDNP11IDNC250IDND2615IDZ65116', '6a2e7491595b9cb6f8146560', 'WYB-1781429393571', NULL, NULL, 'jne', 'jtr', NULL, 0);
INSERT INTO public.shippings VALUES (85, 'ORD-260614-268', 'JNE Reguler', '082331339737', 7000, 'Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-14 17:36:28.492323+07', '2026-06-14 17:42:36.60486+07', 'IDNP11IDNC250IDND2615IDZ65116', '6a2e859c84c80c1c78b7a12e', 'WYB-1781433756610', NULL, NULL, 'jne', 'reg', NULL, 0);
INSERT INTO public.shippings VALUES (86, 'ORD-260614-231', 'JNE Reguler', '+6282132148698', 7000, 'Perumahan Ijen Nirwana Blok C3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur', '2026-06-14 17:39:14.466397+07', '2026-06-14 17:48:25.105203+07', 'IDNP11IDNC250IDND2615IDZ65116', '6a2e86f9a2e9af71af3b729e', 'WYB-1781434105123', NULL, NULL, 'jne', 'reg', NULL, 0);
INSERT INTO public.shippings VALUES (87, 'ORD-260614-564', 'JNE Reguler', '+628123456', 7000, 'Ijen Nirwana, Klojen, Malang, Jawa Timur. 65116', '2026-06-14 17:41:16.992098+07', '2026-06-14 17:41:16.992098+07', 'IDNP11IDNC250IDND2615IDZ65116', '', '', NULL, NULL, 'jne', 'reg', NULL, 0);


--
-- Data for Name: stock_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.stock_logs VALUES (248, 'P-002', NULL, 'addition', 30, 37, 'Inbound PO Kulakan', '2026-06-14 15:32:04.042586+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (34, 'P-034', NULL, 'addition', 50, 50, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.000348+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (49, 'P-049', NULL, 'addition', 20, 20, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.01237+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (6, 'P-006', NULL, 'addition', 50, 50, 'Stok Awal (Seeder)', '2026-05-31 14:39:51.982006+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (8, 'P-008', NULL, 'addition', 70, 70, 'Stok Awal (Seeder)', '2026-05-31 14:39:51.983034+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (7, 'P-007', NULL, 'addition', 70, 70, 'Stok Awal (Seeder)', '2026-05-31 14:39:51.982521+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (5, 'P-005', NULL, 'addition', 80, 80, 'Stok Awal (Seeder)', '2026-05-31 14:39:51.980982+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (21, 'P-021', NULL, 'addition', 300, 300, 'Stok Awal (Seeder)', '2026-05-31 14:39:51.992272+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (66, 'P-066', NULL, 'addition', 70, 70, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.026699+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (22, 'P-022', NULL, 'addition', 250, 250, 'Stok Awal (Seeder)', '2026-05-31 14:39:51.992802+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (23, 'P-023', NULL, 'addition', 200, 200, 'Stok Awal (Seeder)', '2026-05-31 14:39:51.993978+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (24, 'P-024', NULL, 'addition', 150, 150, 'Stok Awal (Seeder)', '2026-05-31 14:39:51.994492+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (9, 'P-009', NULL, 'addition', 200, 200, 'Stok Awal (Seeder)', '2026-05-31 14:39:51.983591+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (41, 'P-041', NULL, 'addition', 150, 150, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.004529+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (68, 'P-068', NULL, 'addition', 100, 100, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.029127+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (53, 'P-053', NULL, 'addition', 100, 100, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.015689+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (81, 'P-081', NULL, 'addition', 15, 15, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.057419+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (56, 'P-056', NULL, 'addition', 20, 20, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.01783+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (54, 'P-054', NULL, 'addition', 35, 35, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.016722+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (59, 'P-059', NULL, 'addition', 120, 120, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.01948+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (60, 'P-060', NULL, 'addition', 40, 40, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.020021+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (67, 'P-067', NULL, 'addition', 80, 80, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.027969+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (69, 'P-069', NULL, 'addition', 200, 200, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.029651+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (51, 'P-051', NULL, 'addition', 100, 100, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.014528+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (58, 'P-058', NULL, 'addition', 15, 15, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.018943+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (71, 'P-071', NULL, 'addition', 120, 120, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.031408+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (72, 'P-072', NULL, 'addition', 100, 100, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.032557+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (73, 'P-073', NULL, 'addition', 80, 80, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.033768+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (74, 'P-074', NULL, 'addition', 60, 60, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.034298+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (62, 'P-062', NULL, 'addition', 100, 100, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.021094+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (55, 'P-055', NULL, 'addition', 60, 60, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.017243+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (79, 'P-079', NULL, 'addition', 10, 10, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.04405+07', 1, 16);
INSERT INTO public.stock_logs VALUES (57, 'P-057', NULL, 'addition', 50, 50, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.018376+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (70, 'P-070', NULL, 'addition', 150, 150, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.030857+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (75, 'P-075', NULL, 'addition', 30, 30, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.035909+07', 1, 1);
INSERT INTO public.stock_logs VALUES (11, 'P-011', NULL, 'addition', 150, 150, 'Stok Awal (Seeder)', '2026-05-31 14:39:51.984831+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (13, 'P-013', NULL, 'addition', 100, 100, 'Stok Awal (Seeder)', '2026-05-31 14:39:51.985925+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (12, 'P-012', NULL, 'addition', 100, 100, 'Stok Awal (Seeder)', '2026-05-31 14:39:51.985415+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (14, 'P-014', NULL, 'addition', 80, 80, 'Stok Awal (Seeder)', '2026-05-31 14:39:51.986459+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (15, 'P-015', NULL, 'addition', 60, 60, 'Stok Awal (Seeder)', '2026-05-31 14:39:51.987616+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (3, 'P-003', NULL, 'addition', 100, 100, 'Stok Awal (Seeder)', '2026-05-31 14:39:51.97944+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (44, 'P-044', NULL, 'addition', 80, 80, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.006316+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (35, 'P-035', NULL, 'addition', 40, 40, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.000977+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (17, 'P-017', NULL, 'addition', 40, 40, 'Stok Awal (Seeder)', '2026-05-31 14:39:51.98871+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (65, 'P-065', NULL, 'addition', 50, 50, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.024465+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (63, 'P-063', NULL, 'addition', 60, 60, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.021619+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (16, 'P-016', NULL, 'addition', 50, 50, 'Stok Awal (Seeder)', '2026-05-31 14:39:51.988126+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (29, 'P-029', NULL, 'addition', 50, 50, 'Stok Awal (Seeder)', '2026-05-31 14:39:51.997445+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (26, 'P-026', NULL, 'addition', 100, 100, 'Stok Awal (Seeder)', '2026-05-31 14:39:51.995666+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (39, 'P-039', NULL, 'addition', 200, 200, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.003304+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (64, 'P-064', NULL, 'addition', 80, 80, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.022935+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (45, 'P-045', NULL, 'addition', 60, 60, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.007702+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (40, 'P-040', NULL, 'addition', 200, 200, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.003916+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (46, 'P-046', NULL, 'addition', 50, 50, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.009603+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (27, 'P-027', NULL, 'addition', 80, 80, 'Stok Awal (Seeder)', '2026-05-31 14:39:51.996273+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (36, 'P-036', NULL, 'addition', 30, 30, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.001548+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (32, 'P-032', NULL, 'addition', 80, 80, 'Stok Awal (Seeder)', '2026-05-31 14:39:51.999155+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (20, 'P-020', NULL, 'addition', 15, 15, 'Stok Awal (Seeder)', '2026-05-31 14:39:51.990424+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (33, 'P-033', NULL, 'addition', 60, 60, 'Stok Awal (Seeder)', '2026-05-31 14:39:51.999763+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (38, 'P-038', NULL, 'addition', 15, 15, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.002734+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (28, 'P-028', NULL, 'addition', 60, 60, 'Stok Awal (Seeder)', '2026-05-31 14:39:51.996827+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (43, 'P-043', NULL, 'addition', 100, 100, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.005675+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (31, 'P-031', NULL, 'addition', 100, 100, 'Stok Awal (Seeder)', '2026-05-31 14:39:51.998573+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (1, 'P-001', NULL, 'addition', 100, 100, 'Stok Awal (Seeder)', '2026-05-31 14:39:51.974391+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (42, 'P-042', NULL, 'addition', 100, 100, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.005098+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (37, 'P-037', NULL, 'addition', 20, 20, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.002145+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (19, 'P-019', NULL, 'addition', 20, 20, 'Stok Awal (Seeder)', '2026-05-31 14:39:51.989822+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (249, 'P-002', NULL, 'deduction', -10, 27, 'Penjualan (Order ORD-260614-699)', '2026-06-14 15:35:16.116722+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (106, 'P-106', NULL, 'addition', 200, 200, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.114666+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (127, 'P-127', NULL, 'addition', 200, 200, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.128423+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (138, 'P-002', NULL, 'deduction', -20, 100, 'Penjualan (Order ORD-260531-793)', '2026-05-31 20:15:04.088969+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (142, 'P-002', NULL, 'deduction', -10, 90, 'Penjualan (Order ORD-260601-785)', '2026-06-01 19:38:17.391078+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (144, 'P-002', NULL, 'deduction', -20, 70, 'Penjualan (Order ORD-260603-721)', '2026-06-03 12:43:09.746838+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (147, 'P-002', NULL, 'deduction', -20, 50, 'Penjualan (Order ORD-260603-541)', '2026-06-03 12:56:55.366055+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (131, 'P-131', NULL, 'addition', 100, 100, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.130712+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (137, 'P-137', NULL, 'addition', 50, 50, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.134682+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (115, 'P-115', NULL, 'addition', 80, 80, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.11976+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (96, 'P-096', NULL, 'addition', 300, 300, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.097366+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (101, 'P-101', NULL, 'addition', 300, 300, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.111384+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (100, 'P-100', NULL, 'addition', 200, 200, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.110858+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (82, 'P-082', NULL, 'addition', 15, 15, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.058927+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (145, 'P-054', NULL, 'deduction', -3, 32, 'Penjualan (Order ORD-260603-721)', '2026-06-03 12:43:09.762873+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (98, 'P-098', NULL, 'addition', 250, 250, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.108983+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (84, 'P-084', NULL, 'addition', 15, 15, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.064775+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (99, 'P-099', NULL, 'addition', 200, 200, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.110341+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (87, 'P-087', NULL, 'addition', 10, 10, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.066418+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (83, 'P-083', NULL, 'addition', 20, 20, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.064272+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (151, 'P-083', NULL, 'deduction', -1, 19, 'Penjualan (Order ORD-260603-503)', '2026-06-03 14:23:00.283674+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (146, 'P-074', NULL, 'deduction', -20, 40, 'Penjualan (Order ORD-260603-721)', '2026-06-03 12:43:09.764978+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (154, 'P-074', NULL, 'deduction', -5, 35, 'Penjualan (Order ORD-260603-256)', '2026-06-03 18:02:28.553313+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (155, 'P-074', NULL, 'deduction', -5, 30, 'Penjualan (Order ORD-260603-300)', '2026-06-03 18:09:36.858282+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (143, 'P-061', NULL, 'deduction', -2, 78, 'Penjualan (Order ORD-260601-741)', '2026-06-01 19:43:12.072926+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (159, 'P-061', NULL, 'deduction', -5, 73, 'Penjualan (Order ORD-260603-971)', '2026-06-03 19:30:22.982841+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (107, 'P-107', NULL, 'addition', 150, 150, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.115245+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (105, 'P-105', NULL, 'addition', 200, 200, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.114084+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (128, 'P-128', NULL, 'addition', 250, 250, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.129018+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (121, 'P-121', NULL, 'addition', 100, 100, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.123625+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (134, 'P-134', NULL, 'addition', 100, 100, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.132463+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (110, 'P-110', NULL, 'addition', 150, 150, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.116944+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (119, 'P-119', NULL, 'addition', 70, 70, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.121969+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (125, 'P-125', NULL, 'addition', 150, 150, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.127349+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (132, 'P-132', NULL, 'addition', 150, 150, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.131302+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (109, 'P-109', NULL, 'addition', 100, 100, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.116373+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (114, 'P-114', NULL, 'addition', 60, 60, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.119212+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (136, 'P-136', NULL, 'addition', 70, 70, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.133564+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (135, 'P-135', NULL, 'addition', 80, 80, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.133028+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (129, 'P-129', NULL, 'addition', 200, 200, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.129583+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (111, 'P-111', NULL, 'addition', 100, 100, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.117502+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (112, 'P-112', NULL, 'addition', 120, 120, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.118099+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (133, 'P-133', NULL, 'addition', 130, 130, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.131875+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (124, 'P-124', NULL, 'addition', 120, 120, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.126219+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (118, 'P-118', NULL, 'addition', 60, 60, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.121434+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (113, 'P-113', NULL, 'addition', 50, 50, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.118648+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (117, 'P-117', NULL, 'addition', 40, 40, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.120818+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (104, 'P-104', NULL, 'addition', 250, 250, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.113546+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (116, 'P-116', NULL, 'addition', 30, 30, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.120308+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (123, 'P-123', NULL, 'addition', 100, 100, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.125655+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (130, 'P-130', NULL, 'addition', 180, 180, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.130162+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (120, 'P-120', NULL, 'addition', 100, 100, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.123095+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (122, 'P-122', NULL, 'addition', 120, 120, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.124197+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (126, 'P-126', NULL, 'addition', 200, 200, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.127868+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (85, 'P-085', NULL, 'addition', 18, 18, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.065288+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (108, 'P-108', NULL, 'addition', 150, 150, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.115807+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (97, 'P-097', NULL, 'addition', 300, 300, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.107047+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (88, 'P-088', NULL, 'addition', 200, 200, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.066933+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (89, 'P-089', NULL, 'addition', 200, 200, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.067495+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (86, 'P-086', NULL, 'addition', 12, 12, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.065829+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (92, 'P-092', NULL, 'addition', 100, 100, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.069156+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (95, 'P-095', NULL, 'addition', 100, 100, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.088337+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (93, 'P-093', NULL, 'addition', 100, 100, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.069677+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (91, 'P-091', NULL, 'addition', 150, 150, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.068589+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (102, 'P-102', NULL, 'addition', 300, 300, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.112428+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (103, 'P-103', NULL, 'addition', 250, 250, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.11295+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (250, 'P-002', NULL, 'deduction', -10, 17, 'Penjualan (Order ORD-260614-130)', '2026-06-14 16:28:49.577317+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (251, 'P-128', NULL, 'deduction', -10, 240, 'Penjualan (Order ORD-260614-268)', '2026-06-14 17:36:28.483152+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (252, 'P-128', NULL, 'deduction', -5, 235, 'Penjualan (Order ORD-260614-231)', '2026-06-14 17:39:14.459083+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (253, 'P-128', NULL, 'deduction', -5, 230, 'Penjualan (Order ORD-260614-564)', '2026-06-14 17:41:16.985321+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (254, 'P-001', NULL, 'addition', 30, 50, 'Inbound PO Kulakan', '2026-06-14 17:57:42.38639+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (255, 'P-128', NULL, 'addition', 5, 235, 'Pembatalan Pesanan (Order ORD-260614-564)', '2026-06-14 18:21:24.66286+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (177, 'P-004', NULL, 'deduction', -10, 39, 'Penjualan (Order ORD-260604-507)', '2026-06-04 20:36:37.788145+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (183, 'P-004', NULL, 'deduction', -10, 29, 'Penjualan (Order ORD-260605-629)', '2026-06-05 15:44:02.083999+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (184, 'P-004', NULL, 'deduction', -10, 19, 'Penjualan (Order ORD-260605-558)', '2026-06-05 16:36:47.717954+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (185, 'P-004', NULL, 'addition', 10, 29, 'Pembatalan Pesanan (Order ORD-260605-629)', '2026-06-05 16:55:19.14839+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (195, 'P-106', NULL, 'deduction', -10, 190, 'Penjualan (Order ORD-260606-964)', '2026-06-06 10:10:18.487555+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (178, 'P-021', NULL, 'deduction', -10, 290, 'Penjualan (Order ORD-260604-216)', '2026-06-04 21:15:20.640936+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (179, 'P-021', NULL, 'addition', 10, 300, 'Pembatalan Pesanan (Order ORD-260604-216)', '2026-06-04 21:20:57.001003+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (182, 'P-002', NULL, 'deduction', -10, 7, 'Penjualan (Order ORD-260605-340)', '2026-06-05 10:25:25.546283+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (163, 'P-101', NULL, 'deduction', -10, 290, 'Penjualan (Order ORD-260603-391)', '2026-06-03 21:22:38.206143+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (172, 'P-101', NULL, 'deduction', -10, 280, 'Penjualan (Order ORD-260604-705)', '2026-06-04 20:15:41.651252+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (173, 'P-101', NULL, 'addition', 10, 290, 'Pembatalan Pesanan (Order ORD-260604-705)', '2026-06-04 20:26:12.946295+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (174, 'P-101', NULL, 'deduction', -10, 280, 'Penjualan (Order ORD-260604-795)', '2026-06-04 20:29:13.159303+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (203, 'P-054', NULL, 'deduction', -1, 31, 'Penjualan (Order ORD-260608-999)', '2026-06-08 07:51:36.819896+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (196, 'P-069', NULL, 'deduction', -10, 190, 'Penjualan (Order ORD-260606-149)', '2026-06-06 10:54:28.529421+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (160, 'P-083', NULL, 'deduction', -1, 18, 'Penjualan (Order ORD-260603-941)', '2026-06-03 20:35:00.095313+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (161, 'P-083', NULL, 'deduction', -1, 17, 'Penjualan (Order ORD-260603-324)', '2026-06-03 20:39:29.375749+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (162, 'P-083', NULL, 'deduction', -1, 16, 'Penjualan (Order ORD-260603-526)', '2026-06-03 21:01:13.64501+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (189, 'P-083', NULL, 'deduction', -1, 15, 'Penjualan (Order ORD-260605-636)', '2026-06-05 22:09:03.371882+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (190, 'P-083', NULL, 'addition', 1, 16, 'Pembatalan Pesanan (Order ORD-260605-636)', '2026-06-05 22:16:25.709238+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (191, 'P-083', NULL, 'deduction', -1, 15, 'Penjualan (Order ORD-260605-729)', '2026-06-05 22:21:44.923134+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (192, 'P-083', NULL, 'deduction', -1, 14, 'Penjualan (Order ORD-260605-279)', '2026-06-05 22:59:15.514943+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (171, 'P-074', NULL, 'deduction', -5, 15, 'Penjualan (Order ORD-260604-204)', '2026-06-04 19:51:34.40751+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (164, 'P-061', NULL, 'deduction', -1, 72, 'Penjualan (Order ORD-260603-629)', '2026-06-03 21:30:02.743295+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (168, 'P-061', NULL, 'deduction', -3, 69, 'Penjualan (Order ORD-260604-224)', '2026-06-04 18:13:00.956755+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (180, 'P-061', NULL, 'deduction', -3, 66, 'Penjualan (Order ORD-260604-787)', '2026-06-04 22:41:12.775773+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (197, 'P-061', NULL, 'deduction', -5, 61, 'Penjualan (Order ORD-260606-731)', '2026-06-06 14:56:38.021205+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (205, 'P-061', NULL, 'deduction', -5, 56, 'Penjualan (Order ORD-260608-999)', '2026-06-08 07:51:36.862228+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (206, 'P-061', NULL, 'deduction', -5, 51, 'Penjualan (Order ORD-260610-321)', '2026-06-10 14:12:46.575274+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (202, 'P-003', NULL, 'deduction', -10, 90, 'Penjualan (Order ORD-260606-995)', '2026-06-06 20:50:00.928256+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (209, 'P-003', NULL, 'deduction', -10, 80, 'Penjualan (Order ORD-260610-330)', '2026-06-10 23:31:12.01306+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (210, 'P-003', NULL, 'deduction', -10, 70, 'Penjualan (Order ORD-260611-975)', '2026-06-11 11:35:05.168292+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (211, 'P-003', NULL, 'addition', 10, 80, 'Pembatalan Pesanan (Order ORD-260611-975)', '2026-06-11 11:46:33.668921+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (212, 'P-003', NULL, 'deduction', -10, 70, 'Penjualan (Order ORD-260611-855)', '2026-06-11 11:49:15.627876+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (213, 'P-003', NULL, 'addition', 10, 80, 'Pembatalan Pesanan (Order ORD-260611-855)', '2026-06-11 11:56:36.759616+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (214, 'P-003', NULL, 'deduction', -10, 70, 'Penjualan (Order ORD-260611-298)', '2026-06-11 11:58:25.742516+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (165, 'P-001', NULL, 'deduction', -10, 90, 'Penjualan (Order ORD-260603-818)', '2026-06-03 21:33:29.824051+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (166, 'P-001', NULL, 'deduction', -10, 80, 'Penjualan (Order ORD-260603-817)', '2026-06-03 21:38:19.441745+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (167, 'P-001', NULL, 'deduction', -10, 70, 'Penjualan (Order ORD-260604-224)', '2026-06-04 18:13:00.940989+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (169, 'P-001', NULL, 'deduction', -10, 60, 'Penjualan (Order ORD-260604-871)', '2026-06-04 19:02:01.158844+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (170, 'P-001', NULL, 'deduction', -10, 50, 'Penjualan (Order ORD-260604-204)', '2026-06-04 19:51:34.397833+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (186, 'P-001', NULL, 'deduction', -10, 40, 'Penjualan (Order ORD-260605-444)', '2026-06-05 20:25:48.64962+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (187, 'P-001', NULL, 'addition', 10, 50, 'Pembatalan Pesanan (Order ORD-260605-444)', '2026-06-05 20:27:51.88705+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (188, 'P-001', NULL, 'deduction', -10, 40, 'Penjualan (Order ORD-260605-505)', '2026-06-05 20:31:16.238222+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (193, 'P-102', NULL, 'deduction', -10, 290, 'Penjualan (Order ORD-260605-300)', '2026-06-05 23:06:56.934644+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (194, 'P-102', NULL, 'deduction', -1, 289, 'Penjualan (Order ORD-260605-128)', '2026-06-05 23:09:54.045017+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (256, 'P-001', NULL, 'addition', 200, 250, 'Inbound PO Kulakan', '2026-06-14 20:01:18.96311+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (4, 'P-004', NULL, 'addition', 60, 60, 'Stok Awal (Seeder)', '2026-05-31 14:39:51.980467+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (139, 'P-004', NULL, 'deduction', -20, 40, 'Penjualan (Order ORD-260531-793)', '2026-05-31 20:15:04.110039+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (140, 'P-004', NULL, 'deduction', -10, 30, 'Penjualan (Order ORD-260531-325)', '2026-05-31 21:02:38.602973+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (141, 'P-004', NULL, 'deduction', -10, 20, 'Penjualan (Order ORD-260601-785)', '2026-06-01 19:38:17.355383+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (152, 'P-004', NULL, 'deduction', -10, 10, 'Penjualan (Order ORD-260603-731)', '2026-06-03 14:34:02.569738+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (153, 'P-004', 1, 'addition', 39, 49, 'Penambahan Manual Owner', '2026-06-03 17:12:09.301716+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (204, 'P-004', NULL, 'deduction', -11, 18, 'Penjualan (Order ORD-260608-999)', '2026-06-08 07:51:36.857216+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (2, 'P-002', NULL, 'addition', 120, 120, 'Stok Awal (Seeder)', '2026-05-31 14:39:51.978397+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (148, 'P-002', NULL, 'deduction', -10, 40, 'Penjualan (Order ORD-260603-437)', '2026-06-03 13:56:18.755981+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (149, 'P-002', NULL, 'deduction', -11, 29, 'Penjualan (Order ORD-260603-153)', '2026-06-03 14:07:54.029792+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (150, 'P-002', NULL, 'deduction', -12, 17, 'Penjualan (Order ORD-260603-820)', '2026-06-03 14:12:25.638354+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (25, 'P-025', NULL, 'addition', 150, 150, 'Stok Awal (Seeder)', '2026-05-31 14:39:51.995067+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (175, 'P-101', NULL, 'addition', 10, 290, 'Pembatalan Pesanan (Order ORD-260604-795)', '2026-06-04 20:29:45.785573+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (176, 'P-101', NULL, 'deduction', -10, 280, 'Penjualan (Order ORD-260604-969)', '2026-06-04 20:32:14.765185+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (201, 'P-101', NULL, 'deduction', -11, 269, 'Penjualan (Order ORD-260606-680)', '2026-06-06 20:39:01.628595+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (215, 'P-101', NULL, 'deduction', -1, 268, 'Penjualan (Order ORD-260611-681)', '2026-06-11 12:15:51.090357+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (216, 'P-101', NULL, 'deduction', -1, 267, 'Penjualan (Order ORD-260611-815)', '2026-06-11 12:31:51.125822+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (217, 'P-101', NULL, 'deduction', -1, 266, 'Penjualan (Order ORD-260611-735)', '2026-06-11 12:32:45.181104+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (218, 'P-101', NULL, 'deduction', -1, 265, 'Penjualan (Order ORD-260611-740)', '2026-06-11 12:41:21.519063+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (219, 'P-101', NULL, 'deduction', -1, 264, 'Penjualan (Order ORD-260611-474)', '2026-06-11 18:33:38.876104+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (220, 'P-101', NULL, 'deduction', -1, 263, 'Penjualan (Order ORD-260611-253)', '2026-06-11 18:36:06.416064+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (221, 'P-101', NULL, 'deduction', -1, 262, 'Penjualan (Order ORD-260611-824)', '2026-06-11 18:36:15.465948+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (222, 'P-101', NULL, 'deduction', -1, 261, 'Penjualan (Order ORD-260611-870)', '2026-06-11 18:38:01.128021+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (223, 'P-101', NULL, 'deduction', -1, 260, 'Penjualan (Order ORD-260611-305)', '2026-06-11 18:40:36.956575+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (224, 'P-101', NULL, 'deduction', -1, 259, 'Penjualan (Order ORD-260611-457)', '2026-06-11 18:42:25.802566+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (225, 'P-101', NULL, 'deduction', -1, 258, 'Penjualan (Order ORD-260611-487)', '2026-06-11 18:48:46.702922+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (226, 'P-101', NULL, 'addition', 1, 259, 'Pembatalan oleh Customer (Order ORD-260611-487)', '2026-06-11 18:48:51.024024+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (227, 'P-101', NULL, 'deduction', -1, 258, 'Penjualan (Order ORD-260611-311)', '2026-06-11 18:48:58.060724+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (228, 'P-101', NULL, 'deduction', -1, 257, 'Penjualan (Order ORD-260611-359)', '2026-06-11 18:49:47.134921+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (229, 'P-101', NULL, 'deduction', -1, 256, 'Penjualan (Order ORD-260611-761)', '2026-06-11 18:51:22.030396+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (230, 'P-101', NULL, 'deduction', -5, 251, 'Penjualan (Order ORD-260611-708)', '2026-06-11 18:55:48.971635+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (231, 'P-101', NULL, 'deduction', -1, 250, 'Penjualan (Order ORD-260611-353)', '2026-06-11 18:58:30.7958+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (232, 'P-101', NULL, 'addition', 1, 251, 'Pembatalan oleh Customer (Order ORD-260611-353)', '2026-06-11 18:58:52.494274+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (233, 'P-101', NULL, 'deduction', -1, 250, 'Penjualan (Order ORD-260611-973)', '2026-06-11 19:00:04.582314+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (247, 'P-068', NULL, 'deduction', -3, 97, 'Penjualan (Order ORD-260613-153)', '2026-06-13 22:00:42.686847+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (77, 'P-077', NULL, 'addition', 40, 40, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.037598+07', 1, 9);
INSERT INTO public.stock_logs VALUES (181, 'P-077', NULL, 'deduction', -1, 39, 'Penjualan (Order ORD-260604-787)', '2026-06-04 22:41:12.787118+07', 1, 9);
INSERT INTO public.stock_logs VALUES (78, 'P-078', NULL, 'addition', 10, 10, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.038121+07', 1, 13);
INSERT INTO public.stock_logs VALUES (76, 'P-076', NULL, 'addition', 30, 30, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.037042+07', 1, 5);
INSERT INTO public.stock_logs VALUES (156, 'P-074', NULL, 'deduction', -3, 27, 'Penjualan (Order ORD-260603-480)', '2026-06-03 18:21:57.435867+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (157, 'P-074', NULL, 'deduction', -4, 23, 'Penjualan (Order ORD-260603-849)', '2026-06-03 18:32:25.599183+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (158, 'P-074', NULL, 'deduction', -3, 20, 'Penjualan (Order ORD-260603-210)', '2026-06-03 18:42:25.482532+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (80, 'P-080', NULL, 'addition', 12, 12, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.050377+07', 1, 19);
INSERT INTO public.stock_logs VALUES (61, 'P-061', NULL, 'addition', 80, 80, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.020583+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (241, 'P-061', NULL, 'deduction', -1, 50, 'Penjualan (Order ORD-260613-517)', '2026-06-13 21:14:24.487519+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (243, 'P-061', NULL, 'deduction', -1, 49, 'Penjualan (Order ORD-260613-888)', '2026-06-13 21:28:19.985663+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (246, 'P-061', NULL, 'deduction', -1, 48, 'Penjualan (Order ORD-260613-221)', '2026-06-13 21:35:01.482947+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (10, 'P-010', NULL, 'addition', 200, 200, 'Stok Awal (Seeder)', '2026-05-31 14:39:51.984233+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (48, 'P-048', NULL, 'addition', 25, 25, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.011244+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (52, 'P-052', NULL, 'addition', 40, 40, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.015031+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (18, 'P-018', NULL, 'addition', 30, 30, 'Stok Awal (Seeder)', '2026-05-31 14:39:51.989223+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (30, 'P-030', NULL, 'addition', 100, 100, 'Stok Awal (Seeder)', '2026-05-31 14:39:51.997991+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (50, 'P-050', NULL, 'addition', 10, 10, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.012937+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (234, 'P-102', NULL, 'deduction', -1, 288, 'Penjualan (Order ORD-260611-780)', '2026-06-11 19:09:20.939926+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (94, 'P-094', NULL, 'addition', 100, 100, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.078145+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (207, 'P-001', NULL, 'deduction', -10, 30, 'Penjualan (Order ORD-260610-883)', '2026-06-10 14:49:22.880069+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (239, 'P-001', NULL, 'deduction', -10, 20, 'Penjualan (Order ORD-260613-471)', '2026-06-13 18:32:22.620413+07', 2, NULL);
INSERT INTO public.stock_logs VALUES (90, 'P-090', NULL, 'addition', 150, 150, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.068033+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (47, 'P-047', NULL, 'addition', 40, 40, 'Stok Awal (Seeder)', '2026-05-31 14:39:52.010727+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (235, 'P-102', NULL, 'addition', 1, 289, 'Pembatalan oleh Customer (Order ORD-260611-780)', '2026-06-11 19:09:56.665385+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (236, 'P-102', NULL, 'deduction', -1, 288, 'Penjualan (Order ORD-260611-590)', '2026-06-11 19:10:38.476056+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (237, 'P-102', NULL, 'addition', 1, 289, 'Pembatalan oleh Customer (Order ORD-260611-590)', '2026-06-11 19:10:49.650409+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (238, 'P-102', NULL, 'deduction', -1, 288, 'Penjualan (Order ORD-260611-399)', '2026-06-11 19:12:01.382474+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (240, 'P-102', NULL, 'deduction', -5, 283, 'Penjualan (Order ORD-260613-517)', '2026-06-13 21:14:24.464103+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (242, 'P-102', NULL, 'deduction', -5, 278, 'Penjualan (Order ORD-260613-888)', '2026-06-13 21:28:19.98067+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (244, 'P-102', NULL, 'deduction', -10, 268, 'Penjualan (Order ORD-260613-832)', '2026-06-13 21:32:02.479425+07', 1, NULL);
INSERT INTO public.stock_logs VALUES (245, 'P-102', NULL, 'deduction', -5, 263, 'Penjualan (Order ORD-260613-221)', '2026-06-13 21:35:01.478509+07', 1, NULL);


--
-- Data for Name: warehouse_stocks; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.warehouse_stocks VALUES (549, 'P-091', NULL, 1, 150);
INSERT INTO public.warehouse_stocks VALUES (550, 'P-135', NULL, 1, 80);
INSERT INTO public.warehouse_stocks VALUES (551, 'P-045', NULL, 1, 60);
INSERT INTO public.warehouse_stocks VALUES (552, 'P-103', NULL, 1, 250);
INSERT INTO public.warehouse_stocks VALUES (553, 'P-078', 13, 1, 10);
INSERT INTO public.warehouse_stocks VALUES (554, 'P-068', NULL, 1, 97);
INSERT INTO public.warehouse_stocks VALUES (555, 'P-024', NULL, 1, 150);
INSERT INTO public.warehouse_stocks VALUES (556, 'P-039', NULL, 1, 200);
INSERT INTO public.warehouse_stocks VALUES (557, 'P-072', NULL, 2, 100);
INSERT INTO public.warehouse_stocks VALUES (558, 'P-117', NULL, 1, 40);
INSERT INTO public.warehouse_stocks VALUES (559, 'P-082', NULL, 1, 15);
INSERT INTO public.warehouse_stocks VALUES (560, 'P-119', NULL, 1, 70);
INSERT INTO public.warehouse_stocks VALUES (561, 'P-048', NULL, 1, 25);
INSERT INTO public.warehouse_stocks VALUES (562, 'P-133', NULL, 1, 130);
INSERT INTO public.warehouse_stocks VALUES (563, 'P-092', NULL, 1, 100);
INSERT INTO public.warehouse_stocks VALUES (564, 'P-086', NULL, 1, 12);
INSERT INTO public.warehouse_stocks VALUES (565, 'P-104', NULL, 1, 250);
INSERT INTO public.warehouse_stocks VALUES (566, 'P-020', NULL, 1, 15);
INSERT INTO public.warehouse_stocks VALUES (567, 'P-102', NULL, 1, 263);
INSERT INTO public.warehouse_stocks VALUES (568, 'P-037', NULL, 1, 20);
INSERT INTO public.warehouse_stocks VALUES (569, 'P-076', 5, 1, 30);
INSERT INTO public.warehouse_stocks VALUES (570, 'P-067', NULL, 1, 80);
INSERT INTO public.warehouse_stocks VALUES (571, 'P-130', NULL, 1, 180);
INSERT INTO public.warehouse_stocks VALUES (572, 'P-100', NULL, 1, 200);
INSERT INTO public.warehouse_stocks VALUES (573, 'P-098', NULL, 1, 250);
INSERT INTO public.warehouse_stocks VALUES (574, 'P-043', NULL, 1, 100);
INSERT INTO public.warehouse_stocks VALUES (575, 'P-054', NULL, 1, 31);
INSERT INTO public.warehouse_stocks VALUES (576, 'P-088', NULL, 1, 200);
INSERT INTO public.warehouse_stocks VALUES (577, 'P-034', NULL, 1, 50);
INSERT INTO public.warehouse_stocks VALUES (578, 'P-029', NULL, 1, 50);
INSERT INTO public.warehouse_stocks VALUES (579, 'P-095', NULL, 1, 100);
INSERT INTO public.warehouse_stocks VALUES (580, 'P-084', NULL, 1, 15);
INSERT INTO public.warehouse_stocks VALUES (581, 'P-071', NULL, 2, 120);
INSERT INTO public.warehouse_stocks VALUES (582, 'P-110', NULL, 1, 150);
INSERT INTO public.warehouse_stocks VALUES (583, 'P-111', NULL, 1, 100);
INSERT INTO public.warehouse_stocks VALUES (584, 'P-055', NULL, 1, 60);
INSERT INTO public.warehouse_stocks VALUES (585, 'P-096', NULL, 1, 300);
INSERT INTO public.warehouse_stocks VALUES (586, 'P-041', NULL, 1, 150);
INSERT INTO public.warehouse_stocks VALUES (587, 'P-107', NULL, 1, 150);
INSERT INTO public.warehouse_stocks VALUES (588, 'P-074', NULL, 2, 15);
INSERT INTO public.warehouse_stocks VALUES (589, 'P-025', NULL, 1, 150);
INSERT INTO public.warehouse_stocks VALUES (590, 'P-118', NULL, 1, 60);
INSERT INTO public.warehouse_stocks VALUES (592, 'P-060', NULL, 1, 40);
INSERT INTO public.warehouse_stocks VALUES (593, 'P-116', NULL, 1, 30);
INSERT INTO public.warehouse_stocks VALUES (594, 'P-036', NULL, 1, 30);
INSERT INTO public.warehouse_stocks VALUES (595, 'P-097', NULL, 1, 300);
INSERT INTO public.warehouse_stocks VALUES (596, 'P-075', 1, 1, 30);
INSERT INTO public.warehouse_stocks VALUES (597, 'P-089', NULL, 1, 200);
INSERT INTO public.warehouse_stocks VALUES (598, 'P-115', NULL, 1, 80);
INSERT INTO public.warehouse_stocks VALUES (599, 'P-124', NULL, 1, 120);
INSERT INTO public.warehouse_stocks VALUES (600, 'P-105', NULL, 1, 200);
INSERT INTO public.warehouse_stocks VALUES (601, 'P-028', NULL, 1, 60);
INSERT INTO public.warehouse_stocks VALUES (602, 'P-085', NULL, 1, 18);
INSERT INTO public.warehouse_stocks VALUES (603, 'P-132', NULL, 1, 150);
INSERT INTO public.warehouse_stocks VALUES (604, 'P-081', NULL, 1, 15);
INSERT INTO public.warehouse_stocks VALUES (605, 'P-128', NULL, 1, 235);
INSERT INTO public.warehouse_stocks VALUES (606, 'P-027', NULL, 1, 80);
INSERT INTO public.warehouse_stocks VALUES (607, 'P-114', NULL, 1, 60);
INSERT INTO public.warehouse_stocks VALUES (608, 'P-006', NULL, 2, 50);
INSERT INTO public.warehouse_stocks VALUES (609, 'P-050', NULL, 1, 10);
INSERT INTO public.warehouse_stocks VALUES (610, 'P-134', NULL, 1, 100);
INSERT INTO public.warehouse_stocks VALUES (611, 'P-129', NULL, 1, 200);
INSERT INTO public.warehouse_stocks VALUES (612, 'P-127', NULL, 1, 200);
INSERT INTO public.warehouse_stocks VALUES (613, 'P-093', NULL, 1, 100);
INSERT INTO public.warehouse_stocks VALUES (614, 'P-046', NULL, 1, 50);
INSERT INTO public.warehouse_stocks VALUES (615, 'P-007', NULL, 2, 70);
INSERT INTO public.warehouse_stocks VALUES (616, 'P-017', NULL, 1, 40);
INSERT INTO public.warehouse_stocks VALUES (617, 'P-022', NULL, 1, 250);
INSERT INTO public.warehouse_stocks VALUES (618, 'P-044', NULL, 1, 80);
INSERT INTO public.warehouse_stocks VALUES (619, 'P-126', NULL, 1, 200);
INSERT INTO public.warehouse_stocks VALUES (620, 'P-136', NULL, 1, 70);
INSERT INTO public.warehouse_stocks VALUES (621, 'P-063', NULL, 1, 60);
INSERT INTO public.warehouse_stocks VALUES (622, 'P-090', NULL, 1, 150);
INSERT INTO public.warehouse_stocks VALUES (623, 'P-070', NULL, 2, 150);
INSERT INTO public.warehouse_stocks VALUES (624, 'P-073', NULL, 2, 80);
INSERT INTO public.warehouse_stocks VALUES (625, 'P-016', NULL, 1, 50);
INSERT INTO public.warehouse_stocks VALUES (626, 'P-113', NULL, 1, 50);
INSERT INTO public.warehouse_stocks VALUES (627, 'P-008', NULL, 2, 70);
INSERT INTO public.warehouse_stocks VALUES (628, 'P-031', NULL, 1, 100);
INSERT INTO public.warehouse_stocks VALUES (629, 'P-108', NULL, 1, 150);
INSERT INTO public.warehouse_stocks VALUES (630, 'P-094', NULL, 1, 100);
INSERT INTO public.warehouse_stocks VALUES (631, 'P-040', NULL, 1, 200);
INSERT INTO public.warehouse_stocks VALUES (632, 'P-010', NULL, 1, 200);
INSERT INTO public.warehouse_stocks VALUES (633, 'P-064', NULL, 1, 80);
INSERT INTO public.warehouse_stocks VALUES (634, 'P-101', NULL, 1, 250);
INSERT INTO public.warehouse_stocks VALUES (635, 'P-033', NULL, 1, 60);
INSERT INTO public.warehouse_stocks VALUES (636, 'P-059', NULL, 1, 120);
INSERT INTO public.warehouse_stocks VALUES (637, 'P-123', NULL, 1, 100);
INSERT INTO public.warehouse_stocks VALUES (638, 'P-004', NULL, 2, 18);
INSERT INTO public.warehouse_stocks VALUES (639, 'P-053', NULL, 1, 100);
INSERT INTO public.warehouse_stocks VALUES (640, 'P-002', NULL, 2, 17);
INSERT INTO public.warehouse_stocks VALUES (641, 'P-026', NULL, 1, 100);
INSERT INTO public.warehouse_stocks VALUES (642, 'P-052', NULL, 1, 40);
INSERT INTO public.warehouse_stocks VALUES (643, 'P-021', NULL, 1, 300);
INSERT INTO public.warehouse_stocks VALUES (644, 'P-019', NULL, 1, 20);
INSERT INTO public.warehouse_stocks VALUES (645, 'P-112', NULL, 1, 120);
INSERT INTO public.warehouse_stocks VALUES (646, 'P-121', NULL, 1, 100);
INSERT INTO public.warehouse_stocks VALUES (647, 'P-057', NULL, 1, 50);
INSERT INTO public.warehouse_stocks VALUES (648, 'P-065', NULL, 1, 50);
INSERT INTO public.warehouse_stocks VALUES (649, 'P-122', NULL, 1, 120);
INSERT INTO public.warehouse_stocks VALUES (650, 'P-080', 19, 1, 12);
INSERT INTO public.warehouse_stocks VALUES (651, 'P-047', NULL, 1, 40);
INSERT INTO public.warehouse_stocks VALUES (652, 'P-011', NULL, 1, 150);
INSERT INTO public.warehouse_stocks VALUES (653, 'P-061', NULL, 1, 48);
INSERT INTO public.warehouse_stocks VALUES (654, 'P-013', NULL, 1, 100);
INSERT INTO public.warehouse_stocks VALUES (655, 'P-083', NULL, 1, 14);
INSERT INTO public.warehouse_stocks VALUES (656, 'P-035', NULL, 1, 40);
INSERT INTO public.warehouse_stocks VALUES (657, 'P-014', NULL, 1, 80);
INSERT INTO public.warehouse_stocks VALUES (658, 'P-003', NULL, 2, 70);
INSERT INTO public.warehouse_stocks VALUES (659, 'P-087', NULL, 1, 10);
INSERT INTO public.warehouse_stocks VALUES (660, 'P-023', NULL, 1, 200);
INSERT INTO public.warehouse_stocks VALUES (661, 'P-062', NULL, 1, 100);
INSERT INTO public.warehouse_stocks VALUES (662, 'P-051', NULL, 1, 100);
INSERT INTO public.warehouse_stocks VALUES (663, 'P-125', NULL, 1, 150);
INSERT INTO public.warehouse_stocks VALUES (664, 'P-018', NULL, 1, 30);
INSERT INTO public.warehouse_stocks VALUES (665, 'P-015', NULL, 1, 60);
INSERT INTO public.warehouse_stocks VALUES (666, 'P-079', 16, 1, 10);
INSERT INTO public.warehouse_stocks VALUES (667, 'P-120', NULL, 1, 100);
INSERT INTO public.warehouse_stocks VALUES (668, 'P-049', NULL, 1, 20);
INSERT INTO public.warehouse_stocks VALUES (669, 'P-106', NULL, 1, 190);
INSERT INTO public.warehouse_stocks VALUES (670, 'P-099', NULL, 1, 200);
INSERT INTO public.warehouse_stocks VALUES (671, 'P-131', NULL, 1, 100);
INSERT INTO public.warehouse_stocks VALUES (672, 'P-030', NULL, 1, 100);
INSERT INTO public.warehouse_stocks VALUES (673, 'P-058', NULL, 1, 15);
INSERT INTO public.warehouse_stocks VALUES (674, 'P-042', NULL, 1, 100);
INSERT INTO public.warehouse_stocks VALUES (675, 'P-137', NULL, 1, 50);
INSERT INTO public.warehouse_stocks VALUES (676, 'P-005', NULL, 2, 80);
INSERT INTO public.warehouse_stocks VALUES (677, 'P-032', NULL, 1, 80);
INSERT INTO public.warehouse_stocks VALUES (678, 'P-056', NULL, 1, 20);
INSERT INTO public.warehouse_stocks VALUES (679, 'P-066', NULL, 1, 70);
INSERT INTO public.warehouse_stocks VALUES (680, 'P-009', NULL, 1, 200);
INSERT INTO public.warehouse_stocks VALUES (681, 'P-012', NULL, 1, 100);
INSERT INTO public.warehouse_stocks VALUES (682, 'P-038', NULL, 1, 15);
INSERT INTO public.warehouse_stocks VALUES (683, 'P-109', NULL, 1, 100);
INSERT INTO public.warehouse_stocks VALUES (684, 'P-069', NULL, 2, 190);
INSERT INTO public.warehouse_stocks VALUES (591, 'P-001', NULL, 2, 250);
INSERT INTO public.warehouse_stocks VALUES (685, 'P-077', 9, 1, 39);


--
-- Data for Name: warehouses; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.warehouses VALUES (2, 'Gudang Y', 'Besi Beton dan Semen.', true, '2026-06-14 14:10:02.570435+07', '2026-06-14 14:22:36.997285+07');
INSERT INTO public.warehouses VALUES (1, 'Gudang M', 'Paralon, Kunci Pintu, Mesin, Engsel, dan Cat.', true, '2026-06-14 14:09:48.307587+07', '2026-06-14 14:59:44.962877+07');


--
-- Name: admins_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.admins_id_seq', 2, true);


--
-- Name: customer_addresses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.customer_addresses_id_seq', 7, true);


--
-- Name: customers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.customers_id_seq', 10, true);


--
-- Name: inbound_order_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.inbound_order_items_id_seq', 4, true);


--
-- Name: inbound_orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.inbound_orders_id_seq', 4, true);


--
-- Name: order_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_items_id_seq', 104, true);


--
-- Name: owners_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.owners_id_seq', 2, true);


--
-- Name: payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payments_id_seq', 86, true);


--
-- Name: product_variants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.product_variants_id_seq', 21, true);


--
-- Name: shippings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shippings_id_seq', 87, true);


--
-- Name: stock_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stock_logs_id_seq', 256, true);


--
-- Name: warehouse_stocks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.warehouse_stocks_id_seq', 685, true);


--
-- Name: warehouses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.warehouses_id_seq', 2, true);


--
-- Name: admins admins_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_pkey PRIMARY KEY (id);


--
-- Name: customer_addresses customer_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_addresses
    ADD CONSTRAINT customer_addresses_pkey PRIMARY KEY (id);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: inbound_order_items inbound_order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inbound_order_items
    ADD CONSTRAINT inbound_order_items_pkey PRIMARY KEY (id);


--
-- Name: inbound_orders inbound_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inbound_orders
    ADD CONSTRAINT inbound_orders_pkey PRIMARY KEY (id);


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
-- Name: owners owners_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.owners
    ADD CONSTRAINT owners_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: product_variants product_variants_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_variants
    ADD CONSTRAINT product_variants_pkey PRIMARY KEY (id);


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
-- Name: stock_logs stock_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_logs
    ADD CONSTRAINT stock_logs_pkey PRIMARY KEY (id);


--
-- Name: warehouses uni_warehouses_name; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouses
    ADD CONSTRAINT uni_warehouses_name UNIQUE (name);


--
-- Name: warehouse_stocks warehouse_stocks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouse_stocks
    ADD CONSTRAINT warehouse_stocks_pkey PRIMARY KEY (id);


--
-- Name: warehouses warehouses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouses
    ADD CONSTRAINT warehouses_pkey PRIMARY KEY (id);


--
-- Name: idx_admins_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_admins_email ON public.admins USING btree (email);


--
-- Name: idx_admins_username; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_admins_username ON public.admins USING btree (username);


--
-- Name: idx_customers_username; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_customers_username ON public.customers USING btree (username);


--
-- Name: idx_inbound_order_items_inbound_order_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_inbound_order_items_inbound_order_id ON public.inbound_order_items USING btree (inbound_order_id);


--
-- Name: idx_inbound_order_items_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_inbound_order_items_product_id ON public.inbound_order_items USING btree (product_id);


--
-- Name: idx_inbound_order_items_warehouse_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_inbound_order_items_warehouse_id ON public.inbound_order_items USING btree (warehouse_id);


--
-- Name: idx_order_items_order_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_order_items_order_id ON public.order_items USING btree (order_id);


--
-- Name: idx_order_items_variant_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_order_items_variant_id ON public.order_items USING btree (variant_id);


--
-- Name: idx_owners_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_owners_email ON public.owners USING btree (email);


--
-- Name: idx_owners_username; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_owners_username ON public.owners USING btree (username);


--
-- Name: idx_payments_order_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_payments_order_id ON public.payments USING btree (order_id);


--
-- Name: idx_prod_var_wh; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_prod_var_wh ON public.warehouse_stocks USING btree (product_id, variant_id, warehouse_id);


--
-- Name: idx_product_variants_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_product_variants_product_id ON public.product_variants USING btree (product_id);


--
-- Name: idx_shippings_order_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_shippings_order_id ON public.shippings USING btree (order_id);


--
-- Name: idx_stock_logs_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_stock_logs_product_id ON public.stock_logs USING btree (product_id);


--
-- Name: idx_stock_logs_variant_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_stock_logs_variant_id ON public.stock_logs USING btree (variant_id);


--
-- Name: idx_stock_logs_warehouse_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_stock_logs_warehouse_id ON public.stock_logs USING btree (warehouse_id);


--
-- Name: inbound_order_items fk_inbound_order_items_product; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inbound_order_items
    ADD CONSTRAINT fk_inbound_order_items_product FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: inbound_order_items fk_inbound_order_items_variant; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inbound_order_items
    ADD CONSTRAINT fk_inbound_order_items_variant FOREIGN KEY (variant_id) REFERENCES public.product_variants(id);


--
-- Name: inbound_order_items fk_inbound_order_items_warehouse; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inbound_order_items
    ADD CONSTRAINT fk_inbound_order_items_warehouse FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id);


--
-- Name: inbound_order_items fk_inbound_orders_items; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inbound_order_items
    ADD CONSTRAINT fk_inbound_orders_items FOREIGN KEY (inbound_order_id) REFERENCES public.inbound_orders(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: orders fk_orders_customer; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES public.customers(id);


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
-- Name: product_variants fk_products_variants; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_variants
    ADD CONSTRAINT fk_products_variants FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: shippings fk_shippings_admin; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shippings
    ADD CONSTRAINT fk_shippings_admin FOREIGN KEY (admin_id) REFERENCES public.admins(id);


--
-- Name: stock_logs fk_stock_logs_owner; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_logs
    ADD CONSTRAINT fk_stock_logs_owner FOREIGN KEY (owner_id) REFERENCES public.owners(id);


--
-- Name: stock_logs fk_stock_logs_product; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_logs
    ADD CONSTRAINT fk_stock_logs_product FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: stock_logs fk_stock_logs_variant; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_logs
    ADD CONSTRAINT fk_stock_logs_variant FOREIGN KEY (variant_id) REFERENCES public.product_variants(id);


--
-- Name: stock_logs fk_stock_logs_warehouse; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_logs
    ADD CONSTRAINT fk_stock_logs_warehouse FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id);


--
-- Name: warehouse_stocks fk_warehouse_stocks_product; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouse_stocks
    ADD CONSTRAINT fk_warehouse_stocks_product FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: warehouse_stocks fk_warehouse_stocks_variant; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouse_stocks
    ADD CONSTRAINT fk_warehouse_stocks_variant FOREIGN KEY (variant_id) REFERENCES public.product_variants(id);


--
-- Name: warehouse_stocks fk_warehouse_stocks_warehouse; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouse_stocks
    ADD CONSTRAINT fk_warehouse_stocks_warehouse FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id);


--
-- PostgreSQL database dump complete
--

\unrestrict 5SMgr5JoejPk5aR1NcwEfgluqtQP4y5UKn3KhCekBRGCZjldEXcyeVKEnv1Etvp

