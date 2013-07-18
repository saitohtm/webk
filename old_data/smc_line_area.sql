-- phpMyAdmin SQL Dump
-- version 2.8.2.4
-- http://www.phpmyadmin.net
-- 
-- ホスト: localhost:3306
-- 作成の時間: 2013 年 1 月 13 日 01:45
-- サーバーのバージョン: 5.0.77
-- PHP バージョン: 5.2.6
-- 
-- データベース: `waao`
-- 

-- --------------------------------------------------------

-- 
-- テーブルの構造 `smc_line_area`
-- 

CREATE TABLE `smc_line_area` (
  `id` int(11) NOT NULL auto_increment,
  `code` varchar(64) NOT NULL,
  `name` varchar(128) NOT NULL,
  `link_line_area` varchar(255) NOT NULL,
  `link_mobile` varchar(255) NOT NULL,
  `area_code` varchar(64) NOT NULL,
  `area_name` varchar(64) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `area_code` (`area_code`)
) ENGINE=MyISAM AUTO_INCREMENT=18 DEFAULT CHARSET=cp932 AUTO_INCREMENT=18 ;

-- 
-- テーブルのダンプデータ `smc_line_area`
-- 

INSERT INTO `smc_line_area` (`id`, `code`, `name`, `link_line_area`, `link_mobile`, `area_code`, `area_name`) VALUES (1, '06007', '神戸電鉄・神戸市営地下鉄ほか', 'http://www.smatch.jp/rail/06007/', 'http://m.smatch.jp/CSM/CSM10/CSM100200.jsp?AR=060&EH=06007&guid=ON', '060', '関西'),
(2, '06001', 'ＪＲ', 'http://www.smatch.jp/rail/06001/', 'http://m.smatch.jp/CSM/CSM10/CSM100200.jsp?AR=060&EH=06001&guid=ON', '060', '関西'),
(3, '06008', 'その他', 'http://www.smatch.jp/rail/06008/', 'http://m.smatch.jp/CSM/CSM10/CSM100200.jsp?AR=060&EH=06008&guid=ON', '060', '関西'),
(4, '06004', '近鉄', 'http://www.smatch.jp/rail/06004/', 'http://m.smatch.jp/CSM/CSM10/CSM100200.jsp?AR=060&EH=06004&guid=ON', '060', '関西'),
(5, '06002', '大阪市営地下鉄・大阪モノレールほか', 'http://www.smatch.jp/rail/06002/', 'http://m.smatch.jp/CSM/CSM10/CSM100200.jsp?AR=060&EH=06002&guid=ON', '060', '関西'),
(6, '06003', '阪急・阪神・山陽・能勢', 'http://www.smatch.jp/rail/06003/', 'http://m.smatch.jp/CSM/CSM10/CSM100200.jsp?AR=060&EH=06003&guid=ON', '060', '関西'),
(7, '06006', '南海電鉄・阪堺電気軌道ほか', 'http://www.smatch.jp/rail/06006/', 'http://m.smatch.jp/CSM/CSM10/CSM100200.jsp?AR=060&EH=06006&guid=ON', '060', '関西'),
(8, '06005', '京阪・京都市営地下鉄ほか', 'http://www.smatch.jp/rail/06005/', 'http://m.smatch.jp/CSM/CSM10/CSM100200.jsp?AR=060&EH=06005&guid=ON', '060', '関西'),
(9, '03007', '栃木方面', 'http://www.smatch.jp/rail/03007/', 'http://m.smatch.jp/CSM/CSM10/CSM100200.jsp?AR=030&EH=03007&guid=ON', '030', '関東'),
(10, '030ZZ', 'その他', 'http://www.smatch.jp/rail/030ZZ/', 'http://m.smatch.jp/CSM/CSM10/CSM100200.jsp?AR=030&EH=030ZZ&guid=ON', '030', '関東'),
(11, '03008', '群馬方面', 'http://www.smatch.jp/rail/03008/', 'http://m.smatch.jp/CSM/CSM10/CSM100200.jsp?AR=030&EH=03008&guid=ON', '030', '関東'),
(12, '03005', '東京?千葉方面', 'http://www.smatch.jp/rail/03005/', 'http://m.smatch.jp/CSM/CSM10/CSM100200.jsp?AR=030&EH=03005&guid=ON', '030', '関東'),
(13, '03003', '東京?市部方面', 'http://www.smatch.jp/rail/03003/', 'http://m.smatch.jp/CSM/CSM10/CSM100200.jsp?AR=030&EH=03003&guid=ON', '030', '関東'),
(14, '03004', '東京?埼玉方面', 'http://www.smatch.jp/rail/03004/', 'http://m.smatch.jp/CSM/CSM10/CSM100200.jsp?AR=030&EH=03004&guid=ON', '030', '関東'),
(15, '03001', '都心部（山手線・地下鉄）', 'http://www.smatch.jp/rail/03001/', 'http://m.smatch.jp/CSM/CSM10/CSM100200.jsp?AR=030&EH=03001&guid=ON', '030', '関東'),
(16, '03006', '茨城方面', 'http://www.smatch.jp/rail/03006/', 'http://m.smatch.jp/CSM/CSM10/CSM100200.jsp?AR=030&EH=03006&guid=ON', '030', '関東'),
(17, '03002', '東京?神奈川方面', 'http://www.smatch.jp/rail/03002/', 'http://m.smatch.jp/CSM/CSM10/CSM100200.jsp?AR=030&EH=03002&guid=ON', '030', '関東');
