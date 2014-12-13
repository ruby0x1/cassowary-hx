


import tests.Point_test;

class Main extends luxe.Game {

    override function config( config:luxe.AppConfig ) {
        config.has_window = false;
        return config;
    } //config

    override function ready() {

        new Point_test();

        var s = new Variable({ value:3 });
        trace(s);

    } //ready

} //Main