# Haxium an automated UI testing framework (WIP)

framework consists of two parts, one driver that you have to include in your application (e.g. `new HaxeUIDriver("ws://127.0.0.1:9999")`). the other part is your testrunner application, where you use `AppDriver` to communicate with your application during testruns.
currently supports C++ and HTML5 applications based on HaxeUI (all tests were done using OpenFL flavour of HaxeUI, technically it can work with other backends, but that remains to be seen).

## installation

`lix download gh:AlexHaxe/haxeium`

## running samples

### building C++ app

for Linux builds

```bash
cd samples/haxeui/button
lix download
lime build linux
haxe build.hxml
bin/TestMain
```

for Windows builds

```bash
cd samples/haxeui/button
lix download
lime build windows
haxe buildWindows.hxml
bin/TestMain.exe
```

### building Html5 app

```bash
cd samples/haxeui/button
lix download
lime test html5
```

in second window run

```bash
cd samples/haxeui/button
haxe buildHtml5.hxml
bin/TestMain
```
