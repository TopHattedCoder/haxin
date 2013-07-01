package haxin;
import haxe.macro.*;
import haxe.macro.Expr;
import haxe.macro.Type;
using haxe.macro.ExprTools;
using haxe.macro.TypeTools;
using haxe.macro.ComplexTypeTools;
import llvm.ir.*;
import llvm.support.*;
import llvm.*;
using StringTools;
class HaxeGen {
	var ctx:LLVMContext;
	public var fields:Array<Field>;
	public var name:String;
	public var path:String;
	public var pos:Position;
	public function new(path:String) {
		this.path = path;
		pos = {min: 0, max: 0, file: path};
		name = toHaxeName(path);
		fields = [];
		fields.push({
			name: "main",
			kind: FFun({
				ret: macro:Void,
				params: [],
				args: [],
				expr: macro trace("Hello, world!")
			}),
			pos: pos,
			access: [APublic, AStatic]
		});
		ctx = new LLVMContext();
	}
	public function toString():String {
        var td:TypeDefinition = {
            pos: pos,
            params: [],
            pack: [],
            name: name,
            meta: [],
            kind: TypeDefKind.TDClass(),
            isExtern: false,
            fields: fields
        };
        return new Printer.printTypeDeclaration(td);
	}
	static function haxeFilter(n:String, camel:Bool=true) {
		var notAllowed = "./+_-";
		for(i in 0...notAllowed.length) {
			var c = notAllowed.charAt(i);
			var found = 0;
			var count = 0;
			while((found = n.indexOf(c)) != -1 && count++ < 500) {
				if(camel)
					n = n.substr(0, found) + n.substr(found+1, 1) + n.substr(c.length+1);
				else
					n = n.substr(0, found) + "_" + n.substr(c.length);
			}
		}
		if(n == "main")
			n = '_$n';
		return n;
	}
	static function toHaxeName(n:String) {
		if(n.endsWith(".bc")) n = n.substr(0, n.length-3);
		n = n.substr(n.indexOf(".") + 1);
		n = n.substr(n.lastIndexOf("/") + 1);
		n = haxeFilter(n, true);
		var parts:Array<String> = n.split("::");
		var last = parts[parts.length -1];
		parts[parts.length - 1] = last.charAt(0).toUpperCase() + last.substr(1);
		n = parts.join(".");
		return n;
	}
}