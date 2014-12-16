


import tests.Point_test;
import tests.Strength_test;
import Constraint;
import Expression;
import Variable;

class Main extends luxe.Game {

    override function config( config:luxe.AppConfig ) {
        config.has_window = false;
        return config;
    } //config

    override function ready() {

        mohxa.Mohxa.use_colors = false;

        // new Point_test();
        // new Strength_test();

        var solver = new SimplexSolver();
        var x = new Variable({ name: 'x', value: 10 });
        var y = new Variable({ name: 'y', value: 20 });
        var z = new Variable({ name: 'z', value: 1 });
        var w = new Variable({ name: 'w', value: 1 });

        // Default weights.
        var e0 = new Equation(x, y);
        solver.add_stay(y);
        solver.add_constraint(e0);
        trace(C.approx(x, 20));
        trace(C.approx(y, 20));

        // Weak.
        var e1 = new Equation(x, z, Strength.weak);
        // console.log('x:', x.value);
        // trace = true;
        solver.add_stay(x);
        solver.add_constraint(e1);
        trace(C.approx(x, 20));
        trace(C.approx(z, 20));

        // Strong.
        var e2 = new Equation(z, w, Strength.strong);
        solver.add_stay(w);
        solver.add_constraint(e2);
        trace(w.value == 1);
        trace(z.value == 1);

    } //ready

} //Main