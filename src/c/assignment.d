/*
    assignment.c  -- Assignment.
*/
/*
    Copyright (c) 1984, Taiichi Yuasa and Masami Hagiya.
    Copyright (c) 1990, Giuseppe Attardi.
    Copyright (c) 2001, Juan Jose Garcia Ripoll.

    ECL is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    See file '../Copyright' for full details.
*/

#include "ecl.h"
#include <string.h>

cl_object
cl_set(cl_object var, cl_object val)
{
	if (!SYMBOLP(var))
		FEtype_error_symbol(var);
	if (var->symbol.stype == stp_constant)
		FEinvalid_variable("Cannot assign to the constant ~S.", var);
	return1(SYM_VAL(var) = val);
}

cl_object
setf_namep(cl_object fun_spec)
{	cl_object cdr;
	int intern_flag; 
	if (CONSP(fun_spec) && !endp(cdr = CDR(fun_spec)) &&
	    endp(CDR(cdr)) && CAR(fun_spec) == @'setf') {
		cl_object sym, fn_name = CAR(cdr);
		sym = si_get_sysprop(fn_name, @'si::setf-symbol');
		if (sym == Cnil) {
			cl_object fn_str = fn_name->symbol.name;
			cl_index l = fn_str->string.fillp + 7;
			cl_object string = cl_alloc_simple_string(l);
			char *str = string->string.self;
			strncpy(str, "(SETF ", 6);
			strncpy(str + 6, fn_str->string.self, fn_str->string.fillp);
			str[l-1] = ')';
			if (fn_name->symbol.hpack == Cnil)
				sym = make_symbol(string);
			else
				sym = intern(string, fn_name->symbol.hpack, &intern_flag);
			si_put_sysprop(fn_name, @'si::setf-symbol', sym);
		}
		return(sym);
	} else {
		return(OBJNULL);
	}
}

cl_object
si_setf_namep(cl_object arg)
{
	cl_object x;

	x = setf_namep(arg);
	@(return ((x != OBJNULL) ? x : Cnil))
}

@(defun si::fset (fun def &optional macro pprint)
	cl_type t;
	bool mflag;
@
	mflag = !Null(macro);
	if (!SYMBOLP(fun)) {
		cl_object sym = setf_namep(fun);
		if (sym == OBJNULL)
			FEtype_error_symbol(fun);
		if (mflag)
			FEerror("Cannot define a macro with name (SETF ~S).", 1, fun);
		fun = CADR(fun);
		si_put_sysprop(fun, @'si::setf-symbol', sym);
		si_rem_sysprop(fun, @'si::setf-lambda');
		si_rem_sysprop(fun, @'si::setf-method');
		si_rem_sysprop(fun, @'si::setf-update');
		fun = sym;
	}
	if (fun->symbol.isform && !mflag)
		FEerror("~S, a special form, cannot be redefined as a function.",
			1, fun);
	clear_compiler_properties(fun);
	if (fun->symbol.hpack &&
	    fun->symbol.hpack->pack.locked &&
	    SYM_FUN(fun) != OBJNULL)
		funcall(3, @'warn', make_simple_string("~S is being redefined."), fun);
	t = type_of(def);
	if (t == t_bytecodes || t == t_cfun || t == t_cclosure) {
	        SYM_FUN(fun) = def;
#ifdef CLOS
	} else if (t == t_gfun) {
		SYM_FUN(fun) = def;
#endif
	} else {
		FEinvalid_function(def);
	}
	fun->symbol.mflag = !Null(macro);
	if (pprint != Cnil)
		si_put_sysprop(fun, @'si::pretty-print-format', pprint);
	@(return fun)
@)

cl_object
cl_makunbound(cl_object sym)
{
	if (!SYMBOLP(sym))
		FEtype_error_symbol(sym);
	if ((enum stype)sym->symbol.stype == stp_constant)
		FEinvalid_variable("Cannot unbind the constant ~S.", sym);
	SYM_VAL(sym) = OBJNULL;
	@(return sym)
}
	
cl_object
cl_fmakunbound(cl_object sym)
{
	if (!SYMBOLP(sym)) {
		cl_object sym1 = setf_namep(sym);
		if (sym1 == OBJNULL)
			FEtype_error_symbol(sym);
		sym = CADR(sym);
		cl_remprop(sym, @'si::setf-lambda');
		cl_remprop(sym, @'si::setf-method');
		cl_remprop(sym, @'si::setf-update');
		cl_fmakunbound(sym1);
		@(return sym)
	}
	clear_compiler_properties(sym);
#ifdef PDE
	cl_remprop(sym, @'defun');
#endif
	if (sym->symbol.hpack &&
	    sym->symbol.hpack->pack.locked &&
	    SYM_FUN(sym) != OBJNULL)
		funcall(3, @'warn', make_simple_string("~S is being redefined."),
			sym);
	SYM_FUN(sym) = OBJNULL;
	sym->symbol.mflag = FALSE;
	@(return sym)
}

void
clear_compiler_properties(cl_object sym)
{
	if (ecl_booted) {
		si_unlink_symbol(sym);
		funcall(2, @'si::clear-compiler-properties', sym);
	}
}

#ifdef PDE
void
record_source_pathname(cl_object sym, cl_object def)
{
  if (symbol_value(@'si::*record-source-pathname-p*') != Cnil)
    (void)funcall(3, @'si::record-source-pathname', sym, def);
}
#endif /* PDE */

static cl_object system_properties = OBJNULL;

cl_object
si_get_sysprop(cl_object sym, cl_object prop)
{
	cl_object plist = gethash_safe(sym, system_properties, Cnil);
	@(return ecl_getf(plist, prop, Cnil));
}

cl_object
si_put_sysprop(cl_object sym, cl_object prop, cl_object value)
{
	cl_object plist;
	assert_type_symbol(sym);
	plist = gethash_safe(sym, system_properties, Cnil);
	sethash(sym, system_properties, si_put_f(plist, value, prop));
	@(return value);
}

cl_object
si_rem_sysprop(cl_object sym, cl_object prop)
{
	cl_object plist, found;
	assert_type_symbol(sym);
	plist = gethash_safe(sym, system_properties, Cnil);
	plist = si_rem_f(plist, prop);
	found = VALUES(1);
	sethash(sym, system_properties, plist);
	@(return found);
}

void
init_assignment(void)
{
#ifdef PDE
	SYM_VAL(@'si::*record-source-pathname-p*') = Cnil;
#endif
	ecl_register_root(&system_properties);
	system_properties =
	    cl__make_hash_table(@'eq', MAKE_FIXNUM(1024), /* size */
				make_shortfloat(1.5), /* rehash-size */
				make_shortfloat(0.7)); /* rehash-threshold */
}
