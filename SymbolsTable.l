import system'io;
import system'text;
import system;
import system'collections;
import system'routines;
import extensions;
import extensions'text;
import extensions'routines;
import system'culture;




class SymbolsTable
{ 
    field staticCount;          // keeps a running index of static variables for class scope
	field fieldCount;           // keeps a running index of field variables for class scope
	field argCount;             // keeps a running index of argument variables for subroutine scope
	field varCount;             // keeps a running index of var variables for subroutine scope  
    field classScopeMap;        // hash table for class scope
	field subroutineScopeMap;   // hash table for subroutine scope 
 
    field ifCounter; 
    field whileCounter;
     
    constructor()
    {         
        staticCount := 0;
        fieldCount := 0;
        argCount := 0;
        varCount := 0;
        
        classScopeMap := new Map<string,SymbolDetails>();
        subroutineScopeMap := new Map<string,SymbolDetails>();
           
        ifCounter := 0;
        whileCounter := 0;        
    }
    
    // Starts a new subroutine scope (resets the subroutine's symbol table)
    method startSubroutine()
    {
        subroutineScopeMap.clear();
        argCount := 0;
        varCount := 0;
        ifCounter := 0;
        whileCounter := 0; 
    }
    
    // Defines a new identifier of a given name, type, and kind 
    //and assigns it a running index. symboltable::STATIC and FIELD have class scope, 
    //ARG and VAR have subroutine scope
    method define(String name, String type, String kind)
    {
        
        kind =>
        "static"{classScopeMap[name] := new SymbolDetails(type,kind,staticCount);
		        staticCount += 1;}
        "field"{classScopeMap[name] := new SymbolDetails(type,kind,fieldCount);
		        fieldCount += 1;}
        "arg"{subroutineScopeMap[name] := new SymbolDetails(type,kind,argCount);
		        argCount += 1;}
        "var"{subroutineScopeMap[name] := new SymbolDetails(type,kind,varCount);
		        varCount += 1;}
     }
		       
   
    
    // Returns the number of variables of the given kind already defined in the current scope
    method varCount(String kind)
    {
        kind =>
        "static"{^staticCount;}
        "field"{^fieldCount;}
        "arg"{^argCount;}
        "var"{^varCount;}
        :{^-1;}  
    } 
    
    // Returns the kind of the named identifier in the current scope.
    // If the identifier is unknown in the current scope, returns NONE
    method kindOf(String name)
    {       
    console.printLine(subroutineScopeMap.containsKey(name));   
                  console.readChar();
                  
        if(subroutineScopeMap.containsKey(name))
        {    console.printLine("1");   
                  console.readChar();
                  
                  ^subroutineScopeMap[name].getKind();};
        if(classScopeMap.containsKey(name))
        {console.printLine("2");   
                  console.readChar();
                  ^classScopeMap[name].getKind();};
        ^"NONE";
    }
    
    // Returns the type of the named identifier in the current scope
    method typeOf(String name)
    { 
        if(subroutineScopeMap.containsKey(name))
        {^subroutineScopeMap[name].getType();};
        if(classScopeMap.containsKey(name))
        {^classScopeMap[name].getType();};
        ^"";
    }
    
    // Returns the index assigned to the named identifier
    method indexOf(String name)
    {
        if(subroutineScopeMap.containsKey(name))
        {^subroutineScopeMap[name].getIndex();};
        if(classScopeMap.containsKey(name))
        {^classScopeMap[name].getIndex();};
        ^-1;
    }
    
    //מחזיר מונה של איפ ומעלה אחכ ב1
    method getIfCounter()
    {
       var ret := ifCounter.toString();
       ifCounter += 1;
       ^ ret
    }
      //מחזיר מונה של איפ ומעלה אחכ ב1
    method getWhileCounter()
    {
       var ret := whileCounter.toString();
       whileCounter += 1;
       ^ ret
    }
    
}