
import luxe.Input;
import luxe.Vector;
import luxe.Sprite;
import luxe.Color;

import Expression;
import Variable;
import Constraint;
import ExprParser;


class Main extends luxe.Game {

    var solver:SimplexSolver;

    var screen:Bounds;
    var canvas:Bounds;

    override function ready() {
        solver = new SimplexSolver();
        screen = new Bounds('screen',new Color().rgb(0xf67b00));
        canvas = new Bounds('canvas',new Color().rgb(0xf6007b));

            screen.w.value = Luxe.screen.w;
            screen.h.value = Luxe.screen.h;

                //stays hold a value down until its constraints breach
            solver.add_stay(screen.x);
            solver.add_stay(screen.y);
            solver.add_stay(screen.w);
            solver.add_stay(screen.h);


        constrain(canvas.x, '(screen.w/2) - (canvas.w/2)');
        constrain(canvas.y, 'screen.y + 20');

        constrain(canvas.w, 'screen.w * 0.8');
        constrain(canvas.h, 'screen.h * 0.2');

        constrain(canvas.w, '>= 128');
        constrain(canvas.h, '>= 128');

    }

    function onresize(nw:Float, nh:Float, from_window:Bool=false) {

        if(from_window) Luxe.camera.viewport = new luxe.Rectangle(0,0,nw,nh);

        solver.begin_edit();
            solver.set_edited_value(screen.w, nw);
            solver.set_edited_value(screen.h, nh);
        solver.end_edit();

    } //onresize

    override function onmousemove(e:MouseEvent) {
        onresize(e.x, e.y);
    }

    override function onkeyup(e:KeyEvent) {
        if(e.keycode == Key.escape) Luxe.shutdown();
    }

    override function update(dt:Float) {

        screen.draw();
        canvas.draw();

        Luxe.draw.line({ p0:new Vector(0,screen.h.value/2), p1:new Vector(screen.w.value,screen.h.value/2), color:new Color(1,1,1,0.1),immediate:true });
        Luxe.draw.line({ p0:new Vector(screen.w.value/2,0), p1:new Vector(screen.w.value/2,screen.h.value), color:new Color(1,1,1,0.1),immediate:true });

    }

    function constrain( v:Variable, expr:String, ?strength:Strength, ?weight:Float ) {
        var parsed = new ExprParser(expr).parse();
        var e = eval(parsed);
        if(e.op != null) {
            solver.add_constraint(new Inequality(v, e.op, e.expr, strength, weight));
        } else {
            solver.add_constraint(new Equation(v, e.expr, strength, weight));
        }
    } //constrain

    function eval(e:Exp):{ expr:Expression, ?op:Op } {
        return switch(e) {

            case EPar(e):       eval(e);
            case EConstant(f):  { expr: Expression.from_constant(f) }
            case EIdent(f):     { expr: Expression.from_variable(find_var(f)) }
            case ENeg(e):       { expr: eval(e).expr.multiply_me(-1) }

            case EInequality(op, rhs): {
                var rhs = eval(rhs);
                switch(op) {
                    case leq:   { op:Op.LEQ, expr:rhs.expr }
                    case geq:   { op:Op.GEQ, expr:rhs.expr }
                }
            } //ineqaulity operator

            case EBinop(op, lhs, rhs): {
                var lhs_e = eval(lhs).expr;
                var rhs_e = eval(rhs).expr;
                trace('lhs $lhs_e $op $rhs_e');
                switch(op) {
                    case add: { expr:Expression.from_expr(lhs_e).plus(rhs_e) }
                    case sub: { expr:Expression.from_expr(lhs_e).minus(rhs_e) }
                    case mul: { expr:Expression.from_expr(lhs_e).times(rhs_e) }
                    case div: { expr:Expression.from_expr(lhs_e).divide(rhs_e) }
                }
            } //binary operator
        } //switch(e)
    } //eval

    function find_var(name:String) : Variable {
        var res = cast CVariable.map.get(name);
        if(res == null) throw "variable not found " + name;
        return res;
    }


    function parse_expr( expr:String ) {
        return eval(new ExprParser(expr).parse());
    }

    override function config(config:luxe.AppConfig) {

        config.window.width = 700;
        config.window.height = 467;

        return config;
    }

} //Main

class Bounds {

    public var x:Variable;
    public var y:Variable;
    public var w:Variable;
    public var h:Variable;

    public var color:Color;
    public var name:String;

    public function new( _name:String='bounds', ?c:Color ) {
        name = _name;
        x = new Variable({name:'${_name}.x', value:0 });
        y = new Variable({name:'${_name}.y', value:0 });
        w = new Variable({name:'${_name}.w', value:32 });
        h = new Variable({name:'${_name}.h', value:32 });

        if(c!=null) color = c; else c = new Color(1,1,1,0.4);
    }

    public function draw( imm:Bool=true ) {
        Luxe.draw.rectangle({
            immediate:imm,
            color:color,
            x:x.value,
            y:y.value,
            w:w.value,
            h:h.value
        });
    }

    function toString() {
        return '$name [$x,$y,$w,$h]';
    }

}
