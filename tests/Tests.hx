

class Tests {

    static function main() {

        mohxa.Mohxa.use_colors = false;
        // C.logging = true;
        // C.verbose = true;

        new Tableau_test();
        new Variable_test();
        new SymbolicWeight_test();
        new Strength_test();
        new SimplexSolver_test();
        new Point_test();
        new EndToEnd_test();
        new Constraint_test();
        new Expression_test();

        mohxa.Mohxa.finish();

    }

} //Tests