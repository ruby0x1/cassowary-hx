


import tests.Point_test;
import tests.Strength_test;
import Constraint;

class Main extends luxe.Game {

    override function config( config:luxe.AppConfig ) {
        config.has_window = false;
        return config;
    } //config

    override function ready() {

        new Point_test();
        new Strength_test();

        var s = new Variable({ value:3 });
        trace(s);

    } //ready

} //Main