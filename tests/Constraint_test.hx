
import Constraint;
import Expression;
import Variable;

class Constraint_test extends mohxa.Mohxa {

    public function new() {

        super();

        describe('Constraint', function(){
            it('should create expression equations', function () {
                var ex = new Expression(10);
                var c1 = new Equation(ex);
                equal(c1.expression, ex);
            });

            it('can create expressions Variable instances', function () {
                var x = new Variable({ value: 167 });
                var y = new Variable({ value: 2 });
                var cly = new Expression(y);
                cly.add_expr(x);
            });

            it('can create equations from variables and expressions', function () {
                var x = new Variable({ name: 'x', value: 167 });
                var cly = new Expression(2);
                var eq = new Equation(x, cly);
                equal(true, eq.expression.equals(cly.minusv(x)) );
            });

            it('should handle strengths correctly', function () {
                var solver = new SimplexSolver();
                var x = new Variable({ name: 'x', value: 10 });
                var y = new Variable({ name: 'y', value: 20 });
                var z = new Variable({ name: 'z', value: 1 });
                var w = new Variable({ name: 'w', value: 1 });

                // Default weights.
                var e0 = new Equation(x, y);
                solver.add_stay(y);
                solver.add_constraint(e0);
                equal(true,C.approx(x, 20), 'x = 20');
                equal(true,C.approx(y, 20), 'y = 20');

                // Weak.
                var e1 = new Equation(x, z, Strength.weak);
                // console.log('x:', x.value);
                solver.add_stay(x);
                solver.add_constraint(e1);
                equal(true,C.approx(x, 20), 'x = 20');
                equal(true,C.approx(z, 20), 'z = 20');

                // Strong.
                var e2 = new Equation(z, w, Strength.strong);
                solver.add_stay(w);
                solver.add_constraint(e2);
                equal(w.value, 1, 'w = 1');
                equal(z.value, 1, 'z = 1');
            });

            it('can use numbers in place of variables', function () {
                var v = new Variable({ name: 'v', value: 22 });
                var eq = new Equation(v, 5);
                equal(true, eq.expression.equals(C.minus(5, v)), 'eq = 5 - v');
            });

            it('can use equations in place of variables', function () {
                var e = new Expression(10);
                var v = new Variable({ name: 'v', value: 22 });
                var eq = new Equation(e, v);

                equal(true,eq.expression.equals(C.minus(10, v)), 'eq = 10 - v');
            });

            it('works with nested expressions', function () {

                var e1 = new Expression(10);
                var e2 = new Expression(new Variable({ name: 'z', value: 10 }), 2, 4);
                var eq = new Equation(e1, e2);
                equal(true,eq.expression.equals(e1.minus(e2)), 'eq = e1 - e2');
            });

            it('instantiates inequality expressions correctly', function () {
                var e = new Expression(10);
                var ieq = new Inequality(e);
                equal(ieq.expression, e, 'ieq.expr = e');
            });

            it('handles inequality constructors with operator arguments', function () {
                var v1 = new Variable({ name: 'v1', value: 10 });
                var v2 = new Variable({ name: 'v2', value: 5 });
                var ieq = new Inequality(v1, Op.GEQ, v2);

                equal(true,ieq.expression.equals(C.minus(v1, v2)), 'ieq = v1 - v2');

                ieq = new Inequality(v1, Op.LEQ, v2);
                equal(true,ieq.expression.equals(C.minus(v2, v1)), 'ieq = v2 - v1');
            });

            it('handles expressions with variables, operators, and numbers', function () {
                var v = new Variable({ name: 'v', value: 10 });
                var ieq = new Inequality(v, Op.GEQ, 5);

                equal(true,ieq.expression.equals(C.minus(v, 5)), 'ieq = v - 5');

                ieq = new Inequality(v, Op.LEQ, 5);
                equal(true,ieq.expression.equals(C.minus(5, v)), 'ieq = 5 - v');
            });

            it('handles inequalities with reused variables', function () {
                var e1 = new Expression(10);
                var e2 = new Expression(new Variable({ name: 'c', value: 10 }), 2, 4);
                var ieq = new Inequality(e1, Op.GEQ, e2);

                equal(true,ieq.expression.equals(e1.minus(e2)), 'ieq = e1 - e2');

                ieq = new Inequality(e1, Op.LEQ, e2);
                equal(true,ieq.expression.equals(e2.minus(e1)), 'ieq = e2 - e1');
            });

            it('handles constructors with variable/operator/expression args', function () {
                var v = new Variable({ name: 'v', value: 10 });
                var e = new Expression(new Variable({ name: 'x', value: 5 }), 2, 4);
                var ieq = new Inequality(v, Op.GEQ, e);

                equal(true,ieq.expression.equals(C.minus(v, e)), 'ieq = v - e');

                ieq = new Inequality(v, Op.LEQ, e);
                equal(true, ieq.expression.equals( e.minusv(v)), 'ieq = e - v');
            });

            it('handles constructors with expression/operator/variable args', function () {
                var v = new Variable({ name: 'v', value: 10 });
                var e = new Expression(new Variable({ name: 'x', value: 5 }), 2, 4);
                var ieq = new Inequality(e, Op.GEQ, v);

                equal(true,ieq.expression.equals(e.minusv(v)), 'ieq = e - v');

                ieq = new Inequality(e, Op.LEQ, v);
                equal(true,ieq.expression.equals(C.minus(v, e)), 'ieq = v - e');
            });

            it('StayConstraint constant equals stay variable value', function () {
              var stayVariable = new Variable({name:"stay", value:10});
              var stayConstraint = new StayConstraint(stayVariable,
                    // Strength.weak,
                    Strength.required,
                    1);

              var solver = new SimplexSolver();
              solver.auto_solve = true;
              solver.add_constraint(stayConstraint);

              solver.add_edit_var(stayVariable, Strength.strong, 1).begin_edit();
              solver.suggest_value(stayVariable, 20);
              solver.resolve();
              solver.end_edit();

              var value = stayVariable.value;
              var constant = stayConstraint.expression.constant;

              // console.log(constant, value);
              // equal(true,value == 20);

              equal(true,value == 10,'value = 10');
              equal(true,constant == value,'constant = value');
            });
        });

        run();

    }

}