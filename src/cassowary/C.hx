package cassowary;

import cassowary.Expression;
import cassowary.Variable;

class C {

    public static var logging = false;
    public static var verbose = false;

    static inline function expr_from_var_or_value(v:Dynamic) : Expression {
        if(Std.is(v, Float) || Std.is(v,Int)) {
            return Expression.from_constant(v);
        }

        if(Std.is(v, AbstractVariable)) {
            return Expression.from_variable(v);
        }

        return v;
    }

    public static inline function plus(e1:Dynamic,e2:Dynamic) : Expression {
        e1 = expr_from_var_or_value(e1);
        e2 = expr_from_var_or_value(e2);
        return e1.plus(e2);
    }
    public static inline function minus(e1:Dynamic,e2:Dynamic) : Expression {
        e1 = expr_from_var_or_value(e1);
        e2 = expr_from_var_or_value(e2);
        return e1.minus(e2);
    }
    public static inline function divide(e1:Dynamic,e2:Dynamic) : Expression {
        e1 = expr_from_var_or_value(e1);
        e2 = expr_from_var_or_value(e2);
        return e1.divide(e2);
    }
    public static inline function times(e1:Dynamic,e2:Dynamic) : Expression {
        e1 = expr_from_var_or_value(e1);
        e2 = expr_from_var_or_value(e2);
        return e1.times(e2);
    }

    public static var epsilon = 1e-8;
    public static inline function approx(a:Float, b:Float) {
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
    public static inline function inc() {
        // println('count=$count');
        return count++;
    }

}