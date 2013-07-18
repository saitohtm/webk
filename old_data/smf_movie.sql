-- phpMyAdmin SQL Dump
-- version 2.8.2.4
-- http://www.phpmyadmin.net
-- 
-- ホスト: localhost:3306
-- 作成の時間: 2013 年 1 月 13 日 01:41
-- サーバーのバージョン: 5.0.77
-- PHP バージョン: 5.2.6
-- 
-- データベース: `waao`
-- 

-- --------------------------------------------------------

-- 
-- テーブルの構造 `smf_movie`
-- 

CREATE TABLE `smf_movie` (
  `id` int(11) NOT NULL auto_increment,
  `sitename` varchar(255) NOT NULL,
  `url` varchar(255) NOT NULL,
  `logo` varchar(255) default NULL,
  `comment` text,
  `in` int(11) NOT NULL default '0',
  `out` int(11) NOT NULL default '0',
  `type` tinyint(4) default '0',
  `howtodl` text,
  `eva` tinyint(4) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=11 DEFAULT CHARSET=cp932 AUTO_INCREMENT=11 ;

-- 
-- テーブルのダンプデータ `smf_movie`
-- 

INSERT INTO `smf_movie` (`id`, `sitename`, `url`, `logo`, `comment`, `in`, `out`, `type`, `howtodl`, `eva`) VALUES (1, 'ぷにゅむにゅ　（punyu2 munyu）', 'http://www.punyu.com/iphone/', NULL, NULL, 0, 0, 0, NULL, 5),
(2, 'えっち動画.com', 'http://iphone.hdouga.com/', NULL, NULL, 0, 0, 0, NULL, 5),
(3, 'CPZonline', 'http://sp.cpz.to/', NULL, NULL, 0, 0, 0, NULL, 5),
(4, 'オナニー大好き', 'http://iphone.onani-daisuki.com/', NULL, NULL, 0, 0, 0, NULL, 5),
(5, '動画ファイルナビゲーター', 'http://www.i-like-seen.com/', NULL, NULL, 0, 0, 0, NULL, 5),
(6, '桃猿', 'http://iphone.pinkape.net/', NULL, NULL, 0, 0, 0, NULL, 5),
(7, 'フリー＆イージー', 'http://i.erois2.tv/', NULL, NULL, 0, 0, 0, NULL, 5),
(8, 'smart movie （スマムビ）', 'http://smartmovie.jp', NULL, NULL, 0, 0, 0, NULL, 5),
(9, 'えろつべ', 'http://iphone.erotube.org/', NULL, NULL, 0, 0, 0, NULL, 4),
(10, 'ひめギャル', 'http://smart.hime-movie.com/', NULL, NULL, 0, 0, 0, NULL, 4);
