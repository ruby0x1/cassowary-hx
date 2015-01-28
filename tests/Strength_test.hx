
import cassowary.Strength;
import cassowary.Constraint;
import cassowary.SimplexSolver;
import cassowary.Variable;
import cassowary.C;

class Strength_test extends mohxa.Mohxa {

    public function new() {

        super();


        describe('Strength', function () {

            describe('::statics', function () {
                it('is an instance of Strength', function () {
                    equal(Std.is(Strength.required,Strength), true, 'Strength.required');
                    equal(Std.is(Strength.strong, Strength), true, 'Strength.strong');
                    equal(Std.is(Strength.medium, Strength), true, 'Strength.medium');
                    equal(Std.is(Strength.weak, Strength), true, 'Strength.weak');
                });
            });


            describe('statics required values', function () {
                it('is true for Strength.required', function () {
                    equal(Strength.required.is_required, true, 'Strength.required.is_required is true');
                });
                it('is false for all the others', function () {
                    equal(Strength.strong.is_required, false, 'Strength.strong.is_required == false');
                    equal(Strength.medium.is_required, false, 'Strength.medium.is_required == false');
                    equal(Strength.weak.is_required, false, 'Strength.weak.is_required == false');
                });
            });

            describe('is sane', function () {
                it('should be sane', function () {
                    var s = new SimplexSolver();

                    // x = 10
                    // y = 20
                    // z = x (weak)
                    // z = y (strong)
                    // z == 20

                    var x = new Variable('x');
                    var y = new Variable('y');
                    var z = new Variable('z');

                    s.add_constraint(new Equation(z, x, Strength.weak))
                    .add_constraint(new Equation(z, y, Strength.strong));

                    s.add_stay(x)
                     .add_stay(y)
                     .add_edit_var(x)
                     .add_edit_var(y).begin_edit();

                    s.suggest_value(x, 10)
                     .suggest_value(y, 20).resolve();
                    s.end_edit();

                    equal(true, C.approx(x.value, 10.0), 'x.value = 10.0');
                    equal(true, C.approx(y.value, 20.0), 'y.value = 20.0');
                    equal(true, C.approx(z.value, 20.0), 'z.value = 30.0');
                });
            });

            describe('multiple stays/edits', function () {
                var s = new SimplexSolver();

                var x = new Variable('x');
                var y = new Variable('y');
                var z = new Variable('z');

                s.add_constraint(new Equation(z, x, Strength.weak))
                .add_constraint(new Equation(z, y, Strength.strong));

                it('has sane edit behavior', function () {
                    s.add_stay(x)
                    .add_stay(y)
                    .add_edit_var(x)
                    .add_edit_var(y).begin_edit();

                    s.suggest_value(x, 10)
                    .suggest_value(y, 20).resolve();
                    s.end_edit();

                    equal(true, C.approx(x.value, 10.0), 'x.value = 10.0');
                    equal(true, C.approx(y.value, 20.0), 'y.value = 20.0');
                    equal(true, C.approx(z.value, 20.0), 'z.value = 30.0');
                });

                it('can edit a second time correctly', function () {
                    s.add_edit_var(x)
                    .add_edit_var(y).begin_edit();

                    s.suggest_value(x, 30)
                    .suggest_value(y, 50).resolve();
                    s.end_edit();

                    equal(true, C.approx(x.value, 30.0), 'x.value = 30.0');
                    equal(true, C.approx(y.value, 50.0), 'y.value = 50.0');
                    equal(true, C.approx(z.value, 50.0), 'z.value = 50.0');
                });
            });

        }); //Strength

        run();

    }

}