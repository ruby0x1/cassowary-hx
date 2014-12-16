

class Strength {

    public var symbolic_weight:SymbolicWeight;
    public var is_required(get,never): Bool;
    public var name:String = '';

    public function new( _name:String, s:Dynamic, ?w2:Float, ?w3:Float) {

        name = _name;

        if( Std.is(s, SymbolicWeight) ) {
            symbolic_weight = s;
        } else {
            symbolic_weight = new SymbolicWeight([s, w2, w3]);
        }
    }

    function get_is_required() {
        return this == Strength.required;
    }

    function toString() {
        return '$name' + (!is_required ? (':$symbolic_weight') : '');
    }

    public static var required = new Strength("<Required>", 1000,   1000,   1000 );
    public static var strong   = new Strength("strong",     1,      0,      0 );
    public static var medium   = new Strength("medium",     0,      1,      0 );
    public static var weak     = new Strength("weak",       0,      0,      1 );

} //Strength