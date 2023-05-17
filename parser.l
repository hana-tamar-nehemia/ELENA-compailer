
import system'io;
import system'text;
import system;
import system'collections;
import system'routines;
import extensions;
import extensions'text;
import extensions'routines;
import system'culture;


/* class that generates hierarchical xml file of tokenz from a jack file*/
class parser
{
    field tabs;
    field outFileLogger;  
    field xmlfileReader; 
    field lineTxml;
    field key;   
    field value;
    field ArrayList arr_tokens;
    field i;
    
    field writer;
    field SymbolTable;
    field className;
    field funcName;
    field funcType;
    field numArgs;
    
    constructor(String filePath, ArrayList arr)
    {
        i:= 0;
        arr_tokens := new ArrayList();
        arr_tokens := arr; 
        writer := new VMwriter(filePath);

        SymbolTable := new SymbolsTable();
        className := "";
        funcType := "";
        self.compileClass(); 
    }
    
    method compileClass()
    {  
         // class
         // name
        className := arr_tokens[i+1];

        //{
        
        i := 3;
        
        //static || field
        while(arr_tokens[i] == "static" || arr_tokens[i] == "field" )
        {
             console.printLine("static || field"); 
             console.readChar();  
            i := self.compileClassVarDec();
        };
          
        //constructor || function || method
        while(arr_tokens[i] == "constructor" || arr_tokens[i] == "function" || arr_tokens[i] == "method")
        {
             console.printLine("constructor || function || method");  
             console.readChar(); 
            i :=  self.compileSubroutineDec();
        };
        
        // }
    } 
 
    // static || field
    method compileClassVarDec()  
    {                                   
        // static || field
        var kind := arr_tokens[i];
        //type
        var type := arr_tokens[i+1];
        //name
        var name := arr_tokens[i+2];
                                                 
        SymbolTable.define(name, type, kind);
    
        i += 3;
        while(arr_tokens[i] == ",") 
        {
            // ,
            // name
            name :=  arr_tokens[i+1]; 
            SymbolTable.define(name, type, kind);
            i+=2;
        };
    
        // ;
        
        ^i+1;
    }
    
    //constructor || function || method
    method compileSubroutineDec()
    {  
         //open a Metho-scope sembol table
        SymbolTable.startSubroutine();   
        
        //constructor || function || method                    
        var funcKind := arr_tokens[i];
        //return type
        var functype := arr_tokens[i+1];
        // name
        funcName := className + "." + arr_tokens[i+2] ; 
        
        if (funcKind == "method")
        {
           SymbolTable.define("this", className, "arg");
        };
        
        // ( 
        i+=4;
        //argument
        i := self.compileParameterList();
        // )
        
        //body function
        i := self.compileSubroutineBody();    

        ^i;
    }
    

    method compileParameterList()
    { 
        //more argument
        while(arr_tokens[i] != ")")  
        { 
            // type
            String type := arr_tokens[i];
            // name
             String name := arr_tokens[i+1];
             SymbolTable.define(name, type, "arg");

            i+=2;
            //if more argument go again
            if(arr_tokens[i] == ",")
            {
                // ,
                i+=1;
            }
        };
        
        ^i;
    }


    method compileSubroutineBody()
    {
        // {
         i += 2;
        // local var
        while(arr_tokens[i] == "var") 
        {
            console.printLine("var");   
            i := self.compileVarDec();
        };
        
        var CountVar := SymbolTable.varCount("var");
        
         if(funcType == "constructor")
        {
           
            writer.writeFunction(className +".new", CountVar);
            // push the number as argument for Memory.alloc
             var CountField := SymbolTable.varCount("field");
            writer.writePush("constant", CountField);
            // call func Memory.alloc with 1 argument
            writer.writeCall("Memory.alloc", 1);
            // point to the new memory that was allocated so 
            //this has the contant of fields
            writer.writePop("pointer", 0); 
        }
        else
        {
              console.printLine("function");   
                  console.readChar();
                    
              writer.writeFunction(funcName, CountVar);
        };
        
        if(funcType == "method")        
	    {
            // push "this" of calling object
		    writer.writePush("argument", 0);
            // set  pointer  to "this" of method to the calling object 
		    writer.writePop("pointer", 0); 
	    };
     
        // subroutine's statements
        i := self.compileStatements();  
        
        // }
        
        ^i+1;   
    }
    
    method compileVarDec()
    {
        // var
        var kind := arr_tokens[i]; 
        // type
        var type := arr_tokens[i+1];
        // name
        var name := arr_tokens[i+2];
        
        SymbolTable.define(name, type,kind);
        
        i += 3;
        while(arr_tokens[i] == ",")
        {
            // name
            name := arr_tokens[i+1];
            SymbolTable.define(name, type, kind);
            i+=2;
        };
        
         ^i+1;
    }
    
