

class Point {

    public var x: Variable;
    public var y: Variable;

    public var xv (get,set):Float;
        function set_xv(v) { return x.value = v; }
        function get_xv() { return x.value; }
    public var yv (get,set):Float;
        function set_yv(v) { return y.value = v; }
        function get_yv() { return y.value; }

    public function new(?_x:Variable, ?_y:Variable, ?suffix:String='') {
        x = _x;
        y = _y;

        if(x._ff) x.name = 'x'+suffix;
        if(y._ff) y.name = 'y'+suffix;
    }

    function toString() return '[$x, $y]';

} //Point