
import system'io;
import system'text;
import system;
import system'collections;
import system'routines;
import extensions;
import extensions'text;
import extensions'routines;
import system'culture;

class tokenizer
{
    field jackfileReader;
    ArrayList list_tokens;
    field lineIndex;
    field currentToken;
    field outFileName;
    field outFile;
    field ArrayList arr;
    
      constructor(String path)
    {
        arr := new ArrayList();
        jackfileReader := File.assign(path).textreader();
        lineIndex := 0;
        currentToken := "";
        list_tokens := new ArrayList();
        outFileName := path.replace(".jack","T.xml");   // create file name 
        outFile := File.assign(outFileName).logger();
    }
    
     method get_arr()
    {
        ^arr;
    }
    
   method addTok(String tok)
    {
        arr.append:tok;
    }
    
     method file_not_end()
    {
        ^(jackfileReader.Available);
    }
    
   method advance()
    {
       CharValue cv := 9;                                              // ascii val of Tab key
                //קורא שורה חדשה
                var line := "";
                //מדלג על קורות ריקות ועל הערות מסוג רגילות
                while((line.isEmpty() && self.file_not_end()) || ( line.startingWith("//")&& self.file_not_end()))       // loop over empty lines or lines with only white spaces
                {
                        line := jackfileReader.readLine();
                        while(line.isNonempty() && line.at(0).isWhitespace()) // clear all white spaces from current line
                        {
                                line := line.trim().trim(cv);
                        };
                };
                   

                 // זורק שורות של הערות מסוג 2               
                if(line.containing("/*"))                     // if currentToken is beginning of multi line comment 
                {
                    var flag := true;  
                    int i := line.indexOf("/*");  
                    if (i>0)// אם ההערה ל
                    {
                      self.createTokens(line.Substring(0,i));
                      int i :=  line.indexOf("*/");
                      if(i == line.Length-2)// אם ההערה נגמרת בסוף השורה יוצא מכל הפונקציה
                      {
                          flag :=false;
                           line:="";
                      } 
                    };
                    
                    int i1 :=  line.indexOf("/*");  
                    int i2 :=  line.indexOf("*/");  
                    if(i1==0 && i2 == line.Length-2 )// אם ההערה נגמרת בסוף השורה יוצא מכל הפונקציה
                    {
                        flag :=false;
                        line :="";
                    };
                    
                    if( i1==0 && i2 == -1)
                    {
                        line:="";
                    };
                    // אם ההערה יותר משורה אחת
                    if(flag)                                         // if comment ending is not found in current line
                    {
                        
                        var line := jackfileReader.readLine();
                        while(line.indexOf("*/") == -1 && self.file_not_end())             // read from file until comment ending is found in line
                        {
                            line := jackfileReader.readLine();
                        };
                        
                        var index := line.indexOf("*/");
                        
                        // אם הערה נגמרת באמצע השורה
                        if(index + 2 < line.Length-1) //line+++          // if there is more code in line after comment ending
                        {
                            line := line.Substring(index + 2);
                            while(line.isNonempty() && line.at(0).isWhitespace()) // clear all white spaces from begining and end of current line
                            {
                                line := line.trim().trim(cv);
                            };
                        }
                        //כשהערה בסוף השורה
                        else                                            // if there is no more code in line after comment ending
                        {
                            line:="";       // set current line to be empty list so outer loop reads a new line
                        };
                    };
                };  
                self.createTokens(line);                        
        }
        
