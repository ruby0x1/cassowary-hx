
import Tableau;

class Tableau_test extends mohxa.Mohxa {

    public function new() {

        super();

        describe('Tableau', function(){
            describe('ctor', function(){

                it("doesn't blow up", function(){
                    new Tableau();
                });

                it('has sane properties', function(){
                    var tab = new Tableau();
                    equal(0, Lambda.count(tab.columns), 'columns = empty');
                    equal(0, Lambda.count(tab.rows), 'rows = empty');
                    equal(0, tab.infeasible_rows.length, 'infeasible_rows = empty');
                    equal(0, tab.external_rows.length, 'external_rows = empty');
                    equal(0, tab.external_parametric_vars.length, 'external_parametric_vars = empty');
                });
            });
        });

        run();

    }

}