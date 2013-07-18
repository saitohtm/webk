if( typeof ABROAD != "function" ){
    var ABROAD = function (){};
}
ABROAD.KwicProcessor = function (){
    this.initialize.apply( this, arguments );
};
ABROAD.KwicProcessor.prototype = {
    initialize: function ( kwic, opt ){
        if( typeof kwic != 'string' ){ kwic = '' }
        opt = $.extend({
            alt : '',      // alternative content
            tier: '...',   // tier string for joining multiple kwic blocks
            wrap: ''       // wrap string for ...
        }, opt );
        this.kwic = this.parse_kwic_string( kwic ); // array of kwic blocks
        this.opt  = opt;
    },
    parse_kwic_string: function ( str ){
        if( typeof str != 'string' ){ return }
        str = str.replace( /^\.\.\.|\.\.\.$/g, '' );
        return str.split( '......' );
    },
    trim_if_included_in: function ( target ){
        if( typeof target != 'string' ){ return }
        var arr = [];
        var did_trim = false;
        $.each( this.kwic, function (i,v){
            var sani = v.replace( /<(\/)?span.*?>/g, '' );
            sani = sani.replace( /^ | $/g, '' );
            console.log({ sani: sani, target: target, io: target.indexOf( sani ) });
            if( target.indexOf( sani ) > -1 ){ return }
            arr.push( v );
            did_trim = true;
        });
        this.kwic = arr;
        return did_trim;
    },
    get_result: function ( tier, wrap ){
        if( typeof tier != 'string' ){ tier = this.opt.tier }
        if( typeof wrap != 'string' ){ wrap = this.opt.wrap }
        var arr = this.kwic;
        var res = this.kwic.join( tier );
        if( res == "" ){
            return this.opt.alt;
        }
        return wrap + res + wrap;
    }
};

