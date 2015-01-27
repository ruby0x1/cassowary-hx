package cassowary;

import cassowary.Variable;

class Point {

    public var x : Variable;
    public var y : Variable;

    public function new(?_x:Variable, ?_y:Variable, ?suffix:String='') {

        if(_x == null) { _x = new Variable(); }
        if(_y == null) { _y = new Variable(); }

        x = _x;
        y = _y;

        if(x._ff) x.name = 'x'+suffix;
        if(y._ff) y.name = 'y'+suffix;
    }

    inline function toString() return '[$x, $y]';

} //Point