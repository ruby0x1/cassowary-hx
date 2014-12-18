
class Point_test extends mohxa.Mohxa {

    public function new() {

        super();

        describe('Point', function(){
            it('should be constructable', function(){
                trace(new Point());
                trace(new Point(4, 7));
                trace(new Point(3, 5, '1'));
            });
        });

        run();

    }

}