    method createTokens(string line)
    {
        string digits := "0123456789";
        string symbols := "{}()[].,;+-*/&|<>=~";
        string letters := "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        letters := letters+letters.lowerCase()+"_";
        
        string thisLine := line.trim();//מוציא רווחים מתחילת וסוף השורה
        
        while(thisLine!="" && thisLine!="\n")// כל עוד השורה לא נגמרה ולא הגענו לירידת שורה מכוונת
        {
            //סטרינג
            if (thisLine[0]=="""")
            {
                int i:= self.getStringIndex(thisLine.Substring(1));
                string token:= thisLine.Substring(1, i); //  מחזיר מחרוזת בלי גרשיים
                
                outFile.writeLine("<stringConstant> " + token + " </stringConstant>");
                
                thisLine:= thisLine.Substring(i+2).trimLeft();
                self.addTok( """" + token + """");
            }
            //מספר
            else if(digits.indexOf(0,thisLine[0])!=-1 && digits.indexOf(0,thisLine[0])!=digits.Length)
            {
                int i:= self.getNumIndex(thisLine.Substring(0)); //לוקח את כל המספרים ברצף
                string token:= thisLine.Substring(0, i);// שם ב token
                
                outFile.writeLine("<integerConstant> " + token + " </integerConstant>");
                
                thisLine:= thisLine.Substring(i).trimLeft();
                self.addTok(token);
            }
            //סימבול
            else if(symbols.indexOf(0,thisLine[0])!=-1 && symbols.indexOf(0,thisLine[0])!=symbols.Length)
            {
                if(thisLine.startingWith("//"))
                   {
                    thisLine:="";
                   }
                else
                   {
                    string token:= thisLine[0];
                    
                            token=>
                            "<"{outFile.writeLine("<symbol> &lt; </symbol>");}
                            ">"{outFile.writeLine("<symbol> &gt; </symbol>");}
                            "&"{outFile.writeLine("<symbol> &amp; </symbol>");}
                            :{outFile.writeLine("<symbol> " + token + " </symbol>");};  
                                                      
                    thisLine := thisLine.Substring(1).trimLeft(); 
                    self.addTok(token);
                  };
            }
            
            //משתנה או מילה שמורה
            else if(letters.indexOf(0,thisLine[0])!=-1 && letters.indexOf(0,thisLine[0])!=letters.Length)
            {
                int i:= self.getIdentifierIndex(thisLine.Substring(1));
                string token:= thisLine.Substring(0, i+1);
                thisLine:= thisLine.Substring(i+1).trimLeft();
                
               if(self.tokenType(token) == "IDENTIFIER")
               {
                    outFile.writeLine("<identifier> " + token + " </identifier>");
               }
               else if(self.tokenType(token)== "KEYWORD")
               {
                    outFile.writeLine("<keyword> " + token + " </keyword>");
               }; 
                self.addTok(token);
            }
            else{//shouldn't happen
                thisLine:= thisLine.Substring(1).trimLeft(); 
            };
        }  
        
   }   
   method getStringIndex(string line)
    {
        int i:= 0;
        while(i<line.Length && line[i]!="""")
        {
            i+=1;
        };
        ^i;
    }

   method getNumIndex(string line)
    {
        string digits := "0123456789";
        int i:= 0;
        while(i<line.Length && digits.indexOf(0,line[i])!=-1)
        {
            i+=1;
        };
        ^i;
    }
    
    method getIdentifierIndex(string line)
    {
        string letters := "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        letters:= letters+letters.lowerCase()+"_0123456789";
        int i := 0;
        while(i<line.Length && letters.indexOf(0,line[i])!=-1)
        {
            i+=1;
        };
        ^i;
    }
    
    
    method tokenType(string currentToken)
    {
        
        if("{}()[].,;+-*/&|<>=~".containing(currentToken))
        { ^ "SYMBOL"; };
       
        if( currentToken == "class" || currentToken == "constructor" || currentToken == "function" || currentToken == "method" ||
         currentToken == "field" || currentToken == "static"  || currentToken == "var" || currentToken == "int" || currentToken == "char" ||
         currentToken == "boolean" || currentToken == "void" || currentToken == "true" || currentToken == "false" ||
         currentToken == "null" || currentToken == "this" || currentToken == "let"  ||currentToken == "do"|| 
         currentToken == "if" || currentToken == "else" || currentToken == "while" || currentToken == "return")
        {^  "KEYWORD";};
        
        ^ "IDENTIFIER";
   }
   
     method begin(){outFile.writeLine("<tokens>");}
     method end(){outFile.writeLine("</tokens>");}
     
 }





