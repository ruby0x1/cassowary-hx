
enum ExprToken {
    TIdent(v:String);
    TConstant(v:String);
    TOp(v:ExprOp);
    TIeq(v:ExprIeq);

    TBrOpen;
    TBrClose;
    TEof;
}

enum ExprOp {
    mul;
    div;
    sub;
    add;
}

enum ExprIeq {
    leq;
    geq;
}

enum Exp {
    EConstant(v:Float);
    EIdent(i:String);
    EBinop(op:ExprOp, lhs:Exp, rhs:Exp);
    EInequality(op:ExprIeq, rhs:Exp);
    EPar(e:Exp);
    ENeg(e:Exp);
}

class ExprLexer extends hxparse.Lexer implements hxparse.RuleBuilder {
    public static var tok = @:rule [
        "[(]" => TBrOpen,
        "[)]" => TBrClose,

        "[*]" => TOp(ExprOp.mul),
        "[/]" => TOp(ExprOp.div),
        "[\\-]" => TOp(ExprOp.sub),
        "[+]" => TOp(ExprOp.add),
        "(<=)" => TIeq(ExprIeq.leq),
        "(>=)" => TIeq(ExprIeq.geq),

        "[\r\n\t ]" => lexer.token(tok),
        "-?(([1-9][0-9]*)|0)(.[0-9]+)?([eE][\\+\\-]?[0-9]?)?" => TConstant(lexer.current),
        '([_.a-zA-Z][_a-zA-Z0-9])+' => TIdent(lexer.current),
        "" => TEof
    ];
}


class ExprParser extends hxparse.Parser<hxparse.LexerTokenSource<ExprToken>, ExprToken> implements hxparse.ParserBuilder {

    public function new(input:String) {
        var lex = new ExprLexer(byte.ByteData.ofString(input), 'expression');
        super( new hxparse.LexerTokenSource(lex, ExprLexer.tok) );
    }

    var count = 0;
    var list = [];

    function parse_item() : Dynamic {
        return switch stream {
            case [TConstant(c)]:
                // trace('const $c');
                c;
            case [TIdent(v)]:
                // trace('ident $v');
                v;
            case _:
                var f = peek(0);
                junk();
                trace('ppp $f');
                f;
        }
    }

    function parse_expr() : Dynamic {
        return switch stream {
            case [TBrOpen, e = parse_expr(), TBrClose]:
                trace('( expr ) = ' + e);
                e;
            case [lhs = parse_item(), TOp(op), rhs = parse_item()]:
                trace('expr = $lhs $op $rhs');
                { LHS:lhs, RHS:rhs, OP:op }
            case _:
                var f = peek(0);
                junk();
                trace('peeked $f');
                f;
        }
    }

    function binop(lhs:Exp, op:ExprOp, rhs:Exp) {
        return switch [rhs, op] {
            case [EBinop(op2 = add | sub, e3, e4), mul | div]:
                // precedence
                EBinop(op2, EBinop(op, lhs, e3), e4);
            case _:
                EBinop(op, lhs, rhs);
        }
    }

    function parse_next( lhs:Exp ) {
        return switch stream {
            case [TOp(op), rhs = parse()]:
                binop(lhs, op, rhs);
            case _:
                lhs;
        }
    }

    public function parse() {
        return switch stream {
            case [TConstant(v)]:
                parse_next(EConstant(Std.parseFloat(v)));
            case [TIdent(i)]:
                parse_next(EIdent(i));
            case [TIeq(ieq), rhs = parse()]:
                EInequality(ieq, rhs);
            case [TBrOpen, e = parse(), TBrClose]:
                parse_next(EPar(e));
            case [TOp(sub), e = parse()]:
                parse_next(ENeg(e));
        }

    }
}
