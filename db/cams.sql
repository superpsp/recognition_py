--
-- PostgreSQL database dump
--

-- Dumped from database version 15.6
-- Dumped by pg_dump version 16.4

-- Started on 2024-10-13 19:38:56

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
-- TOC entry 13 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO pg_database_owner;

--
-- TOC entry 3876 (class 0 OID 0)
-- Dependencies: 13
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- TOC entry 325 (class 1255 OID 38327)
-- Name: get_or_create_channel(integer, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_or_create_channel(p_number integer, p_device_id bigint) RETURNS bigint
    LANGUAGE plpgsql
    AS $$declare
	v_id bigint;
begin
	select id
		into v_id
		from channel
		where number = p_number
		and device_id = p_device_id;
		
	if not found then
		insert into channel (
			number
			, device_id
		)
		select
			p_number number
			, p_device_id device_id
		returning id into v_id;
	end if;
	
	return v_id;
end;
$$;


ALTER FUNCTION public.get_or_create_channel(p_number integer, p_device_id bigint) OWNER TO postgres;

--
-- TOC entry 320 (class 1255 OID 38233)
-- Name: get_or_create_container(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_or_create_container(p_name text, p_parent_name text DEFAULT NULL::text) RETURNS bigint
    LANGUAGE plpgsql
    AS $$declare
	v_id bigint;
begin
	select id
		into v_id
		from container
		where name = p_name;
		
	if not found then
		insert into container (
			name
			, type_id
			, parent_id
		)
		select
			p_name name
			, id type_id
			, (
				select id
					from container
					where name = p_parent_name
			) parent_id
			from container_type
			where name = case
				when strpos(p_name, 'snapshots') > 0 then 'zip'
				else 'directory'
			end
		returning id into v_id;
	end if;
	
	return v_id;
end;
$$;


ALTER FUNCTION public.get_or_create_container(p_name text, p_parent_name text) OWNER TO postgres;

--
-- TOC entry 324 (class 1255 OID 38325)
-- Name: get_or_create_device(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_or_create_device(p_ip text) RETURNS bigint
    LANGUAGE plpgsql
    AS $$declare
	v_id bigint;
begin
	select id
		into v_id
		from device
		where ip = p_ip;
		
	if not found then
		insert into device (
			ip
		)
		select
			p_ip ip
		returning id into v_id;
	end if;
	
	return v_id;
end;
$$;


ALTER FUNCTION public.get_or_create_device(p_ip text) OWNER TO postgres;

--
-- TOC entry 327 (class 1255 OID 38330)
-- Name: get_or_create_device_login(bigint, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_or_create_device_login(p_device_id bigint, p_login_id bigint) RETURNS bigint
    LANGUAGE plpgsql
    AS $$declare
	v_id bigint;
begin
	select id
		into v_id
		from device_login
		where device_id = p_device_id
		and login_id = p_login_id;
		
	if not found then
		insert into device_login (
			device_id
			, login_id
		)
		select
			p_device_id device_id
			, p_login_id login_id
		returning id into v_id;
	end if;
	
	return v_id;
end;
$$;


ALTER FUNCTION public.get_or_create_device_login(p_device_id bigint, p_login_id bigint) OWNER TO postgres;

--
-- TOC entry 326 (class 1255 OID 38329)
-- Name: get_or_create_login(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_or_create_login(p_user_name text, p_password text) RETURNS bigint
    LANGUAGE plpgsql
    AS $$declare
	v_id bigint;
begin
	select id
		into v_id
		from login
		where user_name = p_user_name
		and password = p_password;
		
	if not found then
		insert into login (
			user_name
			, password
		)
		select
			p_user_name user_name
			, p_password password
		returning id into v_id;
	end if;
	
	return v_id;
end;
$$;


ALTER FUNCTION public.get_or_create_login(p_user_name text, p_password text) OWNER TO postgres;

--
-- TOC entry 328 (class 1255 OID 38356)
-- Name: get_or_create_object(text, bigint, bigint, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_or_create_object(p_name text, p_channel_id bigint, p_container_id bigint, p_probability double precision) RETURNS bigint
    LANGUAGE plpgsql
    AS $$declare
	v_id bigint;
begin
	select id
		into v_id
		from object
		where channel_id = p_channel_id
		and container_id = p_container_id
		and probability = p_probability;

	if not found then
		select id
			into v_id
			from object
			where channel_id = p_channel_id
			and container_id = p_container_id;
		
		if not found then
			insert into object (
				channel_id
				, container_id
				, class_id
			)
			select
				p_channel_id channel_id
				, p_container_id container_id
				, (
					select id
						from class
						where name = p_name
				) class_id
			returning id into v_id;
		end if;
		
		update object
			set probability = p_probability
			where id = v_id;
	end if;
	
	return v_id;
end;
$$;


ALTER FUNCTION public.get_or_create_object(p_name text, p_channel_id bigint, p_container_id bigint, p_probability double precision) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 297 (class 1259 OID 29241)
-- Name: channel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.channel (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    number integer NOT NULL,
    device_id bigint NOT NULL
);


ALTER TABLE public.channel OWNER TO postgres;

--
-- TOC entry 3884 (class 0 OID 0)
-- Dependencies: 297
-- Name: TABLE channel; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.channel IS 'channel';


--
-- TOC entry 298 (class 1259 OID 29244)
-- Name: channel_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.channel ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.channel_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 299 (class 1259 OID 29256)
-- Name: class; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.class (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    name text,
    yolo_id integer
);


ALTER TABLE public.class OWNER TO postgres;

--
-- TOC entry 3887 (class 0 OID 0)
-- Dependencies: 299
-- Name: TABLE class; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.class IS 'class';


--
-- TOC entry 300 (class 1259 OID 29259)
-- Name: class_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.class ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.class_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 289 (class 1259 OID 29177)
-- Name: container; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.container (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    type_id smallint NOT NULL,
    name text,
    parent_id bigint
);


ALTER TABLE public.container OWNER TO postgres;

--
-- TOC entry 3890 (class 0 OID 0)
-- Dependencies: 289
-- Name: TABLE container; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.container IS 'container';


--
-- TOC entry 290 (class 1259 OID 29180)
-- Name: container_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.container ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.container_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 291 (class 1259 OID 29190)
-- Name: container_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.container_type (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    name text
);


ALTER TABLE public.container_type OWNER TO postgres;

--
-- TOC entry 3893 (class 0 OID 0)
-- Dependencies: 291
-- Name: TABLE container_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.container_type IS 'container_type';


--
-- TOC entry 292 (class 1259 OID 29193)
-- Name: container_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.container_type ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.container_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 295 (class 1259 OID 29219)
-- Name: device; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.device (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    ip text
);


ALTER TABLE public.device OWNER TO postgres;

--
-- TOC entry 3896 (class 0 OID 0)
-- Dependencies: 295
-- Name: TABLE device; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.device IS 'device';


--
-- TOC entry 296 (class 1259 OID 29222)
-- Name: device_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.device ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.device_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 303 (class 1259 OID 30474)
-- Name: device_login; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.device_login (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    device_id bigint NOT NULL,
    login_id bigint NOT NULL,
    is_working text,
    is_default text
);


ALTER TABLE public.device_login OWNER TO postgres;

--
-- TOC entry 304 (class 1259 OID 30477)
-- Name: device_login_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.device_login ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.device_login_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 293 (class 1259 OID 29207)
-- Name: login; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.login (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_name text,
    password text
);


ALTER TABLE public.login OWNER TO postgres;

--
-- TOC entry 3901 (class 0 OID 0)
-- Dependencies: 293
-- Name: TABLE login; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.login IS 'login';


--
-- TOC entry 294 (class 1259 OID 29210)
-- Name: login_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.login ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.login_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 301 (class 1259 OID 29310)
-- Name: object; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.object (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    channel_id bigint NOT NULL,
    container_id bigint NOT NULL,
    class_id bigint NOT NULL,
    probability double precision,
    processed_at timestamp with time zone
);


ALTER TABLE public.object OWNER TO postgres;

--
-- TOC entry 3904 (class 0 OID 0)
-- Dependencies: 301
-- Name: TABLE object; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.object IS 'Recognized object';


--
-- TOC entry 302 (class 1259 OID 29313)
-- Name: object_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.object ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.object_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 3706 (class 2606 OID 29250)
-- Name: channel channel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.channel
    ADD CONSTRAINT channel_pkey PRIMARY KEY (id);


--
-- TOC entry 3708 (class 2606 OID 29267)
-- Name: class class_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.class
    ADD CONSTRAINT class_pkey PRIMARY KEY (id);


--
-- TOC entry 3698 (class 2606 OID 29188)
-- Name: container container_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.container
    ADD CONSTRAINT container_pkey PRIMARY KEY (id);


--
-- TOC entry 3700 (class 2606 OID 29201)
-- Name: container_type container_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.container_type
    ADD CONSTRAINT container_type_pkey PRIMARY KEY (id);


--
-- TOC entry 3712 (class 2606 OID 30485)
-- Name: device_login device_login_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_login
    ADD CONSTRAINT device_login_pkey PRIMARY KEY (id);


--
-- TOC entry 3704 (class 2606 OID 29230)
-- Name: device device_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device
    ADD CONSTRAINT device_pkey PRIMARY KEY (id);


--
-- TOC entry 3702 (class 2606 OID 29218)
-- Name: login login_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.login
    ADD CONSTRAINT login_pkey PRIMARY KEY (id);


--
-- TOC entry 3710 (class 2606 OID 29319)
-- Name: object object_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.object
    ADD CONSTRAINT object_pkey PRIMARY KEY (id);


--
-- TOC entry 3715 (class 2606 OID 29251)
-- Name: channel channel_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.channel
    ADD CONSTRAINT channel_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.device(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3713 (class 2606 OID 29236)
-- Name: container container_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.container
    ADD CONSTRAINT container_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.container(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3714 (class 2606 OID 29202)
-- Name: container container_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.container
    ADD CONSTRAINT container_type_fkey FOREIGN KEY (type_id) REFERENCES public.container_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3719 (class 2606 OID 30486)
-- Name: device_login device_login_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_login
    ADD CONSTRAINT device_login_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.device(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3720 (class 2606 OID 30491)
-- Name: device_login device_login_login_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_login
    ADD CONSTRAINT device_login_login_id_fkey FOREIGN KEY (login_id) REFERENCES public.login(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3716 (class 2606 OID 29320)
-- Name: object object_channel_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.object
    ADD CONSTRAINT object_channel_id_fkey FOREIGN KEY (channel_id) REFERENCES public.channel(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3717 (class 2606 OID 29330)
-- Name: object object_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.object
    ADD CONSTRAINT object_class_id_fkey FOREIGN KEY (class_id) REFERENCES public.class(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3718 (class 2606 OID 29325)
-- Name: object object_container_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.object
    ADD CONSTRAINT object_container_id_fkey FOREIGN KEY (container_id) REFERENCES public.container(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3877 (class 0 OID 0)
-- Dependencies: 13
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO postgres;
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO service_role;


--
-- TOC entry 3878 (class 0 OID 0)
-- Dependencies: 325
-- Name: FUNCTION get_or_create_channel(p_number integer, p_device_id bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_or_create_channel(p_number integer, p_device_id bigint) TO anon;
GRANT ALL ON FUNCTION public.get_or_create_channel(p_number integer, p_device_id bigint) TO authenticated;
GRANT ALL ON FUNCTION public.get_or_create_channel(p_number integer, p_device_id bigint) TO service_role;


--
-- TOC entry 3879 (class 0 OID 0)
-- Dependencies: 320
-- Name: FUNCTION get_or_create_container(p_name text, p_parent_name text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_or_create_container(p_name text, p_parent_name text) TO anon;
GRANT ALL ON FUNCTION public.get_or_create_container(p_name text, p_parent_name text) TO authenticated;
GRANT ALL ON FUNCTION public.get_or_create_container(p_name text, p_parent_name text) TO service_role;


--
-- TOC entry 3880 (class 0 OID 0)
-- Dependencies: 324
-- Name: FUNCTION get_or_create_device(p_ip text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_or_create_device(p_ip text) TO anon;
GRANT ALL ON FUNCTION public.get_or_create_device(p_ip text) TO authenticated;
GRANT ALL ON FUNCTION public.get_or_create_device(p_ip text) TO service_role;


--
-- TOC entry 3881 (class 0 OID 0)
-- Dependencies: 327
-- Name: FUNCTION get_or_create_device_login(p_device_id bigint, p_login_id bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_or_create_device_login(p_device_id bigint, p_login_id bigint) TO anon;
GRANT ALL ON FUNCTION public.get_or_create_device_login(p_device_id bigint, p_login_id bigint) TO authenticated;
GRANT ALL ON FUNCTION public.get_or_create_device_login(p_device_id bigint, p_login_id bigint) TO service_role;


--
-- TOC entry 3882 (class 0 OID 0)
-- Dependencies: 326
-- Name: FUNCTION get_or_create_login(p_user_name text, p_password text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_or_create_login(p_user_name text, p_password text) TO anon;
GRANT ALL ON FUNCTION public.get_or_create_login(p_user_name text, p_password text) TO authenticated;
GRANT ALL ON FUNCTION public.get_or_create_login(p_user_name text, p_password text) TO service_role;


--
-- TOC entry 3883 (class 0 OID 0)
-- Dependencies: 328
-- Name: FUNCTION get_or_create_object(p_name text, p_channel_id bigint, p_container_id bigint, p_probability double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_or_create_object(p_name text, p_channel_id bigint, p_container_id bigint, p_probability double precision) TO anon;
GRANT ALL ON FUNCTION public.get_or_create_object(p_name text, p_channel_id bigint, p_container_id bigint, p_probability double precision) TO authenticated;
GRANT ALL ON FUNCTION public.get_or_create_object(p_name text, p_channel_id bigint, p_container_id bigint, p_probability double precision) TO service_role;


--
-- TOC entry 3885 (class 0 OID 0)
-- Dependencies: 297
-- Name: TABLE channel; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.channel TO anon;
GRANT ALL ON TABLE public.channel TO authenticated;
GRANT ALL ON TABLE public.channel TO service_role;


--
-- TOC entry 3886 (class 0 OID 0)
-- Dependencies: 298
-- Name: SEQUENCE channel_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.channel_id_seq TO anon;
GRANT ALL ON SEQUENCE public.channel_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.channel_id_seq TO service_role;


--
-- TOC entry 3888 (class 0 OID 0)
-- Dependencies: 299
-- Name: TABLE class; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.class TO anon;
GRANT ALL ON TABLE public.class TO authenticated;
GRANT ALL ON TABLE public.class TO service_role;


--
-- TOC entry 3889 (class 0 OID 0)
-- Dependencies: 300
-- Name: SEQUENCE class_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.class_id_seq TO anon;
GRANT ALL ON SEQUENCE public.class_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.class_id_seq TO service_role;


--
-- TOC entry 3891 (class 0 OID 0)
-- Dependencies: 289
-- Name: TABLE container; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.container TO anon;
GRANT ALL ON TABLE public.container TO authenticated;
GRANT ALL ON TABLE public.container TO service_role;


--
-- TOC entry 3892 (class 0 OID 0)
-- Dependencies: 290
-- Name: SEQUENCE container_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.container_id_seq TO anon;
GRANT ALL ON SEQUENCE public.container_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.container_id_seq TO service_role;


--
-- TOC entry 3894 (class 0 OID 0)
-- Dependencies: 291
-- Name: TABLE container_type; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.container_type TO anon;
GRANT ALL ON TABLE public.container_type TO authenticated;
GRANT ALL ON TABLE public.container_type TO service_role;


--
-- TOC entry 3895 (class 0 OID 0)
-- Dependencies: 292
-- Name: SEQUENCE container_type_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.container_type_id_seq TO anon;
GRANT ALL ON SEQUENCE public.container_type_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.container_type_id_seq TO service_role;


--
-- TOC entry 3897 (class 0 OID 0)
-- Dependencies: 295
-- Name: TABLE device; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.device TO anon;
GRANT ALL ON TABLE public.device TO authenticated;
GRANT ALL ON TABLE public.device TO service_role;


--
-- TOC entry 3898 (class 0 OID 0)
-- Dependencies: 296
-- Name: SEQUENCE device_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.device_id_seq TO anon;
GRANT ALL ON SEQUENCE public.device_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.device_id_seq TO service_role;


--
-- TOC entry 3899 (class 0 OID 0)
-- Dependencies: 303
-- Name: TABLE device_login; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.device_login TO anon;
GRANT ALL ON TABLE public.device_login TO authenticated;
GRANT ALL ON TABLE public.device_login TO service_role;


--
-- TOC entry 3900 (class 0 OID 0)
-- Dependencies: 304
-- Name: SEQUENCE device_login_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.device_login_id_seq TO anon;
GRANT ALL ON SEQUENCE public.device_login_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.device_login_id_seq TO service_role;


--
-- TOC entry 3902 (class 0 OID 0)
-- Dependencies: 293
-- Name: TABLE login; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.login TO anon;
GRANT ALL ON TABLE public.login TO authenticated;
GRANT ALL ON TABLE public.login TO service_role;


--
-- TOC entry 3903 (class 0 OID 0)
-- Dependencies: 294
-- Name: SEQUENCE login_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.login_id_seq TO anon;
GRANT ALL ON SEQUENCE public.login_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.login_id_seq TO service_role;


--
-- TOC entry 3905 (class 0 OID 0)
-- Dependencies: 301
-- Name: TABLE object; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.object TO anon;
GRANT ALL ON TABLE public.object TO authenticated;
GRANT ALL ON TABLE public.object TO service_role;


--
-- TOC entry 3906 (class 0 OID 0)
-- Dependencies: 302
-- Name: SEQUENCE object_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.object_id_seq TO anon;
GRANT ALL ON SEQUENCE public.object_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.object_id_seq TO service_role;


--
-- TOC entry 2490 (class 826 OID 16484)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- TOC entry 2491 (class 826 OID 16485)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- TOC entry 2489 (class 826 OID 16483)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- TOC entry 2493 (class 826 OID 16487)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- TOC entry 2488 (class 826 OID 16482)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO service_role;


--
-- TOC entry 2492 (class 826 OID 16486)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO service_role;


-- Completed on 2024-10-13 19:39:02

--
-- PostgreSQL database dump complete
--