    method compileStatements()
    {
        
        while(arr_tokens[i] != "}") // if has more statements               
        {             
            if (arr_tokens[i] == "let"){ i := self.compileLet(); }
            else if (arr_tokens[i] == "if"){ i := self.compileIf();}
            else if (arr_tokens[i] == "do"){ i := self.compileDo();  }
            else if (arr_tokens[i] == "return"){ i := self.compileReturn(); }
            else if (arr_tokens[i] == "while"){ i := self.compileWhile();};
        };
        
        ^i;                       
    }

    method compileLet()
    {   
        var isArr := false;             
        // let
        
        // name
        var name := arr_tokens[i+1];
        
        
        i+=2;
        if( arr_tokens[i] == "[")
        {
             // push base address of array
               
             console.printLine("writePush00");   
             console.readChar();
             
           writer.writePush(self.kind_TO_segment(SymbolTable.kindOf(name)),SymbolTable.indexOf(name));  
          
            // [
            i+=1;
            i := self.compileExpression();
            // ]
            
          
           // add index to the base address
            writer.writeArithmetic("add");                                                                  
            isArr := true;
            i+=1;
        };
        
       
        
        i+=1;
        i := self.compileExpression();
        
         console.printLine("end of compileExpression in let");   
         console.readChar();
        // ;
        if(isArr)
        {
            // save right side of expretion in temp segment
            writer.writePop("temp", 0);
            // write the calculated address into pointer
            writer.writePop("pointer", 1);                
            // push right side of expretion into the stack         
            writer.writePush("temp", 0); 
            // write the calculated expretion into the calculated address
            writer.writePop("that", 0);                             
        }
        
        // =
        
        else
        {
            console.printLine("writePop");   
                  console.readChar();
            // save right side of expretion in the right segment
              console.printLine(name);   
                  console.readChar();
                  string s := SymbolTable.kindOf(name);
            writer.writePop(self.kind_TO_segment(SymbolTable.kindOf(name)),SymbolTable.indexOf(name));  
            
        };
        ^i+1;
    }
    
    method compileIf()
    {
        // if
        // (
        i+=2;
        i := self.compileExpression(); 
        // )
        
        var IF_labelCount :=  SymbolTable.getIfCounter();
        //conditional jump 
        
        writer.writeArithmetic("not");
        writer.writeIf("IF_FALSE" + IF_labelCount);                                                              
        //writer.writeGoto("IF_FALSE" + IF_labelCount);
        //writer.writeLabel("IF_TRUE" + IF_labelCount); 
        
        // {
        i+=2; 
        i := self.compileStatements();
        // }

        if(arr_tokens[i+1] == "else")
        {
            // if was TRUE goto "END IF" lable
            writer.writeGoto("IF_END" + IF_labelCount);
            writer.writeLabel("IF_FALSE" + IF_labelCount);
            
            // else
            // {
            i+=3;
            i := self.compileStatements();
            // }
            writer.writeLabel("IF_END" + IF_labelCount);
        }
         else
        {
            // if no "else block" "IF FALSE" lable is used as "END IF" 
            writer.writeLabel("IF_FALSE" + IF_labelCount);
        };
        
        ^i+1;
    }
 
    method compileWhile()
    {
        var WHILE_labelCount :=  SymbolTable.getWhileCounter();
        writer.writeLabel("WHILE_EXP" + WHILE_labelCount);
        // while
        // (
        i+=2;
        i := self.compileExpression();
        // )

        writer.writeArithmetic("not");
        writer.writeIf("WHILE_END" + WHILE_labelCount);
        
        // {
        i+=2;
        i := self.compileStatements();
        // }
        
        writer.writeGoto("WHILE_EXP" + WHILE_labelCount);
        writer.writeLabel("WHILE_END" + WHILE_labelCount);
        
        ^i+1;
    }
    
