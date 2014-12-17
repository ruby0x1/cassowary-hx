
import Expression;
import Variable;

class C {

    public static var logging = false;
    public static var verbose = false;

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
        if(logging) Sys.println(v);
    }

    public static function logv(v:Dynamic) {
        if(logging && verbose) Sys.println(v);
    }

    static function expr_from_var_or_value(v:Dynamic) : Expression {
        if(Std.is(v, Float) || Std.is(v,Int)) {
            return Expression.from_constant(v);
        } else if(Std.is(v, AbstractVariable)) {
            return Expression.from_variable(v);
        }
        return v;
    }

    public static function plus(e1:Dynamic,e2:Dynamic) : Expression {
        e1 = expr_from_var_or_value(e1);
        e2 = expr_from_var_or_value(e2);
        return e1.plus(e2);
    }
    public static function minus(e1:Dynamic,e2:Dynamic) : Expression {
        e1 = expr_from_var_or_value(e1);
        e2 = expr_from_var_or_value(e2);
        return e1.minus(e2);
    }
    public static function divide(e1:Dynamic,e2:Dynamic) : Expression {
        e1 = expr_from_var_or_value(e1);
        e2 = expr_from_var_or_value(e2);
        return e1.divide(e2);
    }
    public static function times(e1:Dynamic,e2:Dynamic) : Expression {
        e1 = expr_from_var_or_value(e1);
        e2 = expr_from_var_or_value(e2);
        return e1.times(e2);
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
        // Sys.println('count=$count');
        return count++;
    }

}