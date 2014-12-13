package tests;

import Strength;

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

        }); //Strength

            // it('is sane', function () {
            //     var s = new c.SimplexSolver();

            //     // x = 10
            //     // y = 20
            //     // z = x (weak)
            //     // z = y (strong)
            //     // z == 20

            //     var x = new c.Variable({ name: 'x' });
            //     var y = new c.Variable({ name: 'y' });
            //     var z = new c.Variable({ name: 'z' });

            //     s.addConstraint(new c.Equation(z, x, c.Strength.weak))
            //     .addConstraint(new c.Equation(z, y, c.Strength.strong));

            //     s.addStay(x)
            //     .addStay(y)
            //     .addEditVar(x)
            //     .addEditVar(y).beginEdit();

            //     s.suggestValue(x, 10)
            //     .suggestValue(y, 20).resolve();
            //     s.endEdit();
            //     assert.isTrue(c.approx(x.value, 10.0));
            //     assert.isTrue(c.approx(y.value, 20.0));
            //     assert.isTrue(c.approx(z.value, 20.0));
            // });

            // describe('multiple stays/edits', function () {
            //     var s = new c.SimplexSolver();

            //     var x = new c.Variable({ name: 'x' });
            //     var y = new c.Variable({ name: 'y' });
            //     var z = new c.Variable({ name: 'z' });

            //     s.addConstraint(new c.Equation(z, x, c.Strength.weak))
            //     .addConstraint(new c.Equation(z, y, c.Strength.strong));

            //     it('has sane edit behavior', function () {
            //         s.addStay(x)
            //         .addStay(y)
            //         .addEditVar(x)
            //         .addEditVar(y).beginEdit();

            //         s.suggestValue(x, 10)
            //         .suggestValue(y, 20).resolve();
            //         s.endEdit();

            //         assert.isTrue(c.approx(x.value, 10.0));
            //         assert.isTrue(c.approx(y.value, 20.0));
            //         assert.isTrue(c.approx(z.value, 20.0));
            //     });

            //     it('can edit a second time correctly', function () {
            //         s.addEditVar(x)
            //         .addEditVar(y).beginEdit();

            //         s.suggestValue(x, 30)
            //         .suggestValue(y, 50).resolve();
            //         s.endEdit();

            //         assert.isTrue(c.approx(x.value, 30.0));
            //         assert.isTrue(c.approx(y.value, 50.0));
            //         assert.isTrue(c.approx(z.value, 50.0));
            //     });
            // });
        

        run();

    }

}