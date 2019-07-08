-- phpMyAdmin SQL Dump
-- version 4.4.12
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1
-- Generation Time: 08 Jul 2019 pada 16.14
-- Versi Server: 5.6.25
-- PHP Version: 5.6.11

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `uas_administrasi_basis_data`
--

DELIMITER $$
--
-- Prosedur
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `isi_data`(IN `lokasi` VARCHAR(20), IN `barang` VARCHAR(20))
BEGIN
	DECLARE brgnya INT;
    DECLARE loknya INT;
	SELECT kode INTO brgnya FROM referensi WHERE tag = 'Barang' AND nama = barang;
    SELECT kode INTO loknya FROM referensi WHERE tag = 'Lokasi' AND nama = lokasi;
    INSERT INTO data SET lokasi = loknya, barang = brgnya;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `data`
--

CREATE TABLE IF NOT EXISTS `data` (
  `id` int(20) NOT NULL,
  `barang` int(20) NOT NULL,
  `lokasi` int(20) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=latin1;

--
-- Dumping data untuk tabel `data`
--

INSERT INTO `data` (`id`, `barang`, `lokasi`) VALUES
(1, 2, 1),
(2, 1, 3),
(3, 2, 5),
(4, 2, 5),
(5, 3, 4),
(6, 3, 1),
(7, 4, 3),
(8, 4, 4),
(9, 3, 2),
(10, 5, 1),
(11, 1, 5),
(12, 2, 4),
(13, 3, 3),
(14, 4, 3),
(17, 4, 3);

--
-- Trigger `data`
--
DELIMITER $$
CREATE TRIGGER `add_data` AFTER INSERT ON `data`
 FOR EACH ROW BEGIN
	INSERT INTO data_audit (id_data, barang_after,lokasi_after, waktu, status)
    VALUES (NEW.id, NEW.barang, NEW.lokasi, NOW(), 'ADD');
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `delete_data` BEFORE DELETE ON `data`
 FOR EACH ROW BEGIN
	INSERT INTO data_audit
    (id_data, barang_before, lokasi_before, waktu, status)
    VALUES
    (OLD.id, OLD.barang, OLD.lokasi, NOW(), 'DELETE');
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `udate_data_after` AFTER UPDATE ON `data`
 FOR EACH ROW BEGIN
	DECLARE up INT;
    SELECT id INTO up FROM data_audit ORDER BY id DESC LIMIT 1;
    
    UPDATE data_audit SET 
    barang_after = NEW.barang,
    lokasi_after = NEW.lokasi
    WHERE id = up;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_data_before` BEFORE UPDATE ON `data`
 FOR EACH ROW BEGIN
	INSERT INTO data_audit
    (id_data, barang_before, lokasi_before, waktu, status)
    VALUES
    (OLD.id, OLD.barang, OLD.lokasi, NOW(), 'UPDATE');
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `data_audit`
--

CREATE TABLE IF NOT EXISTS `data_audit` (
  `id` int(20) NOT NULL,
  `id_data` int(20) DEFAULT NULL,
  `barang_before` int(20) DEFAULT NULL,
  `barang_after` int(20) DEFAULT NULL,
  `lokasi_before` int(20) DEFAULT NULL,
  `lokasi_after` int(20) DEFAULT NULL,
  `waktu` date DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1;

--
-- Dumping data untuk tabel `data_audit`
--

INSERT INTO `data_audit` (`id`, `id_data`, `barang_before`, `barang_after`, `lokasi_before`, `lokasi_after`, `waktu`, `status`) VALUES
(1, 16, NULL, 2, NULL, 5, '2019-07-08', 'ADD'),
(2, 16, 2, NULL, 5, NULL, '2019-07-08', 'DELETE'),
(4, 4, 2, 2, 2, 5, '2019-07-08', 'UPDATE'),
(5, 1, 1, 2, 1, 1, '2019-07-08', 'UPDATE'),
(6, 17, NULL, 4, NULL, 3, '2019-07-08', 'ADD'),
(7, 18, NULL, 4, NULL, 3, '2019-07-08', 'ADD'),
(8, 9, 5, 3, 2, 2, '2019-07-08', 'UPDATE'),
(9, 18, 4, NULL, 3, NULL, '2019-07-08', 'DELETE');

-- --------------------------------------------------------

--
-- Struktur dari tabel `referensi`
--

CREATE TABLE IF NOT EXISTS `referensi` (
  `tag` varchar(20) NOT NULL,
  `kode` int(20) NOT NULL,
  `nama` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data untuk tabel `referensi`
--

INSERT INTO `referensi` (`tag`, `kode`, `nama`) VALUES
('Barang', 1, 'Meja'),
('Lokasi', 1, 'Ruang Tamu'),
('Barang', 2, 'Kursi'),
('Lokasi', 2, 'Kamar Tidur'),
('Barang', 3, 'Lemari'),
('Lokasi', 3, 'Garasi'),
('Barang', 4, 'Rak Buku'),
('Lokasi', 4, 'Dapur'),
('Barang', 5, 'Sofa'),
('Lokasi', 5, 'Kamar Mandi');

-- --------------------------------------------------------

--
-- Stand-in structure for view `tampil_data`
--
CREATE TABLE IF NOT EXISTS `tampil_data` (
`id` int(20)
,`barang` varchar(20)
,`lokasi` varchar(20)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_audit`
--
CREATE TABLE IF NOT EXISTS `view_audit` (
`status` varchar(20)
,`COUNT(status)` bigint(21)
);

-- --------------------------------------------------------

--
-- Struktur untuk view `tampil_data`
--
DROP TABLE IF EXISTS `tampil_data`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `tampil_data` AS select `data`.`id` AS `id`,`brg`.`nama` AS `barang`,`lok`.`nama` AS `lokasi` from ((`data` join `referensi` `brg` on((`data`.`barang` = `brg`.`kode`))) join `referensi` `lok` on((`data`.`lokasi` = `lok`.`kode`))) where ((`lok`.`tag` = 'Lokasi') and (`brg`.`tag` = 'Barang'));

-- --------------------------------------------------------

--
-- Struktur untuk view `view_audit`
--
DROP TABLE IF EXISTS `view_audit`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_audit` AS select `data_audit`.`status` AS `status`,count(`data_audit`.`status`) AS `COUNT(status)` from `data_audit` group by `data_audit`.`status`;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `data`
--
ALTER TABLE `data`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `data_audit`
--
ALTER TABLE `data_audit`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `data`
--
ALTER TABLE `data`
  MODIFY `id` int(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=19;
--
-- AUTO_INCREMENT for table `data_audit`
--
ALTER TABLE `data_audit`
  MODIFY `id` int(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=10;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
