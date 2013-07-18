-- phpMyAdmin SQL Dump
-- version 2.8.2.4
-- http://www.phpmyadmin.net
-- 
-- ホスト: localhost:3306
-- 作成の時間: 2013 年 1 月 13 日 00:10
-- サーバーのバージョン: 5.0.77
-- PHP バージョン: 5.2.6
-- 
-- データベース: `waao`
-- 

-- --------------------------------------------------------

-- 
-- テーブルの構造 `olympic_genre`
-- 

CREATE TABLE `olympic_genre` (
  `id` int(11) NOT NULL auto_increment,
  `genre` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `genre` (`genre`)
) ;

-- 
-- テーブルのダンプデータ `olympic_genre`
-- 

INSERT INTO `olympic_genre` (`id`, `genre`, `name`) VALUES (1, 'athletics', '陸上競技'),
(2, 'swimming', '競泳'),
(3, 'diving', '飛込み'),
(4, 'synchronisedswimming', 'シンクロナイズドスイミング'),
(5, 'football', 'サッカー'),
(6, 'tennis', 'テニス'),
(7, 'rowing', 'ボート'),
(8, 'hockey', 'ホッケー'),
(9, 'boxing', 'ボクシング'),
(10, 'volleyball', 'バレーボール'),
(11, 'beachvolleyball', 'ビーチバレー'),
(12, 'artistic', '体操'),
(13, 'rhythmic', '新体操'),
(14, 'trampoline', 'トランポリン'),
(15, 'wrestling', 'レスリング'),
(16, 'sailing', 'セーリング'),
(17, 'weightlifting', 'ウエイトリフティング'),
(18, 'cycling', '自転車'),
(19, 'tabletennis', '卓球'),
(20, 'equestrian', '馬術'),
(21, 'fencing', 'フェンシング'),
(22, 'judo', '柔道'),
(23, 'badminton', 'バドミントン'),
(24, 'rifle_shooting', 'ライフル射撃'),
(25, 'cray_shooting', 'クレー射撃'),
(26, 'modernpentathlon', '近代五種'),
(27, 'canoe', 'カヌー'),
(28, 'archery', 'アーチェリー'),
(29, 'triathlon', 'トライアスロン'),
(30, 'taekwondo', 'テコンドー');
