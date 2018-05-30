/* DANIEL KURNIAWAN */
/* TRIGGER */

CREATE TABLE log_onr LIKE onr;
ALTER TABLE log_onr ADD
(
`tgl_perubahan` DATETIME,
`status` VARCHAR(200)
);

-- Insert new data
DELIMITER$$
CREATE TRIGGER insert_onr
AFTER INSERT ON onr
FOR EACH ROW
BEGIN
  INSERT INTO log_onr VALUES (new.onr_id, new.pelaku_id, new.nama_barang, new.kategori, new.deskripsi, new.harga, new.jumlah, new.waktu, new.kota_barang, new.kota_onr, new.onr, SYSDATE(), 'INSERT');
END$$
DELIMITER ;

INSERT INTO `onr` VALUES('b2b646d813884ee6a5985475448660e0','423d35da44b547f0b74e039007df3724','Cakekinian','kategori001','Cakekinian dengan varian rasa oreo, dan beng-beng.','80000','5','2018-05-31','Bekasi','Surabaya','OFFER');

-- update data
DELIMITER$$
CREATE TRIGGER update_harga
AFTER UPDATE ON onr
FOR EACH ROW
BEGIN
  INSERT INTO log_onr VALUES (old.onr_id, old.pelaku_id, old.nama_barang, old.kategori, old.deskripsi, new.harga, old.jumlah, old.waktu, old.kota_barang, old.kota_onr, old.onr, SYSDATE(), 'UPDATE');
END$$
DELIMITER ;

UPDATE onr
SET harga=4
WHERE onr_id='6e078756f71643839b32aed67b8176c6';

-- delete data
DELIMITER$$
CREATE TRIGGER delete_onr
AFTER DELETE ON onr
FOR EACH ROW
BEGIN
  INSERT INTO log_onr VALUES (old.onr_id, old.pelaku_id, old.nama_barang, old.kategori, old.deskripsi, old.harga, old.jumlah, old.waktu, old.kota_barang, old.kota_onr, old.onr, SYSDATE(), 'DELETE');
END$$
DELIMITER ;

DELETE FROM onr
WHERE onr_id='b2b646d813884ee6a5985475448660e0';

/* FUNCTION */
DELIMITER $$
CREATE FUNCTION jumlah_itemUser(idUser CHAR(50))
    RETURNS INT
    DETERMINISTIC
    BEGIN
    DECLARE jumlahItem INT;
    SELECT COUNT(onrs.onr_id) AS Jumlah_ItemOffer INTO jumlahItem
    FROM onrs INNER JOIN users ON users.`user_id`=onrs.`pelaku_id`
    WHERE onrs.onr = 'OFFER'
    AND users.user_id = idUser;
    RETURN jumlahItem;
    END$$
DELIMITER ;

SELECT DISTINCT jumlah_itemUser('a967b5e523604ce4898720edbd004928') AS 'Jumlah item offer' FROM users u, onrs, transaksi t, kategori k;

/* PROCEDURE */
DELIMITER $$
CREATE PROCEDURE sesuaikan(paketkursus VARCHAR(100), diskon INT)
BEGIN
UPDATE pengajar p, paket_kursus pk SET pk.pk_tarif = pk.pk_tarif-diskon WHERE pk.pk_nama = paketkursus;
UPDATE pengajar p, paket_kursus pk SET p.p_gaji = p.p_gaji-diskon WHERE p.id_pengajar = pk.id_pengajar AND pk.pk_nama = paketkursus;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE updateRating(idUser CHAR(50))
BEGIN
UPDATE users u, transaksi t SET u.rating = ((u.rating + t.rate) / 2) WHERE u.user_id = idUser;
END $$
DELIMITER ;


CALL sesuaikan('Class Basic','100000');

/*INDEX*/
SELECT * FROM onrs
WHERE onr LIKE 'OFFER';

CREATE INDEX idx_onr
ON onrs(onr);

/*VIEW*/
CREATE VIEW item_category AS
SELECT nama_barang
FROM onrs
WHERE kategori = 'Ibu dan Anak';

/*JOIN*/
SELECT o.nama_barang
FROM onrs o
JOIN users u ON o.pelaku_id = u.user_id
JOIN transaksi t ON (u.user_id=o.kategori AND u.onr_id=t.onr_id)
WHERE k.nama = 'Ibu dan Anak';

/*CURSOR*/
DELIMITER $$
CREATE PROCEDURE order()
BEGIN
    SELECT DISTINCT *
    FROM  transaksi
        LEFT JOIN pemesan ON transaksi.id_pemesan = pemesan.id_pemesan
        LEFT JOIN memutar ON transaksi.id_memutar = memutar.id_memutar
        LEFT JOIN film    ON memutar.id_film = film.id_film
    WHERE  film.nama_film = "London Love Story";
END$$
DELIMITER ;