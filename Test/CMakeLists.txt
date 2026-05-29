cmake_minimum_required(VERSION 3.12)

set(PROJECT_NAME GambitTest)

project(${PROJECT_NAME})

file(GLOB TEST_SOURCES "*.cpp") 

include_directories(${PROJECT_INCLUDE_DIR})

add_executable(${PROJECT_NAME} ${TEST_SOURCES} ${ALL_HEADERS})

set_target_properties(${PROJECT_NAME} PROPERTIES
    CXX_STANDARD 17
    CXX_EXTENSIONS OFF)

target_include_directories(GambitTest PRIVATE ${CMAKE_SOURCE_DIR}/../Include)
target_include_directories(${PROJECT_NAME} PRIVATE ${PROJECT_INCLUDE_DIR})

add_test(NAME ${PROJECT_NAME} COMMAND ${PROJECT_NAME})

set_target_properties(GambitTest PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/../Bin/Tests)