    method compileDo()
    {
        // do
        i+=1;
        var name :=  arr_tokens[i];
        var fullName := "";
        numArgs := 0;
        
        i+=1;
        if(arr_tokens[i] == ".")
        {
            var name2; 
            // .
            // if is var name
            if(SymbolTable.kindOf(name) != "NONE")                      
            {
                //name after the "."
                name2 := arr_tokens[i+1];
                // push var addres as first param for method
                  console.printLine("writePush1");   
                 console.readChar();
                writer.writePush(self.kind_TO_segment(SymbolTable.kindOf(name)),SymbolTable.indexOf(name));  
                // add subroutine name to class name
                fullName := SymbolTable.typeOf(name) + "." + name2;                        
                numArgs := 1;
            }
            // is a class name
            else                                                        
            {
                fullName := name + "." + name2        // add subroutine name to class name
            };
            i+=2;
        }
        // Calling own class method
        else                                                            
        {
            writer.writePush("pointer", 0); 
            // push this as first argument
            numArgs := 1;                            
            fullName := className + "." + name;
        };
        
        // (
        i+=1;
        i := self.compileExpressionList();
        // )
        
        writer.writeCall(fullName, numArgs);                            
        writer.writePop("temp", 0); 
        
        i += 1;

        // ;
        
        ^i+1;
    }
    
    //יוצאים בלי תו
    method compileReturn()
    {                    
        // return
        i+=1;
        if(arr_tokens[i] != ";")
        {
           i := self.compileExpression();
        }
        else
        {
            writer.writePush("constant",0);
        };
        
        writer.writeReturn();
        // ;
         
        ^i+1;                      
    }
    
    method subRoutineCall()
    {
        var name :=  arr_tokens[i];
        var fullName := "";
        numArgs := 0;
                 console.printLine(name);   
                  console.readChar();
        
        i+=1;
           console.printLine(arr_tokens[i] + "befor if");   
                  console.readChar();
        if(arr_tokens[i] == ".")
        {
            var name2; 
            // .
            // if is var name
            if(SymbolTable.kindOf(name) != "NONE")                      
            {
                  console.printLine(name2);   
                  console.readChar();
                //name after the "."
                name2 := arr_tokens[i+1];
                // push var addres as first param for method
                  console.printLine("writePush2");   
                  console.readChar();
                writer.writePush(self.kind_TO_segment(SymbolTable.kindOf(name)),SymbolTable.indexOf(name));  
                // add subroutine name to class name
                console.printLine(SymbolTable.typeOf(name));   
                console.readChar();
                fullName := SymbolTable.typeOf(name) + "." + name2;                        
                numArgs := 1;
            }
            // is a class name
            else                                                        
            {
                name2 := arr_tokens[i+1];
                console.printLine(name + "else");   
                console.readChar();
                fullName := name + "." + name2        // add subroutine name to class name
            };
            i+=2;
        }
        // Calling own class method
        else                                                            
        {
            writer.writePush("pointer", 0); 
            // push this as first argument
            numArgs := 1;      
             console.printLine(name + "else 2");   
                console.readChar();                      
            fullName := className + "." + name;
        };
          console.printLine(" before compileExpressionList in subbcall");   
        console.readChar();
        // (
        i+=1;
        i := self.compileExpressionList();
        // )
 
        
        console.printLine(numArgs.toString() + "  numArgs before print");   
        console.readChar();
                  
        writer.writeCall(fullName, numArgs);                            
       // writer.writePop("temp", 0); 
        ^i+1;
    }
    
    method extractVal(String tok)
    {
        tok=>
        "&lt;"{^"<"}
        "&gt;"{^">"}
        "&amp;"{^"&"}
        :{^tok};
        
    }
    
    method compileExpression() 
    {
          console.printLine("term");   
                  console.readChar();
        //term 
        i := self.compileTerm();
        

        string ops := "+-*/&|<>=";
        
        string nextVal := self.extractVal(arr_tokens[i]);
        while(ops.indexOf(nextVal)!=-1)
        {
            //op
            var op :=  arr_tokens[i];
            i+=1;
            
            console.printLine("term");   
                  console.readChar();
                  
            //term
            i := self.compileTerm(); 
            op => 
            "+"{writer.writeArithmetic("add");}
            "-"{writer.writeArithmetic("sub");}
            "*"{writer.writeCall("Math.multiply", 2);}
            "/"{writer.writeCall("Math.divide", 2);}
            "|"{writer.writeArithmetic("or");}
            "&"{writer.writeArithmetic("and");}
            "="{writer.writeArithmetic("eq");}
            "<"{writer.writeArithmetic("lt");}
            ">"{writer.writeArithmetic("gt");};
            
            nextVal := self.extractVal(arr_tokens[i]);
        };     
        ^i;              
    }
    

