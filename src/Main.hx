

import luxe.Input;

import tests.*;
import Expression;
import luxe.Vector;
import Variable;
import Constraint;

class Main extends luxe.Game {

    override function config( config:luxe.AppConfig ) {
        // config.has_window = false;
        config.window.width = 512;
        config.window.height = 512;
        return config;
    } //config

    function tests() {
        mohxa.Mohxa.use_colors = false;
        // C.logging = true;
        // C.verbose = true;

        new Tableau_test();
        new Variable_test();
        new SymbolicWeight_test();
        new Strength_test();
        new SimplexSolver_test();
        new Point_test();
        new Expression_test();
        new EndToEnd_test();
        new Constraint_test();

        mohxa.Mohxa.finish();
    }


    var solver:SimplexSolver;
    var dbDragging:Int = -1;
    var db:Array<DraggableBox>;
    var mp:Array<DraggableBox>;

    override function ready() {

        // tests();
        // return;

        // C.logging = true;
        // C.verbose = true;

        solver = new SimplexSolver();
        mp = [];
        db = [];

        for(a in 0 ... 8) db[a] = new DraggableBox(a);
        for(a in 0 ... 4) mp[a] = db[a+4];

        db[0].center = {x:10,y:10};
        db[1].center = {x:10,y:200};
        db[2].center = {x:200,y:200};
        db[3].center = {x:200,y:10};

        solver.add_point_stays([db[0].center,db[1].center,db[2].center,db[3].center]);

        var cle:Expression = null;
        var cleq:Equation = null;

        cle = Expression.from_constant(db[0].x).plusv(db[1].x).dividef(2);
        cleq = new Equation(mp[0].x, cle);

        solver.add_constraint(cleq);

        cle = Expression.from_constant(db[0].y).plusv(db[1].y).dividef(2);
        cleq = new Equation(mp[0].y, cle);

        solver.add_constraint(cleq);

        cle = Expression.from_constant(db[1].x).plusv(db[2].x).dividef(2);
        cleq = new Equation(mp[1].x, cle);

        solver.add_constraint(cleq);

        cle = Expression.from_constant(db[1].y).plusv(db[2].y).dividef(2);
        cleq = new Equation(mp[1].y, cle);

        solver.add_constraint(cleq);

        cle = Expression.from_constant(db[2].x).plusv(db[3].x).dividef(2);
        cleq = new Equation(mp[2].x, cle);

        solver.add_constraint(cleq);

        cle = Expression.from_constant(db[2].y).plusv(db[3].y).dividef(2);
        cleq = new Equation(mp[2].y, cle);

        solver.add_constraint(cleq);

        cle = Expression.from_constant(db[3].x).plusv(db[0].x).dividef(2);
        cleq = new Equation(mp[3].x, cle);

        solver.add_constraint(cleq);

        cle = Expression.from_constant(db[3].y).plusv(db[0].y).dividef(2);
        cleq = new Equation(mp[3].y, cle);

        solver.add_constraint(cleq);

        cle = C.plus(db[0].x, 20);

        solver.add_constraint(new Inequality(cle, Op.LEQ, db[2].x))
              .add_constraint(new Inequality(cle, Op.LEQ, db[3].x));

        cle = C.plus(db[1].x, 20);

        solver.add_constraint(new Inequality(cle, Op.LEQ, db[2].x))
              .add_constraint(new Inequality(cle, Op.LEQ, db[3].x));

        cle = C.plus(db[0].y, 20);

        solver.add_constraint(new Inequality(cle, Op.LEQ, db[1].y))
              .add_constraint(new Inequality(cle, Op.LEQ, db[2].y));

        cle = C.plus(db[3].y, 20);

        solver.add_constraint(new Inequality(cle, Op.LEQ, db[1].y))
              .add_constraint(new Inequality(cle, Op.LEQ, db[2].y));

        // Add constraints to keep points inside window
        for(p in db) {
          solver.add_constraint(new Inequality(p.x, Op.GEQ, 10));
          solver.add_constraint(new Inequality(p.y, Op.GEQ, 10));

          trace(p.x + ' <= ' + (Luxe.screen.w-10));
          solver.add_constraint(new Inequality(p.x, Op.LEQ, Luxe.screen.w - 10));
          solver.add_constraint(new Inequality(p.y, Op.LEQ, Luxe.screen.h - 10));
        }

        trace(solver);

    } //ready

