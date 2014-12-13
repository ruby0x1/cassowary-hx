package tests;

class Point_test extends mohxa.Mohxa {

    public function new() {

        super();

        describe('Point', function(){
            it('should be constructable', function(){
                log(new Point(4, 7));
                log(new Point(3, 5, '1'));
            });
        });

        run();

    }

}