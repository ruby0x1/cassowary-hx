

class Strength {

    public var symbolic_weight:SymbolicWeight;
    public var is_required(get,never): Bool;

    public function new( name:String, ?s:SymbolicWeight, ?w1:Null<Float>, ?w2:Null<Float>, ?w3:Null<Float> ) {

        var has_3_weights = (w1 != null && w1 != null && w3 != null);
        var has_any_weights = (w1 != null || w1 != null || w3 != null);
        var has_symbolic = s != null;

        if(has_symbolic && has_3_weights) throw "Strength: either a s OR 3 weights are given, not both";
        if(has_symbolic && has_any_weights) throw "Strength: either a s OR 3 weights are given, not both";
        if(!has_symbolic && !has_3_weights) throw "Strength: All 3 weights are required if using weights";

        if(has_symbolic) {
            symbolic_weight = s;
        } else {
            symbolic_weight = new SymbolicWeight([w1, w2, w3]);
        }
    }

    function get_is_required() {
        return this == Strength.required;
    }

    public static var required = new Strength("<Required>", 1000,   1000,   1000 );
    public static var strong   = new Strength("strong",     1,      0,      0 );
    public static var medium   = new Strength("medium",     0,      1,      0 );
    public static var weak     = new Strength("weak",       0,      0,      1 );

} //Strength