# Haxium an automated UI testing framework (WIP)

framework consists of two parts, one driver that you have to include in your application (e.g. `new HaxeUIDriver("ws://127.0.0.1:9999")`). the other part is your testrunner application, where you use `AppDriver` to communicate with your application during testruns.
currently supports C++ and HTML5 applications based on HaxeUI (all tests were done using OpenFL flavour of HaxeUI, technically it can work with other backends, but that remains to be seen).

## installation

`lix download gh:AlexHaxe/haxeium`

## running samples

### building C++ app

```bash
cd samples/haxeui/button
lix download
lime build linux
haxe build.hxml
bin/TestMain
```

### building Html5 app

```bash
cd samples/haxeui/button
lix download
lime test html5
```

edit `TestMain.hx`
and change commented out lines to:

```haxe
  // lime test html5
  var driver = new AppDriver("localhost", 9999, null);

  // lime build linux
  // new AppDriver("localhost", 9999, new AppRestarter("./Main", [], "build/openfl/linux/bin"));
```

in second window run

```bash
cd samples/haxeui/button
haxe build.hxml
bin/TestMain
```
