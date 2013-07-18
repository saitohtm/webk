/*
 * carsensor.ui.js - UI library for カーセンサー Web Service
 * AUTHOR: Toshimasa Ishibashi iandeth [at] gmail.com
 * VERSION: 1.00
 */

// everything wrapped in jQuery -
// same effect as jQuery.noConflict() for use with prototype.js
(function($){

if( typeof( CarSensor ) != 'function' ) {
    CarSensor = function (){};
}
if( typeof( CarSensor.UI ) != 'function' ) {
    CarSensor.UI = function (){};
}
if( typeof( CarSensor.UI.UsedCar ) != 'function' ) {
    CarSensor.UI.UsedCar = function (){};
}

/*
 * CarSensor.UI.CountryBrand.Pulldown - 国 x ブランド選択プルダウン
 * VERSION 1.01
 * CHANGES
 *   2008-03-26 v1.01 Recruit.UI.Base.Hierarchy 利用に変更
 *   2008-02-27 v1.00 released
 */
if( typeof( CarSensor.UI.CountryBrand ) != 'function' ) {
    CarSensor.UI.CountryBrand = function (){};
}
CarSensor.UI.CountryBrand.Pulldown =
Class.create( Recruit.UI.Base.Hierarchy, {
    _get_definition : function (){
        var ret = [
            { cls: CarSensor.UI.Country.Pulldown },
            { cls: CarSensor.UI.Brand.Pulldown   }
        ];
        return ret;
    }
});

/*
 * CarSensor.UI.Country.Pulldown - 国選択プルダウン
 * VERSION 1.00
 * CHANGES
 *   2008-02-27 v1.00 released
 */
if( typeof( CarSensor.UI.Country ) != 'function' ) {
    CarSensor.UI.Country = function (){};
}
CarSensor.UI.Country.Pulldown =
Class.create( Recruit.UI.Base.Pulldown.JSONP, {
    _get_def_props: function (){
        return {
            id    : 'car-country-sel',
            name  : 'country',
            label : '国'
        };
    },
    _get_driver: function (){
        return new Recruit.UI.Driver.JSONP({
            url : '/carsensor/country/v1/'
        });
    },
    _get_selections_material: function (){
        return this.driver.results.country;
    }
});

/*
 * CarSensor.UI.Brand.Pulldown - ブランド選択プルダウン
 * VERSION 1.00
 * CHANGES
 *   2008-02-27 v1.00 released
 */
if( typeof( CarSensor.UI.Brand ) != 'function' ) {
    CarSensor.UI.Brand = function (){};
}
CarSensor.UI.Brand.Pulldown =
Class.create( Recruit.UI.Base.Pulldown.JSONP, {
    _get_def_props: function (){
        return {
            id          : 'car-brand-sel',
            name        : 'brand',
            label       : 'ブランド',
            has_parent  : true,
            parent      : 'country',
            country     : ''
        };
    },
    _get_driver: function (){
        return new Recruit.UI.Driver.JSONP({
            url : '/carsensor/brand/v1/'
        });
    },
    _get_selections_material: function (){
        return this.driver.results.brand;
    }
});

/*
 * CarSensor.UI.Places.Pulldown - エリア選択プルダウン
 * VERSION 1.00
 * CHANGES
 *   2008-02-28 v1.00 released
 */
if( typeof( CarSensor.UI.Places ) != 'function' ) {
    CarSensor.UI.Places = function (){};
}
CarSensor.UI.Places.find_place_by_code = function ( hash ){
    hash = $.extend({
        large_area : undefined,
        pref       : undefined,
        callback : function (){}
    }, hash );
    var drv_la = new Recruit.UI.Driver.JSONP({
        url: '/carsensor/large_area/v1/'
    });
    var drv_pref = new Recruit.UI.Driver.JSONP({
        url: '/carsensor/pref/v1/'
    });
    if( hash.pref ){
        drv_pref.get( function ( success ){
            if( !success ){ return } 
            var res = {};
            if( this.results.pref ){
                res = this.results.pref[0];
            }
            hash.callback( res );
        }, { code: hash.pref } );
    }else if( hash.large_area ){
        drv_la.get( function ( success ){
            if( !success ){ return } 
            var res = {};
            if( this.results.large_area ){
                res = this.results.large_area[0];
            }
            hash.callback( res );
        }, { code: hash.large_area });
    }
    return true;
};
CarSensor.UI.Places.Pulldown = Class.create({
    initialize: function ( hash ){
        if( typeof hash != 'object' ){ hash = {} }
        var prm_la   = $.extend( {}, hash.large_area );
        var prm_pref = $.extend( {}, hash.pref );
        // does it need default val resolving?
        var def_type = '';
        if   ( prm_pref.val ){ def_type = 'pref'   }
        else if( prm_la.val ){ def_type = 'large_area' }
        // define post handler
        var _self = this;
        var process = function ( itm ){
            if( def_type == 'pref' && itm ){
                prm_la.val          = itm.large_area.code;
                prm_pref.large_area = itm.large_area.code;
            }else if( def_type == 'large_area' ){
                prm_pref.large_area = prm_la.val;
            }
            // create pulldown
            var la = new CarSensor.UI.LargeArea.Pulldown( prm_la );
            var pref = new CarSensor.UI.Pref.Pulldown( prm_pref );
            if( la.elm.length > 0 )  { this.large_area = la }
            if( pref.elm.length > 0 ){ this.pref = pref     }
            // add on change handler
            if( this.pref && this.large_area ){
                this.large_area.elm.change( function (){
                    _self.pref.large_area = _self.large_area.elm.val();
                    _self.pref.update_ui();
                });
            }
        };
        // do ajax default code resolving
        if( def_type == 'pref' ){
            CarSensor.UI.Places.find_place_by_code({
                pref: prm_pref.val,
                callback: function ( itm ){
                    process.apply( _self, [ itm ] );
                }
            });
        }else{
            process.apply( this, [] ); 
        }
    }
});


/*
 * CarSensor.UI.LargeArea.Pulldown - 大エリア選択プルダウン
 * VERSION 1.00
 * CHANGES
 *   2008-02-28 v1.00 released
 */
if( typeof( CarSensor.UI.LargeArea ) != 'function' ) {
    CarSensor.UI.LargeArea = function (){};
}
CarSensor.UI.LargeArea.Pulldown =
Class.create( Recruit.UI.Base.Pulldown.JSONP, {
    _get_def_props: function (){
        return {
            id    : 'car-large-area-sel',
            name  : 'large_area',
            label : '大エリア'
        };
    },
    _get_driver: function (){
        return new Recruit.UI.Driver.JSONP({
            url : '/carsensor/large_area/v1/'
        });
    },
    _get_selections_material: function (){
        return this.driver.results.large_area;
    }
});

/*
 * CarSensor.UI.Pref.Pulldown - 都道府県選択プルダウン
 * VERSION 1.00
 * CHANGES
 *   2008-02-28 v1.00 released
 */
if( typeof( CarSensor.UI.Pref ) != 'function' ) {
    CarSensor.UI.Pref = function (){};
}
CarSensor.UI.Pref.Pulldown =
Class.create( Recruit.UI.Base.Pulldown.JSONP, {
    _get_def_props: function (){
        return {
            id    : 'car-pref-sel',
            name  : 'pref',
            label : '都道府県',
            has_parent  : true,
            parent      : 'large_area',
            large_area  : ''
        };
    },
    _get_driver: function (){
        return new Recruit.UI.Driver.JSONP({
            url : '/carsensor/pref/v1/'
        });
    },
    _get_selections_material: function (){
        return this.driver.results.pref;
    }
});

/*
 * CarSensor.UI.Body.Pulldown - ボディタイプ選択プルダウン
 * VERSION 1.00
 * CHANGES
 *   2008-02-27 v1.00 released
 */
if( typeof( CarSensor.UI.Body ) != 'function' ) {
    CarSensor.UI.Body = function (){};
}
var Body_skeleton = {
    _get_def_props: function (){
        return {
            id    : 'car-body-sel',
            name  : 'body',
            label : 'ボディタイプ'
        };
    },
    _get_driver: function (){
        return new Recruit.UI.Driver.JSONP({
            url : '/carsensor/body/v1/'
        });
    },
    _get_selections_material: function (){
        return this.driver.results.body;
    }
};
CarSensor.UI.Body.Pulldown =
Class.create( Recruit.UI.Base.Pulldown.JSONP, Body_skeleton );

/*
 * CarSensor.Body.Checkbox - ボディタイプ選択チェックボックス
 * VERSION 1.00
 * CHANGES
 *   2008-02-28 v1.00 released
 */
CarSensor.UI.Body.Checkbox =
Class.create( Recruit.UI.Base.Checkbox.JSONP,
    $.extend( Body_skeleton, {
        _get_def_props: function (){
            return {
                id    : 'car-body-checkbox',
                name  : 'body',
                label : 'ボディタイプ',
                template : 'horizontal'
            };
        }
    })
);

/*
 * CarSensor.UI.Color.Pulldown - カラー選択プルダウン
 * VERSION 1.00
 * CHANGES
 *   2008-02-28 v1.00 released
 */
if( typeof( CarSensor.UI.Color ) != 'function' ) {
    CarSensor.UI.Color = function (){};
}
var Color_skeleton = {
    _get_def_props: function (){
        return {
            id    : 'car-color-sel',
            name  : 'color',
            label : 'カラー'
        };
    },
    _get_driver: function (){
        return new Recruit.UI.Driver.JSONP({
            url : '/carsensor/color/v1/'
        });
    },
    _get_selections_material: function (){
        return this.driver.results.color;
    }
};
CarSensor.UI.Color.Pulldown =
Class.create( Recruit.UI.Base.Pulldown.JSONP, Color_skeleton );

/*
 * CarSensor.Color.Checkbox - カラー選択チェックボックス
 * VERSION 1.00
 * CHANGES
 *   2008-02-28 v1.00 released
 */
CarSensor.UI.Color.Checkbox =
Class.create( Recruit.UI.Base.Checkbox.JSONP,
    $.extend( Color_skeleton, {
        _get_def_props: function (){
            return {
                id    : 'car-color-checkbox',
                name  : 'color',
                label : 'カラー',
                template : 'horizontal'
            };
        }
    })
);

/*
 * CarSensor.UI.Person.Pulldown - 定員プルダウン
 * VERSION 1.00
 * CHANGES
 *   2008-02-27 v1.00 released
 */
if( typeof( CarSensor.UI.Person ) != 'function' ) {
    CarSensor.UI.Person = function (){};
}
CarSensor.UI.Person.Pulldown =
Class.create( Recruit.UI.Base.Pulldown, {
    _get_def_props: function (){
        return {
            id             : 'car-person-sel',
            name           : 'person',
            label          : '定員'
        };
    },
    get_selections: function (){
        var ret = {};
        for (var i=2; i<=10; i++){
            ret[ i.toString() ] = i + '名';
        }
        return ret;
    }
});

/*
 * CarSensor.UI.UsedCar.Order.Pulldown - 中古車 並び順プルダウン
 * VERSION 1.00
 * CHANGES
 *   2008-02-27 v1.00 released
 */
if( typeof( CarSensor.UI.UsedCar.Order ) != 'function' ) {
    CarSensor.UI.UsedCar.Order = function (){};
}
CarSensor.UI.UsedCar.Order.Pulldown =
Class.create( Recruit.UI.Base.Pulldown, {
    _get_def_props: function (){
        return {
            id             : 'car-usedcar-order-sel',
            name           : 'order',
            label          : '並び順',
            first_opt_text : 'ブランド順'
        };
    },
    get_selections: function (){
        return {
            "1" : "価格安い順",
            "2" : "価格高い順",
            "3" : "車種名順",
            "4" : "年式古い順",
            "5" : "年式新しい順",
            "6" : "走行距離少ない順"
        };
    }
});

/*
 * CarSensor.UI.Catalog.Order.Pulldown - 中古車 並び順プルダウン
 * VERSION 1.00
 * CHANGES
 *   2008-02-27 v1.00 released
 */
if( typeof( CarSensor.UI.Catalog ) != 'function' ) {
    CarSensor.UI.Catalog = function (){};
}
if( typeof( CarSensor.UI.Catalog.Order ) != 'function' ) {
    CarSensor.UI.Catalog.Order = function (){};
}
CarSensor.UI.Catalog.Order.Pulldown =
Class.create( Recruit.UI.Base.Pulldown, {
    _get_def_props: function (){
        return {
            id             : 'car-catalog-order-sel',
            name           : 'order',
            label          : '並び順',
            first_opt_text : 'ブランド順'
        };
    },
    get_selections: function (){
        return {
            "1" : "モデル名順"
        };
    }
});

/*
 * CarSensor.UI.Price.Pulldown - 価格帯プルダウン
 * VERSION 1.00
 * CHANGES
 *   2008-02-28 v1.00 released
 */
if( typeof( CarSensor.UI.Price ) != 'function' ) {
    CarSensor.UI.Price = function (){};
}
/*
 * CarSensor.UI.Price.Pulldown
 *   - initialize both CarSensor.UI.Price.[Max|Min].Pulldown at once.
 */
CarSensor.UI.Price.Pulldown = Class.create({
    initialize: function ( arg ){
        arg = $.extend({
            'max' : undefined,
            'min' : undefined
        }, arg );
        var tgt = {
            'max' : CarSensor.UI.Price.Max.Pulldown,
            'min' : CarSensor.UI.Price.Min.Pulldown
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
 * CarSensor.UI.Price.Max.Pulldown
 */
var price_pattern = [
    2,4,6,8,10,12,15,20,25,30,40,50,60,70,80,90,100
];
CarSensor.UI.Price.Max = function (){};
CarSensor.UI.Price.Max.Pulldown =
Class.create( Recruit.UI.Base.Pulldown, {
    prices: price_pattern,
    _get_def_props: function (){
        return {
            id             : 'car-price-max-sel',
            name           : 'price_max',
            label          : '最高価格'
        };
    },
    get_selections: function (){
        var h = {};
        $.each( this.prices, function (i,v){
            var key = v * 100000;
            var str = v * 10;
            var val = str + '万円 以内';
            h[ key ] = val;
        });
        return h;
    }
});

/*
 * CarSensor.UI.Price.Min.Pulldown
 */
CarSensor.UI.Price.Min = function (){};
CarSensor.UI.Price.Min.Pulldown =
Class.create( Recruit.UI.Base.Pulldown, {
    prices: price_pattern,
    _get_def_props: function (){
        return {
            id             : 'car-price-min-sel',
            name           : 'price_min',
            label          : '最低価格'
        };
    },
    get_selections: function (){
        var h = {};
        $.each( this.prices, function (i,v){
            var key = v * 100000;
            var str = v * 10;
            var val = str + '万円 以上';
            h[ key ] = val;
        });
        return h;
    }
});

/*
 * CarSensor.UI.Mission.Pulldown - ミッション式選択プルダウン
 * VERSION 1.00
 * CHANGES
 *   2008-02-28 v1.00 released
 */
if( typeof( CarSensor.UI.Mission ) != 'function' ) {
    CarSensor.UI.Mission = function (){};
}
CarSensor.UI.Mission.Pulldown =
Class.create( Recruit.UI.Base.Pulldown, {
    _get_def_props: function (){
        return {
            id             : 'car-mission-sel',
            name           : 'mission',
            label          : 'ミッション式'
        };
    },
    get_selections: function (){
        return {
            "1" : "AT",
            "2" : "MT"
        };
    }
});

/*
 * CarSensor.UI.Kodawari.Checkbox - こだわり選択チェック
 * VERSION 1.00
 * CHANGES
 *   2008-02-28 v1.00 released
 */
if( typeof( CarSensor.UI.Kodawari ) != 'function' ) {
    CarSensor.UI.Kodawari = function (){};
}
CarSensor.UI.Kodawari.Checkbox =
Class.create( Recruit.UI.Base.Checkbox, {
    _get_def_props: function (){
        return {
            id          : 'car-kodawari-checkbox',
            label       : 'こだわり',
            template    : 'horizontal'
        };
    },
    get_selections: function (){
        return [
            { value:'1', name:'nonsmoking', label: '禁煙車' },
            { value:'1', name:'leather',    label: '本革シート' },
            { value:'1', name:'welfare',    label: '福祉車両' }
        ];
    }
});

/*
 * CarSensor.UI.Year.Pulldown - 年式プルダウン
 * VERSION 1.00
 * CHANGES
 *   2008-02-28 v1.00 released
 */
if( typeof( CarSensor.UI.Year ) != 'function' ) {
    CarSensor.UI.Year = function (){};
}
CarSensor.UI.Year.create_list = function ( type ){
    var dt = new Date();
    var now_y = dt.getFullYear();
    var ret = {};
    for (var y=now_y; y >= 1982; y-- ){
        var wa = '';
        if( y <= 1988 ){  // 昭和
            var diff = y - 1982;
            wa = 57 + diff;
            wa = 'S' + wa;
        }else{  // 平成
            var diff = y - 1989;
            wa = 1 + diff;
            wa = wa.toString();
            if( wa.length == 1 ){
                wa = '0' + wa;
            }
            wa = 'H' + wa;
        }
        var lbl = wa + ' (' + y + ') 年';
        if( type == 'new' ){
            lbl += '以前';
        }else{
            lbl += '以降';
        }
        ret[ y.toString() ] = lbl;
    }
    return ret;
};

/*
 * CarSensor.UI.Year.Pulldown
 *   - initialize both CarSensor.UI.Year.[Max|Min].Pulldown at once.
 */
CarSensor.UI.Year.Pulldown = Class.create({
    initialize: function ( arg ){
        arg = $.extend({
            'max' : undefined,
            'min' : undefined
        }, arg );
        var tgt = {
            'max' : CarSensor.UI.Year.Max.Pulldown,
            'min' : CarSensor.UI.Year.Min.Pulldown
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
 * CarSensor.UI.Year.Max.Pulldown
 */
CarSensor.UI.Year.Max = function (){};
CarSensor.UI.Year.Max.Pulldown =
Class.create( Recruit.UI.Base.Pulldown, {
    _get_def_props: function (){
        return {
            id             : 'car-year-max-sel',
            name           : 'year_new',
            label          : '登録年式(新しい)'
        };
    },
    get_selections: function (){
        return CarSensor.UI.Year.create_list( 'new' );
    }
});

/*
 * CarSensor.UI.Year.Min.Pulldown
 */
CarSensor.UI.Year.Min = function (){};
CarSensor.UI.Year.Min.Pulldown =
Class.create( Recruit.UI.Base.Pulldown, {
    _get_def_props: function (){
        return {
            id             : 'car-year-min-sel',
            name           : 'year_old',
            label          : '登録年式(古い)'
        };
    },
    get_selections: function (){
        return CarSensor.UI.Year.create_list( 'old' );
    }
});

/*
 * CarSensor.UI.Odd.Pulldown - 走行距離プルダウン
 * VERSION 1.00
 * CHANGES
 *   2008-02-28 v1.00 released
 */
if( typeof( CarSensor.UI.Odd ) != 'function' ) {
    CarSensor.UI.Odd = function (){};
}
/*
 * CarSensor.UI.Odd.Pulldown
 *   - initialize both CarSensor.UI.Odd.[Max|Min].Pulldown at once.
 */
CarSensor.UI.Odd.Pulldown = Class.create({
    initialize: function ( arg ){
        arg = $.extend({
            'max' : undefined,
            'min' : undefined
        }, arg );
        var tgt = {
            'max' : CarSensor.UI.Odd.Max.Pulldown,
            'min' : CarSensor.UI.Odd.Min.Pulldown
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
CarSensor.UI.Odd.create_list = function ( type ){
    var pattern = [
        1,2,3,4,5,10,20,30,40,50,60,70,80,90,100
    ];
    var ret = {};
    $.each( pattern, function (i,v){
        var key = v * 1000;
        var str = '';
        if( v < 10 ){
            str = v * 1000;
        }else{
            str = v / 10;
            str += '万';
        }
        var suf = ( type == 'max' )? '未満' : '以上';
        ret[ key ] = str + 'km ' + suf;
    });
    return ret;
};
/*
 * CarSensor.UI.Odd.Max.Pulldown
 */
CarSensor.UI.Odd.Max = function (){};
CarSensor.UI.Odd.Max.Pulldown =
Class.create( Recruit.UI.Base.Pulldown, {
    _get_def_props: function (){
        return {
            id             : 'car-odd-max-sel',
            name           : 'odd_max',
            label          : '走行距離(最長)'
        };
    },
    get_selections: function (){
        return CarSensor.UI.Odd.create_list( 'max' );
    }
});

/*
 * CarSensor.UI.Odd.Min.Pulldown
 */
CarSensor.UI.Odd.Min = function (){};
CarSensor.UI.Odd.Min.Pulldown =
Class.create( Recruit.UI.Base.Pulldown, {
    _get_def_props: function (){
        return {
            id             : 'car-odd-min-sel',
            name           : 'odd_min',
            label          : '走行距離(最短)'
        };
    },
    get_selections: function (){
        return CarSensor.UI.Odd.create_list( 'min' );
    }
});

// end of jQuery no-conflict wrapper
})(jQuery);
