package haxeium;

import sys.io.Process;
import haxeium.AppDriver;

class AppRestarter {
	var cmd:String;
	var programmArgs:Null<Array<String>>;
	var workingFolder:Null<String>;
	var process:Process = null;

	public var logger:Null<LogFunction>;

	public function new(cmd:String, ?programmArgs:Array<String>, workingFolder:Null<String>) {
		this.cmd = cmd;
		this.programmArgs = programmArgs;
		this.workingFolder = workingFolder;
		this.logger = AppDriver.traceLogger;
	}

	public function start() {
		if (process != null) {
			kill();
		}
		var oldCwd = Sys.getCwd();
		var textInFolder = "";
		if (workingFolder != null) {
			Sys.setCwd(workingFolder);
			textInFolder = "in " + Sys.getCwd();
		}
		process = new Process(cmd, programmArgs, false);
		logger('--- launching test app "$cmd" ${programmArgs.join(" ")} (${process.getPid()}) $textInFolder');
		if (workingFolder != null) {
			Sys.setCwd(oldCwd);
		}
	}

	public function kill() {
		logger('--- shutting down test app (${process.getPid()})');
		var stdOut = process.stderr.readAll().toString();
		if (stdOut != "") {
			trace(stdOut);
		}
		var stdErr = process.stderr.readAll().toString();
		if (stdErr != "") {
			trace(stdErr);
		}
		process.kill();
		process.close();
		process = null;
	}
}
