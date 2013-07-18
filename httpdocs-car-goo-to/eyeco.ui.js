/*
 * eyeco.ui.js - UI library for eyeco Web Service
 * AUTHOR: Toshimasa Ishibashi iandeth [at] gmail.com
 * VERSION: 1.00
 */

// everything wrapped in jQuery -
// same effect as jQuery.noConflict() for use with prototype.js
(function($){

if( typeof( Eyeco ) != 'function' ) {
    Eyeco = function (){};
}
if( typeof( Eyeco.UI ) != 'function' ) {
    Eyeco.UI = function (){};
}

/*
 * Eyeco.UI.Price.Pulldown - 価格帯プルダウン
 * VERSION 1.00
 * CHANGES
 *   2008-02-28 v1.00 released
 */
if( typeof( Eyeco.UI.Price ) != 'function' ) {
    Eyeco.UI.Price = function (){};
}
/*
 * Eyeco.UI.Price.Pulldown
 *   - initialize both Eyeco.UI.Price.[Max|Min].Pulldown at once.
 */
Eyeco.UI.Price.Pulldown = Class.create({
    initialize: function ( arg ){
        arg = $.extend({
            'max' : undefined,
            'min' : undefined
        }, arg );
        var tgt = {
            'max' : Eyeco.UI.Price.Max.Pulldown,
            'min' : Eyeco.UI.Price.Min.Pulldown
        };
        this.instances = {};
        var _self = this;
        $.each( tgt, function (k,v){
            var d = v.prototype._get_def_props();
            d = $.extend( d, arg[ k ] );
            var elem_id = d.id;
            if( $( '#' + elem_id ).length > 0 ){
                _self.instances[ k ] = new v( arg[ k ] );
            }
        });
    }
});
/*
 * Eyeco.UI.Price.Max.Pulldown
 */
var price_pattern = [
    0.5,1,2,3,4,5,6,7,8,9,10,15,20,25,30,40,50
];
var Price_create_list = function ( type ){
    if( !type ){ type = 'min' }
    var h = {};
    $.each( price_pattern, function (i,v){
        var key = v * 1000;
        var str = key;
        str = Recruit.UI.to_comma( str );
        str += '円';
        var val = '';
        if( type == 'max' ){ val = str + ' 以内' }
        else               { val = str + ' 以上' }
        h[ key ] = val;
    });
    return h;
};
Eyeco.UI.Price.Max = function (){};
Eyeco.UI.Price.Max.Pulldown =
Class.create( Recruit.UI.Base.Pulldown, {
    prices: price_pattern,
    _get_def_props: function (){
        return {
            id    : 'eye-price-max-sel',
            name  : 'price_max',
            label : '最高価格'
        };
    },
    get_selections: function (){
        return Price_create_list( 'max' );
    }
});

/*
 * Eyeco.UI.Price.Min.Pulldown
 */
Eyeco.UI.Price.Min = function (){};
Eyeco.UI.Price.Min.Pulldown =
Class.create( Recruit.UI.Base.Pulldown, {
    prices: price_pattern,
    _get_def_props: function (){
        return {
            id             : 'eye-price-min-sel',
            name           : 'price_min',
            label          : '最低価格'
        };
    },
    get_selections: function (){
        return Price_create_list( 'min' );
    }
});

/*
 * Eyeco.UI.Category.Pulldown - カテゴリ選択プルダウン
 * VERSION 1.01
 * CHANGES
 *   2008-03-26 v1.01 Recruit.UI.Base.Hierarchy 利用に変更
 *   2008-02-28 v1.00 released
 */
if( typeof( Eyeco.UI.Category ) != 'function' ) {
    Eyeco.UI.Category = function (){};
}
Eyeco.UI.Category.Pulldown =
Class.create( Recruit.UI.Base.Hierarchy, {
    _get_definition : function (){
        var ret = [
            { cls: Eyeco.UI.LargeCategory.Pulldown },
            { cls: Eyeco.UI.SmallCategory.Pulldown }
        ];
        return ret;
    }
});

/*
 * Eyeco.UI.LargeCategory.Pulldown - 大カテゴリ選択プルダウン
 * VERSION 1.00
 * CHANGES
 *   2008-02-28 v1.00 released
 */
if( typeof( Eyeco.UI.LargeCategory ) != 'function' ) {
    Eyeco.UI.LargeCategory = function (){};
}
Eyeco.UI.LargeCategory.Pulldown =
Class.create( Recruit.UI.Base.Pulldown.JSONP, {
    _get_def_props: function (){
        return {
            id    : 'eye-large-category-sel',
            name  : 'large_category',
            label : '大カテゴリ'
        };
    },
    _get_driver: function (){
        return new Recruit.UI.Driver.JSONP({
            url : '/eyeco/large_category/v1/'
        });
    },
    _get_selections_material: function (){
        return this.driver.results.large_category;
    }
});

/*
 * Eyeco.UI.SmallCategory.Pulldown - 小カテゴリ選択プルダウン
 * VERSION 1.00
 * CHANGES
 *   2008-02-28 v1.00 released
 */
if( typeof( Eyeco.UI.SmallCategory ) != 'function' ) {
    Eyeco.UI.SmallCategory = function (){};
}
Eyeco.UI.SmallCategory.Pulldown =
Class.create( Recruit.UI.Base.Pulldown.JSONP, {
    _get_def_props: function (){
        return {
            id    : 'eye-small-category-sel',
            name  : 'small_category',
            label : '小カテゴリ',
            has_parent     : true,
            parent         : 'large_category',
            large_category : ''
        };
    },
    _get_driver: function (){
        return new Recruit.UI.Driver.JSONP({
            url : '/eyeco/small_category/v1/'
        });
    },
    _get_selections_material: function (){
        return this.driver.results.small_category;
    }
});

/*
 * Eyeco.UI.Order.Pulldown - 並び順プルダウン
 * VERSION 1.00
 * CHANGES
 *   2008-02-28 v1.00 released
 */
if( typeof( Eyeco.UI.Order ) != 'function' ) {
    Eyeco.UI.Order = function (){};
}
Eyeco.UI.Order.Pulldown =
Class.create( Recruit.UI.Base.Pulldown, {
    _get_def_props: function (){
        return {
            id             : 'eye-order-sel',
            name           : 'order',
            label          : '並び順',
            first_opt_text : 'オススメ順'
        };
    },
    get_selections: function (){
        return {
            "1" : "価格安い順",
            "2" : "価格高い順",
            "3" : "商品名順"
        };
    }
});

// end of jQuery no-conflict wrapper
})(jQuery);
