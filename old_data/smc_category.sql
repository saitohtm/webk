-- phpMyAdmin SQL Dump
-- version 2.8.2.4
-- http://www.phpmyadmin.net
-- 
-- ホスト: localhost:3306
-- 作成の時間: 2013 年 1 月 13 日 01:46
-- サーバーのバージョン: 5.0.77
-- PHP バージョン: 5.2.6
-- 
-- データベース: `waao`
-- 

-- --------------------------------------------------------

-- 
-- テーブルの構造 `smc_category`
-- 

CREATE TABLE `smc_category` (
  `id` int(11) NOT NULL auto_increment,
  `code` varchar(64) NOT NULL,
  `name` varchar(64) NOT NULL,
  `link_category` varchar(255) NOT NULL,
  `link_mobile` varchar(255) NOT NULL,
  `area_code` varchar(64) NOT NULL,
  `area_name` varchar(64) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `area_code` (`area_code`)
) ENGINE=MyISAM AUTO_INCREMENT=25 DEFAULT CHARSET=cp932 AUTO_INCREMENT=25 ;

-- 
-- テーブルのダンプデータ `smc_category`
-- 

INSERT INTO `smc_category` (`id`, `code`, `name`, `link_category`, `link_mobile`, `area_code`, `area_name`) VALUES (1, '011', '名古屋市内', 'http://www.smatch.jp/theme/011/', 'http://m.smatch.jp/CSM/CSM20/CSM200000.jsp?AR=050&CA=011&guid=ON', '050', '東海'),
(2, '012', '東海・名古屋市外', 'http://www.smatch.jp/theme/012/', 'http://m.smatch.jp/CSM/CSM20/CSM200000.jsp?AR=050&CA=012&guid=ON', '050', '東海'),
(3, '007', '大阪', 'http://www.smatch.jp/theme/007/', 'http://m.smatch.jp/CSM/CSM20/CSM200000.jsp?AR=060&CA=007&guid=ON', '060', '関西'),
(4, '010', '奈良・和歌山', 'http://www.smatch.jp/theme/010/', 'http://m.smatch.jp/CSM/CSM20/CSM200000.jsp?AR=060&CA=010&guid=ON', '060', '関西'),
(5, '008', '兵庫', 'http://www.smatch.jp/theme/008/', 'http://m.smatch.jp/CSM/CSM20/CSM200000.jsp?AR=060&CA=008&guid=ON', '060', '関西'),
(6, '009', '京都・滋賀', 'http://www.smatch.jp/theme/009/', 'http://m.smatch.jp/CSM/CSM20/CSM200000.jsp?AR=060&CA=009&guid=ON', '060', '関西'),
(7, '020', 'リフォーム・リノベーション・DIY', 'http://www.smatch.jp/theme/020/', 'http://m.smatch.jp/CSM/CSM20/CSM200000.jsp?AR=000&CA=020&guid=ON', '000', '相談'),
(8, '022', '賃貸マンション', 'http://www.smatch.jp/theme/022/', 'http://m.smatch.jp/CSM/CSM20/CSM200000.jsp?AR=000&CA=022&guid=ON', '000', '相談'),
(9, '021', '一戸建て・注文住宅', 'http://www.smatch.jp/theme/021/', 'http://m.smatch.jp/CSM/CSM20/CSM200000.jsp?AR=000&CA=021&guid=ON', '000', '相談'),
(10, '024', '雑談', 'http://www.smatch.jp/theme/024/', 'http://m.smatch.jp/CSM/CSM20/CSM200000.jsp?AR=000&CA=024&guid=ON', '000', '相談'),
(11, '017', '住宅ローン・保険・税金', 'http://www.smatch.jp/theme/017/', 'http://m.smatch.jp/CSM/CSM20/CSM200000.jsp?AR=000&CA=017&guid=ON', '000', '相談'),
(12, '019', '中古マンション', 'http://www.smatch.jp/theme/019/', 'http://m.smatch.jp/CSM/CSM20/CSM200000.jsp?AR=000&CA=019&guid=ON', '000', '相談'),
(13, '023', '住宅ニュース', 'http://www.smatch.jp/theme/023/', 'http://m.smatch.jp/CSM/CSM20/CSM200000.jsp?AR=000&CA=023&guid=ON', '000', '相談'),
(14, '018', 'マンションの質問', 'http://www.smatch.jp/theme/018/', 'http://m.smatch.jp/CSM/CSM20/CSM200000.jsp?AR=000&CA=018&guid=ON', '000', '相談'),
(15, '014', '東北', 'http://www.smatch.jp/theme/014/', 'http://m.smatch.jp/CSM/CSM20/CSM200000.jsp?AR=999&CA=014&guid=ON', '999', 'その他'),
(16, '016', '九州', 'http://www.smatch.jp/theme/016/', 'http://m.smatch.jp/CSM/CSM20/CSM200000.jsp?AR=999&CA=016&guid=ON', '999', 'その他'),
(17, '013', '北海道', 'http://www.smatch.jp/theme/013/', 'http://m.smatch.jp/CSM/CSM20/CSM200000.jsp?AR=999&CA=013&guid=ON', '999', 'その他'),
(18, '015', '中国・四国', 'http://www.smatch.jp/theme/015/', 'http://m.smatch.jp/CSM/CSM20/CSM200000.jsp?AR=999&CA=015&guid=ON', '999', 'その他'),
(19, '006', '茨城・栃木・群馬他', 'http://www.smatch.jp/theme/006/', 'http://m.smatch.jp/CSM/CSM20/CSM200000.jsp?AR=030&CA=006&guid=ON', '030', '関東'),
(20, '003', '神奈川', 'http://www.smatch.jp/theme/003/', 'http://m.smatch.jp/CSM/CSM20/CSM200000.jsp?AR=030&CA=003&guid=ON', '030', '関東'),
(21, '002', '東京市部', 'http://www.smatch.jp/theme/002/', 'http://m.smatch.jp/CSM/CSM20/CSM200000.jsp?AR=030&CA=002&guid=ON', '030', '関東'),
(22, '001', '東京23区', 'http://www.smatch.jp/theme/001/', 'http://m.smatch.jp/CSM/CSM20/CSM200000.jsp?AR=030&CA=001&guid=ON', '030', '関東'),
(23, '005', '埼玉', 'http://www.smatch.jp/theme/005/', 'http://m.smatch.jp/CSM/CSM20/CSM200000.jsp?AR=030&CA=005&guid=ON', '030', '関東'),
(24, '004', '千葉', 'http://www.smatch.jp/theme/004/', 'http://m.smatch.jp/CSM/CSM20/CSM200000.jsp?AR=030&CA=004&guid=ON', '030', '関東');
