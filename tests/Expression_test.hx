
import cassowary.Expression;
import cassowary.Variable;
import cassowary.C;

class Expression_test extends mohxa.Mohxa {

    public function new() {

        super();

        describe('Expression', function () {
            it('is constructable with 3 variables as arguments', function () {
                var x = new Variable('x',167);
                var e = new Expression(x, 2, 3);
                equal(e+'', '3 + 2*167', 'constructed with x, 2, 3');
            });

            it('is constructable with one parameter', function () {
                equal(new Expression(4)+'', '4', 'constructed with 4');
            });

            it('plus', function () {
                var x = new Variable('x',167);
                equal(C.plus(4, 2)+'', '6', 'plus(4,2) = 6');
                equal(C.plus(x, 2)+'', '2 + 1*167', 'plus(x,2) = 2 + 1*167');
                equal(C.plus(3, x)+'', '3 + 1*167', 'plus(3,x) = 3 + 1*167');
            });

            it('plus_solve', function () {
                var x = new Variable('x',167);
                equal(C.plus(4, 2)+'', '6', 'plus(4,2) = 6');
                equal(C.plus(x, 2)+'', '2 + 1*167', 'plus(x,2) = 2 + 1*167');
                equal(C.plus(3, x)+'', '3 + 1*167', 'plus(3,x) = 3 + 1*167');
            });

            it('times', function () {
                var x = new Variable('x',167);
                equal(C.times(x, 3)+'', '3*167', 'times(x,3) = 3*167');
                equal(C.times(7, x)+'', '7*167', 'times(7,x) = 7*167');
            });

            it('complex', function () {
                var x = new Variable('x',167);
                var y = new Variable('y',2);
                var ex = C.plus(4, C.plus(C.times(x, 3), C.times(2, y)));
                equal(ex+'', '4 + 3*167 + 2*2', '(4 + (x*3)+(2*y)) = 4 + 3*167 + 2*2');
            });

            it('zero_args', function () {
                var exp = new Expression();
                equal(0.0, exp.constant, 'constant = 0');
                equal(0, Lambda.count(exp.terms), 'terms size = 0');
            });

            it('one_number', function () {
                var exp = new Expression(10);
                equal(10.0, exp.constant, 'constant = 10');
                equal(0, Lambda.count(exp.terms), 'terms size = 0');
            });

            it('one_variable', function () {
                var v = new Variable(10);
                var exp = new Expression(v);
                equal(0.0, exp.constant, 'constant = 0');
                equal(1, Lambda.count(exp.terms), 'terms size = 1');
                equal(1.0, exp.terms.get(v), 'terms[v] = 1.0');
            });

            it('variable_number', function () {
                var v = new Variable(10);
                var exp = new Expression(v, 20);
                equal(0.0, exp.constant, 'constant = 0');
                equal(1, Lambda.count(exp.terms), 'terms size = 1');
                equal(20.0, exp.terms.get(v), 'terms[v] = 20.0');
            });

            it('variable_number_number', function () {
                var v = new Variable(10);
                var exp = new Expression(v, 20, 2);
                equal(2.0, exp.constant, 'constant = 2');
                equal(1, Lambda.count(exp.terms), 'terms size = 1');
                equal(20.0, exp.terms.get(v), 'terms[v] = 20.0');
            });

            it('clone', function () {
                var v = new Variable(10);
                var exp = new Expression(v, 20, 2);
                var clone = exp.clone();

                equal(clone.constant, exp.constant, 'constant =');
                equal(Lambda.count(clone.terms), Lambda.count(exp.terms), 'terms length =');
                equal(20.0, clone.terms.get(v), 'clone terms[v] = 20');
            });

            it('isConstant', function () {
                var e1 = new Expression();
                var e2 = new Expression(10);
                var e3 = new Expression(new Variable(10), 20, 2);

                equal(true, e1.is_constant, 'e1 is_constant');
                equal(true, e2.is_constant, 'e2 is_constant');
                equal(false, e3.is_constant, 'e3 not is_constant');
            });

            it('multiplyMe', function () {
                var v = new Variable(10);
                var e = new Expression(v, 20, 2).multiply_me(-1);

                equal(e.constant, -2.0, 'constant = -20');
                equal(v.value, 10.0, 'v.value = 10');
                equal(e.terms.get(v), -20.0, 'terms[v] = -20');
            });

            it('times', function () {
                var v = new Variable(10);
                var a = new Expression(v, 20, 2);

                // times a number
                var e = a.timesf(10);
                equal(e.constant, 20, 'constant = 20');
                equal(e.terms.get(v), 200, 'terms[v] = 200');

                // times a constant exression
                e = a.times(new Expression(10));
                equal(e.constant, 20, 'constant = 20');
                equal(e.terms.get(v), 200, 'terms[v] = 200');

                // constant expression times another expression
                e = new Expression(10).times(a);
                equal(e.constant, 20, 'constant = 20');
                equal(e.terms.get(v), 200, 'terms[v] = 200');

                //:note: not testing throws atm
                // multiplying two non-constant expressions
                // t.e(c.NonExpression, a, 'times', [a]);
                // assert.throws(a.times.bind(a, a), c.NonExpression);
            });

            it('addVariable', function () {
                var a = new Expression(new Variable(10), 20, 2);
                var v = new Variable(20);

                // implicit coefficient of 1
                a.add_variable(v);
                equal(Lambda.count(a.terms), 2, '2 terms');
                equal(a.terms.get(v), 1, 'terms[v] = 1');

                // add again, with different coefficient
                a.add_variable(v, 2);
                equal(Lambda.count(a.terms), 2, '2 terms');
                equal(a.terms.get(v), 3, 'terms[v] = 3');

                // add again, with resulting 0 coefficient. should remove the term.
                a.add_variable(v, -3);
                equal(Lambda.count(a.terms), 1, '1 term');
                equal(null, a.terms.get(v), 'terms[v] = null');

                // try adding the removed term back, with 0 coefficient
                a.add_variable(v, 0);
                equal(Lambda.count(a.terms), 1, '1 term');
                equal(null, a.terms.get(v), 'terms[v] = null');
            });

            it('add_expr_variable', function () {
                var a = new Expression(new Variable(10), 20, 2);
                var v = new Variable(20);

                // should work just like addVariable
                a.add_expr(v, 2);
                equal(Lambda.count(a.terms), 2, '2 terms');
                equal(a.terms.get(v), 2, 'terms[v] = 2');
            });

            it('add_expr', function () {
                var va = new Variable(10);
                var vb = new Variable(20);
                var vc = new Variable(5);
                var a = new Expression(va, 20, 2);

                // different variable and implicit coefficient of 1, should make new term
                a.add_expr(new Expression(vb, 10, 5));
                equal(Lambda.count(a.terms), 2, '2 terms');
                equal(a.constant, 7, 'constant = 7');
                equal(a.terms.get(vb), 10, 'terms[vb] = 10');

                // same variable, should reuse existing term
                a.add_expr(new Expression(vb, 2, 5));
                equal(Lambda.count(a.terms), 2, '2 terms');
                equal(a.constant, 12, 'constant = 12');
                equal(a.terms.get(vb), 12, 'terms[vb] = 12');

                // another variable and a coefficient,
                // should multiply the constant and all terms in the new expression
                a.add_expr(new Expression(vc, 1, 2), 2);
                equal(Lambda.count(a.terms), 3, '3 terms');
                equal(a.constant, 16, 'constant = 16');
                equal(a.terms.get(vc), 2, 'terms[vc] = 2');
            });

            it('plus', function () {
                var va = new Variable(10);
                var vb = new Variable(20);
                var a = new Expression(va, 20, 2);
                var b = new Expression(vb, 10, 5);

                var p = a.plus(b);
                notequal(a, p, 'a != p');
                notequal(a, b, 'a != b');

                equal(p.constant, 7, 'constant = 7');
                equal(Lambda.count(p.terms), 2, '2 terms');
                equal(p.terms.get(va), 20, 'terms[va] = 20');
                equal(p.terms.get(vb), 10, 'terms[vb] = 10');
            });

            it('minus', function () {
                var va = new Variable(10);
                var vb = new Variable(20);
                var a = new Expression(va, 20, 2);
                var b = new Expression(vb, 10, 5);

                var p = a.minus(b);
                notequal(a, p, 'a != p');
                notequal(a, b, 'a != b');

                equal(p.constant, -3, 'constant = -3');
                equal(Lambda.count(p.terms), 2, '2 terms');
                equal(p.terms.get(va), 20, 'terms[va] = 20');
                equal(p.terms.get(vb), -10, 'terms[vb] = -10');
            });

            it('divide', function () {
                var va = new Variable(10);
                var vb = new Variable(20);
                var a = new Expression(va, 20, 2);

                // assert.throws(a.divide.bind(a, 0), c.NonExpression);
                // t.e(c.NonExpression, a, 'divide', [0]);

                var p = a.dividef(2);
                equal(p.constant, 1, 'constant = 1');
                equal(p.terms.get(va), 10, 'terms[va] = 10');

                // assert.throws(a.divide.bind(a, new Expression(vb, 10, 5)), c.NonExpression);
                // t.e(c.NonExpression, a, 'divide', [new Expression(vb, 10, 5)]);
                var ne = new Expression(vb, 10, 5);
                // assert.throws(ne.divide.bind(ne, a), c.NonExpression);

                p = a.divide(new Expression(2));
                equal(p.constant, 1, 'constant = 1');
                equal(p.terms.get(va), 10, 'terms[va] = 10');
            });

            it('coefficientFor', function () {
                var va = new Variable(10);
                var vb = new Variable(20);
                var a = new Expression(va, 20, 2);

                equal(a.coefficient_for(va), 20, 'coefficient_for va = 20');
                equal(a.coefficient_for(vb), 0, 'coefficient_for vb = 0');
            });

            it('setVariable', function () {
                var va = new Variable(10);
                var vb = new Variable(20);
                var a = new Expression(va, 20, 2);

                // set existing variable
                a.set_variable(va, 2);
                equal(Lambda.count(a.terms), 1, '1 term');
                equal(a.coefficient_for(va), 2, 'terms[va] = 2');

                // set new variable
                a.set_variable(vb, 2);
                equal(Lambda.count(a.terms), 2, '2 terms');
                equal(a.coefficient_for(vb), 2, 'terms[vb] = 2');
            });

            it('anyPivotableVariable', function () {

                // t.e(c.InternalError, new Expression(10), 'anyPivotableVariable');
                var e = new Expression(10);
                // assert.throws(e.anyPivotableVariable.bind(e), c.InternalError);
                // t.e(c.InternalError, new Expression(10), 'anyPivotableVariable');

                var va = new Variable(10);
                var vb = new SlackVariable();
                var a = new Expression(va, 20, 2);

                equal(null, a.any_pivotable_variable(), 'any_pivotable_variable = null');

                a.set_variable(vb, 2);
                equal((vb:AbstractVariable), a.any_pivotable_variable(), 'any_pivotable_variable = vb');
            });

            it('substituteOut', function () {
                var v1 = new Variable(20);
                var v2 = new Variable(2);
                var a = new Expression(v1, 2, 2); // 2*v1 + 2

                // new variable
                a.substitute_out(v1, new Expression(v2, 4, 4));
                equal(a.constant, 10, 'constant = 10');
                equal(null, a.terms.get(v1), 'terms[v1] = null');
                equal(a.terms.get(v2), 8, 'terms[v2] = 8');

                // existing variable
                a.set_variable(v1, 1);
                a.substitute_out(v2, new Expression(v1, 2, 2));

                equal(a.constant, 26, 'constant = 26');
                equal(null, a.terms.get(v2), 'terms[v2] = null');
                equal(a.terms.get(v1), 17, 'terms[v1] = 17');
            });

            it('newSubject', function () {
                var v = new Variable(10);
                var e = new Expression(v, 2, 5);

                equal(e.new_subject(v), 1 / 2, 'new subject = 1/2');
                equal(e.constant, -2.5, 'constant = -2.5');
                equal(null, e.terms.get(v), 'terms[v] = null');
                equal(true, e.is_constant, 'is constant');
            });

            it('changeSubject', function () {
                var va = new Variable(10);
                var vb = new Variable(5);
                var e = new Expression(va, 2, 5);

                e.change_subject(vb, va);
                equal(e.constant, -2.5, 'constant = -2.5');
                equal(null, e.terms.get(va), 'terms[va] = null');
                equal(e.terms.get(vb), 0.5, 'terms[vb] = 0.5');
            });

            it('toString', function () {
                var v = new Variable('v',5);

                equal(Expression.from_constant(10)+'', '10', '= 10');
                equal(new Expression(v, 0, 10)+'', '10 + 0*5', '= 10 + 0*5');

                var e = new Expression(v, 2, 10);
                equal(e+'', '10 + 2*5', '= 10 + 2*5');

                e.set_variable(new Variable('b',2), 4);
                equal(e+'', '10 + 2*5 + 4*2', '= 10 + 2*5 + 4*2');
            });

            it('equals', function () {
                var v = new Variable('v',5);

                equal(true, new Expression(10).equals(new Expression(10)), 'e(10) = e(10)');
                equal(false, new Expression(10).equals(new Expression(1)), 'e(10) != e(1)');
                equal(true, new Expression(v, 2, -1).equals(new Expression(v, 2, -1)), 'e(v,2,-1) = e(v,2,-1)');
                equal(false, new Expression(v, -2, 5).equals(new Expression(v, 3, 6)), 'e(v,-2,5) != e(v,3,6)');
            });

            it('plus', function () {
                var x = new Variable('x',167);
                var y = new Variable('y',10);

                equal(C.plus(2, 3)+'', '5', 'plus(2,3) = 5');
                equal(C.plus(x, 2)+'', '2 + 1*167', 'plus(x,2) = 2 + 1*167');
                equal(C.plus(3, x)+'', '3 + 1*167','plus(3,x) = 3 + 1*167' );
                equal(C.plus(x, y)+'', '1*167 + 1*10', 'plus(x,y) = 1*167 + 1*10' );
            });

            it('minus', function () {
                var x = new Variable('x',167);
                var y = new Variable('y',10);

                equal(C.minus(2, 3)+'', '-1', 'minus(2, 3) = -1');
                equal(C.minus(x, 2)+'', '-2 + 1*167', 'minus(x, 2) = -2 + 1*167');
                equal(C.minus(3, x)+'', '3 + -1*167', 'minus(3, x) = 3 + -1*167');
                equal(C.minus(x, y)+'', '1*167 + -1*10', 'minus(x, y) = 1*167 + -1*10');
            });

            it('times', function () {
                var x = new Variable('x',167);
                var y = new Variable('y',10);

                equal(C.times(2, 3)+'', '6', 'times(2, 3) = 6');
                equal(C.times(x, 2)+'', '2*167', 'times(x, 2) = 2*167');
                equal(C.times(3, x)+'', '3*167', 'times(3, x) = 3*167');
                // assert.throws(C.times.bind(c, x, y), C.NonExpression);
            });

            it('divide', function () {
                var x = new Variable('x',167);
                var y = new Variable('y',10);

                equal(C.divide(4, 2)+'', '2', 'divide(4,2) = 2');
                equal(C.divide(x, 2)+'', '0.5*167', 'divide(x,2) = 0.5*167');
                // assert.throws(c.divide.bind(c, 4, x), c.NonExpression);
                // assert.throws(c.divide.bind(c, x, y), c.NonExpression);
            });
        });

        run();

    }

}