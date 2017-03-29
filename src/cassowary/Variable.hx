package cassowary;

typedef VariableArgs = {
    ? name : String,
    ? prefix : String,
    ? value : Float,
    ? __ff:Bool
}

class AbstractVariable {

    public var is_dummy:Bool = false;
    public var is_external:Bool = false;
    public var is_pivotable:Bool = false;
    public var is_restricted:Bool = false;

    public var prefix : String = '';
    public var name : String;
    public var value : Float = 0;
    public var _value : String = '';
    public var hashcode : Int;

    public var val (get,never):String;
        function get_val() return (_value != 'obj') ? Std.string(value) : _value;

    @:noCompletion
    public var _ff: Bool = false;

    public inline function new(
        ? _name:String,
        ? _val:Float,
        ? _prefix:String,
        ? __ff:Bool
    ) {
        //name defaults to a hash id then,
        //and in subclasses is prefixed before calling super
        hashcode = C.inc();
        name += hashcode;

        if(_name != null) name = _name;
        if(_prefix != null) prefix = _prefix;
        if(_val != null) value = _val;
        if(__ff != null) _ff = __ff;
    }

    function toString() {
        return '$prefix[$name:$val]';
    }

} //AbstractVariable

@:forward()
abstract Variable(CVariable) from CVariable to CVariable {

    public inline function new(
        ? _name:String,
        ? _val:Float,
        ? _prefix:String,
        ? __ff:Bool
    ) {
        this = new CVariable(_name,_val,_prefix,__ff);
    }

    @:from
    static function fromFloat(f:Float) : Variable {
        return new CVariable(f,true);
    }

    @:to
    function toFloat() : Float {
        return this.value;
    }
}

class CVariable extends AbstractVariable {

    @:noCompletion
    public static var map: Map<String, AbstractVariable> = new Map();

    public inline function new(
        ? _name:String,
        ? _val:Float,
        ? _prefix:String,
        ? __ff:Bool
    ) {
        name = 'v';

        super( _name,_val,_prefix,__ff );

        is_external = true;

        map.set(name, this);
    }

} //Variable

class DummyVariable extends AbstractVariable {

    public inline function new(
        ? _name:String,
        ? _val:Float,
        ? _prefix:String,
        ? __ff:Bool
    ) {
        name = 'd';

        super( _name,_val,_prefix,__ff );

        is_dummy = true;
        is_restricted = true;
        _value = 'dummy';
    }

} //DummyVariable

class ObjectiveVariable extends AbstractVariable {

    public inline function new(
        ? _name:String,
        ? _val:Float,
        ? _prefix:String,
        ? __ff:Bool
    ) {
        name = 'o';

        super( _name,_val,_prefix,__ff );

        _value = 'obj';
    }

} //ObjectiveVariable

class SlackVariable extends AbstractVariable {

    public inline function new(
        ? _name:String,
        ? _val:Float,
        ? _prefix:String,
        ? __ff:Bool
    ) {
        name = 's';

        super( _name,_val,_prefix,__ff );

        is_pivotable = true;
        is_restricted = true;
        _value = 'slack';
    }

} //SlackVariable
