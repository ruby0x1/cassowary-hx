

class C {

    public static var epsilon = 1e-8;
    public static function approx(a:Float, b:Float) {
        if (a == b) return true;

        if (a == 0) {
            return (Math.abs(b) < epsilon);
        }

        if (b == 0) {
            return (Math.abs(a) < epsilon);
        }

        return (Math.abs(a - b) < Math.abs(a) * epsilon);
    } //approx

    static var count = 1;
    public static function inc() {
        return count++;
    }

}