------------------
-- DROP TABLES ---
------------------

DROP TABLE osoba CASCADE CONSTRAINTS;
DROP TABLE alkoholik CASCADE CONSTRAINTS;
DROP TABLE patron CASCADE CONSTRAINTS;
DROP TABLE odbornik CASCADE CONSTRAINTS;
DROP TABLE schuze CASCADE CONSTRAINTS;
DROP TABLE sezeni CASCADE CONSTRAINTS;
DROP TABLE misto_konani CASCADE CONSTRAINTS;
DROP TABLE zaznam CASCADE CONSTRAINTS;
DROP TABLE je_sverencem CASCADE CONSTRAINTS;
DROP TABLE je_pacientem CASCADE CONSTRAINTS;
DROP TABLE byl_pritomen CASCADE CONSTRAINTS;
DROP TABLE ucast CASCADE CONSTRAINTS;
DROP TABLE vedl CASCADE CONSTRAINTS;

DROP SEQUENCE osoba_seq;
DROP SEQUENCE alkoholik_seq;
DROP SEQUENCE sezeni_seq;
DROP SEQUENCE misto_seq;
DROP SEQUENCE zaznam_seq;
DROP SEQUENCE schuze_seq;

DROP MATERIALIZED VIEW odbornik_role;
DROP MATERIALIZED VIEW patron_pocet;


ALTER SESSION SET NLS_DATE_FORMAT = 'DD.MM.YYYY HH24:MI';

--------------------------------
-- CREATE TABLES AND ADD KEYS --
--------------------------------

CREATE TABLE osoba(
  id_osoba NUMBER NOT NULL,
  jmeno VARCHAR2(64) NOT NULL,
  prijmeni VARCHAR2(128) NOT NULL,
  rodne_cislo NUMBER NOT NULL,
  
  CONSTRAINT pk_osoba PRIMARY KEY (id_osoba),
  CONSTRAINT rc_osoba UNIQUE (rodne_cislo)
);

/* specialisations of osoba */
CREATE TABLE patron(
  id_osoba NUMBER NOT NULL,
  
  CONSTRAINT fk_patron FOREIGN KEY (id_osoba) REFERENCES osoba(id_osoba)
);

CREATE TABLE odbornik(
  id_osoba NUMBER NOT NULL,
  expertiza VARCHAR2(64) NOT NULL,
  lekarskapraxe VARCHAR2(128) NOT NULL,
  
  CONSTRAINT fk_odbornik FOREIGN KEY (id_osoba) REFERENCES osoba(id_osoba)
);
/* end of specialisations */

CREATE TABLE alkoholik(
  id_alkoholik NUMBER NOT NULL,
  vek NUMBER NOT NULL,
  pohlavi VARCHAR2(64) NOT NULL,
  
  CONSTRAINT pk_alkoholik PRIMARY KEY (id_alkoholik)
);

CREATE TABLE schuze(
  id_schuze NUMBER NOT NULL,
  datum DATE NOT NULL,
  misto VARCHAR2(64) NOT NULL,
  zucastneny_alkoholik NUMBER NOT NULL,
  zucastneny_patron NUMBER NOT NULL,

  CONSTRAINT schuze PRIMARY KEY (id_schuze),
  CONSTRAINT fk_schuze_alkoholik FOREIGN KEY (zucastneny_alkoholik) REFERENCES alkoholik(id_alkoholik),
  CONSTRAINT fk_schuze_patron FOREIGN KEY (zucastneny_patron) REFERENCES osoba(id_osoba)
);

CREATE TABLE misto_konani(
  id_misto NUMBER NOT NULL,
  nazev VARCHAR2(64) NOT NULL,
  adresa VARCHAR2(64) NOT NULL,
  
  CONSTRAINT pk_misto_konani PRIMARY KEY (id_misto)
);

CREATE TABLE sezeni(
  id_sezeni NUMBER NOT NULL,
  datum DATE NOT NULL,
  misto NUMBER NOT NULL,
  
  CONSTRAINT pk_sezeni PRIMARY KEY (id_sezeni),
  CONSTRAINT fk_sezeni_misto FOREIGN KEY (misto) REFERENCES misto_konani(id_misto)
);

