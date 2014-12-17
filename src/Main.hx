

import luxe.Input;

import tests.*;
import Expression;
import luxe.Vector;
import Variable;
import Constraint;

class Main extends luxe.Game {

    override function config( config:luxe.AppConfig ) {
        // config.has_window = false;
        config.window.width = 960;
        config.window.height = 700;
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
    var cw:Float = 512;
    var ch:Float = 512;
    var cx:Float = 512;
    var cy:Float = 512;

    override function ready() {

        // tests();
        // return;

        // C.logging = true;
        // C.verbose = true;

        cx = (Luxe.screen.mid.x-(cw/2));
        cy = (Luxe.screen.mid.y-(ch/2));

        Luxe.draw.rectangle({ x:cx,y:cy,w:cw,h:ch, color:new luxe.Color(1,1,1,0.2)});

        solver = new SimplexSolver();
        mp = [];
        db = [];

        for(a in 0 ... 8) db[a] = new DraggableBox(a);
        for(a in 0 ... 4) mp[a] = db[a+4];

        db[0].center = new Point(cx+10,  cy+10);
        db[1].center = new Point(cx+10,  cy+200);
        db[2].center = new Point(cx+200, cy+200);
        db[3].center = new Point(cx+200, cy+10);

        solver.add_point_stays([db[0].center,db[1].center,db[2].center,db[3].center]);

        var cle:Expression = null;
        var cleq:Equation = null;

        cle = Expression.from_variable(db[0].x).plusv(db[1].x).dividef(2);
        cleq = new Equation(mp[0].x, cle);

        solver.add_constraint(cleq);

        cle = Expression.from_variable(db[0].y).plusv(db[1].y).dividef(2);
        cleq = new Equation(mp[0].y, cle);

        solver.add_constraint(cleq);

        cle = Expression.from_variable(db[1].x).plusv(db[2].x).dividef(2);
        cleq = new Equation(mp[1].x, cle);

        solver.add_constraint(cleq);

        cle = Expression.from_variable(db[1].y).plusv(db[2].y).dividef(2);
        cleq = new Equation(mp[1].y, cle);

        solver.add_constraint(cleq);

        cle = Expression.from_variable(db[2].x).plusv(db[3].x).dividef(2);
        cleq = new Equation(mp[2].x, cle);

        solver.add_constraint(cleq);

        cle = Expression.from_variable(db[2].y).plusv(db[3].y).dividef(2);
        cleq = new Equation(mp[2].y, cle);

        solver.add_constraint(cleq);

        cle = Expression.from_variable(db[3].x).plusv(db[0].x).dividef(2);
        cleq = new Equation(mp[3].x, cle);

        solver.add_constraint(cleq);

        cle = Expression.from_variable(db[3].y).plusv(db[0].y).dividef(2);
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

        for(p in db) {
          solver.add_constraint(new Inequality(p.x, Op.GEQ, cx+10));
          solver.add_constraint(new Inequality(p.y, Op.GEQ, cy+10));

          solver.add_constraint(new Inequality(p.x, Op.LEQ, cx+cw - 10));
          solver.add_constraint(new Inequality(p.y, Op.LEQ, cy+ch - 10));
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

class DraggableBox {
    public var x (get,null) : Variable;
    public var y (get,null) : Variable;
    public var w:Float;
    public var h:Float;

    public var center:Point;

    public function new(_x:Float,?_y:Float,_w:Float=15,_h:Float=15) {
        w = _w;
        h = _h;
        if(_y == null) {
            center = new Point(0,0,Std.string(_x));
        } else {
            center = new Point(_x,_y);
        }
    }

    function get_x() return center.x;
    function get_y() return center.y;

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
        return '${center.x},${center.y}';
    }

    public function contains(_x, _y) {
        return ( (_x >= x.value - w/2) &&
                 (_x <= x.value + w/2) &&
                 (_y >= y.value - h/2) &&
                 (_y <= y.value + h/2)
       );
    }
}