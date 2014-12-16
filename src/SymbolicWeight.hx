

class SymbolicWeight {

    public var value : Float = 0.0;
    public var multiplier : Float = 1000;

    public function new( weights:Array<Float> ) {
        var factor = 1.0;

        for(weight in weights) {
            value = weight * factor;
            factor *= multiplier;
        }
    }

    function toString() return '$value';

} //SymbolicWeight