-- COMPLETE
CREATE TABLE zaznam(
  id_zaznam NUMBER NOT NULL,
  ma_alkoholik NUMBER NOT NULL,
  datum DATE NOT NULL,
  miraAlkoholu BINARY_FLOAT NOT NULL,
  puvodAlkoholu VARCHAR2(64),
  typAlkoholu VARCHAR2(64),
  provedl_odbornik NUMBER,
  
  CONSTRAINT pk_zaznam PRIMARY KEY (id_zaznam),
  CONSTRAINT fk_zaznam_odbornik FOREIGN KEY (provedl_odbornik) REFERENCES osoba(id_osoba),
  CONSTRAINT fk_zaznam_alkoholik FOREIGN KEY (ma_alkoholik) REFERENCES alkoholik(id_alkoholik)
);

CREATE TABLE je_sverencem(
  sverenec_patrona NUMBER NOT NULL,
  patron_alkoholika NUMBER NOT NULL,
  
  CONSTRAINT pk_je_sverencem PRIMARY KEY (sverenec_patrona, patron_alkoholika),
  CONSTRAINT fk_sverencem_sverenec FOREIGN KEY (sverenec_patrona) REFERENCES alkoholik(id_alkoholik),
  CONSTRAINT fk_sverencem_patron FOREIGN KEY (patron_alkoholika) REFERENCES osoba(id_osoba)
);

CREATE TABLE je_pacientem(
  pacient NUMBER NOT NULL,
  odbornik NUMBER NOT NULL,
  
  CONSTRAINT pk_je_pacientem PRIMARY KEY (pacient,odbornik),
  CONSTRAINT fk_pacientem_pacient FOREIGN KEY (pacient) REFERENCES alkoholik(id_alkoholik),
  CONSTRAINT fk_pacientem_odbornik FOREIGN KEY (odbornik) REFERENCES osoba(id_osoba)
);

CREATE TABLE byl_pritomen(
  sezeni NUMBER NOT NULL,
  osoba NUMBER NOT NULL,
  
  CONSTRAINT pk_byl_pritomen PRIMARY KEY (sezeni,osoba),
  CONSTRAINT fk_pritomen_sezeni FOREIGN KEY (sezeni) REFERENCES sezeni(id_sezeni),
  CONSTRAINT fk_pritomen_osoba FOREIGN KEY (osoba) REFERENCES osoba(id_osoba)
);

CREATE TABLE ucast(
  sezeni NUMBER NOT NULL,
  zucastneny NUMBER NOT NULL,

  CONSTRAINT pk_ucast PRIMARY KEY (sezeni, zucastneny),
  CONSTRAINT fk_ucast_sezeni FOREIGN KEY (sezeni) REFERENCES sezeni(id_sezeni),
  CONSTRAINT fk_ucast_alk FOREIGN KEY (zucastneny) REFERENCES alkoholik(id_alkoholik)
);

CREATE TABLE vedl(
	sezeni NUMBER NOT NULL,
  osoba NUMBER,
  alkoholik NUMBER,
  
  
  CONSTRAINT pk_vedl PRIMARY KEY (sezeni),
  CONSTRAINT fk_vedl_sezeni FOREIGN KEY (sezeni) REFERENCES sezeni(id_sezeni),
  CONSTRAINT fk_vedl_osoba FOREIGN KEY (osoba) REFERENCES osoba(id_osoba),
  CONSTRAINT fk_vedl_alkoholik FOREIGN KEY (alkoholik) REFERENCES alkoholik(id_alkoholik)
);

----------------------
-- CREATE SEQUENCES --
----------------------

CREATE SEQUENCE osoba_seq INCREMENT BY 1 START WITH 1 NOMAXVALUE MINVALUE 1 NOCYCLE;
CREATE SEQUENCE alkoholik_seq INCREMENT BY 1 START WITH 1 NOMAXVALUE MINVALUE 1 NOCYCLE;
CREATE SEQUENCE sezeni_seq INCREMENT BY 1 START WITH 1 NOMAXVALUE MINVALUE 1 NOCYCLE;
CREATE SEQUENCE misto_seq INCREMENT BY 1 START WITH 1 NOMAXVALUE MINVALUE 1 NOCYCLE;
CREATE SEQUENCE zaznam_seq INCREMENT BY 1 START WITH 1 NOMAXVALUE MINVALUE 1 NOCYCLE;
CREATE SEQUENCE schuze_seq INCREMENT BY 1 START WITH 1 NOMAXVALUE MINVALUE 1 NOCYCLE;

