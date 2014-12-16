


import tests.*;

class Main extends luxe.Game {

    override function config( config:luxe.AppConfig ) {
        config.has_window = false;
        return config;
    } //config

    override function ready() {

        mohxa.Mohxa.use_colors = false;

        new Tableau_test();
        // new Point_test();
        // new Strength_test();

    } //ready

} //Main