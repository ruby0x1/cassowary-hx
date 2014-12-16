

class SymbolicWeight {

    public var value : Float = 0.0;
    public var multiplier : Float = 1000;

    public function new( weights:Array<Float> ) {
        var factor = 1.0;

        var i = weights.length - 1;
        while( i >= 0 ) {
            value += weights[i] * factor;
            factor *= multiplier;
            i--;
        }
    }

    function toString() return '$value';

} //SymbolicWeight