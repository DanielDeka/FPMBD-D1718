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
CREATE FUNCTION jumlah_itemUser(idUser CHAR(32))
    RETURNS INT
    DETERMINISTIC
    BEGIN
    DECLARE jumlahItem INT;
    SELECT COUNT(onr.onr_id) AS Jumlah_ItemOffer INTO jumlahItem
    FROM onrs INNER JOIN users ON users.`user_id`=onrs.`pelaku_id`
    WHERE onrs.onr = 'OFFER'
    AND users.user_id = idUser;
    RETURN jumlahItem;
    END$$
DELIMITER ;

SELECT DISTINCT jumlah_itemUser('a967b5e523604ce4898720edbd004928') AS 'Jumlah item offer' FROM users u, onrs, transaksi t, kategori k;