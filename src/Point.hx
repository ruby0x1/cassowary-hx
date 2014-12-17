
import Variable;

class Point {

    public var x (get,set) : Dynamic;
    public var y (get,set) : Dynamic;

    var _x: Variable;
    var _y: Variable;

    public function new(?x:Dynamic, ?y:Dynamic, ?suffix:String='') {
        if(Std.is(x, AbstractVariable)) {
            _x = x;
        } else {
            _x = new Variable({ value:x, name:'x$suffix' });
        }
        if(Std.is(y, AbstractVariable)) {
            _y = y;
        } else {
            _y = new Variable({ value:y, name:'y$suffix' });
        }
    }

    function get_x() { return _x; }
    function get_y() { return _y; }

    function set_x(xVar) {
        if(Std.is(xVar, AbstractVariable)) {
            _x = xVar;
        } else {
            _x.value = xVar;
        }
        return xVar;
    }

    function set_y(yVar) {
        if(Std.is(yVar, AbstractVariable)) {
            _y = yVar;
        } else {
            _y.value = yVar;
        }
        return yVar;
    }

    function toString() return '($x, $y)';

} //Point