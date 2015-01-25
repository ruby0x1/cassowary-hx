import ExprParser;

class ParseTest {

    static function main() {

        var expr = '(screen.w/2) - (canvas.w/2)';
        var parser = new ExprParser(expr);
        var res = parser.parse();

        trace(eval(res));


    }

    static function eval(e:Exp):String {
        return switch(e) {
            case EConstant(f):
                Std.string(f);
            case EIdent(f):
                f;
            case EBinop(op, lhs, rhs):
                switch(op) {
                    case add:
                        eval(lhs) +'+'+ eval(rhs);
                    case sub:
                        eval(lhs) +'-'+ eval(rhs);
                    case mul:
                        eval(lhs) +'*'+ eval(rhs);
                    case div:
                        eval(lhs) +'/'+ eval(rhs);
                }
            case EPar(e):
                '('+eval(e)+')';
            case ENeg(e):
                '-'+eval(e);
        }
    }

}