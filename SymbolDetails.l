import system'io;
import system'text;
import system;
import system'collections;
import system'routines;
import extensions;
import extensions'text;
import extensions'routines;
import system'culture;


// enum Kind { STATIC, FIELD, ARG, VAR, NONE };

class SymbolDetails
{
    field type;
    field kind;
    field index;
    
    constructor(String t, String k, IntNumber i)
    {
        type := t;
        kind := k;
        index:= i;
    }
    
    method getType()
    {^type;}
    
    method getKind()
    {^kind;}
    
    method getIndex()
    {^index;}
}