-- phpMyAdmin SQL Dump
-- version 2.8.2.4
-- http://www.phpmyadmin.net
-- 
-- ホスト: localhost:3306
-- 作成の時間: 2013 年 1 月 14 日 20:18
-- サーバーのバージョン: 5.0.77
-- PHP バージョン: 5.2.6
-- 
-- データベース: `waao`
-- 

-- --------------------------------------------------------

-- 
-- テーブルの構造 `photo`
-- 

CREATE TABLE `photo` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `keywordid` int(10) unsigned NOT NULL,
  `url` varchar(255) NOT NULL,
  `keyword` varchar(255) NOT NULL,
  `title1` varchar(32) default NULL,
  `key1` varchar(64) default NULL,
  `key2` varchar(64) default NULL,
  `key3` varchar(64) default NULL,
  `key4` varchar(64) default NULL,
  `key5` varchar(64) default NULL,
  `good` int(11) NOT NULL default '0',
  `bad` int(11) NOT NULL default '0',
  `backurl` varchar(255) default NULL,
  `yahoo` tinyint(4) default '0',
  `fullurl` varchar(255) default NULL,
  `updated` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `fit_img_url` varchar(255) default NULL,
  `flickr` tinyint(4) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `url` (`url`),
  KEY `keywordid` (`keywordid`),
  KEY `keyword` (`keyword`,`good`)
) ;
