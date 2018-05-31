/* ALMAS AQMARINA*/
/* TRIGGER PROFILE*/
CREATE TABLE users_new LIKE users;
ALTER TABLE users_new ADD
(
`tgl_perubahan` DATETIME,
`status` VARCHAR(200)
);

-- Insert new data
DELIMITER$$
CREATE TRIGGER insert_users
AFTER INSERT ON users
FOR EACH ROW
BEGIN
  INSERT INTO `users_new` VALUES (new.`user_id`, new.`user_nama`, new.`email`, new.`password`, new.`alamat`, new.`jenis_kel`, new.`tgl_lahir`, new.`rating`, new.`token`, new.`aboutme`, new.`no_telp`, SYSDATE(), 'INSERT');
END$$
DELIMITER;

-- update data
DELIMITER$$
CREATE TRIGGER update_users
AFTER UPDATE ON users
FOR EACH ROW
BEGIN
  INSERT INTO `users_new` VALUES (old.`user_id`, new.`user_nama`, old.`email`, old.`password`, new.`alamat`, old.`jenis_kel`, old.`tgl_lahir`, old.`rating`, old.`token`, new.`aboutme`, new.`no_telp`, old.`remember_token`, old.`created_at`, old,`updated_at`, SYSDATE(), 'UPDATE');
END$$
DELIMITER ;

-- delete data
DELIMITER$$
CREATE TRIGGER delete_users
AFTER DELETE ON users
FOR EACH ROW
BEGIN
  INSERT INTO `users_new` VALUES (old.`user_id`, old.`user_nama`, old.`email`, old.`password`, old.`alamat`, old.`jenis_kel`, old.`tgl_lahir`, old.`rating`, old.`token`, old.`aboutme`, old.`no_telp`, SYSDATE(), 'DELETE');
END$$
DELIMITER ;

/*FUNCTION KATEGORI DI PROFILE*/

DELIMITER $$
CREATE FUNCTION jumlah_itemMakanan(idUser CHAR(50))
    RETURNS INT
    DETERMINISTIC
    BEGIN
    DECLARE jumlahItem INT;
    SELECT COUNT(onrs.onr_id) INTO jumlahItem
    FROM onrs INNER JOIN users ON users.`user_id`=onrs.`pelaku_id`
    WHERE onrs.kategori = '1'
    AND users.user_id = idUser;
    RETURN jumlahItem;
    END$$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION jumlah_itemTaksesoris(idUser CHAR(50))
    RETURNS INT
    DETERMINISTIC
    BEGIN
    DECLARE jumlahItem INT;
    SELECT COUNT(onrs.onr_id) INTO jumlahItem
    FROM onrs INNER JOIN users ON users.`user_id`=onrs.`pelaku_id`
    WHERE onrs.kategori = '2'
    AND users.user_id = idUser;
    RETURN jumlahItem;
    END$$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION jumlah_itemIbuanak(idUser CHAR(50))
    RETURNS INT
    DETERMINISTIC
    BEGIN
    DECLARE jumlahItem INT;
    SELECT COUNT(onrs.onr_id) INTO jumlahItem
    FROM onrs INNER JOIN users ON users.`user_id`=onrs.`pelaku_id`
    WHERE onrs.kategori = '3'
    AND users.user_id = idUser;
    RETURN jumlahItem;
    END$$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION jumlah_itemGames(idUser CHAR(50))
    RETURNS INT
    DETERMINISTIC
    BEGIN
    DECLARE jumlahItem INT;
    SELECT COUNT(onrs.onr_id) INTO jumlahItem
    FROM onrs INNER JOIN users ON users.`user_id`=onrs.`pelaku_id`
    WHERE onrs.kategori = '4'
    AND users.user_id = idUser;
    RETURN jumlahItem;
    END$$
DELIMITER ;

/*PROCEDURE KATEGORI DI PAGE KATEGORI*/

DELIMITER $$
CREATE PROCEDURE tambah(idKategori CHAR, jml INT)
BEGIN
  UPDATE kategoris k SET k.jumlah_item = k.jumlah_item + jml WHERE k.kategori_id = idKategori;
END $$
DELIMITER ;

CALL tambah('1', '200');

DELIMITER $$
CREATE PROCEDURE kurang(idKategori CHAR, jml INT)
BEGIN
  UPDATE kategoris k SET k.jumlah_item = k.jumlah_item - jml WHERE k.kategori_id = idKategori;
END $$
DELIMITER ;

CALL kurang('1', '150');

/*INDEX ONRS NAMA BARANG*/
SELECT * FROM onrs
WHERE nama_barang LIKE '%a%';

CREATE INDEX idx_kata
ON onrs(nama_barang);

/*VIEW ONRS HARGA TERTENTU*/
CREATE VIEW harga_item AS
SELECT *
FROM onrs
WHERE harga='123123';

/*JOIN USER YANG MELAKUKAN OFFER PADA KATEGORI TERTENTU*/
SELECT u.`user_nama`
FROM users u
JOIN onrs o ON u.user_id=o.pelaku_id
LEFT JOIN kategoris k ON k.kategori_id=o.kategori
WHERE o.onr='OFFER'
AND k.nama = 'Ibu dan Anak';

/*CURSOR DISKON 25.000 > 350.000*/
DELIMITER $$
CREATE PROCEDURE excursor5()
BEGIN
   DECLARE idnya    CHAR(10);
   DECLARE harganya INT(3);
   DECLARE flag     BOOL DEFAULT TRUE;
   DECLARE diskonbarang CURSOR
  FOR   SELECT transaksi_id, total_harga
    FROM transaksis;
   DECLARE CONTINUE HANDLER
  FOR   NOT FOUND
    SET flag=FALSE;
   
   OPEN diskonbarang;
   
   satu: LOOP
      FETCH diskonbarang INTO idnya, harganya;
  IF flag=FALSE THEN LEAVE satu;
  END IF;
  
  IF harganya > 350000 THEN
    UPDATE transaksis SET total_harga=total_harga-25000 WHERE transaksi_id=idnya;
  END IF;
   END LOOP;
   CLOSE diskonbarang;
END$$
DELIMITER ;

INSERT INTO transaksis VALUES('1','7','2026ce80-6312-11e8-80a4-a1cd0bdef95d','400000','4.5');
CALL excursor5 ();