/*
 * akasugu.ui.js - UI library for 赤すぐnet Web Service
 * AUTHOR: Toshimasa Ishibashi iandeth [at] gmail.com
 * VERSION: 1.00
 */

// everything wrapped in jQuery -
// same effect as jQuery.noConflict() for use with prototype.js
(function($){

if( typeof( Akasugu ) != 'function' ) {
    Akasugu = function (){};
}
if( typeof( Akasugu.UI ) != 'function' ) {
    Akasugu.UI = function (){};
}

/*
 * Akasugu.UI.Category.Pulldown - カテゴリ選択 プルダウン
 * VERSION 1.01
 * CHANGES
 *   2008-03-26 v1.01 Recruit.UI.Base.Hierarchy 利用に変更
 *   2008-02-29 v1.00 released
 */
if( typeof( Akasugu.UI.Category ) != 'function' ) {
    Akasugu.UI.Category = function (){};
}
Akasugu.UI.Category.Pulldown =
Class.create( Recruit.UI.Base.Hierarchy, {
    _get_definition : function (){
        var ret = [
            { cls: Akasugu.UI.LargeCategory.Pulldown  },
            { cls: Akasugu.UI.MiddleCategory.Pulldown },
            { cls: Akasugu.UI.SmallCategory.Pulldown  }
        ];
        return ret;
    }
});
/*
 * Akasugu.UI.LargeCategory.Pulldown
 */
if( typeof( Akasugu.UI.LargeCategory ) != 'function' ) {
    Akasugu.UI.LargeCategory = function (){};
}
Akasugu.UI.LargeCategory.Pulldown =
Class.create( Recruit.UI.Base.Pulldown.JSONP, {
    get_selections: function (){
        var ret = {};
        var arr = this._get_selections_material();
        $.each( arr, function (i,d){
            ret[ d.code ] = d.name;
        });
        return ret;
    },
    _get_def_props: function (){
        return {
            id    : 'aka-large-category-sel',
            name  : 'large_category',
            label : '大カテゴリ'
        };
    },
    _get_driver: function (){
        return new Recruit.UI.Driver.JSONP({
            url : '/akasugu/large_category/v1/'
        });
    },
    _get_selections_material: function (){
        return this.driver.results.large_category;
    }
});
/*
 * Akasugu.UI.MiddleCategory.Pulldown
 */
if( typeof( Akasugu.UI.MiddleCategory ) != 'function' ) {
    Akasugu.UI.MiddleCategory = function (){};
}
Akasugu.UI.MiddleCategory.Pulldown =
Class.create( Akasugu.UI.LargeCategory.Pulldown, {
    _get_def_props: function (){
        return {
            id         : 'aka-middle-category-sel',
            name       : 'middle_category',
            label      : '中カテゴリ',
            has_parent : true,
            parent     : 'large_category',
            large_category : ''
        };
    },
    _get_driver: function (){
        return new Recruit.UI.Driver.JSONP({
            url : '/akasugu/middle_category/v1/'
        });
    },
    _get_selections_material: function (){
        return this.driver.results.middle_category;
    }
});
/*
 * Akasugu.UI.SmallCategory.Pulldown
 */
if( typeof( Akasugu.UI.SmallCategory ) != 'function' ) {
    Akasugu.UI.SmallCategory = function (){};
}
Akasugu.UI.SmallCategory.Pulldown =
Class.create( Akasugu.UI.LargeCategory.Pulldown, {
    _get_def_props: function (){
        return {
            id         : 'aka-small-category-sel',
            name       : 'small_category',
            label      : '小カテゴリ',
            has_parent : true,
            parent     : 'middle_category',
            middle_category : ''
        };
    },
    _get_driver: function (){
        return new Recruit.UI.Driver.JSONP({
            url : '/akasugu/small_category/v1/'
        });
    },
    _get_selections_material: function (){
        return this.driver.results.small_category;
    }
});

/*
 * Akasugu.UI.Age.Pulldown - 対象月齢選択プルダウン
 * VERSION 1.00
 * CHANGES
 *   2008-03-01 v1.00 released
 */
if( typeof( Akasugu.UI.Age ) != 'function' ) {
    Akasugu.UI.Age = function (){};
}
Akasugu.UI.Age.Pulldown =
Class.create( Recruit.UI.Base.Pulldown.JSONP, {
    _get_def_props: function (){
        return {
            id    : 'aka-age-sel',
            name  : 'age',
            label : '対象月例'
        };
    },
    _get_driver: function (){
        return new Recruit.UI.Driver.JSONP({
            url : '/akasugu/age/v1/'
        });
    },
    _get_selections_material: function (){
        return this.driver.results.age;
    }
});

/*
 * Akasugu.UI.Price.Pulldown - 価格帯プルダウン
 * VERSION 1.00
 * CHANGES
 *   2008-03-01 v1.00 released
 */
if( typeof( Akasugu.UI.Price ) != 'function' ) {
    Akasugu.UI.Price = function (){};
}
/*
 * Akasugu.UI.Price.Pulldown
 *   - initialize both Akasugu.UI.Price.[Max|Min].Pulldown at once.
 */
Akasugu.UI.Price.Pulldown = Class.create({
    initialize: function ( arg ){
        arg = $.extend({
            'max' : undefined,
            'min' : undefined
        }, arg );
        var tgt = {
            'max' : Akasugu.UI.Price.Max.Pulldown,
            'min' : Akasugu.UI.Price.Min.Pulldown
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
 * Akasugu.UI.Price.Max.Pulldown
 */
var price_pattern = [
    0.5,1,2,3,4,5,6,7,8,9,10,15,20,25,30,40,50
];
var price_create_list = function ( type ){
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
Akasugu.UI.Price.Max = function (){};
Akasugu.UI.Price.Max.Pulldown =
Class.create( Recruit.UI.Base.Pulldown, {
    prices: price_pattern,
    _get_def_props: function (){
        return {
            id    : 'aka-price-max-sel',
            name  : 'price_max',
            label : '最高価格'
        };
    },
    get_selections: function (){
        return price_create_list( 'max' );
    }
});

/*
 * Akasugu.UI.Price.Min.Pulldown
 */
Akasugu.UI.Price.Min = function (){};
Akasugu.UI.Price.Min.Pulldown =
Class.create( Recruit.UI.Base.Pulldown, {
    prices: price_pattern,
    _get_def_props: function (){
        return {
            id             : 'aka-price-min-sel',
            name           : 'price_min',
            label          : '最低価格'
        };
    },
    get_selections: function (){
        return price_create_list( 'min' );
    }
});

/*
 * Akasugu.UI.Order.Pulldown - 並び順プルダウン
 * VERSION 1.00
 * CHANGES
 *   2008-02-28 v1.00 released
 */
if( typeof( Akasugu.UI.Order ) != 'function' ) {
    Akasugu.UI.Order = function (){};
}
Akasugu.UI.Order.Pulldown =
Class.create( Recruit.UI.Base.Pulldown, {
    _get_def_props: function (){
        return {
            id             : 'aka-order-sel',
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
