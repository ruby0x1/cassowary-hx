package cassowary;

class SymbolicWeight {

    public var value : Float = 0.0;
    public var multiplier : Float = 1000;

    public inline function new( ?weights:Array<Float> ) {
        var factor = 1.0;
        if(weights == null) weights = [];

        var i = weights.length - 1;
        while( i >= 0 ) {
            value += weights[i] * factor;
            factor *= multiplier;
            i--;
        }
    }

    inline function toString() return '$value';

} //SymbolicWeight