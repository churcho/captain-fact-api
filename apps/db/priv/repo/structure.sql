--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.4
-- Dumped by pg_dump version 9.6.8

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: accounts_reset_password_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accounts_reset_password_requests (
    token character varying(255) NOT NULL,
    source_ip character varying(255) NOT NULL,
    user_id bigint NOT NULL,
    inserted_at timestamp without time zone NOT NULL
);


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comments (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    statement_id bigint NOT NULL,
    source_id bigint,
    reply_to_id bigint,
    text character varying(255),
    approve boolean,
    is_reported boolean DEFAULT false NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comments_id_seq OWNED BY public.comments.id;


--
-- Name: flags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flags (
    id bigint NOT NULL,
    reason integer NOT NULL,
    source_user_id bigint NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    action_id bigint NOT NULL
);


--
-- Name: flags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.flags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: flags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.flags_id_seq OWNED BY public.flags.id;


--
-- Name: invitation_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invitation_requests (
    id bigint NOT NULL,
    email character varying(255),
    token character varying(255),
    invitation_sent boolean DEFAULT false NOT NULL,
    invited_by_id bigint,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: invitation_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.invitation_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invitation_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.invitation_requests_id_seq OWNED BY public.invitation_requests.id;


--
-- Name: moderation_users_feedbacks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.moderation_users_feedbacks (
    id bigint NOT NULL,
    value integer,
    user_id bigint,
    action_id bigint,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: moderation_users_feedbacks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.moderation_users_feedbacks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: moderation_users_feedbacks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.moderation_users_feedbacks_id_seq OWNED BY public.moderation_users_feedbacks.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp without time zone
);


--
-- Name: sources; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sources (
    id bigint NOT NULL,
    url character varying(255) NOT NULL,
    title character varying(255),
    language character varying(255),
    site_name character varying(255),
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sources_id_seq OWNED BY public.sources.id;


--
-- Name: speakers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.speakers (
    id bigint NOT NULL,
    full_name public.citext NOT NULL,
    title character varying(255),
    is_user_defined boolean NOT NULL,
    picture character varying(255),
    wikidata_item_id integer,
    country character varying(255),
    is_removed boolean DEFAULT false NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    slug character varying(255)
);


--
-- Name: speakers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.speakers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: speakers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.speakers_id_seq OWNED BY public.speakers.id;


--
-- Name: statements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.statements (
    id bigint NOT NULL,
    text character varying(255) NOT NULL,
    "time" integer NOT NULL,
    is_removed boolean DEFAULT false NOT NULL,
    video_id bigint NOT NULL,
    speaker_id bigint,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: statements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.statements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: statements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.statements_id_seq OWNED BY public.statements.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    username public.citext NOT NULL,
    email public.citext NOT NULL,
    encrypted_password character varying(255) NOT NULL,
    name public.citext,
    picture_url character varying(255),
    reputation integer DEFAULT 0 NOT NULL,
    locale character varying(255),
    fb_user_id character varying(255),
    email_confirmed boolean DEFAULT false NOT NULL,
    email_confirmation_token character varying(255),
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    achievements integer[] DEFAULT ARRAY[]::integer[] NOT NULL,
    today_reputation_gain integer DEFAULT 0 NOT NULL,
    newsletter boolean DEFAULT true NOT NULL,
    newsletter_subscription_token character varying(255) DEFAULT md5((random())::text) NOT NULL,
    is_publisher boolean DEFAULT false NOT NULL
);


--
-- Name: users_actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_actions (
    id bigint NOT NULL,
    user_id bigint,
    target_user_id bigint,
    type integer NOT NULL,
    entity integer NOT NULL,
    context character varying(255),
    entity_id integer,
    changes jsonb,
    inserted_at timestamp without time zone NOT NULL
);


--
-- Name: users_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_actions_id_seq OWNED BY public.users_actions.id;


--
-- Name: users_actions_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_actions_reports (
    id bigint NOT NULL,
    analyser_id integer NOT NULL,
    last_action_id integer NOT NULL,
    status integer NOT NULL,
    nb_actions integer,
    nb_entries_updated integer,
    run_duration integer,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: users_actions_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_actions_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_actions_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_actions_reports_id_seq OWNED BY public.users_actions_reports.id;


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: videos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.videos (
    id bigint NOT NULL,
    provider character varying(255) NOT NULL,
    provider_id character varying(255) NOT NULL,
    title character varying(255) NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    language character varying(2)
);


--
-- Name: videos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.videos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: videos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.videos_id_seq OWNED BY public.videos.id;


--
-- Name: videos_speakers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.videos_speakers (
    video_id bigint NOT NULL,
    speaker_id bigint NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: votes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.votes (
    value integer NOT NULL,
    user_id bigint NOT NULL,
    comment_id bigint NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments ALTER COLUMN id SET DEFAULT nextval('public.comments_id_seq'::regclass);


--
-- Name: flags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flags ALTER COLUMN id SET DEFAULT nextval('public.flags_id_seq'::regclass);


--
-- Name: invitation_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitation_requests ALTER COLUMN id SET DEFAULT nextval('public.invitation_requests_id_seq'::regclass);


--
-- Name: moderation_users_feedbacks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_users_feedbacks ALTER COLUMN id SET DEFAULT nextval('public.moderation_users_feedbacks_id_seq'::regclass);


--
-- Name: sources id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sources ALTER COLUMN id SET DEFAULT nextval('public.sources_id_seq'::regclass);


--
-- Name: speakers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.speakers ALTER COLUMN id SET DEFAULT nextval('public.speakers_id_seq'::regclass);


--
-- Name: statements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.statements ALTER COLUMN id SET DEFAULT nextval('public.statements_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: users_actions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_actions ALTER COLUMN id SET DEFAULT nextval('public.users_actions_id_seq'::regclass);


--
-- Name: users_actions_reports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_actions_reports ALTER COLUMN id SET DEFAULT nextval('public.users_actions_reports_id_seq'::regclass);


--
-- Name: videos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.videos ALTER COLUMN id SET DEFAULT nextval('public.videos_id_seq'::regclass);


--
-- Name: accounts_reset_password_requests accounts_reset_password_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts_reset_password_requests
    ADD CONSTRAINT accounts_reset_password_requests_pkey PRIMARY KEY (token);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: flags flags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flags
    ADD CONSTRAINT flags_pkey PRIMARY KEY (id);


--
-- Name: invitation_requests invitation_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitation_requests
    ADD CONSTRAINT invitation_requests_pkey PRIMARY KEY (id);


--
-- Name: moderation_users_feedbacks moderation_users_feedbacks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_users_feedbacks
    ADD CONSTRAINT moderation_users_feedbacks_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sources sources_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sources
    ADD CONSTRAINT sources_pkey PRIMARY KEY (id);


--
-- Name: speakers speakers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.speakers
    ADD CONSTRAINT speakers_pkey PRIMARY KEY (id);


--
-- Name: statements statements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.statements
    ADD CONSTRAINT statements_pkey PRIMARY KEY (id);


--
-- Name: users_actions users_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_actions
    ADD CONSTRAINT users_actions_pkey PRIMARY KEY (id);


--
-- Name: users_actions_reports users_actions_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_actions_reports
    ADD CONSTRAINT users_actions_reports_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: videos videos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.videos
    ADD CONSTRAINT videos_pkey PRIMARY KEY (id);


--
-- Name: videos_speakers videos_speakers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.videos_speakers
    ADD CONSTRAINT videos_speakers_pkey PRIMARY KEY (video_id, speaker_id);


--
-- Name: votes votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT votes_pkey PRIMARY KEY (user_id, comment_id);


--
-- Name: comments_statement_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX comments_statement_id_index ON public.comments USING btree (statement_id);


--
-- Name: comments_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX comments_user_id_index ON public.comments USING btree (user_id);


--
-- Name: invitation_requests_email_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX invitation_requests_email_index ON public.invitation_requests USING btree (email);


--
-- Name: moderation_users_feedbacks_user_id_action_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX moderation_users_feedbacks_user_id_action_id_index ON public.moderation_users_feedbacks USING btree (user_id, action_id);


--
-- Name: sources_url_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sources_url_index ON public.sources USING btree (url);


--
-- Name: speakers_full_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX speakers_full_name_index ON public.speakers USING btree (full_name) WHERE (is_user_defined = false);


--
-- Name: speakers_slug_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX speakers_slug_index ON public.speakers USING btree (slug) WHERE ((slug)::text <> NULL::text);


--
-- Name: speakers_wikidata_item_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX speakers_wikidata_item_id_index ON public.speakers USING btree (wikidata_item_id) WHERE (is_user_defined = false);


--
-- Name: statements_speaker_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX statements_speaker_id_index ON public.statements USING btree (speaker_id) WHERE (is_removed = false);


--
-- Name: statements_video_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX statements_video_id_index ON public.statements USING btree (video_id) WHERE (is_removed = false);


--
-- Name: user_comment_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_comment_index ON public.votes USING btree (user_id, comment_id);


--
-- Name: user_flags_unique_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_flags_unique_index ON public.flags USING btree (source_user_id, action_id);


--
-- Name: users_actions_context_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_actions_context_index ON public.users_actions USING btree (context);


--
-- Name: users_actions_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_actions_user_id_index ON public.users_actions USING btree (user_id);


--
-- Name: users_email_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_email_index ON public.users USING btree (email);


--
-- Name: users_fb_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_fb_user_id_index ON public.users USING btree (fb_user_id);


--
-- Name: users_newsletter_subscription_token_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_newsletter_subscription_token_index ON public.users USING btree (newsletter_subscription_token);


--
-- Name: users_username_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_username_index ON public.users USING btree (username);


--
-- Name: videos_language_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX videos_language_index ON public.videos USING btree (language);


--
-- Name: videos_provider_provider_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX videos_provider_provider_id_index ON public.videos USING btree (provider, provider_id);


--
-- Name: videos_speakers_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX videos_speakers_index ON public.videos_speakers USING btree (video_id, speaker_id);


--
-- Name: accounts_reset_password_requests accounts_reset_password_requests_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts_reset_password_requests
    ADD CONSTRAINT accounts_reset_password_requests_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: comments comments_reply_to_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_reply_to_id_fkey FOREIGN KEY (reply_to_id) REFERENCES public.comments(id) ON DELETE CASCADE;


--
-- Name: comments comments_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_source_id_fkey FOREIGN KEY (source_id) REFERENCES public.sources(id) ON DELETE SET NULL;


--
-- Name: comments comments_statement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_statement_id_fkey FOREIGN KEY (statement_id) REFERENCES public.statements(id) ON DELETE CASCADE;


--
-- Name: comments comments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: flags flags_action_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flags
    ADD CONSTRAINT flags_action_id_fkey FOREIGN KEY (action_id) REFERENCES public.users_actions(id) ON DELETE CASCADE;


--
-- Name: flags flags_source_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flags
    ADD CONSTRAINT flags_source_user_id_fkey FOREIGN KEY (source_user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: invitation_requests invitation_requests_invited_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitation_requests
    ADD CONSTRAINT invitation_requests_invited_by_id_fkey FOREIGN KEY (invited_by_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: moderation_users_feedbacks moderation_users_feedbacks_action_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_users_feedbacks
    ADD CONSTRAINT moderation_users_feedbacks_action_id_fkey FOREIGN KEY (action_id) REFERENCES public.users_actions(id) ON DELETE CASCADE;


--
-- Name: moderation_users_feedbacks moderation_users_feedbacks_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_users_feedbacks
    ADD CONSTRAINT moderation_users_feedbacks_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: statements statements_speaker_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.statements
    ADD CONSTRAINT statements_speaker_id_fkey FOREIGN KEY (speaker_id) REFERENCES public.speakers(id) ON DELETE SET NULL;


--
-- Name: statements statements_video_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.statements
    ADD CONSTRAINT statements_video_id_fkey FOREIGN KEY (video_id) REFERENCES public.videos(id) ON DELETE CASCADE;


--
-- Name: users_actions users_actions_target_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_actions
    ADD CONSTRAINT users_actions_target_user_id_fkey FOREIGN KEY (target_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: users_actions users_actions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_actions
    ADD CONSTRAINT users_actions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: videos_speakers videos_speakers_speaker_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.videos_speakers
    ADD CONSTRAINT videos_speakers_speaker_id_fkey FOREIGN KEY (speaker_id) REFERENCES public.speakers(id) ON DELETE CASCADE;


--
-- Name: videos_speakers videos_speakers_video_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.videos_speakers
    ADD CONSTRAINT videos_speakers_video_id_fkey FOREIGN KEY (video_id) REFERENCES public.videos(id) ON DELETE CASCADE;


--
-- Name: votes votes_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT votes_comment_id_fkey FOREIGN KEY (comment_id) REFERENCES public.comments(id) ON DELETE CASCADE;


--
-- Name: votes votes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT votes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

INSERT INTO "schema_migrations" (version) VALUES (20170118223600), (20170118223631), (20170125235612), (20170206062334), (20170206063137), (20170221035619), (20170309214200), (20170309214307), (20170316233954), (20170428062411), (20170611075306), (20170726224741), (20170730064848), (20170928043353), (20171003220327), (20171003220416), (20171004100258), (20171005001838), (20171005215001), (20171009065840), (20171026222425), (20171105124655), (20171109105152), (20171110040302), (20171110212108), (20171117131508), (20171119075520), (20171205174328), (20180131002547), (20180302024059);