---------------------
-- CREATE TRIGGERS --
---------------------

CREATE OR REPLACE TRIGGER trigger_rc
  BEFORE INSERT OR UPDATE OF rodne_cislo ON osoba
  FOR EACH ROW
DECLARE
  rc osoba.rodne_cislo%TYPE;
  rc_str VARCHAR(64);
BEGIN
  rc := :NEW.rodne_cislo;
  IF (MOD(rc, 11) != 0) THEN
    Raise_Application_Error(-20111, 'Rodne cislo musi byt delitelne 11.');
  END IF;
  rc_str := TO_CHAR(rc);
  IF NOT (REGEXP_LIKE(rc_str, '^[0-9]{2}[0-1|5-6][0-9][0-3][0-9]{5}$')) THEN
    Raise_Application_Error(-20112, 'Neplatny format rodneho cisla.');
  END IF;
END trigger_rc;
/

CREATE OR REPLACE TRIGGER trigger_alk_id
  BEFORE INSERT ON alkoholik
  FOR EACH ROW
BEGIN
  :new.id_alkoholik := alkoholik_seq.nextval;
END trigger_alk_id;
/

-----------------------
-- CREATE PROCEDURES --
-----------------------

SET serveroutput ON;
CREATE OR REPLACE PROCEDURE neuspesnost_kontrol(idAlkoholika IN NUMBER)
IS
  CURSOR ukazatel IS SELECT * FROM zaznam;
  radek ukazatel%ROWTYPE;
  celkem NUMBER;
  neuspesne NUMBER;
BEGIN
  celkem := 0;
  neuspesne := 0;
  OPEN ukazatel;
  LOOP
    FETCH ukazatel INTO radek;
    EXIT WHEN ukazatel%NOTFOUND;
    IF (radek.ma_alkoholik = idAlkoholika) AND (radek.provedl_odbornik IS NOT NULL) THEN
      IF (radek.miraAlkoholu <> 0.0) THEN
        neuspesne := neuspesne + 1;
      END IF;
      celkem := celkem + 1;
    END IF;
  END LOOP;
  DBMS_OUTPUT.put_line('U alkoholika cislo ' || idAlkoholika || ' byl pri ' || (neuspesne * 100)/celkem || '% kotrol nameren alkohol.');
EXCEPTION
  WHEN ZERO_DIVIDE THEN
    DBMS_OUTPUT.put_line('U alkoholika cislo' || idAlkoholika || ' zatim nebyla provedena zadna kontrola.');
  WHEN OTHERS THEN
    Raise_Application_Error(-20211, 'Chyba pri provadeni procedury: neuspesnost_kontrol!');
END neuspesnost_kontrol;
/

CREATE OR REPLACE PROCEDURE aktivita_patrona(idpatron IN NUMBER)
IS
  CURSOR ukazatel IS SELECT zucastneny_patron, zucastneny_alkoholik, Count (*) AS v FROM schuze WHERE(schuze.zucastneny_patron = idpatron) GROUP BY zucastneny_patron, zucastneny_alkoholik;
  radek ukazatel%ROWTYPE;
  jmeno_patrona osoba.jmeno%TYPE;
  prijmeni_patrona osoba.prijmeni%TYPE;
  ucasti NUMBER;
BEGIN
  SELECT osoba.jmeno INTO jmeno_patrona FROM osoba WHERE idpatron = osoba.id_osoba;
  SELECT osoba.prijmeni INTO prijmeni_patrona FROM osoba WHERE idpatron = osoba.id_osoba;

  DBMS_OUTPUT.put_line('Aktivita patrona ' || jmeno_patrona || ' ' || prijmeni_patrona || ':');

  OPEN ukazatel;
  LOOP
    FETCH ukazatel INTO radek;
    EXIT WHEN ukazatel%NOTFOUND;    
    DBMS_OUTPUT.put_line('Pocet schuzek s alkoholikem c. ' || radek.zucastneny_alkoholik || ': ' || radek.v);
  END LOOP;

  SELECT Count (*) AS "pocet" INTO ucasti FROM byl_pritomen WHERE byl_pritomen.osoba = idpatron GROUP BY byl_pritomen.osoba;

  DBMS_OUTPUT.put_line('Pocet ucasti na sezenich: ' || ucasti);
