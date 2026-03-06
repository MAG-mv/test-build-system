from conan import ConanFile
from conan.tools.cmake import CMakeToolchain, CMake, cmake_layout

class TestLib(ConanFile):
    name = "test-lib"
    version = "0.1"
    settings = "os", "compiler", "build_type", "arch"
    options = {"shared": [True, False]}
    default_options = {"shared": False}

    exports_sources = "CMakeLists.txt", "Library/*", "Tests/*", "cmake/*"

    def layout(self):
        cmake_layout(self)

    def requirements(self):
        self.requires("gtest/1.17.0")

    def generate(self):
        tc = CMakeToolchain(self)
        tc.cache_variables["BUILD_SHARED_LIBS"] = self.options.shared
        tc.generate()

    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()

    def package(self):
        cmake = CMake(self)
        cmake.install()