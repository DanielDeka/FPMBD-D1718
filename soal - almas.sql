/* ALMAS AQMARINA*/

/* TRIGGER */
CREATE TABLE transaksi_order LIKE transaksi;
ALTER TABLE transaksi_order ADD
(
`tgl_perubahan` DATETIME,
`status` VARCHAR(200)
);

-- Insert new data
DELIMITER$$
CREATE TRIGGER tambah_transaksi
AFTER INSERT ON transaksi
FOR EACH ROW
BEGIN
  INSERT INTO transaksi_order VALUES (new.transaksi_id, new.onr_id, new.pelaku_id, new.user_id, new.jumlah_barang, new.total_harga, new.rate, SYSDATE(), 'INSERT');
END$$
DELIMITER;

INSERT INTO `transaksi` VALUES('9ef290e13c1848d8855ed55d62e6ac10','87e94021be0a474da21a93f93c303924','45b1d452950c40048c75c40fefe04f9e','a967b5e523604ce4898720edbd004928','1','100000','4.2');

-- update data
DELIMITER$$
CREATE TRIGGER update_jumlah_barang
AFTER UPDATE ON transaksi
FOR EACH ROW
BEGIN
  INSERT INTO transaksi_order VALUES (old.transaksi_id, old.onr_id, old.pelaku_id, old.user_id, new.jumlah_barang, old.total_harga, old.rate, SYSDATE(), 'UPDATE');
END$$
DELIMITER ;

UPDATE transaksi
SET jumlah_barang=3
WHERE onr_id='293c7a0465794f3d897bd66f387b8b28';

-- delete data
DELIMITER$$
CREATE TRIGGER delete_jumlah_barang
AFTER DELETE ON transaksi
FOR EACH ROW
BEGIN
  INSERT INTO transaksi_order VALUES (old.transaksi_id, old.onr_id, old.pelaku_id, old.user_id, old.jumlah_barang, old.total_harga, old.rate, SYSDATE(), 'DELETE');
END$$
DELIMITER ;

DELETE FROM transaksi
WHERE transaksi_id='e91fdbe920ec4be4a3700934b574e5e2';

/*FUNCTION
DELIMITER $$
CREATE FUNCTION tampil_mahasiswa(tahun INT)
    RETURNS INT
    DETERMINISTIC
    BEGIN
    DECLARE jml INT;
    SELECT COUNT(*) AS jml_mhs INTO jml
    FROM mahasiswa
    WHERE EXTRACT(YEAR FROM tgl_lhr)=tahun;
    RETURN jml;
    END$$
DELIMITER ;*/

/*PROCEDURE*/
DELIMITER $$
CREATE PROCEDURE tambah(idKategori CHAR)
BEGIN
  UPDATE SET kategoris k
  WHERE idKategori = k.kategoris_id
END $$
DELIMITER ;

CALL tambah('1');

/*INDEX*/
SELECT * FROM onrs
WHERE nama_barang LIKE '%deka%';

CREATE INDEX idx_kata
ON onrs(nama_barang);

/*VIEW*/
CREATE VIEW harga_item AS
FROM onrs
WHERE harga_item='123123';

/*JOIN*/
SELECT u.`user_nama`
FROM users u
JOIN onrs o ON u.user_id=o.pelaku_id
LEFT JOIN kategoris k ON k.kategori_id=o.kategori
WHERE k.nama = 'Ibu dan Anak';

/*CURSOR*/
DELIMITER $$
CREATE PROCEDURE excursor5()
BEGIN
   DECLARE idnya    CHAR(10);
   DECLARE harganya INT(3);
   DECLARE flag     BOOL DEFAULT TRUE;
   DECLARE diskonbarang CURSOR
  FOR   SELECT id_transaksi, total_harga
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
    UPDATE transaksis SET total_harga=total_harga-25000 WHERE id_transaksi=idnya;
  END IF;
   END LOOP;
   CLOSE diskonbarang;
END $$
DELIMITER;

CALL excursor5 ();