    override function onmousedown(e:MouseEvent) {
        for(a in 0 ... 8) {
            if(db[a].contains(e.x,e.y)) {
                dbDragging = a;
            }
        }

        if(dbDragging != -1) {
            solver
                .add_edit_var(db[dbDragging].x)
                .add_edit_var(db[dbDragging].y)
                .begin_edit();
            trace('begin_edit $dbDragging');
        }
    }

    override function onmouseup(e:MouseEvent){
        if(dbDragging != -1) {
            dbDragging = -1;
            solver.end_edit();
            trace('end_edit');
        }

        trace(Std.string(db));
    }

    override function onmousemove(e:MouseEvent){
        if(dbDragging != -1) {
            solver
                .suggest_value(db[dbDragging].x, e.x)
                .suggest_value(db[dbDragging].y, e.y)
                .resolve();
        }
    }

    override function onkeydown(e:KeyEvent) {
        if(e.keycode == Key.escape) {
            Luxe.shutdown();
        }
    }


    static var col1: luxe.Color = new luxe.Color(1,1,1,0.6);
    static var col2: luxe.Color = new luxe.Color().rgb(0xf6007b);
    function draw() {

        Luxe.draw.line({p0:new Vector(db[0].x.value,db[0].y.value), p1:new Vector(db[1].x.value,db[1].y.value), color:col1, immediate:true });
        Luxe.draw.line({p0:new Vector(db[1].x.value,db[1].y.value), p1:new Vector(db[2].x.value,db[2].y.value), color:col1, immediate:true });
        Luxe.draw.line({p0:new Vector(db[2].x.value,db[2].y.value), p1:new Vector(db[3].x.value,db[3].y.value), color:col1, immediate:true });
        Luxe.draw.line({p0:new Vector(db[3].x.value,db[3].y.value), p1:new Vector(db[0].x.value,db[0].y.value), color:col1, immediate:true });

        Luxe.draw.line({p0:new Vector(mp[0].x.value,mp[0].y.value), p1:new Vector(mp[1].x.value,mp[1].y.value), color:col2, immediate:true });
        Luxe.draw.line({p0:new Vector(mp[1].x.value,mp[1].y.value), p1:new Vector(mp[2].x.value,mp[2].y.value), color:col2, immediate:true });
        Luxe.draw.line({p0:new Vector(mp[2].x.value,mp[2].y.value), p1:new Vector(mp[3].x.value,mp[3].y.value), color:col2, immediate:true });
        Luxe.draw.line({p0:new Vector(mp[3].x.value,mp[3].y.value), p1:new Vector(mp[0].x.value,mp[0].y.value), color:col2, immediate:true });

        for(a in 0 ... 8) {
            var col = col1;
            if(a == dbDragging) col = col2;
            db[a].draw(col);
        }

    }

    override function update(dt) {
        draw();
    }

} //Main

typedef P = {x:Float,y:Float};
class DraggableBox {
    public var x (get,null) : Variable;
    public var y (get,null) : Variable;
    public var w:Float;
    public var h:Float;

    public var center(get,set):P;
    var _center:Point;

    public function new(_x:Float,?_y:Float,_w:Float=15,_h:Float=15) {
        w = _w;
        h = _h;
        if(_y == null) {
            _center = new Point(0,0,Std.string(_x));
        } else {
            _center = new Point(_x,_y);
        }
    }

    function get_center() return { x:_center.x.value, y:_center.y.value };
    function set_center(c:P) { _center.x.value = c.x; _center.y.value = c.y; return c; };
    function get_x() return _center.x;
    function get_y() return _center.y;

    public function draw(col:luxe.Color) {
        Luxe.draw.rectangle({
            x: x.value - (w/2),
            y: y.value - (h/2),
            w: w,
            h:h,
            color: col,
            immediate : true
        });
    }

    function toString() {
        return '${_center.x},${_center.y}';
    }

    public function contains(_x, _y) {
        return ( (_x >= x.value - w/2) &&
                 (_x <= x.value + w/2) &&
                 (_y >= y.value - h/2) &&
                 (_y <= y.value + h/2)
       );
    }
}