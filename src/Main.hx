
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

        var x_expr = parse_expr('(screen.w/2) - (canvas.w/2)');
        var y_expr = parse_expr('screen.y + 20');
        var width_expr = parse_expr('screen.w * 0.8');
        var height_expr = parse_expr('screen.h * 0.2');

            //set size
        solver.add_constraint(new Equation(canvas.w, width_expr));
        solver.add_constraint(new Equation(canvas.h, height_expr));
            //center to 'screen'
        solver.add_constraint(new Equation(canvas.x, x_expr));
        solver.add_constraint(new Equation(canvas.y, y_expr));
            // max size
        solver.add_constraint(new Inequality(canvas.w, Op.GEQ, 128));
        solver.add_constraint(new Inequality(canvas.h, Op.GEQ, 128, Strength.weak));

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

    function eval(e:Exp):Expression {
        return switch(e) {
            case EConstant(f):
                Expression.from_constant(f);
            case EIdent(f):
                Expression.from_variable(find_var(f));
            case EBinop(op, lhs, rhs):
                switch(op) {
                    case add:
                        var e = Expression.empty();
                            e = e.add_expr(eval(lhs));
                            e.plus(eval(rhs));
                    case sub:
                        var e = Expression.empty();
                            e = e.add_expr(eval(lhs));
                            e.minus(eval(rhs));
                    case mul:
                        var e = Expression.empty();
                            e = e.add_expr(eval(lhs));
                            e.times(eval(rhs));
                    case div:
                        var e = Expression.empty();
                            e = e.add_expr(eval(lhs));
                            e.divide(eval(rhs));
                }
            case EPar(e):
                eval(e);
            case ENeg(e):
                var exp = eval(e);
                exp.multiply_me(-1);
        }
    }

    function find_var(name:String) : Variable {
        var res = cast CVariable.map.get(name);
        if(res == null) throw "variable not found " + name;
        return res;
    }


    function parse_expr( expr:String ) {
        return eval(new ExprParser(expr).parse());
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