EXCEPTION
  WHEN OTHERS THEN
    Raise_Application_Error(-20221, 'Chyba pri provadeni procedury: aktivita_patrona!');
END aktivita_patrona;
/

------------------------------
-- CREATE MATERIALIZED VIEW --
------------------------------

CREATE MATERIALIZED VIEW LOG ON odbornik WITH ROWID(expertiza) INCLUDING NEW VALUES;
CREATE MATERIALIZED VIEW LOG ON patron WITH ROWID INCLUDING NEW VALUES;

CREATE MATERIALIZED VIEW odbornik_role CACHE REFRESH FAST ON COMMIT ENABLE QUERY REWRITE
  AS SELECT odbornik.expertiza, COUNT(odbornik.expertiza) AS "Zastoupeni experizy"
  FROM odbornik
  GROUP BY odbornik.expertiza;

CREATE MATERIALIZED VIEW patron_pocet CACHE REFRESH FAST ON COMMIT ENABLE QUERY REWRITE
  AS SELECT COUNT (*) AS "Pocet patronu"
  FROM patron;

-------------------------
-- CREATE EXPLAIN PLAN --
-------------------------

CREATE INDEX alk_p ON alkoholik(pohlavi);

EXPLAIN PLAN FOR
SELECT pohlavi, MAX(miraAlkoholu)
FROM alkoholik NATURAL JOIN zaznam
GROUP BY miraAlkoholu, pohlavi;
SELECT * FROM TABLE(DBMS_XPLAN.display);

-------------------------
-- GRANT ACCESS RIGHTS --
-------------------------

GRANT ALL ON zaznam TO xjemel01;
GRANT ALL ON alkoholik TO xjemel01;
GRANT ALL ON je_pacientem TO xjemel01;
GRANT ALL ON sezeni TO xjemel01;
GRANT ALL ON vedl TO xjemel01;
GRANT ALL ON ucast TO xjemel01;
GRANT ALL ON byl_pritomen TO xjemel01;

GRANT ALL ON odbornik_role TO xjemel01;
GRANT ALL ON patron_pocet TO xjemel01;

GRANT EXECUTE ON neuspesnost_kontrol TO xjemel01;
GRANT EXECUTE ON aktivita_patrona TO xjemel01;

------------------------
-- INSERT INTO TABLES --
------------------------

INSERT INTO osoba VALUES(osoba_seq.nextval, 'Tomas', 'Marny', 6803127584);
INSERT INTO osoba VALUES(osoba_seq.nextval, 'Daniel', 'Vyskocil', 7106057299);
INSERT INTO osoba VALUES(osoba_seq.nextval, 'Karel', 'Nejezchleba', 8511240375);
INSERT INTO osoba VALUES(osoba_seq.nextval, 'Jiri', 'Vesely', 9107153308);
INSERT INTO osoba VALUES(osoba_seq.nextval, 'Milan', 'Enzym', 5601018346);
INSERT INTO osoba VALUES(osoba_seq.nextval, 'Jarda', 'Noha', 7510211533);
INSERT INTO osoba VALUES(osoba_seq.nextval, 'Jirina', 'Hrachova', 6652053485);

INSERT INTO patron VALUES(2);
INSERT INTO patron VALUES(3);
INSERT INTO patron VALUES(6);

INSERT INTO odbornik VALUES(1, 'Prevencni expertiza', '5 let ve spolku UZ PIJU JEN VODU');
INSERT INTO odbornik VALUES(4, 'Prevencni expertiza', '7 let ve spolku NEMAME RADI RUM');
INSERT INTO odbornik VALUES(5, 'Metabolisticky expert', '12 let v CISTIRNA ODPOADNICH VOD PRAHA');
INSERT INTO odbornik VALUES(7, 'Vyzivovy poradce', '2 roky v EKOFLEKO');

INSERT INTO alkoholik VALUES(NULL, 38, 'muž');
INSERT INTO alkoholik VALUES(NULL, 41, 'muž');
INSERT INTO alkoholik VALUES(NULL, 36, 'žena');
INSERT INTO alkoholik VALUES(NULL, 28, 'žena');
INSERT INTO alkoholik VALUES(NULL, 18, 'muž');
INSERT INTO alkoholik VALUES(NULL, 68, 'muž');
INSERT INTO alkoholik VALUES(NULL, 78, 'žena');
INSERT INTO alkoholik VALUES(NULL, 88, 'žena');
INSERT INTO alkoholik VALUES(NULL, 33, 'muž');

