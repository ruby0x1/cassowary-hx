
import cassowary.Constraint;
import cassowary.Variable;
import cassowary.Expression;
import cassowary.SimplexSolver;
import cassowary.Strength;
import cassowary.C;

class EndToEnd_test extends mohxa.Mohxa {

    public function new() {

        super();

        describe('EndToEnd', function(){
            it('simple1', function(){
                var solver = new SimplexSolver();

                var x = new Variable(167);
                var y = new Variable(2);
                var eq = new Equation(x, new Expression(y));

                solver.add_constraint(eq);
                equal(x.value, y.value, 'x value = y value');
                equal(x.value, 0.0, 'x = 0');
                equal(y.value, 0.0, 'y = 0');
            });

            it('justStay1', function () {
                var x = new Variable(5);
                var y = new Variable(10);
                var solver = new SimplexSolver();
                    solver.add_stay(x);
                    solver.add_stay(y);
                equal(true, C.approx(x, 5), 'x approx 5');
                equal(true, C.approx(y, 10), 'y approx 10');
                equal(x.value, 5, 'x = 5');
                equal(y.value, 10, 'y = 10');
            });

            it('var >= num', function () {
                // x >= 100
                var solver = new SimplexSolver();

                var x = new Variable(10);
                var ieq = new Inequality(x, Op.GEQ, 100);
                solver.add_constraint(ieq);
                equal(x.value, 100, 'x = 100');
            });

            it('num == var', function () {
                // 100 == var
                var solver = new SimplexSolver();

                var x = new Variable(10);
                var eq = new Equation(100, x);
                solver.add_constraint(eq);
                equal(x.value, 100, 'x = 100');
            });

            it('num <= var', function () {
                // x >= 100
                var solver = new SimplexSolver();

                var x = new Variable(10);
                var ieq = new Inequality(100, Op.LEQ, x);
                solver.add_constraint(ieq);

                equal(x.value, 100, 'x = 100');
            });

            it('exp >= num', function () {
                // stay width
                // right >= 100
                var solver = new SimplexSolver();

                // x = 10
                var x = new Variable(10);
                // width = 10
                var width = new Variable(10);
                // right = x + width
                var right = new Expression(x).plusv(width);
                // right >= 100
                var ieq = new Inequality(right, Op.GEQ, 100);
                solver.add_stay(width);
                solver.add_constraint(ieq);

                equal(x.value, 90, 'x = 90');
                equal(width.value, 10, 'width = 10');
            });

            it('num <= exp', function () {
                // stay width
                // 100 <= right
                var solver = new SimplexSolver();

                var x = new Variable(10);
                var width = new Variable(10);
                var right = new Expression(x).plusv(width);
                var ieq = new Inequality(100, Op.LEQ, right);

                solver.add_stay(width)
                      .add_constraint(ieq);

                equal(x.value, 90, 'x = 90');
                equal(width.value, 10, 'width = 10');
            });

            it('exp == var', function () {
                // stay width, rightMin
                // right >= rightMin
                var solver = new SimplexSolver();

                var x = new Variable(10);
                var width = new Variable(10);
                var rightMin = new Variable(100);
                var right = new Expression(x).plusv(width);
                var eq = new Equation(right, rightMin);

                solver.add_stay(width)
                    .add_stay(rightMin)
                    .add_constraint(eq);

                equal(x.value, 90, 'x = 90');
                equal(width.value, 10, 'width = 10');
            });

            it('exp >= var', function () {
                // stay width, rightMin
                // right >= rightMin
                var solver = new SimplexSolver();

                var x = new Variable(10);
                var width = new Variable(10);
                var rightMin = new Variable(100);
                var right = new Expression(x).plusv(width);
                var ieq = new Inequality(right, Op.GEQ, rightMin);

                solver.add_stay(width)
                    .add_stay(rightMin)
                    .add_constraint(ieq);

                equal(x.value, 90, 'x = 90');
                equal(width.value, 10, 'width = 10');
            });

            it('var <= exp', function () {
                // stay width
                // right >= rightMin
                var solver = new SimplexSolver();

                var x = new Variable(10);
                var width = new Variable(10);
                var rightMin = new Variable(100);
                var right = new Expression(x).plusv(width);
                var ieq = new Inequality(rightMin, Op.LEQ, right);
                solver.add_stay(width)
                    .add_stay(rightMin)
                    .add_constraint(ieq);

                equal(x.value, 90, 'x = 90');
                equal(width.value, 10, 'width = 10');
            });

            it('exp == exp', function () {
                // stay width, rightMin
                // right >= rightMin
                var solver = new SimplexSolver();

                var x1 = new Variable(10);
                var width1 = new Variable(10);
                var right1 = new Expression(x1).plusv(width1);
                var x2 = new Variable(100);
                var width2 = new Variable(10);
                var right2 = new Expression(x2).plusv(width2);

                var eq = new Equation(right1, right2);

                solver.add_stay(width1)
                    .add_stay(width2)
                    .add_stay(x2)
                    .add_constraint(eq);

                equal(x1.value, 100, 'x1 = 100');
                equal(x2.value, 100, 'x2 = 100');
                equal(width1.value, 10, 'width1 = 10');
                equal(width2.value, 10, 'width2 = 10');
            });

            it('exp >= exp', function () {
                // stay width, rightMin
                // right >= rightMin
                var solver = new SimplexSolver();

                var x1 = new Variable(10);
                var width1 = new Variable(10);
                var right1 = new Expression(x1).plusv(width1);
                var x2 = new Variable(100);
                var width2 = new Variable(10);
                var right2 = new Expression(x2).plusv(width2);

                var ieq = new Inequality(right1, Op.GEQ, right2);

                solver.add_stay(width1)
                    .add_stay(width2)
                    .add_stay(x2)
                    .add_constraint(ieq);

                equal(x1.value, 100, 'x = 100');
            });

            it('exp <= exp', function () {
                // stay width, rightMin
                // right >= rightMin
                var solver = new SimplexSolver();

                var x1 = new Variable(10);
                var width1 = new Variable(10);
                var right1 = new Expression(x1).plusv(width1);
                var x2 = new Variable(100);
                var width2 = new Variable(10);
                var right2 = new Expression(x2).plusv(width2);
                var ieq = new Inequality(right2, Op.LEQ, right1);

                solver.add_stay(width1)
                    .add_stay(width2)
                    .add_stay(x2)
                    .add_constraint(ieq);

                equal(x1.value, 100, 'x = 100');
            });

            it('addDelete1', function () {
                var solver = new SimplexSolver();
                var x = new Variable('x');
                var cbl = new Equation(x, 100, Strength.weak);
                solver.add_constraint(cbl);

                var c10 = new Inequality(x, Op.LEQ, 10);
                var c20 = new Inequality(x, Op.LEQ, 20);
                solver.add_constraint(c10)
                      .add_constraint(c20);
                equal(true, C.approx(x, 10));

                solver.remove_constraint(c10);
                equal(true, C.approx(x, 20));

                solver.remove_constraint(c20);
                equal(true, C.approx(x, 100));

                var c10again = new Inequality(x, Op.LEQ, 10);
                solver.add_constraint(c10)
                      .add_constraint(c10again);
                equal(true, C.approx(x, 10));

                solver.remove_constraint(c10);
                equal(true, C.approx(x, 10));

                solver.remove_constraint(c10again);
                equal(true, C.approx(x, 100));
            });

            it('addDelete2', function () {
                var solver = new SimplexSolver();
                var x = new Variable('x');
                var y = new Variable('y');

                solver.add_constraint(new Equation(x, 100, Strength.weak))
                .add_constraint(new Equation(y, 120, Strength.strong));
                var c10 = new Inequality(x, Op.LEQ, 10);
                var c20 = new Inequality(x, Op.LEQ, 20);
                solver.add_constraint(c10)
                .add_constraint(c20);
                equal(true, C.approx(x, 10));
                equal(true, C.approx(y, 120));

                solver.remove_constraint(c10);
                equal(true, C.approx(x, 20));
                equal(true, C.approx(y, 120));

                var cxy = new Equation(C.times(2, x), y);
                solver.add_constraint(cxy);
                equal(true, C.approx(x, 20));
                equal(true, C.approx(y, 40));

                solver.remove_constraint(c20);
                equal(true, C.approx(x, 60));
                equal(true, C.approx(y, 120));

                solver.remove_constraint(cxy);
                equal(true, C.approx(x, 100));
                equal(true, C.approx(y, 120));
            });

            it('casso1', function () {
                var solver = new SimplexSolver();
                var x = new Variable('x');
                var y = new Variable('y');

                solver.add_constraint(new Inequality(x, Op.LEQ, y))
                      .add_constraint(new Equation(y, C.plus(x, 3)))
                      .add_constraint(new Equation(x, 10, Strength.weak))
                      .add_constraint(new Equation(y, 10, Strength.weak));

                equal(true,
                    (C.approx(x, 10) && C.approx(y, 13)) ||
                    (C.approx(x,  7) && C.approx(y, 10))
                    );
            });


            it('multiedit', function () {
                // This test stresses the edit session stack. begin_edit() starts a new
                // "edit variable group" and "end_edit" closes it, leaving only the
                // previously opened edit variables still active.
                var x = new Variable('x');
                var y = new Variable('y');
                var w = new Variable('w');
                var h = new Variable('h');
                var solver = new SimplexSolver();
                // Add some stays and start an editing session
                solver.add_stay(x)
                      .add_stay(y)
                      .add_stay(w)
                      .add_stay(h)
                      .add_edit_var(x)
                      .add_edit_var(y).begin_edit();
                solver.suggest_value(x, 10)
                      .suggest_value(y, 20).resolve();
                equal(true,C.approx(x, 10), 'x = 10');
                equal(true,C.approx(y, 20), 'y = 20');
                equal(true,C.approx(w, 0), 'w = 0');
                equal(true,C.approx(h, 0), 'h = 0');

                // Open a second set of variables for editing
                solver.add_edit_var(w)
                      .add_edit_var(h).begin_edit();
                solver.suggest_value(w, 30)
                      .suggest_value(h, 40).end_edit();
                // Close the second set...
                equal(true,C.approx(x, 10), 'x = 10');
                equal(true,C.approx(y, 20), 'y = 20');
                equal(true,C.approx(w, 30), 'w = 30');
                equal(true,C.approx(h, 40), 'h = 40');

                // Now make sure the first set can still be edited
                solver.suggest_value(x, 50)
                      .suggest_value(y, 60).end_edit();
                equal(true,C.approx(x, 50), 'x = 50');
                equal(true,C.approx(y, 60), 'y = 60');
                equal(true,C.approx(w, 30), 'w = 30');
                equal(true,C.approx(h, 40), 'h = 40');
            });

            it('multiedit2', function () {
                var x = new Variable('x');
                var y = new Variable('y');
                var w = new Variable('w');
                var h = new Variable('h');
                var solver = new SimplexSolver();
                solver.add_stay(x)
                      .add_stay(y)
                      .add_stay(w)
                      .add_stay(h)
                      .add_edit_var(x)
                      .add_edit_var(y).begin_edit();
                solver.suggest_value(x, 10)
                      .suggest_value(y, 20).resolve();
                solver.end_edit();

                equal(true,C.approx(x, 10), 'x = 10');
                equal(true,C.approx(y, 20), 'y = 20');
                equal(true,C.approx(w, 0), 'w = 0');
                equal(true,C.approx(h, 0), 'h = 0');

                solver.add_edit_var(w)
                      .add_edit_var(h).begin_edit();
                solver.suggest_value(w, 30)
                      .suggest_value(h, 40);
                solver.end_edit();

                equal(true,C.approx(x, 10), 'x = 10');
                equal(true,C.approx(y, 20), 'y = 20');
                equal(true,C.approx(w, 30), 'w = 30');
                equal(true,C.approx(h, 40), 'h = 40');

                solver.add_edit_var(x)
                      .add_edit_var(y).begin_edit();
                solver.suggest_value(x, 50)
                      .suggest_value(y, 60);
                solver.end_edit();

                equal(true,C.approx(x, 50), 'x = 50');
                equal(true,C.approx(y, 60), 'y = 60');
                equal(true,C.approx(w, 30), 'w = 30');
                equal(true,C.approx(h, 40), 'h = 40');
            });

            it('multiedit3', function () {
                var rand = function (?max:Float, ?min:Dynamic) {
                    min = (min != null) ? min : 0;
                    max = (max != null) ? max : Math.pow(2, 26);
                    return Std.int(Math.random() * (max - min)) + min;
                };
                var MAX = 500;
                var MIN = 100;

                var weak = Strength.weak;
                var medium = Strength.medium;
                var strong = Strength.strong;

                var eq  = function (a1:Dynamic, a2:Dynamic, ?strength, w:Float=0) {
                    if(strength == null) strength = weak;
                    return new Equation(a1, a2, strength, w);
                };

                var v = {
                    width: new Variable('width'),
                    height: new Variable('height'),
                    top: new Variable('top'),
                    bottom: new Variable('bottom'),
                    left: new Variable('left'),
                    right: new Variable('right'),
                };

                var solver = new SimplexSolver();

                var iw = new Variable('window_innerWidth',rand(MAX, MIN));
                var ih = new Variable('window_innerHeight', rand(MAX, MIN));
                var iwStay = new StayConstraint(iw);
                var ihStay = new StayConstraint(ih);

                var widthEQ = eq(v.width, iw, strong);
                var heightEQ = eq(v.height, ih, strong);

                var cs = [
                    widthEQ,
                    heightEQ,
                    eq(v.top, 0, weak),
                    eq(v.left, 0, weak),
                    eq(v.bottom, C.plus(v.top, v.height), medium),
                    // Right is at least left + width
                    eq(v.right,  C.plus(v.left, v.width), medium),
                    iwStay,
                    ihStay
                ];
                for(cn in cs) {
                    solver.add_constraint(cn);
                }

                // Propigate viewport size changes.
                var reCalc = function () {

                    // Measurement should be cheap here.
                    var iwv = rand(MAX, MIN);
                    var ihv = rand(MAX, MIN);

                    solver.add_edit_var(iw);
                    solver.add_edit_var(ih);

                    solver.begin_edit();
                    solver.suggest_value(iw, iwv)
                    .suggest_value(ih, ihv);
                    solver.resolve();
                    solver.end_edit();

                    equal(v.top.value, 0, 'top = 0');
                    equal(v.left.value, 0, 'left = 0');
                    equal(true,v.bottom.value <= MAX, 'bottom <= MAX');
                    equal(true,v.bottom.value >= MIN, 'bottom >= MIN');
                    equal(true,v.right.value <= MAX, 'right <= MAX');
                    equal(true,v.right.value >= MIN, 'right >= MIN');

                }

                reCalc();
                reCalc();
                reCalc();
            });

            it('errorWeights', function () {
                var solver = new SimplexSolver();

                var weak = Strength.weak;
                var medium = Strength.medium;
                var strong = Strength.strong;

                var x = new Variable('x',100);
                var y = new Variable('y',200);
                var z = new Variable('z',50);

                equal(x.value, 100, 'x = 100');
                equal(y.value, 200, 'y = 200');
                equal(z.value,  50, 'z = 50');

                solver.add_constraint(new Equation(z,   x,   weak))
                .add_constraint(new Equation(x,  20,   weak))
                .add_constraint(new Equation(y, 200, strong));

                equal(x.value,  20, 'x = 20');
                equal(y.value, 200, 'y = 200');
                equal(z.value,  20, 'z = 20');

                solver.add_constraint(
                    new Inequality(C.plus(z, 150), Op.LEQ, y, medium)
                    );

                equal(x.value,  20, 'x = 20');
                equal(y.value, 200, 'y = 200');
                equal(z.value,  20, 'z = 20');
            });

        });

        run();

    }

}