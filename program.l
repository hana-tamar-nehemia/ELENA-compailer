/*
id:318750254 sara lea amir
id:324068113 tamar nechemia
*/
import system'io;
import system'text;
import system;
import system'collections;
import system'routines;
import extensions;
import extensions'text;
import extensions'routines;
import system'culture;

/*
  the main program:
  extracts VM files
  Reads from each file line by line
  Sends the line for translation by command type
*/
public program()
{
    console.printLine("enter path");
    until( string path := console.readLine(), path.isEmpty())
    {
    
        var dir := Directory.assign(path);
        var files := dir.getFiles("*.jack").asEnumerable().forEach:(item)  // loop over all jack files in the directory
        {
                tokenizer my_tokenizer := new tokenizer(item);// create Tokenizer
                
                //יוצר קובץ T
                my_tokenizer.begin(); // token פתיחה
                
                while(my_tokenizer.file_not_end())  // אם לא נגמר הקובץ 
                {
                        my_tokenizer.advance();   //קורא שורה חדשה
                };
                 my_tokenizer.end();  // token סיום
            
            
                // יצירת קובץ VM
                ArrayList arr := new ArrayList();
                arr := my_tokenizer.get_arr();
                parser my_parser := new parser(item,arr);
              
        };
           console.printLine("enter another path");
  };              
     console.readChar(); 
}

  /*
  C:\Users\tamar\elena\T5\11\Average
  C:\Users\tamar\elena\T5\11\ComplexArrays
  C:\Users\tamar\elena\T5\11\ConvertToBin
  C:\Users\tamar\elena\T5\11\Pong
  C:\Users\tamar\elena\T5\11\Seven
  C:\Users\tamar\elena\T5\11\Square
  */