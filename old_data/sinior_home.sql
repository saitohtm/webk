-- phpMyAdmin SQL Dump
-- version 2.8.2.4
-- http://www.phpmyadmin.net
-- 
-- ホスト: localhost:3306
-- 作成の時間: 2013 年 1 月 13 日 00:13
-- サーバーのバージョン: 5.0.77
-- PHP バージョン: 5.2.6
-- 
-- データベース: `waao`
-- 

-- --------------------------------------------------------

-- 
-- テーブルの構造 `sinior_home`
-- 

CREATE TABLE `sinior_home` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `pref_name` varchar(64) NOT NULL,
  `pref_id` int(11) NOT NULL,
  `address` varchar(255) default NULL,
  `tel` varchar(64) default NULL,
  `type` tinyint(4) NOT NULL,
  `homepage` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `type` (`type`)
) ;

-- 
-- テーブルのダンプデータ `sinior_home`
-- 

INSERT INTO `sinior_home` (`id`, `name`, `pref_name`, `pref_id`, `address`, `tel`, `type`, `homepage`) VALUES (1, '特別養護老人ホーム羊蹄ハイツ', '北海道', 1, '虻田郡倶知安町字峠下１１３－２', '0136-22-3131', 1, 'http://www6.ocn.ne.jp/~y.haitu/'),
(2, '社会福祉法人幸清会', '北海道', 1, '虻田郡洞爺湖町清水４３４', '0142-76-4633', 1, 'http://www.koseikai-wel.or.jp'),
(3, '特別養護老人ホームしらかば苑', '北海道', 1, '足寄郡陸別町字陸別原野基線３２１－５', '0156-27-3803', 1, 'http://www.rikubetsu.or.jp'),
(4, '利尻富士町役場／特別養護老人ホーム', '北海道', 1, '利尻郡利尻富士町鬼脇字金崎', '0163-83-1313', 1, 'http://www.town.rishirifuji.hokkaido.jp/'),
(5, '青山荘／特別養護老人ホーム', '青森県', 2, '五所川原市大字金山字盛山４２－８', '0173-35-4215', 1, 'http://www.pma.ne.jp/seizansou/'),
(6, '長慶苑／特別養護老人ホーム', '青森県', 2, '弘前市大字坂市字亀田５３－３', '0172-84-1010', 1, 'http://www.cnet.or.jp/'),
(7, '特別養護老人ホーム松山荘', '青森県', 2, '弘前市大字百沢字小松野８７－１７３', '0172-83-2231', 1, 'http://www.infoaomori.ne.jp/syozanso/index.html'),
(8, '社会福祉法人和幸園／特別養護老人ホーム和幸園', '青森県', 2, '青森市大字矢田字下野尻４８－３', '017-737-3333', 1, 'http://www.wakouen.or.jp/'),
(9, '光葉園／特別養護老人ホーム', '青森県', 2, '八戸市大字鮫町字金屎３５－９０', '0178-33-5426', 1, 'http://www.koyoen.or.jp/'),
(10, '福寿草特別養護老人ホーム', '青森県', 2, '八戸市大字妙字西平６－２７', '0178-25-1021', 1, 'http://www5.ocn.ne.jp/~fukujuso/'),
(11, '都南あけぼの荘', '岩手県', 3, '盛岡市湯沢４地割２５－１', '019-639-2525', 1, 'http://akebonosou.org/'),
(12, '特別養護老人ホーム永寿園', '宮城県', 4, '宮崎県日向市大字富高５４６－１', '0982-53-4007', 1, 'http://www.himawarikai.or.jp'),
(13, '飯舘村役場／いいたて福祉会／いいたてホーム', '福島県', 7, '相馬郡飯舘村伊丹沢字伊丹沢５７１', '0244-42-1700', 1, 'http://www.vill.iitate.fukushima.jp/'),
(14, '白百合会増戸ホーム', '東京都', 13, 'あきる野市三内４８５－１', '042-596-3456', 1, 'http://plaza12.mbn.or.jp/~masuko'),
(15, '特別養護老人ホーム／奥戸くつろぎの郷', '東京都', 13, '葛飾区奥戸３丁目２５－１', '03-5670-1261', 1, 'http://www.edogawa.or.jp'),
(16, '特別養護老人ホーム／水元ふれあいの家', '東京都', 13, '葛飾区水元１丁目２６－２０', '03-3607-7881', 1, 'http://www.edogawa.or.jp'),
(17, '特別養護老人ホーム／むつみ園', '東京都', 13, '江東区深川２丁目１４－１１', '03-3642-4791', 1, 'http://mutumien.hp.infoseek.co.jp/'),
(18, '老人ホーム全国ネット', '東京都', 13, '新宿区西新宿１丁目１４－１０', '0120-607013', 1, 'http://www.r-home.jp/'),
(19, '有料老人ホーム・介護施設紹介センター', '東京都', 13, '世田谷区玉川３丁目１５－１２－２０６', '0120-176246', 1, 'http://www.careproduce.com'),
(20, '世田谷区立特別養護老人ホーム芦花ホーム', '東京都', 13, '世田谷区粕谷２丁目２３－１', '03-5317-1094', 1, 'http://www.setagayaj.or.jp'),
(21, '特別養護老人ホーム久我山園', '東京都', 13, '世田谷区北烏山２丁目１４－１４', '03-3309-3211', 1, 'http://www8.ocn.ne.jp/~kugayama/'),
(22, '介護老人福祉施設・琴清苑', '東京都', 13, '西多摩郡奥多摩町氷川１０９９', '0428-83-3932', 1, 'http://www.futabakai.or.jp'),
(23, '大洋園', '東京都', 13, '青梅市今井５丁目２４４０－１４１', '0428-31-3666', 1, 'http://www.taiyoen.or.jp'),
(24, '特別養護老人ホーム中央本町杉の子園', '東京都', 13, '足立区中央本町４丁目１４－２０', '03-3886-0002', 1, 'http://www3.tokai.or.jp/suginokoen/'),
(25, 'ゆうあいの郷六月', '東京都', 13, '足立区六月１丁目６－１', '03-5242-0303', 1, 'http://www.seifuukai.or.jp'),
(26, '特別養護老人ホーム好日苑', '東京都', 13, '大田区上池台５丁目７－１', '03-3748-6193', 1, 'http://www.hibikikai-tokyo.or.jp'),
(27, '社会福祉法人ゴールデン鶴亀ホーム白陽会', '東京都', 13, '大田区矢口１丁目２３－１２', '03-3758-1810', 1, 'http://homepage2.nifty.com/hakuyokai'),
(28, 'マザアス日野', '東京都', 13, '日野市万願寺１－１６－１', '042-582-1661', 1, 'http://www.moth.or.jp'),
(29, '小松原園', '東京都', 13, '八王子市犬目町６８８－２', '042-654-8331', 1, 'http://www.komatubaraen.or.jp/'),
(30, '不二健育会特別養護老人ホームケアポート板橋　（社会福祉法人）', '東京都', 13, '板橋区舟渡３丁目４－８', '03-3969-3101', 1, 'http://www.fujikenikukai.or.jp'),
(31, 'サンシャインホーム', '東京都', 13, '武蔵村山市伊奈平４丁目１０－２', '042-531-3741', 1, 'http://www.sunshinehome.or.jp'),
(32, '墨田区特別養護老人ホームたちばなホーム', '東京都', 13, '墨田区立花３丁目１０－１', '03-3613-8718', 1, 'http://www.san-ikukai.or.jp'),
(33, '清徳園特別養護老人ホーム', '東京都', 13, '目黒区目黒本町４丁目２－１', '03-3794-5577', 1, 'http://seitoku.or.jp/'),
(34, '社会福祉法人東京福祉会練馬高松園', '東京都', 13, '練馬区高松２丁目９－３', '03-3926-8341', 1, 'http://www.tfk.or.jp'),
(35, '練馬区／特別養護老人ホーム練馬キングス・ガーデン', '東京都', 13, '練馬区早宮２丁目１０－２２', '03-5399-2201', 1, 'http://www.n-kings.or.jp'),
(36, '練馬区／田柄特別養護老人ホーム', '東京都', 13, '練馬区田柄４丁目１２－１０', '03-3825-1551', 1, 'http://www.nerima-swf.jp/tagara.htm'),
(37, '練馬区／富士見台特別養護老人ホーム', '東京都', 13, '練馬区富士見台１丁目２２－４', '03-5241-6010', 1, 'http://www.nerima-swf.jp/fujimidai.htm'),
(38, '特別養護老人ホームシャローム横浜', '神奈川県', 14, '横浜市旭区上川井町１９８８', '045-922-7333', 1, 'http://homepage1.nifty.com/shalom-yokohama/'),
(39, 'たきがしら芭蕉苑', '神奈川県', 14, '横浜市磯子区滝頭２丁目３０－１', '045-750-5151', 1, 'http://www2u.biglobe.ne.jp/~basyoen/'),
(40, '特別養護老人ホームかわしまホーム', '神奈川県', 14, '横浜市保土ケ谷区川島町１５１４－２', '045-371-8080', 1, 'http://www.fukushi-kousaikai.or.jp'),
(41, '睦合ホーム／やすらぎ', '神奈川県', 14, '厚木市下川入１２９６', '046-245-8312', 1, 'http://www.mutuaihome.or.jp/main/'),
(42, '社会福祉法人寒川ホーム', '神奈川県', 14, '高座郡寒川町小谷１丁目１３－５', '0467-75-0785', 1, 'http://www.samukawahome.com'),
(43, '長寿園有料老人ホーム', '神奈川県', 14, '小田原市入生田４７５', '0465-24-0002', 1, 'http://www.chojuen.or.jp/'),
(44, '特別養護老人ホーム中の郷', '神奈川県', 14, '相模原市大島１５５６', '042-763-0005', 1, 'http://www.nakanogou.org/'),
(45, '中井富士白苑', '神奈川県', 14, '足柄上郡中井町井ノ口２３０５－４', '0465-81-5888', 1, 'http://www.fujishiro-group.com'),
(46, '富士白苑介護老人福祉施設', '神奈川県', 14, '平塚市唐ケ原１', '0463-61-1841', 1, 'http://www.fujishiro-group.com/'),
(47, '武蔵野ユートピアダイアナクラブ', '埼玉県', 11, '熊谷市小江川１３９６', '048-536-1911', 1, 'http://www5.ocn.ne.jp/~yu-topia/'),
(48, '社会福祉法人明正会', '埼玉県', 11, '児玉郡上里町大字金久保７７７', '0495-34-3388', 1, 'http://www.hpmix.com/home/meiseikai/'),
(49, '特別養護老人ホーム悠う湯ホーム', '埼玉県', 11, '秩父郡皆野町大字下日野沢３９０６－３', '0494-62-5550', 1, 'http://www15.ocn.ne.jp/~you-you/'),
(50, '特別養護老人ホームみずほ苑', '埼玉県', 11, '入間郡三芳町大字竹間沢７３５－１', '049-258-9211', 1, 'http://www.mizuhoen.com'),
(51, '介護老人福祉施設太行路', '埼玉県', 11, '飯能市大字下名栗４６０', '042-979-0011', 1, 'http://www.nagurien.or.jp'),
(52, 'デイサービスセンターグランモア和光苑', '千葉県', 12, '市原市椎津５－１', '0436-62-6008', 1, 'http://www.mmjp.or.jp/wakouen/'),
(53, 'ケアハウスグリーンパーク習志野', '千葉県', 12, '習志野市新栄１丁目１０－２', '047-476-5122', 1, 'http://www.baycm.co.jp/kaiseien/'),
(54, 'ゆりの木苑', '千葉県', 12, '東金市家徳７５６－２', '0475-50-8111', 1, 'http://www1.ocn.ne.jp/~yurinoki/'),
(55, '四季の里／特別養護老人ホーム四季の里', '千葉県', 12, '柏市松ケ崎８９９－１', '04-7135-2255', 1, 'http://www.aoikai.jp/shisetu/shiki_tokuyo/'),
(56, '社会福祉法人さつき会特別養護老人ホームつつじ苑', '千葉県', 12, '富津市上飯野１４２６－３', '0439-87-6101', 1, 'http://www.syakaihukushihoujin.satsuki-kai.or.jp/'),
(57, '特別養護老人ホームサントピア鹿島', '茨城県', 8, '鹿嶋市大字宮中５２００', '0299-83-2311', 1, 'http://www.suntopia.jp/'),
(58, 'べるびー水戸', '茨城県', 8, '水戸市赤塚１丁目１', '029-309-0770', 1, 'http://www.bellevie.jp/'),
(59, 'まほろばの里', '栃木県', 9, '下野市箕輪４４１－１', '0285-44-5155', 1, 'http://www7.ocn.ne.jp/~keiwa22/'),
(60, 'ホピ園', '群馬県', 10, '高崎市寺尾町６２１', '027-324-8844', 1, 'http://www6.wind.ne.jp/hopi/'),
(61, '社会福祉法人新生会／桜が丘三ホーム', '群馬県', 10, '高崎市中室田町２１０９', '027-374-4777', 1, 'http://www.sinseikai.org/'),
(62, '社会福祉法人新生会／フィリアの丘', '群馬県', 10, '高崎市中室田町２２５２', '027-374-0767', 1, 'http://www.sinseikai.org/'),
(63, '社会福祉法人新生会／フィリアの丘／榛名町在宅介護支援センターフィリアいこい', '群馬県', 10, '高崎市中室田町２２５２', '027-374-8788', 1, 'http://www.sinseikai.org/'),
(64, '社会福祉法人新生会／ジョージが丘三ホーム', '群馬県', 10, '高崎市中室田町２２５４', '027-374-2998', 1, 'http://www.sinseikai.org/'),
(65, '特別養護老人ホーム敷島荘', '山梨県', 19, '甲斐市大久保１３５７', '055-277-8811', 1, 'http://park15.wakwak.com/~seichoukai/'),
(66, 'つばめ福寿園', '新潟県', 15, '燕市佐渡７４５－１', '0256-62-6157', 1, 'http://www3.ocn.ne.jp/~fukuju/index.html'),
(67, '白ふじの里', '新潟県', 15, '燕市大曲２４７２－１', '0256-61-6150', 1, 'http://www3.ocn.ne.jp/~fukuju/index.html'),
(68, '特別養護老人ホームこぶし園', '新潟県', 15, '長岡市深沢町２２７８－８', '0258-46-6610', 1, 'http://www.kobushien.com/'),
(69, '佐久福寿園', '長野県', 20, '佐久市岩村田４２１３', '0267-68-3055', 1, 'http://www.janis.or.jp/users/fukujuen/'),
(70, '松塩筑木曽老人福祉施設組合特別養護老人ホーム四賀福寿荘', '長野県', 20, '松本市刈谷原町６１３', '0263-64-2922', 1, 'http://www.aoihato.jp/'),
(71, 'ゆめの里和田／特別養護老人ホーム・短期入所', '長野県', 20, '松本市大字和田２２４０－３３', '0263-40-3377', 1, 'http://www.mhl.janis.or.jp/local/tokuyouro/yumenosato.html'),
(72, '依田窪特別養護老人ホームともしび', '長野県', 20, '上田市下武石７７６－１', '0268-85-2218', 1, 'http://www.janis.or.jp/users/tomosibi/'),
(73, 'ローマンうえだ特別養護老人ホーム', '長野県', 20, '上田市殿城２５０－１', '0268-26-8871', 1, 'http://www.janis.or.jp/kenren/kouseiren/tokuyo.html/'),
(74, 'グレイスフル下諏訪／特別養護老人ホーム', '長野県', 20, '諏訪郡下諏訪町北高木９３７５－１', '0266-26-8851', 1, 'http://www.sun-vision.or.jp/'),
(75, '諏訪市在宅介護支援センター／西山の里・居宅介護支援事業所', '長野県', 20, '諏訪市大字湖南４０１６－１', '0266-56-1000', 1, 'http://www.suwacity-shakyo.or.jp'),
(76, '特別養護老人ホーム須坂やすらぎの園', '長野県', 20, '須坂市大字日滝２８８７－１', '026-246-4600', 1, 'http://www.valley.ne.jp/~yasuragi/'),
(77, 'カトレヤ／特別養護老人ホーム', '長野県', 20, '大町市平１９５５－９７１', '0261-23-0722', 1, 'http://www.bh.wakwak.com/~katoreya/'),
(78, '博仁会桜荘', '長野県', 20, '長野市篠ノ井二ツ柳１５３５－１', '026-293-0088', 1, 'http://w2.avis.ne.jp/~sakuraso/index.htm'),
(79, 'フォーレスト', '長野県', 20, '東御市常田２－１', '0268-64-7200', 1, 'http://www.forest-c.com'),
(80, '松塩筑木曽老人福祉施設組合／特別養護老人ホームサンライフおみ', '長野県', 20, '東筑摩郡麻績村麻２１１７－１', '0263-67-4555', 1, 'http://www.aoihato.jp/'),
(81, '特別養護老人ホーム遠山荘', '長野県', 20, '飯田市南信濃和田１５５０', '0260-34-5522', 1, 'http://www.iidanet.or.jp/~toyamaso/'),
(82, 'アルペンハイツ／特別養護老人ホーム', '富山県', 16, '富山市小西１７０', '076-451-1000', 1, 'http://www.alpen.or.jp'),
(83, '特別養護老人ホーム金沢朱鷺の苑', '石川県', 17, '金沢市岸川町ほ５', '076-257-7100', 1, 'http://www.tokinoen.com/kintoki/index.html'),
(84, '中央金沢朱鷺の苑', '石川県', 17, '金沢市広岡２丁目１－７', '076-234-7878', 1, 'http://www.tokinoen.com/'),
(85, '万陽苑', '石川県', 17, '金沢市三口新町１丁目８－１', '076-263-7101', 1, 'http://www.yofuen.com'),
(86, '第三万陽苑', '石川県', 17, '金沢市三小牛町２４－３－１', '076-280-6781', 1, 'http://www.yofuen.com'),
(87, '第二金沢朱鷺の苑', '石川県', 17, '金沢市上辰巳１０－２１１', '076-229-8181', 1, 'http://www.tokinoen.com/dai2toki/'),
(88, '第二万陽苑', '石川県', 17, '金沢市大桑町中ノ大平１８－２５', '076-243-0101', 1, 'http://www.yofuen.com'),
(89, '美杉の郷', '石川県', 17, '白山市桑島４－８７－５', '0761-98-2117', 1, 'http://www.misuginosato.or.jp'),
(90, '特別養護老人ホームゆきわりそう', '石川県', 17, '輪島市門前町深田２２－４２', '0768-42-3333', 1, 'http://www.incl.ne.jp/yukiwari/'),
(91, 'すみれ荘', '福井県', 18, '福井市島寺町８３－１', '0776-98-5550', 1, 'http://www.sumiresou.jp'),
(92, '春緑苑／特別養護老人ホーム', '愛知県', 23, '春日井市廻間町７０３－１', '0568-88-5585', 1, 'http://www.mc.ccnw.ne.jp/aichi-douen/'),
(93, '愛厚ホーム瀬戸苑', '愛知県', 23, '瀬戸市原山町１－１０', '0561-84-5282', 1, 'http://www6.ocn.ne.jp/~setoen/'),
(94, '特別養護老人ホームほほえみの里', '愛知県', 23, '知立市昭和２丁目４－３', '0566-85-2525', 1, 'http://www.hohoeminosato.com'),
(95, 'シルバーピアみどり苑', '愛知県', 23, '碧南市油渕町３丁目５０', '0566-48-7111', 1, 'http://www.chojukai.com'),
(96, '港寿楽苑特別養護老人ホーム', '愛知県', 23, '名古屋市港区寛政町６丁目１０', '052-381-4122', 1, 'http://www.shoumei.or.jp'),
(97, '瀬古マザー園', '愛知県', 23, '名古屋市守山区瀬古２丁目３０１', '052-792-5556', 1, 'http://www.nagoya-lighthouse.jp/mather/'),
(98, '第二尾張荘', '愛知県', 23, '名古屋市守山区川東山３３２１', '052-794-1611', 1, 'http://www.gyokuyokai.com'),
(99, '特別養護老人ホームほほえみ福寿の家', '岐阜県', 21, '関市稲口８４５', '0575-24-9570', 1, 'http://www.hohoemi.or.jp'),
(100, '特別養護老人ホームビアンカ', '岐阜県', 21, '多治見市上山町１丁目９７－２', '0572-25-0780', 1, 'http://www.c-5.ne.jp/~bianca/'),
(101, '友和苑', '岐阜県', 21, '大垣市入方３丁目７０－１', '0584-88-1567', 1, 'http://www11.ocn.ne.jp/~yuuwaen/'),
(102, '梓の里', '静岡県', 22, '下田市加増野１８１－１', '0558-28-1172', 1, 'http://www.shiyuukai.or.jp'),
(103, '特別養護老人ホーム太陽の里', '静岡県', 22, '賀茂郡西伊豆町仁科１１３４', '0558-52-6200', 1, 'http://www.shiyuukai.or.jp'),
(104, '特別養護老人ホームみなとの園', '静岡県', 22, '賀茂郡南伊豆町湊６３８－１', '0558-62-8111', 1, 'http://www.shiyuukai.or.jp'),
(105, '東海清風園', '静岡県', 22, '御前崎市池新田４０９４', '0537-86-3286', 1, 'http://www.san-ikukai.or.jp'),
(106, '御寿園／特別養護老人ホーム', '静岡県', 22, '三島市御園５８０', '055-977-6200', 1, 'http://www.misono-home.jp/'),
(107, '信愛会ぬまづホーム', '静岡県', 22, '沼津市下香貫猪沼９８１－２', '055-934-1821', 1, 'http://www3.ocn.ne.jp/~f-shinai/'),
(108, 'あしたかホーム', '静岡県', 22, '沼津市東椎路１６３９－１', '055-967-1166', 1, 'http://www.shunpuukai.com'),
(109, '晃の園', '静岡県', 22, '静岡市葵区富沢１５４２－３９', '054-270-1210', 1, 'http://www.1.ocn.ne.jp/~surugga/hikari'),
(110, '楽寿の園高齢者総合福祉エリア', '静岡県', 22, '静岡市葵区与左衛門新田７４－６', '054-296-1111', 1, 'http://www.rakuju.or.jp'),
(111, '特別養護老人ホームこもれび', '静岡県', 22, '静岡市清水区吉原１７３１', '054-343-0155', 1, 'http://www.t-komorebi.com/'),
(112, 'ぶなの森／特別養護老人ホーム', '静岡県', 22, '田方郡函南町仁田２８４－５', '055-970-1127', 1, 'http://www.buna-no-mori.jp'),
(113, '本田山荘', '静岡県', 22, '島田市牛尾１１０２－１', '0547-45-2022', 1, 'http://park22.wakwak.com/~hondenyamaso/'),
(114, '西貝の郷特別養護老人ホーム', '静岡県', 22, '磐田市西貝塚２１１１－１', '0538-21-3955', 1, 'http://www.saishinkai.or.jp'),
(115, '岳南厚生会／老人ホーム高原荘', '静岡県', 22, '富士宮市貫戸１０３－２', '0544-23-0486', 1, 'http://takaharasou.jp/'),
(116, '特別養護老人ホーム富士宮荘', '静岡県', 22, '富士宮市上井出２０２９－１', '0544-54-1351', 1, 'http://www.fujikoseikai.or.jp/'),
(117, '特別養護老人ホーム正邦苑', '三重県', 24, '伊勢市村松町３２９４－１', '0596-38-1800', 1, 'http://www2.ocn.ne.jp/~jikeikai/'),
(118, '在宅介護支援センター／みどり', '三重県', 24, '員弁郡東員町城山３丁目３４－２９', '0594-76-7826', 1, 'http://www.touin.jp'),
(119, '（社）成年後見センター・リーガルサポート三重支部', '三重県', 24, '津市丸之内養正町１７－１７', '059-213-4666', 1, 'http://www.legal-support.or.jp/'),
(120, '特別養護老人ホーム榊原陽光苑', '三重県', 24, '津市榊原町５６８４', '059-252-2650', 1, 'http://www.chusei-fukushi.com/'),
(121, '社会福祉法人高田福祉事業協会／特別養護老人ホーム高田光寿園', '三重県', 24, '津市大里野田町１１２４－１', '059-230-7811', 1, 'http://www.chusei-fukushi.com/'),
(122, '特別養護老人ホーム春日丘荘', '大阪府', 27, '茨木市南春日丘７丁目１１－２２', '072-625-6377', 1, 'http://www.osj.or.jp/kasugaoka/'),
(123, '寿里苑', '大阪府', 27, '河内長野市小山田町４４８－２', '0721-52-3888', 1, 'http://www.julien.or.jp/'),
(124, 'ハーモニー特別養護老人ホーム', '大阪府', 27, '堺市東区南野田３３', '072-239-0011', 1, 'http://www.harmony.or.jp'),
(125, '特別養護老人ホーム寝屋川苑', '大阪府', 27, '寝屋川市宇谷町１－３６', '072-824-0345', 1, 'http://www.neyagawaen.com'),
(126, '特別養護老人ホームあすーる吹田', '大阪府', 27, '吹田市岸部中２丁目７－１２', '06-6385-7070', 1, 'http://azul.or.jp'),
(127, '特別養護老人ホームホライズン', '大阪府', 27, '泉佐野市鶴原１０７１－１', '072-460-0880', 1, 'http://www.horizon.or.jp/'),
(128, '特別養護老人ホーム／弥栄園', '大阪府', 27, '泉南郡熊取町大久保南３丁目１３８０－１', '072-452-7025', 1, 'http://www.yasakaen.com/'),
(129, '特別養護老人ホーム六尾の郷', '大阪府', 27, '泉南市信達六尾５４７', '072-480-2850', 1, 'http://www.chojukai.or.jp'),
(130, '特別養護老人ホーム・ピープルハウス忠岡', '大阪府', 27, '泉北郡忠岡町高月北１丁目１１－３', '0725-46-3333', 1, 'http://www.koseikai.org'),
(131, 'しぎの黄金の里特別養護老人ホーム', '大阪府', 27, '大阪市城東区鴫野東２丁目２６－１２', '06-6963-5551', 1, 'http://www.kogane.or.jp'),
(132, '（株）アクターリアリティー', '大阪府', 27, '大阪市都島区東野田町２丁目９－７', '06-4800-0808', 1, 'http://www.aqtor.co.jp'),
(133, '花嵐・特別養護老人ホーム', '大阪府', 27, '大阪市東住吉区矢田６丁目８－７', '06-6699-8787', 1, 'http://www.fuk-fureai.com'),
(134, 'ハミングベル中道', '大阪府', 27, '大阪市東成区中道２丁目７－１', '06-6971-9788', 1, 'http://www.humming-bell.or.jp'),
(135, '特別養護老人ホーム喜連', '大阪府', 27, '大阪市平野区喜連２丁目２－４０', '06-6790-6666', 1, 'http://www.eijyu.or.jp'),
(136, 'ＹＭＣＡサンホーム', '大阪府', 27, '東大阪市御厨南３丁目１－１８', '06-6787-3733', 1, 'http://www.osakaymca.or.jp/shisetsu/sunhome/index.html'),
(137, '福寿苑', '大阪府', 27, '東大阪市出雲井本町３－２５', '072-985-7771', 1, 'http://www.kawahukukai.or.jp'),
(138, 'ロココ豊中', '大阪府', 27, '豊中市宝山町７－８', '06-6858-1060', 1, 'http://www.kouyukai.jp/'),
(139, '特別養護老人ホーム豊泉家北緑丘', '大阪府', 27, '豊中市北緑丘２丁目９－５', '06-6152-1233', 1, 'http://www.housenka.com'),
(140, '豊泉家／北緑丘／ショートステイ', '大阪府', 27, '豊中市北緑丘２丁目９－５', '06-6850-1272', 1, 'http://www.housenka.com'),
(141, '豊中グリーンヒル', '大阪府', 27, '豊中市緑丘３丁目３３０－２', '06-6845-6667', 1, 'http://www2.ocn.ne.jp/green-h'),
(142, 'あかつき特別養護老人ホーム', '大阪府', 27, '箕面市白島３丁目１６－１', '072-722-3438', 1, 'http://homepage3.nifty.com/akatuki-toku'),
(143, '白島荘特別養護老人ホーム', '大阪府', 27, '箕面市白島３丁目５－５０', '072-724-5511', 1, 'http://www.osj.or.jp/hakushima/index.html'),
(144, '社会福祉法人三養福祉会三養苑', '大阪府', 27, '門真市大字桑才２９４－５', '072-882-3333', 1, 'http://www11.ocn.ne.jp/~sanyouen/'),
(145, 'せいりょう園', '兵庫県', 28, '加古川市野口町長砂９５－２０', '079-421-7156', 1, 'http://seiryoen.kobe.fm'),
(146, '特別養護老人ホームサンホームみかづき', '兵庫県', 28, '佐用郡佐用町志文５１５', '0790-79-3145', 1, 'http://www.sunhome-cat.jp/'),
(147, '千種川リハビリテーションセンター', '兵庫県', 28, '佐用郡佐用町平福７８０', '0790-83-2001', 1, 'http://www.seifukai.or.jp'),
(148, 'ありがとう', '兵庫県', 28, '宍粟市山崎町東下野２７３－２', '0790-65-0790', 1, 'http://shoeikai.jp'),
(149, '篠山すみれ園', '兵庫県', 28, '篠山市今田町釜屋３５', '079-590-3111', 1, 'http://www.sasayama-sumire.com'),
(150, '特別養護老人ホーム神出シニアコミュニティ', '兵庫県', 28, '神戸市西区神出町南３６８－１１９', '078-965-3080', 1, 'http://www2s.biglobe.ne.jp/~mediaref/kande/'),
(151, '西神戸エルダーハウス', '兵庫県', 28, '神戸市西区平野町印路８８７－８', '078-961-5200', 1, 'http://www.yurinkai.or.jp/'),
(152, '特別養護老人ホームオリンピア', '兵庫県', 28, '神戸市中央区生田町１丁目２－３２', '078-221-7098', 1, 'http://www.osk.3web.ne.jp/~wataru8/'),
(153, '神戸老人ホーム', '兵庫県', 28, '神戸市東灘区住吉本町３丁目７－４１', '078-851-2560', 1, 'http://www5e.biglobe.ne.jp/~kobe-rh/'),
(154, '特別養護老人ホームおおぎの郷', '兵庫県', 28, '神戸市東灘区北青木１丁目１－３', '078-431-0001', 1, 'http://www.oogi.or.jp'),
(155, '大池サンホーム', '兵庫県', 28, '神戸市北区山田町上谷上ヤンゲン３', '078-581-0230', 1, 'http://www3.ocn.ne.jp/~osunhome/'),
(156, '特別養護老人ホームひまわり荘', '兵庫県', 28, '神崎郡市川町下牛尾６８０', '0790-27-0800', 1, 'http://www.himawarisou.or.jp'),
(157, '楽寿園', '兵庫県', 28, '西脇市前島町２６０－１', '0795-23-7700', 1, 'http://www.rakujuen.jp/'),
(158, 'ほうらいの里／特別養護老人ホーム', '兵庫県', 28, '赤穂郡上郡町中野１１１８－１', '0791-52-5900', 1, 'http://www10.ocn.ne.jp/~hohrai/'),
(159, '湯々館', '兵庫県', 28, '川西市西多田字平井田筋５', '072-793-2727', 1, 'http://www.toto-kan.org/'),
(160, 'あわじ荘', '兵庫県', 28, '淡路市野島貴船２２９－１', '0799-82-1950', 1, 'http://www.hwc.or.jp/awaji/'),
(161, '朝来市／あさがおホール', '兵庫県', 28, '朝来市新井１４８', '079-677-1901', 1, 'http://himawari-mission.com'),
(162, 'ステーションＲＯＮＤＯ', '兵庫県', 28, '朝来市和田山町安井８２０－１０', '079-670-6010', 1, 'http://www.himawari-mission.jp/'),
(163, 'あまの里特別養護老人ホーム', '兵庫県', 28, '尼崎市下坂部３丁目２－４０', '06-6495-4750', 1, 'http://www.shafuku-nijinokai.or.jp/'),
(164, 'ロータス・ガーデン', '兵庫県', 28, '尼崎市栗山町１丁目２０－２０', '06-6428-7111', 1, 'http://www.e-akane.com'),
(165, 'サンライフ御立／特別養護老人ホーム', '兵庫県', 28, '姫路市御立東５丁目１－１', '079-291-6666', 1, 'http://www.mcn2k.co.jp/pub/sasayuri/'),
(166, '特別養護老人ホームキャッシル真和', '兵庫県', 28, '姫路市山田町西山田７２６－１', '079-263-2325', 1, 'http://www.casil.or.jp/'),
(167, '特別養護老人ホームむれさき苑', '兵庫県', 28, '姫路市四郷町東阿保４４', '079-283-6861', 1, 'http://www.scs-lab.com/muresaki3/'),
(168, '白鳥園', '兵庫県', 28, '姫路市林田町久保１６１－２', '079-261-3939', 1, 'http://www10.ocn.ne.jp/~hakucho/'),
(169, '特別養護老人ホームしらさぎの里', '兵庫県', 28, '姫路市林田町山田３５１－３', '079-261-4088', 1, 'http://www2.117.ne.jp/~sirasato/'),
(170, '特別養護老人ホーム楽々むら', '兵庫県', 28, '豊岡市城崎町楽々浦４１９－１', '0796-32-0161', 1, 'http://www.amanoho.com/'),
(171, '特別養護老人ホームけやきホール', '兵庫県', 28, '豊岡市但東町太田６１４', '0796-56-1016', 1, 'http://himawari-mission.com'),
(172, '特別養護老人ホームたじま荘', '兵庫県', 28, '豊岡市日高町頃垣４１', '0796-44-1730', 1, 'http://www.hwc.or.jp/tajima/index.html'),
(173, '特別養護老人ホームとよおかの里', '兵庫県', 28, '豊岡市香住1272番地', '0796-29-5533', 1, 'http://shotokukai.jan-jan.net/toyoka/index.html'),
(174, '恵泉第２特別養護老人ホーム', '兵庫県', 28, '明石市大久保町大窪２８１３', '078-938-6933', 1, 'http://www.akashi-keisen.com'),
(175, '特別養護老人ホームペーパームーン', '兵庫県', 28, '明石市二見町西二見１６０１－１', '078-945-0701', 1, 'http://www.p-moon.or.jp'),
(176, 'ウェルフェア・グランデ明石', '兵庫県', 28, '明石市北王子町１３－４１', '078-929-2630', 1, 'http://www.wga.or.jp'),
(177, '宇治明星園白川／特別養護老人ホーム', '京都府', 26, '宇治市白川鍋倉山２２－１０', '0774-21-6055', 1, 'http://www.myoujyo.or.jp'),
(178, '亀岡友愛園', '京都府', 26, '亀岡市本梅町平松ナベ倉１１', '0771-26-2115', 1, 'http://www.yuaien.com'),
(179, '社会福祉法人南山福祉会つつきの郷', '京都府', 26, '京田辺市三山木西ノ河原４３－２', '0774-68-5155', 1, 'http://www.tsukinosato.or.jp'),
(180, '特別養護老人ホーム豊和園', '京都府', 26, '京都市右京区京北上中町宮ノ下２２', '0771-54-0314', 1, 'http://www4.ocn.ne.jp/~houwaen/'),
(181, '特別養護老人ホーム嵐山寮', '京都府', 26, '京都市右京区嵯峨天龍寺北造路町１７', '075-871-0032', 1, 'http://www2.ocn.ne.jp/~arashi55/'),
(182, '梅津富士園特別養護老人ホーム', '京都府', 26, '京都市右京区梅津尻溝町２８', '075-862-5100', 1, 'http://www5.ocn.ne.jp/~fujien'),
(183, '修徳特別養護老人ホーム', '京都府', 26, '京都市下京区新町通松原下る富永町１１０－１', '075-351-2181', 1, 'http://kyoto-fukushi.org'),
(184, '特別養護老人ホーム西七条', '京都府', 26, '京都市下京区西七条八幡町２９', '075-315-7067', 1, 'http://kyoto-fukushi.org'),
(185, '小川特別養護老人ホーム', '京都府', 26, '京都市上京区小川今出川下西入東今３７５', '075-415-8833', 1, 'http://kyoto-fukushi.org'),
(186, '壬生老人ホーム', '京都府', 26, '京都市中京区壬生梛ノ宮町２７', '075-801-1243', 1, 'http://www.joho-kyoto.or.jp/~mibuhome'),
(187, '塔南の園／特別養護老人ホーム', '京都府', 26, '京都市南区西九条菅田町４－２', '075-662-2731', 1, 'http://kyoto-fukushi.org'),
(188, 'そせい苑／特別養護老人ホーム', '京都府', 26, '京都市伏見区下鳥羽但馬町１５０', '075-605-1026', 1, 'http://www.soseikai.or.jp'),
(189, '同和園', '京都府', 26, '京都市伏見区醍醐上ノ山町１１', '075-571-0010', 1, 'http://www2.ocn.ne.jp/~dowaen/'),
(190, '特別養護老人ホーム紫野', '京都府', 26, '京都市北区紫野西野町１５', '075-494-3341', 1, 'http://kyoto-fukushi.org'),
(191, 'ユーカリの里', '京都府', 26, '京都市北区上賀茂ケシ山１－４３', '075-712-1120', 1, 'http://web.kyoto-inet.or.jp/people/koalamet'),
(192, '特別養護老人ホームグリーンプラザ博愛苑', '京都府', 26, '舞鶴市字市場３９０', '0773-65-3700', 1, 'http://www5.nkansai.ne.jp/org/hakuai/index.htm'),
(193, '六人部晴風特別養護老人ホーム', '京都府', 26, '福知山市字大内３１７３－１', '0773-20-2750', 1, 'http://www.kuushin.ecnet.jp'),
(194, '社会福祉法人八起会／特別養護老人ホームあぼし', '滋賀県', 25, '湖南市丸山４丁目５－１', '0748-77-0037', 1, 'http://www.biwa.ne.jp/~hachiki/'),
(195, '特別養護老人ホーム甲賀荘', '滋賀県', 25, '甲賀市甲賀町大原中９０４', '0748-88-5723', 1, 'http://www11.ocn.ne.jp/~kougakai/'),
(196, 'せせらぎ苑／特別養護老人ホーム', '滋賀県', 25, '甲賀市甲南町葛木８５５', '0748-86-1020', 1, 'http://www5.ocn.ne.jp/~seserag/'),
(197, 'エーデル土山', '滋賀県', 25, '甲賀市土山町北土山２０６２', '0748-66-1911', 1, 'http://www.edeltutiyama.com'),
(198, '特別養護老人ホーム清風荘', '滋賀県', 25, '高島市今津町南新保８７', '0740-22-1601', 1, 'http://www.biwa.ne.jp/~seifu/'),
(199, '特別養護老人ホーム近江舞子しょうぶ苑', '滋賀県', 25, '大津市南小松９０', '077-596-2233', 1, 'http://www.biwa.ne.jp/~syoubu/'),
(200, '介護老人福祉施設もみじ', '滋賀県', 25, '東近江市永源寺高野町４３１－２', '0748-27-2031', 1, 'http://www.biwa.ne.jp/~hachiki/'),
(201, 'テンダーヒル御所／特別養護老人ホーム', '奈良県', 29, '御所市大字船路４１５', '0745-66-2500', 1, 'http://www.tender.or.jp'),
(202, '社会福祉法人明徳会', '奈良県', 29, '御所市大字船路４１５', '0745-66-2500', 1, 'http://www.tender.or.jp'),
(203, '国見苑', '奈良県', 29, '御所市大字柏原１５９４－１', '0745-63-1102', 1, 'http://www2.mahoroba.ne.jp/~kunimien/'),
(204, 'あまがし苑特別養護老人ホーム', '奈良県', 29, '高市郡明日香村大字栗原４２１－２', '0744-54-5454', 1, 'http://www4.ocn.ne.jp/~amagashi/'),
(205, 'デイサービスセンターあまがし苑', '奈良県', 29, '高市郡明日香村大字栗原４２１－２', '0744-54-5454', 1, 'http://www4.ocn.ne.jp/~amagashi/'),
(206, 'やすらぎの杜延寿', '奈良県', 29, '生駒市小瀬町１１００', '0743-76-2266', 1, 'http://www.baijyuso.or.jp'),
(207, 'ホームケアー生駒', '奈良県', 29, '生駒市門前町８－１６', '0743-71-6558', 1, 'http://www.homecare.co.jp/'),
(208, 'ふれあいの里総合相談センター', '奈良県', 29, '天理市中之庄町５１０－２', '0743-65-5141', 1, 'http://www.fureai-net.com'),
(209, 'グラニー・グランダ／グランダあやめ池・奈良', '奈良県', 29, '奈良市あやめ池南７丁目５５５－５４', '0742-52-9797', 1, 'http://www.shinkoukai.co.jp'),
(210, 'ならやま園', '奈良県', 29, '奈良市山陵町１０８５', '0742-41-8088', 1, 'http://www6.ocn.ne.jp/~narayama'),
(211, '美里園／特別養護老人ホーム', '和歌山県', 30, '海草郡紀美野町安井６－１', '073-495-3216', 1, 'http://www6.ocn.ne.jp/~misatoen/'),
(212, '特別養護老人ホーム愛の園', '和歌山県', 30, '西牟婁郡上富田町生馬３１６－５６', '0739-47-1234', 1, 'http://www.shinai.or.jp/'),
(213, '紀伊松風苑', '和歌山県', 30, '和歌山市園部１６６８', '073-455-3676', 1, 'http://www4.ocn.ne.jp/~shoufuu/'),
(214, 'ダスキンホームインステッド紀三井寺ステーション', '和歌山県', 30, '和歌山市三葛１３１－１', '0120-066488', 1, 'http://www.nihon-homeinstead.co.jp'),
(215, '社会福祉法人寿敬会／特別養護老人ホーム大日山荘', '和歌山県', 30, '和歌山市平尾６３４', '073-478-3437', 1, 'http://www.jukeikai.jp/'),
(216, '特別養護老人ホーム喜成会', '和歌山県', 30, '和歌山市北野１２８', '073-462-3033', 1, 'http://www.kiseikai-w.or.jp/'),
(217, '社会福祉法人寿敬会／大日山荘海のデイサービス', '和歌山県', 30, '和歌山市毛見１５１６', '073-448-0406', 1, 'http://www.jukeikai.jp/'),
(218, '特別養護老人ホーム安寿荘', '愛媛県', 38, '松山市安城寺町１６７３－１', '089-978-6910', 1, 'http://www8.ocn.ne.jp/~anju/'),
(219, '気高あすなろ', '鳥取県', 31, '鳥取市気高町八幡２６８', '0857-82-3971', 1, 'http://www.t-asunaro.or.jp/shi-03-down.htm'),
(220, 'ひまわり園／特別養護老人ホーム', '島根県', 32, '出雲市神西沖町２４７９－６', '0853-43-2633', 1, 'http://www.w-himawari.or.jp'),
(221, '長命園特別養護老人ホーム', '島根県', 32, '松江市上乃木１０丁目５－２', '0852-27-3884', 1, 'http://fish.miracle.ne.jp/tyoumei'),
(222, '川本町役場／特別養護老人ホームみどりの里やすらぎ荘', '島根県', 32, '邑智郡川本町大字因原５７０－１', '0855-72-3517', 1, 'http://www.kawamoto-town.jp/'),
(223, '足守荘／特別養護老人ホーム', '岡山県', 33, '岡山市下足守１８９８', '086-295-1800', 1, 'http://www.okayama-ikiiki-shiawase.net/shisetu/ashimorisou/'),
(224, '社会福祉法人旭川荘／事務局', '岡山県', 33, '岡山市祇園地先', '086-275-0131', 1, 'http://www.asahigawasou.or.jp'),
(225, '健生園／特別養護老人ホーム', '岡山県', 33, '岡山市吉原２３１', '086-943-1701', 1, 'http://www16.ocn.ne.jp/~kensei/sisetu.htm'),
(226, 'グループホーム西大寺あゆみホーム', '岡山県', 33, '岡山市西大寺南２丁目９－３５', '086-943-7593', 1, 'http://www.h5.dion.ne.jp/~ayu.kame/'),
(227, '特別養護老人ホーム旭ヶ丘', '岡山県', 33, '岡山市万成東町２－２８', '086-252-5050', 1, 'http://www1.ocn.ne.jp/~junfuku/l/l_13/index13.html'),
(228, '特別養護老人ホーム誠和園', '広島県', 34, '安芸郡熊野町城之堀７７９０－１', '082-854-0421', 1, 'http://www.wsn.or.jp/'),
(229, '和楽荘／特別養護老人ホーム', '広島県', 34, '広島市安佐南区沼田町大字伴１４３２－１', '082-848-5000', 1, 'http://www.warakusou.or.jp'),
(230, '三篠園特別養護老人ホーム', '広島県', 34, '広島市安佐北区白木町大字井原１２４４', '082-828-3330', 1, 'http://www.misasakai.or.jp/misasaen/'),
(231, '特別養護老人ホーム神田山長生園', '広島県', 34, '広島市東区牛田新町１丁目１８－１', '082-228-9231', 1, 'http://www.tyoseien.jp/'),
(232, 'ひうな荘特別養護老人ホーム', '広島県', 34, '広島市南区日宇那町３０－１', '082-256-1001', 1, 'http://www.misasakai.or.jp/hiunasou/'),
(233, '特別養護老人ホームこじか荘', '広島県', 34, '三次市吉舎町敷地６８－５', '0824-43-3117', 1, 'http://www15.ocn.ne.jp/~kojikaso/'),
(234, '油木デイサービスセンター', '広島県', 34, '神石郡神石高原町油木甲５０７１－１', '0847-82-2277', 1, 'http://www.alice.or.jp/index.html'),
(235, '新生園', '広島県', 34, '東広島市八本松町原１１１７１－１', '082-429-0350', 1, 'http://www.aoikai.jp/shisetu/shinseien/'),
(236, '特別養護老人ホームふれあい', '広島県', 34, '尾道市御調町高尾１３４８－６', '0848-76-2415', 1, 'http://www.town.mitsugi.hiroshima.jp/'),
(237, '特別養護老人ホーム・サンサンホーム', '広島県', 34, '福山市神辺町字東中条６１０－１６', '084-967-1033', 1, 'http://ww3.enjoy.ne.jp/~sansan/index.html'),
(238, '社会福祉法人春海会／特別養護老人ホームエクセル鞆の浦', '広島県', 34, '福山市田尻町４１１５', '084-983-5888', 1, 'http://www.harumikai.jp'),
(239, '神原苑', '山口県', 35, '宇部市神原町２丁目１－２２', '0836-34-2885', 1, 'http://www11.ocn.ne.jp/~kamihara/'),
(240, 'アイユウの苑', '山口県', 35, '下関市彦島迫町３丁目１７－２', '0832-66-8287', 1, 'http://www.shoubikai.or.jp'),
(241, '光富士白苑／特別養護老人ホーム', '山口県', 35, '光市虹ケ浜２丁目５－７', '0833-71-3090', 1, 'http://fujishiroen.web.infoseek.co.jp/'),
(242, '防府あかり園特別養護老人ホーム', '山口県', 35, '防府市大字台道１６５５', '0835-32-0730', 1, 'http://www.hakuaikai-yamaguchi.jp/'),
(243, '特別養護老人ホームケアポート玄海', '福岡県', 40, '宗像市神湊１１８－２', '0940-62-4312', 1, 'http://www.aso-group.co.jp/genkai/'),
(244, 'かすがの郷', '福岡県', 40, '春日市塚原台３丁目１２９', '092-595-6060', 1, 'http://www.otogane.or.jp/'),
(245, '栄光会／ケアプランサービス', '福岡県', 40, '糟屋郡志免町大字別府７２３', '092-935-0147', 1, 'http://www.eikoh.or.jp/'),
(246, '特別養護老人ホーム大川荘', '福岡県', 40, '大川市大字大野島８５７', '0944-89-2500', 1, 'http://nttbj.itp.ne.jp/0944892500/'),
(247, '特別養護老人ホーム桜の丘', '福岡県', 40, '筑後市大字西牟田６３６５－８', '0942-53-7747', 1, 'http://www.sakuranooka.gr.jp'),
(248, 'リハモール福岡', '福岡県', 40, '福岡市西区野方７丁目７８０', '092-812-3811', 1, 'http://www18.ocn.ne.jp/~rmf/'),
(249, '特別養護老人ホーム梅光園', '福岡県', 40, '福岡市中央区梅光園３丁目４－１', '092-737-3223', 1, 'http://www.tenjyukai.com'),
(250, '梅光園／特別養護老人ホーム梅光園', '福岡県', 40, '福岡市中央区梅光園３丁目４－１', '092-737-3223', 1, 'http://www.tenjyukai.com'),
(251, '介護老人福祉施設春吉園', '福岡県', 40, '北九州市小倉南区大字春吉４６３－１', '093-452-1351', 1, 'http://nttbj.itp.ne.jp/0934521351'),
(252, '特別養護老人ホーム双葉苑', '福岡県', 40, '北九州市小倉南区長行東３丁目１３－１７', '093-451-5865', 1, 'http://www.futaba-kai.or.jp'),
(253, '薫会北九州シティホーム', '福岡県', 40, '北九州市小倉北区萩崎町１－３２', '093-952-1188', 1, 'http://www3.ocn.ne.jp/~kaorukai/'),
(254, '特別養護老人ホーム桜の園', '佐賀県', 41, '杵島郡白石町大字福富下分２３８７－３', '0952-87-3939', 1, 'http://www4.ocn.ne.jp/~reifukai/'),
(255, 'シオンの園／特別養護老人ホーム', '佐賀県', 41, '佐賀市大和町大字久留間３８６５－１', '0952-62-5566', 1, 'http://www2.saganet.ne.jp/zion/'),
(256, '真心の園／特別養護老人ホーム', '佐賀県', 41, '鳥栖市平田町３１０６－２３', '0942-82-2301', 1, 'http://www.magokoro.or.jp'),
(257, 'ゆうゆうの里', '長崎県', 42, '五島市玉之浦町玉之浦１３７１－１', '0959-75-6023', 1, 'http://www.u-u-sato.com'),
(258, '特別養護老人ホームサンフラワー', '長崎県', 42, '佐世保市吉井町直谷３６８－６', '0956-64-4516', 1, 'http://park3.wakwak.com/~sunflower/'),
(259, '白寿荘', '長崎県', 42, '佐世保市鹿子前町９０４－１', '0956-28-1181', 1, 'http://www.hakuzyusou.or.jp/'),
(260, '特別養護老人ホーム虹の里', '長崎県', 42, '北松浦郡佐々町八口免８０５－３', '0956-41-1213', 1, 'http://nttbj.itp.ne.jp/0956411213'),
(261, '天恵荘／デイサービスセンター和心園', '長崎県', 42, '諫早市有喜町５３７－１', '0957-28-0505', 1, 'http://tenkeiso.blog71.fc2.com/'),
(262, '特別養護老人ホームしらぬい荘', '熊本県', 43, '宇城市松橋町竹崎１１４２－１', '0964-32-0709', 1, 'http://www.shiranuiso.or.jp/'),
(263, '（株）かおり（雅音里）', '熊本県', 43, '菊池郡菊陽町光の森５丁目２０－１１－２', '096-213-5055', 1, 'http://www.hikarinomori.jp/'),
(264, '特別養護老人ホームリバーサイド熊本', '熊本県', 43, '熊本市河内町野出１９３６－１', '096-277-2288', 1, 'http://www.river-tensui.or.jp'),
(265, 'みゆきの里', '熊本県', 43, '熊本市御幸笛田６丁目７－４０', '096-378-1166', 1, 'http://www.miyukinosato.or.jp'),
(266, '介護老人保健施設ぼたん園', '熊本県', 43, '熊本市御幸笛田６丁目８－１', '096-370-1222', 1, 'http://www.miyukinosato.or.jp'),
(267, '天望庵／特別養護老人ホーム', '熊本県', 43, '熊本市龍田陳内１丁目３－３０', '096-339-7111', 1, 'http://www.jiyukai.net'),
(268, 'みやび園特別養護老人ホーム', '熊本県', 43, '八代市高島町４２２１', '0965-32-0088', 1, 'http://www.miyabien.jp'),
(269, '特別養護老人ホーム四季の郷', '大分県', 44, '臼杵市大字江無田１１１９－５', '0972-64-0177', 1, 'http://www.i-mizuho.net'),
(270, '特別養護老人ホーム鈴鳴荘', '大分県', 44, '国東市安岐町下山口５８', '0978-67-2626', 1, 'http://www.oct-net.jp/~reimeyso'),
(271, '特別養護老人ホーム光明園', '大分県', 44, '大分市大字志生木３５０２－１３', '097-574-0634', 1, 'http://www.koumyouen.or.jp'),
(272, 'いずみの園', '大分県', 44, '中津市大字永添２７４４', '0979-23-1616', 1, 'http://www.izuminosono.jp/'),
(273, '別府ナーシングホーム泰生園', '大分県', 44, '別府市大字鶴見１０６８－１', '0977-66-9988', 1, 'http://www.wellb.or.jp/'),
(274, '特別養護老人ホーム情和園', '大分県', 44, '由布市庄内町西長宝８７０－１', '097-582-0427', 1, 'http://www.okk.or.jp/shisetsu_01.html'),
(275, '小松の里／特別養護老人ホーム', '鹿児島県', 46, '志布志市有明町野井倉２００６－１', '099-474-0808', 1, 'http://www13.synapse.ne.jp/komatu/'),
(276, '悠々総合福祉施設／特別養護老人ホーム', '鹿児島県', 46, '鹿屋市大浦町１４０２８－６', '0994-42-0808', 1, 'http://www5.synapse.ne.jp/inouebyouin'),
(277, 'ひまわり園', '鹿児島県', 46, '鹿児島市犬迫町５４０７－２', '099-238-2140', 1, 'http://www.himawarien.jp'),
(278, '（有）ライフサポート', '鹿児島県', 46, '鹿児島市唐湊４丁目１－２－１Ｆ', '099-250-0611', 1, 'http://www.tanpoponosato.jp'),
(279, '済生会鹿児島地域福祉センター／特別養護老人ホーム高喜苑', '鹿児島県', 46, '鹿児島市武岡５丁目５１－１０', '099-284-8250', 1, 'http://www.synapse.ne.jp/~saiseikai-kg/saisei/'),
(280, '日本赤十字社鹿児島県支部特別養護老人ホーム錦江園', '鹿児島県', 46, '鹿児島市平川町２５３０－１', '099-261-2789', 1, 'http://www.minc.ne.jp/nisseki/kinkoen/kinkoen.htm'),
(281, '回生園特別養護老人ホーム', '鹿児島県', 46, '曽於郡大崎町菱田３０６３', '099-477-0372', 1, 'http://www.synapse.ne.jp/%7ekaiseien/'),
(282, 'おおすみ竹山園', '鹿児島県', 46, '曽於市大隅町月野１５８２', '099-482-4100', 1, 'http://www.h2.dion.ne.jp/~osumikai'),
(283, '牧之原むつみ園／特別養護老人ホーム', '鹿児島県', 46, '霧島市福山町福山５２９０－３０', '0995-56-2234', 1, 'http://www.mutumi-en.com'),
(284, '谷茶の丘', '沖縄県', 47, '国頭郡恩納村字谷茶１９１９', '098-966-2323', 1, 'http://www.yuunanokai.or.jp/'),
(285, '特別養護老人ホーム大名', '沖縄県', 47, '那覇市首里大名町１丁目４３－２', '098-886-5070', 1, 'http://www.yuunanokai.or.jp'),
(286, '特別養護老人ホームしらゆりの園', '沖縄県', 47, '南城市知念字久手堅２７５－１', '098-948-7060', 1, 'http://www.h3.dion.ne.jp/~sirayuri/'),
(287, '南風見苑', '沖縄県', 47, '八重山郡竹富町字上原８７０－２３７', '0980-85-6911', 1, 'http://www6.ocn.ne.jp/~haemien/'),
(288, 'おもととよみの杜／特別養護老人ホームすみれ', '沖縄県', 47, '豊見城市字渡嘉敷１５０－３３', '098-851-0101', 1, 'http://www.omotokai.or.jp/sumire/');
