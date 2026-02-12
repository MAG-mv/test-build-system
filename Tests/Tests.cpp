#include "TestLib.h"
#include "gtest/gtest.h"

TEST(HelloWorldLibTests, HelloWorldTest) 
{
    EXPECT_EQ(test_lib::HelloWorld(), "Hello World!");
}