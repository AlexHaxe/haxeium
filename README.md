# Haxium an automated UI testing framework

framework consists of two parts:

1. a driver that you have to include in your application (e.g. via `new HaxeUIDriver("ws://127.0.0.1:9999")`).
2. your testrunner application, where you use `AppDriver` to communicate with your application during testruns

it currently supports C++ and HTML5 applications based on HaxeUI (all tests were done using OpenFL flavour of HaxeUI, technically it can work with other backends, but that remains to be seen). testrunner runs as a C++ application.

## installation

`lix download gh:AlexHaxe/haxeium`

## getting started

in your application you want to add `new HaxeUIDriver("ws://127.0.0.1:9999");` somewhere at the start / during initialisation. you will also need to add haxium lib as a dependency to your project. `HaxeUIDriver` will try to connect to your testrunner application via websocket. once connected it will receive and execute commands that simulate inputs from a user.

next step is to create a testrunner app using utest and haxeium libraries. you will initialise `AppDriver` and instruct it to open the very websocket port your application is trying to connect to. you will also have to configure and pass an `AppRestarter` instance so it can launch your application whenever necessary.

then you start writing testcases the way you would when doing regular unittesting with utest. you can use some `ITest` compatible base classes to e.g. make your testcases auto restart your application between each testcase. they also provide a way to automatically take screenshots in case of test failures. so that you can see what state your application was in when a failure occured.

for your testcases there are commands that will send mouse or keyboard events and you can read and write any property of a HaxeUI component. there is also ways to find and address components. a `Wait` helper class provides a few blocking functions to wait e.g. for an element to become available. an `Actions` class allows to define a sequence of input actions, that you can apply multiple times.

## running samples

### building C++ app

for Linux builds

```bash
cd samples/haxeui/button
lix download
lime build linux # build app to test
haxe build.hxml # build testrunner

bin/TestMain # launch testrunner - will automatically start and kill app multiple times during run
```

for Windows builds

```bash
cd samples/haxeui/button # or samples/haxeui/login
lix download
lime build windows # build app to test
haxe buildWindows.hxml # build testrunner

bin/TestMain.exe # launch testrunner - will automatically start and kill app multiple times during run
```

### building Html5 app

```bash
cd samples/haxeui/button # or samples/haxeui/login
lix download
lime test html5 # build app to test and launch app in web browser
```

in second window run

```bash
cd samples/haxeui/button # or samples/haxeui/login
haxe buildHtml5.hxml # build testrunner

bin/TestMain # launch testrunner - will automatically reload app webpage multiple times during run
```