    method compileTerm()  
    {                      
        string type := self.tokenType(arr_tokens[i]);
                  console.printLine(type);   
                  console.readChar();
        if (type == "INTEGERCONSTANT")
            {
                //const int
                writer.writePush("constant", arr_tokens[i]);
                i+=1;
            }
       else if (type == "STRINGCONSTANT") 
            {
                string s := arr_tokens[i].Substring(1, ((arr_tokens[i]).Length - 2));
                writer.writePush("constant", s.Length);
                writer.writeCall("String.new",1);
                for(IntNumber i := 0, i < s.Length, i += 1)
			       {
				      writer.writePush("constant",s.at(i).toChar().toInt());
				      writer.writeCall("String.appendChar",2);
			       };
                i+=1;
            }
        else if (type =="KEYWORD")
            {
                 if(arr_tokens[i] == "this")
                    {
                        writer.writePush("pointer",0);      // this refers to pointer 0
                    }
                 else if(arr_tokens[i] == "true")
                      {
                            writer.writePush("constant",1);
                            writer.writeArithmetic("neg");                          
                      }
                 else if (arr_tokens[i] == "null" || arr_tokens[i] == "false")
                        {
                             writer.writePush("constant",0);
                        };
                 i+=1;
            }
       else if (type == "SYMBOL"){
           console.printLine(arr_tokens[i]);   
           console.readChar();
                    if(arr_tokens[i] == "-" || arr_tokens[i]  == "~")
                    {
                        // unary op
                        var op := arr_tokens[i];
                        i+=1;
                        i := self.compileTerm();
                        op =>
                        "-"{writer.writeArithmetic("neg");}
                        "~"{writer.writeArithmetic("not");};
                    }
                    else if(arr_tokens[i] == "(")
                    {
                        // (
                        i+=1;
                                          
                        i := self.compileExpression(); 
                        // )
                        i+=1;
                    };
                }           
      else if (type =="IDENTIFIER"){
                    string value := arr_tokens[i+1];
                       console.printLine(value);   
                         console.readChar();
                    if(value == "[")
                    {
                         //varName
                         var id := arr_tokens[i];
                        
                         // [
                        i+=2;
                        i := self.compileExpression();
                        // ]
                        
                        console.printLine("writePush3");   
                        console.readChar();
                        // push base address of array
                        writer.writePush(self.kind_TO_segment(SymbolTable.kindOf(id)),SymbolTable.indexOf(id));   
                        // add index to the base address
                        writer.writeArithmetic("add");                                                         
                        // pop address pointer into pointer 1 
                        writer.writePop("pointer",1);                                                           
					    writer.writePush("that",0);
         
                        i+=1;
                    }
                    else if(value == "(" || value == ".")
                    {
                        
                        numArgs := 1;
                       
                        i := self.subRoutineCall();
                    }
                    else
                    {
                        //varName  
                         var id := arr_tokens[i];
                         
                         console.printLine("writePush4");   
                  console.readChar();
                         writer.writePush(self.kind_TO_segment(SymbolTable.kindOf(id)),SymbolTable.indexOf(id));
                       i+=1;
                    };
                  };
                   
        ^i;               
    }
    
    method compileExpressionList()
    {
        var numExpressions := 0;
        
        while(arr_tokens[i] != ")")// , 
        {
            
            numExpressions += 1;
            //expression 
            i := self.compileExpression();
               console.printLine("after compileExpression in compileExpressionList ");   
               console.readChar();
            if(arr_tokens[i] == ",")
            { 
                // ,
                i+=1;
            }
        }; 

        numArgs += numExpressions;
        
        console.printLine(numArgs);   
        console.readChar();
        ^i;                        
    }
    
     method tokenType(string currentToken)
    {
        String c := currentToken.at(0);
        if("{}()[].,;+-*/&|<>=~".containing(currentToken))
        { ^ "SYMBOL"; };
       
        if( currentToken == "class" || currentToken == "constructor" || currentToken == "function" || currentToken == "method" ||
         currentToken == "field" || currentToken == "static"  || currentToken == "var" || currentToken == "int" || currentToken == "char" ||
         currentToken == "boolean" || currentToken == "void" || currentToken == "true" || currentToken == "false" ||
         currentToken == "null" || currentToken == "this" || currentToken == "let"  ||currentToken == "do"|| 
         currentToken == "if" || currentToken == "else" || currentToken == "while" || currentToken == "return")
        {^  "KEYWORD";}
        
         else if("0123456789".containing(c))
        {^ "INTEGERCONSTANT";}
    
        else if(c == """")
        { ^ "STRINGCONSTANT";};
        
        ^ "IDENTIFIER";
   }
   
     method kind_TO_segment(String kind)
    {
        
        String segment := "";
        kind =>
        "static"{segment := "static";}
        "field"{segment := "this";}
        "arg"{segment := "argument";}
        "var"{segment := "local";}
        "NONE"{segment := "NONE";};
        
        ^ segment;
    }

}

