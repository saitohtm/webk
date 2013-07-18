-- phpMyAdmin SQL Dump
-- version 2.8.2.4
-- http://www.phpmyadmin.net
-- 
-- ホスト: localhost:3306
-- 作成の時間: 2013 年 1 月 13 日 01:44
-- サーバーのバージョン: 5.0.77
-- PHP バージョン: 5.2.6
-- 
-- データベース: `waao`
-- 

-- --------------------------------------------------------

-- 
-- テーブルの構造 `smc_pref`
-- 

CREATE TABLE `smc_pref` (
  `id` int(11) NOT NULL auto_increment,
  `code` varchar(64) NOT NULL,
  `name` varchar(64) NOT NULL,
  `link_pref` varchar(255) NOT NULL,
  `link_mobile` varchar(255) NOT NULL,
  `area_code` varchar(64) NOT NULL,
  `area_name` varchar(64) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `area_code` (`area_code`)
) ENGINE=MyISAM AUTO_INCREMENT=29 DEFAULT CHARSET=cp932 AUTO_INCREMENT=29 ;

-- 
-- テーブルのダンプデータ `smc_pref`
-- 

INSERT INTO `smc_pref` (`id`, `code`, `name`, `link_pref`, `link_mobile`, `area_code`, `area_name`) VALUES (1, '0504747', '静岡県', 'http://www.smatch.jp/area/0504747/', 'http://m.smatch.jp/CSM/CSM10/CSM100100.jsp?AR=050&FT=0504747&guid=ON', '050', '東海'),
(2, '0504894', '名古屋市内', 'http://www.smatch.jp/area/0504894/', 'http://m.smatch.jp/CSM/CSM10/CSM100100.jsp?AR=050&FT=0504894&guid=ON', '050', '東海'),
(3, '0505050', '三重県', 'http://www.smatch.jp/area/0505050/', 'http://m.smatch.jp/CSM/CSM10/CSM100100.jsp?AR=050&FT=0505050&guid=ON', '050', '東海'),
(4, '0509999', 'その他', 'http://www.smatch.jp/area/0509999/', 'http://m.smatch.jp/CSM/CSM10/CSM100100.jsp?AR=050&FT=0509999&guid=ON', '050', '東海'),
(5, '0504646', '岐阜県', 'http://www.smatch.jp/area/0504646/', 'http://m.smatch.jp/CSM/CSM10/CSM100100.jsp?AR=050&FT=0504646&guid=ON', '050', '東海'),
(6, '0504893', '尾張地区', 'http://www.smatch.jp/area/0504893/', 'http://m.smatch.jp/CSM/CSM10/CSM100100.jsp?AR=050&FT=0504893&guid=ON', '050', '東海'),
(7, '0504892', '三河地区', 'http://www.smatch.jp/area/0504892/', 'http://m.smatch.jp/CSM/CSM10/CSM100100.jsp?AR=050&FT=0504892&guid=ON', '050', '東海'),
(8, '0605555', '奈良県', 'http://www.smatch.jp/area/0605555/', 'http://m.smatch.jp/CSM/CSM10/CSM100100.jsp?AR=060&FT=0605555&guid=ON', '060', '関西'),
(9, '0605252', '京都府', 'http://www.smatch.jp/area/0605252/', 'http://m.smatch.jp/CSM/CSM10/CSM100100.jsp?AR=060&FT=0605252&guid=ON', '060', '関西'),
(10, '0605151', '滋賀県', 'http://www.smatch.jp/area/0605151/', 'http://m.smatch.jp/CSM/CSM10/CSM100100.jsp?AR=060&FT=0605151&guid=ON', '060', '関西'),
(11, '0605496', '兵庫県神戸市内', 'http://www.smatch.jp/area/0605496/', 'http://m.smatch.jp/CSM/CSM10/CSM100100.jsp?AR=060&FT=0605496&guid=ON', '060', '関西'),
(12, '0605397', '大阪府大阪市内', 'http://www.smatch.jp/area/0605397/', 'http://m.smatch.jp/CSM/CSM10/CSM100100.jsp?AR=060&FT=0605397&guid=ON', '060', '関西'),
(13, '0609999', '和歌山・三重・その他', 'http://www.smatch.jp/area/0609999/', 'http://m.smatch.jp/CSM/CSM10/CSM100100.jsp?AR=060&FT=0609999&guid=ON', '060', '関西'),
(14, '0605353', '大阪府大阪市以外', 'http://www.smatch.jp/area/0605353/', 'http://m.smatch.jp/CSM/CSM10/CSM100100.jsp?AR=060&FT=0605353&guid=ON', '060', '関西'),
(15, '0605454', '兵庫県神戸市以外', 'http://www.smatch.jp/area/0605454/', 'http://m.smatch.jp/CSM/CSM10/CSM100100.jsp?AR=060&FT=0605454&guid=ON', '060', '関西'),
(16, '0900000', '九州', 'http://www.smatch.jp/area/0900000/', 'http://m.smatch.jp/CSM/CSM10/CSM100100.jsp?AR=999&FT=0900000&guid=ON', '999', 'その他'),
(17, '0100000', '北海道', 'http://www.smatch.jp/area/0100000/', 'http://m.smatch.jp/CSM/CSM10/CSM100100.jsp?AR=999&FT=0100000&guid=ON', '999', 'その他'),
(18, '0200000', '東北・北陸', 'http://www.smatch.jp/area/0200000/', 'http://m.smatch.jp/CSM/CSM10/CSM100100.jsp?AR=999&FT=0200000&guid=ON', '999', 'その他'),
(19, '0800000', '中四国', 'http://www.smatch.jp/area/0800000/', 'http://m.smatch.jp/CSM/CSM10/CSM100100.jsp?AR=999&FT=0800000&guid=ON', '999', 'その他'),
(20, '0303333', '埼玉県', 'http://www.smatch.jp/area/0303333/', 'http://m.smatch.jp/CSM/CSM10/CSM100100.jsp?AR=030&FT=0303333&guid=ON', '030', '関東'),
(21, '0303636', '神奈川県', 'http://www.smatch.jp/area/0303636/', 'http://m.smatch.jp/CSM/CSM10/CSM100100.jsp?AR=030&FT=0303636&guid=ON', '030', '関東'),
(22, '0309999', 'その他', 'http://www.smatch.jp/area/0309999/', 'http://m.smatch.jp/CSM/CSM10/CSM100100.jsp?AR=030&FT=0309999&guid=ON', '030', '関東'),
(23, '0303535', '東京市部', 'http://www.smatch.jp/area/0303535/', 'http://m.smatch.jp/CSM/CSM10/CSM100100.jsp?AR=030&FT=0303535&guid=ON', '030', '関東'),
(24, '0303030', '茨城県', 'http://www.smatch.jp/area/0303030/', 'http://m.smatch.jp/CSM/CSM10/CSM100100.jsp?AR=030&FT=0303030&guid=ON', '030', '関東'),
(25, '0303131', '栃木県', 'http://www.smatch.jp/area/0303131/', 'http://m.smatch.jp/CSM/CSM10/CSM100100.jsp?AR=030&FT=0303131&guid=ON', '030', '関東'),
(26, '0303598', '東京23区内', 'http://www.smatch.jp/area/0303598/', 'http://m.smatch.jp/CSM/CSM10/CSM100100.jsp?AR=030&FT=0303598&guid=ON', '030', '関東'),
(27, '0303232', '群馬県', 'http://www.smatch.jp/area/0303232/', 'http://m.smatch.jp/CSM/CSM10/CSM100100.jsp?AR=030&FT=0303232&guid=ON', '030', '関東'),
(28, '0303434', '千葉県', 'http://www.smatch.jp/area/0303434/', 'http://m.smatch.jp/CSM/CSM10/CSM100100.jsp?AR=030&FT=0303434&guid=ON', '030', '関東');
