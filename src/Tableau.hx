
import Variable;

class Tableau  {

        // columns is a mapping from variables which occur in expressions to the
        // set of basic variables whose expressions contain them
        // i.e., it's a mapping from variables in expressions (a column) to the
        // set of rows that contain them
    public var columns:Map<AbstractVariable, Array<AbstractVariable>>;
        // _rows maps basic variables to the expressions for that row in the tableau
    public var rows:Map<AbstractVariable, Expression>;

        // the collection of basic variables that have infeasible rows
        // (used when reoptimizing)
    var infeasible_rows : Array<AbstractVariable>;
        // the set of rows where the basic variable is external this was added to
        // the C++ version to reduce time in setExternalVariables()
    var external_rows : Array<AbstractVariable>;
        // the set of external variables which are parametric this was added to the
        // C++ version to reduce time in setExternalVariables()
    var external_parametric_vars : Array<AbstractVariable>;

    public function new() {
        columns = new Map();
        rows = new Map();

        infeasible_rows = [];
        external_rows = [];
        external_parametric_vars = [];
    }

    public function note_removed( v:AbstractVariable, subject:AbstractVariable ) {
        C.fnenter("note_removed: " + v + ' / ' + subject);
        var col = columns.get(v);
        if(col != null) {
            col.remove(subject);
        }
    }

    public function note_added( v:AbstractVariable, subject:AbstractVariable ) {
        C.fnenter("note_added: " + v + ' / ' + subject);
        if(subject != null) {
            insert_column_var(v, subject);
        }
    }


        // Convenience function to insert a variable into
        // the set of rows stored at columns[param_var],
        // creating a new set if needed
    function insert_column_var( param_var:AbstractVariable, rowvar: AbstractVariable ) {

        var rowset = columns.get(param_var);
        if(rowset == null) {
            rowset = [];
            columns.set(param_var, rowset);
        }

        rowset.push(rowvar);
    }

    function add_row(aVar:AbstractVariable, expr:Expression) {

        var val = aVar.vvalue == '' ? Std.string(aVar.value) : aVar.vvalue;
        C.fnenter("addRow: " + val + ", " + expr);

        rows.set(aVar, expr);

        expr.each(function(clv, coeff) {
            insert_column_var(clv, aVar);
            if(clv.is_external) {
                this.external_parametric_vars.push(clv);
            }
        });

        if(aVar.is_external) {
            this.external_rows.push(aVar);
        }

        C.log(this);

    } //add_row

    function remove_column(aVar: AbstractVariable) {

        C.fnenter("remove_column:" + aVar);

        var _rows = this.columns.get(aVar);
        if(_rows != null) {
            columns.remove(aVar);
            for(clv in _rows) {
                var expr = rows.get(clv);
                expr.terms.remove(aVar);
            } //for
        } else {
            C.log('\t Could not find var $aVar in columns');
        }

        if(aVar.is_external) {
            external_rows.remove(aVar);
            external_parametric_vars.remove(aVar);
        }

    } //remove_column

    function columns_has_key( subject:AbstractVariable ) {
        return columns.get(subject) != null;
    }

    function remove_row( aVar:AbstractVariable ) {

        C.fnenter("remove_row:" + aVar);

        var expr = rows.get(aVar);
        if(expr == null) throw "null expression";

        expr.each(function(clv, coeff) {
            var varset = columns.get(clv);
            if (varset != null) {
                C.log("Tableau.remove_row removing from varset: " + aVar);
                varset.remove(aVar);
            }
        });

        this.infeasible_rows.remove(aVar);
        if(aVar.is_external) {
            external_rows.remove(aVar);
        }

        rows.remove(aVar);

        C.log("Tableau.remove_row returning " + expr);

        return expr;

    } //remove_row

    function substitute_out( oldvar:AbstractVariable, expr:Expression ) {

        C.fnenter("substitute_out: " + oldvar + ", " + expr);
        C.log(this);

        var varset = columns.get(oldvar);
        for(v in varset) {
            var row = rows.get(v);
            row.substitute_out(oldvar, expr, v, this);
            if(v.is_restricted && row.constant < 0) {
                infeasible_rows.push(v);
            }
        }

        if(oldvar.is_external) {
            external_rows.push(oldvar);
            external_parametric_vars.remove(oldvar);
        }

        columns.remove(oldvar);

    } //substitute_out

    public function get_internal_info() {

        var rowsize = Lambda.count(rows);
        var retstr = "Tableau Information:\n";
            retstr += "Rows: " + rowsize;
            retstr += " (= " + (rowsize - 1) + " constraints)";
            retstr += "\nColumns: " + Lambda.count(columns);
            retstr += "\nInfeasible Rows: " + infeasible_rows.length;
            retstr += "\nExternal basic variables: " + external_rows.length;
            retstr += "\nExternal parametric variables: ";
            retstr += external_parametric_vars.length;
            retstr += "\n";

        return retstr;

    } //get_internal_info

    function toString() {

        var bstr = "Tableau:\n";

        for(row in rows.keys()) {
            bstr += row;
            bstr += " <==> ";
            bstr += rows[row];
            bstr += "\n";
        }

            bstr += "\nColumns:\n";
            bstr += columns;
            bstr += "\nInfeasible rows: ";
            bstr += infeasible_rows;
            bstr += "\n External basic variables: ";
            bstr += external_rows;
            bstr += "\n External parametric variables: ";
            bstr += external_parametric_vars;

        return bstr;

    } //toString

} //Tableau
