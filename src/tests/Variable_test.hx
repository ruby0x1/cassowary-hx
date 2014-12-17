package tests;

import Variable;

class Variable_test extends mohxa.Mohxa {

    public function new() {

        super();

        describe('Variable', function(){
            describe('ctor', function(){
                it('names/maps correctly', function(){
                    new Variable({name:'x'});
                    new Variable({name:'y', value:2});
                    equal(CVariable.map.get('x').value+'', '0', 'x mapped, value 0');
                    equal(CVariable.map.get('y').value+'', '2', 'y mapped, value 2');
                });

                it('has the correct properties', function(){
                    var x = new Variable({ name:'x', value:25 });

                    equal(x.value, 25, 'x value = 25');
                    equal(x.val+'', '25', 'valueOf = 25');
                    equal(x.is_external, true, 'is_external');
                    equal(x.is_dummy, false, 'not is_dummy');
                    equal(x.is_pivotable, false, 'not is_pivotable');
                    equal(x.is_restricted, false, 'not is_restricted');
                });
            });
        });

        describe('DummyVariable', function(){
            describe('ctor', function(){
                it('serializes', function(){
                    var d = new DummyVariable({name:'foo'});
                    equal(d.val+'','dummy', 'valueOf = dummy');
                });

                it('has the correct properties', function(){
                    var x = new DummyVariable({name:'x'});

                    equal(x.val+'','dummy', 'valueOf = dummy');
                    equal(x.is_external, false, 'not is_external');
                    equal(x.is_dummy, true, 'is_dummy');
                    equal(x.is_pivotable, false, 'not is_pivotable');
                    equal(x.is_restricted, true, 'is_restricted');
                });
            });
        });

        describe('ObjectiveVariable', function(){
            describe('ctor', function(){
                it('serializes', function(){
                    var o = new ObjectiveVariable({name:'obj'});
                    equal(o.val+'','obj', 'valueOf = obj');
                });

                it('has the correct properties', function(){
                    var x = new ObjectiveVariable({name:'x'});

                    equal(x.val+'','obj', 'valueOf = obj');
                    equal(x.is_external, false, 'not is_external');
                    equal(x.is_dummy, false, 'not is_dummy');
                    equal(x.is_pivotable, false, 'not is_pivotable');
                    equal(x.is_restricted, false, 'not is_restricted');
                });
            });
        });

        describe('SlackVariable', function(){
            describe('ctor', function(){
                it('has the correct properties', function(){
                    var x = new SlackVariable({name:'x'});

                    equal(x.val+'','slack', 'valueOf = slack');
                    equal(x.is_external, false, 'not is_external');
                    equal(x.is_dummy, false, 'not is_dummy');
                    equal(x.is_pivotable, true, 'is_pivotable');
                    equal(x.is_restricted, true, 'is_restricted');
                });
            });
        });

        run();

    }

}