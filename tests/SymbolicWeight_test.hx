
import cassowary.SymbolicWeight;

class SymbolicWeight_test extends mohxa.Mohxa {

    public function new() {

        super();

        describe('SymbolicWeight', function(){
            describe('ctor', function(){
                describe('no args', function(){
                    var w = new SymbolicWeight();
                    it('has the right weight', function(){
                        equal(0.0, w.value, 'weight: 0');
                    });
                });
                describe('var args', function(){
                    var w = new SymbolicWeight([1,1]);
                    it('has the right weight', function(){
                        equal(1001.0, w.value, 'weight: 1001');
                    });
                });
            });
        });

        //:note: not done JSON serialization yet

        run();

    }

}