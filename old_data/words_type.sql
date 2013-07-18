-- phpMyAdmin SQL Dump
-- version 2.8.2.4
-- http://www.phpmyadmin.net
-- 
-- ホスト: localhost:3306
-- 作成の時間: 2013 年 1 月 13 日 01:37
-- サーバーのバージョン: 5.0.77
-- PHP バージョン: 5.2.6
-- 
-- データベース: `waao`
-- 

-- --------------------------------------------------------

-- 
-- テーブルの構造 `words_type`
-- 

CREATE TABLE `words_type` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `adult` tinyint(4) NOT NULL default '0',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=cp932;

-- 
-- テーブルのダンプデータ `words_type`
-- 

INSERT INTO `words_type` (`id`, `name`, `adult`) VALUES (1, 'ソープランド用語', 1),
(2, '2ちゃんねる', 0),
(3, 'Twitter', 0),
(4, '経営', 0);
