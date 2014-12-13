

typedef VariableArgs = {
    ? name : String,
    ? prefix : String,
    ? value : Float,
    ? _ff:Bool
}

class AbstractVariable {

    public var is_dummy:Bool = false;
    public var is_external:Bool = false;
    public var is_pivotable:Bool = false;
    public var is_restricted:Bool = false;

    public var prefix : String = '';
    public var name : String;
    public var value : Float = 0;

    var tag: String;

    @:noCompletion
    public var _ff: Bool = false;

    public function new( args:VariableArgs ) {
        //name defaults to a hash id then,
        //and in subclasses is prefixed before calling super
        //:todo: using luxe hash instead of isolate
        name += Luxe.utils.uniquehash();

        if(args.name != null)   name = args.name;
        if(args.prefix != null) prefix = args.prefix;
        if(args.value != null)  value = args.value;
        if(args._ff != null)  _ff = args._ff;
    }

    function toString() return '$prefix[$name:$value]';

} //AbstractVariable

@:forward(prefix, name, value, is_dummy, is_external, is_pivotable, is_restricted, tag, _ff)
abstract Variable(CVariable) from CVariable to CVariable {

    public inline function new(args:VariableArgs) {
        this = new CVariable(args);
    }

    @:from
    static public function fromFloat(f:Float) {
        return new CVariable({ value:f, _ff:true });
    }

    @:to
    public function toFloat() : Float {
        return this.value;
    }
}

class CVariable extends AbstractVariable {

    static var map: Map<String, AbstractVariable> = new Map();

    public function new( args:VariableArgs ) {
        name = 'v';

        super( args );

        is_external = true;

        map.set(name, this);
    }

} //Variable

class DummyVariable extends AbstractVariable {

    public function new( args:VariableArgs ) {
        name = 'd';

        super( args );

        is_dummy = true;
        is_restricted = true;
        tag = 'dummy';
    }

} //DummyVariable

class SlackVariable extends AbstractVariable {

    public function new( args:VariableArgs ) {
        name = 's';

        super( args );

        is_pivotable = true;
        is_restricted = true;
        tag = 'slack';
    }

} //SlackVariable