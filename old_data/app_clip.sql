-- phpMyAdmin SQL Dump
-- version 2.8.2.4
-- http://www.phpmyadmin.net
-- 
-- ホスト: localhost:3306
-- 作成の時間: 2013 年 1 月 12 日 21:34
-- サーバーのバージョン: 5.0.77
-- PHP バージョン: 5.2.6
-- 
-- データベース: `waao`
-- 

-- --------------------------------------------------------

-- 
-- テーブルの構造 `app_clip`
-- 

CREATE TABLE `app_clip` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(255) NOT NULL,
  `memo` text,
  `pv` int(11) NOT NULL default '0',
  `regist` date NOT NULL,
  `type` tinyint(4) NOT NULL,
  `keyword` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  KEY `type` (`type`),
  KEY `keyword` (`keyword`)
) ;

-- 
-- テーブルのダンプデータ `app_clip`
-- 

INSERT INTO `app_clip` (`id`, `title`, `memo`, `pv`, `regist`, `type`, `keyword`) VALUES (1, 'お正月に使える！便利で大活躍するiPhoneアプリまとめ', '２０１３年、お正月に使える！便利で大活躍すること間違いなしのiPhoneアプリまとめ。\r\n\r\nお正月といえば、\r\n「あけおめ」メール。\r\nメール送信に便利なアプリまとめ。\r\n\r\n初詣に行く時に便利なiphoneアプリ活用術\r\n\r\n年始のお出かけ便利アプリ\r\n\r\n２０１３年の運勢占い\r\n\r\nなど、お正月に大活躍すること間違いなしのアプリをまとめました！', 0, '2012-12-31', 1, NULL),
(2, '無料で使える！渋滞情報が分かるiphoneアプリ。渋滞に役立つ特選iphoneアプリ', '渋滞情報は、カーナビよりもiphoneアプリを利用するととっても便利！\r\n規制ラッシュやゴールデンウィーク、連休中の渋滞情報もiphoneアプリで楽々ゲット！\r\nそんな渋滞情報をらくにゲットできるアプリを紹介！', 0, '2013-01-02', 1, NULL);
