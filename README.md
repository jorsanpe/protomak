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
 * `build/<ARCH>`. The intermediate build files will be placed in this folder.
 
