-- phpMyAdmin SQL Dump
-- version 2.8.2.4
-- http://www.phpmyadmin.net
-- 
-- ホスト: localhost:3306
-- 作成の時間: 2013 年 1 月 13 日 01:47
-- サーバーのバージョン: 5.0.77
-- PHP バージョン: 5.2.6
-- 
-- データベース: `waao`
-- 

-- --------------------------------------------------------

-- 
-- テーブルの構造 `smc_area`
-- 

CREATE TABLE `smc_area` (
  `id` int(11) NOT NULL auto_increment,
  `code` varchar(64) NOT NULL,
  `name` varchar(64) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=cp932 AUTO_INCREMENT=6 ;

-- 
-- テーブルのダンプデータ `smc_area`
-- 

INSERT INTO `smc_area` (`id`, `code`, `name`) VALUES (1, '050', '東海'),
(2, '060', '関西'),
(3, '000', '相談'),
(4, '999', 'その他'),
(5, '030', '関東');
