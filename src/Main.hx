


import tests.*;

class Main extends luxe.Game {

    override function config( config:luxe.AppConfig ) {
        config.has_window = false;
        return config;
    } //config

    override function ready() {

        mohxa.Mohxa.use_colors = false;
        // C.logging = true;

        // new Tableau_test();
        // new Variable_test();
        // new SymbolicWeight_test();
        // new Strength_test();
        // new SimplexSolver_test();
        new Point_test();

    } //ready

} //Main