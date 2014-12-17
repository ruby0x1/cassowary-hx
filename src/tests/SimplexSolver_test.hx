package tests;

import SimplexSolver;
import Constraint;
import Variable;

class SimplexSolver_test extends mohxa.Mohxa {

    public function new() {

        super();

        describe('SimplexSolver', function(){
            describe('should be constructable without args', function(){
                new SimplexSolver();
            });
        });

        describe('add_edit_var', function(){
            it("works with required strength", function() {

                var solver = new SimplexSolver();
                var a = new Variable({ name: "a" });

                solver.add_constraint(new StayConstraint(a, Strength.strong, 0));
                solver.resolve();

                equal(0.0, a.value, 'a.value = 0');

                solver.add_edit_var(a, Strength.required)
                      .begin_edit()
                      .suggest_value(a, 2)
                      .resolve();

                equal(2.0, a.value, 'a.value = 2');

            });

            it("works with required strength after many suggestions", function() {

                var solver = new SimplexSolver();
                var a = new Variable({ name: "a" });
                var b = new Variable({ name: "b" });

                solver.add_constraint(new StayConstraint(a, Strength.strong, 0))
                      .add_constraint(new Equation(a,b,Strength.required))
                      .resolve();

                equal(0.0, b.value, 'a.value = 0');
                equal(0.0, a.value, 'b.value = 0');

                solver.add_edit_var(a, Strength.required)
                      .begin_edit()
                      .suggest_value(a, 2)
                      .resolve();

                equal(2.0, a.value, 'a.value = 2');
                equal(2.0, b.value, 'b.value = 2');

                solver.suggest_value(a, 10)
                      .resolve();

                equal(10.0, a.value, 'a.value = 10');
                equal(10.0, b.value, 'b.value = 10');

            });

            it('works with weight', function () {

                var x = new Variable({ name: 'x' });
                var y = new Variable({ name: 'y' });
                var solver = new SimplexSolver();

                solver.add_stay(x).add_stay(y)
                      .add_constraint(new Equation(x, y, Strength.required))
                      .add_edit_var(x,Strength.medium,1)
                      .add_edit_var(y,Strength.medium,10).begin_edit();

                solver.suggest_value(x, 10)
                      .suggest_value(y, 20);

                solver.resolve();

                equal(true, C.approx(x, 20), 'x = 20');
                equal(true, C.approx(y, 20), 'y = 20');
            });
        });

        run();

    }

}