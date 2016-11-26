# Protomak

Protomak is a template for C projects. It is based on the venerable GNU Make to provide a complete 
solution for building C projects. Its features are:

 * Simple project configuration. Simply fill in the required variables at `build_config.mk`.
 * Multi-arch compilations. Architecture specific parameters, as for example the compiler name, 
 will have to be configured at `build_rules.mk`.
 * Embedded unit testing and mocking for C based on ThrowTheSwitch Unity and CMock tools.
 
# Directory Layout

Protomak uses the following layout for the project files:

 * `src`. The source code files are expected to be here.
 * `test`. This folder will contain the unit tests and the testing framework files.
   * `test/unit`. Include here the unit tests you want. Each file containing unit tests is expected to have the name `test_*.c`.
   * `test/framework`. The Unity and CMock frameworks source files shall be contained here. You can configure CMock through the 
     file `test/framework/cmock_conf.yml`.
 * `bin`. The generated binary file with the compiled application will be placed here.
 * `build/$(ARCH)`. The intermediate build files will be placed in this folder.

# Build Configuration

The configuration of the build is performed through `build_config.mk`. The following variables are available:

 * `NAME`. Name of the application. The name will be used to generate the binary at the directory `bin`.
 * `ARCH`. The target architecture. As there are so many compilers out there, Protomak only supports native builds with `gcc` and `clang`. In order to cross compile, please read the section Cross Compiling below.
 * `SOURCE_PATHS`. Non-recursive list of paths where to find the source files.
 * `INCLUDE_PATHS`. Non-recursive list of include directories.
 * `LIBRARIES`. List of libraries with which to link the application. The library names have to be defined using its bare names. For example, use `pthread` in order to link with the pthread library.
 * `LIBRARY_PATHS`. List of search paths for non-standard libraries.
 * `SYMBOLS`. List of symbols to be defined in the application scope (used as `#define`)
 * `EXCLUDED_FILES`. Define the list of files to be excluded from the compilation.
 * Compilation flags for individual files. It's possible to define compilation flags for individual flags simply by defining the file name as a variable and defining the list of flags. For example, `src/main.c = -O0`. 
 
# Unit Test Configuration

Unity and CMock are an integral part of Protomak. A set of compilation rules has been included to provide the simplest configuration of unit tests. 

The unit test configuration is performed through the file `test/unit/test_cases.mk`. Each file in `test/unit/test_*.c` is linked only to the relevant sources that it tests. In order to define the file dependencies of a test file, define a variable with the same name in `test/unit/test_cases.mk`. For example, if you have a test file `test/unit/test_unit.c` that will test the functionality of the file `src/module.c`, you'll have to define the variable `test_unit = src/module.c`. It is possible to define more than one file for a single test file. If you have doubts, please take a look at the examples provided in the template.

## Mocks

In order to Mock interfaces, CMock is used. This library provides scripts to parse a header file and automatically create a `Mock%.c` file with the mock implementation. In order to define the set of headers from which to create mocks, please define the `MOCK_HEADERS` variable in `test/unit/test_cases.mk`.

The mock sources will be placed in the folder `test/unit/mocks`. This folder is automatically created and deleted so please do not place any files here that you don't want to loose. The mocks are compiled into a library at `test/unit/mocks/libmocks.a`. Each test case is automatically linked against this library.
 
# Command Line

## Building the Application

For the basic compilation, simply run make:
```bash
$ make
```

There are some special variables that allow further build customization. They can be placed in the `build_config.mk` file, but usually it's preferrable to use them from the command line. 

By default, the output of the build is minimalistic. However, if you want to have a verbose compilation, you can define the `V` flag. This is useful when using an IDE like Eclipse, that automatically generates an index from the build output. 

```bash
$ make V=1
```

By default, optimizations are enabled with `-O2`. If you want to disable them, run with the `NOOPT` flag.

```bash
$ make NOOPT=1
```

## Running the Unit Tests

In order to run the unit tests, a `unit` rule is provided:  

```bash
$ make unit
```

Verbose compilation is available for unit tests as well:

```bash
$ make unit V=1
```

# Cross Compiling

One of the problems that Protomak attempts to solve is cross compilation. There are many ways to do it through makefiles. Protomak provides one that attempts to be as simple as possible.

In order to configure a compiler for a different architecture, please create a new section in `build_rules.mk`, that contains the definitions for that specific architecture. The template for that section is:

```make
ifeq ($(ARCH), arm)
CROSS_COMPILER := arm-linux-gnueabi-
endif
```

Once this is configured, each time we want to compile for `ARM` architecture you will only have to call make for the proper architecture:

```bash
$ make ARCH=arm
```

The compilation intermediate files are placed in the `build/$(ARCH)` directory.