INSERT INTO schuze VALUES(schuze_seq.nextval, '1.1.2011', 'Kavarni Podnebi', 1, 3);
INSERT INTO schuze VALUES(schuze_seq.nextval, '2.1.2011', 'Frykaso', 3, 2);
INSERT INTO schuze VALUES(schuze_seq.nextval, '3.1.2011', 'Vesela vacice', 7, 2);
INSERT INTO schuze VALUES(schuze_seq.nextval, '4.1.2011', 'Tivoli', 1, 3);

INSERT INTO misto_konani VALUES(misto_seq.nextval, 'Budova 21', 'Brno Vlhka 68');
INSERT INTO misto_konani VALUES(misto_seq.nextval, 'Pavilon C', 'Brno Veveri 312');
INSERT INTO misto_konani VALUES(misto_seq.nextval, 'Impact Hub', 'Brno Lesna 12');

INSERT INTO sezeni VALUES(sezeni_seq.nextval, '10.3.2012', 2);
INSERT INTO sezeni VALUES(sezeni_seq.nextval, '25.6.2012', 3);
INSERT INTO sezeni VALUES(sezeni_seq.nextval, '30.9.2012', 3);
INSERT INTO sezeni VALUES(sezeni_seq.nextval, '20.12.2012', 3);
INSERT INTO sezeni VALUES(sezeni_seq.nextval, '1.3.2013', 1);

INSERT INTO zaznam VALUES(zaznam_seq.nextval, 4, '1.3.2013', 0.5, 'hospoda', 'pivo', 1);
INSERT INTO zaznam VALUES(zaznam_seq.nextval, 1, '5.3.2013', 3.5, 'sámoška', 'rum', 4);
INSERT INTO zaznam VALUES(zaznam_seq.nextval, 1, '30.3.2013', 0.0, '', '', 1);
INSERT INTO zaznam VALUES(zaznam_seq.nextval, 5, '1.3.2013', 1.0, 'hospoda', 'pivo', 1);

INSERT INTO je_pacientem VALUES (1,1);
INSERT INTO je_pacientem VALUES (2,4);
INSERT INTO je_pacientem VALUES (3,5);
INSERT INTO je_pacientem VALUES (4,4);
INSERT INTO je_pacientem VALUES (5,4);
INSERT INTO je_pacientem VALUES (6,4);
INSERT INTO je_pacientem VALUES (7,4);
INSERT INTO je_pacientem VALUES (8,1);
INSERT INTO je_pacientem VALUES (9,1);

INSERT INTO je_sverencem VALUES (1,2);
INSERT INTO je_sverencem VALUES (3,3);
INSERT INTO je_sverencem VALUES (4,2);
INSERT INTO je_sverencem VALUES (7,2);

INSERT INTO byl_pritomen VALUES (1,1);
INSERT INTO byl_pritomen VALUES (1,2);
INSERT INTO byl_pritomen VALUES (1,3);
INSERT INTO byl_pritomen VALUES (2,2);
INSERT INTO byl_pritomen VALUES (2,3);
INSERT INTO byl_pritomen VALUES (3,1);
INSERT INTO byl_pritomen VALUES (3,4);
INSERT INTO byl_pritomen VALUES (4,4);
INSERT INTO byl_pritomen VALUES (5,2);
INSERT INTO byl_pritomen VALUES (5,3);

INSERT INTO ucast VALUES (1,5);
INSERT INTO ucast VALUES (1,3);
INSERT INTO ucast VALUES (1,2);
INSERT INTO ucast VALUES (1,7);
INSERT INTO ucast VALUES (2,1);
INSERT INTO ucast VALUES (2,2);
INSERT INTO ucast VALUES (2,3);
INSERT INTO ucast VALUES (2,4);
INSERT INTO ucast VALUES (2,5);
INSERT INTO ucast VALUES (2,6);
INSERT INTO ucast VALUES (2,7);
INSERT INTO ucast VALUES (2,8);
INSERT INTO ucast VALUES (3,4);
INSERT INTO ucast VALUES (3,6);
INSERT INTO ucast VALUES (4,1);
INSERT INTO ucast VALUES (4,2);
INSERT INTO ucast VALUES (4,3);
INSERT INTO ucast VALUES (4,4);
INSERT INTO ucast VALUES (5,5);
INSERT INTO ucast VALUES (5,7);
INSERT INTO ucast VALUES (5,8);

