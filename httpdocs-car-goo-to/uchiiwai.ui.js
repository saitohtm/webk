/*
 * uchiiwai.ui.js - UI library for 赤すぐ内祝い Web Service
 * AUTHOR: Toshimasa Ishibashi iandeth [at] gmail.com
 * VERSION: 1.00
 */

// everything wrapped in jQuery -
// same effect as jQuery.noConflict() for use with prototype.js
(function($){

if( typeof( Uchiiwai ) != 'function' ) {
    Uchiiwai = function (){};
}
if( typeof( Uchiiwai.UI ) != 'function' ) {
    Uchiiwai.UI = function (){};
}

/*
 * Uchiiwai.UI.Category.Pulldown - カテゴリ選択プルダウン
 * VERSION 1.00
 * CHANGES
 *   2008-03-01 v1.00 released
 */
if( typeof( Uchiiwai.UI.Category ) != 'function' ) {
    Uchiiwai.UI.Category = function (){};
}
Uchiiwai.UI.Category.Pulldown =
Class.create( Recruit.UI.Base.Pulldown.JSONP, {
    _get_def_props: function (){
        return {
            id    : 'uchi-category-sel',
            name  : 'category',
            label : 'カテゴリ'
        };
    },
    _get_driver: function (){
        return new Recruit.UI.Driver.JSONP({
            url : '/uchiiwai/category/v1/'
        });
    },
    _get_selections_material: function (){
        return this.driver.results.category;
    }
});

/*
 * Uchiiwai.UI.Target.Pulldown - あげる人選択プルダウン
 * VERSION 1.00
 * CHANGES
 *   2008-03-01 v1.00 released
 */
if( typeof( Uchiiwai.UI.Target ) != 'function' ) {
    Uchiiwai.UI.Target = function (){};
}
Uchiiwai.UI.Target.Pulldown =
Class.create( Recruit.UI.Base.Pulldown.JSONP, {
    _get_def_props: function (){
        return {
            id    : 'uchi-target-sel',
            name  : 'target',
            label : 'あげる人'
        };
    },
    _get_driver: function (){
        return new Recruit.UI.Driver.JSONP({
            url : '/uchiiwai/target/v1/'
        });
    },
    _get_selections_material: function (){
        return this.driver.results.target;
    }
});

/*
 * Uchiiwai.UI.Feature.Pulldown - あげる人選択プルダウン
 * VERSION 1.00
 * CHANGES
 *   2008-03-01 v1.00 released
 */
if( typeof( Uchiiwai.UI.Feature ) != 'function' ) {
    Uchiiwai.UI.Feature = function (){};
}
Uchiiwai.UI.Feature.Pulldown =
Class.create( Recruit.UI.Base.Pulldown.JSONP, {
    _get_def_props: function (){
        return {
            id    : 'uchi-feature-sel',
            name  : 'feature',
            label : '特集'
        };
    },
    _get_driver: function (){
        return new Recruit.UI.Driver.JSONP({
            url : '/uchiiwai/feature/v1/'
        });
    },
    _get_selections_material: function (){
        return this.driver.results.feature;
    }
});

/*
 * Uchiiwai.UI.Price.Pulldown - 価格帯プルダウン
 * VERSION 1.00
 * CHANGES
 *   2008-03-01 v1.00 released
 */
if( typeof( Uchiiwai.UI.Price ) != 'function' ) {
    Uchiiwai.UI.Price = function (){};
}
/*
 * Uchiiwai.UI.Price.Pulldown
 *   - initialize both Uchiiwai.UI.Price.[Max|Min].Pulldown at once.
 */
Uchiiwai.UI.Price.Pulldown = Class.create({
    initialize: function ( arg ){
        arg = $.extend({
            'max' : undefined,
            'min' : undefined
        }, arg );
        var tgt = {
            'max' : Uchiiwai.UI.Price.Max.Pulldown,
            'min' : Uchiiwai.UI.Price.Min.Pulldown
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
 * Uchiiwai.UI.Price.Max.Pulldown
 */
var price_pattern = [
    1,2,3,4,5,6,7,8,9,10,15,20,25,30
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
Uchiiwai.UI.Price.Max = function (){};
Uchiiwai.UI.Price.Max.Pulldown =
Class.create( Recruit.UI.Base.Pulldown, {
    prices: price_pattern,
    _get_def_props: function (){
        return {
            id    : 'uchi-price-max-sel',
            name  : 'price_max',
            label : '最高価格'
        };
    },
    get_selections: function (){
        return price_create_list( 'max' );
    }
});

/*
 * Uchiiwai.UI.Price.Min.Pulldown
 */
Uchiiwai.UI.Price.Min = function (){};
Uchiiwai.UI.Price.Min.Pulldown =
Class.create( Recruit.UI.Base.Pulldown, {
    prices: price_pattern,
    _get_def_props: function (){
        return {
            id             : 'uchi-price-min-sel',
            name           : 'price_min',
            label          : '最低価格'
        };
    },
    get_selections: function (){
        return price_create_list( 'min' );
    }
});

/*
 * Uchiiwai.UI.Order.Pulldown - 並び順プルダウン
 * VERSION 1.00
 * CHANGES
 *   2008-02-28 v1.00 released
 */
if( typeof( Uchiiwai.UI.Order ) != 'function' ) {
    Uchiiwai.UI.Order = function (){};
}
Uchiiwai.UI.Order.Pulldown =
Class.create( Recruit.UI.Base.Pulldown, {
    _get_def_props: function (){
        return {
            id             : 'uchi-order-sel',
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
