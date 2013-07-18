/*
 * shingaku.ui.js - UI library for リクルート進学ネット Web Service
 * AUTHOR: Toshimasa Ishibashi iandeth [at] gmail.com
 * VERSION: 1.00
 */

// everything wrapped in jQuery -
// same effect as jQuery.noConflict() for use with prototype.js
(function($){

if( typeof( Shingaku ) != 'function' ) {
    Shingaku = function (){};
}
if( typeof( Shingaku.UI ) != 'function' ) {
    Shingaku.UI = function (){};
}

/*
 * Shingaku.UI.Pref.Pulldown - エリア選択プルダウン
 * VERSION 1.00
 * CHANGES
 *   2008-02-27 v1.00 released
 */
if( typeof( Shingaku.UI.Pref ) != 'function' ) {
    Shingaku.UI.Pref = function (){};
}
Shingaku.UI.Pref.Pulldown =
Class.create( Recruit.UI.Base.Pulldown.JSONP, {
    _get_def_props: function (){
        return {
            id         : 'shin-pref-sel',
            name       : 'pref_cd',
            label      : 'エリア',
            has_parent : false
        };
    },
    _get_driver: function (){
        return new Recruit.UI.Driver.JSONP({
            url : '/shingaku/pref/v1/'
        });
    },
    _get_selections_material: function (){
        return this.driver.results.pref;
    }
});

/*
 * Shingaku.UI.Category.Pulldown - カテゴリ選択プルダウン
 * VERSION 1.00
 * CHANGES
 *   2008-02-27 v1.00 released
 */
if( typeof( Shingaku.UI.Category ) != 'function' ) {
    Shingaku.UI.Category = function (){};
}
var Category_skeleton = {
    _get_def_props: function (){
        return {
            id         : 'shin-category-sel',
            name       : 'category_cd',
            label      : 'カテゴリ',
            has_parent : false
        };
    },
    _get_driver: function (){
        return new Recruit.UI.Driver.JSONP({
            url : '/shingaku/category/v1/'
        });
    },
    _get_selections_material: function (){
        return this.driver.results.category;
    }
};
Shingaku.UI.Category.Pulldown =
Class.create( Recruit.UI.Base.Pulldown.JSONP, Category_skeleton );

/*
 * Shingaku.UI.Category.Checkbox - カテゴリ選択チェックボックス
 * VERSION 1.00
 * CHANGES
 *   2008-02-27 v1.00 released
 */
Shingaku.UI.Category.Checkbox =
Class.create( Recruit.UI.Base.Checkbox.JSONP,
    $.extend( Category_skeleton, {
        _get_def_props: function (){
            return {
                id       : 'shin-category-checkbox',
                name     : 'category_cd',
                label    : 'カテゴリ',
                template : 'horizontal'
            };
        }
    })
);

/*
 * Shingaku.UI.Order.Pulldown - 並び順プルダウン
 * VERSION 1.00
 * CHANGES
 *   2008-02-27 v1.00 released
 */
if( typeof( Shingaku.UI.Order ) != 'function' ) {
    Shingaku.UI.Order = function (){};
}
Shingaku.UI.Order.Pulldown =
Class.create( Recruit.UI.Base.Pulldown, {
    _get_def_props: function (){
        return {
            id             : 'shin-order-sel',
            name           : 'order',
            label          : '並び順',
            first_opt_text : 'オススメ順'
        };
    },
    get_selections: function (){
        return {
            "2": "エリア順",
            "3": "学校名五十音順"
        };
    }
});

// end of jQuery no-conflict wrapper
})(jQuery);
