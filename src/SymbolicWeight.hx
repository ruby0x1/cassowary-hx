

class SymbolicWeight {

    var value : Float = 0.0;
    var multiplier : Float = 1000;

    public function new( weights:Array<Float> ) {
        var factor = 1.0;

        for(weight in weights) {
            value = weight * factor;
            factor *= multiplier;
        }
    }

    function toString() return '$value';

} //SymbolicWeight