<?php
/**
 * The base configurations of the WordPress.
 *
 * このファイルは、MySQL、テーブル接頭辞、秘密鍵、言語、ABSPATH の設定を含みます。
 * より詳しい情報は {@link http://wpdocs.sourceforge.jp/wp-config.php_%E3%81%AE%E7%B7%A8%E9%9B%86 
 * wp-config.php の編集} を参照してください。MySQL の設定情報はホスティング先より入手できます。
 *
 * このファイルはインストール時に wp-config.php 作成ウィザードが利用します。
 * ウィザードを介さず、このファイルを "wp-config.php" という名前でコピーして直接編集し値を
 * 入力してもかまいません。
 *
 * @package WordPress
 */

// 注意: 
// Windows の "メモ帳" でこのファイルを編集しないでください !
// 問題なく使えるテキストエディタ
// (http://wpdocs.sourceforge.jp/Codex:%E8%AB%87%E8%A9%B1%E5%AE%A4 参照)
// を使用し、必ず UTF-8 の BOM なし (UTF-8N) で保存してください。

// ** MySQL 設定 - こちらの情報はホスティング先から入手してください。 ** //
/** WordPress のためのデータベース名 */
define('DB_NAME', 'wordpress');

/** MySQL データベースのユーザー名 */
define('DB_USER', 'mysqlweb');

/** MySQL データベースのパスワード */
define('DB_PASSWORD', 'WaAoqzxe7h6yyHz');

/** MySQL のホスト名 */
define('DB_HOST', 'localhost');

/** データベースのテーブルを作成する際のデータベースのキャラクターセット */
define('DB_CHARSET', 'utf8');

/** データベースの照合順序 (ほとんどの場合変更する必要はありません) */
define('DB_COLLATE', '');

/**#@+
 * 認証用ユニークキー
 *
 * それぞれを異なるユニーク (一意) な文字列に変更してください。
 * {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org の秘密鍵サービス} で自動生成することもできます。
 * 後でいつでも変更して、既存のすべての cookie を無効にできます。これにより、すべてのユーザーを強制的に再ログインさせることになります。
 *
 * @since 2.6.0
 */
define('AUTH_KEY',         '+d?v96hJGjX<KRk-Jl/PPy_,79C/#^3O-Ql8J+Hs0ECq+v:?|C7zWUsL*H>fjVin');
define('SECURE_AUTH_KEY',  'm:LE+[695V+KzG3 jPt5EpF7t@+modBPB8&0y`WIz)(Rg+CJ$dx.Lmm8$|GB,a)3');
define('LOGGED_IN_KEY',    'BjE*r/f9Nt?^@wo)0e[qzy+tJjtgK4Z==sGR~ozvR2ZMHtdC6P8OSt|wo<FLw^B%');
define('NONCE_KEY',        '<:e7l^+tbQK15CQ.?};?<ug&EPTG8rE<-6[b[<8-j6AQUQF/ZB99o)>c+vas{c.g');
define('AUTH_SALT',        'jiT5tAuh_oNNte^-|@n*wU;Op|16HU|lmYVYkaQ?AzZt]>UhYb3M]9rMxO,0dCx(');
define('SECURE_AUTH_SALT', ' .u&l@>+ZO7$c/G)/lHTRWgqV<P<6|%bjB[R`[hJp-c`TN&jru;!bq-<l|BXBcrz');
define('LOGGED_IN_SALT',   '{ZP*uJbu.^1B(P-<>34n0aITkjH(vSN4yu`D]Cp]<}eYKcI>RafE|gW#~(gvV_$0');
define('NONCE_SALT',       '^P%PeOQp2wGF-P] CA.>e^0.<l01K(x{/{m-A~w_p^F;qGr)Ek44?Rk|40OwSo]]');

/**#@-*/

/**
 * WordPress データベーステーブルの接頭辞
 *
 * それぞれにユニーク (一意) な接頭辞を与えることで一つのデータベースに複数の WordPress を
 * インストールすることができます。半角英数字と下線のみを使用してください。
 */
$table_prefix  = 'wp_';

/**
 * ローカル言語 - このパッケージでは初期値として 'ja' (日本語 UTF-8) が設定されています。
 *
 * WordPress のローカル言語を設定します。設定した言語に対応する MO ファイルが
 * wp-content/languages にインストールされている必要があります。例えば de_DE.mo を
 * wp-content/languages にインストールし WPLANG を 'de_DE' に設定することでドイツ語がサポートされます。
 */
define('WPLANG', 'ja');

/**
 * 開発者へ: WordPress デバッグモード
 *
 * この値を true にすると、開発中に注意 (notice) を表示します。
 * テーマおよびプラグインの開発者には、その開発環境においてこの WP_DEBUG を使用することを強く推奨します。
 */
define('WP_DEBUG', false);

/* 編集が必要なのはここまでです ! WordPress でブログをお楽しみください。 */

/** Absolute path to the WordPress directory. */
if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');
