

class C {

    public static var logging = true;
    public static var verbose = true;

    public static function fnenter(v:Dynamic) {
        if(logging) {
            Sys.print('* ');
            Sys.println(v);
        }
    }
    public static function fnexit(v:Dynamic) {
        if(logging) {
            Sys.print('- ');
            Sys.println(v);
        }
    }

    public static function log(v:Dynamic) {
        if(logging && verbose) Sys.println(v);
    }

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