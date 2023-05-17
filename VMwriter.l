import system'io;
import system'text;
import system;
import system'collections;
import system'routines;
import extensions;
import extensions'text;
import extensions'routines;
import system'culture;


class VMwriter
{
    field outFileLogger;
    
    constructor(String filePath)
    {
        outFileLogger := File.assign(filePath.replace(".jack",".vm")).logger();
    }
    
    // Writes a VM push command    
    method writePush(String segment, IntNumber index)
    {
        outFileLogger.writeLine("push " + segment + " " + index.toString());
    }
    
    // Writes a VM pop command    
    method writePop(String segment, IntNumber index)
    {
        outFileLogger.writeLine("pop " + segment + " " + index.toString());
    }
    
    // Writes a VM arithmetic command       
    method writeArithmetic(String command)
    {
        outFileLogger.writeLine(command);
    } 
    
    // Writes a VM label command       
    method writeLabel(String label)
    {
        outFileLogger.writeLine("label " + label);
    } 
    
    // Writes a VM goto command       
    method writeGoto(String label)
    {
        outFileLogger.writeLine("goto " + label);
    }
    
    // Writes a VM if-goto command       
    method writeIf(String label)
    {
        outFileLogger.writeLine("if-goto " + label);
    }
    
    // Writes a VM call command       
    method writeCall(String name, IntNumber nArgs)
    {
        outFileLogger.writeLine("call " + name + " " + nArgs.toString());
    }
    
    // Writes a VM function command       
    method writeFunction(String name, IntNumber nLocals)
    {
        outFileLogger.writeLine("function " + name + " " + nLocals.toString());
    }
    
    // Writes a VM return command       
    method  writeReturn()
    {
        outFileLogger.writeLine("return");
    }  
}