INSERT INTO vedl (sezeni, osoba) VALUES (1,1);
INSERT INTO vedl (sezeni, osoba) VALUES (2,3);
INSERT INTO vedl (sezeni, alkoholik) VALUES (3,5);
INSERT INTO vedl (sezeni, alkoholik) VALUES (4,8);
INSERT INTO vedl (sezeni, osoba) VALUES (5,1);

-- SELECTY
-- vypise alkoholika(id) a jeho patrona(jmeno a prijmeni)
SELECT je_sverencem.SVERENEC_PATRONA, osoba.JMENO, osoba.PRIJMENI
FROM osoba, je_sverencem
WHERE (osoba.ID_osoba = je_sverencem.PATRON_ALKOHOLIKA);

-- vypise vsechny zaznamy(id), ktere provedl odbornik(jmno a prijmeni)
SELECT zaznam.ID_ZAZNAM, osoba.JMENO, osoba.PRIJMENI
FROM osoba, zaznam
WHERE (osoba.ID_osoba = zaznam.PROVEDL_ODBORNIK);

-- vypise jmeno odbornika a datum sezeni vsech sezeni, ktera vedl
SELECT osoba.JMENO, osoba.PRIJMENI, sezeni.DATUM
FROM osoba, (odbornik INNER JOIN vedl ON (odbornik.ID_osoba = vedl.osoba) INNER JOIN sezeni ON (sezeni.ID_SEZENI = vedl.SEZENI))
WHERE (osoba.ID_osoba = odbornik.ID_osoba);

-- vypise pocet ucasti jednotlivych alkoholiku na sezenich
SELECT alkoholik.ID_ALKOHOLIK, COUNT (*) AS "POCET UCASTI"
FROM alkoholik INNER JOIN ucast ON (alkoholik.ID_ALKOHOLIK = ucast.ZUCASTNENY)
GROUP BY alkoholik.ID_ALKOHOLIK
ORDER BY alkoholik.ID_ALKOHOLIK;

-- vypise pocet sezeni podle jednotlivych mist konani
SELECT misto_konani.ID_MISTO, misto_konani.NAZEV, Count (*) AS "POCET SEZENI"
FROM misto_konani INNER JOIN sezeni ON (misto_konani.ID_MISTO = sezeni.MISTO)
GROUP BY misto_konani.ID_MISTO, misto_konani.NAZEV
ORDER BY misto_konani.ID_MISTO;

-- vypise vsechny odborniky (id, jmeno, prijmeni), kteri maji za pacienta alespon jednoho muze
SELECT osoba.ID_osoba, osoba.JMENO, osoba.PRIJMENI FROM osoba, odbornik
WHERE osoba.ID_osoba = odbornik.ID_osoba AND EXISTS (
  SELECT alkoholik.ID_ALKOHOLIK FROM alkoholik, je_pacientem
  WHERE alkoholik.POHLAVI = 'muž'
  AND je_pacientem.PACIENT = alkoholik.ID_ALKOHOLIK
  AND je_pacientem.ODBORNIK = odbornik.ID_osoba
);

-- vybere vsechny alkoholiky, kteri byly na schuzi a nemaji zaznam alkoholu, ci jejich zaznam je nulovy
SELECT alkoholik.ID_ALKOHOLIK
FROM alkoholik INNER JOIN ucast ON (alkoholik.ID_ALKOHOLIK = ucast.ZUCASTNENY)
WHERE (alkoholik.ID_ALKOHOLIK NOT IN (SELECT zaznam.MA_ALKOHOLIK FROM zaznam))
OR (alkoholik.ID_ALKOHOLIK IN (SELECT zaznam.MA_ALKOHOLIK FROM zaznam WHERE (zaznam.MIRAALKOHOLU = 0.0)))
GROUP BY alkoholik.ID_ALKOHOLIK
ORDER BY alkoholik.ID_ALKOHOLIK;

EXEC neuspesnost_kontrol(1);
EXEC aktivita_patrona(3);

COMMIT;

SELECT * FROM odbornik_role;
SELECT * FROM patron_pocet;